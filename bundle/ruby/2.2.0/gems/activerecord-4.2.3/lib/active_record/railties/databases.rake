require 'active_record'

db_namespace = namespace :db do
  task :load_config do
    ActiveRecord::Base.configurations       = ActiveRecord::Tasks::DatabaseTasks.database_configuration || {}
    ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
  end

  namespace :create do
    task :all => :load_config do
      ActiveRecord::Tasks::DatabaseTasks.create_all
    end
  end

  desc 'Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:create:all to create all databases in the config). Without RAILS_ENV it defaults to creating the development and test databases.'
  task :create => [:load_config] do
    ActiveRecord::Tasks::DatabaseTasks.create_current
  end

  namespace :drop do
    task :all => :load_config do
      ActiveRecord::Tasks::DatabaseTasks.drop_all
    end
  end

  desc 'Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:drop:all to drop all databases in the config). Without RAILS_ENV it defaults to dropping the development and test databases.'
  task :drop => [:load_config] do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
  end

  namespace :purge do
    task :all => :load_config do
      ActiveRecord::Tasks::DatabaseTasks.purge_all
    end
  end

  # desc "Empty the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:drop:all to drop all databases in the config). Without RAILS_ENV it defaults to purging the development and test databases."
  task :purge => [:load_config] do
    ActiveRecord::Tasks::DatabaseTasks.purge_current
  end

  desc "Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)."
  task :migrate => [:environment, :load_config] do
    ActiveRecord::Tasks::DatabaseTasks.migrate
    db_namespace['_dump'].invoke if ActiveRecord::Base.dump_schema_after_migration
  end

  task :_dump do
    case ActiveRecord::Base.schema_format
    when :ruby then db_namespace["schema:dump"].invoke
    when :sql  then db_namespace["structure:dump"].invoke
    else
      raise "unknown schema format #{ActiveRecord::Base.schema_format}"
    end
    # Allow this task to be called as many times as required. An example is the
    # migrate:redo task, which calls other two internally that depend on this one.
    db_namespace['_dump'].reenable
  end

  namespace :migrate do
    # desc  'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo => [:environment, :load_config] do
      if ENV['VERSION']
        db_namespace['migrate:down'].invoke
        db_namespace['migrate:up'].invoke
      else
        db_namespace['rollback'].invoke
        db_namespace['migrate'].invoke
      end
    end

    # desc 'Resets your database using your migrations for the current environment'
    task :reset => ['db:drop', 'db:create', 'db:migrate']

    # desc 'Runs the "up" for a given migration VERSION.'
    task :up => [:environment, :load_config] do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_paths, version)
      db_namespace['_dump'].invoke
    end

    # desc 'Runs the "down" for a given migration VERSION.'
    task :down => [:environment, :load_config] do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required - To go down one migration, run db:rollback' unless version
      ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_paths, version)
      db_namespace['_dump'].invoke
    end

    desc 'Display status of migrations'
    task :status => [:environment, :load_config] do
      unless ActiveRecord::SchemaMigration.table_exists?
        abort 'Schema migrations table does not exist yet.'
      end
      db_list = ActiveRecord::SchemaMigration.normalized_versions

      file_list =
          ActiveRecord::Migrator.migrations_paths.flat_map do |path|
            # match "20091231235959_some_name.rb" and "001_some_name.rb" pattern
            Dir.foreach(path).grep(/^(\d{3,})_(.+)\.rb$/) do
              version = ActiveRecord::SchemaMigration.normalize_migration_number($1)
              status = db_list.delete(version) ? 'up' : 'down'
              [status, version, $2.humanize]
            end
          end

      db_list.map! do |version|
        ['up', version, '********** NO FILE **********']
      end
      # output
      puts "\ndatabase: #{ActiveRecord::Base.connection_config[:database]}\n\n"
      puts "#{'Status'.center(8)}  #{'Migration ID'.ljust(14)}  Migration Name"
      puts "-" * 50
      (db_list + file_list).sort_by { |_, version, _| version }.each do |status, version, name|
        puts "#{status.center(8)}  #{version.ljust(14)}  #{name}"
      end
      puts
    end
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => [:environment, :load_config] do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
    db_namespace['_dump'].invoke
  end

  # desc 'Pushes the schema to the next version (specify steps w/ STEP=n).'
  task :forward => [:environment, :load_config] do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.forward(ActiveRecord::Migrator.migrations_paths, step)
    db_namespace['_dump'].invoke
  end

  # desc 'Drops and recreates the database from db/schema.rb for the current environment and loads the seeds.'
  task :reset => [:environment, :load_config] do
    db_namespace["drop"].invoke
    db_namespace["setup"].invoke
  end

  # desc "Retrieves the charset for the current environment's database"
  task :charset => [:environment, :load_config] do
    puts ActiveRecord::Tasks::DatabaseTasks.charset_current
  end

  # desc "Retrieves the collation for the current environment's database"
  task :collation => [:environment, :load_config] do
    begin
      puts ActiveRecord::Tasks::DatabaseTasks.collation_current
    rescue NoMethodError
      $stderr.puts 'Sorry, your database adapter is not supported yet. Feel free to submit a patch.'
    end
  end

  desc 'Retrieves the current schema version number'
  task :version => [:environment, :load_config] do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  # desc "Raises an error if there are pending migrations"
  task :abort_if_pending_migrations => :environment do
    pending_migrations = ActiveRecord::Migrator.open(ActiveRecord::Migrator.migrations_paths).pending_migrations

    if pending_migrations.any?
      puts "You have #{pending_migrations.size} pending #{pending_migrations.size > 1 ? 'migrations:' : 'migration:'}"
      pending_migrations.each do |pending_migration|
        puts '  %4d %s' % [pending_migration.version, pending_migration.name]
      end
      abort %{Run `rake db:migrate` to update your database then try again.}
    end
  end

  desc 'Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the database first)'
  task :setup => ['db:schema:load_if_ruby', 'db:structure:load_if_sql', :seed]

  desc 'Load the seed data from db/seeds.rb'
  task :seed do
    db_namespace['abort_if_pending_migrations'].invoke
    ActiveRecord::Tasks::DatabaseTasks.load_seed
  end

  namespace :fixtures do
    desc "Load fixtures into the current environment's database. Load specific fixtures using FIXTURES=x,y. Load from subdirectory in test/fixtures using FIXTURES_DIR=z. Specify an alternative path (eg. spec/fixtures) using FIXTURES_PATH=spec/fixtures."
    task :load => [:environment, :load_config] do
      require 'active_record/fixtures'

      base_dir = ActiveRecord::Tasks::DatabaseTasks.fixtures_path

      fixtures_dir = if ENV['FIXTURES_DIR']
                       File.join base_dir, ENV['FIXTURES_DIR']
                     else
                       base_dir
                     end

      fixture_files = if ENV['FIXTURES']
                        ENV['FIXTURES'].split(',')
                      else
                        # The use of String#[] here is to support namespaced fixtures
                        Dir["#{fixtures_dir}/**/*.yml"].map {|f| f[(fixtures_dir.size + 1)..-5] }
                      end

      ActiveRecord::FixtureSet.create_fixtures(fixtures_dir, fixture_files)
    end

    # desc "Search for a fixture given a LABEL or ID. Specify an alternative path (eg. spec/fixtures) using FIXTURES_PATH=spec/fixtures."
    task :identify => [:environment, :load_config] do
      require 'active_record/fixtures'

      label, id = ENV['LABEL'], ENV['ID']
      raise 'LABEL or ID required' if label.blank? && id.blank?

      puts %Q(The fixture ID for "#{label}" is #{ActiveRecord::FixtureSet.identify(label)}.) if label

      base_dir = ActiveRecord::Tasks::DatabaseTasks.fixtures_path

      Dir["#{base_dir}/**/*.yml"].each do |file|
        if data = YAML::load(ERB.new(IO.read(file)).result)
          data.each_key do |key|
            key_id = ActiveRecord::FixtureSet.identify(key)

            if key == label || key_id == id.to_i
              puts "#{file}: #{key} (#{key_id})"
            end
          end
        end
      end
    end
  end

  namespace :schema do
    desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
    task :dump => [:environment, :load_config] do
      require 'active_record/schema_dumper'
      filename = ENV['SCHEMA'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'schema.rb')
      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
      db_namespace['schema:dump'].reenable
    end

    desc 'Load a schema.rb file into the database'
    task :load => [:environment, :load_config] do
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:ruby, ENV['SCHEMA'])
    end

    task :load_if_ruby => ['db:create', :environment] do
      db_namespace["schema:load"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    namespace :cache do
      desc 'Create a db/schema_cache.dump file.'
      task :dump => [:environment, :load_config] do
        con = ActiveRecord::Base.connection
        filename = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "schema_cache.dump")

        con.schema_cache.clear!
        con.tables.each { |table| con.schema_cache.add(table) }
        open(filename, 'wb') { |f| f.write(Marshal.dump(con.schema_cache)) }
      end

      desc 'Clear a db/schema_cache.dump file.'
      task :clear => [:environment, :load_config] do
        filename = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "schema_cache.dump")
        FileUtils.rm(filename) if File.exist?(filename)
      end
    end

  end

  namespace :structure do
    desc 'Dump the database structure to db/structure.sql. Specify another file with DB_STRUCTURE=db/my_structure.sql'
    task :dump => [:environment, :load_config] do
      filename = ENV['DB_STRUCTURE'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure.sql")
      current_config = ActiveRecord::Tasks::DatabaseTasks.current_config
      ActiveRecord::Tasks::DatabaseTasks.structure_dump(current_config, filename)

      if ActiveRecord::Base.connection.supports_migrations? &&
          ActiveRecord::SchemaMigration.table_exists?
        File.open(filename, "a") do |f|
          f.puts ActiveRecord::Base.connection.dump_schema_information
          f.print "\n"
        end
      end
      db_namespace['structure:dump'].reenable
    end

    desc "Recreate the databases from the structure.sql file"
    task :load => [:load_config] do
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:sql, ENV['DB_STRUCTURE'])
    end

    task :load_if_sql => ['db:create', :environment] do
      db_namespace["structure:load"].invoke if ActiveRecord::Base.schema_format == :sql
    end
  end

  namespace :test do

    task :deprecated do
      Rake.application.top_level_tasks.grep(/^db:test:/).each do |task|
        $stderr.puts "WARNING: #{task} is deprecated. The Rails test helper now maintains " \
                     "your test schema automatically, see the release notes for details."
      end
    end

    # desc "Recreate the test database from the current schema"
    task :load => %w(db:test:purge) do
      case ActiveRecord::Base.schema_format
        when :ruby
          db_namespace["test:load_schema"].invoke
        when :sql
          db_namespace["test:load_structure"].invoke
      end
    end

    # desc "Recreate the test database from an existent schema.rb file"
    task :load_schema => %w(db:test:purge) do
      begin
        should_reconnect = ActiveRecord::Base.connection_pool.active_connection?
        ActiveRecord::Schema.verbose = false
        ActiveRecord::Tasks::DatabaseTasks.load_schema_for ActiveRecord::Base.configurations['test'], :ruby, ENV['SCHEMA']
      ensure
        if should_reconnect
          ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[ActiveRecord::Tasks::DatabaseTasks.env])
        end
      end
    end

    # desc "Recreate the test database from an existent structure.sql file"
    task :load_structure => %w(db:test:purge) do
      ActiveRecord::Tasks::DatabaseTasks.load_schema_for ActiveRecord::Base.configurations['test'], :sql, ENV['SCHEMA']
    end

    # desc "Recreate the test database from a fresh schema"
    task :clone => %w(db:test:deprecated environment) do
      case ActiveRecord::Base.schema_format
        when :ruby
          db_namespace["test:clone_schema"].invoke
        when :sql
          db_namespace["test:clone_structure"].invoke
      end
    end

    # desc "Recreate the test database from a fresh schema.rb file"
    task :clone_schema => %w(db:test:deprecated db:schema:dump db:test:load_schema)

    # desc "Recreate the test database from a fresh structure.sql file"
    task :clone_structure => %w(db:test:deprecated db:structure:dump db:test:load_structure)

    # desc "Empty the test database"
    task :purge => %w(environment load_config) do
      ActiveRecord::Tasks::DatabaseTasks.purge ActiveRecord::Base.configurations['test']
    end

    # desc 'Check for pending migrations and load the test schema'
    task :prepare => %w(environment load_config) do
      unless ActiveRecord::Base.configurations.blank?
        db_namespace['test:load'].invoke
      end
    end
  end
end

namespace :railties do
  namespace :install do
    # desc "Copies missing migrations from Railties (e.g. engines). You can specify Railties to use with FROM=railtie1,railtie2"
    task :migrations => :'db:load_config' do
      to_load = ENV['FROM'].blank? ? :all : ENV['FROM'].split(",").map {|n| n.strip }
      railties = {}
      Rails.application.migration_railties.each do |railtie|
        next unless to_load == :all || to_load.include?(railtie.railtie_name)

        if railtie.respond_to?(:paths) && (path = railtie.paths['db/migrate'].first)
          railties[railtie.railtie_name] = path
        end
      end

      on_skip = Proc.new do |name, migration|
        puts "NOTE: Migration #{migration.basename} from #{name} has been skipped. Migration with the same name already exists."
      end

      on_copy = Proc.new do |name, migration|
        puts "Copied migration #{migration.basename} from #{name}"
      end

      ActiveRecord::Migration.copy(ActiveRecord::Migrator.migrations_paths.first, railties,
                                    :on_skip => on_skip, :on_copy => on_copy)
    end
  end
end
