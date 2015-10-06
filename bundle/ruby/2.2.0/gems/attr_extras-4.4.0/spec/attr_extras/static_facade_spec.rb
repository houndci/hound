require "spec_helper"

describe Object, ".static_facade" do
  it "creates a class method that instantiates and runs that instance method" do
    klass = Class.new do
      static_facade :fooable?,
        :foo

      def fooable?
        foo
      end
    end

    assert klass.fooable?(true)
    refute klass.fooable?(false)
  end

  it "doesn't require attributes" do
    klass = Class.new do
      static_facade :fooable?

      def fooable?
        true
      end
    end

    assert klass.fooable?
  end
end
