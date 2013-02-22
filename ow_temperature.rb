require 'net/http'
require 'socket'
require 'log_wrapper'
require './config'

@log   	= Log_Wrapper.new

def http_get(url)
	url = URI.parse(url)
	req = Net::HTTP::Get.new(url.path)
	res = Net::HTTP.start(url.host, url.port) {|http|
	  http.request(req)
	}
	res.body
end

def get_temperature(target)
	temperature = nil
	@log.debug("Retrieve temperature of #{target}") do
		body = http_get("#{OW_HTTP_ROOT_URL}#{MONITORS[target][:ow_path]}")
		body.match(/\s(?<temperature>\d+\.\d*)</) do |match_data|
			temperature = match_data[:temperature]
		end
		@log.error "Temperature not found", :body => body unless temperature
	end
	temperature
end

def publish_temperature(target, temperature)
	socket = UDPSocket.new
	socket.send("#{target} #{temperature}", 0, UMMP_IP, UMMP_PORT)
end

def valid_target?(target)
	valid = target!=nil && MONITORS[target] && MONITORS[target][:ow_path]
	@log.error "Thermometer '#{target}' not defined." unless valid
	valid
end

if valid_target?(ARGV[0])
	temperature = get_temperature(ARGV[0])
	publish_temperature ARGV[0], temperature
end