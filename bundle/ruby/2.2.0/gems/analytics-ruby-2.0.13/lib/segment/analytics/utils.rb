require 'securerandom'

module Segment
  class Analytics
    module Utils
      extend self

      # public: Return a new hash with keys converted from strings to symbols
      #
      def symbolize_keys(hash)
        hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
      end

      # public: Convert hash keys from strings to symbols in place
      #
      def symbolize_keys!(hash)
        hash.replace symbolize_keys hash
      end

      # public: Return a new hash with keys as strings
      #
      def stringify_keys(hash)
        hash.inject({}) { |memo, (k,v)| memo[k.to_s] = v; memo }
      end

      # public: Returns a new hash with all the date values in the into iso8601
      #         strings
      #
      def isoify_dates(hash)
        hash.inject({}) { |memo, (k, v)|
          memo[k] = datetime_in_iso8601(v)
          memo
        }
      end

      # public: Converts all the date values in the into iso8601 strings in place
      #
      def isoify_dates!(hash)
        hash.replace isoify_dates hash
      end

      # public: Returns a uid string
      #
      def uid
        arr = SecureRandom.random_bytes(16).unpack("NnnnnN")
        arr[2] = (arr[2] & 0x0fff) | 0x4000
        arr[3] = (arr[3] & 0x3fff) | 0x8000
        "%08x-%04x-%04x-%04x-%04x%08x" % arr
      end

      def datetime_in_iso8601 datetime
        case datetime
        when Time
            time_in_iso8601 datetime
        when DateTime
            time_in_iso8601 datetime.to_time
        when Date
          date_in_iso8601 datetime
        else
          datetime
        end
      end

      def time_in_iso8601 time, fraction_digits = 3
        fraction = if fraction_digits > 0
                     (".%06i" % time.usec)[0, fraction_digits + 1]
                   end

        "#{time.strftime("%Y-%m-%dT%H:%M:%S")}#{fraction}#{formatted_offset(time, true, 'Z')}"
      end

      def date_in_iso8601 date
        date.strftime("%F")
      end

      def formatted_offset time, colon = true, alternate_utc_string = nil
        time.utc? && alternate_utc_string || seconds_to_utc_offset(time.utc_offset, colon)
      end

      def seconds_to_utc_offset(seconds, colon = true)
        (colon ? UTC_OFFSET_WITH_COLON : UTC_OFFSET_WITHOUT_COLON) % [(seconds < 0 ? '-' : '+'), (seconds.abs / 3600), ((seconds.abs % 3600) / 60)]
      end

      UTC_OFFSET_WITH_COLON = '%s%02d:%02d'
      UTC_OFFSET_WITHOUT_COLON = UTC_OFFSET_WITH_COLON.sub(':', '')
    end
  end
end
