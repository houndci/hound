require "spec_helper"

describe Object, ".method_object" do
  it "creates a .call class method that instantiates and runs the #call instance method" do
    klass = Class.new do
      method_object :foo

      def call
        foo
      end
    end

    assert klass.call(true)
    refute klass.call(false)
  end

  it "doesn't require attributes" do
    klass = Class.new do
      method_object

      def call
        true
      end
    end

    assert klass.call
  end
end
