module Solenoid_Handlers

	def on_receive_solenoid(payload)
		
		#time    = Time.at(payload['local_time'])
		#off     = (payload['integer_value']==0)
		#guid    = payload['guid']

		#broadcast_message_to_websockets 'alarm', (off ? 'Off' : 'Armed'), payload
		#log_message                     'alarm', :info, (off ? 'Alarm disarmed' : 'Alarm armed'), payload
		#tweet                           "#{(off ? 'Disarmed' : 'Armed')} (#{time.strftime("%H:%M:%S")}).", guid
		
		p "Solenoid!!!"
		p payload

	  payload

	end

end
