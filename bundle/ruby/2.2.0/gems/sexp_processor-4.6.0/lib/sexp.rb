$TESTING ||= false # unless defined $TESTING

##
# Sexps are the basic storage mechanism of SexpProcessor.  Sexps have
# a +type+ (to be renamed +node_type+) which is the first element of
# the Sexp. The type is used by SexpProcessor to determine whom to
# dispatch the Sexp to for processing.

class Sexp < Array # ZenTest FULL

  attr_writer :line
  attr_accessor :file, :comments

  @@array_types = [ :array, :args, ]

  ##
  # Create a new Sexp containing +args+.

  def initialize(*args)
    super(args)
  end

  ##
  # Creates a new Sexp from Array +a+.

  def self.from_array(a)
    ary = Array === a ? a : [a]

    result = self.new

    ary.each do |x|
      case x
      when Sexp
        result << x
      when Array
        result << self.from_array(x)
      else
        result << x
      end
    end

    result
  end

  def ==(obj) # :nodoc:
    obj.class == self.class and super
  end

  ##
  # Returns true if this Sexp's pattern matches +sexp+.

  def ===(sexp)
    return nil unless Sexp === sexp
    pattern = self # this is just for my brain

    return true if pattern == sexp

    sexp.each do |subset|
      return true if pattern === subset
    end

    return nil
  end

  ##
  # Returns true if this Sexp matches +pattern+.  (Opposite of #===.)

  def =~(pattern)
    return pattern === self
  end

  ##
  # Returns true if the node_type is +array+ or +args+.
  #
  # REFACTOR: to TypedSexp - we only care when we have units.

  def array_type?
    type = self.first
    @@array_types.include? type
  end

  def compact # :nodoc:
    self.delete_if { |o| o.nil? }
  end

  ##
  # Recursively enumerates the sexp yielding to +block+ for every element.
  # TODO: test

  def deep_each(&block)
    self.each_sexp do |sexp|
      block[sexp]
      sexp.deep_each(&block)
    end
  end

  ##
  # Enumeratates the sexp yielding to +b+ when the node_type == +t+.

  def each_of_type(t, &b)
    each do | elem |
      if Sexp === elem then
        elem.each_of_type(t, &b)
        b.call(elem) if elem.first == t
      end
    end
  end

  ##
  # Recursively enumerates all sub-sexps skipping non-Sexp elements.
  # TODO: test

  def each_sexp
    self.each do |sexp|
      next unless Sexp === sexp

      yield sexp
    end
  end

  ##
  # Replaces all elements whose node_type is +from+ with +to+. Used
  # only for the most trivial of rewrites.

  def find_and_replace_all(from, to)
    each_with_index do | elem, index |
      if Sexp === elem then
        elem.find_and_replace_all(from, to)
      else
        self[index] = to if elem == from
      end
    end
  end

  ##
  # Replaces all Sexps matching +pattern+ with Sexp +repl+.

  def gsub(pattern, repl)
    return repl if pattern == self

    new = self.map do |subset|
      case subset
      when Sexp then
        subset.gsub(pattern, repl)
      else
        subset
      end
    end

    return Sexp.from_array(new)
  end

  def inspect # :nodoc:
    sexp_str = self.map {|x|x.inspect}.join(', ')
    if ENV['VERBOSE'] && line then
      "s(#{sexp_str}).line(#{line})"
    else
      "s(#{sexp_str})"
    end
  end

  def find_node name, delete = false
    matches = find_nodes name

    case matches.size
    when 0 then
      nil
    when 1 then
      match = matches.first
      delete match if delete
      match
    else
      raise NoMethodError, "multiple nodes for #{name} were found in #{inspect}"
    end
  end

  ##
  # Find every node with type +name+.

  def find_nodes name
    find_all { | sexp | Sexp === sexp and sexp.first == name }
  end

  ##
  # If passed a line number, sets the line and returns self. Otherwise
  # returns the line number. This allows you to do message cascades
  # and still get the sexp back.

  def line(n=nil)
    if n then
      @line = n
      self
    else
      @line ||= nil
    end
  end

  ##
  # Returns the size of the sexp, flattened.

  def mass
    @mass ||= self.structure.flatten.size
  end

  ##
  # Returns the node named +node+, deleting it if +delete+ is true.

  def method_missing meth, delete = false
    find_node meth, delete
  end

  def respond_to? msg, private = false # :nodoc:
    # why do I need this? Because ruby 2.0 is broken. That's why.
    super
  end

  def pretty_print(q) # :nodoc:
    nnd = ')'
    nnd << ".line(#{line})" if line && ENV['VERBOSE']

    q.group(1, 's(', nnd) do
      q.seplist(self) {|v| q.pp v }
    end
  end

  ##
  # Returns the node type of the Sexp.

  def sexp_type
    first
  end

  ##
  # Returns the Sexp body, ie the values without the node type.

  def sexp_body
    self[1..-1]
  end

  alias :head :sexp_type
  alias :rest :sexp_body

  ##
  # If run with debug, Sexp will raise if you shift on an empty
  # Sexp. Helps with debugging.

  def shift
    raise "I'm empty" if self.empty?
    super
  end if ($DEBUG or $TESTING) unless (defined?(RUBY_ENGINE) and RUBY_ENGINE == "maglev")

  ##
  # Returns the bare bones structure of the sexp.
  # s(:a, :b, s(:c, :d), :e) => s(:a, s(:c))

  def structure
    if Array === self.first then
      s(:bogus, *self).structure # TODO: remove >= 4.2.0
    else
      result = s(self.first)
      self.each do |subexp|
        result << subexp.structure if Sexp === subexp
      end
      result
    end
  end

  ##
  # Replaces the Sexp matching +pattern+ with +repl+.

  def sub(pattern, repl)
    return repl.dup if pattern == self

    done = false

    new = self.map do |subset|
      if done then
        subset
      else
        case subset
        when Sexp then
          if pattern == subset then
            done = true
            repl.dup
          elsif pattern === subset then
            done = true
            subset.sub pattern, repl
          else
            subset
          end
        else
          subset
        end
      end
    end

    return Sexp.from_array(new)
  end

  def to_a # :nodoc:
    self.map { |o| Sexp === o ? o.to_a : o }
  end

  def to_s # :nodoc:
    inspect
  end
end

class SexpMatchSpecial < Sexp; end

class SexpAny < SexpMatchSpecial
  def ==(o)
    Sexp === o
  end

  def ===(o)
    return Sexp === o
  end

  def inspect
    "ANY"
  end
end

module SexpMatchSpecials
  def ANY(); return SexpAny.new; end
end

##
# This is a very important shortcut to make using Sexps much more awesome.

def s(*args)
  Sexp.new(*args)
end
