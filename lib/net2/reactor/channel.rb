module Net2
  class Reactor
    class IOChannel
      attr_reader :io
      attr_writer :reactor

      def initialize(io)
        @io = io
      end

      def read
        return call unless @io.eof?
        @reactor.stop_watching(@io, :read)
        eof
      end

      def write
      end

      def err
      end
    end

    class SocketChannel < IOChannel
      def write
        @reactor.stop_watching(@io, :write)
        connect
      end

      def connect
      end
    end
  end
end

