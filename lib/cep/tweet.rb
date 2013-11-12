module Tweet

	Twitter.configure do |config|
		config.consumer_key 			= TWITTER_CONSUMER_KEY
	  config.consumer_secret 		= TWITTER_CONSUMER_SECRET
	  config.oauth_token 				= TWITTER_OAUTH_TOKEN
	  config.oauth_token_secret = TWITTER_OAUTH_TOKEN_SECRET
	end

  def tweet(message, guid)
  	message = {
			'guid' 		  => guid,
			'message' 	=> message
		}
		@fan_out_exchanges[:twitter][:exchange].publish message.to_json
  end

	def send_tweet(payload)
		begin
			#@log.debug('Tweeting', :guid => payload['guid']) do 
			#	@log.debug 'Tweeted', :guid => payload['guid'], :payload => Twitter.update(format_message(payload['message']))
			#end
		rescue Twitter::Error::Forbidden => e
			p "Twitter call failed: #{e}"
		end
	end

	protected

		def format_message(message)
			r   = message.strip
			dot = (message[-1,1]=='.')
      now = CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now).strftime("%H:%M:%S")
			if dot
				r = "#{r} #{now}."
			else
				r = "#{r} (#{now})."
			end
			r
		end

end
