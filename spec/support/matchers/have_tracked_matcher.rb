RSpec::Matchers.define :have_tracked do |event_name|
  match do |backend|
    @event_name = event_name
    @backend = backend
    backend.
      tracked_events_for(@user).
      named(@event_name).
      has_keys?(@keys)
  end

  description do
    "tracked event"
  end

  failure_message do |_|
    "expected event '#{@event_name}' to be tracked for user '#{@user}' " +
    "with included keys #{@keys} but was not"
  end

  failure_message_when_negated do |_|
    "expected event '#{@event_name}' not to be tracked for user '#{@user}' " +
    "with included keys #{@keys} but was"
  end

  chain(:for_user) { |user| @user = user }
  chain(:with) { |keys| @keys = keys }
end
