module Net2
  class Reactor
    class Timer
      def initialize(ms, obj)
        @time = Time.now + (ms / 1000.0)
        @obj  = obj
      end

      def elapsed?
        Time.now > @time
      end

      def callback
        @obj.call
      end
    end
  end
end
