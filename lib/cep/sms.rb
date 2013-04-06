module SMS

	def sms(message, guid)
  	message = {
			'guid' 		  => guid,
			'message' 	=> message
		}
		@fan_out_exchanges[:sms][:exchange].publish message.to_json
  end

	def send_sms(payload)
		@log.debug('SMSing', :guid => payload['guid']) do 
			message 	= URI::encode(payload['message'])
			username 	= URI::encode(SMS_USERNAME)
			password 	= URI::encode(SMS_PASSWORD)
			CEP_Utils.http_get("http://bulksms.2way.co.za:5567/eapi/submission/send_sms/2/2.0?username=#{username}&password=#{password}&message=#{message}&msisdn=#{SMS_RECIPIENT_LIST}")
		end
	end

end

