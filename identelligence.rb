#!/usr/bin/env ruby
#Simon Moffatt Feb 2013
#Identity intelligence and RBAC acceleration utility
 
#requires
require 'rubygems'
require 'csv'

#my libs
require './lib/logger'
require './lib/file_manager'


module Identelligence

  class Analyzer

    #initialize globals
    def initialize
      
      #class globals
      @accounts = {} #system
      @role_users = {} #hash of roles mapped to array of users
      @role_entitlements = {} # hash of role entitlements per system
      @user_exceptions = {} # hash of user and entitlements that fall outside of the role framework
      @functions = [] #top down unique functional groupings
    
      #temporary initialization
      @@accounts = {"smof"=>["read","write"], "john"=>["read","edit"], "clare"=>["execute", "read"], "vicki"=>["blog"]}
      @@identities = [["smof","IT"], ["john","Sales"], ["clare","Sales"], ["vicki","PR"]]
      
    end
    
    
    #analyses auth source, picks out attributes used for grouping and creates a unique array of them
    def get_functional_groups

      @@identities.each {|id| @functions << id[1]}
      @functions.uniq! #de-dupe
      @functions.each {|func| puts func}
      
    end

    #create shell roles
    def create_shell_roles
      
        #populate the role_users hash with the names of the top down roles as keys
        @functions.each {|f| @role_users[f] = [] } #empty array will be for users of that role

        #populate role_users hash with users for each role
        @functions.each do |f| 
          
          @@identities.each {|id| @role_users[f] << id[0] if f == id[1] } 
        
        end
 
        role_users.each {|role,users| puts "This role: #{role}, contains the following users: #{users}"}
        
        return @role_users
        
        
    end

    #create role entitlements
    def create_role_entitlements
      
        #create keys for role_entitlements hash
        @role_users.keys.each {|role| @role_entitlements[role] = [] }

        #populate role entitlement hash with common entitlements on a per system level
        @role_users.keys.each do |role| 

            tmp = []  #temporary array storage
            @role_users[role].each {|role_user| @@accounts.each {|acc| tmp << acc[1] if role_user == acc[0] } } #store array of all user perms
            @role_entitlements[role] = tmp.inject(:&) #succint code to do an intersection of user entitlement arrays using &

        end
      
      @role_entitlements.each {|role,entitlements| puts "This role #{role}, contains the following entitlements: #{entitlements}"}
      
      
    end 
        
  end #class
  

  #run through
  puts "Starting analyzer..."
  puts "======================================================================"
  analyzer = Identelligence::Analyzer.new
  puts "The following unique functional groups will be used..."
  analyzer.get_functional_groups
  puts "======================================================================"
  puts "The following are the shell roles that have been created..."
  analyzer.create_shell_roles
  puts "======================================================================"
  puts "The following entitlements have been created for the following roles..."
  analyzer.create_role_entitlements
  puts "======================================================================"
  puts "Writing out the role objects"
  File_Manager::write_file "roles.csv", @role_users
  puts "Finito :)"  
  
  

end #module