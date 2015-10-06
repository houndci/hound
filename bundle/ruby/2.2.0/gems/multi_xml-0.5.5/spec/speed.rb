#!/usr/bin/env ruby -wW1

$: << '.'
$: << '../lib'

if __FILE__ == $0
  while (i = ARGV.index('-I'))
    x,path = ARGV.slice!(i, 2)
    $: << path
  end
end

require 'optparse'
require 'stringio'
require 'multi_xml'

begin
  require 'libxml'
rescue Exception => e
end
begin
  require 'nokogiri'
rescue Exception => e
end
begin
  require 'ox'
rescue Exception => e
end

$verbose = 0
$parsers = []
$iter = 10

opts = OptionParser.new
opts.on("-v", "increase verbosity")                            { $verbose += 1 }
opts.on("-p", "--parser [String]", String, "parser to test")   { |p| $parsers = [p] }
opts.on("-i", "--iterations [Int]", Integer, "iterations")     { |i| $iter = i }
opts.on("-h", "--help", "Show this display")                   { puts opts; Process.exit!(0) }
files = opts.parse(ARGV)

if $parsers.empty?
  $parsers << 'libxml' if defined?(::LibXML)
  $parsers << 'nokogiri' if defined?(::Nokogiri)
  $parsers << 'ox' if defined?(::Ox)
end

files.each do |filename|
  times = { }
  xml = File.read(filename)
  $parsers.each do |p|
    MultiXml.parser = p
    start = Time.now
    $iter.times do |i|
      io = StringIO.new(xml)
      MultiXml.parse(io)
    end
    dt = Time.now - start
    times[p] = Time.now - start
  end
  times.each do |p,t|
    puts "%8s took %0.3f seconds to parse %s %d times." % [p, t, filename, $iter]
  end
end
