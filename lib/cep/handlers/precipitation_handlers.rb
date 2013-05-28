module Precipitation_Handlers

	def on_receive_precipitation(payload)
		
		data = payload['packet'].split(' ', 2)
		detail = JSON.parse(data[1])		# ==> {"precipitation"=>[13.3, 5.2, 1.9], "start"=>1369558800, "next_three_hours"=>3.7}
		precipitation = detail['precipitation']

		is_it_wet = 0

		# look forwards
		is_it_wet = 1 if precipitation[0] > RAINY_DAY_PRECIPITATION_THRESHOLD
		is_it_wet = 1 if (precipitation[0] + precipitation[1] + precipitation[2]) > RAINY_DAY_PRECIPITATION_THRESHOLD * 2
		
		# now look backwards
		_24hour_precipitation = nil
		_48hour_precipitation = nil
		_72hour_precipitation = nil

		_24hours_ago = CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now.to_i-24*60*60) * 1000
		_48hours_ago = CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now.to_i-48*60*60) * 1000
		_72hours_ago = CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now.to_i-72*60*60) * 1000

		history   = @cache.get("#{payload['data_store']}.history.precipitation_t0")
		if history
			# most recent is at end, ie, oldest is first. ie, we want the first entry < 24 hours old
			history.each do |d|
				_24hour_precipitation = d['converted_value'] if d['local_time'].to_i > _24hours_ago && _24hour_precipitation.nil?
				_48hour_precipitation = d['converted_value'] if d['local_time'].to_i > _48hours_ago && _48hour_precipitation.nil?
				_72hour_precipitation = d['converted_value'] if d['local_time'].to_i > _72hours_ago && _72hour_precipitation.nil?
			end
		end
		
		is_it_wet = 1 if _24hour_precipitation > RAINY_DAY_PRECIPITATION_THRESHOLD
		is_it_wet = 1 if (_72hour_precipitation + _48hour_precipitation + _24hour_precipitation) > RAINY_DAY_PRECIPITATION_THRESHOLD * 2
		
		t_next 	= { 'received' => payload['received'], 'packet' => "precipitation_3h #{detail['next_three_hours']}" }.to_json
		tv   		= { 'received' => payload['received'], 'packet' => "precipitation_tv #{_72hour_precipitation}" }.to_json
		tw   		= { 'received' => payload['received'], 'packet' => "precipitation_tw #{_48hour_precipitation}" }.to_json
		tx   		= { 'received' => payload['received'], 'packet' => "precipitation_tx #{_24hour_precipitation}" }.to_json
		t0   		= { 'received' => payload['received'], 'packet' => "precipitation_t0 #{precipitation[0]}" }.to_json
		t1   		= { 'received' => payload['received'], 'packet' => "precipitation_t1 #{precipitation[1]}" }.to_json
		t2   		= { 'received' => payload['received'], 'packet' => "precipitation_t2 #{precipitation[2]}" }.to_json

		rain = { 'received' => payload['received'], 'packet' => "rainy_day #{is_it_wet}" }.to_json

		@exchange.publish t_next, :routing_key => 'udp_message_received'
		@exchange.publish tv,     :routing_key => 'udp_message_received'
		@exchange.publish tw,     :routing_key => 'udp_message_received'
		@exchange.publish tx,     :routing_key => 'udp_message_received'  
		@exchange.publish t0,   	:routing_key => 'udp_message_received'  
	  @exchange.publish t1,   	:routing_key => 'udp_message_received'
	  @exchange.publish t2,   	:routing_key => 'udp_message_received'
	  @exchange.publish rain, 	:routing_key => 'udp_message_received'

	  nil
	end

end
