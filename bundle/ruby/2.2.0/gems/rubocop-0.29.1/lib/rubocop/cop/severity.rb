# encoding: utf-8

module RuboCop
  module Cop
    # Severity class is simple value object about severity
    class Severity
      include Comparable

      # @api private
      NAMES = [:refactor, :convention, :warning, :error, :fatal]

      # @api private
      CODE_TABLE = { R: :refactor, C: :convention,
                     W: :warning, E: :error, F: :fatal }

      # @api public
      #
      # @!attribute [r] name
      #
      # @return [Symbol]
      #   severity.
      #   any of `:refactor`, `:convention`, `:warning`, `:error` or `:fatal`.
      attr_reader :name

      # @api private
      def self.name_from_code(code)
        name = code.to_sym
        CODE_TABLE[name] || name
      end

      # @api private
      def initialize(name_or_code)
        name = Severity.name_from_code(name_or_code)
        unless NAMES.include?(name)
          fail ArgumentError, "Unknown severity: #{name}"
        end
        @name = name.freeze
        freeze
      end

      # @api private
      def to_s
        @name.to_s
      end

      # @api private
      def code
        @name.to_s[0].upcase
      end

      # @api private
      def level
        NAMES.index(name) + 1
      end

      # @api private
      def ==(other)
        if other.is_a?(Symbol)
          @name == other
        else
          @name == other.name
        end
      end

      # @api private
      def hash
        @name.hash
      end

      # @api private
      def <=>(other)
        level <=> other.level
      end
    end
  end
end
