require 'socket'
require_relative '../config/config'

def send_udp_message(message)
	socket = UDPSocket.new
	socket.send(message, 0, UMMP_IP, UMMP_PORT)
end

send_udp_message ARGV[0]
