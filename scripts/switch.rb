require 'net/http'
require_relative '../config/config'

def switch_on(target, duration)
  http = Net::HTTP.new(MONITORS[target][:controller])
  request = Net::HTTP::Put.new("/on?switch=#{MONITORS[target][:circuit]}&duration=#{duration}&#{target}")
  response = http.request(request)
end

def valid_target?(target)
  valid = target!=nil && MONITORS[target] && MONITORS[target][:controller] && MONITORS[target][:circuit]
  unless valid
    p target
    p MONITORS[target]
    p MONITORS[target][:controller]
    p MONITORS[target][:circuit]
    raise ArgumentError, "Switch '#{target}' not defined."
  end
  valid
end

def switchable?(target)
  if MONITORS[target][:switchable_check]
    http = Net::HTTP.new(API_DOMAIN, API_PORT)
    response = http.request_head(MONITORS[target][:switchable_check])
    (response['status']=~/200/)
  else
    true
  end
end

def should_we_flick_the_switch?(target)
  valid_target?(target) && switchable?(target)
end

switch_name   = ARGV[0]
duration      = ARGV[1]

switch_on(switch_name, duration) if should_we_flick_the_switch?(switch_name)
