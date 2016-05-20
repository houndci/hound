require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/statement_pool'
require 'arel/visitors/bind_visitor'

gem 'sqlite3', '~> 1.3.6'
require 'sqlite3'

module ActiveRecord
  module ConnectionHandling # :nodoc:
    # sqlite3 adapter reuses sqlite_connection.
    def sqlite3_connection(config)
      # Require database.
      unless config[:database]
        raise ArgumentError, "No database file specified. Missing argument: database"
      end

      # Allow database path relative to Rails.root, but only if the database
      # path is not the special path that tells sqlite to build a database only
      # in memory.
      if ':memory:' != config[:database]
        config[:database] = File.expand_path(config[:database], Rails.root) if defined?(Rails.root)
        dirname = File.dirname(config[:database])
        Dir.mkdir(dirname) unless File.directory?(dirname)
      end

      db = SQLite3::Database.new(
        config[:database].to_s,
        :results_as_hash => true
      )

      db.busy_timeout(ConnectionAdapters::SQLite3Adapter.type_cast_config_to_integer(config[:timeout])) if config[:timeout]

      ConnectionAdapters::SQLite3Adapter.new(db, logger, nil, config)
    rescue Errno::ENOENT => error
      if error.message.include?("No such file or directory")
        raise ActiveRecord::NoDatabaseError.new(error.message, error)
      else
        raise
      end
    end
  end

  module ConnectionAdapters #:nodoc:
    class SQLite3Binary < Type::Binary # :nodoc:
      def cast_value(value)
        if value.encoding != Encoding::ASCII_8BIT
          value = value.force_encoding(Encoding::ASCII_8BIT)
        end
        value
      end
    end

    # The SQLite3 adapter works SQLite 3.6.16 or newer
    # with the sqlite3-ruby drivers (available as gem from https://rubygems.org/gems/sqlite3).
    #
    # Options:
    #
    # * <tt>:database</tt> - Path to the database file.
    class SQLite3Adapter < AbstractAdapter
      ADAPTER_NAME = 'SQLite'.freeze
      include Savepoints

      NATIVE_DATABASE_TYPES = {
        primary_key:  'INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL',
        string:       { name: "varchar" },
        text:         { name: "text" },
        integer:      { name: "integer" },
        float:        { name: "float" },
        decimal:      { name: "decimal" },
        datetime:     { name: "datetime" },
        time:         { name: "time" },
        date:         { name: "date" },
        binary:       { name: "blob" },
        boolean:      { name: "boolean" }
      }

      class Version
        include Comparable

        def initialize(version_string)
          @version = version_string.split('.').map { |v| v.to_i }
        end

        def <=>(version_string)
          @version <=> version_string.split('.').map { |v| v.to_i }
        end
      end

      class StatementPool < ConnectionAdapters::StatementPool
        def initialize(connection, max)
          super
          @cache = Hash.new { |h,pid| h[pid] = {} }
        end

        def each(&block); cache.each(&block); end
        def key?(key);    cache.key?(key); end
        def [](key);      cache[key]; end
        def length;       cache.length; end

        def []=(sql, key)
          while @max <= cache.size
            dealloc(cache.shift.last[:stmt])
          end
          cache[sql] = key
        end

        def clear
          cache.each_value do |hash|
            dealloc hash[:stmt]
          end
          cache.clear
        end

        private
        def cache
          @cache[$$]
        end

        def dealloc(stmt)
          stmt.close unless stmt.closed?
        end
      end

      def initialize(connection, logger, connection_options, config)
        super(connection, logger)

        @active     = nil
        @statements = StatementPool.new(@connection,
                                        self.class.type_cast_config_to_integer(config.fetch(:statement_limit) { 1000 }))
        @config = config

        @visitor = Arel::Visitors::SQLite.new self

        if self.class.type_cast_config_to_boolean(config.fetch(:prepared_statements) { true })
          @prepared_statements = true
        else
          @prepared_statements = false
        end
      end

      def supports_ddl_transactions?
        true
      end

      def supports_savepoints?
        true
      end

      def supports_partial_index?
        sqlite_version >= '3.8.0'
      end

      # Returns true, since this connection adapter supports prepared statement
      # caching.
      def supports_statement_cache?
        true
      end

      # Returns true, since this connection adapter supports migrations.
      def supports_migrations? #:nodoc:
        true
      end

      def supports_primary_key? #:nodoc:
        true
      end

      def requires_reloading?
        true
      end

      def supports_views?
        true
      end

      def active?
        @active != false
      end

      # Disconnects from the database if already connected. Otherwise, this
      # method does nothing.
      def disconnect!
        super
        @active = false
        @connection.close rescue nil
      end

      # Clears the prepared statements cache.
      def clear_cache!
        @statements.clear
      end

      def supports_index_sort_order?
        true
      end

      # Returns 62. SQLite supports index names up to 64
      # characters. The rest is used by rails internally to perform
      # temporary rename operations
      def allowed_index_name_length
        index_name_length - 2
      end

      def native_database_types #:nodoc:
        NATIVE_DATABASE_TYPES
      end

      # Returns the current database encoding format as a string, eg: 'UTF-8'
      def encoding
        @connection.encoding.to_s
      end

      def supports_explain?
        true
      end

      # QUOTING ==================================================

      def _quote(value) # :nodoc:
        case value
        when Type::Binary::Data
          "x'#{value.hex}'"
        else
          super
        end
      end

      def _type_cast(value) # :nodoc:
        case value
        when BigDecimal
          value.to_f
        when String
          if value.encoding == Encoding::ASCII_8BIT
            super(value.encode(Encoding::UTF_8))
          else
            super
          end
        else
          super
        end
      end

      def quote_string(s) #:nodoc:
        @connection.class.quote(s)
      end

      def quote_table_name_for_assignment(table, attr)
        quote_column_name(attr)
      end

      def quote_column_name(name) #:nodoc:
        %Q("#{name.to_s.gsub('"', '""')}")
      end

      # Quote date/time values for use in SQL input. Includes microseconds
      # if the value is a Time responding to usec.
      def quoted_date(value) #:nodoc:
        if value.respond_to?(:usec)
          "#{super}.#{sprintf("%06d", value.usec)}"
        else
          super
        end
      end

      #--
      # DATABASE STATEMENTS ======================================
      #++

      def explain(arel, binds = [])
        sql = "EXPLAIN QUERY PLAN #{to_sql(arel, binds)}"
        ExplainPrettyPrinter.new.pp(exec_query(sql, 'EXPLAIN', []))
      end

      class ExplainPrettyPrinter
        # Pretty prints the result of a EXPLAIN QUERY PLAN in a way that resembles
        # the output of the SQLite shell:
        #
        #   0|0|0|SEARCH TABLE users USING INTEGER PRIMARY KEY (rowid=?) (~1 rows)
        #   0|1|1|SCAN TABLE posts (~100000 rows)
        #
        def pp(result) # :nodoc:
          result.rows.map do |row|
            row.join('|')
          end.join("\n") + "\n"
        end
      end

      def exec_query(sql, name = nil, binds = [])
        type_casted_binds = binds.map { |col, val|
          [col, type_cast(val, col)]
        }

        log(sql, name, type_casted_binds) do
          # Don't cache statements if they are not prepared
          if without_prepared_statement?(binds)
            stmt    = @connection.prepare(sql)
            begin
              cols    = stmt.columns
              records = stmt.to_a
            ensure
              stmt.close
            end
            stmt = records
          else
            cache = @statements[sql] ||= {
              :stmt => @connection.prepare(sql)
            }
            stmt = cache[:stmt]
            cols = cache[:cols] ||= stmt.columns
            stmt.reset!
            stmt.bind_params type_casted_binds.map { |_, val| val }
          end

          ActiveRecord::Result.new(cols, stmt.to_a)
        end
      end

      def exec_delete(sql, name = 'SQL', binds = [])
        exec_query(sql, name, binds)
        @connection.changes
      end
      alias :exec_update :exec_delete

      def last_inserted_id(result)
        @connection.last_insert_row_id
      end

      def execute(sql, name = nil) #:nodoc:
        log(sql, name) { @connection.execute(sql) }
      end

      def update_sql(sql, name = nil) #:nodoc:
        super
        @connection.changes
      end

      def delete_sql(sql, name = nil) #:nodoc:
        sql += " WHERE 1=1" unless sql =~ /WHERE/i
        super sql, name
      end

      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil) #:nodoc:
        super
        id_value || @connection.last_insert_row_id
      end
      alias :create :insert_sql

      def select_rows(sql, name = nil, binds = [])
        exec_query(sql, name, binds).rows
      end

      def begin_db_transaction #:nodoc:
        log('begin transaction',nil) { @connection.transaction }
      end

      def commit_db_transaction #:nodoc:
        log('commit transaction',nil) { @connection.commit }
      end

      def exec_rollback_db_transaction #:nodoc:
        log('rollback transaction',nil) { @connection.rollback }
      end

      # SCHEMA STATEMENTS ========================================

      def tables(name = nil, table_name = nil) #:nodoc:
        sql = <<-SQL
          SELECT name
          FROM sqlite_master
          WHERE (type = 'table' OR type = 'view') AND NOT name = 'sqlite_sequence'
        SQL
        sql << " AND name = #{quote_table_name(table_name)}" if table_name

        exec_query(sql, 'SCHEMA').map do |row|
          row['name']
        end
      end

      def table_exists?(table_name)
        table_name && tables(nil, table_name).any?
      end

      # Returns an array of +Column+ objects for the table specified by +table_name+.
      def columns(table_name) #:nodoc:
        table_structure(table_name).map do |field|
          case field["dflt_value"]
          when /^null$/i
            field["dflt_value"] = nil
          when /^'(.*)'$/m
            field["dflt_value"] = $1.gsub("''", "'")
          when /^"(.*)"$/m
            field["dflt_value"] = $1.gsub('""', '"')
          end

          sql_type = field['type']
          cast_type = lookup_cast_type(sql_type)
          new_column(field['name'], field['dflt_value'], cast_type, sql_type, field['notnull'].to_i == 0)
        end
      end

      # Returns an array of indexes for the given table.
      def indexes(table_name, name = nil) #:nodoc:
        exec_query("PRAGMA index_list(#{quote_table_name(table_name)})", 'SCHEMA').map do |row|
          sql = <<-SQL
            SELECT sql
            FROM sqlite_master
            WHERE name=#{quote(row['name'])} AND type='index'
            UNION ALL
            SELECT sql
            FROM sqlite_temp_master
            WHERE name=#{quote(row['name'])} AND type='index'
          SQL
          index_sql = exec_query(sql).first['sql']
          match = /\sWHERE\s+(.+)$/i.match(index_sql)
          where = match[1] if match
          IndexDefinition.new(
            table_name,
            row['name'],
            row['unique'] != 0,
            exec_query("PRAGMA index_info('#{row['name']}')", "SCHEMA").map { |col|
              col['name']
            }, nil, nil, where)
        end
      end

      def primary_key(table_name) #:nodoc:
        pks = table_structure(table_name).select { |f| f['pk'] > 0 }
        return nil unless pks.count == 1
        pks[0]['name']
      end

      def remove_index!(table_name, index_name) #:nodoc:
        exec_query "DROP INDEX #{quote_column_name(index_name)}"
      end

      # Renames a table.
      #
      # Example:
      #   rename_table('octopuses', 'octopi')
      def rename_table(table_name, new_name)
        exec_query "ALTER TABLE #{quote_table_name(table_name)} RENAME TO #{quote_table_name(new_name)}"
        rename_table_indexes(table_name, new_name)
      end

      # See: http://www.sqlite.org/lang_altertable.html
      # SQLite has an additional restriction on the ALTER TABLE statement
      def valid_alter_table_type?(type)
        type.to_sym != :primary_key
      end

      def add_column(table_name, column_name, type, options = {}) #:nodoc:
        if valid_alter_table_type?(type)
          super(table_name, column_name, type, options)
        else
          alter_table(table_name) do |definition|
            definition.column(column_name, type, options)
          end
        end
      end

      def remove_column(table_name, column_name, type = nil, options = {}) #:nodoc:
        alter_table(table_name) do |definition|
          definition.remove_column column_name
        end
      end

      def change_column_default(table_name, column_name, default) #:nodoc:
        alter_table(table_name) do |definition|
          definition[column_name].default = default
        end
      end

      def change_column_null(table_name, column_name, null, default = nil)
        unless null || default.nil?
          exec_query("UPDATE #{quote_table_name(table_name)} SET #{quote_column_name(column_name)}=#{quote(default)} WHERE #{quote_column_name(column_name)} IS NULL")
        end
        alter_table(table_name) do |definition|
          definition[column_name].null = null
        end
      end

      def change_column(table_name, column_name, type, options = {}) #:nodoc:
        alter_table(table_name) do |definition|
          include_default = options_include_default?(options)
          definition[column_name].instance_eval do
            self.type    = type
            self.limit   = options[:limit] if options.include?(:limit)
            self.default = options[:default] if include_default
            self.null    = options[:null] if options.include?(:null)
            self.precision = options[:precision] if options.include?(:precision)
            self.scale   = options[:scale] if options.include?(:scale)
          end
        end
      end

      def rename_column(table_name, column_name, new_column_name) #:nodoc:
        column = column_for(table_name, column_name)
        alter_table(table_name, rename: {column.name => new_column_name.to_s})
        rename_column_indexes(table_name, column.name, new_column_name)
      end

      protected

        def initialize_type_map(m)
          super
          m.register_type(/binary/i, SQLite3Binary.new)
        end

        def table_structure(table_name)
          structure = exec_query("PRAGMA table_info(#{quote_table_name(table_name)})", 'SCHEMA').to_hash
          raise(ActiveRecord::StatementInvalid, "Could not find table '#{table_name}'") if structure.empty?
          structure
        end

        def alter_table(table_name, options = {}) #:nodoc:
          altered_table_name = "a#{table_name}"
          caller = lambda {|definition| yield definition if block_given?}

          transaction do
            move_table(table_name, altered_table_name,
              options.merge(:temporary => true))
            move_table(altered_table_name, table_name, &caller)
          end
        end

        def move_table(from, to, options = {}, &block) #:nodoc:
          copy_table(from, to, options, &block)
          drop_table(from)
        end

        def copy_table(from, to, options = {}) #:nodoc:
          from_primary_key = primary_key(from)
          options[:id] = false
          create_table(to, options) do |definition|
            @definition = definition
            @definition.primary_key(from_primary_key) if from_primary_key.present?
            columns(from).each do |column|
              column_name = options[:rename] ?
                (options[:rename][column.name] ||
                 options[:rename][column.name.to_sym] ||
                 column.name) : column.name
              next if column_name == from_primary_key

              @definition.column(column_name, column.type,
                :limit => column.limit, :default => column.default,
                :precision => column.precision, :scale => column.scale,
                :null => column.null)
            end
            yield @definition if block_given?
          end
          copy_table_indexes(from, to, options[:rename] || {})
          copy_table_contents(from, to,
            @definition.columns.map {|column| column.name},
            options[:rename] || {})
        end

        def copy_table_indexes(from, to, rename = {}) #:nodoc:
          indexes(from).each do |index|
            name = index.name
            if to == "a#{from}"
              name = "t#{name}"
            elsif from == "a#{to}"
              name = name[1..-1]
            end

            to_column_names = columns(to).map { |c| c.name }
            columns = index.columns.map {|c| rename[c] || c }.select do |column|
              to_column_names.include?(column)
            end

            unless columns.empty?
              # index name can't be the same
              opts = { name: name.gsub(/(^|_)(#{from})_/, "\\1#{to}_"), internal: true }
              opts[:unique] = true if index.unique
              add_index(to, columns, opts)
            end
          end
        end

        def copy_table_contents(from, to, columns, rename = {}) #:nodoc:
          column_mappings = Hash[columns.map {|name| [name, name]}]
          rename.each { |a| column_mappings[a.last] = a.first }
          from_columns = columns(from).collect {|col| col.name}
          columns = columns.find_all{|col| from_columns.include?(column_mappings[col])}
          quoted_columns = columns.map { |col| quote_column_name(col) } * ','

          quoted_to = quote_table_name(to)

          raw_column_mappings = Hash[columns(from).map { |c| [c.name, c] }]

          exec_query("SELECT * FROM #{quote_table_name(from)}").each do |row|
            sql = "INSERT INTO #{quoted_to} (#{quoted_columns}) VALUES ("

            column_values = columns.map do |col|
              quote(row[column_mappings[col]], raw_column_mappings[col])
            end

            sql << column_values * ', '
            sql << ')'
            exec_query sql
          end
        end

        def sqlite_version
          @sqlite_version ||= SQLite3Adapter::Version.new(select_value('select sqlite_version(*)'))
        end

        def translate_exception(exception, message)
          case exception.message
          # SQLite 3.8.2 returns a newly formatted error message:
          #   UNIQUE constraint failed: *table_name*.*column_name*
          # Older versions of SQLite return:
          #   column *column_name* is not unique
          when /column(s)? .* (is|are) not unique/, /UNIQUE constraint failed: .*/
            RecordNotUnique.new(message, exception)
          else
            super
          end
        end
    end
  end
end
