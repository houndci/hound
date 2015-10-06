require "spec_helper"

describe Object, ".attr_initialize" do
  let(:klass) do
    Class.new do
      attr_initialize :foo, :bar

      def self.name
        "ExampleClass"
      end
    end
  end

  it "creates an initializer setting those instance variables" do
    example = klass.new("Foo", "Bar")
    example.instance_variable_get("@foo").must_equal "Foo"
    example.instance_variable_get("@bar").must_equal "Bar"
  end

  it "requires all arguments" do
    exception = lambda { klass.new("Foo") }.must_raise ArgumentError
    exception.message.must_equal "wrong number of arguments (1 for 2) for ExampleClass initializer"
  end

  it "can set ivars from a hash" do
    klass = Class.new do
      attr_initialize :foo, [:bar, :baz]
    end

    example = klass.new("Foo", :bar => "Bar", :baz => "Baz")
    example.instance_variable_get("@foo").must_equal "Foo"
    example.instance_variable_get("@bar").must_equal "Bar"
    example.instance_variable_get("@baz").must_equal "Baz"
  end

  it "treats hash values as optional" do
    klass = Class.new do
      attr_initialize :foo, [:bar, :baz]
    end

    example = klass.new("Foo", :bar => "Bar")
    example.instance_variable_get("@baz").must_equal nil

    example = klass.new("Foo")
    example.instance_variable_get("@bar").must_equal nil
  end

  it "can require hash values" do
    klass = Class.new do
      attr_initialize [:optional, :required!]
    end

    example = klass.new(:required => "X")
    example.instance_variable_get("@required").must_equal "X"

    lambda { klass.new(:optional => "X") }.must_raise KeyError
  end

  it "accepts a block for initialization" do
    klass = Class.new do
      attr_initialize :value do
        @copy = @value
      end

      attr_reader :copy
    end

    example = klass.new("expected")

    example.copy.must_equal "expected"
  end
end
