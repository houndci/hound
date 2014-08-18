class FakeAnalyticsRuby
  def initialize
    @tracked_events = EventsList.new([])
  end

  def track(options)
    @tracked_events << options
  end

  delegate :tracked_events_for, to: :tracked_events

  private

  attr_reader :tracked_events

  class EventsList
    def initialize(events)
      @events = events
    end

    def <<(event)
      @events << event
    end

    def tracked_events_for(user)
      self.class.new(
        events.select do |event|
          event[:user_id] == user.id
        end
      )
    end

    def named(event_name)
      self.class.new(
        events.select do |event|
          event[:event] == event_name
        end
      )
    end

    def has_keys?(options)
      events.any? do |event|
        (options.to_a - event.to_a).empty?
      end
    end

    private

    attr_reader :events
  end
end
