#Simon Moffatt
#Manages file reading and writing and data parsing

#requires
require 'rubygems'
require 'date'
require 'csv'
require 'json'
require 'builder'

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
  def File_Manager.write_file path, format, contents, type
    
    #init output file
    @output_file = File.open(path, 'w')
    
    if format.downcase == "csv" #CSV print out stuff
                        
        File_Manager.flatten_hash_for_writing(contents).each do |record| #bit of reformatting from hash to array of strings
          @output_file.puts record.to_s
        end
        
        @output_file.close
    end 
      
    if format.downcase == "json" #JSON print out stuff
 
          @output_file = File.open(path, 'w') do |file|
            file.write(JSON.pretty_generate(contents))
          end
    
    end
       
    if format.downcase == "XML"
      
        xml = Builder::XmlMarkup.new( :target => @output_file, :indent => 2 )
        xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        
        #formatting is different dep on contents
        if type == "RU" #role users
          
          xml.roles do #could be roles or users
          
            contents.each do | role, user | #could be role:user, role:entitlements, user:entitlements
            
              xml.role(:name=>role) do #could be :name => role or :id => user
              
                xml.users do #could be users or entitlements
                  user.each do |u| #could be user or entitlement
                    xml.user u #could be user or entitlement
                  end
                end
              
              end #end role
            
            end #end contents
          
          end #end roles         
  
        end #end type if
        
                
        if type == "RE" #role entitlements
          
          xml.roles do 
          
            contents.each do | role, entitlement | 
            
              xml.role(:name=>role) do 
              
                xml.entitlements do 
                  entitlement.each do |e| 
                    xml.entitlement e 
                  end
                end
              
              end #end role
            
            end #end contents
          
          end #end roles
          
          
          
        end
        
        if type == "UE" #user exceptions
          
          xml.users do 
          
            contents.each do | user, entitlement | 
            
              xml.user(:id=>user) do 
              
                xml.entitlements do 
                  entitlement.each do |e| 
                    xml.entitlement e 
                  end
                end
              
              end #end role
            
            end #end contents
          
          end #end roles
          
          
        end
        
        
           
    end #end XML if

  end #end function

  
  
  #monkey patch to hash.  probably needs moving out. returns array with string representation of hash contents
  def File_Manager.flatten_hash_for_writing hash

      array_of_strings = []
      hash.each do |key,value| 
        
        if value.to_s.empty?
          
          array_of_strings << "#{key},#{value}"
          
        else
        
          array_of_strings << "#{key},#{value.join(";")}"
            
        end

      end #ends hash each
      
      return array_of_strings

  end


end #module