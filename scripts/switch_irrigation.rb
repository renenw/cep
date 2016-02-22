require 'net/http'
require_relative '../config/config'

        def valid_target?(target)
                valid = target!=nil && MONITORS[target] && MONITORS[target][:controller] && MONITORS[target][:circuit]
                unless valid
                        raise ArgumentError, "Switch '#{target}' not defined."
                end
                valid
        end


def switch_circuit_on(target, duration)
	http = Net::HTTP.new(MONITORS[target][:controller])
	request = Net::HTTP::Put.new("/on?switch=#{MONITORS[target][:circuit]}&duration=#{duration}&#{target}")
	response = http.request(request)
end

def is_it_wet?
	http = Net::HTTP.new(API_DOMAIN, API_PORT)
	response = http.request_head('/api/30_camp_ground_road/is_it_wet?')
	(response['status']=~/200/ ? false : true)
end

def should_we_flick_the_switch?(target)
	answer = true
	if valid_target?(target)
		answer = !is_it_wet? unless MONITORS[target][:run_when_wet]
	end
	answer
end

switch   = ARGV[0]
duration = ARGV[1]

switch_circuit_on(switch, duration) if should_we_flick_the_switch?(switch)



#switch(ARGV[0], ARGV[1]) if should_we_flick_the_switch?(ARGV[0], ARGV[1])
