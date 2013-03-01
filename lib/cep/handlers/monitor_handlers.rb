module Monitor_Handlers

  def add_converted_values(payload)
  	payload.merge( { 'converted_value' => payload['float_value'] } )
  end

	def handle_pulse_specific_calculations(payload)
	  prior_pulses = @cache.fetch("#{payload['data_store']}.pulse.last.#{payload['source']}")
          unless prior_pulses
	    p "pulse miss"
	    prior_pulses = payload['integer_value']	# assume that we haven't seen this meter before. Therefore, first reading is 0 watt hours (or similar)
	    @mysql.query("select max(integer_value) as pulses from #{payload['data_store']}.events where source = '#{payload['source']}' and id < #{payload['event_id']};").each do |row|
	      prior_pulses = row['pulses']
	    end
	  end
	  if prior_pulses
	  	# leave the two step assignment for clarity
	    elapsed_pulses = payload['integer_value'] - prior_pulses
	    converted_value = elapsed_pulses
	    payload.merge!( { 'converted_value' => converted_value } )
	  end
	  @cache.set("#{payload['data_store']}.pulse.last.#{payload['source']}", payload['integer_value'])
	  payload
	end


	def after_received_pulse(payload)
		if payload['source'] =~ /electricity_/
			# pulse_to_watt_hours
			payload['converted_value'] = payload['converted_value'] * 10
		end
		payload
	end

end
