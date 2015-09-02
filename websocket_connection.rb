class WebSocketConnection

  attr_reader :socket

  def initialize(socket) # socket passed from server
    @socket = socket
  end

end
