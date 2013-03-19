#Simon Moffatt
#To file and to screen log manager

module Logger
    
    #globals #########################################################################################
    DATE=Time.now.strftime("%d-%m-%Y_%H%M") #date formatter
    LOG_FILE = "logs/identelligence_#{DATE}.log"
    WRITE_TO_FILE = true #managed via yml file
    PRINT_TO_SCREEN = true #managed via yml file
    #globals #########################################################################################
    
    #Log writer
    def Logger.write_to_log message
      
      date=Time.now.strftime("%d-%m-%Y %H:%M:%S") #more detailed date as DATE can't contain :
      
      if WRITE_TO_FILE
        
        File.open(LOG_FILE,"a") do |log|
      
          log.puts "#{date} Identelligence #{message}"
         
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
   
