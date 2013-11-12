require 'net/http'
require_relative 'ow_switch_base.rb'

include Switch_Base

@log = Log_Wrapper.new( File.join(File.dirname(__FILE__), 'log.txt') )

def is_it_wet?
	http = Net::HTTP.new(API_DOMAIN, API_PORT)
	response = http.request_head('/api/30_camp_ground_road/is_it_wet?')
	(response['status']=='200')
end

def should_we_flick_the_switch?(target, target_state)
	answer = true
	if valid_target?(target)
		unless MONITORS[target][:run_when_wet]
			answer = is_it_wet? if target_state.downcase=='on'
		end
	end
	answer
end

switch(ARGV[0], ARGV[1]) if should_we_flick_the_switch?(ARGV[0], ARGV[1])
