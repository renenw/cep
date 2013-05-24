require_relative 'ow_switch_base.rb'

include Switch_Base

@log = Log_Wrapper.new( File.join(File.dirname(__FILE__), 'log.txt') )

switch(ARGV[0], ARGV[1])