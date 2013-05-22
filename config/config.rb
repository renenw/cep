require_relative './credentials'

Infinity = 1.0/0

CACHED_HISTORY_ITEMS          = 200
OUTLIER_ITEMS                 = 200
PAYLOAD_HISTORY_ITEMS         = 500
ANOMOLOUS_READING_HISTORY     = 200
MESSAGE_LOGGER_HISTORY_ITEMS  = 300

UMMP_IP         = '0.0.0.0'
UMMP_PORT       = 54545

WEB_SOCKET_IP   = '0.0.0.0'
WEB_SOCKET_PORT = 8081

RABBIT_HOST     = '127.0.0.1'
RABBIT_PASSWORD = 'guest'

RABBIT_EXCHANGE = ''

RABBIT_READINGS_EXCHANGE  = 'process_inbound'
RABBIT_TWITTER_EXCHANGE   = 'holler_exchange'
RABBIT_SMS_EXCHANGE       = 'sms_exchange'

DATA_STORE          = '30_camp_ground_road'
TEMPERATURE_SUFFIX  = '&deg; C'
WATT_HOURS          = ' wh<sup>-1</sup>'
BPS                 = ' bs<sup>-1</sup>'

OW_HTTP_ROOT_URL    = 'http://192.168.0.252:2121'

LOG_FILE            = '/home/renen/cep.log'

SMS_RECIPIENT_LIST  = '27833939595,27832536857'

RAINY_DAY_PRECIPITATION_THRESHOLD = 5.0

SETTINGS = {
  'timezone' => 'Africa/Johannesburg'
}

ALARM_ZONE_DEFINITIONS = {
  "02" => 'Cellar',
  "06" => 'Front door',
  "07" => 'Braai',
  "08" => 'Garden near kids rooms',
  "09" => 'Outside scullery door',
  "14" => 'Dining room',
  "15" => 'Family room',
  "16" => 'Stoep',
  "17" => 'House side of driveway',
  "18" => 'South side of driveway',
  "19" => 'Outhouse',
  "21" => 'Pedestrian entrance',
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

  'precipitation'       => { 
                              :monitor_type => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix => ' mm',
                            },
  'precipitation_t0'    => { 
                              :monitor_type       => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix             => ' mm',
                              :name               => 'Rainfall - Next 24 hours',
                            },
  'precipitation_t1'    => { 
                              :monitor_type       => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix             => ' mm',
                              :name               => 'Rainfall - 24 to 48 hours time',
                            },
  'precipitation_t2'    => { 
                              :monitor_type       => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix             => ' mm',
                              :name               => 'Rainfall - 48 to 72 hours time',
                            },
  'rainy_day'           => { 
                              :monitor_type       => :switch, 
                              :expected_frequency => 3600,
                              :name               => 'Rain Forecast?',
                            },

  'bandwidth'           => { :monitor_type => :mrtg, :expected_frequency => 60  },
  'bandwidth_in'        => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'bandwidth_out'       => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'bandwidth_total'     => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'outlier'             => { :monitor_type => :counter },
  'alarm_alive'         => { :monitor_type => :keep_alive, :name => 'Alarm Keep Alive', :expected_frequency => 60*60 },
  'alarm_armed'         => { :monitor_type => :switch },
  'alarm_activated'     => { :monitor_type => :switch },
  'grey_water_flooded'  => { :monitor_type => :switch, :ow_path => '/1F.ECE103000000/main/29.CC4208000000/latch.7' },
  'bandwidth_throughput'=> { :monitor_type => :gauge, :expected_frequency => 86400 },
  'bandwidth_bps'       => { :monitor_type => :gauge, :expected_frequency => 86400, :suffix => BPS },
  'bandwidth_qos'       => { :monitor_type => :gauge, :expected_frequency => 86400 },
  'weather_forecast'    => { :monitor_type => :keep_alive, :name => 'Weather Forecast', :expected_frequency => 60*60*24 },

  'pond_ferns'          => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.0', :websocket => { :reading => true },  :name => 'Pond fern misters' },
  'front_misters'       => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.1', :websocket => { :reading => true },  :name => 'Front garden misters' },
  'front'               => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.2', :websocket => { :reading => true },  :name => 'Front garden irrigation' },
  'front_fynbos'        => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.3', :websocket => { :reading => true },  :name => 'Front fynbos beds irrigation' },
  'outhouse_lawn'       => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.4', :websocket => { :reading => true },  :name => 'Outhouse lawn irrigation' },
  'driveway'            => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.5', :websocket => { :reading => true },  :name => 'Driveway irrigation' },
  'vegetable_patch'     => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.6', :websocket => { :reading => true },  :name => 'Vegetable Patch irrigation' },
  'jungle_gym'          => { :monitor_type => :solenoid, :ow_path => '/1F.DAE703000000/main/29.23F907000000/PIO.7', :websocket => { :reading => true },  :name => 'Jungle Gym irrigation' },
  'pool_beds'           => { :monitor_type => :solenoid, :ow_path => '/1F.ECE103000000/main/29.CC4208000000/PIO.0', :websocket => { :reading => true },  :name => 'Pool flower bed irrigation' },
  'pool_lawn'           => { :monitor_type => :solenoid, :ow_path => '/1F.ECE103000000/main/29.CC4208000000/PIO.1', :websocket => { :reading => true },  :name => 'Pool Lawn irrigation' },
  'pool'                => { :monitor_type => :solenoid, :ow_path => '/1F.ECE103000000/main/29.CC4208000000/PIO.6', :websocket => { :reading => true },  :name => 'Pool top-up' },

  'alarm_message'       => { :monitor_type => :status },

  'front_gate'          => { :monitor_type => :access },
  'front_gate_fail'     => { :monitor_type => :access },
  'front_gate_alive'    => { :monitor_type => :keep_alive, :name => 'Front Gate Keep Alive', :expected_frequency => 60*60 },

  'clear_caches'        => { :monitor_type => :administrative },

}
