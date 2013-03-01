module Message_Logger

	def log_message(message_type, log_level, message, payload)
		p "#{log_level}, #{message}"
	end

end