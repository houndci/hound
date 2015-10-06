# Wraps the TCP socket and prints data sent and received. Used for debugging
# the wire protocol. You can use this by passing a :socket_class to Browser.
module Capybara::Webkit
  class SocketDebugger
    def self.open(host, port)
      real_socket = TCPSocket.open(host, port)
      new(real_socket)
    end

    def initialize(socket)
      @socket = socket
    end

    def read(length)
      received @socket.read(length)
    end

    def puts(line)
      sent line
      @socket.puts(line)
    end

    def print(content)
      sent content
      @socket.print(content)
    end

    def gets
      received @socket.gets
    end

    def setsockopt(level, name, value)
    end

    private

    def sent(content)
      Kernel.puts " >> " + content.to_s
    end

    def received(content)
      Kernel.puts " << " + content.to_s
      content
    end
  end
end
