module Message_Logger

  LOG_LEVELS = [:trace, :debug, :info, :warn, :error]

	def log_message(message_type, log_level, message, guid = nil)
		message_type_sql 	= message_type.strip
		if validate?(message_type_sql, log_level, message, guid)
			guid_sql    			= ( guid ? "'#{guid}'" : 'null' )
			message_sql 			= message.gsub(/'/, '''''') 
			@mysql.query("insert into messages (message_type, log_level, guid, message, created_at) values ('#{message_type_sql}', '#{log_level.to_s}', #{guid_sql}, '#{message_sql}', now());")
		end
	end

  protected

	  def validate?(message_type, log_level, message, guid)
	  	if message_type.nil? || (message_type.length == 0)
	  		raise ArgumentError, 'Zero length or nil message can not be logged.'
	  	elsif !LOG_LEVELS.include?(log_level)
	  		raise ArgumentError, 'Invalid log level.'
	  	elsif  (!guid.nil? && guid.length!=36)
	  		raise ArgumentError, 'Either no guid, or a valid guid, is required.'
	  	end
	  	true
	  end

end

# create table messages (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, message_type varchar(50) NOT NULL, log_level varchar(20) NOT NULL, guid varchar(36), message varchar(500) NOT NULL, created_at datetime );
