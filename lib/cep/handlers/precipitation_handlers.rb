module Precipitation_Handlers

	def on_receive_precipitation(payload)
		# "packet"=>"precipitation {\"precipitation\":[0.0,0.0,0.2],\"start\":1369072800}"
		data = payload['packet'].split(' ', 2)
		detail = JSON.parse(data[1])		# ==> {"precipitation"=>[0.0, 0.0, 0.0], "start"=>1369245600}
		precipitation = detail['precipitation']

		is_it_going_to_rain = 0
		is_it_going_to_rain = 1 if (precipitation[0] > RAINY_DAY_PRECIPITATION_THRESHOLD)
		
		t0   = { 'received' => payload['received'], 'packet' => "precipitation_t0 #{precipitation[0]}" }.to_json
		t1   = { 'received' => payload['received'], 'packet' => "precipitation_t1 #{precipitation[1]}" }.to_json
		t2   = { 'received' => payload['received'], 'packet' => "precipitation_t2 #{precipitation[2]}" }.to_json
		rain = { 'received' => payload['received'], 'packet' => "rainy_day #{is_it_going_to_rain}" }.to_json

		@exchange.publish t0,   :routing_key => 'udp_message_received'  
	  @exchange.publish t1,   :routing_key => 'udp_message_received'
	  @exchange.publish t2,   :routing_key => 'udp_message_received'
	  @exchange.publish rain, :routing_key => 'udp_message_received'

	  nil
	end

end