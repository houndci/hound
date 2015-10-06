require "attr_extras/version"
require "attr_extras/attr_initialize"
require "attr_extras/attr_value"
require "attr_extras/attr_query"
require "attr_extras/utils"

module AttrExtras
  # To avoid masking coding errors, we don't inherit from StandardError (which would be implicitly rescued). Forgetting to define a requisite method isn't just some runtime error.
  class MethodNotImplementedError < Exception; end

  def self.mixin
    self::ModuleMethods
  end

  # Separate module for `include`ing so that mixing in the methods doesn't also mix in constants:
  # http://thepugautomatic.com/2014/02/private-api/
  module ModuleMethods
    def attr_initialize(*names, &block)
      AttrInitialize.new(self, names, block).apply
    end

    def attr_private(*names)
      # Need this to avoid "private attribute?" warnings when running
      # the full test suite; not sure why exactly.
      public

      attr_reader(*names)
      private(*names)
    end

    def attr_value(*names)
      AttrValue.new(self, *names).apply
    end

    def pattr_initialize(*names, &block)
      attr_initialize(*names, &block)
      attr_private(*Utils.flat_names(names))
    end

    alias_method :attr_private_initialize, :pattr_initialize

    def vattr_initialize(*names, &block)
      attr_initialize(*names, &block)
      attr_value(*Utils.flat_names(names))
    end

    alias_method :attr_value_initialize, :vattr_initialize

    def rattr_initialize(*names, &block)
      attr_initialize(*names, &block)
      attr_reader(*Utils.flat_names(names))
    end

    alias_method :attr_reader_initialize, :rattr_initialize

    def static_facade(method_name, *names)
      define_singleton_method(method_name) do |*values|
        new(*values).public_send(method_name)
      end

      pattr_initialize(*names)
    end

    def method_object(*names)
      static_facade :call, *names
    end

    def attr_query(*names)
      AttrQuery.define_with_suffix(self, "", *names)
    end

    def attr_id_query(*names)
      AttrQuery.define_with_suffix(self, "_id", *names)
    end

    def attr_implement(*names)
      arg_names = names.last.is_a?(Array) ? names.pop : []
      arity = arg_names.length

      mod = Module.new do
        define_method :method_missing do |name, *args|
          if names.include?(name)
            provided_arity = args.length

            if provided_arity != arity
              raise ArgumentError, "wrong number of arguments (#{provided_arity} for #{arity})"
            end

            raise MethodNotImplementedError, "Implement a '#{name}(#{arg_names.join(", ")})' method"
          else
            super(name, *args)
          end
        end
      end

      include mod
    end
  end
end
