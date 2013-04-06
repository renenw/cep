class CEP_Utils

	def self.get_local_time(timezone, event_time_in_utc)
	  tz = TZInfo::Timezone.get(timezone)
	  tz.utc_to_local(event_time_in_utc)
	end

	def self.duration_description(secs)
		descriptions 	=	  [[60, :second, :seconds], [60, :minute, :minutes], [24, :hour, :hours], [7, :day, :days], [1000, :week, :weeks]].map{ |count, single, plural|
										  	if secs > 0
										      secs, n = secs.divmod(count)
										      "#{n.to_i} #{(n==1 ? single : plural)}" if n.to_i > 0
										    end
										  }.compact.reverse
		result = descriptions.pop
		result = "#{descriptions.join(' ')} and #{result}" if descriptions.length > 0
		(result ? result : '0 seconds')
	end

	def self.http_get(url)
		uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)
		response = http.request(Net::HTTP::Get.new(uri.request_uri))
		raise IOError, "Invalid HTTP response code (#{response.code} received)" if response.code != "200"
		response.body
	end

end

