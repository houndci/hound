#!/usr/bin/env ruby

require 'pg' unless defined?( PG )


class PG::Result

	# Apply a type map for all value retrieving methods.
	#
	# +type_map+: a PG::TypeMap instance.
	#
	# See PG::BasicTypeMapForResults
	def map_types!(type_map)
		self.type_map = type_map
		self
	end

	def inspect
		str = self.to_s
		str[-1,0] = " status=#{res_status(result_status)} ntuples=#{ntuples} nfields=#{nfields} cmd_tuples=#{cmd_tuples}"
		str
	end
end # class PG::Result

# Backward-compatible alias
PGresult = PG::Result
