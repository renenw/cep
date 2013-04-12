module Alarm_Handlers

	def after_received_alarm_armed(payload)

    off     = (payload['integer_value']==0)
		guid    = payload['guid']
    changed = true

		state = @cache.get("#{payload['data_store']}.reading.alarm_armed")
    changed = (state['reading'].to_i!=payload['integer_value']) if state

		broadcast_message_to_websockets 'alarm', (off ? 'Off' : 'Armed'), payload
    if changed
      log_message                   'alarm', :info, (off ? 'Alarm disarmed' : 'Alarm armed'), payload
      tweet                         "#{(off ? 'Disarmed' : 'Armed')}", guid
    end

    payload

	end

	def on_receive_alarm_message(payload)
		
		description = CGI::unescape(payload['packet']).match(/\s(.+$)/)[0].strip
		log_level    = :warn
		log_message = description.squeeze
		log_type    = 'notice'

    # if the event is of low importance, push the level down
    if description =~ /(Dis)?[aA]rming[\s]+Area [\d]+/
      log_level = :info
      log_type    = 'alarm'
    end

    # if a circuit has triggered, bump the event level up a notch
    if description =~ /Alarm\s+Area\s+\d+\s+Zone/
      log_level     = :error
      circuit       = description[/\d+\s*$/].strip
      zone          = ALARM_ZONE_DEFINITIONS[circuit] if ALARM_ZONE_DEFINITIONS[circuit]
      integer_value = circuit.to_i
      log_type      = 'alarm'
      log_message   = "#{zone} alarm sensor activated (zone #{integer_value})."
    end

    # some of the alarm messages are interesting...
    if log_type=='notice'
      if description =~ /system reporting via phone failed/i
        log_level = :info
      else
        log_level = :error
      end
    end

    if log_level == :error
	    broadcast_message_to_websockets log_type, log_message, payload
			tweet                           log_message,   payload['guid']
		end
		log_message                     log_type, log_level, log_message, payload

		nil
	end

end
