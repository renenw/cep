module Message_Logger

  LOG_LEVELS = [:trace, :debug, :info, :warn, :error]

	def log_message(message_type, log_level, message, payload)
		payload = {
			'data_store'		=> payload['data_store'],
			'source' 	 		  => payload['source'],
			'message_type'  => message_type.strip,
			'log_level' 		=> log_level,
			'message' 			=> message.strip,
			'guid' 				  => payload['guid']
		}

		if validate?(payload)
			@exchange.publish payload.to_json, :routing_key => 'message_logger'
		end
	end

  def message_logger(payload)
  	  guid_sql    			= ( payload['guid'] ? "'#{payload['guid']}'" : 'null' )
			message_sql 			= payload['message'].gsub(/'/, '''''') 
			@mysql.query("insert into messages (source, message_type, log_level, guid, message, created_at) values ('#{payload['source']}', '#{payload['message_type']}', '#{payload['log_level']}', #{guid_sql}, '#{message_sql}', now());")
			nil
	end

  protected

	  def validate?(payload)
	  	if payload['message'].nil? || (payload['message'].length == 0)
	  		raise ArgumentError, 'Zero length or nil message can not be logged.'
	  	elsif !LOG_LEVELS.include?(payload['log_level'].to_sym)
	  		raise ArgumentError, 'Invalid log level.'
	  	elsif  (!payload['guid'].nil? && payload['guid'].length!=36)
	  		raise ArgumentError, 'Either no guid, or a valid guid, is required.'
	  	end
	  	true
	  end

end

# create table messages (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, source varchar(50) NOT NULL, message_type varchar(50) NOT NULL, log_level varchar(20) NOT NULL, guid varchar(36), message varchar(500) NOT NULL, created_at datetime );
