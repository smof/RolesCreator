#Simon Moffatt
#To file and to screen log manager

module Logger
    
    #static globals #########################################################################################
    DATE=Time.now.strftime("%d-%m-%Y_%H%M") #date formatter
    #static globals #########################################################################################
    
    #slurp in log settings from YML - don't like this as reading YML twice as reading in rolescreator.rb too...
    yml_file = File.expand_path('../../conf/config.yml', __FILE__)
  
    if File.exist? yml_file
    
        config = YAML::load(File.open(yml_file))
              
    else
    
        exit
        
    end
    
    #globals from YML #################################################################################
    LOG_FILE = "#{config['logging']['log_file_location']}_#{DATE}"
    #LOG_FILE = "rolescreator#{DATE}.log"
    WRITE_TO_FILE = config['logging']['write_to_file']
    #WRITE_TO_FILE = true #prints output to file
    PRINT_TO_SCREEN = config['logging']['print_to_screen']
    #PRINT_TO_SCREEN = true #prints output to console
    #globals from YML #################################################################################
    
    
    #Log writer
    def Logger.write_to_log message
      
      date=Time.now.strftime("%d-%m-%Y %H:%M:%S") #more detailed date as DATE can't contain :
      
      if WRITE_TO_FILE
        
        File.open(LOG_FILE,"a") do |log|
      
          log.puts "#{date} RolesCreator #{message}"
         
        end
      end
        
    end #write_log
    
    #write to screen
    def Logger.print_to_screen message
      
      if PRINT_TO_SCREEN
      
        STDOUT.print message
          
      end
          
    end
    
    #error to log
    def Logger.log_error message
      
      message = "ERROR #{message}"
      write_to_log message
      print_to_screen message
      
    end
    
    #info to log
    def Logger.log_info message
      
      message = "INFO #{message}"
      write_to_log message
      print_to_screen message
      
    end
    
    #error to log
    def Logger.log_warning message
      
      message = "WARNING #{message}"
      write_to_log message
      print_to_screen message
      
    end
    
    
    
end #module
   
