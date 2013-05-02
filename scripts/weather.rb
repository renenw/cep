#require 'rubygems'
#require 'pp'
#require 'time'

require "net/http"
require "uri"

FORECAST_URL = 'http://www.weathersa.co.za/web/home.asp?sp=1&f=1098&z=Ctry&v=7&g=gT&h=0&m=Strm&anim=aStr&av=AvWarn&uid=&p=&dbug=&TL=1098&PC=&mw=w&ht=&ib=1&f=1112&setTown=1'

def get_forecast
	uri 			= URI.parse(FORECAST_URL)
	http 			= Net::HTTP.new(uri.host, uri.port)
	request 	= Net::HTTP::Get.new(uri.request_uri)
	response 	= http.request(request)
	raise IOError, 'Download failed' if response.code!='200'
	response.body
end

def get_day(day_forecast)
	day_forecast.match(/<b>(?<day_of_week>\w{3}).+?(?<one_mm>\d+)<\/font>\/(?<tenmm>\d+)\/<font.+?>(?<fiftymm>\d+)<.+?(?<min>\d+)&deg.+?(?<max>\d+)&deg.+?\s+(?<am_wind>\w+)<br\s\/>(?<am_wind_speed>\d+).+?\s+(?<pm_wind>\w+)<br\s\/>(?<pm_wind_speed>\d+)/m) do
	end

end

def run
	get_forecast.scan(/(<b>\w{3}<\/b><\/p>.+?<div style=\"text)/m) do |day|
  	p day
	end

end

run
