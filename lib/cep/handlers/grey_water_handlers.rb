module Grey_Water_Handlers

	def after_received_grey_water_flooded(payload)

		changed = false		
		flooded = (payload['integer_value']==1)
		state 	= @cache.get("#{payload['data_store']}.reading.#{payload['source']}")
    changed = (state['reading'].to_i!=payload['integer_value']) if state

    p "grey #{flooded}"

#    if changed && state
			message = "Grey water cistern flooded"
			message = "Grey water cistern *NO LONGER* flooded" unless flooded
      log_message 'grey_water', :error, message, payload
      tweet       message, payload['guid']
#  	end

	  payload

	end

end
