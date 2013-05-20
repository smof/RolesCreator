#Simon Moffatt
#Manages file reading and writing and data parsing

#requires

require 'rubygems'
require 'date'
require 'csv'
require 'json'
require 'builder'
require_relative './logger'

module File_Manager

  #file reader
  def File_Manager.read_file path, col_separator, header
    
    if File.exist? path
      
      #slurp in file.  might need to make this more effecient is file is large.  ie over 150k lines etc.
      file_contents = []
      
      path = File.absolute_path(path) #first arg is path, second is directory relative to current process, so dir above ./lib/file_manager.rb in this case
                 
      CSV.foreach(path, {:col_sep=>col_separator, :headers=>header, :return_headers=>false}) do |row|
    
        file_contents << row
        #Logger::print_to_screen "." 
                
      end
            
      return file_contents
      
    else
    
      Logger::log_error "File #{path} not found. Exiting \n" 
      exit
      
    end
    
  end

  #file writer
  def File_Manager.write_file path, format, contents, type
    
    path = File.absolute_path(path) #first arg is path, second is directory relative to current process, so dir above ./lib/file_manager.rb in this case
    
    #init output file
    @output_file = File.open(path, 'w')
        
    if format.downcase == "csv" #CSV print out stuff
                        
        File_Manager.flatten_hash_for_writing(contents).each do |record| #bit of reformatting from hash to array of strings
          
          @output_file.puts record.to_s
          #Logger::print_to_screen "."
                   
        end
        
        @output_file.close
    end 
      
    if format.downcase == "json" #JSON print out stuff
 
          @output_file = File.open(path, 'w') do |file|
            file.write(JSON.pretty_generate(contents))
            #Logger::print_to_screen "."
          end
    
    end
       
    if format.downcase == "xml"
      
        xml = Builder::XmlMarkup.new( :target => @output_file, :indent => 2 )
        xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        
        #formatting is different dep on contents
        if type == "RU" #role users
          
          xml.roles do #roles tag
          
            contents.each do | role, user | #iterate over role users hash
            
              xml.role(:name=>role) do #role tag name=role
              
                xml.users do #users tag
                  user.each do |u| #iterate over array of users
                    xml.user u #user tag
                    #Logger::print_to_screen "."
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
                    #Logger::print_to_screen "."
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
                        #Logger::print_to_screen "."
                      end
                    
                  end
              
                end #end user
            
              end #end contents
            
          end #end exceptions

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