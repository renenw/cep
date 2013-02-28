require 'socket'

mrtg = File.open('/var/www/mrtg/192.168.0.1_9.log', &:readline)
socket = UDPSocket.new
socket.send("bandwidth #{mrtg}", 0, '192.168.0.252', 54545)
