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

API_DOMAIN          = '192.168.0.252'
API_PORT            = 8080
OW_HTTP_ROOT_URL    = 'http://192.168.0.252:2121'

LOG_FILE            = '/home/renen/cep.log'

SMS_RECIPIENT_LIST  = '27833939595,27832536857'

RAINY_DAY_PRECIPITATION_THRESHOLD = 2.5

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
  'temperature_pool'    => { 
                              :monitor_type => :gauge, 
                              :range => { :min => 0, :max => 40},
                              :expected_frequency => 300,
                              :suffix => TEMPERATURE_SUFFIX,
                              :websocket => { :reading => true }
                            },

  'precipitation'       => { 
                              :monitor_type => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix => ' mm',
                            },
  'precipitation_tv'    => { 
                              :monitor_type       => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix             => ' mm',
                              :name               => 'Rainfall - Preceding 72 hours',
                            },
  'precipitation_tw'    => { 
                              :monitor_type       => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix             => ' mm',
                              :name               => 'Rainfall - Preceding 48 hours',
                            },
  'precipitation_tx'    => { 
                              :monitor_type       => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix             => ' mm',
                              :name               => 'Rainfall - Preceding 24 hours',
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
  'precipitation_3h'    => { 
                              :monitor_type       => :gauge, 
                              :expected_frequency => 3600, 
                              :suffix             => ' mm',
                              :name               => 'Rainfall - next 3 hours',
                            },
  'rainy_day'           => { 
                              :monitor_type       => :switch, 
                              :expected_frequency => 3600,
                              :name               => 'Is it wet?',
                            },
  'pool_level'          => { 
                              :monitor_type       => :switch, 
                              :expected_frequency => 60,
                              :name               => 'Is the pool full?',
                            },
  'pool_deep_enough'    => { 
                              :monitor_type       => :switch, 
                              :expected_frequency => 60,
                              :name               => 'Should the pool be topped up?',
                            },

  'bandwidth'               => { :monitor_type => :mrtg, :expected_frequency => 60  },
  'bandwidth_in'            => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'bandwidth_out'           => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },
  'bandwidth_total'         => { :monitor_type => :pulse, :range => { :min => 0, :max => Infinity}, :expected_frequency => 60, :suffix => ' bits' },

  'outlier'                 => { :monitor_type => :counter },

  'alarm_alive'             => { :monitor_type => :keep_alive, :name => 'Alarm Keep Alive', :expected_frequency => 60*60 },
  'alarm_armed'             => { :monitor_type => :switch },
  'alarm_activated'         => { :monitor_type => :switch },

  'switcher_alive'          => { :monitor_type => :keep_alive, :name => 'Pool Water Level Sensor Alive', :expected_frequency => 60*3 },
  'pool_water_level'        => { :monitor_type => :switch, :ow_path => '/1F.ECE103000000/main/29.CC4208000000/latch.3' },
  'grey_water_flooded'      => { :monitor_type => :switch, :ow_path => '/1F.ECE103000000/main/29.CC4208000000/latch.4' },
  'basement_sump_flooded'   => { :monitor_type => :switch, :ow_path => '/1F.ECE103000000/main/29.CC4208000000/latch.5' },

  'bandwidth_throughput'    => { :monitor_type => :gauge, :expected_frequency => 86400 },
  'bandwidth_bps'           => { :monitor_type => :gauge, :expected_frequency => 86400, :suffix => BPS },
  'bandwidth_qos'           => { :monitor_type => :gauge, :expected_frequency => 86400 },

  'weather_forecast'        => { :monitor_type => :keep_alive, :name => 'Weather Forecast', :expected_frequency => 60*60*24 },

  'temperature_pool_alive'  => { :monitor_type => :keep_alive, :name => 'Pool Temperature Alive', :expected_frequency => 60*3 },

  'pond_ferns'              => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 6,  :websocket => { :reading => true }, :name => 'Pond fern misters' },
  'front_misters'           => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 2,  :websocket => { :reading => true }, :name => 'Front garden misters' },
  'front'                   => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 1,  :websocket => { :reading => true }, :name => 'Front garden irrigation',      :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'front_fynbos'            => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 0,  :websocket => { :reading => true }, :name => 'Front fynbos beds irrigation', :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'outhouse_lawn'           => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 14, :websocket => { :reading => true }, :name => 'Outhouse lawn irrigation',     :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'driveway'                => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 12, :websocket => { :reading => true }, :name => 'Driveway irrigation',          :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'vegetable_patch'         => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 13, :websocket => { :reading => true }, :name => 'Vegetable Patch irrigation',   :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'jungle_gym'              => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 15, :websocket => { :reading => true }, :name => 'Jungle Gym irrigation',        :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'pool_beds'               => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 5,  :websocket => { :reading => true }, :name => 'Pool flower bed irrigation',   :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'pool_lawn'               => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 7,  :websocket => { :reading => true }, :name => 'Pool Lawn irrigation',         :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'pool'                    => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 8,  :websocket => { :reading => true }, :name => 'Pool top-up',                  :switchable_check => '/api/30_camp_ground_road/may_switch/pool_deep_enough?' },
  'front_lawn'              => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 3,  :websocket => { :reading => true }, :name => 'Front lawn irrigation',        :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },
  'trees'                   => { :monitor_type => :solenoid, :controller => '192.168.0.203', :circuit => 4,  :websocket => { :reading => true }, :name => 'Trees',                        :switchable_check => '/api/30_camp_ground_road/may_switch/rainy_day?' },

  'switch_0'                => { :monitor_type => :switch, :name => 'irrigation front fynbos'      },
  'switch_1'                => { :monitor_type => :switch, :name => 'irrigation front'             },
  'switch_2'                => { :monitor_type => :switch, :name => 'irrigation front misters'     },
  'switch_3'                => { :monitor_type => :switch, :name => 'irrigation front lawn'        },
  'switch_4'                => { :monitor_type => :switch, :name => 'irrigation trees'             },
  'switch_5'                => { :monitor_type => :switch, :name => 'irrigation pool beds'         },
  'switch_6'                => { :monitor_type => :switch, :name => 'irrigation pond_ferns'        },
  'switch_7'                => { :monitor_type => :switch, :name => 'irrigation pool lawn'         },
  'switch_8'                => { :monitor_type => :switch, :name => 'pool topup'                   },
  'switch_12'               => { :monitor_type => :switch, :name => 'irrigation driveway'          },
  'switch_13'               => { :monitor_type => :switch, :name => 'irrigation vegetable patch'   },
  'switch_15'               => { :monitor_type => :switch, :name => 'irrigation jungle gym'        },

  'alarm_message'           => { :monitor_type => :status },

  'front_gate'              => { :monitor_type => :access },
  'front_gate_fail'         => { :monitor_type => :access },
  'front_gate_alive'        => { :monitor_type => :keep_alive, :name => 'Front Gate Keep Alive', :expected_frequency => 60*60 },

  'clear_caches'            => { :monitor_type => :administrative },

  'switch_on'               => { :monitor_type => :administrative },
  'switch_off'              => { :monitor_type => :administrative },

}
