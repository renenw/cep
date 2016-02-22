cep
===

Inbound event processor for H3 home monitoring and automation project

programs
========

cep.rb:            the main processor of messages
ummp.rb:           the udp listener
ow_temperature.rb: reads a 1wire thermometer and pushes the result into rabbit

NB: If you add a new handler, for example, pool_related_handlers.rb, be sure to add this into
cep.rb so that it knows about it:

require_relative 'cep/handlers/pool_related_handlers'

and:

include PoolRelatedHandlers


process flow
============

UDP data is received by ummp.rb, on the port defined in config UMMP_PORT (probably 54545). This data is required to have the struture: #{monitor_name} #{data}. Specifically, in udp_message_received the udp data packet is split as follows: payload['packet'].split(' ', 2).

ummp.rb immediately strips white space from the received message, adds a timestamp, and a GUID, and places the resultant structure into a rabbit queue with routing key: udp_message_received. The structure is created as follows:

{ 'received' => Time.now.to_f, 'packet' => udp_data.strip, 'guid' => SecureRandom.uuid }

There are two key sources of configuration data:
1. config.rb defines a collection of monitors (MONITORS), each of which has a monitor_type which determines how the event will be handled.
2. cep.rb defines a collection of queues (@queues) and fan-out exchanges (@fan_out_exchanges).

Having been placed into rabbit with the routing key udp_message_received, the just-received structure is first processed by udp_message_received in lifecycle_handlers.rb. It validates that the monitor is defined in MONITORS. If it isn't its logged as an anomoly and processing stops. If it is, defined in MONITORS (and has a source type), the packet is rewritten as follows and then placed into the next queue:

                      { 'data_store'  => DATA_STORE,
                        'source'      => data[0],
                        'source_type' => MONITORS[data[0]][:monitor_type].to_s,
                        'data'        => payload_data, # #{data} in the UDP packet (see above)
                       }


@queues (as defined in cep.rp) defines what queue the result of the last operation should be placed into next (this can either be another queue, or a fanout exchange). For example initially the received UDP packet is received and placed into the udp_message_received queue. As described, if this entry is defined in MONITOR, the packet is rewritten, and the result placed in :next_queue (in this case: on_receive).

Each source_type (pulse) or source (electricity_total) is able to define an "on receive" handler, as well as an "after receive" handler. For example, after_received_pulse or on_receive_bandwidth_throughput. These event handlers can rewrite the message, halt processing, or process the message in some other way. Note that, at this time, the packet has not yet been persisted to any kind of data store.

To recap, the UDP packet is received by the handler. It is rewritten by udp_message_received, the on_* events associated with this monitor or monitor type are executed. Then, the message is sent to initialise_structured_message.

From this point forward, it is assumed that the data contained in the UDP payload is a single numeric value (0 or 1 in the case of a switch, or an integer or float value of some description). initialise_structured_message writes the data to the events table, and augments the structure with dimensions.

specifically
============

* the data structure passed through the message chain

Payload is gradually augmented.

udp adds the time the packet was received
udp_handler (handle_udp):
  1. kills badly structured messages
  2. records unkown (ie, not in config.rb) monitors in a dead-letter-list,
  3. for valid messages, a data_store (location) is added, a local time is added, and the message is sent on to initialise_structured_message
  4. if the message is a mrtg message, it is sent to handle_mrtg_pre_processing
the various handle_xxxx handlers add a "converted_value" entry that is the result of assessing the value received in the payload

the handle_xxx adds a "converted_value" entry that reflects the value to be used by subsequent operations.
  
* the queue flow

udp
  => udp_handler (handle_udp): an opportunity to rewrite messages, ditch them etc
    => by default, initialise_structured_message (initialise_structured_message): messages should, by this point, have a basic "events" structure (source, number) with a received time that as closely as practically reflects the event time
      => if :pulse, pulse (handle_pulse): converted_value set to watt_hours since last reading (by implication, only handles watt_hours)
        => reading
      => if :gauge, gauge (handle_ga/Users/renen/Workspace/cep/config/config.rbuge): converted_value set to "float value"
        => reading
      => if :counter, counter (handle_gauge)
        => reading
    => if :mrtg, handle_mrtg_pre_processing: which pushes out three new entries - bandwidth in, out and total - but does not pass itsel along for further processing (it commits suicide)
 
  reading (handle_reading): saves the entry into the "readings" table and pushes the reading out into the fan out exchange
    => handle_summarisation: updates the summary data with this reading (eg, quarterly total, max, min etc)
    => handle_history: keeps a recent set of entries around in the cache (eg 200)
    => handle_calculate_outlier_threshold: for pulse meters, updates the cache with outlier thresholds (if relevant)
    => handle_cache_reading: pushes the latest reading into memcache
    => handle_cache_sources: makes sure the list of known sources (used by the js) is up-to-date


Database Structures
===================

events: The first table to which the result is written: id, source, float_value, integer_value, created_at
messages: Contains a history of messages ("Circuit four activated", "Front lawn irrigation turned on" or "Alarm System reporting via phone failed restored"). Generally logged by after_* events.
outliers: A list of event id's that have been calculated to be outliers.
readings: The readings, stored with data-warehouse style groupings
summary_series: 


Utility Structures
==================

@cache wraps memcache and stories certain historys (for example, the last fifty anomolies)


Example
=======
irb

require 'tzinfo'
require './lib/cep/cacher.rb'
require './lib/cep/utils'
require './config/config'

# init
@cache = Cacher.new('localhost:11211')

# get some history
history   = @cache.get("30_camp_ground_road.history.pool_water_level")

# make a decision using that history
one_hour_ago = (CEP_Utils.get_local_time(SETTINGS['timezone'], Time.now.to_i - (60 * 60) )) * 1000
level_too_low = history[-5,5].select{ |h| h['local_time']>one_hour_ago }.select{ |h| h['reading']==1 }.empty?

# publish the result
deep_enough = { 'received' => payload['received'], 'packet' => "pool_deep_enough #{(level_too_low ? 0 : 1)}" }.to_json
@exchange.publish deep_enough,   :routing_key => 'udp_message_received'


dependencies
============

memcached
rabbitmq

local servers
=============
ow: http://192.168.0.252:2121/




dropped tables
==============

Empty, unused, redundant?

CREATE TABLE `summary_series` (
  `series` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `time_unit` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `local_time` int(11) NOT NULL DEFAULT '0',
  `series_count` int(11) DEFAULT NULL,
  `series_sum` float DEFAULT NULL,
  `series_minimum` float DEFAULT NULL,
  `series_maximum` float DEFAULT NULL,
  `series_average` float DEFAULT NULL,
  PRIMARY KEY (`series`,`time_unit`,`local_time`)
