# encoding: US-ASCII

require 'rubygems'
require 'minitest/autorun'
require 'ruby_lexer'
require 'ruby18_parser'
require 'ruby20_parser'

class TestRubyLexer < Minitest::Test
  attr_accessor :processor, :lex, :parser_class, :lex_state

  alias :lexer :lex # lets me copy/paste code from parser
  alias :lexer= :lex=

  def setup
    self.lex_state = :expr_beg
    setup_lexer_class Ruby20Parser
  end

  def setup_lexer input, exp_sexp = nil
    setup_new_parser
    lex.ss = RPStringScanner.new(input)
    lex.lex_state = self.lex_state
  end

  def setup_new_parser
    self.processor = parser_class.new
    self.lex = processor.lexer
  end

  def setup_lexer_class parser_class
    self.parser_class = parser_class
    setup_new_parser
    setup_lexer "blah blah"
  end

  def assert_lex input, exp_sexp, *args, &b
    setup_lexer input
    assert_parse input, exp_sexp if exp_sexp

    b.call if b

    args.each_slice(5) do |token, value, state, paren, brace|
      assert_next_lexeme token, value, state, paren, brace
    end

    refute_lexeme
  end

  def assert_lex3 input, exp_sexp, *args, &block
    args = args.each_slice(3).map { |a, b, c| [a, b, c, nil, nil] }.flatten

    assert_lex(input, exp_sexp, *args, &block)
  end

  def refute_lex input, *args # TODO: re-sort
    args = args.each_slice(2).map { |a, b| [a, b, nil, nil, nil] }.flatten

    assert_raises RubyParser::SyntaxError do
      assert_lex(input, nil, *args)
    end
  end

  def assert_lex_fname name, type, end_state = :expr_arg # TODO: swap name/type
    assert_lex3("def #{name} ",
                nil,

                :kDEF, "def", :expr_fname,
                type,  name,  end_state)
  end

  def assert_next_lexeme token=nil, value=nil, state=nil, paren=nil, brace=nil
    adv = @lex.next_token

    assert adv, "no more tokens"

    act_token, act_value = adv

    msg = message {
      act = [act_token, act_value, @lex.lex_state,
             @lex.paren_nest, @lex.brace_nest]
      exp = [token, value, state, paren, brace]
      "#{exp.inspect} vs #{act.inspect}"
    }

    act_value = act_value.first if Array === act_value

    assert_equal token, act_token,       msg
    assert_equal value, act_value,       msg
    assert_equal state, @lex.lex_state,  msg if state
    assert_equal paren, @lex.paren_nest, msg if paren
    assert_equal brace, @lex.brace_nest, msg if brace
  end

  def assert_parse input, exp_sexp
    assert_equal exp_sexp, processor.class.new.parse(input)
  end

  def assert_read_escape expected, input
    @lex.ss.string = input
    assert_equal expected, @lex.read_escape, input
  end

  def assert_read_escape_bad input # TODO: rename refute_read_escape
    @lex.ss.string = input
    assert_raises RubyParser::SyntaxError do
      @lex.read_escape
    end
  end

  def refute_lexeme
    x = y = @lex.next_token

    refute x, "not empty: #{y.inspect}"
  end

  ## Utility Methods:

  def emulate_string_interpolation
    lex_strterm = lexer.lex_strterm
    string_nest = lexer.string_nest
    brace_nest  = lexer.brace_nest

    lexer.string_nest = 0
    lexer.brace_nest  = 0
    lexer.cond.push false
    lexer.cmdarg.push false

    lexer.lex_strterm = nil
    lexer.lex_state = :expr_beg

    yield

    lexer.lex_state = :expr_endarg
    assert_next_lexeme :tRCURLY,     "}",  :expr_endarg, 0

    lexer.lex_strterm = lex_strterm
    lexer.lex_state   = :expr_beg
    lexer.string_nest = string_nest
    lexer.brace_nest  = brace_nest

    lexer.cond.lexpop
    lexer.cmdarg.lexpop
  end

  ## Tests:

  def test_next_token
    assert_equal [:tIDENTIFIER, "blah"], @lex.next_token
    assert_equal [:tIDENTIFIER, "blah"], @lex.next_token
    assert_nil @lex.next_token
  end

  def test_unicode_ident
    s = "@\u1088\u1077\u1093\u1072"
    assert_lex3(s.dup, nil, :tIVAR, s.dup, :expr_end)
  end

  def test_read_escape
    assert_read_escape "\\",   "\\"
    assert_read_escape "\n",   "n"
    assert_read_escape "\t",   "t"
    assert_read_escape "\r",   "r"
    assert_read_escape "\f",   "f"
    assert_read_escape "\13",  "v"
    assert_read_escape "\0",   "0"
    assert_read_escape "\07",  "a"
    assert_read_escape "\007", "a"
    assert_read_escape "\033", "e"
    assert_read_escape "\377", "377"
    assert_read_escape "\377", "xff"
    assert_read_escape "\010", "b"
    assert_read_escape " ",    "s"
    assert_read_escape "q",    "q" # plain vanilla escape

    assert_read_escape "8", "8" # ugh... mri... WHY?!?
    assert_read_escape "9", "9" # ugh... mri... WHY?!?

    assert_read_escape "$",    "444" # ugh
  end

  def test_read_escape_c
    assert_read_escape "\030", "C-x"
    assert_read_escape "\030", "cx"
    assert_read_escape "\230", 'C-\M-x'
    assert_read_escape "\230", 'c\M-x'

    assert_read_escape "\177", "C-?"
    assert_read_escape "\177", "c?"
  end

  def test_read_escape_errors
    assert_read_escape_bad ""

    assert_read_escape_bad "M"
    assert_read_escape_bad "M-"
    assert_read_escape_bad "Mx"

    assert_read_escape_bad "Cx"
    assert_read_escape_bad "C"
    assert_read_escape_bad "C-"

    assert_read_escape_bad "c"
  end

  def test_read_escape_m
    assert_read_escape "\370", "M-x"
    assert_read_escape "\230", 'M-\C-x'
    assert_read_escape "\230", 'M-\cx'
  end

  def test_yylex_ambiguous_uminus
    assert_lex3("m -3",
                nil,
                :tIDENTIFIER, "m", :expr_cmdarg,
                :tUMINUS_NUM, "-", :expr_beg,
                :tINTEGER,    3,   :expr_end)

    # TODO: verify warning
  end

  def test_yylex_ambiguous_uplus
    assert_lex3("m +3",
                nil,
                :tIDENTIFIER, "m", :expr_cmdarg,
                :tINTEGER,    3,   :expr_end)

    # TODO: verify warning
  end

  def test_yylex_and
    assert_lex3("&", nil, :tAMPER, "&", :expr_beg)
  end

  def test_yylex_and2
    assert_lex3("&&", nil, :tANDOP, "&&", :expr_beg)
  end

  def test_yylex_and2_equals
    assert_lex3("&&=", nil, :tOP_ASGN, "&&", :expr_beg)
  end

  def test_yylex_and_arg
    self.lex_state = :expr_arg

    assert_lex3(" &y",
                nil,
                :tAMPER,      "&", :expr_beg,
                :tIDENTIFIER, "y", :expr_arg)
  end

  def test_yylex_and_equals
    assert_lex3("&=", nil, :tOP_ASGN, "&", :expr_beg)
  end

  def test_yylex_and_expr
    self.lex_state = :expr_arg

    assert_lex3("x & y",
                nil,
                :tIDENTIFIER, "x", :expr_cmdarg,
                :tAMPER2,     "&", :expr_beg,
                :tIDENTIFIER, "y", :expr_arg)
  end

  def test_yylex_and_meth
    assert_lex_fname "&", :tAMPER2
  end

  def test_yylex_assoc
    assert_lex3("=>", nil, :tASSOC, "=>", :expr_beg)
  end

  def test_yylex_label__18
    setup_lexer_class Ruby18Parser

    assert_lex3("{a:",
                nil,
                :tLBRACE,     "{", :expr_beg,
                :tIDENTIFIER, "a", :expr_arg,
                :tSYMBEG,     ":", :expr_fname)
  end

  def test_yylex_label_in_params__18
    setup_lexer_class Ruby18Parser

    assert_lex3("foo(a:",
                nil,
                :tIDENTIFIER, "foo", :expr_cmdarg,
                :tLPAREN2,    "(",   :expr_beg,
                :tIDENTIFIER, "a",   :expr_cmdarg,
                :tSYMBEG,     ":",   :expr_fname)
  end

  def test_yylex_label__19
    setup_lexer_class Ruby19Parser

    assert_lex3("{a:",
                nil,
                :tLBRACE, "{", :expr_beg,
                :tLABEL,  "a", :expr_labelarg)
  end

  def test_yylex_label_in_params__19
    setup_lexer_class Ruby19Parser

    assert_lex3("foo(a:",
                nil,
                :tIDENTIFIER, "foo", :expr_cmdarg,
                :tLPAREN2,    "(",   :expr_beg,
                :tLABEL,      "a",   :expr_labelarg)
  end

  def test_yylex_paren_string_parens_interpolated
    setup_lexer('%((#{b}#{d}))',
                s(:dstr,
                  "(",
                  s(:evstr, s(:call, nil, :b)),
                  s(:evstr, s(:call, nil, :d)),
                  s(:str, ")")))

    assert_next_lexeme :tSTRING_BEG,     "%)", :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_CONTENT, "(",  :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_DBEG,    nil,  :expr_beg, 0, 0

    emulate_string_interpolation do
      assert_next_lexeme :tIDENTIFIER,   "b",  :expr_arg, 0, 0
    end

    assert_next_lexeme :tSTRING_DBEG,    nil,  :expr_beg, 0, 0

    emulate_string_interpolation do
      assert_next_lexeme :tIDENTIFIER,   "d",  :expr_arg, 0, 0
    end

    assert_next_lexeme :tSTRING_CONTENT, ")",  :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_END,     ")",  :expr_end, 0, 0

    refute_lexeme
  end

  def test_yylex_paren_string_interpolated_regexp
    setup_lexer('%( #{(/abcd/)} )',
                s(:dstr, " ", s(:evstr, s(:lit, /abcd/)), s(:str, " ")))

    assert_next_lexeme :tSTRING_BEG,       "%)",   :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_CONTENT,   " ",    :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_DBEG,      nil,    :expr_beg, 0, 0

    emulate_string_interpolation do
      assert_next_lexeme :tLPAREN,         "(",    :expr_beg, 1, 0
      assert_next_lexeme :tREGEXP_BEG,     "/",    :expr_beg, 1, 0
      assert_next_lexeme :tSTRING_CONTENT, "abcd", :expr_beg, 1, 0
      assert_next_lexeme :tREGEXP_END,     "",     :expr_end, 1, 0
      assert_next_lexeme :tRPAREN,         ")",    :expr_endfn, 0, 0
    end

    assert_next_lexeme :tSTRING_CONTENT,   " ",    :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_END,       ")",    :expr_end, 0, 0

    refute_lexeme
  end

  def test_yylex_not_at_defn
    assert_lex("def +@; end",
               s(:defn, :+@, s(:args), s(:nil)),

               :kDEF,   "def", :expr_fname, 0, 0,
               :tUPLUS, "+@",  :expr_arg,   0, 0,
               :tSEMI,  ";",   :expr_beg,   0, 0,
               :kEND,   "end", :expr_end,   0, 0)

    assert_lex("def !@; end",
               s(:defn, :"!@", s(:args), s(:nil)),

               :kDEF,   "def", :expr_fname, 0, 0,
               :tUBANG, "!@",  :expr_arg,   0, 0,
               :tSEMI,  ";",   :expr_beg,   0, 0,
               :kEND,   "end", :expr_end,   0, 0)
  end

  def test_yylex_not_at_ivar
    assert_lex("!@ivar",
               s(:call, s(:ivar, :@ivar), :"!"),

               :tBANG, "!",     :expr_beg, 0, 0,
               :tIVAR, "@ivar", :expr_end, 0, 0)
  end

  def test_yylex_number_times_ident_times_return_number
    assert_lex("1 * b * 3",
               s(:call,
                 s(:call, s(:lit, 1), :*, s(:call, nil, :b)),
                 :*, s(:lit, 3)),

               :tINTEGER,      1, :expr_end, 0, 0,
               :tSTAR2,      "*", :expr_beg, 0, 0,
               :tIDENTIFIER, "b", :expr_arg, 0, 0,
               :tSTAR2,      "*", :expr_beg, 0, 0,
               :tINTEGER,      3, :expr_end, 0, 0)

    assert_lex("1 * b *\n 3",
               s(:call,
                 s(:call, s(:lit, 1), :*, s(:call, nil, :b)),
                 :*, s(:lit, 3)),

               :tINTEGER,      1, :expr_end, 0, 0,
               :tSTAR2,      "*", :expr_beg, 0, 0,
               :tIDENTIFIER, "b", :expr_arg, 0, 0,
               :tSTAR2,      "*", :expr_beg, 0, 0,
               :tINTEGER,      3, :expr_end, 0, 0)
  end

  def test_yylex_paren_string_parens_interpolated_regexp
    setup_lexer('%((#{(/abcd/)}))',
                s(:dstr, "(", s(:evstr, s(:lit, /abcd/)), s(:str, ")")))

    assert_next_lexeme :tSTRING_BEG,       "%)",   :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_CONTENT,   "(",    :expr_beg, 0, 0

    assert_next_lexeme :tSTRING_DBEG,       nil,   :expr_beg, 0, 0

    emulate_string_interpolation do
      assert_next_lexeme :tLPAREN,         "(",    :expr_beg, 1, 0
      assert_next_lexeme :tREGEXP_BEG,     "/",    :expr_beg, 1, 0
      assert_next_lexeme :tSTRING_CONTENT, "abcd", :expr_beg, 1, 0
      assert_next_lexeme :tREGEXP_END,     "",     :expr_end, 1, 0
      assert_next_lexeme :tRPAREN,         ")",    :expr_endfn, 0, 0
    end

    assert_next_lexeme :tSTRING_CONTENT,   ")",    :expr_beg, 0, 0
    assert_next_lexeme :tSTRING_END,       ")",    :expr_end, 0, 0

    refute_lexeme
  end

  def test_yylex_method_parens_chevron
    assert_lex("a()<<1",
               s(:call, s(:call, nil, :a), :<<, s(:lit, 1)),
               :tIDENTIFIER, "a",   :expr_cmdarg, 0, 0,
               :tLPAREN2,    "(",   :expr_beg,    1, 0,
               :tRPAREN,     ")",   :expr_endfn,  0, 0,
               :tLSHFT,      "<<" , :expr_beg,    0, 0,
               :tINTEGER,    1,     :expr_end,    0, 0)
  end

  def test_yylex_lambda_args__20
    setup_lexer_class Ruby20Parser

    assert_lex("-> (a) { }",
               s(:iter, s(:call, nil, :lambda),
                 s(:args, :a)),

               :tLAMBDA,     nil, :expr_endfn,  0, 0,
               :tLPAREN2,    "(", :expr_beg,    1, 0,
               :tIDENTIFIER, "a", :expr_arg,    1, 0,
               :tRPAREN,     ")", :expr_endfn,  0, 0,
               :tLCURLY,     "{", :expr_beg,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0)
  end

  def test_yylex_lambda_args_opt__20
    setup_lexer_class Ruby20Parser

    assert_lex("-> (a=nil) { }",
               s(:iter, s(:call, nil, :lambda),
                 s(:args, s(:lasgn, :a, s(:nil)))),

               :tLAMBDA,     nil, :expr_endfn,  0, 0,
               :tLPAREN2,    "(", :expr_beg,    1, 0,
               :tIDENTIFIER, "a", :expr_arg,    1, 0,
               :tEQL,        "=", :expr_beg,    1, 0,
               :kNIL,        "nil", :expr_end,    1, 0,
               :tRPAREN,     ")", :expr_endfn,  0, 0,
               :tLCURLY,     "{", :expr_beg,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0)
  end

  def test_yylex_lambda_hash__20
    setup_lexer_class Ruby20Parser

    assert_lex("-> (a={}) { }",
               s(:iter, s(:call, nil, :lambda),
                 s(:args, s(:lasgn, :a, s(:hash)))),

               :tLAMBDA,     nil, :expr_endfn,  0, 0,
               :tLPAREN2,    "(", :expr_beg,    1, 0,
               :tIDENTIFIER, "a", :expr_arg,    1, 0,
               :tEQL,        "=", :expr_beg,    1, 0,
               :tLBRACE,     "{", :expr_beg,    1, 1,
               :tRCURLY,     "}", :expr_endarg, 1, 0,
               :tRPAREN,     ")", :expr_endfn,  0, 0,
               :tLCURLY,     "{", :expr_beg,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0)
  end

  def test_yylex_iter_array_curly
    assert_lex("f :a, [:b] { |c, d| }", # yes, this is bad code
               s(:iter,
                 s(:call, nil, :f, s(:lit, :a), s(:array, s(:lit, :b))),
                 s(:args, :c, :d)),

               :tIDENTIFIER, "f", :expr_cmdarg, 0, 0,
               :tSYMBOL,     "a", :expr_end,    0, 0,
               :tCOMMA,      ",", :expr_beg,    0, 0,
               :tLBRACK,     "[", :expr_beg,    1, 0,
               :tSYMBOL,     "b", :expr_end,    1, 0,
               :tRBRACK,     "]", :expr_endarg, 0, 0,
               :tLBRACE_ARG, "{", :expr_beg,    0, 1,
               :tPIPE,       "|", :expr_beg,    0, 1,
               :tIDENTIFIER, "c", :expr_arg,    0, 1,
               :tCOMMA,      ",", :expr_beg,    0, 1,
               :tIDENTIFIER, "d", :expr_arg,    0, 1,
               :tPIPE,       "|", :expr_beg,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0)
  end

  def test_yylex_const_call_same_name
    assert_lex("X = a { }; b { f :c }",
               s(:block,
                 s(:cdecl, :X, s(:iter, s(:call, nil, :a), 0)),
                 s(:iter,
                   s(:call, nil, :b),
                   0,
                   s(:call, nil, :f, s(:lit, :c)))),

               :tCONSTANT,   "X", :expr_cmdarg, 0, 0,
               :tEQL,        "=", :expr_beg,    0, 0,
               :tIDENTIFIER, "a", :expr_arg,    0, 0,
               :tLCURLY,     "{", :expr_beg,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0,
               :tSEMI,       ";", :expr_beg,    0, 0,

               :tIDENTIFIER, "b", :expr_cmdarg, 0, 0,
               :tLCURLY,     "{", :expr_beg,    0, 1,
               :tIDENTIFIER, "f", :expr_cmdarg, 0, 1, # different
               :tSYMBOL,     "c", :expr_end,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0)

    assert_lex("X = a { }; b { X :c }",
               s(:block,
                 s(:cdecl, :X, s(:iter, s(:call, nil, :a), 0)),
                 s(:iter,
                   s(:call, nil, :b),
                   0,
                   s(:call, nil, :X, s(:lit, :c)))),

               :tCONSTANT,   "X", :expr_cmdarg, 0, 0,
               :tEQL,        "=", :expr_beg,    0, 0,
               :tIDENTIFIER, "a", :expr_arg,    0, 0,
               :tLCURLY,     "{", :expr_beg,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0,
               :tSEMI,       ";", :expr_beg,    0, 0,

               :tIDENTIFIER, "b", :expr_cmdarg, 0, 0,
               :tLCURLY,     "{", :expr_beg,    0, 1,
               :tCONSTANT,   "X", :expr_cmdarg, 0, 1, # same
               :tSYMBOL,     "c", :expr_end,    0, 1,
               :tRCURLY,     "}", :expr_endarg, 0, 0)
  end

  def test_yylex_lasgn_call_same_name
    assert_lex("a = b.c :d => 1",
               s(:lasgn, :a,
                 s(:call, s(:call, nil, :b), :c,
                   s(:hash, s(:lit, :d), s(:lit, 1)))),

               :tIDENTIFIER, "a", :expr_cmdarg, 0, 0,
               :tEQL,        "=", :expr_beg,    0, 0,
               :tIDENTIFIER, "b", :expr_arg,    0, 0,
               :tDOT,        ".", :expr_dot,    0, 0,
               :tIDENTIFIER, "c", :expr_arg,    0, 0, # different
               :tSYMBOL,     "d", :expr_end,    0, 0,
               :tASSOC,      "=>", :expr_beg,   0, 0,
               :tINTEGER,      1, :expr_end,    0, 0)

    assert_lex("a = b.a :d => 1",
               s(:lasgn, :a,
                 s(:call, s(:call, nil, :b), :a,
                   s(:hash, s(:lit, :d), s(:lit, 1)))),

               :tIDENTIFIER, "a", :expr_cmdarg, 0, 0,
               :tEQL,        "=", :expr_beg,    0, 0,
               :tIDENTIFIER, "b", :expr_arg,    0, 0,
               :tDOT,        ".", :expr_dot,    0, 0,
               :tIDENTIFIER, "a", :expr_arg,    0, 0, # same as lvar
               :tSYMBOL,     "d", :expr_end,    0, 0,
               :tASSOC,      "=>", :expr_beg,   0, 0,
               :tINTEGER,      1, :expr_end,    0, 0)
  end

  def test_yylex_back_ref
    assert_lex3("[$&, $`, $', $+]",
                nil,
                :tLBRACK,   "[",  :expr_beg,
                :tBACK_REF, :&,   :expr_end, :tCOMMA, ",", :expr_beg,
                :tBACK_REF, :"`", :expr_end, :tCOMMA, ",", :expr_beg,
                :tBACK_REF, :"'", :expr_end, :tCOMMA, ",", :expr_beg,
                :tBACK_REF, :+,   :expr_end,
                :tRBRACK,   "]",  :expr_endarg)
  end

  def test_yylex_backslash
    assert_lex3("1 \\\n+ 2",
                nil,
                :tINTEGER, 1,   :expr_end,
                :tPLUS,    "+", :expr_beg,
                :tINTEGER, 2,   :expr_end)
  end

  def test_yylex_backslash_bad
    refute_lex("1 \\ + 2", :tINTEGER, 1)
  end

  def test_yylex_backtick
    assert_lex3("`ls`",
                nil,
                :tXSTRING_BEG,    "`",  :expr_beg,
                :tSTRING_CONTENT, "ls", :expr_beg,
                :tSTRING_END,     "`",  :expr_end)
  end

  def test_yylex_backtick_cmdarg
    self.lex_state = :expr_dot

    # \n ensures expr_cmd (TODO: why?)
    assert_lex3("\n`", nil, :tBACK_REF2, "`", :expr_cmdarg)
  end

  def test_yylex_backtick_dot
    self.lex_state = :expr_dot

    assert_lex3("a.`(3)",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tDOT,        ".", :expr_dot,
                :tBACK_REF2,  "`", :expr_arg,
                :tLPAREN2,    "(", :expr_beg,
                :tINTEGER,    3,   :expr_end,
                :tRPAREN,     ")", :expr_endfn)
  end

  def test_yylex_backtick_method
    self.lex_state = :expr_fname

    assert_lex3("`",
                nil,
                :tBACK_REF2, "`", :expr_end)
  end

  def test_yylex_bad_char
    refute_lex(" \010 ")
  end

  def test_yylex_bang
    assert_lex3("!", nil, :tBANG, "!", :expr_beg)
  end

  def test_yylex_bang_equals
    assert_lex3("!=", nil, :tNEQ, "!=", :expr_beg)
  end

  def test_yylex_bang_tilde
    assert_lex3("!~", nil, :tNMATCH, "!~", :expr_beg)
  end

  def test_yylex_carat
    assert_lex3("^", nil, :tCARET, "^", :expr_beg)
  end

  def test_yylex_carat_equals
    assert_lex3("^=", nil, :tOP_ASGN, "^", :expr_beg)
  end

  def test_yylex_colon2
    assert_lex3("A::B",
                nil,
                :tCONSTANT, "A",  :expr_cmdarg,
                :tCOLON2,   "::", :expr_dot,
                :tCONSTANT, "B",  :expr_arg)
  end

  def test_yylex_colon2_argh
    assert_lex3("module X::Y\n  c\nend",
                nil,
                :kMODULE,     "module", :expr_value,
                :tCONSTANT,   "X",      :expr_arg,
                :tCOLON2,     "::",     :expr_dot,
                :tCONSTANT,   "Y",      :expr_arg,
                :tNL,         nil,      :expr_beg,
                :tIDENTIFIER, "c",      :expr_cmdarg,
                :tNL,         nil,      :expr_beg,
                :kEND,        "end",    :expr_end)
  end

  def test_yylex_colon3
    assert_lex3("::Array",
                nil,
                :tCOLON3,   "::",    :expr_beg,
                :tCONSTANT, "Array", :expr_arg)
  end

  def test_yylex_comma
    assert_lex3(",", nil, :tCOMMA, ",", :expr_beg)
  end

  def test_yylex_comment
    assert_lex3("1 # one\n# two\n2",
                nil,
                :tINTEGER, 1,   :expr_end,
                :tNL,      nil, :expr_beg,
                :tINTEGER, 2,   :expr_end)

    assert_equal "# one\n# two\n", @lex.comments
  end

  def test_yylex_comment_begin
    assert_lex3("=begin\nblah\nblah\n=end\n42",
                nil,
                :tINTEGER, 42, :expr_end)

    assert_equal "=begin\nblah\nblah\n=end\n", @lex.comments
  end

  def test_yylex_comment_begin_bad
    refute_lex("=begin\nblah\nblah\n")

    assert_equal "", @lex.comments
  end

  def test_yylex_comment_begin_not_comment
    assert_lex3("beginfoo = 5\np x \\\n=beginfoo",
                nil,
                :tIDENTIFIER, "beginfoo", :expr_cmdarg,
                :tEQL,        "=",        :expr_beg,
                :tINTEGER,    5,          :expr_end,
                :tNL,         nil,        :expr_beg,
                :tIDENTIFIER, "p",        :expr_cmdarg,
                :tIDENTIFIER, "x",        :expr_arg,
                :tEQL,        "=",        :expr_beg,
                :tIDENTIFIER, "beginfoo", :expr_arg)
  end

  def test_yylex_comment_begin_space
    assert_lex3("=begin blah\nblah\n=end\n", nil)

    assert_equal "=begin blah\nblah\n=end\n", @lex.comments
  end

  def test_yylex_comment_end_space_and_text
    assert_lex3("=begin blah\nblah\n=end blab\n", nil)

    assert_equal "=begin blah\nblah\n=end blab\n", @lex.comments
  end

  def test_yylex_comment_eos
    assert_lex3("# comment", nil)
  end

  def test_yylex_constant
    assert_lex3("ArgumentError", nil, :tCONSTANT, "ArgumentError", :expr_cmdarg)
  end

  def test_yylex_constant_semi
    assert_lex3("ArgumentError;",
                nil,
                :tCONSTANT, "ArgumentError", :expr_cmdarg,
                :tSEMI,     ";",             :expr_beg)
  end

  def test_yylex_cvar
    assert_lex3("@@blah", nil, :tCVAR, "@@blah", :expr_end)
  end

  def test_yylex_cvar_bad
    assert_raises RubyParser::SyntaxError do
      assert_lex3("@@1", nil)
    end
  end

  def test_yylex_def_bad_name
    self.lex_state = :expr_fname
    refute_lex("def [ ", :kDEF, "def")
  end

  def test_yylex_div
    assert_lex3("a / 2",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tDIVIDE,     "/", :expr_beg,
                :tINTEGER,    2,   :expr_end)
  end

  def test_yylex_div_equals
    assert_lex3("a /= 2",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tOP_ASGN,    "/", :expr_beg,
                :tINTEGER,    2,   :expr_end)
  end

  def test_yylex_do
    assert_lex3("x do 42 end",
                nil,
                :tIDENTIFIER, "x",   :expr_cmdarg,
                :kDO,         "do",  :expr_beg,
                :tINTEGER,    42,    :expr_end,
                :kEND,        "end", :expr_end)
  end

  def test_yylex_do_block
    self.lex_state = :expr_endarg

    assert_lex3("x.y do 42 end",
                nil,
                :tIDENTIFIER, "x",   :expr_end,
                :tDOT,        ".",   :expr_dot,
                :tIDENTIFIER, "y",   :expr_arg,
                :kDO_BLOCK,   "do",  :expr_beg,
                :tINTEGER,    42,    :expr_end,
                :kEND,        "end", :expr_end) do
      @lex.cmdarg.push true
    end
  end

  def test_yylex_do_block2
    self.lex_state = :expr_endarg

    assert_lex3("do 42 end",
                nil,
                :kDO_BLOCK, "do",  :expr_beg,
                :tINTEGER,  42,    :expr_end,
                :kEND,      "end", :expr_end)
  end

  def test_yylex_is_your_spacebar_broken?
    assert_lex3(":a!=:b",
                nil,
                :tSYMBOL, "a",  :expr_end,
                :tNEQ,    "!=", :expr_beg,
                :tSYMBOL, "b",  :expr_end)
  end

  def test_yylex_do_cond
    assert_lex3("x do 42 end",
                nil,
                :tIDENTIFIER, "x",   :expr_cmdarg,
                :kDO_COND,    "do",  :expr_beg,
                :tINTEGER,    42,    :expr_end,
                :kEND,        "end", :expr_end) do
      @lex.cond.push true
    end
  end

  def test_yylex_dollar_bad
    e = refute_lex("$%")
    assert_includes(e.message, "is not allowed as a global variable name")
  end

  def test_yylex_dollar_eos
    assert_lex3("$", nil, "$", "$", :expr_end) # FIX: wtf is this?!?
  end

  def test_yylex_dot # HINT message sends
    assert_lex3(".", nil, :tDOT, ".", :expr_dot)
  end

  def test_yylex_dot2
    assert_lex3("..", nil, :tDOT2, "..", :expr_beg)
  end

  def test_yylex_dot3
    assert_lex3("...", nil, :tDOT3, "...", :expr_beg)
  end

  def test_yylex_equals
    # FIX: this sucks
    assert_lex3("=", nil, :tEQL, "=", :expr_beg)
  end

  def test_yylex_equals2
    assert_lex3("==", nil, :tEQ, "==", :expr_beg)
  end

  def test_yylex_equals3
    assert_lex3("===", nil, :tEQQ, "===", :expr_beg)
  end

  def test_yylex_equals_tilde
    assert_lex3("=~", nil, :tMATCH, "=~", :expr_beg)
  end

  def test_yylex_float
    assert_lex3("1.0", nil, :tFLOAT, 1.0, :expr_end)
  end

  def test_yylex_float_bad_no_underscores
    refute_lex "1__0.0"
  end

  def test_yylex_float_bad_no_zero_leading
    refute_lex ".0"
  end

  def test_yylex_float_bad_trailing_underscore
    refute_lex "123_.0"
  end

  def test_yylex_float_call
    assert_lex3("1.0.to_s",
                nil,
                :tFLOAT,      1.0,    :expr_end,
                :tDOT,        ".",    :expr_dot,
                :tIDENTIFIER, "to_s", :expr_arg)
  end

  def test_yylex_float_dot_E
    assert_lex3("1.0E10",
                nil,
                :tFLOAT, 10000000000.0, :expr_end)
  end

  def test_yylex_float_dot_E_neg
    assert_lex3("-1.0E10",
                nil,
                :tUMINUS_NUM, "-",           :expr_beg,
                :tFLOAT,      10000000000.0, :expr_end)
  end

  def test_yylex_float_dot_e
    assert_lex3("1.0e10",
                nil,
                :tFLOAT, 10000000000.0, :expr_end)
  end

  def test_yylex_float_dot_e_neg
    assert_lex3("-1.0e10",
                nil,
                :tUMINUS_NUM, "-",           :expr_beg,
                :tFLOAT,      10000000000.0, :expr_end)
  end

  def test_yylex_float_e
    assert_lex3("1e10",
                nil,
                :tFLOAT, 10000000000.0, :expr_end)
  end

  def test_yylex_float_e_bad_double_e
    refute_lex "1e2e3"
  end

  def test_yylex_float_e_bad_trailing_underscore
    refute_lex "123_e10"
  end

  def test_yylex_float_e_minus
    assert_lex3("1e-10", nil, :tFLOAT, 1.0e-10, :expr_end)
  end

  def test_yylex_float_e_neg
    assert_lex3("-1e10",
                nil,
                :tUMINUS_NUM, "-",           :expr_beg,
                :tFLOAT,      10000000000.0, :expr_end)
  end

  def test_yylex_float_e_neg_minus
    assert_lex3("-1e-10",
                nil,
                :tUMINUS_NUM, "-",     :expr_beg,
                :tFLOAT,      1.0e-10, :expr_end)
  end

  def test_yylex_float_e_neg_plus
    assert_lex3("-1e+10",
                nil,
                :tUMINUS_NUM, "-",           :expr_beg,
                :tFLOAT,      10000000000.0, :expr_end)
  end

  def test_yylex_float_e_plus
    assert_lex3("1e+10", nil, :tFLOAT, 10000000000.0, :expr_end)
  end

  def test_yylex_float_e_zero
    assert_lex3("0e0", nil, :tFLOAT, 0.0, :expr_end)
  end

  def test_yylex_float_neg
    assert_lex3("-1.0",
                nil,
                :tUMINUS_NUM, "-", :expr_beg,
                :tFLOAT,      1.0, :expr_end)
  end

  def test_yylex_ge
    assert_lex3("a >= 2",
                nil,
                :tIDENTIFIER, "a",  :expr_cmdarg,
                :tGEQ,        ">=", :expr_beg,
                :tINTEGER,    2,    :expr_end)
  end

  def test_yylex_global
    assert_lex3("$blah", nil, :tGVAR, "$blah", :expr_end)
  end

  def test_yylex_global_backref
    self.lex_state = :expr_fname

    assert_lex3("$`", nil, :tGVAR, "$`", :expr_end)
  end

  def test_yylex_global_dash_nothing
    assert_lex3("$- ", nil, :tGVAR, "$-", :expr_end)
  end

  def test_yylex_global_dash_something
    assert_lex3("$-x", nil, :tGVAR, "$-x", :expr_end)
  end

  def test_yylex_global_number
    self.lex_state = :expr_fname

    assert_lex3("$1", nil, :tGVAR, "$1", :expr_end)
  end

  def test_yylex_global_number_big
    self.lex_state = :expr_fname

    assert_lex3("$1234", nil, :tGVAR, "$1234", :expr_end)
  end

  def test_yylex_global_other
    assert_lex3("[$~, $*, $$, $?, $!, $@, $/, $\\, $;, $,, $., $=, $:, $<, $>, $\"]",
                nil,
                :tLBRACK, "[",   :expr_beg,
                :tGVAR,   "$~",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$*",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$$",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$?",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$!",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$@",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$/",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$\\", :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$;",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$,",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$.",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$=",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$:",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$<",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$>",  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tGVAR,   "$\"", :expr_end,
                :tRBRACK, "]",   :expr_endarg)
  end

  def test_yylex_global_underscore
    assert_lex3("$_", nil, :tGVAR, "$_", :expr_end)
  end

  def test_yylex_global_wierd
    assert_lex3("$__blah", nil, :tGVAR, "$__blah", :expr_end)
  end

  def test_yylex_global_zero
    assert_lex3("$0", nil, :tGVAR, "$0", :expr_end)
  end

  def test_yylex_gt
    assert_lex3("a > 2",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tGT,         ">", :expr_beg,
                :tINTEGER,    2,   :expr_end)
  end

  def test_yylex_heredoc_backtick
    assert_lex3("a = <<`EOF`\n  blah blah\nEOF\n\n",
                nil,
                :tIDENTIFIER,     "a",             :expr_cmdarg,
                :tEQL,            "=",             :expr_beg,
                :tXSTRING_BEG,    "`",             :expr_beg,
                :tSTRING_CONTENT, "  blah blah\n", :expr_beg,
                :tSTRING_END,     "EOF",           :expr_end,
                :tNL,             nil,             :expr_beg)
  end

  def test_yylex_heredoc_double
    assert_lex3("a = <<\"EOF\"\n  blah blah\nEOF\n\n",
                nil,
                :tIDENTIFIER,     "a",             :expr_cmdarg,
                :tEQL,            "=",             :expr_beg,
                :tSTRING_BEG,     "\"",            :expr_beg,
                :tSTRING_CONTENT, "  blah blah\n", :expr_beg,
                :tSTRING_END,     "EOF",           :expr_end,
                :tNL,             nil,             :expr_beg)
  end

  def test_yylex_heredoc_double_dash
    assert_lex3("a = <<-\"EOF\"\n  blah blah\n  EOF\n\n",
                nil,
                :tIDENTIFIER,     "a",             :expr_cmdarg,
                :tEQL,            "=",             :expr_beg,
                :tSTRING_BEG,     "\"",            :expr_beg,
                :tSTRING_CONTENT, "  blah blah\n", :expr_beg,
                :tSTRING_END,     "EOF",           :expr_end,
                :tNL,             nil,             :expr_beg)
  end

  def test_yylex_heredoc_double_eos
    refute_lex("a = <<\"EOF\"\nblah",
               :tIDENTIFIER, "a",
               :tEQL,        "=",
               :tSTRING_BEG, "\"")
  end

  def test_yylex_heredoc_double_eos_nl
    refute_lex("a = <<\"EOF\"\nblah\n",
               :tIDENTIFIER, "a",
               :tEQL,        "=",
               :tSTRING_BEG, "\"")
  end

  def test_yylex_heredoc_double_interp
    assert_lex3("a = <<\"EOF\"\n#x a \#@a b \#$b c \#{3} \nEOF\n\n",
                nil,
                :tIDENTIFIER,     "a",     :expr_cmdarg,
                :tEQL,            "=",     :expr_beg,
                :tSTRING_BEG,     "\"",    :expr_beg,
                :tSTRING_CONTENT, "#x a ", :expr_beg,
                :tSTRING_DVAR,    "\#@",   :expr_beg,
                :tSTRING_CONTENT, "@a b ", :expr_beg, # HUH?
                :tSTRING_DVAR,    "\#$",   :expr_beg,
                :tSTRING_CONTENT, "$b c ", :expr_beg, # HUH?
                :tSTRING_DBEG,    "\#{",   :expr_beg,
                :tSTRING_CONTENT, "3} \n", :expr_beg, # HUH?
                :tSTRING_END,     "EOF",   :expr_end,
                :tNL,             nil,     :expr_beg)
  end

  def test_yylex_heredoc_empty
    assert_lex3("<<\"\"\n\#{x}\nblah2\n\n\n",
                nil,
                :tSTRING_BEG,     "\"",          :expr_beg,
                :tSTRING_DBEG,    "\#{",         :expr_beg,
                :tSTRING_CONTENT, "x}\nblah2\n", :expr_beg,
                :tSTRING_END,     "",            :expr_end,
                :tNL,             nil,           :expr_beg)
  end

  def test_yylex_heredoc_none
    assert_lex3("a = <<EOF\nblah\nblah\nEOF\n",
                nil,
                :tIDENTIFIER,     "a",            :expr_cmdarg,
                :tEQL,            "=",            :expr_beg,
                :tSTRING_BEG,     "\"",           :expr_beg,
                :tSTRING_CONTENT, "blah\nblah\n", :expr_beg,
                :tSTRING_END,     "EOF",          :expr_end,
                :tNL,             nil,            :expr_beg)
  end

  def test_yylex_heredoc_none_bad_eos
    refute_lex("a = <<EOF",
                   :tIDENTIFIER, "a",
                   :tEQL,        "=",
                   :tSTRING_BEG, "\"")
  end

  def test_yylex_heredoc_none_dash
    assert_lex3("a = <<-EOF\nblah\nblah\n  EOF\n",
                nil,
                :tIDENTIFIER,     "a",            :expr_cmdarg,
                :tEQL,            "=",            :expr_beg,
                :tSTRING_BEG,     "\"",           :expr_beg,
                :tSTRING_CONTENT, "blah\nblah\n", :expr_beg,
                :tSTRING_END,     "EOF",          :expr_end,
                :tNL,             nil,            :expr_beg)
  end

  def test_yylex_heredoc_single
    assert_lex3("a = <<'EOF'\n  blah blah\nEOF\n\n",
                nil,
                :tIDENTIFIER,     "a",             :expr_cmdarg,
                :tEQL,            "=",             :expr_beg,
                :tSTRING_BEG,     "\"",            :expr_beg,
                :tSTRING_CONTENT, "  blah blah\n", :expr_beg,
                :tSTRING_END,     "EOF",           :expr_end,
                :tNL,             nil,             :expr_beg)
  end

  def test_yylex_heredoc_single_bad_eos_body
    refute_lex("a = <<'EOF'\nblah",
               :tIDENTIFIER, "a",
               :tEQL,        "=",
               :tSTRING_BEG, "\"")
  end

  def test_yylex_heredoc_single_bad_eos_empty
    refute_lex("a = <<''\n",
               :tIDENTIFIER, "a",
               :tEQL,        "=",
               :tSTRING_BEG, "\"")
  end

  def test_yylex_heredoc_single_bad_eos_term
    refute_lex("a = <<'EOF",
               :tIDENTIFIER, "a",
               :tEQL,        "=",
               :tSTRING_BEG, "\"")
  end

  def test_yylex_heredoc_single_bad_eos_term_nl
    refute_lex("a = <<'EOF\ns = 'blah blah'",
               :tIDENTIFIER, "a",
               :tEQL,        "=",
               :tSTRING_BEG, "\"")
  end

  def test_yylex_heredoc_single_dash
    assert_lex3("a = <<-'EOF'\n  blah blah\n  EOF\n\n",
                nil,
                :tIDENTIFIER,     "a",             :expr_cmdarg,
                :tEQL,            "=",             :expr_beg,
                :tSTRING_BEG,     "\"",            :expr_beg,
                :tSTRING_CONTENT, "  blah blah\n", :expr_beg,
                :tSTRING_END,     "EOF",           :expr_end,
                :tNL,             nil,             :expr_beg)
  end

  def test_yylex_identifier
    assert_lex3("identifier",
                nil,
                :tIDENTIFIER, "identifier", :expr_cmdarg)
  end

  def test_yylex_identifier_bang
    assert_lex3("identifier!",
                nil,
                :tFID, "identifier!", :expr_cmdarg)
  end

  def test_yylex_identifier_cmp
    assert_lex_fname "<=>", :tCMP
  end

  def test_yylex_identifier_def__18
    setup_lexer_class Ruby18Parser

    assert_lex_fname "identifier", :tIDENTIFIER, :expr_end
  end

  def test_yylex_identifier_def__1920
    setup_lexer_class Ruby19Parser

    assert_lex_fname "identifier", :tIDENTIFIER, :expr_endfn
  end

  def test_yylex_identifier_eh
    assert_lex3("identifier?", nil, :tFID, "identifier?", :expr_cmdarg)
  end

  def test_yylex_identifier_equals_arrow
    assert_lex3(":blah==>",
                nil,
                :tSYMBOL, "blah=", :expr_end,
                :tASSOC,  "=>",    :expr_beg)
  end

  def test_yylex_identifier_equals3
    assert_lex3(":a===b",
                nil,
                :tSYMBOL,     "a",   :expr_end,
                :tEQQ,        "===", :expr_beg,
                :tIDENTIFIER, "b",   :expr_arg)
  end

  def test_yylex_identifier_equals_equals_arrow
    assert_lex3(":a==>b",
                nil,
                :tSYMBOL, "a=", :expr_end,
                :tASSOC, "=>", :expr_beg,
                :tIDENTIFIER, "b", :expr_arg)
  end

  def test_yylex_identifier_equals_caret
    assert_lex_fname "^", :tCARET
  end

  def test_yylex_identifier_equals_def__18
    setup_lexer_class Ruby18Parser

    assert_lex_fname "identifier=", :tIDENTIFIER, :expr_end
  end

  def test_yylex_identifier_equals_def__1920
    setup_lexer_class Ruby19Parser

    assert_lex_fname "identifier=", :tIDENTIFIER, :expr_endfn
  end

  def test_yylex_identifier_equals_def2
    assert_lex_fname "==", :tEQ
  end

  def test_yylex_identifier_equals_expr
    self.lex_state = :expr_dot
    assert_lex3("y = arg",
                nil,
                :tIDENTIFIER, "y",   :expr_cmdarg,
                :tEQL,        "=",   :expr_beg,
                :tIDENTIFIER, "arg", :expr_arg)
  end

  def test_yylex_identifier_equals_or
    assert_lex_fname "|", :tPIPE
  end

  def test_yylex_identifier_equals_slash
    assert_lex_fname "/", :tDIVIDE
  end

  def test_yylex_identifier_equals_tilde
    self.lex_state = :expr_fname # can only set via parser's defs

    assert_lex3("identifier=~",
                nil,
                :tIDENTIFIER, "identifier", :expr_endfn,
                :tMATCH,      "=~",         :expr_beg)
  end

  def test_yylex_identifier_gt
    assert_lex_fname ">", :tGT
  end

  def test_yylex_identifier_le
    assert_lex_fname "<=", :tLEQ
  end

  def test_yylex_identifier_lt
    assert_lex_fname "<", :tLT
  end

  def test_yylex_identifier_tilde
    assert_lex_fname "~", :tTILDE
  end

  def test_yylex_index
    assert_lex_fname "[]", :tAREF
  end

  def test_yylex_index_equals
    assert_lex_fname "[]=", :tASET
  end

  def test_yylex_integer
    assert_lex3("42", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_integer_bin
    assert_lex3("0b101010", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_integer_bin_bad_none
    refute_lex "0b "
  end

  def test_yylex_integer_bin_bad_underscores
    refute_lex "0b10__01"
  end

  def test_yylex_integer_dec
    assert_lex3("42", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_integer_dec_bad_underscores
    refute_lex "42__24"
  end

  def test_yylex_integer_dec_d
    assert_lex3("0d42", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_integer_dec_d_bad_none
    refute_lex "0d"
  end

  def test_yylex_integer_dec_d_bad_underscores
    refute_lex "0d42__24"
  end

  def test_yylex_question_eh_a__18
    setup_lexer_class Ruby18Parser

    assert_lex3("?a", nil, :tINTEGER, 97, :expr_end)
  end

  def test_yylex_question_eh_a__19
    setup_lexer_class Ruby19Parser

    assert_lex3("?a", nil, :tSTRING, "a", :expr_end)
  end

  def test_yylex_question_eh_escape_M_escape_C__18
    setup_lexer_class Ruby18Parser

    assert_lex3("?\\M-\\C-a", nil, :tINTEGER, 129, :expr_end)
  end

  def test_yylex_question_eh_escape_M_escape_C__19
    setup_lexer_class Ruby19Parser

    assert_lex3("?\\M-\\C-a", nil, :tSTRING, "\M-\C-a", :expr_end)
  end

  def test_yylex_integer_hex
    assert_lex3 "0x2a", nil, :tINTEGER, 42, :expr_end
  end

  def test_yylex_integer_hex_bad_none
    refute_lex "0x "
  end

  def test_yylex_integer_hex_bad_underscores
    refute_lex "0xab__cd"
  end

  def test_yylex_integer_oct
    assert_lex3("052", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_integer_oct_bad_range
    refute_lex "08"
  end

  def test_yylex_integer_oct_bad_range2
    refute_lex "08"
  end

  def test_yylex_integer_oct_bad_underscores
    refute_lex "01__23"
  end

  def test_yylex_integer_oct_O
    assert_lex3 "0O52", nil, :tINTEGER, 42, :expr_end
  end

  def test_yylex_integer_oct_O_bad_range
    refute_lex "0O8"
  end

  def test_yylex_integer_oct_O_bad_underscores
    refute_lex "0O1__23"
  end

  def test_yylex_integer_oct_O_not_bad_none
    assert_lex3 "0O ", nil, :tINTEGER, 0, :expr_end
  end

  def test_yylex_integer_oct_o
    assert_lex3 "0o52", nil, :tINTEGER, 42, :expr_end
  end

  def test_yylex_integer_oct_o_bad_range
    refute_lex "0o8"
  end

  def test_yylex_integer_oct_o_bad_underscores
    refute_lex "0o1__23"
  end

  def test_yylex_integer_oct_o_not_bad_none
    assert_lex3 "0o ", nil, :tINTEGER, 0, :expr_end
  end

  def test_yylex_integer_trailing
    assert_lex3("1.to_s",
                nil,
                :tINTEGER,    1,      :expr_end,
                :tDOT,        ".",    :expr_dot,
                :tIDENTIFIER, "to_s", :expr_arg)
  end

  def test_yylex_integer_underscore
    assert_lex3("4_2", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_integer_underscore_bad
    refute_lex "4__2"
  end

  def test_yylex_integer_zero
    assert_lex3 "0", nil, :tINTEGER, 0, :expr_end
  end

  def test_yylex_ivar
    assert_lex3("@blah", nil, :tIVAR, "@blah", :expr_end)
  end

  def test_yylex_ivar_bad
    refute_lex "@1"
  end

  def test_yylex_ivar_bad_0_length
    refute_lex "1+@\n", :tINTEGER, 1, :tPLUS, "+", :expr_end
  end

  def test_yylex_keyword_expr
    self.lex_state = :expr_endarg

    assert_lex3("if", nil, :kIF_MOD, "if", :expr_beg)
  end

  def test_yylex_lt
    assert_lex3("<", nil, :tLT, "<", :expr_beg)
  end

  def test_yylex_lt2
    assert_lex3("a << b",
                nil,
                :tIDENTIFIER, "a",  :expr_cmdarg,
                :tLSHFT,      "<<", :expr_beg,
                :tIDENTIFIER, "b",  :expr_arg)
  end

  def test_yylex_lt2_equals
    assert_lex3("a <<= b",
                nil,
                :tIDENTIFIER, "a",  :expr_cmdarg,
                :tOP_ASGN,    "<<", :expr_beg,
                :tIDENTIFIER, "b",  :expr_arg)
  end

  def test_yylex_lt_equals
    assert_lex3("<=", nil, :tLEQ, "<=", :expr_beg)
  end

  def test_yylex_minus
    assert_lex3("1 - 2",
                nil,
                :tINTEGER, 1,   :expr_end,
                :tMINUS,   "-", :expr_beg,
                :tINTEGER, 2,   :expr_end)
  end

  def test_yylex_minus_equals
    assert_lex3("-=", nil, :tOP_ASGN, "-", :expr_beg)
  end

  def test_yylex_minus_method
    self.lex_state = :expr_fname

    assert_lex3("-", nil, :tMINUS, "-", :expr_arg)
  end

  def test_yylex_minus_unary_method
    self.lex_state = :expr_fname

    assert_lex3("-@", nil, :tUMINUS, "-@", :expr_arg)
  end

  def test_yylex_minus_unary_number
    assert_lex3("-42",
                nil,
                :tUMINUS_NUM, "-", :expr_beg,
                :tINTEGER,    42,  :expr_end)
  end

  def test_yylex_nth_ref
    assert_lex3("[$1, $2, $3, $4, $5, $6, $7, $8, $9]",
               nil,
               :tLBRACK,  "[", :expr_beg,
               :tNTH_REF, 1,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 2,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 3,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 4,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 5,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 6,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 7,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 8,   :expr_end, :tCOMMA,   ",", :expr_beg,
               :tNTH_REF, 9,   :expr_end,
               :tRBRACK,  "]", :expr_endarg)
  end

  def test_yylex_open_bracket
    assert_lex3("(", nil, :tLPAREN, "(", :expr_beg)
  end

  def test_yylex_open_bracket_cmdarg
    self.lex_state = :expr_cmdarg

    assert_lex3(" (", nil, :tLPAREN_ARG, "(", :expr_beg)
  end

  def test_yylex_open_bracket_exprarg__18
    setup_lexer_class Ruby18Parser
    self.lex_state = :expr_arg

    assert_lex3(" (", nil, :tLPAREN2, "(", :expr_beg)
  end

  def test_yylex_open_bracket_exprarg__19
    setup_lexer_class Ruby19Parser
    self.lex_state = :expr_arg

    assert_lex3(" (", nil, :tLPAREN_ARG, "(", :expr_beg)
  end

  def test_yylex_open_curly_bracket
    assert_lex3("{", nil, :tLBRACE, "{", :expr_beg)
  end

  def test_yylex_open_curly_bracket_arg
    self.lex_state = :expr_arg

    assert_lex3("m { 3 }",
                nil,
                :tIDENTIFIER, "m", :expr_cmdarg,
                :tLCURLY,     "{", :expr_beg,
                :tINTEGER,    3,   :expr_end,
                :tRCURLY,     "}", :expr_endarg)
  end

  def test_yylex_open_curly_bracket_block
    self.lex_state = :expr_endarg # seen m(3)

    assert_lex3("{ 4 }",
                nil,
                :tLBRACE_ARG, "{", :expr_beg,
                :tINTEGER,    4,   :expr_end,
                :tRCURLY,     "}", :expr_endarg)
  end

  def test_yylex_open_square_bracket_arg
    self.lex_state = :expr_arg

    assert_lex3("m [ 3 ]",
                nil,
                :tIDENTIFIER, "m", :expr_cmdarg,
                :tLBRACK,     "[", :expr_beg,
                :tINTEGER,    3,   :expr_end,
                :tRBRACK,     "]", :expr_endarg)
  end

  def test_yylex_open_square_bracket_ary
    assert_lex3("[1, 2, 3]",
                nil,
                :tLBRACK, "[", :expr_beg,
                :tINTEGER, 1,  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tINTEGER, 2,  :expr_end, :tCOMMA,  ",", :expr_beg,
                :tINTEGER, 3,  :expr_end,
                :tRBRACK, "]", :expr_endarg)
  end

  def test_yylex_open_square_bracket_meth
    assert_lex3("m[3]",
               nil,
               :tIDENTIFIER, "m", :expr_cmdarg,
               :tLBRACK2,    "[", :expr_beg,
               :tINTEGER,    3,   :expr_end,
               :tRBRACK,     "]", :expr_endarg)
  end

  def test_yylex_or
    assert_lex3("|", nil, :tPIPE, "|", :expr_beg)
  end

  def test_yylex_or2
    assert_lex3("||", nil, :tOROP, "||", :expr_beg)
  end

  def test_yylex_or2_equals
    assert_lex3("||=", nil, :tOP_ASGN, "||", :expr_beg)
  end

  def test_yylex_or_equals
    assert_lex3("|=", nil, :tOP_ASGN, "|", :expr_beg)
  end

  def test_yylex_percent
    assert_lex3("a % 2",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tPERCENT,    "%", :expr_beg,
                :tINTEGER,    2,   :expr_end)
  end

  def test_yylex_percent_equals
    assert_lex3("a %= 2",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tOP_ASGN,    "%", :expr_beg,
                :tINTEGER,    2,   :expr_end)
  end

  def test_yylex_plus
    assert_lex3("1 + 1", # TODO lex_state?
                nil,
                :tINTEGER, 1,   :expr_end,
                :tPLUS,    "+", :expr_beg,
                :tINTEGER, 1,   :expr_end)
  end

  def test_yylex_plus_equals
    assert_lex3("+=", nil, :tOP_ASGN, "+", :expr_beg)
  end

  def test_yylex_plus_method
    self.lex_state = :expr_fname

    assert_lex3("+", nil, :tPLUS, "+", :expr_arg)
  end

  def test_yylex_plus_unary_method
    self.lex_state = :expr_fname

    assert_lex3("+@", nil, :tUPLUS, "+@", :expr_arg)
  end

  def test_yylex_not_unary_method
    self.lex_state = :expr_fname

    assert_lex3("!@", nil, :tUBANG, "!@", :expr_arg)
  end

  def test_yylex_numbers
    assert_lex3("0b10", nil, :tINTEGER, 2,  :expr_end)
    assert_lex3("0B10", nil, :tINTEGER, 2,  :expr_end)

    assert_lex3("0d10", nil, :tINTEGER, 10, :expr_end)
    assert_lex3("0D10", nil, :tINTEGER, 10, :expr_end)

    assert_lex3("0x10", nil, :tINTEGER, 16, :expr_end)
    assert_lex3("0X10", nil, :tINTEGER, 16, :expr_end)

    assert_lex3("0o10", nil, :tINTEGER, 8,  :expr_end)
    assert_lex3("0O10", nil, :tINTEGER, 8,  :expr_end)

    assert_lex3("0o",   nil, :tINTEGER, 0,  :expr_end)
    assert_lex3("0O",   nil, :tINTEGER, 0,  :expr_end)

    assert_lex3("0",    nil, :tINTEGER, 0,  :expr_end)

    refute_lex "0x"
    refute_lex "0X"
    refute_lex "0b"
    refute_lex "0B"
    refute_lex "0d"
    refute_lex "0D"

    refute_lex "08"
    refute_lex "09"
    refute_lex "0o8"
    refute_lex "0o9"
    refute_lex "0O8"
    refute_lex "0O9"

    refute_lex "1_e1"
    refute_lex "1_.1"
    refute_lex "1__1"
  end

  def test_yylex_plus_unary_number
    assert_lex3("+42", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_question__18
    setup_lexer_class Ruby18Parser

    assert_lex3("?*", nil, :tINTEGER, 42, :expr_end)
  end

  def test_yylex_question__19
    setup_lexer_class Ruby19Parser

    assert_lex3("?*", nil, :tSTRING, "*", :expr_end)
  end

  def test_yylex_question_bad_eos
    refute_lex "?"
  end

  def test_yylex_question_ws
    assert_lex3("? ",  nil, :tEH, "?", :expr_value)
    assert_lex3("?\n", nil, :tEH, "?", :expr_value)
    assert_lex3("?\t", nil, :tEH, "?", :expr_value)
    assert_lex3("?\v", nil, :tEH, "?", :expr_value)
    assert_lex3("?\r", nil, :tEH, "?", :expr_value)
    assert_lex3("?\f", nil, :tEH, "?", :expr_value)
  end

  def test_yylex_question_ws_backslashed__18
    setup_lexer_class Ruby18Parser

    assert_lex3("?\\ ", nil, :tINTEGER, 32, :expr_end)
    assert_lex3("?\\n", nil, :tINTEGER, 10, :expr_end)
    assert_lex3("?\\t", nil, :tINTEGER,  9, :expr_end)
    assert_lex3("?\\v", nil, :tINTEGER, 11, :expr_end)
    assert_lex3("?\\r", nil, :tINTEGER, 13, :expr_end)
    assert_lex3("?\\f", nil, :tINTEGER, 12, :expr_end)
  end

  def test_yylex_question_ws_backslashed__19
    setup_lexer_class Ruby19Parser

    assert_lex3("?\\ ", nil, :tSTRING, " ",  :expr_end)
    assert_lex3("?\\n", nil, :tSTRING, "\n", :expr_end)
    assert_lex3("?\\t", nil, :tSTRING, "\t", :expr_end)
    assert_lex3("?\\v", nil, :tSTRING, "\v", :expr_end)
    assert_lex3("?\\r", nil, :tSTRING, "\r", :expr_end)
    assert_lex3("?\\f", nil, :tSTRING, "\f", :expr_end)
  end

  def test_yylex_rbracket
    assert_lex3("]", nil, :tRBRACK, "]", :expr_endarg)
  end

  def test_yylex_rcurly
    assert_lex3("}", nil, :tRCURLY, "}", :expr_endarg)
  end

  def test_yylex_regexp
    assert_lex3("/regexp/",
                nil,
                :tREGEXP_BEG,     "/",      :expr_beg,
                :tSTRING_CONTENT, "regexp", :expr_beg,
                :tREGEXP_END,     "",       :expr_end)
  end

  def test_yylex_regexp_ambiguous
    assert_lex3("method /regexp/",
                nil,
                :tIDENTIFIER,     "method", :expr_cmdarg,
                :tREGEXP_BEG,     "/",      :expr_cmdarg,
                :tSTRING_CONTENT, "regexp", :expr_cmdarg,
                :tREGEXP_END,     "",       :expr_end)
  end

  def test_yylex_regexp_bad
    refute_lex("/.*/xyz",
               :tREGEXP_BEG,     "/",
               :tSTRING_CONTENT, ".*")
  end

  def test_yylex_regexp_escape_C
    assert_lex3("/regex\\C-x/",
                nil,
                :tREGEXP_BEG,     "/",          :expr_beg,
                :tSTRING_CONTENT, "regex\\C-x", :expr_beg,
                :tREGEXP_END,     "",           :expr_end)
  end

  def test_yylex_regexp_escape_C_M
    assert_lex3("/regex\\C-\\M-x/",
                nil,
                :tREGEXP_BEG,     "/",              :expr_beg,
                :tSTRING_CONTENT, "regex\\C-\\M-x", :expr_beg,
                :tREGEXP_END,     "",               :expr_end)
  end

  def test_yylex_regexp_escape_C_M_craaaazy
    assert_lex3("/regex\\C-\\\n\\M-x/",
                nil,
                :tREGEXP_BEG,     "/",              :expr_beg,
                :tSTRING_CONTENT, "regex\\C-\\M-x", :expr_beg,
                :tREGEXP_END,     "",               :expr_end)
  end

  def test_yylex_regexp_escape_C_bad_dash
    refute_lex '/regex\\Cx/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_dash_eos
    refute_lex '/regex\\C-/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_dash_eos2
    refute_lex '/regex\\C-', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_eos
    refute_lex '/regex\\C/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_C_bad_eos2
    refute_lex '/regex\\c', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M
    assert_lex3("/regex\\M-x/",
                nil,
                :tREGEXP_BEG,     "/",          :expr_beg,
                :tSTRING_CONTENT, "regex\\M-x", :expr_beg,
                :tREGEXP_END,     "",           :expr_end)
  end

  def test_yylex_regexp_escape_M_C
    assert_lex3("/regex\\M-\\C-x/",
                nil,
                :tREGEXP_BEG,     "/",              :expr_beg,
                :tSTRING_CONTENT, "regex\\M-\\C-x", :expr_beg,
                :tREGEXP_END,     "",               :expr_end)
  end

  def test_yylex_regexp_escape_M_bad_dash
    refute_lex '/regex\\Mx/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M_bad_dash_eos
    refute_lex '/regex\\M-/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M_bad_dash_eos2
    refute_lex '/regex\\M-', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_M_bad_eos
    refute_lex '/regex\\M/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_backslash_slash
    assert_lex3("/\\//",
                nil,
                :tREGEXP_BEG,     "/",   :expr_beg,
                :tSTRING_CONTENT, "\\/", :expr_beg,
                :tREGEXP_END,     "",    :expr_end)
  end

  def test_yylex_regexp_escape_backslash_terminator
    assert_lex3("%r%blah\\%blah%",
                nil,
                :tREGEXP_BEG,     "%r\000",      :expr_beg,
                :tSTRING_CONTENT, "blah\\%blah", :expr_beg,
                :tREGEXP_END,     "",            :expr_end)
  end

  def test_yylex_regexp_escape_backslash_terminator_meta1
    assert_lex3("%r{blah\\}blah}",
                nil,
                :tREGEXP_BEG,     "%r{",         :expr_beg, # FIX ?!?
                :tSTRING_CONTENT, "blah\\}blah", :expr_beg,
                :tREGEXP_END,     "",            :expr_end)
  end

  def test_yylex_regexp_escape_backslash_terminator_meta2
    assert_lex3("%r/blah\\/blah/",
                nil,
                :tREGEXP_BEG,     "%r\000",      :expr_beg,
                :tSTRING_CONTENT, "blah\\/blah", :expr_beg,
                :tREGEXP_END,     "",            :expr_end)
  end

  def test_yylex_regexp_escape_backslash_terminator_meta3
    assert_lex3("%r/blah\\%blah/",
                nil,
                :tREGEXP_BEG,     "%r\000",      :expr_beg,
                :tSTRING_CONTENT, "blah\\%blah", :expr_beg,
                :tREGEXP_END,     "",            :expr_end)
  end

  def test_yylex_regexp_escape_bad_eos
    refute_lex '/regex\\', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_bs
    assert_lex3("/regex\\\\regex/",
                nil,
                :tREGEXP_BEG,     "/",              :expr_beg,
                :tSTRING_CONTENT, "regex\\\\regex", :expr_beg,
                :tREGEXP_END,     "",               :expr_end)
  end

  def test_yylex_regexp_escape_c
    assert_lex3("/regex\\cxxx/",
                nil,
                :tREGEXP_BEG,     "/",           :expr_beg,
                :tSTRING_CONTENT, "regex\\cxxx", :expr_beg,
                :tREGEXP_END,     "",            :expr_end)
  end

  def test_yylex_regexp_escape_c_backslash
    assert_lex3("/regex\\c\\n/",
                nil,
                :tREGEXP_BEG,     "/",           :expr_beg,
                :tSTRING_CONTENT, "regex\\c\\n", :expr_beg,
                :tREGEXP_END,     "",            :expr_end)
  end

  def test_yylex_regexp_escape_chars
    assert_lex3("/re\\tge\\nxp/",
                nil,
                :tREGEXP_BEG,     "/",            :expr_beg,
                :tSTRING_CONTENT, "re\\tge\\nxp", :expr_beg,
                :tREGEXP_END,     "",             :expr_end)
  end

  def test_yylex_regexp_escape_double_backslash
    regexp = '/[\\/\\\\]$/'
    assert_lex3(regexp.dup,
                nil,
                :tREGEXP_BEG,     "/",          :expr_beg,
                :tSTRING_CONTENT, "[\\/\\\\]$", :expr_beg,
                :tREGEXP_END,     "",           :expr_end)
  end

  def test_yylex_regexp_escape_hex
    assert_lex3("/regex\\x61xp/",
                nil,
                :tREGEXP_BEG,     "/",            :expr_beg,
                :tSTRING_CONTENT, "regex\\x61xp", :expr_beg,
                :tREGEXP_END,     "",             :expr_end)
  end

  def test_yylex_regexp_escape_hex_bad
    refute_lex '/regex\\xzxp/', :tREGEXP_BEG, "/"
  end

  def test_yylex_regexp_escape_hex_one
    assert_lex3("/^[\\xd\\xa]{2}/on",
                nil,
                :tREGEXP_BEG,     "/",              :expr_beg,
                :tSTRING_CONTENT, "^[\\xd\\xa]{2}", :expr_beg,
                :tREGEXP_END,     "on",             :expr_end)
  end

  def test_yylex_regexp_escape_oct1
    assert_lex3("/regex\\0xp/",
                nil,
                :tREGEXP_BEG,     "/",          :expr_beg,
                :tSTRING_CONTENT, "regex\\0xp", :expr_beg,
                :tREGEXP_END,     "",           :expr_end)
  end

  def test_yylex_regexp_escape_oct2
    assert_lex3("/regex\\07xp/",
                nil,
                :tREGEXP_BEG,     "/",           :expr_beg,
                :tSTRING_CONTENT, "regex\\07xp", :expr_beg,
                :tREGEXP_END,     "",            :expr_end)
  end

  def test_yylex_regexp_escape_oct3
    assert_lex3("/regex\\10142/",
                nil,
                :tREGEXP_BEG,     "/",            :expr_beg,
                :tSTRING_CONTENT, "regex\\10142", :expr_beg,
                :tREGEXP_END,     "",             :expr_end)
  end

  def test_yylex_regexp_escape_return
    assert_lex3("/regex\\\nregex/",
                nil,
                :tREGEXP_BEG,     "/",          :expr_beg,
                :tSTRING_CONTENT, "regexregex", :expr_beg,
                :tREGEXP_END,     "",           :expr_end)
  end

  def test_yylex_regexp_nm
    assert_lex3("/.*/nm",
                nil,
                :tREGEXP_BEG,     "/",  :expr_beg,
                :tSTRING_CONTENT, ".*", :expr_beg,
                :tREGEXP_END,     "nm", :expr_end)
  end

  def test_yylex_rparen
    assert_lex3(")", nil, :tRPAREN, ")", :expr_endfn)
  end

  def test_yylex_rshft
    assert_lex3("a >> 2",
                nil,
                :tIDENTIFIER, "a",  :expr_cmdarg,
                :tRSHFT,      ">>", :expr_beg,
                :tINTEGER,    2,    :expr_end)
  end

  def test_yylex_rshft_equals
    assert_lex3("a >>= 2",
                nil,
                :tIDENTIFIER, "a",  :expr_cmdarg,
                :tOP_ASGN,    ">>", :expr_beg,
                :tINTEGER,    2,    :expr_end)
  end

  def test_yylex_star
    assert_lex3("a * ",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tSTAR2,      "*", :expr_beg)
  end

  def test_yylex_star2
    assert_lex3("a ** ",
                nil,
                :tIDENTIFIER, "a",  :expr_cmdarg,
                :tPOW,        "**", :expr_beg)
  end

  def test_yylex_star2_equals
    assert_lex3("a **= ",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tOP_ASGN,    "**", :expr_beg)
  end

  def test_yylex_star_arg
    self.lex_state = :expr_arg

    assert_lex3(" *a",
                nil,
                :tSTAR,       "*", :expr_beg,
                :tIDENTIFIER, "a", :expr_arg)
  end

  def test_yylex_star_arg_beg
    self.lex_state = :expr_beg

    assert_lex3("*a",
                nil,
                :tSTAR,       "*", :expr_beg,
                :tIDENTIFIER, "a", :expr_arg)
  end

  def test_yylex_star_arg_beg_fname
    self.lex_state = :expr_fname

    assert_lex3("*a",
                nil,
                :tSTAR2,      "*", :expr_arg,
                :tIDENTIFIER, "a", :expr_arg)
  end

  def test_yylex_star_arg_beg_fname2
    self.lex_state = :expr_fname

    assert_lex3("*a",
                nil,
                :tSTAR2,      "*", :expr_arg,
                :tIDENTIFIER, "a", :expr_arg)
  end

  def test_yylex_star_equals
    assert_lex3("a *= ",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tOP_ASGN, "*", :expr_beg)
  end

  def test_yylex_string_bad_eos
    refute_lex('%', :tSTRING_BEG, '%')
  end

  def test_yylex_string_bad_eos_quote
    refute_lex('%{nest', :tSTRING_BEG, '%}')
  end

  def test_yylex_string_double
    assert_lex3("\"string\"", nil, :tSTRING, "string", :expr_end)
  end

  def test_yylex_string_double_escape_C
    assert_lex3("\"\\C-a\"", nil, :tSTRING, "\001", :expr_end)
  end

  def test_yylex_string_double_escape_C_backslash
    assert_lex3("\"\\C-\\\\\"",
                nil,
                :tSTRING_BEG,     "\"",   :expr_beg,
                :tSTRING_CONTENT, "\034", :expr_beg,
                :tSTRING_END,     "\"",   :expr_end)
  end

  def test_yylex_string_double_escape_C_escape
    assert_lex3("\"\\C-\\M-a\"",
                nil,
                :tSTRING_BEG,     "\"",   :expr_beg,
                :tSTRING_CONTENT, "\201", :expr_beg,
                :tSTRING_END,     "\"",   :expr_end)
  end

  def test_yylex_string_double_escape_C_question
    assert_lex3("\"\\C-?\"", nil, :tSTRING, "\177", :expr_end)
  end

  def test_yylex_string_utf8_simple
    chr = [0x3024].pack("U")

    assert_lex3('"\u{3024}"',
                s(:str, chr),
                :tSTRING, chr, :expr_end)
  end

  def test_yylex_string_utf8_complex
    chr = [0x3024].pack("U")

    assert_lex3('"#@a\u{3024}"',
                s(:dstr, "", s(:evstr, s(:ivar, :@a)), s(:str, chr)),
                :tSTRING_BEG,     '"',      :expr_beg,
                :tSTRING_DVAR,    nil,      :expr_beg,
                :tSTRING_CONTENT, "@a"+chr, :expr_beg,
                :tSTRING_END,     '"',      :expr_end)
  end

  def test_yylex_string_double_escape_M
    chr = "\341"
    chr.force_encoding("UTF-8") if RubyLexer::RUBY19

    assert_lex3("\"\\M-a\"", nil, :tSTRING, chr, :expr_end)
  end

  def test_why_does_ruby_hate_me?
    assert_lex3("\"Nl%\\000\\000A\\000\\999\"", # you should be ashamed
                nil,
                :tSTRING, ["Nl%","\x00","\x00","A","\x00","999"].join, :expr_end)
  end

  def test_yylex_string_double_escape_M_backslash
    assert_lex3("\"\\M-\\\\\"",
                nil,
                :tSTRING_BEG,     "\"",   :expr_beg,
                :tSTRING_CONTENT, "\334", :expr_beg,
                :tSTRING_END,     "\"",   :expr_end)
  end

  def test_yylex_string_double_escape_M_escape
    assert_lex3("\"\\M-\\C-a\"",
                nil,
                :tSTRING_BEG,     "\"",   :expr_beg,
                :tSTRING_CONTENT, "\201", :expr_beg,
                :tSTRING_END,     "\"",   :expr_end)
  end

  def test_yylex_string_double_escape_bs1
    assert_lex3("\"a\\a\\a\"", nil, :tSTRING, "a\a\a", :expr_end)
  end

  def test_yylex_string_double_escape_bs2
    assert_lex3("\"a\\\\a\"", nil, :tSTRING, "a\\a", :expr_end)
  end

  def test_yylex_string_double_escape_c
    assert_lex3("\"\\ca\"", nil, :tSTRING, "\001", :expr_end)
  end

  def test_yylex_string_double_escape_c_backslash
    assert_lex3("\"\\c\\\"",
                nil,
                :tSTRING_BEG,     "\"",   :expr_beg,
                :tSTRING_CONTENT, "\034", :expr_beg,
                :tSTRING_END,     "\"",   :expr_end)
  end

  def test_yylex_string_double_escape_c_escape
    assert_lex3("\"\\c\\M-a\"",
                nil,
                :tSTRING_BEG,     "\"",   :expr_beg,
                :tSTRING_CONTENT, "\201", :expr_beg,
                :tSTRING_END,     "\"",   :expr_end)
  end

  def test_yylex_string_double_escape_c_question
    assert_lex3("\"\\c?\"", nil, :tSTRING, "\177", :expr_end)
  end

  def test_yylex_string_double_escape_chars
    assert_lex3("\"s\\tri\\ng\"", nil, :tSTRING, "s\tri\ng", :expr_end)
  end

  def test_yylex_string_double_escape_hex
    assert_lex3("\"n = \\x61\\x62\\x63\"", nil, :tSTRING, "n = abc", :expr_end)
  end

  def test_yylex_string_double_escape_octal
    assert_lex3("\"n = \\101\\102\\103\"", nil, :tSTRING, "n = ABC", :expr_end)
  end

  def test_yylex_string_double_escape_octal_fucked
    assert_lex3("\"n = \\444\"", nil, :tSTRING, "n = $", :expr_end)
  end

  def test_yylex_string_double_interp
    assert_lex3("\"blah #x a \#@a b \#$b c \#{3} # \"",
                nil,
                :tSTRING_BEG,     "\"",         :expr_beg,
                :tSTRING_CONTENT, "blah #x a ", :expr_beg,
                :tSTRING_DVAR,    nil,          :expr_beg,
                :tSTRING_CONTENT, "@a b ",      :expr_beg,
                :tSTRING_DVAR,    nil,          :expr_beg,
                :tSTRING_CONTENT, "$b c ",      :expr_beg,
                :tSTRING_DBEG,    nil,          :expr_beg,
                :tSTRING_CONTENT, "3} # ",      :expr_beg,
                :tSTRING_END,     "\"",         :expr_end)
  end

  def test_yylex_string_double_pound_dollar_bad
    skip if Ruby18Parser === lexer.parser

    assert_lex3('"#$%"', nil,

                :tSTRING_BEG,     "\"",  :expr_beg,
                :tSTRING_CONTENT, '#$%', :expr_beg,
                :tSTRING_END,     "\"",  :expr_end)
  end

  def test_yylex_string_double_nested_curlies
    assert_lex3("%{nest{one{two}one}nest}",
                nil,
                :tSTRING_BEG,     "%}",                    :expr_beg,
                :tSTRING_CONTENT, "nest{one{two}one}nest", :expr_beg,
                :tSTRING_END,     "}",                     :expr_end)
  end

  def test_yylex_string_double_no_interp
    assert_lex3("\"# blah\"",      nil, :tSTRING, "# blah",      :expr_end)
    assert_lex3("\"blah # blah\"", nil, :tSTRING, "blah # blah", :expr_end)
  end

  def test_yylex_string_escape_x_single
    assert_lex3("\"\\x0\"", nil, :tSTRING, "\000", :expr_end)
  end

  def test_yylex_string_pct_i
    assert_lex3("%i[s1 s2\ns3]",
                nil,
                :tQSYMBOLS_BEG,   "%i[", :expr_beg,
                :tSTRING_CONTENT, "s1",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s2",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s3",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_END,     nil,   :expr_end)
  end

  def test_yylex_string_pct_I
    assert_lex3("%I[s1 s2\ns3]",
                nil,
                :tSYMBOLS_BEG,    "%I[", :expr_beg,
                :tSTRING_CONTENT, "s1",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s2",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s3",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_END,     nil,   :expr_end)
  end

  def test_yylex_string_pct_i_extra_space
    assert_lex3("%i[ s1 s2\ns3 ]",
                nil,
                :tQSYMBOLS_BEG,   "%i[", :expr_beg,
                :tSTRING_CONTENT, "s1",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s2",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s3",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_END,     nil,   :expr_end)
  end

  def test_yylex_string_pct_I_extra_space
    assert_lex3("%I[ s1 s2\ns3 ]",
                nil,
                :tSYMBOLS_BEG,    "%I[", :expr_beg,
                :tSTRING_CONTENT, "s1",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s2",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s3",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_END,     nil,   :expr_end)
  end

  def test_yylex_string_pct_q
    assert_lex3("%q[s1 s2]",
                nil,
                :tSTRING_BEG,     "%q[",   :expr_beg,
                :tSTRING_CONTENT, "s1 s2", :expr_beg,
                :tSTRING_END,     "]",     :expr_end)
  end

  def test_yylex_string_pct_Q
    assert_lex3("%Q[s1 s2]",
                nil,
                :tSTRING_BEG,     "%Q[",   :expr_beg,
                :tSTRING_CONTENT, "s1 s2", :expr_beg,
                :tSTRING_END,     "]",     :expr_end)
  end

  def test_yylex_string_pct_W
    assert_lex3("%W[s1 s2\ns3]", # TODO: add interpolation to these
                nil,
                :tWORDS_BEG,      "%W[", :expr_beg,
                :tSTRING_CONTENT, "s1",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s2",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s3",  :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_END,     nil,   :expr_end)
  end

  def test_yylex_string_pct_W_bs_nl
    assert_lex3("%W[s1 \\\ns2]", # TODO: add interpolation to these
                nil,
                :tWORDS_BEG,      "%W[",  :expr_beg,
                :tSTRING_CONTENT, "s1",   :expr_beg,
                :tSPACE,          nil,    :expr_beg,
                :tSTRING_CONTENT, "\ns2", :expr_beg,
                :tSPACE,          nil,    :expr_beg,
                :tSTRING_END,     nil,    :expr_end)
  end

  def test_yylex_string_pct_angle
    assert_lex3("%<blah>",
                nil,
                :tSTRING_BEG,     "%>",   :expr_beg,
                :tSTRING_CONTENT, "blah", :expr_beg,
                :tSTRING_END,     ">",    :expr_end)
  end

  def test_yylex_string_pct_other
    assert_lex3("%%blah%",
                nil,
                :tSTRING_BEG,     "%%",   :expr_beg,
                :tSTRING_CONTENT, "blah", :expr_beg,
                :tSTRING_END,     "%",    :expr_end)
  end

  def test_yylex_string_pct_w
    refute_lex("%w[s1 s2 ",
               :tQWORDS_BEG,     "%w[",
               :tSTRING_CONTENT, "s1",
               :tSPACE,          nil,
               :tSTRING_CONTENT, "s2",
               :tSPACE,          nil)
  end

  def test_yylex_string_pct_w_bs_nl
    assert_lex3("%w[s1 \\\ns2]",
                nil,
                :tQWORDS_BEG,     "%w[",  :expr_beg,
                :tSTRING_CONTENT, "s1",   :expr_beg,
                :tSPACE,          nil,    :expr_beg,
                :tSTRING_CONTENT, "\ns2", :expr_beg,
                :tSPACE,          nil,    :expr_beg,
                :tSTRING_END,     nil,    :expr_end)
  end

  def test_yylex_string_pct_w_bs_sp
    assert_lex3("%w[s\\ 1 s\\ 2]",
                nil,
                :tQWORDS_BEG,     "%w[", :expr_beg,
                :tSTRING_CONTENT, "s 1", :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_CONTENT, "s 2", :expr_beg,
                :tSPACE,          nil,   :expr_beg,
                :tSTRING_END,     nil,   :expr_end)
  end

  def test_yylex_string_single
    assert_lex3("'string'", nil, :tSTRING, "string", :expr_end)
  end

  def test_yylex_string_single_escape_chars
    assert_lex3("'s\\tri\\ng'", nil, :tSTRING, "s\\tri\\ng", :expr_end)
  end

  def test_yylex_string_single_nl
    assert_lex3("'blah\\\nblah'", nil, :tSTRING, "blah\\\nblah", :expr_end)
  end

  def test_yylex_symbol
    assert_lex3(":symbol", nil, :tSYMBOL, "symbol", :expr_end)
  end

  def test_yylex_symbol_zero_byte__18
    setup_lexer_class Ruby18Parser

    refute_lex(":\"symbol\0\"", :tSYMBEG, ":")
  end

  def test_yylex_symbol_zero_byte
    assert_lex(":\"symbol\0\"", nil,
                :tSYMBOL,         "symbol\0", :expr_end)
  end

  def test_yylex_symbol_double
    assert_lex3(":\"symbol\"",
                nil,
                :tSYMBOL,         "symbol", :expr_end)
  end

  def test_yylex_symbol_double_interp
    assert_lex3(':"symbol#{1+1}"',
                nil,
                :tSYMBEG,         ":",      :expr_fname,
                :tSTRING_CONTENT, "symbol", :expr_fname,
                :tSTRING_DBEG,    nil,      :expr_fname,
                :tSTRING_CONTENT, "1+1}",   :expr_fname, # HUH? this is BS
                :tSTRING_END,     "\"",     :expr_end)
  end

  def test_yylex_symbol_single
    assert_lex3(":'symbol'",
                nil,
                :tSYMBOL,         "symbol", :expr_end)
  end

  def test_yylex_symbol_single_noninterp
    assert_lex3(':\'symbol#{1+1}\'',
                nil,
                :tSYMBOL,   'symbol#{1+1}', :expr_end)
  end

  def test_yylex_ternary1
    assert_lex3("a ? b : c",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tEH,         "?", :expr_value,
                :tIDENTIFIER, "b", :expr_arg,
                :tCOLON,      ":", :expr_beg,
                :tIDENTIFIER, "c", :expr_arg)

    assert_lex3("a ?bb : c", # GAH! MATZ!!!
                nil,
                :tIDENTIFIER, "a",  :expr_cmdarg,
                :tEH,         "?",  :expr_beg,
                :tIDENTIFIER, "bb", :expr_arg,
                :tCOLON,      ":",  :expr_beg,
                :tIDENTIFIER, "c",  :expr_arg)

    assert_lex3("42 ?",
                nil,
                :tINTEGER, 42,  :expr_end,
                :tEH,      "?", :expr_value)
  end

  def test_yylex_tilde
    assert_lex3("~", nil, :tTILDE, "~", :expr_beg)
  end

  def test_yylex_tilde_unary
    self.lex_state = :expr_fname

    assert_lex3("~@", nil, :tTILDE, "~", :expr_arg)
  end

  def test_yylex_uminus
    assert_lex3("-blah",
                nil,
                :tUMINUS,     "-",    :expr_beg,
                :tIDENTIFIER, "blah", :expr_arg)
  end

  def test_yylex_underscore
    assert_lex3("_var", nil, :tIDENTIFIER, "_var", :expr_cmdarg)
  end

  def test_yylex_underscore_end
    assert_lex3("__END__\n",
                nil,
                RubyLexer::EOF, RubyLexer::EOF, nil)
  end

  def test_yylex_uplus
    assert_lex3("+blah",
                nil,
                :tUPLUS,      "+",    :expr_beg,
                :tIDENTIFIER, "blah", :expr_arg)
  end

  def test_zbug_float_in_decl
    assert_lex3("def initialize(u = 0.0, s = 0.0",
                nil,
                :kDEF,        "def",        :expr_fname,
                :tIDENTIFIER, "initialize", :expr_endfn,
                :tLPAREN2,    "(",          :expr_beg,
                :tIDENTIFIER, "u",          :expr_arg,
                :tEQL,        "=",          :expr_beg,
                :tFLOAT,      0.0,          :expr_end,
                :tCOMMA,      ",",          :expr_beg,
                :tIDENTIFIER, "s",          :expr_arg,
                :tEQL,        "=",          :expr_beg,
                :tFLOAT,      0.0,          :expr_end)
  end

  def test_zbug_id_equals
    assert_lex3("a = 0.0",
                nil,
                :tIDENTIFIER, "a", :expr_cmdarg,
                :tEQL,        "=", :expr_beg,
                :tFLOAT,      0.0, :expr_end)
  end

  def test_zbug_no_spaces_in_decl
    assert_lex3("def initialize(u=0.0,s=0.0",
                nil,
                :kDEF,        "def",        :expr_fname,
                :tIDENTIFIER, "initialize", :expr_endfn,
                :tLPAREN2,    "(",          :expr_beg,
                :tIDENTIFIER, "u",          :expr_arg,
                :tEQL,        "=",          :expr_beg,
                :tFLOAT,      0.0,          :expr_end,
                :tCOMMA,      ",",          :expr_beg,
                :tIDENTIFIER, "s",          :expr_arg,
                :tEQL,        "=",          :expr_beg,
                :tFLOAT,      0.0,          :expr_end)
  end

  def test_pct_w_backslashes
    ["\t", "\n", "\r", "\v", "\f"].each do |char|
      next if !RubyLexer::RUBY19 and char == "\v"

      assert_lex("%w[foo#{char}bar]",
                 s(:array, s(:str, "foo"), s(:str, "bar")),

                 :tQWORDS_BEG,     "%w[", :expr_beg, 0, 0,
                 :tSTRING_CONTENT, "foo", :expr_beg, 0, 0,
                 :tSPACE,          nil,   :expr_beg, 0, 0,
                 :tSTRING_CONTENT, "bar", :expr_beg, 0, 0,
                 :tSPACE,          nil,   :expr_beg, 0, 0,
                 :tSTRING_END,     nil,   :expr_end, 0, 0)
    end
  end

  def test_yylex_sym_quoted
    assert_lex(":'a'",
               s(:lit, :a),

               :tSYMBOL, "a", :expr_end, 0, 0)
  end

  def test_yylex_hash_colon
    assert_lex("{a:1}",
               s(:hash, s(:lit, :a), s(:lit, 1)),

               :tLBRACE, "{", :expr_beg,      0, 1,
               :tLABEL,  "a", :expr_labelarg, 0, 1,
               :tINTEGER, 1,  :expr_end,      0, 1,
               :tRCURLY, "}", :expr_endarg,   0, 0)
  end

  def test_yylex_hash_colon_quoted_22
    setup_lexer_class Ruby22Parser

    assert_lex("{'a':1}",
               s(:hash, s(:lit, :a), s(:lit, 1)),

               :tLBRACE, "{", :expr_beg,    0, 1,
               :tLABEL,  "a", :expr_end,    0, 1,
               :tINTEGER, 1,  :expr_end,    0, 1,
               :tRCURLY, "}", :expr_endarg, 0, 0)
  end

  def test_ruby21_new_numbers
    skip "Don't have imaginary and rational literal lexing yet"

    setup_lexer_class Ruby21Parser

    assert_lex3("10r",      nil, :tRATIONAL, "10r", :expr_end)
    assert_lex3("1.5r",     nil, :tRATIONAL, "1.5r", :expr_end)

    assert_lex3("1i",       nil, :tIMAGINARY, "1i", :expr_end)
    assert_lex3("1+2i",     nil, :tIMAGINARY, "1+2i", :expr_end)
    assert_lex3("1.2+3.4i", nil, :tIMAGINARY, "1.2+3.4i", :expr_end)
    assert_lex3("4r+3i",    nil, :tIMAGINARY, "4r+3i", :expr_end)
    assert_lex3("4r+3ri",   nil, :tIMAGINARY, "4r+3i", :expr_end)

    assert_lex3("4i+3r",    nil, :tIMAGINARY, "4r+3i", :expr_end) # HACK
    assert_lex3("1i+2ri",   nil, :tIMAGINARY, "4r+3i", :expr_end) # HACK

    assert_lex3("1+2ri",    nil, :tIMAGINARY, "1+3ri", :expr_end)
    refute_lex("1+2ir", :tINTEGER, 1)

    flunk
  end
end
