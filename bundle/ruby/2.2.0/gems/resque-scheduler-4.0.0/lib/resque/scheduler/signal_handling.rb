# vim:fileencoding=utf-8

module Resque
  module Scheduler
    module SignalHandling
      attr_writer :signal_queue

      def signal_queue
        @signal_queue ||= []
      end

      # For all signals, set the shutdown flag and wait for current
      # poll/enqueing to finish (should be almost instant).  In the
      # case of sleeping, exit immediately.
      def register_signal_handlers
        %w(INT TERM USR1 USR2 QUIT).each do |sig|
          trap(sig) do
            signal_queue << sig
            # break sleep in the primary scheduler thread, alowing
            # the signal queue to get processed as soon as possible.
            @th.wakeup if @th.alive?
          end
        end
      end

      def handle_signals
        loop do
          sig = signal_queue.shift
          break unless sig
          log! "Got #{sig} signal"
          case sig
          when 'INT', 'TERM', 'QUIT' then shutdown
          when 'USR1' then print_schedule
          when 'USR2' then reload_schedule!
          end
        end
      end
    end
  end
end
