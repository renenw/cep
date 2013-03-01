require 'socket'
require 'log_wrapper'
require 'open-uri'
require_relative './config'

@log   	= Log_Wrapper.new( File.join(File.dirname(__FILE__), 'log.txt') )

def set_switch(target, pio, target_state)
	@log.debug("Set switch #{target} to #{target_state}") do
		open("#{OW_HTTP_ROOT_URL}#{MONITORS[target][:ow_path]}?#{pio}=#{target_state}&#{pio}=CHANGE")
	end
end

def publish_state(target, target_state)
	socket = UDPSocket.new
	socket.send("#{target} #{target_state}", 0, UMMP_IP, UMMP_PORT)
end

def get_pio(target)
	pio = nil
	MONITORS[target][:ow_path].match(/\/(?<pio>PIO\.\d)\z/i) do |match_data|
		pio = match_data[:pio]
	end
	@log.error "No valid PIO defined for #{target}" unless pio
	pio
end

def valid_target?(target)
	valid = target!=nil && MONITORS[target] && MONITORS[target][:ow_path]
	@log.error "Switch '#{target}' not defined." unless valid
	valid
end

def valid_state?(state)
	valid = (state.upcase=="ON" || state.upcase=="OFF")
	@log.error "State '#{state}' not defined." unless valid
	valid
end

def run(target, pio, target_state)
	target_state = target_state.upcase
	pio          = pio.upcase
	set_switch target, pio, target_state
	publish_state target, target_state
end

if valid_target?(ARGV[0]) && valid_state?(ARGV[1])
	pio = get_pio(ARGV[0])
	run(ARGV[0], pio, ARGV[1]) if pio
end

