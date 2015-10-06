require 'json'
module Raven
  class Processor::SanitizeData < Processor
    STRING_MASK = '********'
    INT_MASK = 0
    DEFAULT_FIELDS = %w(authorization password passwd secret ssn social(.*)?sec)
    CREDIT_CARD_RE = /^(?:\d[ -]*?){13,16}$/
    REGEX_SPECIAL_CHARACTERS = %w(. $ ^ { [ ( | ) * + ?)

    attr_accessor :sanitize_fields, :sanitize_credit_cards

    def initialize(client)
      super
      self.sanitize_fields = client.configuration.sanitize_fields
      self.sanitize_credit_cards = client.configuration.sanitize_credit_cards
    end

    def process(value)
      value.inject(value) { |memo,(k,v)|  memo[k] = sanitize(k,v); memo }
    end

    def sanitize(k,v)
      if v.is_a?(Hash)
        process(v)
      elsif v.is_a?(Array)
        v.map{|a| sanitize(k, a)}
      elsif k.to_s == 'query_string'
        sanitize_query_string(v)
      elsif v.is_a?(Integer) && matches_regexes?(k,v)
        INT_MASK
      elsif v.is_a?(String)
        if fields_re.match(v.to_s) && (json = parse_json_or_nil(v))
          #if this string is actually a json obj, convert and sanitize
          json.is_a?(Hash) ? process(json).to_json : v
        elsif matches_regexes?(k,v)
          STRING_MASK
        else
          v
        end
      else
        v
      end
    end

    private

    def sanitize_query_string(query_string)
      query_hash = CGI::parse(query_string)
      processed_query_hash = process(query_hash)
      URI.encode_www_form(processed_query_hash)
    end

    def matches_regexes?(k, v)
      (sanitize_credit_cards && CREDIT_CARD_RE.match(v.to_s)) ||
        fields_re.match(k.to_s)
    end

    def fields_re
      @fields_re ||= /#{(DEFAULT_FIELDS | sanitize_fields).map do |f|
        use_boundary?(f) ? "\\b#{f}\\b" : f
      end.join("|")}/i
    end

    def use_boundary?(string)
      !DEFAULT_FIELDS.include?(string) && !special_characters?(string)
    end

    def special_characters?(string)
      REGEX_SPECIAL_CHARACTERS.select { |r| string.include?(r) }.any?
    end

    def parse_json_or_nil(string)
      begin
        OkJson.decode(string)
      rescue Raven::OkJson::Error, NoMethodError
        nil
      end
    end
  end
end
