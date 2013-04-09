module Solenoid_Handlers

	def after_received_solenoid(payload)
		
		changed			= true
		on_duration = 0

		off 				= (payload['integer_value']==0)
		state 			= @cache.get("#{payload['data_store']}.reading.#{payload['source']}")
    changed 		= (state['reading'].to_i!=payload['integer_value']) if state
    on_duration	= payload['local_time'] - (state['local_time']/1000.0) if off && state

p "#{off} : #{state} : #{changed} : #{on_duration}"

    if changed
    	message = MONITORS[payload['source']][:name]
    	if off
    		message = "#{message} ran for #{CEP_Utils.duration_description(on_duration)}"
    	else
    		message = "#{message} switched on"
    	end

			if changed
	      log_message 'solenoid', (off ? :error : :info), message, payload
	      tweet       message, payload['guid']
	    end
  	end

	  payload

	end

end
