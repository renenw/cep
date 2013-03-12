module Alarm_Handlers

	def after_received_alarm_armed(payload)
		
		time    = Time.at(payload['local_time'])
		off     = (payload['integer_value']==0)
		guid    = payload['guid']

		broadcast_message_to_websockets 'alarm', (off ? 'Off' : 'Armed'), payload
		log_message                     'alarm', :info, (off ? 'Alarm disarmed' : 'Alarm armed'), payload
		tweet                           "#{(off ? 'Disarmed' : 'Armed')}. Set at #{time.strftime("%H:%M:%S")}.", guid
		
	  payload

	end

end
