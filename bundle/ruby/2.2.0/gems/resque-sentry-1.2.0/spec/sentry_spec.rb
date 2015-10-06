require 'spec_helper'

describe Resque::Failure::Sentry do
  it "sends errors to Sentry" do
    sentry_options = { 
      :extra => { 
        "Object" => Object,
        "Arguments" => [ 1, "foo" ]
      } 
    }
    exception = StandardError.new("Test Error")
    worker = Resque::Worker.new(:test)
    queue = "test"
    payload = {'class' => Object, 'args' => [ 1, "foo" ]}

    event = mock
    Raven.expects(:capture_exception).with(exception, sentry_options)

    backend = Resque::Failure::Sentry.new(exception, worker, queue, payload)
    backend.save
  end

  it "will use the configured Sentry logger" do
    Resque::Failure::Sentry.logger = "resque"
    sentry_options = { 
      :logger => "resque",
      :extra => { 
        "Object" => Object,
        "Arguments" => [ 1, "foo" ]
      } 
    }
    exception = StandardError.new("Test Error")
    worker = Resque::Worker.new(:test)
    queue = "test"
    payload = {'class' => Object, 'args' => [ 1, "foo" ]}

    Raven.expects(:capture_exception).with(exception, sentry_options)
    backend = Resque::Failure::Sentry.new(exception, worker, queue, payload)
    backend.save
  end
end

