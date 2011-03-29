require "net2/reactor/version"
require "net2/reactor/timer"

module Net2
  class Reactor
    def initialize(queue)
      @ios = {:read => [], :write => []}
      @channels = {:read => {}, :write => {}}

      @timers = []
      @running = true

      @queue = queue
    end

    def start
      while @running
        read_ios, write_ios, err_ios = IO.select(@ios[:read], @ios[:write], nil, 0.1)

        if read_ios
          read_ios.each do |io|
            @queue.push @channels[:read][io], :read unless io.closed?
          end
        end

        if write_ios
          write_ios.each do |io|
            @queue.push @channels[:write][io], :write unless io.closed?
          end
        end

        if err_ios
          err_ios.each do |io|
            @queue.push @channels[io], :err unless io.closed?
          end
        end

        @ios.each do |type, ios|
          ios.each do |io|
            if io.closed?
              @queue.push @channels[type][io], :close
              stop_watching io, type
            end
          end
        end

        @timers.reject! do |timer|
          if timer.elapsed?
            timer.callback
            true
          end
        end
      end
    end

    def watch(channel, *types)
      io = channel.io
      channel.reactor = self

      types = [:read] if types.empty?

      types.each do |type|
        @ios[type] << io
        @channels[type][io] = channel
      end
    end

    def add_timer(ms, obj=Proc.new)
      @timers << Timer.new(ms, obj)
    end

    def stop_watching(io, type)
      @ios[type].delete(io)
    end

    def stop
      @running = false
    end
  end
end
