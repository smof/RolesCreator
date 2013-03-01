#!/usr/bin/env ruby
#Simon Moffatt
#Identity intelligence and RBAC acceleration utility
#Command Line Interface main module

#requires
require 'rubygems'

#Identelligence
require './lib/analyzer' #core analyzer
require './lib/file_manager' #read/write files

module Identelligence

  #run through
  puts "Starting analyzer..."
  puts "======================================================================"
  analyzer = Analyzer.new
  puts "The following unique functional groups will be used..."
  analyzer.get_functional_groups
  puts "======================================================================"
  puts "The following are the shell roles that have been created..."
  roles = analyzer.create_shell_roles
  puts "======================================================================"
  puts "The following entitlements have been created for the following roles..."
  role_entitlements = analyzer.create_role_entitlements
  puts "======================================================================"
  puts "The following user entitlement exceptions have been identified..."
  user_exceptions = analyzer.create_user_exceptions
  puts "======================================================================"
  puts "Writing output..."
  File_Manager::write_file Analyzer::ROLE_USERS_OUTPUT, Analyzer::flatten_hash_for_writing(roles)
  File_Manager::write_file Analyzer::ROLE_ENTITLEMENTS_OUTPUT, Analyzer::flatten_hash_for_writing(role_entitlements)
  File_Manager::write_file Analyzer::USER_EXCEPTIONS_OUTPUT, Analyzer::flatten_hash_for_writing(user_exceptions)
  puts "======================================================================"
  puts "Finito :)"  

end #module