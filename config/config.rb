require_relative './credentials'

Infinity = 1.0/0

CACHED_HISTORY_ITEMS      = 200
OUTLIER_ITEMS             = 200
PAYLOAD_HISTORY_ITEMS     = 500
ANOMOLOUS_READING_HISTORY = 200

UMMP_IP         = '0.0.0.0'
UMMP_PORT       = 54545

WEB_SOCKET_IP   = '0.0.0.0'
WEB_SOCKET_PORT = 8081

RABBIT_HOST     = '127.0.0.1'
RABBIT_PASSWORD = 'guest'

RABBIT_EXCHANGE = ''

RABBIT_READINGS_EXCHANGE  = 'process_inbound'
RABBIT_TWITTER_EXCHANGE   = 'holler_exchange'

DATA_STORE          = '30_camp_ground_road'
TEMPERATURE_SUFFIX  = '&deg; C'
WATT_HOURS          = ' wh<sup>-1</sup>'
BPS                 = ' bs<sup>-1</sup>'

OW_HTTP_ROOT_URL    = 'http://192.168.0.252:2121'

LOG_FILE            = '/home/renen/cep.log'

SETTINGS = {
  'timezone' => 'Africa/Johannesburg'
}

MONITORS = {
  'electricity_total'   => { 
                              :monitor_type       => :pulse, 
                              :expected_frequency => 60, 
                              :suffix             => WATT_HOURS, 
                              :range              => { :min => 0, :max => Infinity}, 
                              :ow_path            => '/1F.77E703000000/aux/1D.72DC0F000000/counters.A',
                              :websocket => { 
                                              :dimensions => {
                                                'day'   => ['sum'],
                                                'week'  => ['sum'],
                                                'month' => ['sum']
                                              }
                                            } 
                            },
  'electricity_geyser'  => { 
                              :monitor_type => :pulse, 
                              :expected_frequency => 60, 
                              :suffix => WATT_HOURS, 
                              :range => { :min => 0, :max => Infinity}, 
                              :ow_path            => '/1F.77E703000000/aux/1D.72DC0F000000/counters.B',
                              :websocket => { 
                                              :dimensions => {
                                                'day'   => ['sum'],
                                                'week'  => ['sum'],
                                                'month' => ['sum']
                                              }
                                            } 
                            },
  'electricity_pool'    => { 
                              :monitor_type => :pulse, 
                              :expected_frequency => 60, 
                              :suffix => WATT_HOURS, 
                              :range => { :min => 0, :max => Infinity}, 
                              :ow_path            => '/1F.77E703000000/aux/1D.426D0F000000/counters.A',
                              :websocket => { 
                                              :dimensions => {
                                                'day'   => ['sum'],
                                                'week'  => ['sum'],
                                                'month' => ['sum']
                                              }
                                            } 
                            },
  'temperature_cellar'  => {
                              :monitor_type       => :gauge, 
                              :expected_frequency => 300, 
                              :suffix             => TEMPERATURE_SUFFIX,
                              :ow_path            => '/1F.77E703000000/main/28.A2E07C020000/temperature',
                              :websocket          => { :reading => true }
                            },
  'temperature_outside' => { 
                              :monitor_type => :gauge, 
                              :expected_frequency => 300, 
                              :suffix => TEMPERATURE_SUFFIX,
                              :ow_path            => '/1F.77E703000000/main/28.4CDC7C020000/temperature', 
                              :websocket => { 
                                              :reading => true,
                                              :dimensions => {
                                                'day'   => ['min', 'max']
                                              }
                                            }
                            },
  'temperature_inside'  => { 
                              :monitor_type => :gauge, 
                              :expected_frequency => 300, 
                              :suffix => TEMPERATURE_SUFFIX, 
                              :ow_path            => '/1F.77E703000000/main/28.9DDA7C020000/temperature', 
                              :websocket => { 
                                              :reading => true,
                                              :dimensions => {
                                                'day'   => ['min', 'max']
                                              }
                                            }
                            },
  'temperature_pool'    => { :monitor_type => :gauge, :range => { :min => 0, :max => 40}, :expected_frequency => 300, :suffix => TEMPERATURE_SUFFIX, :websocket => { :reading => true } },
  'bandwidth'           => { :monitor_type => :mrtg, :expected_frequency => 60  },
  'bandwidth_in'        => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'bandwidth_out'       => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'bandwidth_total'     => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'outlier'             => { :monitor_type => :counter },
  'alarm_alive'         => { :monitor_type => :keep_alive, :name => 'Alarm and Pool Keep Alive', :expected_frequency => 60*60 },
  'alarm_armed'         => { :monitor_type => :switch },
  'alarm_activated'     => { :monitor_type => :switch },
  'bandwidth_throughput'=> { :monitor_type => :gauge, :expected_frequency => 86400 },
  'bandwidth_bps'       => { :monitor_type => :gauge, :expected_frequency => 86400, :suffix => BPS },
  'bandwidth_qos'       => { :monitor_type => :gauge, :expected_frequency => 86400 },
  'weather_forecast'    => { :monitor_type => :keep_alive, :name => 'Weather Forecast', :expected_frequency => 60*60*24 },

  'front'               => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.2' },
  'front_fynbos'        => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.3' },
  'outhouse_lawn'       => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.4' },
  'driveway'            => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.5' },
  'vegetable_patch'     => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.6' },
  'jungle_gym'          => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.7' },

}
