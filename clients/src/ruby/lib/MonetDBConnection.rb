# The contents of this file are subject to the MonetDB Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the MonetDB Database System.
#
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
# Copyright August 2008-2009 MonetDB B.V.
# All Rights Reserved.

# Implements the MAPI communication protocol

require 'socket'
require 'time'
require 'hasher'
require 'MonetDBExceptions'
require 'iconv' # utf-8 support

Q_TABLE               = "1" # SELECT operation
Q_UPDATE              = "2" # INSERT/UPDATE operations
Q_CREATE              = "3" # CREATE/DROP TABLE operations
Q_TRANSACTION         = "4" # TRANSACTION
Q_PREPARE             = "5"
Q_BLOCK               = "6" # QBLOCK message

MSG_REDIRECT          = '^' # auth redirection through merovingian
MSG_QUERY             = '&'
MSG_SCHEMA_HEADER     = '%'
MSG_INFO              = '!' # info response from mserver
MSG_TUPLE             = '['
MSG_PROMPT            =  nil


REPLY_SIZE            = '250'

MAX_AUTH_ITERATION    = 10  # maximum number of atuh iterations (thorough merovingian) allowed
 
MONET_ERROR           = -1

class MonetDBConnection
 
  
  # enable debug output
  @@DEBUG               = false

  # hour in seconds, used for timezone calculation
  @@HOUR                = 3600

  # maximum size (in bytes) for a monetdb message to be sent
  @@MAX_FB_SIZE         = 100
  @@MAX_SB_SIZE         = 0
  @@MAX_MESSAGE_SIZE    = @@MAX_FB_SIZE + @@MAX_SB_SIZE
  
  # endianness of a message sent to the server
  @@CLIENT_ENDIANNESS   = "BIG"
  
  # MAPI protocols supported by the driver
  @@SUPPORTED_PROTOCOLS = [ 8, 9 ]
  
  attr_reader :socket, :auto_commit, :transactions
  
  # Instantiates a new MonetDBConnection object
  # * user: username (default is monetdb)
  # * passwd: password (default is monetdb)
  # * lang: language (default is sql) 
  # * host: server hostanme or ip  (default is localhost)
  # * port: server port (default is 50000)
  
  def initialize(user = "monetdb", passwd = "monetdb", lang = "sql", host="127.0.0.1", port = "50000")
    @user = user
    @passwd = passwd
    @lang = lang.downcase
    @host = host
    @port = port

    @client_endianness = @@CLIENT_ENDIANNESS
    
    @auth_iteration = 0
    @connection_established = false
        
    @transactions = MonetDBTransaction.new # handles a pool of transactions (generates and keeps track of savepoints)
    
    if @@DEBUG == true
      require 'logger'
    end
    
  end
  
  # Connect to the database, creates a new socket
  def connect(db_name = 'demo', auth_type = 'SHA1')
    @database = db_name
    @auth_type = auth_type
    
    @socket = TCPSocket.new(@host, @port)  
    
    real_connect
  end
  

  # perform a real connection; retrieve challenge, proxy through merovinginan, build challenge and set the timezone
  def real_connect
    
    server_challenge = retrieve_server_challenge()
    
    if server_challenge != nil
      salt = server_challenge.split(':')[0]
      @server_name = server_challenge.split(':')[1]
      @protocol = server_challenge.split(':')[2].to_i
      @supported_auth_types = server_challenge.split(':')[3].split(',')
      @server_endianness = server_challenge.split(':')[4]
      if @protocol == 9
        @pwhash = server_challenge.split(':')[5]
      end
    else
      raise MonetDBConnectionError, "Error: server returned an empty challenge string."
    end
    
    # The server supports only RIPMED168 or crypt as an authentication hash function, but the driver does not.
    if @supported_auth_types.length == 1
      auth = @supported_auth_types[0]
      if auth.upcase == "RIPEMD160" or auth.upcase == "CRYPT"
        raise MonetDBConnectionError, auth.upcase + " " + ": algorithm not supported by ruby-monetdb."
      end
    end
    
    
    # If the server protocol version is not 8: abort and notify the user.
    if @@SUPPORTED_PROTOCOLS.include?(@protocol) == false
      raise MonetDBProtocolError, "Protocol not supported. The current implementation of ruby-monetdb works with MAPI protocols #{@@SUPPORTED_PROTOCOLS} only."
    
    elsif mapi_proto_v8?
      reply = build_auth_string_v8(@auth_type, salt, @database)
    elsif mapi_proto_v9?
      reply = build_auth_string_v9(@auth_type, salt, @database)
    end
             
    if @socket != nil
      @connection_established = true

      send(reply)
      
      monetdb_auth = receive
      
      if monetdb_auth == ""
        # auth succedeed, now set the timezone and proceed
        
        set_timezone
        
      else
        if monetdb_auth == MSG_PROMPT
          true
        elsif monetdb_auth[0].chr == MSG_REDIRECT
        #redirection
          if merovingian?
            if @auth_iteration <= 10
              @auth_iteration += 1
              real_connect
            else
              raise MonetDBConnectionError, "Merovingian: too many iterations while proxying."
            end
          elsif mserver?
          # reinitialize a connection
            @socket.close
            connect(@database, @auth_type)
          else
            @connection_established = false
            raise MonetDBQueryError, monetdb_auth
          end
        elsif monetdb_auth[0].chr == MSG_INFO
          raise MonetDBConnectionError, monetdb_auth
        end
      end
    end
  end

  def savepoint
    @transactions.savepoint
  end

  # Formats a <i>command</i> string so that it can be parsed by the server
  def format_command(x)
    return "X" + x + "\nX"
  end
  

  # send an 'export' command to the server
  def set_export(id, idx, offset)
    send(format_command("export " + id.to_s + " " + idx.to_s + " " + offset.to_s ))
  end
  
  # send a 'reply_size' command to the server
  def set_reply_size
    send(format_command(("reply_size " + REPLY_SIZE)))
  end

  # Disconnect from server
  def disconnect()
    if  @connection_established 
      begin
        @socket.close
      rescue => e
        $stderr.print e
      end
    else
      $stderr.print "No connection established."
    end
  end
  
  # send data to a monetdb5 server instance and returns server's response
  def send(data)
    encode_message(data).each do |m|
      @socket.write(m)
    end
  end
  
  # receive data from a monetdb5 server instance
  def receive
    is_final, chunk_size = recv_decode_hdr
    
    data = @socket.recv(chunk_size)
    
    if is_final == false 
      while is_final == false
        is_final, chunk_size = recv_decode_hdr
        data +=  @socket.recv(chunk_size)
      end
    end
    
    if data.length == 0      
      data = MSG_PROMPT
    end
    
    return data
  end
    
  # Builds and authentication string given the parameters submitted by the user (MAPI protocol v8).
  # 
  def build_auth_string_v8(auth_type, salt, db_name)
    # seed = password + salt
    if (auth_type.upcase == "MD5" or auth_type.upcase == "SHA1") and @supported_auth_types.include?(auth_type.upcase)
      auth_type = auth_type.upcase
      digest = Hasher.new(auth_type, @passwd+salt)
      hashsum = digest.hashsum
    elsif auth_type.downcase == "plain" or not  @supported_auth_types.include?(auth_type.upcase)
      auth_type = 'plain'
      hashsum = @passwd + salt
      
    elsif auth_type.downcase == "crypt"
      auth_type =  @supported_auth_types[@supported_auth_types.index(auth_type)+1]
      $stderr.print "The selected hashing algorithm is not supported by the Ruby driver. #{auth_type} will be used instead."
      digest = Hasher.new(auth_type, @passwd+salt)
      hashsum = digest.hashsum
    else
      # The user selected an auth type not supported by the server.
      raise MonetDBConnectionError, "#{auth_type} not supported by the server. Please choose one from #{@supported_auth_types}"
      
    end    
    # Build the reply message with header
    reply = @client_endianness + ":" + @user + ":{" + auth_type + "}" + hashsum + ":" + @lang + ":" + db_name + ":"
  end

  #
  # Builds and authentication string given the parameters submitted by the user (MAPI protocol v9).
  # 
  def build_auth_string_v9(auth_type, salt, db_name)
    if (auth_type.upcase == "MD5" or auth_type.upcase == "SHA1") and @supported_auth_types.include?(auth_type.upcase)
      auth_type = auth_type.upcase
      # Hash the password
      pwhash = Hasher.new(@pwhash, @passwd)
      
      digest = Hasher.new(auth_type, pwhash.hashsum + salt)
      hashsum = digest.hashsum
        
    elsif auth_type.downcase == "plain" # or not  @supported_auth_types.include?(auth_type.upcase)
      # Keep it for compatibility with merovingian
      auth_type = 'plain'
      hashsum = @passwd + salt
    elsif @supported_auth_types.include?(auth_type.upcase)
      if auth_type.upcase == "RIPEMD160"
        auth_type =  @supported_auth_types[@supported_auth_types.index(auth_type)+1]
        $stderr.print "The selected hashing algorithm is not supported by the Ruby driver. #{auth_type} will be used instead."
      end
      # Hash the password
      pwhash = Hasher.new(@pwhash, @passwd)
        
      digest = Hasher.new(auth_type, pwhash.hashsum + salt)
      hashsum = digest.hashsum  
    else
      # The user selected an auth type not supported by the server.
      raise MonetDBConnectionError, "#{auth_type} not supported by the server. Please choose one from #{@supported_auth_types}"
    end    
    # Build the reply message with header
    reply = @client_endianness + ":" + @user + ":{" + auth_type + "}" + hashsum + ":" + @lang + ":" + db_name + ":"
  end


  # builds a message to be sent to the server
  def encode_message(query = "")
    message = Array.new
   
    if @client_endianness == @@CLIENT_ENDIANNESS
      
      message_size = query.length    
      data_delimiter_begin = 0
      if message_size <= @@MAX_MESSAGE_SIZE
        data_delimiter_end = message_size
      else
        data_delimiter_end = @@MAX_MESSAGE_SIZE
      end
      
      is_final = false
      
      if @@DEBUG
      
      end
      i = 0
      while is_final != true
        if message_size <= @@MAX_MESSAGE_SIZE 
        # the query fits one packet
          if message_size < @@MAX_FB_SIZE
            fb =  message_size
            sb = 0
          else
            fb = @@MAX_FB_SIZE
            sb = message_size - fb   
          end
          fb = fb << 1
          fb = fb | 00000001
         
          data_delimiter_end = data_delimiter_begin + message_size
          message << fb.chr + sb.chr + query[data_delimiter_begin...data_delimiter_end]
        
      
          is_final = true
        else
          
          fb = @@MAX_FB_SIZE
          sb = @@MAX_SB_SIZE
          
          fb = (fb << 1) | 00000000
          
          message << fb.chr + sb.chr + query[data_delimiter_begin...data_delimiter_end]
          data_delimiter_begin = data_delimiter_end
          data_delimiter_end = data_delimiter_begin + @@MAX_MESSAGE_SIZE
         
          message_size -= @@MAX_MESSAGE_SIZE 
        end  
        i += 1
      end
    end
    
    return message.freeze
  end

  # Used as the first step in the authentication phase; retrives a challenge string from the server.
  def retrieve_server_challenge()
    server_challenge = receive
  end
  
  # reads and decodes the header of a server message
  def recv_decode_hdr()
    if @socket != nil
      
      fb = @socket.recv(1)
      sb = @socket.recv(1)
      
      # Use execeptions handling to keep compatibility between different ruby
      # versions.
      #
      # Chars are treated differently in ruby 1.8 and 1.9
      # try do to ascii to int conversion using ord (ruby 1.9)
      # and if it fail fallback to character.to_i (ruby 1.8)
      begin
        fb = fb[0].ord
        sb = sb[0].ord
      rescue NoMethodError => one_eight
        fb = fb[0].to_i
        sb = sb[0].to_i
      end
      
      chunk_size = (sb << 7) | (fb >> 1)
      
      is_final = false
      if ( (fb & 1) == 1 )
        is_final = true
        
      end

      # return the size of the chunk (in bytes)
      return is_final, chunk_size  
    else  
        raise MonetDBSocketError
    end 
  end
  
  # Sets the time zone according to the Operating System settings
  def set_timezone()
    tz = Time.new
    tz_offset = tz.gmt_offset / @@HOUR
      
    if tz_offset <= 9 # verify minute count!
      tz_offset = "'+0" + tz_offset.to_s + ":00'"
    else
      tz_offset = "'+" + tz_offset.to_s + ":00'"
    end
    query_tz = "sSET TIME ZONE INTERVAL " + tz_offset + " HOUR TO MINUTE;"
    
    # Perform the query directly within the method
    send(query_tz)
    response = receive
  
    if response[0] == MSG_INFO
      raise MonetDBQueryError, response
    end
  end
  
  # Turns auto commit on/off
  def set_auto_commit(flag=true)
    if flag == false 
      ac = " 0"
    else 
      ac = " 1"
    end

    send(format_command("auto_commit " + ac))
    
    response = receive
    if response == MSG_PROMPT
      @auto_commit = flag
    elsif response[0] == MSG_INFO
      raise MonetDBCommandError, response
      return
    end
    
  end
  
  # Check the auto commit status (on/off)
  def auto_commit?
    @auto_commit
  end
  
  # Check if monetdb is running behind the merovingian proxy and forward the connection in case
  def merovingian?
    if @server_name.downcase == 'merovingian'
      true
    else
      false
    end
  end
  
  def mserver?
    if @server_name.downcase == 'monetdb'
      true
    else
      false
    end
  end
  
  # Check which protocol is spoken by the server
  def mapi_proto_v8?
    if @protocol == 8
      true
    else
      false
    end
  end
  
  def mapi_proto_v9?
    if @protocol == 9
      true
    else
      false
    end    
  end
end

# handles transactions and savepoints. Can be used to simulate nested transactions.
class MonetDBTransaction  
  def initialize
    @id = 0
    @savepoint = ""
  end
  
  def savepoint
    @savepoint = "monetdbsp" + @id.to_s
  end
  
  def release
    prev_id
  end
  
  def save
    next_id
  end
  
  private
  def next_id
    @id += 1
  end
  
  def prev_id
    @id -= 1
  end
  
end
