#!/usr/bin/env rake

require 'rbconfig'
require 'pathname'
require 'tmpdir'

begin
	require 'rake/extensiontask'
rescue LoadError
	abort "This Rakefile requires rake-compiler (gem install rake-compiler)"
end

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

require 'rake/clean'

# Build directory constants
BASEDIR = Pathname( __FILE__ ).dirname
SPECDIR = BASEDIR + 'spec'
LIBDIR  = BASEDIR + 'lib'
EXTDIR  = BASEDIR + 'ext'
PKGDIR  = BASEDIR + 'pkg'
TMPDIR  = BASEDIR + 'tmp'

DLEXT   = RbConfig::CONFIG['DLEXT']
EXT     = LIBDIR + "pg_ext.#{DLEXT}"

GEMSPEC = 'pg.gemspec'

TEST_DIRECTORY = BASEDIR + "tmp_test_specs"

CLOBBER.include( TEST_DIRECTORY.to_s )
CLEAN.include( PKGDIR.to_s, TMPDIR.to_s )

# Set up Hoe plugins
Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :deveiate
Hoe.plugin :bundler

Hoe.plugins.delete :rubyforge
Hoe.plugins.delete :compiler

load 'Rakefile.cross'


# Hoe specification
$hoespec = Hoe.spec 'pg' do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.extra_rdoc_files = Rake::FileList[ '*.rdoc' ]
	self.extra_rdoc_files.include( 'POSTGRES', 'LICENSE' )
	self.extra_rdoc_files.include( 'ext/*.c' )
	self.license :BSD

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'
	self.developer 'Lars Kanis', 'lars@greiz-reinsdorf.de'

	self.dependency 'rake-compiler', '~> 0.9', :developer
	self.dependency 'rake-compiler-dock', '~> 0.3', :developer
	self.dependency 'hoe', '~> 3.12', :developer
	self.dependency 'hoe-deveiate', '~> 0.6', :developer
	self.dependency 'hoe-bundler', '~> 1.0', :developer
	self.dependency 'rspec', '~> 3.0', :developer

	self.spec_extras[:licenses] = ['BSD', 'Ruby', 'GPL']
	self.spec_extras[:extensions] = [ 'ext/extconf.rb' ]

	self.require_ruby_version( '>= 1.9.3' )

	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags= )
	self.check_history_on_release = true if self.respond_to?( :check_history_on_release= )
	self.spec_extras[:rdoc_options] = [
		'-f', 'fivefish',
		'-t', 'pg: The Ruby Interface to PostgreSQL',
		'-m', 'README.rdoc',
	]

	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= $hoespec.spec.version.to_s

# Tests should pass before checking in
task 'hg:precheckin' => [ :check_history, :check_manifest, :spec ]

# Support for 'rvm specs'
task :specs => :spec

# Compile before testing
task :spec => :compile

# gem-testers support
task :test do
	# rake-compiler always wants to copy the compiled extension into lib/, but
	# we don't want testers to have to re-compile, especially since that
	# often fails because they can't (and shouldn't have to) write to tmp/ in
	# the installed gem dir. So we clear the task rake-compiler set up
	# to break the dependency between :spec and :compile when running under
	# rubygems-test, and then run :spec.
	Rake::Task[ EXT.to_s ].clear
	Rake::Task[ :spec ].execute
end

desc "Turn on warnings and debugging in the build."
task :maint do
	ENV['MAINTAINER_MODE'] = 'yes'
end

ENV['RUBY_CC_VERSION'] ||= '1.8.7:1.9.2:2.0.0'

# Rake-compiler task
Rake::ExtensionTask.new do |ext|
	ext.name           = 'pg_ext'
	ext.gem_spec       = $hoespec.spec
	ext.ext_dir        = 'ext'
	ext.lib_dir        = 'lib'
	ext.source_pattern = "*.{c,h}"
	ext.cross_compile  = true
	ext.cross_platform = CrossLibraries.map &:for_platform

	ext.cross_config_options += CrossLibraries.map do |lib|
		{
			lib.for_platform => [
				"--enable-windows-cross",
				"--with-pg-include=#{lib.static_postgresql_incdir}",
				"--with-pg-lib=#{lib.static_postgresql_libdir}",
				# libpq-fe.h resides in src/interfaces/libpq/ before make install
				"--with-opt-include=#{lib.static_postgresql_libdir}",
			]
		}
	end

	# Add libpq.dll to windows binary gemspec
	ext.cross_compiling do |spec|
		# mingw32-platform strings differ (RUBY_PLATFORM=i386-mingw32 vs. x86-mingw32 for rubygems)
		spec.files << "lib/#{spec.platform.to_s.gsub(/^x86-/, "i386-")}/libpq.dll"
	end
end


# Make the ChangeLog update if the repo has changed since it was last built
file '.hg/branch' do
	warn "WARNING: You need the Mercurial repo to update the ChangeLog"
end
file 'ChangeLog' do |task|
	if File.exist?('.hg/branch')
		$stderr.puts "Updating the changelog..."
		begin
			include Hoe::MercurialHelpers
			content = make_changelog()
		rescue NameError
			abort "Packaging tasks require the hoe-mercurial plugin (gem install hoe-mercurial)"
		end
		File.open( task.name, 'w', 0644 ) do |fh|
			fh.print( content )
		end
	else
		touch 'ChangeLog'
	end
end

# Rebuild the ChangeLog immediately before release
task :prerelease => 'ChangeLog'


desc "Stop any Postmaster instances that remain after testing."
task :cleanup_testing_dbs do
    require 'spec/lib/helpers'
    PgTestingHelpers.stop_existing_postmasters()
    Rake::Task[:clean].invoke
end

desc "Update list of server error codes"
task :update_error_codes do
	URL_ERRORCODES_TXT = "http://git.postgresql.org/gitweb/?p=postgresql.git;a=blob_plain;f=src/backend/utils/errcodes.txt;hb=HEAD"

	ERRORCODES_TXT = "ext/errorcodes.txt"
	sh "wget #{URL_ERRORCODES_TXT.inspect} -O #{ERRORCODES_TXT.inspect} || curl #{URL_ERRORCODES_TXT.inspect} -o #{ERRORCODES_TXT.inspect}"
end

file 'ext/errorcodes.def' => ['ext/errorcodes.rb', 'ext/errorcodes.txt'] do
	ruby 'ext/errorcodes.rb', 'ext/errorcodes.txt', 'ext/errorcodes.def'
end

file 'ext/pg_errors.c' => ['ext/errorcodes.def'] do
	# trigger compilation of changed errorcodes.def
	touch 'ext/pg_errors.c'
end

task :gemspec => GEMSPEC
file GEMSPEC => __FILE__
task GEMSPEC do |task|
	spec = $hoespec.spec
	spec.files.delete( '.gemtest' )
	spec.version = "#{spec.version}.pre#{Time.now.strftime("%Y%m%d%H%M%S")}"
	File.open( task.name, 'w' ) do |fh|
		fh.write( spec.to_ruby )
	end
end

CLOBBER.include( GEMSPEC.to_s )
task :default => :gemspec

