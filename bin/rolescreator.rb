#!/usr/bin/env ruby
#Simon Moffatt
#Identity intelligence and RBAC acceleration utility
#Command Line Interface main module
#RoleCreator

#requires
require 'rubygems'
require 'yaml'

#RolesCreator
require_relative '../lib/analyzer' #core analyzer
require_relative '../lib/file_manager' #read/write files
require_relative '../lib/logger' #console and file logger

module RolesCreator

  #slurp in YML config options
  #yml_file = '../config/config.yml'
  #yml_file = File.expand_path('../../config/config.yml', __FILE__)
  yml_file = File.absolute_path('./config/config.yml')
  
  if File.exist? yml_file
    
      config = YAML::load(File.open(yml_file))
      Logger::log_info "YML file #{yml_file} loaded successfully \n"
      
  else
    
      Logger::log_error "YML config file #{yml_file} not found. Exiting \n"
      exit
        
  end
  
  #analyzer options pulled in from config.yml
  CREATE_ROLE_USERS = config['analyzer']['create_role_users']
  CREATE_ROLE_ENTITLEMENTS = config['analyzer']['create_role_entitlements']
  CREATE_USER_EXCEPTIONS = config['analyzer']['create_user_exceptions']
  PERFORM_PEER_ANALYSIS = config['analyzer']['perform_peer_analysis']
  
  #inputs
  IDS_INPUT = config['input']['identities']['file']
  IDS_INPUT_COL_SEPARATOR = config['input']['identities']['col_separator']
  IDS_INPUT_HEADER_LINE = config['input']['identities']['header_line']
  IDS_UID_INDEX = config['input']['identities']['uuid_index']
  IDS_FUNCTION_INDEX = config['input']['identities']['function_index']
  
  ACC_INPUT = config['input']['accounts']['file']
  ACC_INPUT_COL_SEPARATOR = config['input']['accounts']['col_separator']
  ACC_INPUT_HEADER_LINE = config['input']['accounts']['header_line']
  ACC_UID_INDEX = config['input']['accounts']['uuid_index']
  ACC_PERMISSION_INDEX = config['input']['accounts']['permission_index']
  ACC_MULTIVALUE_COL_SEPARATOR = config['input']['accounts']['multivalue_separator']  
  
  ROLE_USERS_INPUT = config['input']['role_users']['file']
  ROLE_USERS_INPUT_COL_SEPARATOR = config['input']['role_users']['col_separator']
  ROLE_USERS_INPUT_HEADER_LINE = config['input']['role_users']['header_line']
  ROLE_USER_MULTIVALUE_SEPARATOR = config['input']['role_users']['multivalue_separator']
  
  ROLE_ENTS_INPUT = config['input']['role_entitlements']['file']
  ROLE_ENTS_INPUT_COL_SEPARATOR = config['input']['role_entitlements']['col_separator']
  ROLE_ENTS_INPUT_HEADER_LINE = config['input']['role_entitlements']['header_line']
  ROLE_ENTS_MULTIVALUE_SEPARATOR = config['input']['role_entitlements']['multivalue_separator']
  
  #outputs
  ROLE_USERS_OUTPUT_FORMAT = config['output']['role_users']['format']
  ROLE_USERS_OUTPUT = config['output']['role_users']['file']
  
  ROLE_ENTS_OUTPUT_FORMAT = config['output']['role_entitlements']['format']  
  ROLE_ENTS_OUTPUT = config['output']['role_entitlements']['file']
  
  USER_EXCEPTIONS_OUTPUT_FORMAT = config['output']['user_exceptions']['format']
  USER_EXCEPTIONS_OUTPUT = config['output']['user_exceptions']['file']
  
    
  #run through
  Logger::log_info "Starting...\n"
      
  #see what options have been set in the config file
  if CREATE_ROLE_USERS
    
    Logger::log_info "Creating new shell roles...\n"
    
    #read in auth source
    Logger::log_info "Reading identities...\n"
    Analyzer::read_identities IDS_INPUT, IDS_INPUT_COL_SEPARATOR, IDS_INPUT_HEADER_LINE
    
    
    #create shell roles
    Logger::log_info "Creating roles...\n"
    role_users = Analyzer::create_role_users IDS_UID_INDEX, IDS_FUNCTION_INDEX
    
    #write out to file
    Logger::log_info "Writing roles file...\n"
    File_Manager::write_file ROLE_USERS_OUTPUT, ROLE_USERS_OUTPUT_FORMAT, role_users, "RU"
        
  else
 
    #only bother with this stuff if other options are true and role user file needs to be read in
    if CREATE_ROLE_ENTITLEMENTS || CREATE_USER_EXCEPTIONS
    
       Logger::log_info "Reading in shell roles...\n"
       roles = Analyzer::read_role_users ROLE_USERS_INPUT, ROLE_USERS_INPUT_COL_SEPARATOR, 
            ROLE_USERS_INPUT_HEADER_LINE, ROLE_USER_MULTIVALUE_SEPARATOR
                         
    end
    
  end
  
  if CREATE_ROLE_ENTITLEMENTS
  
      Logger::log_info "Reading accounts file...\n"
      Analyzer::read_accounts ACC_INPUT, ACC_INPUT_COL_SEPARATOR, ACC_INPUT_HEADER_LINE
      
      Logger::log_info "Creating role entitlements...\n"
      role_entitlements = Analyzer::create_role_entitlements ACC_UID_INDEX, ACC_MULTIVALUE_COL_SEPARATOR, ACC_PERMISSION_INDEX
      
      Logger::log_info "Writing role entitlements file...\n"     
      File_Manager::write_file ROLE_ENTS_OUTPUT, ROLE_ENTS_OUTPUT_FORMAT, role_entitlements, "RE"  
        
  else
    
      #only both with this is user exceptions need creating
      if CREATE_USER_EXCEPTIONS
        
        Logger::log_info "Reading role users...\n"
        Analyzer::read_accounts ACC_INPUT, ACC_INPUT_COL_SEPARATOR, ACC_INPUT_HEADER_LINE
                
        Logger::log_info "Reading role entitlements...\n"
        Analyzer::read_role_entitlements ROLE_ENTS_INPUT, ROLE_ENTS_COL_SEPARATOR, 
                ROLE_ENTS_HEADER_LINE, ROLE_ENTS_MULTIVALUE_SEPARATOR 
      end   
          
  end
  
  if CREATE_USER_EXCEPTIONS
            
      Logger::log_info "Creating user exceptions...\n"
      user_exceptions = Analyzer::create_user_exceptions ACC_UID_INDEX, ACC_PERMISSION_INDEX, ACC_MULTIVALUE_COL_SEPARATOR
      
      Logger::log_info "Writing user exceptions file...\n"
      File_Manager::write_file USER_EXCEPTIONS_OUTPUT, USER_EXCEPTIONS_OUTPUT_FORMAT, user_exceptions, "UE"
        
  end
  
  
  if PERFORM_PEER_ANALYSIS
    
    #do something around calling peer analysis function.  requires auth source and ACC data 
    
  end
  
  

end #module