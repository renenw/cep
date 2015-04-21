require 'nokogiri'
require 'open-uri'
require 'socket'
require 'log_wrapper'
require 'json'
require_relative '../config/config'

@log   	= Log_Wrapper.new( File.join(File.dirname(__FILE__), 'log.txt') )


FORECAST_URL = 'http://api.yr.no/weatherapi/locationforecast/1.9/?lat=-33.95283;lon=18.48056'

# resultant xml includes three types of node:
# precipitation forecasts, containing only a precipitation element (node) with a three hour window. Three hourly, for the next three days.
# precipitation forecasts, containing only a precipitation element (node) with a six hour window. Three hourly for the first three days, and thereafter, six hourly for the next week or so.
# general forecast nodes, containing wind and all that. Six hourly, for the next week or so.

# sigh. or something like that.

def get_value(type, detail)
	case type
	when 'temperature', 'humidity', 'pressure', 'precipitation'
		r = detail['value']
	when 'winddirection'
		r = detail['name']
	when 'windspeed'
		r = detail['mps']
	when 'cloudiness', 'fog', 'lowclouds', 'mediumclouds', 'highclouds'
		r = detail['percent']
	else
		nil
	end
end

def get_element(period_forecast)
	# skip over the location node
	r = {}
	period_forecast.children[0].children.each do |detail|
		value = get_value(detail.name, detail)
		r[detail.name] = value if value
	end	
	r
end

def retrieve_forecast()
	forecast = {}
	doc = Nokogiri::HTML(open(FORECAST_URL))
	doc.xpath('//time').each do |period_forecast|
		key = "#{period_forecast['from']} #{period_forecast['to']}"
		start 			= Time.parse(period_forecast['from']).to_i
		stop  			= Time.parse(period_forecast['to']).to_i
		duration		= (stop-start)/3600
		duration		= 6 if duration == 0
		forecast[key] ||= {
			'from' 			=> period_forecast['from'],
			'to'	 			=> period_forecast['to'],
			'duration'	=> duration,
			'start'			=> start,
		}
		forecast[key].merge!(get_element(period_forecast))
	end
	forecast
end

def publish(type, message)
	socket = UDPSocket.new
	socket.send("#{type} #{message.to_json}", 0, UMMP_IP, UMMP_PORT)
end

# for now, I am only interested in the forecast level of precipitation over the next 24, 48 and 72 hours.
def get_precipitation_forecast(forecast)
	
	precipitation_forecast = []
	rainfall_forecast			 = [0.0,0.0,0.0]
	next_three_hours			 = 0.0

	first = Time.now.to_i + 24*60*60*5

	# find the earliest start time, get forecast for earliest time, and collect three hourly precipitation forecasts
	forecast.each_value do |f|
		if f['precipitation'] && f['duration']==3
			precipitation_forecast << f
			if f['start'] < first
				first = f['start']
				next_three_hours = f['precipitation'].to_f
			end
		end
	end

	# now collect and group into days
	precipitation_forecast.each do |f|
		period = (f['start'] - first) / (24*60*60)
		rainfall_forecast[period] += f['precipitation'].to_f if period < 3
	end

	{
		'precipitation' 		=> rainfall_forecast,
		'start'							=> first,
		'next_three_hours'  => next_three_hours
	}

end

def get_weather_forecast(forecast)

	weather_forecast   = []

	first = Time.now.to_i + 24*60*60*5
	forecast.each_value do |f|
		if f['temperature']
			weather_forecast << f
			first = f['start'] if f['start'] < first
		end
	end

	p first
	p weather_forecast

end

def test
	forecast = retrieve_forecast
	forecast.each_value do |f|
		start = Time.parse(f['from']).to_i
		stop  = Time.parse(f['to']).to_i
		p "#{(f['precipitation'] ? 'p' : 'w')}#{f['duration']} #{start} #{f['from']} #{f['to']} #{(f['precipitation'] ? f['precipitation'] + "mm" : f['temperature'] + 'C')}"
	end
	p "******"
	x = get_weather_forecast(forecast)
	x.sort! do |a, b|
		a['start'] <=> b['start']
	end
	x.each do |y|
		p "#{y['start']} ==> #{y['from']} #{y['to']}"
	end
end

def run
	rainfall_forecast = nil
	@log.debug("Retrieve precipitation forecast") do
		forecast 						= retrieve_forecast
		rainfall_forecast 	= get_precipitation_forecast(forecast)
	end
	publish('precipitation', rainfall_forecast) if rainfall_forecast
end

run
