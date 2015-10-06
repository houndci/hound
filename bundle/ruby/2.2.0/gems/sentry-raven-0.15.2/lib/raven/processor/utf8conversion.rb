module Raven
  class Processor::UTF8Conversion < Processor

    def process(value)
      if value.is_a? Array
        value.map { |v| process v }
      elsif value.is_a? Hash
        value.merge(value) { |_, v| process v }
      else
        clean_invalid_utf8_bytes(value)
      end
    end

    private

    def clean_invalid_utf8_bytes(obj)
      if obj.respond_to?(:to_utf8)
        obj.to_utf8
      elsif obj.respond_to?(:encoding) && obj.is_a?(String)
        obj.encode('UTF-16', :invalid => :replace, :undef => :replace, :replace => '').encode('UTF-8')
      else
        obj
      end
    end
  end
end
