module Switch_Handlers

	def on_receive_switch_on(payload)
		# "packet"=>"switch_on vegetable_patch"
		# switch_the_switch payload, 'on'
	  nil
	end

	def on_receive_switch_off(payload)
		# "packet"=>"switch_off vegetable_patch"
		# switch_the_switch payload, 'off'
	  nil
	end

	def switch_the_switch(payload, target_state)
		data = payload['packet'].scan(/[\w\.]+/)
		`ruby scripts/ow_switch.rb #{data[1]} #{target_state}`
	end

end