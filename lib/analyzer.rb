#Simon Moffatt
#Analyzer core for Identelligence.  Role creation and exception analysis

require 'yaml'
require './lib/file_manager'
require './lib/logger'


module Analyzer

    #class globals
    @accounts = {} #system
    @role_users = {} #hash of roles mapped to array of users
    @role_entitlements = {} # hash of role entitlements per system
    @user_exceptions = {} # hash of user and entitlements that fall outside of the role framework
    @functions = [] #top down unique functional groupings

    
    #reads in accounts file
    def Analyzer.read_accounts path, col_separator, header
      
      @@accounts = File_Manager::read_file path, col_separator, header
      
    end
    
    #reads in identities file
    def Analyzer.read_identities path, col_separator, header
           
      @@identities = File_Manager::read_file path, col_separator, header
      
    end
        
    #analyses auth source, picks out attributes used for grouping and creates a unique array of them
    def Analyzer.get_functional_groups identities_function_index

      @@identities.each {|id| @functions << id[identities_function_index]}
      @functions.uniq! #de-dupe
      Logger::log_info "The following functional groups were identified:\n"
      @functions.each {|function| Logger::log_info function}
      
    end


    #analyses user entitlements based on a peer based functional grouping
    def Analyzer.perform_peer_analysis
      
      
      
    end


    #create shell roles
    def Analyzer.create_role_users identities_uid_index, identities_function_index
      
        #get list of unique of function groups from auth source
        get_functional_groups identities_function_index
        
        #populate the role_users hash with the names of the top down roles as keys
        @functions.each {|function| @role_users[function] = [] } #empty array will be for users of that role

        #populate role_users hash with users for each role
        @functions.each do |function| 
          
          @@identities.each do |identity| 
            @role_users[function] << identity[identities_uid_index] if function == identity[identities_function_index]
            Logger::print_to_screen "." 
          end 
          
          Logger::log_info "Adding users to role #{function}: #{@role_users[function].length}\n"
          
        end
       
        return @role_users
        
        
    end

    #create role entitlements
    def Analyzer.create_role_entitlements accounts_uid_index, accounts_mv_col_separator, accounts_permission_index
      
        #create keys for role_entitlements hash
        @role_users.keys.each {|role| @role_entitlements[role] = [] }

        #populate role entitlement hash with common entitlements on a per system level
        @role_users.keys.each do |role| #iterate over each shell role

            tmp = []  #temporary array storage
            @role_users[role].each  do |role_user| #iterate over each user assigned to that role
              
              @@accounts.each  do |acc| #iterate over the raw accounts feed
                
                #need to add some modular regex magic in here...
                if role_user == acc[accounts_uid_index] #if user in shell role matches uuid in account
                                   
                     #pull out entitlements and put in temporary array of arrays, but only if non-empty
                     tmp << acc[accounts_permission_index].split(accounts_mv_col_separator) unless acc[accounts_permission_index].to_s.empty?
                  
                end
                
              end #accounts iteration
              
            end #role_user user iteration
            
            #this is neat.  Performs intersection of user entitlement arrays.  brings back only similar entitlements.
            #this is basically role mining at 100% threshold similarity
            @role_entitlements[role] = tmp.empty? ? [] : tmp.inject(:&) 

            Logger::log_info "Defined entitlements for role #{role}: #{@role_entitlements[role].length} entitlements added:\n"
            @role_entitlements[role].each {|entitlement| Logger::log_info "#{entitlement}\n"}
                        
            
        end #role_user keys iteration
      
      #some debug stuff.  push to logger
            
      return @role_entitlements
      
    end 
    
    
    #analyze user exceptions
    def Analyzer.create_user_exceptions acc_uid_index, acc_permission_index, acc_mv_separator
      
      #create keys for user exceptions hash
      @@accounts.each {|account| @user_exceptions[account[acc_uid_index]] = [] }
      
      @@accounts.each do |account| #iterate over the accounts list
        
        tmp = [] #temp array containing all entitlements given by roles
        @role_users.each do |role,users| #iterate over the role users data
          
          if users.include? account[acc_uid_index] #if user if a member of a role
            
            #find exceptions for that role based on difference between actual account and role entitlements
            tmp << account[acc_permission_index].split(acc_mv_separator) - @role_entitlements[role] unless account[acc_permission_index].to_s.empty?
            
          end
          
          #@user_exceptions[account] << accounts[account] - role_entitlements[role] if users.include?(account)
          
        end #roles
       
        # intersect list of all exceptions to flush out true exceptions across all roles assigned
        # Eg.  user has actual permissions of= read;write;edit and is a member of role1:read and role2:write.  this will create exceptions of:
        # ([read,write,edit] - [read]) & ([read,write,edit] - [write]) = edit
        @user_exceptions[account[acc_uid_index]] = tmp.empty? ? [] : tmp.inject(:&)
        
        Logger::log_info "Identified entitlement exceptions for #{account[acc_uid_index]}: #{@user_exceptions[account[acc_uid_index]].length} found\n"  
        @user_exceptions[account[acc_uid_index]].each {|exception| Logger::log_info "#{exception}\n" }
          
      end #accounts
            
      return @user_exceptions
      
    end
    
    


    #read in shell roles and users if already created in external file
    def Analyzer.read_role_users role_users_input, role_users_input_col_separator, role_users_header, role_users_multivalue_separator
      
      #read in role user file array of arrays
      role_users_csv = File_Manager::read_file(role_users_input, role_users_col_separator, role_users_header) 
      
      #split out CSV into hash so can be used
      role_users_csv.each do |role| 
        
        @role_users[role[0]] = role[1].split(role_users_multivalue_separator)
        
        Logger::print_to_screen "."
        
      end
      
      return @role_users
      
    end


    #read in role entitlements if already created in external file
    def Analyzer.read_role_entitlements role_entitlements_input, role_entitlements_col_separator, role_entitlements_header, role_entitlements_mv
      
      #read in role user file array of arrays
      role_entitlements_csv = File_Manager::read_file(role_entitlements_input, role_entitlements_col_separator, role_entitlements_header) 
      
      #split out CSV into hash so can be used
      role_entitlements_csv.each do |role| 
        
        @role_entitlements[role[0]] = role[1].split(role_entitlements_mv)
        
        Logger::print_to_screen "."
        
      end
      
      return @role_entitlements
      
    end         
         
        
        
  end #class
  
