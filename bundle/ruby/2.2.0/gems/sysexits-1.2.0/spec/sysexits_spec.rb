#!/usr/bin/env spec -cfs -b

BEGIN {
	require 'pathname'
	basedir = Pathname( __FILE__ ).dirname.parent
	libdir = basedir + 'lib'

	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
}

require 'rspec'
require 'sysexits'

describe Sysexits do

	it "contains common exit codes as constants" do
		Sysexits::EX_OK.should == 0
		Sysexits::EX_USAGE.should == 64
	end


	it "provides an alternative 'exit' function that can take status names as Strings" do
		expect {
			Sysexits.exit( :usage )
		}.to raise_exception( SystemExit, 'exit' ) do |exc|
			exc.status.should == Sysexits::EX_USAGE
		end
	end

	it "provides an alternative 'exit' function that can take status names as Symbols" do
		expect {
			Sysexits.exit( 'permission_denied' )
		}.to raise_exception( SystemExit, 'exit' ) do |exc|
			exc.status.should == Sysexits::EX_NOPERM
		end
	end

	it "defaults to exiting with a successful status, just like the Kernel version" do
		expect {
			Sysexits.exit( :usage )
		}.to raise_exception( SystemExit, 'exit' ) do |exc|
			exc.status.should == Sysexits::EX_OK
		end
	end


	it "overrides Kernel.exit without patching any monkeys. I mean freedoms. Or something." do
		monkey = Class.new do
			include Sysexits

			def eek_eek
				exit :usage
			end
		end
		expect {
			monkey.new.eek_eek
		}.to raise_exception( SystemExit, 'exit' ) do |exc|
			exc.status.should == Sysexits::EX_USAGE
		end
	end

end
