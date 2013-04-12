module Cache_Handlers

	def on_receive_clear_caches(payload = nil)
		
		p "Flushing all caches..."
		@cache.flush

		p "Warming caches..."
		warm_caches
		p "...hot"

	  nil

	end

end