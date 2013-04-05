module OW_Utils

	def http_get(url)
		url = URI.parse(url)
		req = Net::HTTP::Get.new(url.path)
		res = Net::HTTP.start(url.host, url.port) {|http|
		  http.request(req)
		}
		res.body
	end

	def publish_reading(target, reading)
		socket = UDPSocket.new
		socket.send("#{target} #{reading}", 0, UMMP_IP, UMMP_PORT)
	end

	def valid_target?(target)
		valid = target!=nil && MONITORS[target] && MONITORS[target][:ow_path]
		@log.error "Meter '#{target}' not defined." unless valid
		valid
	end

end