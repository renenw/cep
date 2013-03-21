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

	def on_receive_alarm_message(payload)
		
		description = CGI::unescape(payload['packet']).match(/\s(.+$)/)[0].strip
		log_levl    = :warn
		log_message = description.squeeze
		log_type    = 'notice'

    # if the event is of low importance, push the level down
    if description =~ /(Dis)?[aA]rming[\s]+Area [\d]+/
      log_level = :info
    end
    if description =~ /Alarm system reporting via phone failed/
      log_level = :info
    end

    # if a circuit has triggered, bump the event level up a notch
    if description =~ /Alarm\s+Area\s+\d+\s+Zone/
      log_level     = :error
      circuit       = description[/\d+\s*$/].strip
      zone          = ALARM_ZONE_DEFINITIONS[circuit] if ALARM_ZONE_DEFINITIONS[circuit]
      integer_value = circuit.to_i
      log_type      = 'activation'
      log_message   = "#{zone} alarm sensor activated (zone #{integer_value})"
    end

    broadcast_message_to_websockets log_type, log_message, payload
		log_message                     log_type, log_level, log_message, payload
		tweet                           "#{log_message}",   payload['guid']

		nil
	end

end
