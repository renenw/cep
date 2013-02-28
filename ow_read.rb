require 'net/http'
require 'socket'
require 'log_wrapper'
require_relative './config'

@log   	= Log_Wrapper.new( File.join(File.dirname(__FILE__), 'log.txt') )

def http_get(url)
	url = URI.parse(url)
	req = Net::HTTP::Get.new(url.path)
	res = Net::HTTP.start(url.host, url.port) {|http|
	  http.request(req)
	}
	res.body
end

def get_reading(target)
	reading = nil
	@log.debug("Retrieve reading of #{target}") do
		body = http_get("#{OW_HTTP_ROOT_URL}#{MONITORS[target][:ow_path]}")
		body.match(/<TD>\s*(?<reading>[\d\.]+)<\/TD>/) do |match_data|
			reading = match_data[:reading]
		end
		@log.error "Meter for reading not found", :url => "#{OW_HTTP_ROOT_URL}#{MONITORS[target][:ow_path]}", :body => body unless reading
	end
	reading
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

def run(target)
	reading = get_reading(ARGV[0])
	publish_reading ARGV[0], reading if reading
end

run(ARGV[0]) if valid_target?(ARGV[0])