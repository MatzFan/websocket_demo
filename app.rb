#!/usr/bin/env ruby

require_relative 'websocket_server'

server = WebSocketServer.new # use defaults

loop do
  Thread.new(server.accept) do |connection|
    puts "Connected"
    while (message = connection.recv)
      puts "Received #{message} from the client"
      connection.send("Received #{message}. Thanks!")
    end
  end
end
