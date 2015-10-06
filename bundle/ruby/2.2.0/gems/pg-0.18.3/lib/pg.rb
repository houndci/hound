#!/usr/bin/env ruby

begin
	require 'pg_ext'
rescue LoadError
	# If it's a Windows binary gem, try the <major>.<minor> subdirectory
	if RUBY_PLATFORM =~/(mswin|mingw)/i
		major_minor = RUBY_VERSION[ /^(\d+\.\d+)/ ] or
			raise "Oops, can't extract the major/minor version from #{RUBY_VERSION.dump}"

		# Set the PATH environment variable, so that libpq.dll can be found.
		old_path = ENV['PATH']
		ENV['PATH'] = "#{File.expand_path("../#{RUBY_PLATFORM}", __FILE__)};#{old_path}"
		require "#{major_minor}/pg_ext"
		ENV['PATH'] = old_path
	else
		raise
	end

end


# The top-level PG namespace.
module PG

	# Library version
	VERSION = '0.18.3'

	# VCS revision
	REVISION = %q$Revision: 3b49541c9f12 $

	class NotAllCopyDataRetrieved < PG::Error
	end

	### Get the PG library version. If +include_buildnum+ is +true+, include the build ID.
	def self::version_string( include_buildnum=false )
		vstring = "%s %s" % [ self.name, VERSION ]
		vstring << " (build %s)" % [ REVISION[/: ([[:xdigit:]]+)/, 1] || '0' ] if include_buildnum
		return vstring
	end


	### Convenience alias for PG::Connection.new.
	def self::connect( *args )
		return PG::Connection.new( *args )
	end


	require 'pg/exceptions'
	require 'pg/constants'
	require 'pg/coder'
	require 'pg/text_encoder'
	require 'pg/text_decoder'
	require 'pg/basic_type_mapping'
	require 'pg/type_map_by_column'
	require 'pg/connection'
	require 'pg/result'

end # module PG


# Backward-compatible aliase
PGError = PG::Error

