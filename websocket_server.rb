require 'socket'
require 'digest/sha1'
require 'base64'

require_relative 'websocket_connection'

class WebSocketServer

  WS_MAGIC_STRING = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

  def initialize(options={path: '/', host: 'localhost', port: 4568})
    @path, host, port = options[:path], options[:host], options[:port]
    @tcp_server = TCPServer.new(host, port)
  end

  def accept # connections
    socket = @tcp_server.accept
    send_handshake(socket) && WebSocketConnection.new(socket) # return new WebSocketConnection on successful handshake
  end

  private

  def send_handshake(socket)
    request_line = socket.gets # 1st line, or blocks if there is nothing to get yet
    header = get_header(socket)
    if (request_line =~ /GET #{@path} HTTP\/1.1/) && (header =~ /Sec-WebSocket-Key: (.*)\r\n/)
      ws_accept = create_websocket_accept($1) # $1 is matched from (.*) above - or nil
      send_handshake_response(socket, ws_accept)
      return true
    end
    send_400(socket)
    false # reject the handshake - do not create WebSocketConnection instance (in #accept)
  end

  def get_header(socket, header = "") # 'rn' is EOF - return header
    (line = socket.gets) == "\r\n" ? header : get_header(socket, header + line) # recursively adds a line offered by the socket - nice
  end

  def create_websocket_accept(key)
    digest = Digest::SHA1.digest(key + WS_MAGIC_STRING)
    Base64.encode64(digest)
  end

  def send_400(socket)
    socket << "HTTP/1.1 400 Bad Request\r\n" +
              "Content-Type: text/plain\r\n" +
              "Connection: close\r\n" +
              "\r\n" +
              "Incorrect request" # body
    socket.close
  end

  def send_handshake_response(socket, ws_accept)
    socket << "HTTP/1.1 101 Switching Protocols\r\n" +
              "Upgrade: websocket\r\n" +
              "Connection: Upgrade\r\n" +
              "Sec-WebSocket-Accept: #{ws_accept}\r\n"
  end

end
