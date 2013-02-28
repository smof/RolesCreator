#Managers file reading and writing and data parsing

#requires
require 'rubygems'
require 'date'
require 'csv'

class File_Manager

#globals #########################################################################################
@date=Time.now.strftime("%d-%m-%Y_%H%M") #date formatter
ROLE_USERS = "../role_users_#{@date}.csv"
ROLE_ENTITLEMENTS = "../role_entitlements_#{@date}.csv"
#globals #########################################################################################


  #file reader
  def self.read_file path
    
    if File.exist? path, col_separator
      
      #slurp in file.  might need to make this more effecient is file is large.  ie over 150k lines etc.
      file_contents = CSV.read(path,{:col_sep=>col_separator})
            
    else
    
      puts "File #{path} doesn't exist.  Oops!" 
      return
      
    end
    
    
    
    
  end

  #file writer
  def self.write_file path, contents
    
    #init output file
    output_file = File.open(path, 'w')
    
    #basic puts but driven to open file
    contents.each do |record| 
      output_file.puts record.to_s 
    end 
    
    output_file.close
    
  end
  
  

end #class

