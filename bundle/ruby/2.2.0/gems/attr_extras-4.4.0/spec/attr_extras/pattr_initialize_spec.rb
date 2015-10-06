require "spec_helper"

describe Object, ".pattr_initialize" do
  it "creates both initializer and private readers" do
    klass = Class.new do
      pattr_initialize :foo, :bar
    end

    example = klass.new("Foo", "Bar")
    example.send(:foo).must_equal "Foo"
  end

  it "works with hash ivars" do
    klass = Class.new do
      pattr_initialize :foo, [:bar, :baz!]
    end

    example = klass.new("Foo", :bar => "Bar", :baz => "Baz")
    example.send(:baz).must_equal "Baz"
  end

  it "can reference private initializer methods in an initializer block" do
    klass = Class.new do
      pattr_initialize :value do
        @copy = value
      end

      attr_reader :copy
    end

    example = klass.new("expected")

    example.copy.must_equal "expected"
  end

  it "accepts the alias attr_private_initializer" do
    klass = Class.new do
      attr_private_initialize :foo, :bar
    end

    example = klass.new("Foo", "Bar")
    example.send(:foo).must_equal "Foo"
  end
end
