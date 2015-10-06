require "rspec/core/rake_task"

namespace :spec do
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.pattern = FileList['spec/**/*_spec.rb']
    t.rspec_opts = ['--color', '--format', 'documentation']
  end

  RSpec::Core::RakeTask.new(:normal) do |t|
    t.pattern = FileList['spec/**/*_spec.rb'].exclude(/compat/)
    t.rspec_opts = ['--color', '--format', 'documentation']
  end

  RSpec::Core::RakeTask.new(:all) do |t|
    t.pattern = FileList['spec/**/*_spec.rb']
    t.rspec_opts = ['--color', '--format', 'documentation']
  end

  desc "Generate HTML Specdocs for all specs"
  RSpec::Core::RakeTask.new(:specdoc) do |t|
    specdoc_path = File.expand_path(
      File.join(File.dirname(__FILE__), '..', 'documentation')
    )
    Dir.mkdir(specdoc_path) if !File.exist?(specdoc_path)

    output_file = File.join(specdoc_path, 'index.html')
    t.pattern = FileList['spec/**/*_spec.rb']
    t.fail_on_error = false
  end

  namespace :rcov do
    desc "Browse the code coverage report."
    task :browse => "spec:rcov" do
      require "launchy"
      Launchy.open("coverage/index.html")
    end
  end
end

desc "Alias to spec:normal"
task "spec" => "spec:normal"

task "clobber" => ["spec:clobber_rcov"]
