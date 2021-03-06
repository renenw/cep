#!/usr/bin/env ruby
# encoding: utf-8

require 'amqp'
require 'json'
require 'securerandom'
require_relative '../config/config'

module UmmpServer

  def initialize(exchange)
    @ummp_exchange = exchange
  end

  def receive_data(udp_data)
    p udp_data
    message = { 'received' => Time.now.to_f, 'packet' => udp_data.strip, 'guid' => SecureRandom.uuid }.to_json
    @ummp_exchange.publish message, :routing_key => 'udp_message_received'
  end
end

def receive_udp_packets
  EventMachine.run do
    udp_amqp_client = AMQP.connect(:host => RABBIT_HOST,  :password => RABBIT_PASSWORD)
    channel  = AMQP::Channel.new(udp_amqp_client)
    exchange = channel.direct(RABBIT_EXCHANGE)
    EventMachine::open_datagram_socket UMMP_IP, UMMP_PORT, UmmpServer, exchange
  end
end

def orchestrate
  udp_receiver = Thread.new() { receive_udp_packets }
  p "Started UDP listener on #{UMMP_IP}:#{UMMP_PORT}"
  udp_receiver.join
end

orchestrate
