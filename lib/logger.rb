module Logger
  
  class Logger
    
    #globals #########################################################################################
    $log_file = "../identelligence.log"
    $write_to_logs = true #turns logging on / off
    #globals #########################################################################################
    
    #Log writer
    def self.write_to_log log_message
      
      date=Time.now.strftime("%d-%m-%Y_%H:%M:%S") #more detailed date as $date can't contain :
      
      unless $write_to_logs == false
        
        File.open($log_file,"a") do |log|
      
          log.puts "#{date} Fingerprint.rb #{log_message}"
         
        end
      end
        
    end #write_log
    
  end #class
   
end #module