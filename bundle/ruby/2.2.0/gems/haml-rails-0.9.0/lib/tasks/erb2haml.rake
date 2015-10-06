namespace :haml do
  desc 'Convert html.erb to html.haml each file in app/views'
  task :erb2haml do

    erb_files = Dir.glob('app/views/**/*.erb').select { |f| File.file? f}
    haml_files = Dir.glob('app/views/**/*.haml').select { |f| File.file? f}

    if erb_files.empty?
      puts "No .erb files found. Task will now exit."
      exit
    end

    haml_files_w_out_ext = haml_files.map { |f| f.gsub(/\.haml\z/, '') }

    # Get a list of all those erb files that already seem to have .haml equivalents

    already_existing = erb_files.select { |f| short = f.gsub(/\.erb\z/, ''); haml_files_w_out_ext.include?(short) }

    puts '-'*80

    if already_existing.any?
      puts "Some of your .html.erb files seem to already have .haml equivalents:"
      already_existing.map { |f| puts "\t#{f}" }

      # Ask the user whether he/she would like to overwrite them.
      begin
        puts "Would you like to overwrite these .haml files? (y/n)"
        should_overwrite = STDIN.gets.chomp.downcase[0]
      end until ['y', 'n'].include?(should_overwrite)
      puts '-'*80

      # If we are not overwriting, remove each already_existing from our erb_files list
      if should_overwrite == 'n'
        erb_files = erb_files - already_existing

        if erb_files.empty?
          # It is possible no .erb files remain, after we remove already_existing
          puts "No .erb files remain. Task will now exit."
          return
        end
      else
        # Delete the current .haml
        already_existing.each { |f| File.delete(f.gsub(/\.erb\z/, '.haml')) }
      end
    end

    erb_files.each do |file|
      puts "Generating HAML for #{file}..."
      `html2haml #{file} #{file.gsub(/\.erb\z/, '.haml')}`
    end

    puts '-'*80

    puts "HAML generated for the following files:"
    erb_files.each do |file|
      puts "\t#{file}"
    end

    puts '-'*80
    begin
      puts 'Would you like to delete the original .erb files? (This is not recommended unless you are under version control.) (y/n)'
      should_delete = STDIN.gets.chomp.downcase[0]
    end until ['y', 'n'].include?(should_delete)

    if should_delete == 'y'
      puts "Deleting original .erb files."
      File.delete *erb_files
    else
      puts "Please remember to delete your .erb files once you have ensured they were translated correctly."
    end

    puts '-'*80
    puts "Task complete!"
  end
end