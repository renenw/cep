require 'socket'
require 'log_wrapper'
require 'open-uri'
require_relative '../config/config'

module Switch_Base

	def set_switch(target, pio, target_state)
		@log.debug("Set switch #{target} to #{target_state}") do
			open("#{OW_HTTP_ROOT_URL}#{MONITORS[target][:ow_path]}?#{pio}=#{target_state}&#{pio}=CHANGE")
		end
	end

	def publish_state(target, target_state)
		socket = UDPSocket.new
    switch = 1
    switch = 0 if target_state == 'OFF'
		socket.send("#{target} #{switch}", 0, UMMP_IP, UMMP_PORT)
	end

	def get_pio(target)
		pio = nil
		MONITORS[target][:ow_path].match(/\/(?<pio>PIO\.\d)\z/i) do |match_data|
			pio = match_data[:pio]
		end
		unless pio
			@log.error "No valid PIO defined for #{target}" 
			raise ArgumentError, "No valid PIO defined for #{target}"
		end
		pio
	end

	def valid_target?(target)
		valid = target!=nil && MONITORS[target] && MONITORS[target][:ow_path]
		unless valid
			@log.error "Switch '#{target}' not defined."
			raise ArgumentError, "Switch '#{target}' not defined."
		end
		valid
	end

	def valid_state?(state)
		valid = (state.upcase=="ON" || state.upcase=="OFF")
		unless valid
			@log.error "State '#{state}' not defined." 
			raise ArgumentError, "State '#{state}' not defined."
		end
		valid
	end

	def switch(target, target_state)
		if valid_target?(target) && valid_state?(target_state)
			target_state = target_state.upcase
			pio          = get_pio(target).upcase
			set_switch target, pio, target_state
			publish_state target, target_state
		end
	end

end
