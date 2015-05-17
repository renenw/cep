module Access_Handlers

	def on_receive_access(payload)
		
    message = "#{payload['data'].capitalize} accessed via the #{MONITORS[payload['source']][:name]}"

    broadcast_message_to_websockets 'access', message, payload
    log_message 'access', :error, message, payload
    #tweet       message, payload['guid']

	  nil

	end

end
