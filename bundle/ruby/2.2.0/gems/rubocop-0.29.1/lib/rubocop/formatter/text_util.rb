# encoding: utf-8

module RuboCop
  module Formatter
    # Common logic for UI texts.
    module TextUtil
      module_function

      def pluralize(number, thing, options = {})
        text = ''

        if number == 0 && options[:no_for_zero]
          text = 'no'
        else
          text << number.to_s
        end

        text << " #{thing}"
        text << 's' unless number == 1

        text
      end
    end
  end
end
