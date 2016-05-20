# encoding: UTF-8

class RubyLexer

  # :stopdoc:
  RUBY19 = "".respond_to? :encoding

  IDENT_CHAR = if RUBY19 then
                 /[\w\u0080-\u{10ffff}]/u
               else
                 /[\w\x80-\xFF]/n
               end

  EOF = :eof_haha!

  # ruby constants for strings (should this be moved somewhere else?)

  STR_FUNC_BORING = 0x00
  STR_FUNC_ESCAPE = 0x01 # TODO: remove and replace with REGEXP
  STR_FUNC_EXPAND = 0x02
  STR_FUNC_REGEXP = 0x04
  STR_FUNC_QWORDS = 0x08
  STR_FUNC_SYMBOL = 0x10
  STR_FUNC_INDENT = 0x20 # <<-HEREDOC

  STR_SQUOTE = STR_FUNC_BORING
  STR_DQUOTE = STR_FUNC_BORING | STR_FUNC_EXPAND
  STR_XQUOTE = STR_FUNC_BORING | STR_FUNC_EXPAND
  STR_REGEXP = STR_FUNC_REGEXP | STR_FUNC_ESCAPE | STR_FUNC_EXPAND
  STR_SSYM   = STR_FUNC_SYMBOL
  STR_DSYM   = STR_FUNC_SYMBOL | STR_FUNC_EXPAND

  ESCAPES = {
    "a"    => "\007",
    "b"    => "\010",
    "e"    => "\033",
    "f"    => "\f",
    "n"    => "\n",
    "r"    => "\r",
    "s"    => " ",
    "t"    => "\t",
    "v"    => "\13",
    "\\"   => '\\',
    "\n"   => "",
    "C-\?" => 127.chr,
    "c\?"  => 127.chr,
  }

  TOKENS = {
    "!"   => :tBANG,
    "!="  => :tNEQ,
    # "!@"  => :tUBANG,
    "!~"  => :tNMATCH,
    ","   => :tCOMMA,
    ".."  => :tDOT2,
    "..." => :tDOT3,
    "="   => :tEQL,
    "=="  => :tEQ,
    "===" => :tEQQ,
    "=>"  => :tASSOC,
    "=~"  => :tMATCH,
    "->"  => :tLAMBDA,
  }

  @@regexp_cache = Hash.new { |h,k| h[k] = Regexp.new(Regexp.escape(k)) }
  @@regexp_cache[nil] = nil

  # :startdoc:

  attr_accessor :lineno # we're bypassing oedipus' lineno handling.
  attr_accessor :brace_nest
  attr_accessor :cmdarg
  attr_accessor :command_start
  attr_accessor :command_state
  attr_accessor :last_state
  attr_accessor :cond
  attr_accessor :extra_lineno

  ##
  # Additional context surrounding tokens that both the lexer and
  # grammar use.

  attr_accessor :lex_state
  attr_accessor :lex_strterm
  attr_accessor :lpar_beg
  attr_accessor :paren_nest
  attr_accessor :parser # HACK for very end of lexer... *sigh*
  attr_accessor :space_seen
  attr_accessor :string_buffer
  attr_accessor :string_nest

  # Last token read via next_token.
  attr_accessor :token

  ##
  # What version of ruby to parse. 18 and 19 are the only valid values
  # currently supported.

  attr_accessor :version

  attr_writer :comments

  def initialize v = 18
    self.version = v

    reset
  end

  def arg_ambiguous
    self.warning("Ambiguous first argument. make sure.")
  end

  def arg_state
    in_arg_state? ? :expr_arg : :expr_beg
  end

  def beginning_of_line?
    ss.bol?
  end
  alias :bol? :beginning_of_line? # to make .rex file more readable

  def comments # TODO: remove this... maybe comment_string + attr_accessor
    c = @comments.join
    @comments.clear
    c
  end

  def end_of_stream?
    ss.eos?
  end

  def expr_dot?
    lex_state == :expr_dot
  end

  def expr_fname?
    lex_state == :expr_fname
  end

  def expr_result token, text
    cond.push false
    cmdarg.push false
    result :expr_beg, token, text
  end

  def heredoc here # TODO: rewrite / remove
    _, eos, func, last_line = here

    indent  = (func & STR_FUNC_INDENT) != 0 ? "[ \t]*" : nil
    expand  = (func & STR_FUNC_EXPAND) != 0
    eos_re  = /#{indent}#{Regexp.escape eos}(\r*\n|\z)/
    err_msg = "can't match #{eos_re.inspect} anywhere in "

    rb_compile_error err_msg if end_of_stream?

    if beginning_of_line? && scan(eos_re) then
      self.lineno += 1
      ss.unread_many last_line # TODO: figure out how to remove this
      return :tSTRING_END, eos
    end

    self.string_buffer = []

    if expand then
      case
      when scan(/#[$@]/) then
        ss.pos -= 1 # FIX omg stupid
        return :tSTRING_DVAR, matched
      when scan(/#[{]/) then
        return :tSTRING_DBEG, matched
      when scan(/#/) then
        string_buffer << '#'
      end

      begin
        c = tokadd_string func, "\n", nil

        rb_compile_error err_msg if
          c == RubyLexer::EOF

        if c != "\n" then
          return :tSTRING_CONTENT, string_buffer.join.delete("\r")
        else
          string_buffer << scan(/\n/)
        end

        rb_compile_error err_msg if end_of_stream?
      end until check(eos_re)
    else
      until check(eos_re) do
        string_buffer << scan(/.*(\n|\z)/)
        rb_compile_error err_msg if end_of_stream?
      end
    end

    self.lex_strterm = [:heredoc, eos, func, last_line]

    return :tSTRING_CONTENT, string_buffer.join.delete("\r")
  end

  def heredoc_identifier # TODO: remove / rewrite
    term, func = nil, STR_FUNC_BORING
    self.string_buffer = []

    case
    when scan(/(-?)([\'\"\`])(.*?)\2/) then
      term = ss[2]
      func |= STR_FUNC_INDENT unless ss[1].empty?
      func |= case term
              when "\'" then
                STR_SQUOTE
              when '"' then
                STR_DQUOTE
              else
                STR_XQUOTE
              end
      string_buffer << ss[3]
    when scan(/-?([\'\"\`])(?!\1*\Z)/) then
      rb_compile_error "unterminated here document identifier"
    when scan(/(-?)(#{IDENT_CHAR}+)/) then
      term = '"'
      func |= STR_DQUOTE
      unless ss[1].empty? then
        func |= STR_FUNC_INDENT
      end
      string_buffer << ss[2]
    else
      return nil
    end

    if scan(/.*\n/) then
      # TODO: think about storing off the char range instead
      line = matched
    else
      line = nil
    end

    self.lex_strterm = [:heredoc, string_buffer.join, func, line]

    if term == '`' then
      result nil, :tXSTRING_BEG, "`"
    else
      result nil, :tSTRING_BEG, "\""
    end
  end

  def in_fname?
    in_lex_state? :expr_fname
  end

  def in_arg_state? # TODO: rename is_after_operator?
    in_lex_state? :expr_fname, :expr_dot
  end

  def in_lex_state?(*states)
    states.include? lex_state
  end

  def int_with_base base
    rb_compile_error "Invalid numeric format" if matched =~ /__/
    return result(:expr_end, :tINTEGER, matched.to_i(base))
  end

  def is_arg?
    in_lex_state? :expr_arg, :expr_cmdarg
  end

  def is_beg?
    in_lex_state? :expr_beg, :expr_value, :expr_mid, :expr_class, :expr_labelarg
  end

  def is_end?
    in_lex_state? :expr_end, :expr_endarg, :expr_endfn
  end

  def ruby22_label?
    ruby22? and is_label_possible?
  end

  def is_label_possible?
    (in_lex_state?(:expr_beg, :expr_endfn) && !command_state) || is_arg?
  end

  def is_label_suffix?
    check(/:(?!:)/)
  end

  def is_space_arg? c = "x"
    is_arg? and space_seen and c !~ /\s/
  end

  def matched
    ss.matched
  end

  def not_end?
    not is_end?
  end

  def process_amper text
    token = if is_arg? && space_seen && !check(/\s/) then
               warning("`&' interpreted as argument prefix")
               :tAMPER
             elsif in_lex_state? :expr_beg, :expr_mid then
               :tAMPER
             else
               :tAMPER2
             end

    return result(:arg_state, token, "&")
  end

  def process_backref text
    token = ss[1].to_sym
    # TODO: can't do lineno hack w/ symbol
    result :expr_end, :tBACK_REF, token
  end

  def process_begin text
    @comments << matched

    unless scan(/.*?\n=end( |\t|\f)*[^\n]*(\n|\z)/m) then
      @comments.clear
      rb_compile_error("embedded document meets end of file")
    end

    @comments << matched
    self.lineno += matched.count("\n")

    nil # TODO
  end

  def process_bracing text
    cond.lexpop
    cmdarg.lexpop

    case matched
    when "}" then
      self.brace_nest -= 1
      self.lex_state   = :expr_endarg

      # TODO
      # if (c == '}') {
      #     if (!brace_nest--) c = tSTRING_DEND;
      # }

      return :tRCURLY, matched
    when "]" then
      self.paren_nest -= 1
      self.lex_state   = :expr_endarg
      return :tRBRACK, matched
    when ")" then
      self.paren_nest -= 1
      self.lex_state   = :expr_endfn
      return :tRPAREN, matched
    else
      raise "Unknown bracing: #{matched.inspect}"
    end
  end

  def process_colon1 text
    # ?: / then / when
    if is_end? || check(/\s/) then
      return result :expr_beg, :tCOLON, text
    end

    case
    when scan(/\'/) then
      string STR_SSYM
    when scan(/\"/) then
      string STR_DSYM
    end

    result :expr_fname, :tSYMBEG, text
  end

  def process_colon2 text
    if is_beg? || in_lex_state?(:expr_class) || is_space_arg? then
      result :expr_beg, :tCOLON3, text
    else
      result :expr_dot, :tCOLON2, text
    end
  end

  def process_curly_brace text
    self.brace_nest += 1
    if lpar_beg && lpar_beg == paren_nest then
      self.lpar_beg = nil
      self.paren_nest -= 1

      return expr_result(:tLAMBEG, "{")
    end

    token = if is_arg? || in_lex_state?(:expr_end, :expr_endfn) then
               :tLCURLY      #  block (primary)
             elsif in_lex_state?(:expr_endarg) then
               :tLBRACE_ARG  #  block (expr)
             else
               :tLBRACE      #  hash
             end

    self.command_start = true unless token == :tLBRACE

    return expr_result(token, "{")
  end

  def process_float text
    rb_compile_error "Invalid numeric format" if text =~ /__/
    return result(:expr_end, :tFLOAT, text.to_f)
  end

  def process_gvar text
    text.lineno = self.lineno
    result(:expr_end, :tGVAR, text)
  end

  def process_gvar_oddity text
    return result :expr_end, "$", "$" if text == "$" # TODO: wtf is this?
    rb_compile_error "#{text.inspect} is not allowed as a global variable name"
  end

  def process_ivar text
    tok_id = text =~ /^@@/ ? :tCVAR : :tIVAR
    text.lineno = self.lineno
    return result(:expr_end, tok_id, text)
  end

  def process_lchevron text
    if (!in_lex_state?(:expr_dot, :expr_class) &&
        !is_end? &&
        (!is_arg? || space_seen)) then
      tok = self.heredoc_identifier
      return tok if tok
    end

    return result(:arg_state, :tLSHFT, "\<\<")
  end

  def process_newline_or_comment text
    c = matched
    hit = false

    if c == '#' then
      ss.pos -= 1

      while scan(/\s*\#.*(\n+|\z)/) do
        hit = true
        self.lineno += matched.lines.to_a.size
        @comments << matched.gsub(/^ +#/, '#').gsub(/^ +$/, '')
      end

      return nil if end_of_stream?
    end

    self.lineno += 1 unless hit

    # Replace a string of newlines with a single one
    self.lineno += matched.lines.to_a.size if scan(/\n+/)

    return if in_lex_state?(:expr_beg, :expr_value, :expr_class,
                            :expr_fname, :expr_dot, :expr_labelarg)

    if scan(/([\ \t\r\f\v]*)\./) then
      self.space_seen = true unless ss[1].empty?

      ss.pos -= 1
      return unless check(/\.\./)
    end

    self.command_start = true

    return result(:expr_beg, :tNL, nil)
  end

  def process_nthref text
    # TODO: can't do lineno hack w/ number
    result :expr_end, :tNTH_REF, ss[1].to_i
  end

  def process_paren text
    token = if ruby18 then
              process_paren18
            else
              process_paren19
            end

    self.paren_nest += 1

    return expr_result(token, "(")
  end

  def process_paren18
    self.command_start = true
    token = :tLPAREN2

    if in_lex_state? :expr_beg, :expr_mid then
      token = :tLPAREN
    elsif space_seen then
      if in_lex_state? :expr_cmdarg then
        token = :tLPAREN_ARG
      elsif in_lex_state? :expr_arg then
        warning "don't put space before argument parentheses"
      end
    else
      # not a ternary -- do nothing?
    end

    token
  end

  def process_paren19
    if is_beg? then
      :tLPAREN
    elsif is_space_arg? then
      :tLPAREN_ARG
    else
      :tLPAREN2 # plain '(' in parse.y
    end
  end

  def process_percent text
    return parse_quote if is_beg?

    return result(:expr_beg, :tOP_ASGN, "%") if scan(/\=/)

    return parse_quote if is_arg? && space_seen && ! check(/\s/)

    return result(:arg_state, :tPERCENT, "%")
  end

  def process_plus_minus text
    sign = matched
    utype, type = if sign == "+" then
                    [:tUPLUS, :tPLUS]
                  else
                    [:tUMINUS, :tMINUS]
                  end

    if in_arg_state? then
      if scan(/@/) then
        return result(:expr_arg, utype, "#{sign}@")
      else
        return result(:expr_arg, type, sign)
      end
    end

    return result(:expr_beg, :tOP_ASGN, sign) if scan(/\=/)

    if (is_beg? || (is_arg? && space_seen && !check(/\s/))) then
      arg_ambiguous if is_arg?

      if check(/\d/) then
        return nil if utype == :tUPLUS
        return result(:expr_beg, :tUMINUS_NUM, sign)
      end

      return result(:expr_beg, utype, sign)
    end

    return result(:expr_beg, type, sign)
  end

  def process_questionmark text
    if is_end? then
      state = ruby18 ? :expr_beg : :expr_value # HACK?
      return result(state, :tEH, "?")
    end

    if end_of_stream? then
      rb_compile_error "incomplete character syntax: parsed #{text.inspect}"
    end

    if check(/\s|\v/) then
      unless is_arg? then
        c2 = { " " => 's',
              "\n" => 'n',
              "\t" => 't',
              "\v" => 'v',
              "\r" => 'r',
              "\f" => 'f' }[matched]

        if c2 then
          warning("invalid character syntax; use ?\\" + c2)
        end
      end

      # ternary
      state = ruby18 ? :expr_beg : :expr_value # HACK?
      return result(state, :tEH, "?")
    elsif check(/\w(?=\w)/) then # ternary, also
      return result(:expr_beg, :tEH, "?")
    end

    c = if scan(/\\/) then
          self.read_escape
        else
          ss.getch
        end

    if version == 18 then
      return result(:expr_end, :tINTEGER, c[0].ord & 0xff)
    else
      return result(:expr_end, :tSTRING, c)
    end
  end

  def process_slash text
    if is_beg? then
      string STR_REGEXP

      return result(nil, :tREGEXP_BEG, "/")
    end

    if scan(/\=/) then
      return result(:expr_beg, :tOP_ASGN, "/")
    end

    if is_arg? && space_seen then
      unless scan(/\s/) then
        arg_ambiguous
        string STR_REGEXP, "/"
        return result(nil, :tREGEXP_BEG, "/")
      end
    end

    return result(:arg_state, :tDIVIDE, "/")
  end

  def process_square_bracket text
    self.paren_nest += 1

    token = nil

    if in_arg_state? then
      case
      when scan(/\]\=/) then
        self.paren_nest -= 1 # HACK? I dunno, or bug in MRI
        return result(:expr_arg, :tASET, "[]=")
      when scan(/\]/) then
        self.paren_nest -= 1 # HACK? I dunno, or bug in MRI
        return result(:expr_arg, :tAREF, "[]")
      else
        rb_compile_error "unexpected '['"
      end
    elsif is_beg? then
      token = :tLBRACK
    elsif is_arg? && space_seen then
      token = :tLBRACK
    else
      token = :tLBRACK2
    end

    return expr_result(token, "[")
  end

  def process_symbol text
    symbol = match[1].gsub(ESC) { unescape $1 }

    rb_compile_error "symbol cannot contain '\\0'" if
      ruby18 && symbol =~ /\0/

    return result(:expr_end, :tSYMBOL, symbol)
  end

  def was_label?
    @was_label = ruby22_label?
    true
  end

  def process_label_or_string text
    if @was_label && text =~ /:$/ then
      @was_label = nil
      return process_label text
    elsif text =~ /:$/ then
      ss.pos -= 1 # put back ":"
      text = text[0..-2]
    end

    result :expr_end, :tSTRING, text[1..-2].gsub(/\\\\/, "\\").gsub(/\\'/, "'")
  end

  def process_label text
    result = process_symbol text
    result[0] = :tLABEL
    result
  end

  def process_token text
    # TODO: make this always return [token, lineno]
    token = self.token = text
    token << matched if scan(/[\!\?](?!=)/)

    tok_id =
      case
      when token =~ /[!?]$/ then
        :tFID
      when in_lex_state?(:expr_fname) && scan(/=(?:(?![~>=])|(?==>))/) then
        # ident=, not =~ => == or followed by =>
        # TODO test lexing of a=>b vs a==>b
        token << matched
        :tIDENTIFIER
      when token =~ /^[A-Z]/ then
        :tCONSTANT
      else
        :tIDENTIFIER
      end

    if !ruby18 and is_label_possible? and is_label_suffix? then
      scan(/:/)
      return result(:expr_labelarg, :tLABEL, [token, self.lineno])
    end

    unless in_lex_state? :expr_dot then
      # See if it is a reserved word.
      keyword = if ruby18 then # REFACTOR need 18/19 lexer subclasses
                  RubyParserStuff::Keyword.keyword18 token
                else
                  RubyParserStuff::Keyword.keyword19 token
                end

      return process_token_keyword keyword if keyword
    end # unless in_lex_state? :expr_dot

    # TODO:
    # if (mb == ENC_CODERANGE_7BIT && lex_state != EXPR_DOT) {

    state = if is_beg? or is_arg? or in_lex_state? :expr_dot then
              command_state ? :expr_cmdarg : :expr_arg
            elsif not ruby18 and in_lex_state? :expr_fname then
              :expr_endfn
            else
              :expr_end
            end

    if not [:expr_dot, :expr_fname].include? last_state and
        self.parser.env[token.to_sym] == :lvar then
      state = :expr_end
    end

    token.lineno = self.lineno # yes, on a string. I know... I know...

    return result(state, tok_id, token)
  end

  def process_token_keyword keyword
    state = keyword.state

    value = [token, self.lineno]

    self.command_start = true if state == :expr_beg and lex_state != :expr_fname

    case
    when lex_state == :expr_fname then
      result(state, keyword.id0, keyword.name)
    when keyword.id0 == :kDO then
      case
      when lpar_beg && lpar_beg == paren_nest then
        self.lpar_beg = nil
        self.paren_nest -= 1
        result(state, :kDO_LAMBDA, value)
      when cond.is_in_state then
        result(state, :kDO_COND, value)
      when cmdarg.is_in_state && lex_state != :expr_cmdarg then
        result(state, :kDO_BLOCK, value)
      when in_lex_state?(:expr_beg, :expr_endarg) then
        result(state, :kDO_BLOCK, value)
      else
        result(state, :kDO, value)
      end
    when in_lex_state?(:expr_beg, :expr_value) then # TODO: :expr_labelarg
      result(state, keyword.id0, value)
    when keyword.id0 != keyword.id1 then
      result(:expr_beg, keyword.id1, value)
    else
      result(state, keyword.id1, value)
    end
  end

  def process_underscore text
    ss.unscan # put back "_"

    if beginning_of_line? && scan(/\__END__(\r?\n|\Z)/) then
      return [RubyLexer::EOF, RubyLexer::EOF]
    elsif scan(/\_\w*/) then
      return process_token matched
    end
  end

  def rb_compile_error msg
    msg += ". near line #{self.lineno}: #{ss.rest[/^.*/].inspect}"
    raise RubyParser::SyntaxError, msg
  end

  def read_escape # TODO: remove / rewrite
    case
    when scan(/\\/) then                  # Backslash
      '\\'
    when scan(/n/) then                   # newline
      "\n"
    when scan(/t/) then                   # horizontal tab
      "\t"
    when scan(/r/) then                   # carriage-return
      "\r"
    when scan(/f/) then                   # form-feed
      "\f"
    when scan(/v/) then                   # vertical tab
      "\13"
    when scan(/a/) then                   # alarm(bell)
      "\007"
    when scan(/e/) then                   # escape
      "\033"
    when scan(/b/) then                   # backspace
      "\010"
    when scan(/s/) then                   # space
      " "
    when scan(/[0-7]{1,3}/) then          # octal constant
      (matched.to_i(8) & 0xFF).chr
    when scan(/x([0-9a-fA-F]{1,2})/) then # hex constant
      ss[1].to_i(16).chr
    when check(/M-\\[\\MCc]/) then
      scan(/M-\\/) # eat it
      c = self.read_escape
      c[0] = (c[0].ord | 0x80).chr
      c
    when scan(/M-(.)/) then
      c = ss[1]
      c[0] = (c[0].ord | 0x80).chr
      c
    when check(/(C-|c)\\[\\MCc]/) then
      scan(/(C-|c)\\/) # eat it
      c = self.read_escape
      c[0] = (c[0].ord & 0x9f).chr
      c
    when scan(/C-\?|c\?/) then
      127.chr
    when scan(/(C-|c)(.)/) then
      c = ss[2]
      c[0] = (c[0].ord & 0x9f).chr
      c
    when scan(/^[89]/i) then # bad octal or hex... MRI ignores them :(
      matched
    when scan(/u([0-9a-fA-F]{2,4}|\{[0-9a-fA-F]{2,6}\})/) then
      [ss[1].delete("{}").to_i(16)].pack("U")
    when scan(/[McCx0-9]/) || end_of_stream? then
      rb_compile_error("Invalid escape character syntax")
    else
      ss.getch
    end
  end

  def regx_options # TODO: rewrite / remove
    good, bad = [], []

    if scan(/[a-z]+/) then
      good, bad = matched.split(//).partition { |s| s =~ /^[ixmonesu]$/ }
    end

    unless bad.empty? then
      rb_compile_error("unknown regexp option%s - %s" %
                       [(bad.size > 1 ? "s" : ""), bad.join.inspect])
    end

    return good.join
  end

  def reset
    self.brace_nest    = 0
    self.command_start = true
    self.comments      = []
    self.lex_state     = nil
    self.lex_strterm   = nil
    self.lineno        = 1
    self.lpar_beg      = nil
    self.paren_nest    = 0
    self.space_seen    = false
    self.string_nest   = 0
    self.token         = nil
    self.extra_lineno  = 0

    self.cmdarg = RubyParserStuff::StackState.new(:cmdarg)
    self.cond   = RubyParserStuff::StackState.new(:cond)
  end

  def result lex_state, token, text # :nodoc:
    lex_state = self.arg_state if lex_state == :arg_state
    self.lex_state = lex_state if lex_state
    [token, text]
  end

  def ruby18
    Ruby18Parser === parser
  end

  def ruby19
    Ruby19Parser === parser
  end

  def scan re
    ss.scan re
  end

  def check re
    ss.check re
  end

  def scanner_class # TODO: design this out of oedipus_lex. or something.
    RPStringScanner
  end

  def space_vs_beginning space_type, beg_type, fallback
    if is_space_arg? check(/./m) then
      warning "`**' interpreted as argument prefix"
      space_type
    elsif is_beg? then
      beg_type
    else
      # TODO: warn_balanced("**", "argument prefix");
      fallback
    end
  end

  def string type, beg = matched, nnd = "\0"
    self.lex_strterm = [:strterm, type, beg, nnd]
  end

  # TODO: consider
  # def src= src
  #   raise "bad src: #{src.inspect}" unless String === src
  #   @src = RPStringScanner.new(src)
  # end

  def tokadd_escape term # TODO: rewrite / remove
    case
    when scan(/\\\n/) then
      # just ignore
    when scan(/\\([0-7]{1,3}|x[0-9a-fA-F]{1,2})/) then
      self.string_buffer << matched
    when scan(/\\([MC]-|c)(?=\\)/) then
      self.string_buffer << matched
      self.tokadd_escape term
    when scan(/\\([MC]-|c)(.)/) then
      self.string_buffer << matched
    when scan(/\\[McCx]/) then
      rb_compile_error "Invalid escape character syntax"
    when scan(/\\(.)/m) then
      self.string_buffer << matched
    else
      rb_compile_error "Invalid escape character syntax"
    end
  end

  def tokadd_string(func, term, paren) # TODO: rewrite / remove
    qwords = (func & STR_FUNC_QWORDS) != 0
    escape = (func & STR_FUNC_ESCAPE) != 0
    expand = (func & STR_FUNC_EXPAND) != 0
    regexp = (func & STR_FUNC_REGEXP) != 0
    symbol = (func & STR_FUNC_SYMBOL) != 0

    paren_re = @@regexp_cache[paren]
    term_re  = @@regexp_cache[term]

    until end_of_stream? do
      c = nil
      handled = true

      case
      when paren_re && scan(paren_re) then
        self.string_nest += 1
      when scan(term_re) then
        if self.string_nest == 0 then
          ss.pos -= 1
          break
        else
          self.string_nest -= 1
        end
      when expand && scan(/#(?=[\$\@\{])/) then
        ss.pos -= 1
        break
      when qwords && scan(/\s/) then
        ss.pos -= 1
        break
      when expand && scan(/#(?!\n)/) then
        # do nothing
      when check(/\\/) then
        case
        when qwords && scan(/\\\n/) then
          string_buffer << "\n"
          next
        when qwords && scan(/\\\s/) then
          c = ' '
        when expand && scan(/\\\n/) then
          next
        when regexp && check(/\\/) then
          self.tokadd_escape term
          next
        when expand && scan(/\\/) then
          c = self.read_escape
        when scan(/\\\n/) then
          # do nothing
        when scan(/\\\\/) then
          string_buffer << '\\' if escape
          c = '\\'
        when scan(/\\/) then
          unless scan(term_re) || paren.nil? || scan(paren_re) then
            string_buffer << "\\"
          end
        else
          handled = false
        end # inner /\\/ case
      else
        handled = false
      end # top case

      unless handled then
        t = Regexp.escape term
        x = Regexp.escape(paren) if paren && paren != "\000"
        re = if qwords then
               if RUBY19 then
                 /[^#{t}#{x}\#\0\\\s]+|./ # |. to pick up whatever
               else
                 /[^#{t}#{x}\#\0\\\s\v]+|./ # argh. 1.8's \s doesn't pick up \v
               end
             else
               /[^#{t}#{x}\#\0\\]+|./
             end

        scan re
        c = matched

        rb_compile_error "symbol cannot contain '\\0'" if symbol && c =~ /\0/
      end # unless handled

      c ||= matched
      string_buffer << c
    end # until

    c ||= matched
    c = RubyLexer::EOF if end_of_stream?

    return c
  end

  def unescape s
    r = ESCAPES[s]

    self.extra_lineno -= 1 if r && s == "n"

    return r if r

    x = case s
        when /^[0-7]{1,3}/ then
          ($&.to_i(8) & 0xFF).chr
        when /^x([0-9a-fA-F]{1,2})/ then
          $1.to_i(16).chr
        when /^M-(.)/ then
          ($1[0].ord | 0x80).chr
        when /^(C-|c)(.)/ then
          ($2[0].ord & 0x9f).chr
        when /^[89a-f]/i then # bad octal or hex... ignore? that's what MRI does :(
          s
        when /^[McCx0-9]/ then
          rb_compile_error("Invalid escape character syntax")
        when /u([0-9a-fA-F]{2,4}|\{[0-9a-fA-F]{2,6}\})/ then
          [$1.delete("{}").to_i(16)].pack("U")
        else
          s
        end
    x.force_encoding "UTF-8" if RUBY19
    x
  end

  def warning s
    # do nothing for now
  end

  def ruby22?
    Ruby22Parser === parser
  end

  def process_string # TODO: rewrite / remove
    token = if lex_strterm[0] == :heredoc then
              self.heredoc lex_strterm
            else
              self.parse_string lex_strterm
            end

    token_type, c = token

    if ruby22? && token_type == :tSTRING_END && ["'", '"'].include?(c) then
      if (([:expr_beg, :expr_endfn].include?(lex_state) &&
           !cond.is_in_state) || is_arg?) &&
          is_label_suffix? then
        scan(/:/)
        token_type = token[0] = :tLABEL_END
      end
    end

    if [:tSTRING_END, :tREGEXP_END, :tLABEL_END].include? token_type then
      self.lex_strterm = nil
      self.lex_state   = (token_type == :tLABEL_END) ? :expr_labelarg : :expr_end
    end

    return token
  end

  def parse_quote # TODO: remove / rewrite
    beg, nnd, short_hand, c = nil, nil, false, nil

    if scan(/[a-z0-9]{1,2}/i) then # Long-hand (e.g. %Q{}).
      rb_compile_error "unknown type of %string" if ss.matched_size == 2
      c, beg, short_hand = matched, ss.getch, false
    else                               # Short-hand (e.g. %{, %., %!, etc)
      c, beg, short_hand = 'Q', ss.getch, true
    end

    if end_of_stream? or c == RubyLexer::EOF or beg == RubyLexer::EOF then
      rb_compile_error "unterminated quoted string meets end of file"
    end

    # Figure nnd-char.  "\0" is special to indicate beg=nnd and that no nesting?
    nnd = { "(" => ")", "[" => "]", "{" => "}", "<" => ">" }[beg]
    nnd, beg = beg, "\0" if nnd.nil?

    token_type, text = nil, "%#{c}#{beg}"
    token_type, string_type = case c
                              when 'Q' then
                                ch = short_hand ? nnd : c + beg
                                text = "%#{ch}"
                                [:tSTRING_BEG,   STR_DQUOTE]
                              when 'q' then
                                [:tSTRING_BEG,   STR_SQUOTE]
                              when 'W' then
                                scan(/\s*/)
                                [:tWORDS_BEG,    STR_DQUOTE | STR_FUNC_QWORDS]
                              when 'w' then
                                scan(/\s*/)
                                [:tQWORDS_BEG,   STR_SQUOTE | STR_FUNC_QWORDS]
                              when 'x' then
                                [:tXSTRING_BEG,  STR_XQUOTE]
                              when 'r' then
                                [:tREGEXP_BEG,   STR_REGEXP]
                              when 's' then
                                self.lex_state  = :expr_fname
                                [:tSYMBEG,       STR_SSYM]
                              when 'I' then
                                scan(/\s*/)
                                [:tSYMBOLS_BEG, STR_DQUOTE | STR_FUNC_QWORDS]
                              when 'i' then
                                scan(/\s*/)
                                [:tQSYMBOLS_BEG, STR_SQUOTE | STR_FUNC_QWORDS]
                              end

    rb_compile_error "Bad %string type. Expected [QqWwIixrs], found '#{c}'." if
      token_type.nil?

    raise "huh" unless string_type

    string string_type, nnd, beg

    return token_type, text
  end

  def parse_string quote # TODO: rewrite / remove
    _, string_type, term, open = quote

    space = false # FIX: remove these
    func = string_type
    paren = open
    term_re = @@regexp_cache[term]

    qwords = (func & STR_FUNC_QWORDS) != 0
    regexp = (func & STR_FUNC_REGEXP) != 0
    expand = (func & STR_FUNC_EXPAND) != 0

    unless func then # nil'ed from qwords below. *sigh*
      return :tSTRING_END, nil
    end

    space = true if qwords and scan(/\s+/)

    if self.string_nest == 0 && scan(/#{term_re}/) then
      if qwords then
        quote[1] = nil
        return :tSPACE, nil
      elsif regexp then
        return :tREGEXP_END, self.regx_options
      else
        return :tSTRING_END, term
      end
    end

    return :tSPACE, nil if space

    self.string_buffer = []

    if expand
      case
      when scan(/#(?=\$(-.|[a-zA-Z_0-9~\*\$\?!@\/\\;,\.=:<>\"\&\`\'+]))/) then
        # TODO: !ISASCII
        # ?! see parser_peek_variable_name
        return :tSTRING_DVAR, nil
      when scan(/#(?=\@\@?[a-zA-Z_])/) then
        # TODO: !ISASCII
        return :tSTRING_DVAR, nil
      when scan(/#[{]/) then
        return :tSTRING_DBEG, nil
      when scan(/#/) then
        string_buffer << '#'
      end
    end

    if tokadd_string(func, term, paren) == RubyLexer::EOF then
      rb_compile_error "unterminated string meets end of file"
    end

    return :tSTRING_CONTENT, string_buffer.join
  end
end

require "ruby_lexer.rex"

if ENV["RP_LINENO_DEBUG"] then
  class RubyLexer
    alias :old_lineno= :lineno=

    def d o
      $stderr.puts o.inspect
    end

    def lineno= n
      self.old_lineno= n
      where = caller.first.split(/:/).first(2).join(":")
      d :lineno => [n, where, ss && ss.rest[0,40]]
    end
  end
end
