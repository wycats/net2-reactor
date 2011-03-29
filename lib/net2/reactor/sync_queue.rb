module Net2
  class Reactor
    class SyncQueue
      def initialize
        @queue = []
      end

      def push(channel, type)
        channel.send(type) if channel.respond_to?(type)
      end
    end
  end
end
