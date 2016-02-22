module Pool_Handlers

  def after_received_pool_water_level(payload)

    history   = @cache.get("#{payload['data_store']}.history.pool_water_level")
    one_hour_ago = (CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now.to_i - (60 * 60) )) * 1000

    # most recent is at end, ie, oldest is first. we want the last five entries, and they should all be less than 1 hour old
    level_too_low = history[-5,5].select{ |h| h['local_time']>one_hour_ago }.select{ |h| h['converted_value']==1 }.empty?

    deep_enough = { 'received' => payload['received'], 'packet' => "pool_deep_enough #{(level_too_low ? 0 : 1)}" }.to_json
  
    @exchange.publish deep_enough,   :routing_key => 'udp_message_received'

    nil
  end

end
