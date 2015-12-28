module Grey_Water_Handlers

  def after_received_grey_water_flooded(payload)

    flooded = (payload['integer_value']==1)

    message = "Grey water cistern flooded"
    message = "Grey water cistern *NO LONGER* flooded" unless flooded
    
    log_message 'grey_water', :error, message, payload
    sms         message, payload['guid']
    tweet       message, payload['guid']
  
    payload

  end

  def after_received_basement_sump_flooded(payload)
    
    flooded = (payload['integer_value']==1)
    
    message = "Basement sump flooded"
    message = "Basement sump *NO LONGER* flooded" unless flooded

    log_message 'basement_sump', :error, message, payload
    sms         message, payload['guid']
    tweet       message, payload['guid']

    payload
    
  end

end
