module Precipitation_Handlers

	def on_receive_precipitation(payload)
		# "packet"=>"precipitation {\"precipitation\":[0.0,0.0,0.2],\"start\":1369072800}"
		data = payload['packet'].split(' ', 2)
		detail = JSON.parse(data[1])		# ==> {"precipitation"=>[0.0, 0.0, 0.0], "start"=>1369245600}
		precipitation = detail['precipitation']

		is_it_going_to_be_wet = 0
		is_it_going_to_be_wet = 1 if (precipitation[0] > RAINY_DAY_PRECIPITATION_THRESHOLD)
		history   = @cache.get("#{payload['data_store']}.history.precipitation_t0")
		yesterday = CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now.to_i-24*60*60)
		if history
			history.each do |d|
				if d['local_time'].to_i < yesterday
					is_it_going_to_be_wet = 1 if d['converted_value'] > RAINY_DAY_PRECIPITATION_THRESHOLD
				end
			end
		end
		
		t0   = { 'received' => payload['received'], 'packet' => "precipitation_t0 #{precipitation[0]}" }.to_json
		t1   = { 'received' => payload['received'], 'packet' => "precipitation_t1 #{precipitation[1]}" }.to_json
		t2   = { 'received' => payload['received'], 'packet' => "precipitation_t2 #{precipitation[2]}" }.to_json

		rain = { 'received' => payload['received'], 'packet' => "rainy_day #{is_it_going_to_be_wet}" }.to_json

		@exchange.publish t0,   :routing_key => 'udp_message_received'  
	  @exchange.publish t1,   :routing_key => 'udp_message_received'
	  @exchange.publish t2,   :routing_key => 'udp_message_received'
	  @exchange.publish rain, :routing_key => 'udp_message_received'

	  nil
	end

end
