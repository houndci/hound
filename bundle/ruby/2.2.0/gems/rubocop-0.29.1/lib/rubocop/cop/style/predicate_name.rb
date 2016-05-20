# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop makes sure that predicates are named properly.
      #
      # @example
      #   # bad
      #   def is_even?(value) ...
      #
      #   # good
      #   def even?(value)
      #
      #   # bad
      #   def has_value? ...
      #
      #   # good
      #   def value? ...
      class PredicateName < Cop
        include OnMethodDef

        private

        def on_method_def(node, method_name, _args, _body)
          predicate_prefices.each do |prefix|
            method_name = method_name.to_s
            next unless method_name.start_with?(prefix)
            next if method_name == expected_name(method_name, prefix)
            add_offense(
              node,
              :name,
              message(method_name, expected_name(method_name, prefix))
            )
          end
        end

        def expected_name(method_name, prefix)
          new_name = if prefix_blacklist.include?(prefix)
                       method_name.sub(prefix, '')
                     else
                       method_name.dup
                     end
          new_name << '?' unless method_name.end_with?('?')
          new_name
        end

        def message(method_name, new_name)
          "Rename `#{method_name}` to `#{new_name}`."
        end

        def prefix_blacklist
          cop_config['NamePrefixBlacklist']
        end

        def predicate_prefices
          cop_config['NamePrefix']
        end
      end
    end
  end
end
