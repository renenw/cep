cep
===

Inbound event processor for H3 home monitoring and automation project

programs
========

start.rb:          the main processor of messages
ummp.rb:           the udp listener
ow_temperature.rb: reads a 1wire thermometer and pushes the result into rabbit

dependencies
============

memcached
rabbitmq

local servers
=============
ow: http://192.168.0.252:2121/