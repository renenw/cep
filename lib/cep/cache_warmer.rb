module Cache_Warmer

	def warm_caches
		@cache.set("monitors", MONITORS)
		warm_message_history_cache
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