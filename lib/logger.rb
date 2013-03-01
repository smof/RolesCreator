#Simon Moffatt
#To file and to screen log manager

module Logger
    
    #globals #########################################################################################
    $log_file = "../identelligence.log"
    $write_to_logs = true #turns logging on / off
    #globals #########################################################################################
    
    #Log writer
    def Logger.write_to_log message
      
      date=Time.now.strftime("%d-%m-%Y_%H:%M:%S") #more detailed date as $date can't contain :
      
      unless $write_to_logs == false
        
        File.open($log_file,"a") do |log|
      
          log.puts "#{date} Fingerprint.rb #{message}"
         
        end
      end
        
    end #write_log
    
    #write to screen
    def Logger.print_to_screen message
      
      #do something with message to push to console
      
      
    end
    
end #module
   
