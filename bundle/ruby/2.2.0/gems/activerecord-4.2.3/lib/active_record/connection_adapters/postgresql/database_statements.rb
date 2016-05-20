module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module DatabaseStatements
        def explain(arel, binds = [])
          sql = "EXPLAIN #{to_sql(arel, binds)}"
          ExplainPrettyPrinter.new.pp(exec_query(sql, 'EXPLAIN', binds))
        end

        class ExplainPrettyPrinter # :nodoc:
          # Pretty prints the result of a EXPLAIN in a way that resembles the output of the
          # PostgreSQL shell:
          #
          #                                     QUERY PLAN
          #   ------------------------------------------------------------------------------
          #    Nested Loop Left Join  (cost=0.00..37.24 rows=8 width=0)
          #      Join Filter: (posts.user_id = users.id)
          #      ->  Index Scan using users_pkey on users  (cost=0.00..8.27 rows=1 width=4)
          #            Index Cond: (id = 1)
          #      ->  Seq Scan on posts  (cost=0.00..28.88 rows=8 width=4)
          #            Filter: (posts.user_id = 1)
          #   (6 rows)
          #
          def pp(result)
            header = result.columns.first
            lines  = result.rows.map(&:first)

            # We add 2 because there's one char of padding at both sides, note
            # the extra hyphens in the example above.
            width = [header, *lines].map(&:length).max + 2

            pp = []

            pp << header.center(width).rstrip
            pp << '-' * width

            pp += lines.map {|line| " #{line}"}

            nrows = result.rows.length
            rows_label = nrows == 1 ? 'row' : 'rows'
            pp << "(#{nrows} #{rows_label})"

            pp.join("\n") + "\n"
          end
        end

        def select_value(arel, name = nil, binds = [])
          arel, binds = binds_from_relation arel, binds
          sql = to_sql(arel, binds)
          execute_and_clear(sql, name, binds) do |result|
            result.getvalue(0, 0) if result.ntuples > 0 && result.nfields > 0
          end
        end

        def select_values(arel, name = nil)
          arel, binds = binds_from_relation arel, []
          sql = to_sql(arel, binds)
          execute_and_clear(sql, name, binds) do |result|
            if result.nfields > 0
              result.column_values(0)
            else
              []
            end
          end
        end

        # Executes a SELECT query and returns an array of rows. Each row is an
        # array of field values.
        def select_rows(sql, name = nil, binds = [])
          execute_and_clear(sql, name, binds) do |result|
            result.values
          end
        end

        # Executes an INSERT query and returns the new record's ID
        def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
          unless pk
            # Extract the table from the insert sql. Yuck.
            table_ref = extract_table_ref_from_insert_sql(sql)
            pk = primary_key(table_ref) if table_ref
          end

          if pk && use_insert_returning?
            select_value("#{sql} RETURNING #{quote_column_name(pk)}")
          elsif pk
            super
            last_insert_id_value(sequence_name || default_sequence_name(table_ref, pk))
          else
            super
          end
        end

        def create
          super.insert
        end

        # The internal PostgreSQL identifier of the money data type.
        MONEY_COLUMN_TYPE_OID = 790 #:nodoc:
        # The internal PostgreSQL identifier of the BYTEA data type.
        BYTEA_COLUMN_TYPE_OID = 17 #:nodoc:

        # create a 2D array representing the result set
        def result_as_array(res) #:nodoc:
          # check if we have any binary column and if they need escaping
          ftypes = Array.new(res.nfields) do |i|
            [i, res.ftype(i)]
          end

          rows = res.values
          return rows unless ftypes.any? { |_, x|
            x == BYTEA_COLUMN_TYPE_OID || x == MONEY_COLUMN_TYPE_OID
          }

          typehash = ftypes.group_by { |_, type| type }
          binaries = typehash[BYTEA_COLUMN_TYPE_OID] || []
          monies   = typehash[MONEY_COLUMN_TYPE_OID] || []

          rows.each do |row|
            # unescape string passed BYTEA field (OID == 17)
            binaries.each do |index, _|
              row[index] = unescape_bytea(row[index])
            end

            # If this is a money type column and there are any currency symbols,
            # then strip them off. Indeed it would be prettier to do this in
            # PostgreSQLColumn.string_to_decimal but would break form input
            # fields that call value_before_type_cast.
            monies.each do |index, _|
              data = row[index]
              # Because money output is formatted according to the locale, there are two
              # cases to consider (note the decimal separators):
              #  (1) $12,345,678.12
              #  (2) $12.345.678,12
              case data
              when /^-?\D+[\d,]+\.\d{2}$/  # (1)
                data.gsub!(/[^-\d.]/, '')
              when /^-?\D+[\d.]+,\d{2}$/  # (2)
                data.gsub!(/[^-\d,]/, '').sub!(/,/, '.')
              end
            end
          end
        end

        # Queries the database and returns the results in an Array-like object
        def query(sql, name = nil) #:nodoc:
          log(sql, name) do
            result_as_array @connection.async_exec(sql)
          end
        end

        # Executes an SQL statement, returning a PGresult object on success
        # or raising a PGError exception otherwise.
        def execute(sql, name = nil)
          log(sql, name) do
            @connection.async_exec(sql)
          end
        end

        def exec_query(sql, name = 'SQL', binds = [])
          execute_and_clear(sql, name, binds) do |result|
            types = {}
            fields = result.fields
            fields.each_with_index do |fname, i|
              ftype = result.ftype i
              fmod  = result.fmod i
              types[fname] = get_oid_type(ftype, fmod, fname)
            end
            ActiveRecord::Result.new(fields, result.values, types)
          end
        end

        def exec_delete(sql, name = 'SQL', binds = [])
          execute_and_clear(sql, name, binds) {|result| result.cmd_tuples }
        end
        alias :exec_update :exec_delete

        def sql_for_insert(sql, pk, id_value, sequence_name, binds)
          unless pk
            # Extract the table from the insert sql. Yuck.
            table_ref = extract_table_ref_from_insert_sql(sql)
            pk = primary_key(table_ref) if table_ref
          end

          if pk && use_insert_returning?
            sql = "#{sql} RETURNING #{quote_column_name(pk)}"
          end

          [sql, binds]
        end

        def exec_insert(sql, name, binds, pk = nil, sequence_name = nil)
          val = exec_query(sql, name, binds)
          if !use_insert_returning? && pk
            unless sequence_name
              table_ref = extract_table_ref_from_insert_sql(sql)
              sequence_name = default_sequence_name(table_ref, pk)
              return val unless sequence_name
            end
            last_insert_id_result(sequence_name)
          else
            val
          end
        end

        # Executes an UPDATE query and returns the number of affected tuples.
        def update_sql(sql, name = nil)
          super.cmd_tuples
        end

        # Begins a transaction.
        def begin_db_transaction
          execute "BEGIN"
        end

        def begin_isolated_db_transaction(isolation)
          begin_db_transaction
          execute "SET TRANSACTION ISOLATION LEVEL #{transaction_isolation_levels.fetch(isolation)}"
        end

        # Commits a transaction.
        def commit_db_transaction
          execute "COMMIT"
        end

        # Aborts a transaction.
        def exec_rollback_db_transaction
          execute "ROLLBACK"
        end
      end
    end
  end
end
