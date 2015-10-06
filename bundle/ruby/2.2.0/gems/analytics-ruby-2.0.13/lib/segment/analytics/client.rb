require 'thread'
require 'time'
require 'segment/analytics/utils'
require 'segment/analytics/worker'
require 'segment/analytics/defaults'

module Segment
  class Analytics
    class Client
      include Segment::Analytics::Utils

      # public: Creates a new client
      #
      # attrs - Hash
      #           :write_key         - String of your project's write_key
      #           :max_queue_size - Fixnum of the max calls to remain queued (optional)
      #           :on_error       - Proc which handles error calls from the API
      def initialize attrs = {}
        symbolize_keys! attrs

        @queue = Queue.new
        @write_key = attrs[:write_key]
        @max_queue_size = attrs[:max_queue_size] || Defaults::Queue::MAX_SIZE
        @options = attrs
        @worker_mutex = Mutex.new
        @worker = Worker.new @queue, @write_key, @options

        check_write_key!

        at_exit { @worker_thread && @worker_thread[:should_exit] = true }
      end

      # public: Synchronously waits until the worker has flushed the queue.
      #         Use only for scripts which are not long-running, and will
      #         specifically exit
      #
      def flush
        while !@queue.empty? || @worker.is_requesting?
          ensure_worker_running
          sleep(0.1)
        end
      end

      # public: Tracks an event
      #
      # attrs - Hash
      #           :anonymous_id - String of the user's id when you don't know who they are yet. (optional but you must provide either an anonymous_id or user_id. See: https://segment.io/docs/tracking - api/track/#user - id)
      #           :context      - Hash of context. (optional)
      #           :event        - String of event name.
      #           :integrations - Hash specifying what integrations this event goes to. (optional)
      #           :options      - Hash specifying options such as user traits. (optional)
      #           :properties   - Hash of event properties. (optional)
      #           :timestamp    - Time of when the event occurred. (optional)
      #           :user_id      - String of the user id.
      def track attrs
        symbolize_keys! attrs
        check_user_id! attrs

        event = attrs[:event]
        properties = attrs[:properties] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}

        check_timestamp! timestamp

        if event.nil? || event.empty?
          fail ArgumentError, 'Must supply event as a non-empty string'
        end

        fail ArgumentError, 'Properties must be a Hash' unless properties.is_a? Hash
        isoify_dates! properties

        add_context context

        enqueue({
          :event => event,
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :context =>  context,
          :options => attrs[:options],
          :integrations => attrs[:integrations],
          :properties => properties,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'track'
        })
      end

      # public: Identifies a user
      #
      # attrs - Hash
      #           :anonymous_id - String of the user's id when you don't know who they are yet. (optional but you must provide either an anonymous_id or user_id. See: https://segment.io/docs/tracking - api/track/#user - id)
      #           :context      - Hash of context. (optional)
      #           :integrations - Hash specifying what integrations this event goes to. (optional)
      #           :options      - Hash specifying options such as user traits. (optional)
      #           :timestamp    - Time of when the event occurred. (optional)
      #           :traits       - Hash of user traits. (optional)
      #           :user_id      - String of the user id
      def identify attrs
        symbolize_keys! attrs
        check_user_id! attrs

        traits = attrs[:traits] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}

        check_timestamp! timestamp

        fail ArgumentError, 'Must supply traits as a hash' unless traits.is_a? Hash
        isoify_dates! traits

        add_context context

        enqueue({
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :integrations => attrs[:integrations],
          :context => context,
          :traits => traits,
          :options => attrs[:options],
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'identify'
        })
      end

      # public: Aliases a user from one id to another
      #
      # attrs - Hash
      #           :context     - Hash of context (optional)
      #           :integrations - Hash specifying what integrations this event goes to. (optional)
      #           :options      - Hash specifying options such as user traits. (optional)
      #           :previous_id - String of the id to alias from
      #           :timestamp   - Time of when the alias occured (optional)
      #           :user_id     - String of the id to alias to
      def alias(attrs)
        symbolize_keys! attrs

        from = attrs[:previous_id]
        to = attrs[:user_id]
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}

        check_presence! from, 'previous_id'
        check_presence! to, 'user_id'
        check_timestamp! timestamp
        add_context context

        enqueue({
          :previousId => from,
          :userId => to,
          :integrations => attrs[:integrations],
          :context => context,
          :options => attrs[:options],
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'alias'
        })
      end

      # public: Associates a user identity with a group.
      #
      # attrs - Hash
      #           :context      - Hash of context (optional)
      #           :integrations - Hash specifying what integrations this event goes to. (optional)
      #           :options      - Hash specifying options such as user traits. (optional)
      #           :previous_id  - String of the id to alias from
      #           :timestamp    - Time of when the alias occured (optional)
      #           :user_id      - String of the id to alias to
      def group(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        group_id = attrs[:group_id]
        user_id = attrs[:user_id]
        traits = attrs[:traits] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}

        fail ArgumentError, '.traits must be a hash' unless traits.is_a? Hash
        isoify_dates! traits

        check_presence! group_id, 'group_id'
        check_timestamp! timestamp
        add_context context

        enqueue({
          :groupId => group_id,
          :userId => user_id,
          :traits => traits,
          :integrations => attrs[:integrations],
          :options => attrs[:options],
          :context => context,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'group'
        })
      end

      # public: Records a page view
      #
      # attrs - Hash
      #           :anonymous_id - String of the user's id when you don't know who they are yet. (optional but you must provide either an anonymous_id or user_id. See: https://segment.io/docs/tracking - api/track/#user - id)
      #           :category     - String of the page category (optional)
      #           :context      - Hash of context (optional)
      #           :integrations - Hash specifying what integrations this event goes to. (optional)
      #           :name         - String name of the page
      #           :options      - Hash specifying options such as user traits. (optional)
      #           :properties   - Hash of page properties (optional)
      #           :timestamp    - Time of when the pageview occured (optional)
      #           :user_id      - String of the id to alias from
      def page(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        name = attrs[:name].to_s
        properties = attrs[:properties] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}

        fail ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
        isoify_dates! properties

        check_timestamp! timestamp
        add_context context

        enqueue({
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :name => name,
          :category => attrs[:category],
          :properties => properties,
          :integrations => attrs[:integrations],
          :options => attrs[:options],
          :context => context,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'page'
        })
      end
      # public: Records a screen view (for a mobile app)
      #
      # attrs - Hash
      #           :anonymous_id - String of the user's id when you don't know who they are yet. (optional but you must provide either an anonymous_id or user_id. See: https://segment.io/docs/tracking - api/track/#user - id)
      #           :category     - String screen category (optional)
      #           :context      - Hash of context (optional)
      #           :integrations - Hash specifying what integrations this event goes to. (optional)
      #           :name         - String name of the screen
      #           :options      - Hash specifying options such as user traits. (optional)
      #           :properties   - Hash of screen properties (optional)
      #           :timestamp    - Time of when the screen occured (optional)
      #           :user_id      - String of the id to alias from
      def screen(attrs)
        symbolize_keys! attrs
        check_user_id! attrs

        name = attrs[:name].to_s
        properties = attrs[:properties] || {}
        timestamp = attrs[:timestamp] || Time.new
        context = attrs[:context] || {}

        fail ArgumentError, '.properties must be a hash' unless properties.is_a? Hash
        isoify_dates! properties

        check_timestamp! timestamp
        add_context context

        enqueue({
          :userId => attrs[:user_id],
          :anonymousId => attrs[:anonymous_id],
          :name => name,
          :properties => properties,
          :category => attrs[:category],
          :options => attrs[:options],
          :integrations => attrs[:integrations],
          :context => context,
          :timestamp => timestamp.iso8601,
          :type => 'screen'
        })
      end

      # public: Returns the number of queued messages
      #
      # returns Fixnum of messages in the queue
      def queued_messages
        @queue.length
      end

      private

      # private: Enqueues the action.
      #
      # returns Boolean of whether the item was added to the queue.
      def enqueue(action)
        # add our request id for tracing purposes
        action[:messageId] = uid
        unless queue_full = @queue.length >= @max_queue_size
          ensure_worker_running
          @queue << action
        end
        !queue_full
      end

      # private: Ensures that a string is non-empty
      #
      # obj    - String|Number that must be non-blank
      # name   - Name of the validated value
      #
      def check_presence!(obj, name)
        if obj.nil? || (obj.is_a?(String) && obj.empty?)
          fail ArgumentError, "#{name} must be given"
        end
      end

      # private: Adds contextual information to the call
      #
      # context - Hash of call context
      def add_context(context)
        context[:library] =  { :name => "analytics-ruby", :version => Segment::Analytics::VERSION.to_s }
      end

      # private: Checks that the write_key is properly initialized
      def check_write_key!
        fail ArgumentError, 'Write key must be initialized' if @write_key.nil?
      end

      # private: Checks the timstamp option to make sure it is a Time.
      def check_timestamp!(timestamp)
        fail ArgumentError, 'Timestamp must be a Time' unless timestamp.is_a? Time
      end

      def event attrs
        symbolize_keys! attrs

        {
          :userId => user_id,
          :name => name,
          :properties => properties,
          :context => context,
          :timestamp => datetime_in_iso8601(timestamp),
          :type => 'screen'
        }
      end

      def check_user_id! attrs
        fail ArgumentError, 'Must supply either user_id or anonymous_id' unless attrs[:user_id] || attrs[:anonymous_id]
      end

      def ensure_worker_running
        return if worker_running?
        @worker_mutex.synchronize do
          return if worker_running?
          @worker_thread = Thread.new do
            @worker.run
          end
        end
      end

      def worker_running?
        @worker_thread && @worker_thread.alive?
      end
    end
  end
end
