#Simon Moffatt
#Manages file reading and writing and data parsing

#requires
require 'rubygems'
require 'date'
require 'csv'

module File_Manager

#globals #########################################################################################
@date=Time.now.strftime("%d-%m-%Y_%H%M") #date formatter
#globals #########################################################################################


  #file reader
  def File_Manager.read_file path, col_separator, header
    
    if File.exist? path
      
      #slurp in file.  might need to make this more effecient is file is large.  ie over 150k lines etc.
      file_contents = []
                 
      CSV.foreach(path, {:col_sep=>col_separator, :headers=>header, :return_headers=>false}) do |row|
    
        file_contents << row
        
      end
            
      return file_contents
      
    else
    
      puts "File #{path} doesn't exist.  Oops!" 
      return
      
    end
    
  end

  #file writer
  def File_Manager.write_file path, contents
    
    #init output file
    output_file = File.open(path, 'w')
    
    #basic puts but driven to open file
    contents.each do |record| 
      output_file.puts record.to_s
    end 
    
    output_file.close
    
  end
  
  

end #module


