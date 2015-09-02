#!/usr/bin/env ruby

require_relative 'websocket_server'
require_relative 'websocket_connection'

server = WebSocketServer.new({path: '/', host: 'localhost', port: 4568})

loop do
  Thread.new(server.accept) do |connection|
    puts "Connected"
  end
end
