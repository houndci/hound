module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class Jsonb < Json # :nodoc:
          def type
            :jsonb
          end

          def changed_in_place?(raw_old_value, new_value)
            # Postgres does not preserve insignificant whitespaces when
            # roundtripping jsonb columns. This causes some false positives for
            # the comparison here. Therefore, we need to parse and re-dump the
            # raw value here to ensure the insignificant whitespaces are
            # consistent with our encoder's output.
            raw_old_value = type_cast_for_database(type_cast_from_database(raw_old_value))
            super(raw_old_value, new_value)
          end
        end
      end
    end
  end
end
