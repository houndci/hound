# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of the read_attribute or
      # write_attribute methods.
      #
      # @example
      #
      #   # bad
      #   x = read_attributed(:attr)
      #   write_attribute(:attr, val)
      #
      #   # good
      #   x = self[:attr]
      #   self[:attr] = val
      class ReadWriteAttribute < Cop
        MSG = 'Prefer `%s` over `%s`.'

        def on_send(node)
          receiver, method_name, *_args = *node
          return if receiver
          return unless [:read_attribute,
                         :write_attribute].include?(method_name)

          add_offense(node, :selector)
        end

        def message(node)
          _receiver, method_name, *_args = *node

          if method_name == :read_attribute
            format(MSG, 'self[:attr]', 'read_attribute(:attr)')
          else
            format(MSG, 'self[:attr] = val', 'write_attribute(:attr, var)')
          end
        end

        def autocorrect(node)
          _receiver, method_name, _body = *node

          case method_name
          when :read_attribute
            replacement = read_attribute_replacement(node)
          when :write_attribute
            replacement = write_attribute_replacement(node)
          end

          @corrections << lambda do |corrector|
            corrector.replace(node.loc.expression, replacement)
          end
        end

        private

        def read_attribute_replacement(node)
          _receiver, _method_name, body = *node

          "self[#{body.loc.expression.source}]"
        end

        def write_attribute_replacement(node)
          _receiver, _method_name, *args = *node
          name, value = *args

          name_source = name.loc.expression.source
          value_source = value.loc.expression.source

          "self[#{name_source}] = #{value_source}"
        end
      end
    end
  end
end
