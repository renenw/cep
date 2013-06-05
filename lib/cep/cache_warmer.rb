module Cache_Warmer

	def warm_caches
		@cache.set("monitors", MONITORS)
		warm_message_history_cache
		warm_readings_caches
	end

	def warm_readings_caches
		p "Warm caches: histories and sources (readings)"
		MONITORS.each_key do |source|
			warm_history_caches_source(source)
		end
		p "done with histories and sources"
	end

	def warm_history_caches_source(source)

		p "Source: #{source}"

		###########
		history = []
		@mysql.query("select local_time, reading from #{DATA_STORE}.readings where source = '#{source}' order by local_time desc limit #{CACHED_HISTORY_ITEMS}").each do |row|
		  converted_value = nil
		  # TODO: Make this work for guages... ie, cache miss converted values are wrong if they are read from here as converted values, well, just that (see monitor_handlers.rb)
		  converted_value = row['reading'].to_f if MONITORS[source][:monitor_type] == :gauge
		  history << { 'local_time' => row['local_time']*1000, 'reading' => row['reading'], 'converted_value' => converted_value }
		end
		history.reverse!
		@cache.set("#{DATA_STORE}.history.#{source}", history)

		############
	  sources = {}
    @mysql.query("select source, max(created_at) as _created_at from #{DATA_STORE}.events group by source").each do |row|
      sources[row['source']] = row['_created_at'].to_i
    end
	  @cache.set("#{DATA_STORE}.sources", sources)

	end

	def warm_message_history_cache

		p "Warm cache: messages"
	 	
	 	history = []
    @mysql.query("select * from messages order by id desc limit #{MESSAGE_LOGGER_HISTORY_ITEMS}").each do |row|
    	history << {
										'data_store'		=> DATA_STORE,
										'source' 	 		  => row['source'],
										'message_type'  => row['message_type'],
										'log_level' 		=> row['log_level'],
										'message' 			=> row['message'],
										'guid' 				  => row['guid'],
										'local_time' 		=> CEP_Utils.get_local_time(SETTINGS['timezone'], row['created_at'].to_i)*1000,
									}
    end

    history.reverse!

    history.each do |payload|
    	@cache.array_append("#{DATA_STORE}.messages", payload, MESSAGE_LOGGER_HISTORY_ITEMS)
    end

    @cache.set("#{DATA_STORE}.messages.cached", 1)

	end

end