require 'net/http'
require 'socket'
require 'log_wrapper'
require_relative '../config/config'
require_relative 'ow_utils'

include OW_Utils

@log = Log_Wrapper.new( File.join(File.dirname(__FILE__), 'log.txt') )

def read_sensed_value(target)
	reading = nil
	@log.debug("Reading #{target.gsub('latch','sensed')}") do
		body = http_get("#{OW_HTTP_ROOT_URL}#{MONITORS[target][:ow_path]}".gsub('latch', 'sensed'))
		body.match(/sensed.\d<\/B><\/TD><TD>(?<reading>\w+)/) do |match_data|
			reading = match_data[:reading]
		end
	end
	reading
end

def run(target)
		sensed = read_sensed_value(target)
		publish_reading target, (sensed.downcase=='yes' ? 0 : 1) if sensed
end

run(ARGV[0]) if valid_target?(ARGV[0])

