#Simon Moffatt
#Analyzer core for Identelligence.  Role creation and exception analysis

require 'yaml'
require './lib/file_manager'
require './lib/logger'


  class Analyzer

    #load YML properties
    yml_file = 'config.yml'
    config = YAML::load(File.open(yml_file))

    #general constants
    DATE=Time.now.strftime("%d-%m-%Y_%H%M") #date formatter
    MULTIVALUE_DELIMITER = ";" #for splitting multi-value entitlements
        
    #data files ###########################################################################################
    #authoritative source input
    IDENTITIES_INPUT = config['inputs']['identities']['file']
    #IDENTITIES_INPUT = "identities.csv" # authoritative source of users from HR etc
    IDENTITIES_INPUT_COL_SEPARATOR = "," #column / field separator
    IDENTITIES_INPUT_HEADER_LINE = true # if first row contains column names
    IDENTITIES_UUID_INDEX = 1 #the field in the HR file that contains the unique identifier.  employeeid; email address etc
    IDENTITIES_FUNCTION_INDEX = 5 #the field in the HR file contains the attribute for creating roles.  job-title; dept; team etc
  
    #raw system entitlements files input
    ACCOUNTS_INPUT = "accounts.csv" # accounts input file of entitlements from target system
    ACCOUNTS_INPUT_COL_SEPARATOR = ","
    ACCOUNTS_INPUT_HEADER_LINE = true # if first row contains column names
    ACCOUNTS_UUID_INDEX = 0 # the field in the Accounts file that contains the unique identifier.  AccountID; email address etc;
    ACCOUNTS_PERMISSION_INDEX = 2 #the field in the Accounts file that contains the permissions to mine. group; memberOf etc
  
    #if role mining has already been completed
    ROLE_USERS_INPUT = "role_users.csv" # role1,user1;user2 etc
    ROLE_USERS_INPUT_COL_SEPARATOR = ","
    ROLE_USERS_INPUT_HEADER_LINE = false
    ROLE_ENTITLEMENTS_INPUT = "role_entitlements.csv" # role1,read;edit etc
    ROLE_ENTITLEMENTS_INPUT_COL_SEPARATOR = ","
    ROLE_ENTITLEMENTS_INPUT_HEADER_LINE = false
  
    #outputs
    ROLE_USERS_OUTPUT = "identelligence_role_users_#{DATE}.csv"
    ROLE_ENTITLEMENTS_OUTPUT = "identelligence_role_entitlements_#{DATE}.csv"
    USER_EXCEPTIONS_OUTPUT = "identelligence_user_exceptions_#{DATE}.csv"
    
    #initialize globals
    def initialize
      

                  
      #class globals
      @accounts = {} #system
      @role_users = {} #hash of roles mapped to array of users
      @role_entitlements = {} # hash of role entitlements per system
      @user_exceptions = {} # hash of user and entitlements that fall outside of the role framework
      @functions = [] #top down unique functional groupings
    
      #temporary initialization
      #@@accounts = {"smof"=>["read","write"], "john"=>["read","edit"], "clare"=>["execute", "read"], "vicki"=>["blog"]}
      @@accounts = File_Manager::read_file(ACCOUNTS_INPUT,ACCOUNTS_INPUT_COL_SEPARATOR, ACCOUNTS_INPUT_HEADER_LINE)
      #@@accounts = [["smof",["read","write"]],["vicki",["read"]],["john",["edit"]]]
      #@@identities = [["smof","IT"], ["john","Sales"], ["clare","Sales"], ["vicki","PR"]]
      @@identities = File_Manager::read_file(IDENTITIES_INPUT,IDENTITIES_INPUT_COL_SEPARATOR, IDENTITIES_INPUT_HEADER_LINE)
      
    end
    
    #convert hash into array of formatted strings ready for writing out.  not sure if a simpler way?

    
    #analyses auth source, picks out attributes used for grouping and creates a unique array of them
    def get_functional_groups

      @@identities.each {|id| @functions << id[IDENTITIES_FUNCTION_INDEX]}
      @functions.uniq! #de-dupe
      @functions.each {|func| puts func}
      
    end

    #create shell roles
    def create_shell_roles
      
        #populate the role_users hash with the names of the top down roles as keys
        @functions.each {|function| @role_users[function] = [] } #empty array will be for users of that role

        #populate role_users hash with users for each role
        @functions.each do |function| 
          
          @@identities.each {|identity| @role_users[function] << identity[IDENTITIES_UUID_INDEX] if function == identity[IDENTITIES_FUNCTION_INDEX] } 
        
        end
 
        @role_users.each {|role,users| puts "Role: #{role}, contains the following users: #{users}"}
        
        return @role_users
        
        
    end

    #create role entitlements
    def create_role_entitlements
      
        #create keys for role_entitlements hash
        @role_users.keys.each {|role| @role_entitlements[role] = [] }

        #populate role entitlement hash with common entitlements on a per system level
        @role_users.keys.each do |role| #iterate over each shell role

            tmp = []  #temporary array storage
            @role_users[role].each  do |role_user| #iterate over each user assigned to that role
              
              @@accounts.each  do |acc| #iterate over the raw accounts feed
                
                #need to add some modular regex magic in here...
                if role_user == acc[ACCOUNTS_UUID_INDEX] #if user in shell role matches uuid in account
                                   
                     #pull out entitlements and put in temporary array of arrays, but only if non-empty
                     tmp << acc[ACCOUNTS_PERMISSION_INDEX].split(MULTIVALUE_DELIMITER) unless acc[ACCOUNTS_PERMISSION_INDEX].to_s.empty?
                  
                end
                
              end #accounts iteration
              
            end #role_user user iteration
            
            #this is neat.  Performs intersection of user entitlement arrays.  brings back only similar entitlements.
            #this is basically role mining at 100% threshold similarity
            @role_entitlements[role] = tmp.inject(:&) 

        end #role_user keys iteration
      
      #some debug stuff.  push to logger
      @role_entitlements.each {|role,entitlements| puts "Role #{role}, contains the following entitlements: #{entitlements}"}
      
      return @role_entitlements
      
    end 
    
    
    #analyze user exceptions
    def create_user_exceptions
      
      #create keys for user exceptions hash
      @@accounts.each {|account| @user_exceptions[account[ACCOUNTS_UUID_INDEX]] = [] }
      
      @@accounts.each do |account| #iterate over the accounts list
        
        tmp = [] #temp array containing all entitlements given by roles
        @role_users.each do |role,users| #iterate over the role users data
          
          if users.include? account[ACCOUNTS_UUID_INDEX] #if user if a member of a role
            
            #find exceptions for that role based on difference between actual account and role entitlements
            tmp << account[ACCOUNTS_PERMISSION_INDEX].split(MULTIVALUE_DELIMITER) - @role_entitlements[role] unless account[ACCOUNTS_PERMISSION_INDEX].to_s.empty?
            
          end
          
          #@user_exceptions[account] << accounts[account] - role_entitlements[role] if users.include?(account)
          
        end #roles
       
        # intersect list of all exceptions to flush out true exceptions across all roles assigned
        # Eg.  user has actual permissions of= read;write;edit and is a member of role1:read and role2:write.  this will create exceptions of:
        # ([read,write,edit] - [read]) & ([read,write,edit] - [write]) = edit
        @user_exceptions[account[ACCOUNTS_UUID_INDEX]] = tmp.inject(:&)
          
      end #accounts
      
      #debug stuff - push to logger
      @user_exceptions.each {|user,entitlements| puts "User #{user}, is assigned the following exception entitlements: #{entitlements}"}
      
      return @user_exceptions
      
    end
    
    
    #monkey patch to hash.  probably needs moving out. returns array with string representation of hash contents
    def self.flatten_hash_for_writing hash

      array_of_strings = []
      hash.each do |key,value| 
        
        if value.to_s.empty?
          
          array_of_strings << "#{key},#{value}"
          
        else
        
          array_of_strings << "#{key},#{value.join(";")}"
            
        end

      end
      
      return array_of_strings

    end

    #read in shell roles and users if already created and exist in external file
    def read_shell_roles
      
      File_Manager::read_file 
      roles_a.each {|role| roles_h[role[0]] = role[1]}
      
      
    end

         
        
        
  end #class
  
