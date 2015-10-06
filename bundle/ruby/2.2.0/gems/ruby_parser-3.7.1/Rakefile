# -*- ruby -*-

$:.unshift "../../hoe/dev/lib"

require "rubygems"
require "hoe"

Hoe.plugin :seattlerb
Hoe.plugin :racc
Hoe.plugin :isolate

Hoe.add_include_dirs "../../sexp_processor/dev/lib"
Hoe.add_include_dirs "../../minitest/dev/lib"
Hoe.add_include_dirs "../../oedipus_lex/dev/lib"

Hoe.spec "ruby_parser" do
  developer "Ryan Davis", "ryand-ruby@zenspider.com"

  license "MIT"

  dependency "sexp_processor", "~> 4.1"
  dependency "rake", "< 11", :developer
  dependency "oedipus_lex", "~> 2.1", :developer

  if plugin? :perforce then     # generated files
    self.perforce_ignore << "lib/ruby18_parser.rb"
    self.perforce_ignore << "lib/ruby19_parser.rb"
    self.perforce_ignore << "lib/ruby20_parser.rb"
    self.perforce_ignore << "lib/ruby20_parser.y"
    self.perforce_ignore << "lib/ruby21_parser.rb"
    self.perforce_ignore << "lib/ruby21_parser.y"
    self.perforce_ignore << "lib/ruby22_parser.rb"
    self.perforce_ignore << "lib/ruby22_parser.y"
    self.perforce_ignore << "lib/ruby_lexer.rex.rb"
  end

  self.racc_flags << " -t" if plugin?(:racc) && ENV["DEBUG"]
end

file "lib/ruby20_parser.y" => "lib/ruby_parser.yy" do |t|
  sh "unifdef -tk -DRUBY20 -URUBY21 -URUBY22 -UDEAD #{t.source} > #{t.name} || true"
end

file "lib/ruby21_parser.y" => "lib/ruby_parser.yy" do |t|
  sh "unifdef -tk -URUBY20 -DRUBY21 -URUBY22 -UDEAD #{t.source} > #{t.name} || true"
end

file "lib/ruby22_parser.y" => "lib/ruby_parser.yy" do |t|
  sh "unifdef -tk -URUBY20 -URUBY21 -DRUBY22 -UDEAD #{t.source} > #{t.name} || true"
end

file "lib/ruby18_parser.rb" => "lib/ruby18_parser.y"
file "lib/ruby19_parser.rb" => "lib/ruby19_parser.y"
file "lib/ruby20_parser.rb" => "lib/ruby20_parser.y"
file "lib/ruby21_parser.rb" => "lib/ruby21_parser.y"
file "lib/ruby22_parser.rb" => "lib/ruby22_parser.y"
file "lib/ruby_lexer.rex.rb" => "lib/ruby_lexer.rex"

task :clean do
  rm_rf(Dir["**/*~"] +
        Dir["diff.diff"] + # not all diffs. bit me too many times
        Dir["coverage.info"] +
        Dir["coverage"] +
        Dir["lib/ruby2*_parser.y"] +
        Dir["lib/*.output"])
end

task :sort do
  sh "grepsort '^ +def' lib/ruby_lexer.rb"
  sh "grepsort '^ +def (test|util)' test/test_ruby_lexer.rb"
end

desc "what was that command again?"
task :huh? do
  puts "ruby #{Hoe::RUBY_FLAGS} bin/ruby_parse -q -g ..."
end

task :irb => [:isolate] do
  sh "GEM_HOME=#{Gem.path.first} irb -rubygems -Ilib -rruby_parser;"
end

def (task(:phony)).timestamp
  Time.at 0
end

task :isolate => :phony

# to create parseXX.output:
#
# 1) check out the XX version of ruby
# 2) Edit uncommon.mk, find the ".y.c" rule and remove the RM lines
# 3) run `rm -f parse.c; make parse.c`
# 4) run `bison -r all parse.tmp.y`
# 5) mv parse.tmp.output parseXX.output

# possibly new instructions:
#
# 1) check out the XX version of ruby
# 2) YFLAGS="-r all" make parse.c
# 3) mv y.output parseXX.output

%w[18 19 20 21 22].each do |v|
  task "compare#{v}" do
    sh "./yack.rb lib/ruby#{v}_parser.output > racc#{v}.txt"
    sh "./yack.rb parse#{v}.output > yacc#{v}.txt"
    sh "diff -du racc#{v}.txt yacc#{v}.txt || true"
    puts
    sh "diff -du racc#{v}.txt yacc#{v}.txt | wc -l"
  end
end

task :debug => :isolate do
  ENV["V"] ||= "22"
  Rake.application[:parser].invoke # this way we can have DEBUG set
  Rake.application[:lexer].invoke # this way we can have DEBUG set

  $: << "lib"
  require "ruby_parser"
  require "pp"

  parser = case ENV["V"]
           when "18" then
             Ruby18Parser.new
           when "19" then
             Ruby19Parser.new
           when "20" then
             Ruby20Parser.new
           when "21" then
             Ruby21Parser.new
           when "22" then
             Ruby22Parser.new
           else
             raise "Unsupported version #{ENV["V"]}"
           end

  time = (ENV["RP_TIMEOUT"] || 10).to_i

  n = ENV["BUG"]
  file = (n && "bug#{n}.rb") || ENV["F"] || ENV["FILE"]

  ruby = if file then
           File.read(file)
         else
           file = "env"
           ENV["R"] || ENV["RUBY"]
         end

  begin
    pp parser.process(ruby, file, time)
  rescue Racc::ParseError => e
    p e
    ss = parser.lexer.ss
    src = ss.string
    lines = src[0..ss.pos].split(/\n/)
    abort "on #{file}:#{lines.size}"
  end
end

task :debug_ruby do
  file = ENV["F"] || ENV["FILE"]
  sh "/Users/ryan/Desktop/DVDs/debugparser/miniruby -cwy #{file} 2>&1 | ./yuck.rb"
end

task :extract => :isolate do
  ENV["V"] ||= "19"
  Rake.application[:parser].invoke # this way we can have DEBUG set

  file = ENV["F"] || ENV["FILE"]

  ruby "-Ilib", "bin/ruby_parse_extract_error", file
end

task :bugs do
  sh "for f in bug*.rb ; do #{Gem.ruby} -S rake debug F=$f && rm $f ; done"
end

# vim: syntax=Ruby
