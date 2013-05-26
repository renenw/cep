module Precipitation_Handlers

	def on_receive_precipitation(payload)
		
		data = payload['packet'].split(' ', 2)
		detail = JSON.parse(data[1])		# ==> {"precipitation"=>[13.3, 5.2, 1.9], "start"=>1369558800, "next_three_hours"=>3.7}
		precipitation = detail['precipitation']

		is_it_wet = 0
		is_it_wet = 1 if (precipitation[0] > RAINY_DAY_PRECIPITATION_THRESHOLD)

		historical_precipitation = 0
		history   = @cache.get("#{payload['data_store']}.history.precipitation_t0")
		yesterday = CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now.to_i-24*60*60) * 1000
		if history
			# most recent is at end, ie, oldest is first. ie, we want the first entry < 24 hours old
			history.each do |d|
				if d['local_time'].to_i > yesterday
					historical_precipitation = d['converted_value']
					is_it_wet = 1 if historical_precipitation > RAINY_DAY_PRECIPITATION_THRESHOLD
					break
				end
			end
		end
		
		t_next 	= { 'received' => payload['received'], 'packet' => "precipitation_3h #{detail['next_three_hours']}" }.to_json
		tx   		= { 'received' => payload['received'], 'packet' => "precipitation_tx #{historical_precipitation}" }.to_json
		t0   		= { 'received' => payload['received'], 'packet' => "precipitation_t0 #{precipitation[0]}" }.to_json
		t1   		= { 'received' => payload['received'], 'packet' => "precipitation_t1 #{precipitation[1]}" }.to_json
		t2   		= { 'received' => payload['received'], 'packet' => "precipitation_t2 #{precipitation[2]}" }.to_json

		rain = { 'received' => payload['received'], 'packet' => "rainy_day #{is_it_wet}" }.to_json

		@exchange.publish t_next, :routing_key => 'udp_message_received'  
		@exchange.publish tx,     :routing_key => 'udp_message_received'  
		@exchange.publish t0,   	:routing_key => 'udp_message_received'  
	  @exchange.publish t1,   	:routing_key => 'udp_message_received'
	  @exchange.publish t2,   	:routing_key => 'udp_message_received'
	  @exchange.publish rain, 	:routing_key => 'udp_message_received'

	  nil
	end

end
