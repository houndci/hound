# -*- racc -*-

class Ruby21Parser

token kCLASS kMODULE kDEF kUNDEF kBEGIN kRESCUE kENSURE kEND kIF kUNLESS
      kTHEN kELSIF kELSE kCASE kWHEN kWHILE kUNTIL kFOR kBREAK kNEXT
      kREDO kRETRY kIN kDO kDO_COND kDO_BLOCK kDO_LAMBDA kRETURN kYIELD kSUPER
      kSELF kNIL kTRUE kFALSE kAND kOR kNOT kIF_MOD kUNLESS_MOD kWHILE_MOD
      kUNTIL_MOD kRESCUE_MOD kALIAS kDEFINED klBEGIN klEND k__LINE__
      k__FILE__ k__ENCODING__ tIDENTIFIER tFID tGVAR tIVAR tCONSTANT
      tLABEL tCVAR tNTH_REF tBACK_REF tSTRING_CONTENT tINTEGER tFLOAT
      tREGEXP_END tUPLUS tUMINUS tUMINUS_NUM tPOW tCMP tEQ tEQQ tNEQ
      tGEQ tLEQ tANDOP tOROP tMATCH tNMATCH tDOT tDOT2 tDOT3 tAREF
      tASET tLSHFT tRSHFT tCOLON2 tCOLON3 tOP_ASGN tASSOC tLPAREN
      tLPAREN2 tRPAREN tLPAREN_ARG tLBRACK tLBRACK2 tRBRACK tLBRACE
      tLBRACE_ARG tSTAR tSTAR2 tAMPER tAMPER2 tTILDE tPERCENT tDIVIDE
      tPLUS tMINUS tLT tGT tPIPE tBANG tCARET tLCURLY tRCURLY
      tBACK_REF2 tSYMBEG tSTRING_BEG tXSTRING_BEG tREGEXP_BEG
      tWORDS_BEG tQWORDS_BEG tSTRING_DBEG tSTRING_DVAR tSTRING_END
      tSTRING tSYMBOL tNL tEH tCOLON tCOMMA tSPACE tSEMI tLAMBDA
      tLAMBEG tDSTAR tCHAR tSYMBOLS_BEG tQSYMBOLS_BEG tSTRING_DEND tUBANG
      tRATIONAL tIMAGINARY

prechigh
  right    tBANG tTILDE tUPLUS
  right    tPOW
  right    tUMINUS_NUM tUMINUS
  left     tSTAR2 tDIVIDE tPERCENT
  left     tPLUS tMINUS
  left     tLSHFT tRSHFT
  left     tAMPER2
  left     tPIPE tCARET
  left     tGT tGEQ tLT tLEQ
  nonassoc tCMP tEQ tEQQ tNEQ tMATCH tNMATCH
  left     tANDOP
  left     tOROP
  nonassoc tDOT2 tDOT3
  right    tEH tCOLON
  left     kRESCUE_MOD
  right    tEQL tOP_ASGN
  nonassoc kDEFINED
  right    kNOT
  left     kOR kAND
  nonassoc kIF_MOD kUNLESS_MOD kWHILE_MOD kUNTIL_MOD
  nonassoc tLBRACE_ARG
  nonassoc tLOWEST
preclow

rule

         program:   {
                      self.lexer.lex_state = :expr_beg
                    }
                    top_compstmt
                    {
                      result = new_compstmt val
                    }

    top_compstmt: top_stmts opt_terms
                    {
                      result = val[0]
                    }

       top_stmts: none
                | top_stmt
                | top_stmts terms top_stmt
                    {
                      result = self.block_append val[0], val[2]
                    }
                | error top_stmt

        top_stmt: stmt
                    {
                      result = val[0]

                      # TODO: remove once I have more confidence this is fixed
                      # result.each_of_type :call_args do |s|
                      #   debug20 666, s, result
                      # end
                    }
                | klBEGIN
                    {
                      if (self.in_def || self.in_single > 0) then
                        debug20 1
                        yyerror "BEGIN in method"
                      end
                      self.env.extend
                    }
                  tLCURLY top_compstmt tRCURLY
                    {
                      result = new_iter s(:preexe), nil, val[3]
                    }

        bodystmt: compstmt opt_rescue opt_else opt_ensure
                    {
                      result = new_body val
                    }

        compstmt: stmts opt_terms
                    {
                      result = new_compstmt val
                    }

           stmts: none
                | stmt
                | stmts terms stmt
                    {
                      result = self.block_append val[0], val[2]
                    }
                | error stmt
                    {
                      result = val[1]
                      debug20 2, val, result
                    }

            stmt: kALIAS fitem
                    {
                      lexer.lex_state = :expr_fname
                      result = self.lexer.lineno
                    }
                    fitem
                    {
                      result = s(:alias, val[1], val[3]).line(val[2])
                    }
                | kALIAS tGVAR tGVAR
                    {
                      result = s(:valias, val[1].to_sym, val[2].to_sym)
                    }
                | kALIAS tGVAR tBACK_REF
                    {
                      result = s(:valias, val[1].to_sym, :"$#{val[2]}")
                    }
                | kALIAS tGVAR tNTH_REF
                    {
                      yyerror "can't make alias for the number variables"
                    }
                | kUNDEF undef_list
                    {
                      result = val[1]
                    }
                | stmt kIF_MOD expr_value
                    {
                      result = new_if val[2], val[0], nil
                    }
                | stmt kUNLESS_MOD expr_value
                    {
                      result = new_if val[2], nil, val[0]
                    }
                | stmt kWHILE_MOD expr_value
                    {
                      result = new_while val[0], val[2], true
                    }
                | stmt kUNTIL_MOD expr_value
                    {
                      result = new_until val[0], val[2], true
                    }
                | stmt kRESCUE_MOD stmt
                    {
                      result = s(:rescue, val[0], new_resbody(s(:array), val[2]))
                    }
                | klEND tLCURLY compstmt tRCURLY
                    {
                      if (self.in_def || self.in_single > 0) then
                        debug20 3
                        yyerror "END in method; use at_exit"
                      end
                      result = new_iter s(:postexe), 0, val[2]
                    }
                | command_asgn
                | mlhs tEQL command_call
                    {
                      result = new_masgn val[0], val[2], :wrap
                    }
                | var_lhs tOP_ASGN command_call
                    {
                      result = new_op_asgn val
                    }
                | primary_value tLBRACK2 opt_call_args rbracket tOP_ASGN command_call
                    {
                      result = s(:op_asgn1, val[0], val[2], val[4].to_sym, val[5])
                    }
                | primary_value tDOT tIDENTIFIER tOP_ASGN command_call
                    {
                      result = s(:op_asgn, val[0], val[4], val[2].to_sym, val[3].to_sym)
                    }
                | primary_value tDOT tCONSTANT tOP_ASGN command_call
                    {
                      result = s(:op_asgn, val[0], val[4], val[2].to_sym, val[3].to_sym)
                    }
                | primary_value tCOLON2 tCONSTANT tOP_ASGN command_call
                    {
                      result = s(:op_asgn, val[0], val[4], val[2], val[3])
                      debug20 4, val, result
                    }
                | primary_value tCOLON2 tIDENTIFIER tOP_ASGN command_call
                    {
                      result = s(:op_asgn, val[0], val[4], val[2], val[3])
                      debug20 5, val, result
                    }
                | backref tOP_ASGN command_call
                    {
                      self.backref_assign_error val[0]
                    }
                | lhs tEQL mrhs
                    {
                      result = self.node_assign val[0], s(:svalue, val[2])
                    }
                | mlhs tEQL mrhs_arg
                    {
                      result = new_masgn val[0], val[2]
                    }
                | expr

    command_asgn: lhs tEQL command_call
                    {
                      result = self.node_assign val[0], val[2]
                    }
                | lhs tEQL command_asgn
                    {
                      result = self.node_assign val[0], val[2]
                    }

            expr: command_call
                | expr kAND expr
                    {
                      result = logop(:and, val[0], val[2])
                    }
                | expr kOR expr
                    {
                      result = logop(:or, val[0], val[2])
                    }
                | kNOT opt_nl expr
                    {
                      result = s(:call, val[2], :"!")
                    }
                | tBANG command_call
                    {
                      result = s(:call, val[1], :"!")
                    }
                | arg

      expr_value: expr
                    {
                      result = value_expr(val[0])
                    }

    command_call: command
                | block_command

   block_command: block_call
                | block_call dot_or_colon operation2 command_args
                    {
                      result = new_call val[0], val[2].to_sym, val[3]
                    }

 cmd_brace_block: tLBRACE_ARG
                    {
                      self.env.extend(:dynamic)
                      result = self.lexer.lineno
                    }
                    opt_block_param
                    {
                      result = nil # self.env.dynamic.keys
                    }
                    compstmt tRCURLY
                    {
                      result = new_iter nil, val[2], val[4]
                      result.line = val[1]

                      self.env.unextend
                    }

           fcall: operation
                    {
                      result = new_call nil, val[0].to_sym
                    }

         command: fcall command_args =tLOWEST
                    {
                      result = val[0].concat val[1][1..-1] # REFACTOR pattern
                    }
                | fcall command_args cmd_brace_block
                    {
                      result = val[0].concat val[1][1..-1]
                      if val[2] then
                        block_dup_check result, val[2]

                        result, operation = val[2], result
                        result.insert 1, operation
                      end
                    }
                | primary_value tDOT operation2 command_args =tLOWEST
                    {
                      result = new_call val[0], val[2].to_sym, val[3]
                    }
                | primary_value tDOT operation2 command_args cmd_brace_block
                    {
                      recv, _, msg, args, block = val
                      call = new_call recv, msg.to_sym, args

                      block_dup_check call, block

                      block.insert 1, call
                      result = block
                    }
                | primary_value tCOLON2 operation2 command_args =tLOWEST
                    {
                      result = new_call val[0], val[2].to_sym, val[3]
                    }
                | primary_value tCOLON2 operation2 command_args cmd_brace_block
                    {
                      recv, _, msg, args, block = val
                      call = new_call recv, msg.to_sym, args

                      block_dup_check call, block

                      block.insert 1, call
                      result = block
                    }
                | kSUPER command_args
                    {
                      result = new_super val[1]
                    }
                | kYIELD command_args
                    {
                      result = new_yield val[1]
                    }
                | kRETURN call_args
                    {
                      line = val[0].last
                      result = s(:return, ret_args(val[1])).line(line)
                    }
                | kBREAK call_args
                    {
                      line = val[0].last
                      result = s(:break, ret_args(val[1])).line(line)
                    }
                | kNEXT call_args
                    {
                      line = val[0].last
                      result = s(:next, ret_args(val[1])).line(line)
                    }

            mlhs: mlhs_basic
                | tLPAREN mlhs_inner rparen
                    {
                      result = val[1]
                    }

      mlhs_inner: mlhs_basic
                | tLPAREN mlhs_inner rparen
                    {
                      result = s(:masgn, s(:array, val[1]))
                    }

      mlhs_basic: mlhs_head
                    {
                      result = s(:masgn, val[0])
                    }
                | mlhs_head mlhs_item
                    {
                      result = s(:masgn, val[0] << val[1].compact)
                    }
                | mlhs_head tSTAR mlhs_node
                    {
                      result = s(:masgn, val[0] << s(:splat, val[2]))
                    }
                | mlhs_head tSTAR mlhs_node tCOMMA mlhs_post
                    {
                      ary1, _, splat, _, ary2 = val

                      result = list_append ary1, s(:splat, splat)
                      result.concat ary2[1..-1]
                      result = s(:masgn, result)
                    }
                | mlhs_head tSTAR
                    {
                      result = s(:masgn, val[0] << s(:splat))
                    }
                | mlhs_head tSTAR tCOMMA mlhs_post
                    {
                      ary = list_append val[0], s(:splat)
                      ary.concat val[3][1..-1]
                      result = s(:masgn, ary)
                    }
                | tSTAR mlhs_node
                    {
                      result = s(:masgn, s(:array, s(:splat, val[1])))
                    }
                | tSTAR mlhs_node tCOMMA mlhs_post
                    {
                      ary = s(:array, s(:splat, val[1]))
                      ary.concat val[3][1..-1]
                      result = s(:masgn, ary)
                    }
                | tSTAR
                    {
                      result = s(:masgn, s(:array, s(:splat)))
                    }
                | tSTAR tCOMMA mlhs_post
                    {
                      result = s(:masgn, s(:array, s(:splat), *val[2][1..-1]))
                    }

       mlhs_item: mlhs_node
                | tLPAREN mlhs_inner rparen
                    {
                      result = val[1]
                    }

       mlhs_head: mlhs_item tCOMMA
                    {
                      result = s(:array, val[0])
                    }
                | mlhs_head mlhs_item tCOMMA
                    {
                      result = val[0] << val[1].compact
                    }

       mlhs_post: mlhs_item
                    {
                      result = s(:array, val[0])
                    }
                | mlhs_post tCOMMA mlhs_item
                    {
                      result = list_append val[0], val[2]
                    }

       mlhs_node: user_variable
                    {
                      result = self.assignable val[0]
                    }
                | keyword_variable
                    {
                      result = self.assignable val[0]
                    }
                | primary_value tLBRACK2 opt_call_args rbracket
                    {
                      result = self.aryset val[0], val[2]
                    }
                | primary_value tDOT tIDENTIFIER
                    {
                      result = s(:attrasgn, val[0], :"#{val[2]}=")
                    }
                | primary_value tCOLON2 tIDENTIFIER
                    {
                      result = s(:attrasgn, val[0], :"#{val[2]}=")
                    }
                | primary_value tDOT tCONSTANT
                    {
                      result = s(:attrasgn, val[0], :"#{val[2]}=")
                    }
                | primary_value tCOLON2 tCONSTANT
                    {
                      if (self.in_def || self.in_single > 0) then
                        debug20 7
                        yyerror "dynamic constant assignment"
                      end

                      result = s(:const, s(:colon2, val[0], val[2].to_sym), nil)
                    }
                | tCOLON3 tCONSTANT
                    {
                      if (self.in_def || self.in_single > 0) then
                        debug20 8
                        yyerror "dynamic constant assignment"
                      end

                      result = s(:const, nil, s(:colon3, val[1].to_sym))
                    }
                | backref
                    {
                      self.backref_assign_error val[0]
                    }

             lhs: user_variable
                    {
                      result = self.assignable val[0]
                    }
                | keyword_variable
                    {
                      result = self.assignable val[0]
                      debug20 9, val, result
                    }
                | primary_value tLBRACK2 opt_call_args rbracket
                    {
                      result = self.aryset val[0], val[2]
                    }
                | primary_value tDOT tIDENTIFIER # REFACTOR
                    {
                      result = s(:attrasgn, val[0], :"#{val[2]}=")
                    }
                | primary_value tCOLON2 tIDENTIFIER
                    {
                      result = s(:attrasgn, val[0], :"#{val[2]}=")
                    }
                | primary_value tDOT tCONSTANT # REFACTOR?
                    {
                      result = s(:attrasgn, val[0], :"#{val[2]}=")
                    }
                | primary_value tCOLON2 tCONSTANT
                    {
                      if (self.in_def || self.in_single > 0) then
                        debug20 10
                        yyerror "dynamic constant assignment"
                      end

                      result = s(:const, s(:colon2, val[0], val[2].to_sym))
                    }
                | tCOLON3 tCONSTANT
                    {
                      if (self.in_def || self.in_single > 0) then
                        debug20 11
                        yyerror "dynamic constant assignment"
                      end

                      result = s(:const, s(:colon3, val[1].to_sym))
                    }
                | backref
                    {
                      self.backref_assign_error val[0]
                    }

           cname: tIDENTIFIER
                    {
                      yyerror "class/module name must be CONSTANT"
                    }
                | tCONSTANT

           cpath: tCOLON3 cname
                    {
                      result = s(:colon3, val[1].to_sym)
                    }
                | cname
                    {
                      result = val[0].to_sym
                    }
                | primary_value tCOLON2 cname
                    {
                      result = s(:colon2, val[0], val[2].to_sym)
                    }

           fname: tIDENTIFIER | tCONSTANT | tFID
                | op
                    {
                      lexer.lex_state = :expr_end
                      result = val[0]
                    }

                | reswords
                    {
                      lexer.lex_state = :expr_end
                      result = val[0]
                    }

            fsym: fname | symbol

           fitem: fsym
                    {
                      result = s(:lit, val[0].to_sym)
                    }
                | dsym

      undef_list: fitem
                    {
                      result = new_undef val[0]
                    }
                |
                    undef_list tCOMMA
                    {
                      lexer.lex_state = :expr_fname
                    }
                    fitem
                    {
                      result = new_undef val[0], val[3]
                    }

                op: tPIPE    | tCARET  | tAMPER2  | tCMP  | tEQ    | tEQQ
                |   tMATCH   | tNMATCH | tGT      | tGEQ  | tLT    | tLEQ
                |   tNEQ     | tLSHFT  | tRSHFT   | tPLUS | tMINUS | tSTAR2
                |   tSTAR    | tDIVIDE | tPERCENT | tPOW  | tDSTAR | tBANG   | tTILDE
                |   tUPLUS   | tUMINUS | tAREF    | tASET | tBACK_REF2

        reswords: k__LINE__ | k__FILE__ | k__ENCODING__ | klBEGIN | klEND
                | kALIAS    | kAND      | kBEGIN        | kBREAK  | kCASE
                | kCLASS    | kDEF      | kDEFINED      | kDO     | kELSE
                | kELSIF    | kEND      | kENSURE       | kFALSE  | kFOR
                | kIN       | kMODULE   | kNEXT         | kNIL    | kNOT
                | kOR       | kREDO     | kRESCUE       | kRETRY  | kRETURN
                | kSELF     | kSUPER    | kTHEN         | kTRUE   | kUNDEF
                | kWHEN     | kYIELD    | kIF           | kUNLESS | kWHILE
                | kUNTIL

             arg: lhs tEQL arg
                    {
                      result = self.node_assign val[0], val[2]
                    }
                | lhs tEQL arg kRESCUE_MOD arg
                    {
                      result = self.node_assign val[0], s(:rescue, val[2], new_resbody(s(:array), val[4]))
                    }
                | var_lhs tOP_ASGN arg
                    {
                      result = new_op_asgn val
                    }
                | var_lhs tOP_ASGN arg kRESCUE_MOD arg
                    {
                      result = new_op_asgn val
                      result = s(:rescue, result, new_resbody(s(:array), val[4]))
                    }
                | primary_value tLBRACK2 opt_call_args rbracket tOP_ASGN arg
                    {
                      val[2][0] = :arglist if val[2]
                      result = s(:op_asgn1, val[0], val[2], val[4].to_sym, val[5])
                    }
                | primary_value tDOT tIDENTIFIER tOP_ASGN arg
                    {
                      result = s(:op_asgn2, val[0], :"#{val[2]}=", val[3].to_sym, val[4])
                    }
                | primary_value tDOT tCONSTANT tOP_ASGN arg
                    {
                      result = s(:op_asgn2, val[0], :"#{val[2]}=", val[3].to_sym, val[4])
                    }
                | primary_value tCOLON2 tIDENTIFIER tOP_ASGN arg
                    {
                      result = s(:op_asgn, val[0], val[4], val[2].to_sym, val[3].to_sym)
                    }
                | primary_value tCOLON2 tCONSTANT tOP_ASGN arg
                    {
                      yyerror "constant re-assignment"
                    }
                | tCOLON3 tCONSTANT tOP_ASGN arg
                    {
                      yyerror "constant re-assignment"
                    }
                | backref tOP_ASGN arg
                    {
                      self.backref_assign_error val[0]
                    }
                | arg tDOT2 arg
                    {
                      v1, v2 = val[0], val[2]
                      if v1.node_type == :lit and v2.node_type == :lit and Fixnum === v1.last and Fixnum === v2.last then
                        result = s(:lit, (v1.last)..(v2.last))
                      else
                        result = s(:dot2, v1, v2)
                      end
                    }
                | arg tDOT3 arg
                    {
                      v1, v2 = val[0], val[2]
                      if v1.node_type == :lit and v2.node_type == :lit and Fixnum === v1.last and Fixnum === v2.last then
                        result = s(:lit, (v1.last)...(v2.last))
                      else
                        result = s(:dot3, v1, v2)
                      end
                    }
                | arg tPLUS arg
                    {
                      result = new_call val[0], :+, argl(val[2])
                    }
                | arg tMINUS arg
                    {
                      result = new_call val[0], :-, argl(val[2])
                    }
                | arg tSTAR2 arg # TODO: rename
                    {
                      result = new_call val[0], :*, argl(val[2])
                    }
                | arg tDIVIDE arg
                    {
                      result = new_call val[0], :"/", argl(val[2])
                    }
                | arg tPERCENT arg
                    {
                      result = new_call val[0], :"%", argl(val[2])
                    }
                | arg tPOW arg
                    {
                      result = new_call val[0], :**, argl(val[2])
                    }
                | tUMINUS_NUM simple_numeric tPOW arg
                    {
                      result = new_call(new_call(s(:lit, val[1]), :"**", argl(val[3])), :"-@")
                    }
                | tUPLUS arg
                    {
                      result = new_call val[1], :"+@"
                    }
                | tUMINUS arg
                    {
                      result = new_call val[1], :"-@"
                    }
                | arg tPIPE arg
                    {
                      result = new_call val[0], :"|", argl(val[2])
                    }
                | arg tCARET arg
                    {
                      result = new_call val[0], :"^", argl(val[2])
                    }
                | arg tAMPER2 arg
                    {
                      result = new_call val[0], :"&", argl(val[2])
                    }
                | arg tCMP arg
                    {
                      result = new_call val[0], :"<=>", argl(val[2])
                    }
                | arg tGT arg
                    {
                      result = new_call val[0], :">", argl(val[2])
                    }
                | arg tGEQ arg
                    {
                      result = new_call val[0], :">=", argl(val[2])
                    }
                | arg tLT arg
                    {
                      result = new_call val[0], :"<", argl(val[2])
                    }
                | arg tLEQ arg
                    {
                      result = new_call val[0], :"<=", argl(val[2])
                    }
                | arg tEQ arg
                    {
                      result = new_call val[0], :"==", argl(val[2])
                    }
                | arg tEQQ arg
                    {
                      result = new_call val[0], :"===", argl(val[2])
                    }
                | arg tNEQ arg
                    {
                      result = new_call val[0], :"!=", argl(val[2])
                    }
                | arg tMATCH arg
                    {
                      result = self.get_match_node val[0], val[2]
                    }
                | arg tNMATCH arg
                    {
                      result = s(:not, self.get_match_node(val[0], val[2]))
                    }
                | tBANG arg
                    {
                      result = new_call val[1], :"!"
                    }
                | tTILDE arg
                    {
                      result = new_call value_expr(val[1]), :"~"
                    }
                | arg tLSHFT arg
                    {
                      val[0] = value_expr val[0]
                      val[2] = value_expr val[2]
                      result = new_call val[0], :"\<\<", argl(val[2])
                    }
                | arg tRSHFT arg
                    {
                      val[0] = value_expr val[0]
                      val[2] = value_expr val[2]
                      result = new_call val[0], :">>", argl(val[2])
                    }
                | arg tANDOP arg
                    {
                      result = logop(:and, val[0], val[2])
                    }
                | arg tOROP arg
                    {
                      result = logop(:or, val[0], val[2])
                    }
                | kDEFINED opt_nl arg
                    {
                      result = s(:defined, val[2])
                    }
                | arg tEH arg opt_nl tCOLON arg
                    {
                      result = s(:if, val[0], val[2], val[5])
                    }
                | primary

       arg_value: arg
                    {
                      result = value_expr(val[0])
                    }

       aref_args: none
                | args trailer
                    {
                      result = args [val[0]]
                    }
                | args tCOMMA assocs trailer
                    {
                      result = args [val[0], array_to_hash(val[2])]
                    }
                | assocs trailer
                    {
                      result = args [array_to_hash(val[0])]
                    }

      paren_args: tLPAREN2 opt_call_args rparen
                    {
                      result = val[1]
                    }

  opt_paren_args: none
                | paren_args

   opt_call_args: none
                    {
                      result = val[0]
                    }
                | call_args
                    {
                      result = val[0]
                    }
                | args tCOMMA
                    {
                      result = args val
                    }
                | args tCOMMA assocs tCOMMA
                    {
                      result = args [val[0], array_to_hash(val[2])]
                    }
                | assocs tCOMMA
                    {
                      result = args [array_to_hash(val[0])]
                    }

       call_args: command
                    {
                      warning "parenthesize argument(s) for future version"
                      result = call_args val
                    }
                | args opt_block_arg
                    {
                      result = call_args val
                      result = self.arg_blk_pass val[0], val[1]
                    }
                | assocs opt_block_arg
                    {
                      result = call_args [array_to_hash(val[0])]
                      result = self.arg_blk_pass result, val[1]
                    }
                | args tCOMMA assocs opt_block_arg
                    {
                      result = call_args [val[0], array_to_hash(val[2])]
                      result = self.arg_blk_pass result, val[3]
                    }
                | block_arg
                    {
                      result = call_args val
                    }

    command_args:   {
                      result = lexer.cmdarg.stack.dup # TODO: smell?
                      lexer.cmdarg.push true
                    }
                      call_args
                    {
                      lexer.cmdarg.stack.replace val[0]
                      result = val[1]
                    }

       block_arg: tAMPER arg_value
                    {
                      result = s(:block_pass, val[1])
                    }

   opt_block_arg: tCOMMA block_arg
                    {
                      result = val[1]
                    }
                | none

            args: arg_value
                    {
                      result = s(:array, val[0])
                    }
                | tSTAR arg_value
                    {
                      result = s(:array, s(:splat, val[1]))
                    }
                | args tCOMMA arg_value
                    {
                      result = self.list_append val[0], val[2]
                    }
                | args tCOMMA tSTAR arg_value
                    {
                      result = self.list_append val[0], s(:splat, val[3])
                    }

        mrhs_arg: mrhs
                    {
                      result = new_masgn_arg val[0]
                    }
                | arg_value
                    {
                      result = new_masgn_arg val[0], :wrap
                    }

            mrhs: args tCOMMA arg_value
                    {
                      result = val[0] << val[2]
                    }
                | args tCOMMA tSTAR arg_value
                    {
                      result = self.arg_concat val[0], val[3]
                    }
                | tSTAR arg_value
                    {
                      result = s(:splat, val[1])
                    }

         primary: literal
                | strings
                | xstring
                | regexp
                | words
                | qwords
                | symbols
                | qsymbols
                | var_ref
                | backref
                | tFID
                    {
                      result = new_call nil, val[0].to_sym
                    }
                | kBEGIN
                    {
                      result = self.lexer.lineno
                    }
                    bodystmt kEND
                    {
                      unless val[2] then
                        result = s(:nil)
                      else
                        result = s(:begin, val[2])
                      end

                      result.line = val[1]
                    }
                | tLPAREN_ARG rparen
                    {
                      debug20 13, val, result
                    }
                | tLPAREN_ARG expr
                    {
                      lexer.lex_state = :expr_endarg
                    }
                    rparen
                    {
                      warning "(...) interpreted as grouped expression"
                      result = val[1]
                    }
                | tLPAREN compstmt tRPAREN
                    {
                      result = val[1] || s(:nil)
                      result.paren = true
                    }
                | primary_value tCOLON2 tCONSTANT
                    {
                      result = s(:colon2, val[0], val[2].to_sym)
                    }
                | tCOLON3 tCONSTANT
                    {
                      result = s(:colon3, val[1].to_sym)
                    }
                | tLBRACK aref_args tRBRACK
                    {
                      result = val[1] || s(:array)
                      result[0] = :array # aref_args is :args
                    }
                | tLBRACE assoc_list tRCURLY
                    {
                      result = s(:hash, *val[1].values) # TODO: array_to_hash?
                    }
                | kRETURN
                    {
                      result = s(:return)
                    }
                | kYIELD tLPAREN2 call_args rparen
                    {
                      result = new_yield val[2]
                    }
                | kYIELD tLPAREN2 rparen
                    {
                      result = new_yield
                    }
                | kYIELD
                    {
                      result = new_yield
                    }
                | kDEFINED opt_nl tLPAREN2 expr rparen
                    {
                      result = s(:defined, val[3])
                    }
                | kNOT tLPAREN2 expr rparen
                    {
                      result = s(:call, val[2], :"!")
                    }
                | kNOT tLPAREN2 rparen
                    {
                      debug20 14, val, result
                    }
                | fcall brace_block
                    {
                      oper, iter = val[0], val[1]
                      call = oper # FIX
                      iter.insert 1, call
                      result = iter
                      call.line = iter.line
                    }
                | method_call
                | method_call brace_block
                    {
                      call, iter = val[0], val[1]
                      block_dup_check call, iter
                      iter.insert 1, call # FIX
                      result = iter
                    }
                | tLAMBDA lambda
                    {
                      result = val[1] # TODO: fix lineno
                    }
                | kIF expr_value then compstmt if_tail kEND
                    {
                      result = new_if val[1], val[3], val[4]
                    }
                | kUNLESS expr_value then compstmt opt_else kEND
                    {
                      result = new_if val[1], val[4], val[3]
                    }
                | kWHILE
                    {
                      lexer.cond.push true
                    }
                    expr_value do
                    {
                      lexer.cond.pop
                    }
                    compstmt kEND
                    {
                      result = new_while val[5], val[2], true
                    }
                | kUNTIL
                    {
                      lexer.cond.push true
                    }
                    expr_value do
                    {
                      lexer.cond.pop
                    }
                    compstmt kEND
                    {
                      result = new_until val[5], val[2], true
                    }
                | kCASE expr_value opt_terms case_body kEND
                    {
                      (_, line), expr, _, body, _ = val
                      result = new_case expr, body, line
                    }
                | kCASE            opt_terms case_body kEND
                    {
                      (_, line), _, body, _ = val
                      result = new_case nil, body, line
                    }
                | kFOR for_var kIN
                    {
                      lexer.cond.push true
                    }
                    expr_value do
                    {
                      lexer.cond.pop
                    }
                    compstmt kEND
                    {
                      result = new_for val[4], val[1], val[7]
                    }
                | kCLASS
                    {
                      result = self.lexer.lineno
                    }
                    cpath superclass
                    {
                      self.comments.push self.lexer.comments
                      if (self.in_def || self.in_single > 0) then
                        yyerror "class definition in method body"
                      end
                      self.env.extend
                    }
                    bodystmt kEND
                    {
                      result = new_class val
                      self.env.unextend
                      self.lexer.comments # we don't care about comments in the body
                    }
                | kCLASS tLSHFT
                    {
                      result = self.lexer.lineno
                    }
                    expr
                    {
                      result = self.in_def
                      self.in_def = false
                    }
                    term
                    {
                      result = self.in_single
                      self.in_single = 0
                      self.env.extend
                    }
                    bodystmt kEND
                    {
                      result = new_sclass val
                      self.env.unextend
                      self.lexer.comments # we don't care about comments in the body
                    }
                | kMODULE
                    {
                      result = self.lexer.lineno
                    }
                    cpath
                    {
                      self.comments.push self.lexer.comments
                      yyerror "module definition in method body" if
                        self.in_def or self.in_single > 0

                      self.env.extend
                    }
                    bodystmt kEND
                    {
                      result = new_module val
                      self.env.unextend
                      self.lexer.comments # we don't care about comments in the body
                    }
                | kDEF fname
                    {
                      result = [self.in_def, self.lexer.cmdarg.stack.dup]

                      self.comments.push self.lexer.comments
                      self.in_def = true
                      self.env.extend
                      # TODO: local->cmdargs = cmdarg_stack;
                      # TODO: port local_push_gen and local_pop_gen
                      lexer.cmdarg.stack.replace [false]
                    }
                    f_arglist bodystmt kEND
                    {
                      in_def, cmdarg = val[2]

                      result = new_defn val

                      lexer.cmdarg.stack.replace cmdarg
                      self.env.unextend
                      self.in_def = in_def
                      self.lexer.comments # we don't care about comments in the body
                    }
                | kDEF singleton dot_or_colon
                    {
                      self.comments.push self.lexer.comments
                      lexer.lex_state = :expr_fname
                    }
                    fname
                    {
                      self.in_single += 1
                      self.env.extend
                      lexer.lex_state = :expr_end # force for args
                      result = lexer.lineno
                    }
                    f_arglist bodystmt kEND
                    {
                      result = new_defs val
                      result[3].line val[5]

                      self.env.unextend
                      self.in_single -= 1
                      self.lexer.comments # we don't care about comments in the body
                    }
                | kBREAK
                    {
                      result = s(:break)
                    }
                | kNEXT
                    {
                      result = s(:next)
                    }
                | kREDO
                    {
                      result = s(:redo)
                    }
                | kRETRY
                    {
                      result = s(:retry)
                    }

   primary_value: primary
                    {
                      result = value_expr(val[0])
                    }

                    # These are really stupid
         k_begin: kBEGIN
            k_if: kIF
        k_unless: kUNLESS
         k_while: kWHILE
         k_until: kUNTIL
          k_case: kCASE
           k_for: kFOR
         k_class: kCLASS
        k_module: kMODULE
           k_def: kDEF
           k_end: kEND

            then: term
                | kTHEN
                | term kTHEN

              do: term
                | kDO_COND

         if_tail: opt_else
                | kELSIF expr_value then compstmt if_tail
                    {
                      result = s(:if, val[1], val[3], val[4])
                    }

        opt_else: none
                | kELSE compstmt
                    {
                      result = val[1]
                    }

         for_var: lhs
                | mlhs
                    {
                      val[0].delete_at 1 if val[0][1].nil? # HACK
                    }

          f_marg: f_norm_arg
                | tLPAREN f_margs rparen
                    {
                      result = val[1]
                    }

     f_marg_list: f_marg
                    {
                      result = s(:array, val[0])
                    }
                | f_marg_list tCOMMA f_marg
                    {
                      result = list_append val[0], val[2]
                    }

         f_margs: f_marg_list
                    {
                      args, = val

                      result = block_var args
                    }
                | f_marg_list tCOMMA tSTAR f_norm_arg
                    {
                      args, _, _, splat = val

                      result = block_var args, "*#{splat}".to_sym
                    }
                | f_marg_list tCOMMA tSTAR f_norm_arg tCOMMA f_marg_list
                    {
                      args, _, _, splat, _, args2 = val

                      result = block_var args, "*#{splat}".to_sym, args2
                    }
                | f_marg_list tCOMMA tSTAR
                    {
                      args, _, _ = val

                      result = block_var args, :*
                    }
                | f_marg_list tCOMMA tSTAR tCOMMA f_marg_list
                    {
                      args, _, _, _, args2 = val

                      result = block_var args, :*, args2
                      debug20 16, val, result
                    }
                | tSTAR f_norm_arg
                    {
                      _, splat = val

                      result = block_var :"*#{splat}"
                    }
                | tSTAR f_norm_arg tCOMMA f_marg_list
                    {
                      _, splat, _, args = val

                      result = block_var :"*#{splat}", args
                      debug20 17, val, result
                    }
                | tSTAR
                    {
                      result = block_var :*
                      debug20 18, val, result
                    }
                | tSTAR tCOMMA f_marg_list
                    {
                      _, _, args = val

                      result = block_var :*, args
                    }

 block_args_tail: f_block_kwarg tCOMMA f_kwrest opt_f_block_arg
                    {
                      result = call_args val
                    }
                | f_block_kwarg opt_f_block_arg
                    {
                      result = call_args val
                    }
                | f_kwrest opt_f_block_arg
                    {
                      result = call_args val
                    }
                | f_block_arg
                    {
                      result = call_args val
                    }

opt_block_args_tail: tCOMMA block_args_tail
                    {
                      result = args val
                    }
                | none

     block_param: f_arg tCOMMA f_block_optarg tCOMMA f_rest_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_block_optarg tCOMMA f_rest_arg tCOMMA f_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_block_optarg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_block_optarg tCOMMA f_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_rest_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_rest_arg tCOMMA f_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_block_optarg tCOMMA f_rest_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_block_optarg tCOMMA f_rest_arg tCOMMA f_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_block_optarg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_block_optarg tCOMMA f_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_rest_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | f_rest_arg tCOMMA f_arg opt_block_args_tail
                    {
                      result = args val
                    }
                | block_args_tail
                    {
                      result = args val
                    }

 opt_block_param: none { result = 0 }
                | block_param_def

 block_param_def: tPIPE opt_bv_decl tPIPE
                    {
                      result = args val
                    }
                | tOROP
                    {
                      self.lexer.command_start = true
                      result = s(:args)
                    }
                | tPIPE block_param opt_bv_decl tPIPE
                    {
                      result = args val
                    }

     opt_bv_decl: opt_nl
                | opt_nl tSEMI bv_decls opt_nl
                    {
                      result = args val
                    }

        bv_decls: bvar
                    {
                      result = args val
                    }
                | bv_decls tCOMMA bvar
                    {
                      result = args val
                    }

            bvar: tIDENTIFIER
                    {
                      result = s(:shadow, val[0].to_sym)
                    }
                | f_bad_arg

          lambda:   {
                      self.env.extend :dynamic
                      result = self.lexer.lineno

                      result = lexer.lpar_beg
                      lexer.paren_nest += 1
                      lexer.lpar_beg = lexer.paren_nest
                    }
                    f_larglist lambda_body
                    {
                      lpar, args, body = val
                      lexer.lpar_beg = lpar

                      call = new_call nil, :lambda
                      result = new_iter call, args, body
                      self.env.unextend
                    }

     f_larglist: tLPAREN2 f_args opt_bv_decl rparen
                    {
                      result = args val
                    }
                | f_args
                    {
                      result = val[0]
                      result = 0 if result == s(:args)
                    }

     lambda_body: tLAMBEG compstmt tRCURLY
                    {
                      result = val[1]
                    }
                | kDO_LAMBDA compstmt kEND
                    {
                      result = val[1]
                    }

        do_block: kDO_BLOCK
                    {
                      self.env.extend :dynamic
                      result = self.lexer.lineno
                    }
                    opt_block_param
                    {
                      result = nil # self.env.dynamic.keys
                    }
                    compstmt kEND
                    {
                      args   = val[2]
                      body   = val[4]
                      result = new_iter nil, args, body
                      result.line = val[1]

                      self.env.unextend
                    }

      block_call: command do_block
                    {
                      # TODO:
                      ## if (nd_type($1) == NODE_YIELD) {
                      ##     compile_error(PARSER_ARG "block given to yield");

                      syntax_error "Both block arg and actual block given." if
                        val[0].block_pass?

                      val = invert_block_call val if inverted? val

                      result = val[1]
                      result.insert 1, val[0]
                    }
                | block_call dot_or_colon operation2 opt_paren_args
                    {
                      result = new_call val[0], val[2].to_sym, val[3]
                    }
                | block_call dot_or_colon operation2 opt_paren_args brace_block
                    {
                      iter1, _, name, args, iter2 = val

                      call = new_call iter1, name.to_sym, args
                      iter2.insert 1, call

                      result = iter2
                    }
                | block_call dot_or_colon operation2 command_args do_block
                    {
                      iter1, _, name, args, iter2 = val

                      call = new_call iter1, name.to_sym, args
                      iter2.insert 1, call

                      result = iter2
                    }

     method_call: fcall
                    {
                      result = self.lexer.lineno
                    }
                    paren_args
                    {
                      args = self.call_args val[2..-1]
                      result = val[0].concat args[1..-1]
                    }
                | primary_value tDOT operation2 opt_paren_args
                    {
                      result = new_call val[0], val[2].to_sym, val[3]
                    }
                | primary_value tCOLON2 operation2 paren_args
                    {
                      result = new_call val[0], val[2].to_sym, val[3]
                    }
                | primary_value tCOLON2 operation3
                    {
                      result = new_call val[0], val[2].to_sym
                    }
                | primary_value tDOT paren_args
                    {
                      result = new_call val[0], :call, val[2]
                    }
                | primary_value tCOLON2 paren_args
                    {
                      result = new_call val[0], :call, val[2]
                    }
                | kSUPER paren_args
                    {
                      result = new_super val[1]
                    }
                | kSUPER
                    {
                      result = s(:zsuper)
                    }
                | primary_value tLBRACK2 opt_call_args rbracket
                    {
                      result = new_aref val
                    }

     brace_block: tLCURLY
                    {
                      self.env.extend :dynamic
                      result = self.lexer.lineno
                    }
                    opt_block_param
                    {
                      result = nil # self.env.dynamic.keys
                    }
                    compstmt tRCURLY
                    {
                      _, line, args, _, body, _ = val

                      result = new_iter nil, args, body
                      result.line = line

                      self.env.unextend
                    }
                | kDO
                    {
                      self.env.extend :dynamic
                      result = self.lexer.lineno
                    }
                    opt_block_param
                    {
                      result = nil # self.env.dynamic.keys
                    }
                    compstmt kEND
                    {
                      _, line, args, _, body, _ = val

                      result = new_iter nil, args, body
                      result.line = line

                      self.env.unextend
                    }

       case_body: kWHEN
                    {
                      result = self.lexer.lineno
                    }
                    args then compstmt cases
                    {
                      result = new_when(val[2], val[4])
                      result.line = val[1]
                      result << val[5] if val[5]
                    }

           cases: opt_else | case_body

      opt_rescue: kRESCUE exc_list exc_var then compstmt opt_rescue
                    {
                      _, klasses, var, _, body, rest = val

                      klasses ||= s(:array)
                      klasses << node_assign(var, s(:gvar, :"$!")) if var

                      result = new_resbody(klasses, body)
                      result << rest if rest # UGH, rewritten above
                    }
                |
                    {
                      result = nil
                    }

        exc_list: arg_value
                    {
                      result = s(:array, val[0])
                    }
                | mrhs
                | none

         exc_var: tASSOC lhs
                    {
                      result = val[1]
                    }
                | none

      opt_ensure: kENSURE compstmt
                    {
                      _, body = val

                      result = body || s(:nil)
                    }
                | none

         literal: numeric
                    {
                      result = s(:lit, val[0])
                    }
                | symbol
                    {
                      result = s(:lit, val[0])
                    }
                | dsym

         strings: string
                    {
                      val[0] = s(:dstr, val[0].value) if val[0][0] == :evstr
                      result = val[0]
                    }

          string: tCHAR
                    {
                      debug20 23, val, result
                    }
                | string1
                | string string1
                    {
                      result = self.literal_concat val[0], val[1]
                    }

         string1: tSTRING_BEG string_contents tSTRING_END
                    {
                      result = val[1]
                    }
                | tSTRING
                    {
                      result = new_string val
                    }

         xstring: tXSTRING_BEG xstring_contents tSTRING_END
                    {
                      result = new_xstring val[1]
                    }

          regexp: tREGEXP_BEG regexp_contents tREGEXP_END
                    {
                      result = new_regexp val
                    }

           words: tWORDS_BEG tSPACE tSTRING_END
                    {
                      result = s(:array)
                    }
                | tWORDS_BEG word_list tSTRING_END
                    {
                      result = val[1]
                    }

       word_list: none
                    {
                      result = s(:array)
                    }
                | word_list word tSPACE
                    {
                      word = val[1][0] == :evstr ? s(:dstr, "", val[1]) : val[1]
                      result = val[0].dup << word
                    }

            word: string_content
                | word string_content
                    {
                      result = self.literal_concat val[0], val[1]
                    }

         symbols: tSYMBOLS_BEG tSPACE tSTRING_END
                    {
                      result = s(:array)
                    }
                | tSYMBOLS_BEG symbol_list tSTRING_END
                    {
                      result = val[1]
                    }

     symbol_list: none
                    {
                      result = s(:array)
                    }
                | symbol_list word tSPACE
                    {
                      list, sym, _ = val

                      case sym[0]
                      when :dstr then
                        sym[0] = :dsym
                      when :str then
                        sym = s(:lit, sym.last.to_sym)
                      else
                        debug20 24
                        sym = s(:dsym, "", result)
                      end

                      result = list.dup << sym
                    }

          qwords: tQWORDS_BEG tSPACE tSTRING_END
                    {
                      result = s(:array)
                    }
                | tQWORDS_BEG qword_list tSTRING_END
                    {
                      result = val[1]
                    }

        qsymbols: tQSYMBOLS_BEG tSPACE tSTRING_END
                    {
                      result = s(:array)
                    }
                | tQSYMBOLS_BEG qsym_list tSTRING_END
                    {
                      result = val[1]
                    }

      qword_list: none
                    {
                      result = s(:array)
                    }
                | qword_list tSTRING_CONTENT tSPACE
                    {
                      result = val[0].dup << s(:str, val[1])
                    }

       qsym_list: none
                    {
                      result = s(:array)
                    }
                | qsym_list tSTRING_CONTENT tSPACE
                    {
                      result = val[0].dup << s(:lit, val[1].to_sym)
                    }

 string_contents: none
                    {
                      result = s(:str, "")
                    }
                | string_contents string_content
                    {
                      result = literal_concat(val[0], val[1])
                    }

xstring_contents: none
                    {
                      result = nil
                    }
                | xstring_contents string_content
                    {
                      result = literal_concat(val[0], val[1])
                    }

regexp_contents: none
                    {
                      result = nil
                    }
                | regexp_contents string_content
                    {
                      result = literal_concat(val[0], val[1])
                    }

  string_content: tSTRING_CONTENT
                    {
                      result = new_string val
                    }
                | tSTRING_DVAR
                    {
                      result = lexer.lex_strterm

                      lexer.lex_strterm = nil
                      lexer.lex_state = :expr_beg
                    }
                    string_dvar
                    {
                      lexer.lex_strterm = val[1]
                      result = s(:evstr, val[2])
                    }
                | tSTRING_DBEG
                    {
                      result = [lexer.lex_strterm, 
                                lexer.brace_nest, 
                                lexer.string_nest, # TODO: remove
                                lexer.cond.store, 
                                lexer.cmdarg.store,
                                lexer.lex_state,
                               ]

                      lexer.lex_strterm = nil
                      lexer.brace_nest  = 0
                      lexer.string_nest = 0

                      lexer.lex_state   = :expr_beg
                    }
                    compstmt tRCURLY
                    {
                      # TODO: tRCURLY -> tSTRING_END
                      _, memo, stmt, _ = val

                      lex_strterm, brace_nest, string_nest, oldcond, oldcmdarg, oldlex_state = memo

                      lexer.lex_strterm = lex_strterm
                      lexer.brace_nest  = brace_nest
                      lexer.string_nest = string_nest

                      lexer.cond.restore oldcond
                      lexer.cmdarg.restore oldcmdarg

                      lexer.lex_state = oldlex_state

                      case stmt
                      when Sexp then
                        case stmt[0]
                        when :str, :dstr, :evstr then
                          result = stmt
                        else
                          result = s(:evstr, stmt)
                        end
                      when nil then
                        result = s(:evstr)
                      else
                        debug20 25
                        raise "unknown string body: #{stmt.inspect}"
                      end
                    }

     string_dvar: tGVAR { result = s(:gvar, val[0].to_sym) }
                | tIVAR { result = s(:ivar, val[0].to_sym) }
                | tCVAR { result = s(:cvar, val[0].to_sym) }
                | backref

          symbol: tSYMBEG sym
                    {
                      lexer.lex_state = :expr_end
                      result = val[1].to_sym
                    }
                | tSYMBOL
                    {
                      result = val[0].to_sym
                    }

             sym: fname | tIVAR | tGVAR | tCVAR

            dsym: tSYMBEG xstring_contents tSTRING_END
                    {
                      lexer.lex_state = :expr_end
                      result = val[1]

                      result ||= s(:str, "")

                      case result[0]
                      when :dstr then
                        result[0] = :dsym
                      when :str then
                        result = s(:lit, result.last.to_sym)
                      when :evstr then
                        result = s(:dsym, "", result)
                      else
                        debug20 26, val, result
                      end
                    }

         numeric: simple_numeric
                | tUMINUS_NUM simple_numeric
                    {
                      result = -val[1] # TODO: pt_testcase
                    }

  simple_numeric: tINTEGER
                | tFLOAT
                | tRATIONAL
                | tIMAGINARY

   user_variable: tIDENTIFIER
                | tIVAR
                | tGVAR
                | tCONSTANT
                | tCVAR

keyword_variable: kNIL      { result = s(:nil)   }
                | kSELF     { result = s(:self)  }
                | kTRUE     { result = s(:true)  }
                | kFALSE    { result = s(:false) }
                | k__FILE__ { result = s(:str, self.file) }
                | k__LINE__ { result = s(:lit, lexer.lineno) }
                | k__ENCODING__
                    {
                      result =
                        if defined? Encoding then
                          s(:colon2, s(:const, :Encoding), :UTF_8)
                        else
                          s(:str, "Unsupported!")
                        end
                    }

         var_ref: user_variable
                    {
                      var = val[0]
                      result = Sexp === var ? var : self.gettable(var)
                    }
                | keyword_variable
                    {
                      var = val[0]
                      result = Sexp === var ? var : self.gettable(var)
                    }

         var_lhs: user_variable
                    {
                      result = self.assignable val[0]
                    }
                | keyword_variable
                    {
                      result = self.assignable val[0]
                      debug20 29, val, result
                    }

         backref: tNTH_REF  { result = s(:nth_ref,  val[0]) }
                | tBACK_REF { result = s(:back_ref, val[0]) }

      superclass: term
                    {
                      result = nil
                    }
                | tLT
                    {
                      lexer.lex_state = :expr_beg
                    }
                    expr_value term
                    {
                      result = val[2]
                    }
                | error term
                    {
                      yyerrok
                      result = nil
                      debug20 30, val, result
                    }

       f_arglist: tLPAREN2 f_args rparen
                    {
                      result = val[1]
                      self.lexer.lex_state = :expr_beg
                      self.lexer.command_start = true
                      # TODO:
                      # $<num>$ = parser->parser_in_kwarg;
                      # parser->parser_in_kwarg = 1;
                    }
                | f_args term
                    {
                      # TODO: parser->parser_in_kwarg = $<num>1;
                      result = val[0]
                      self.lexer.lex_state = :expr_beg
                      self.lexer.command_start = true
                    }

       args_tail: f_kwarg tCOMMA f_kwrest opt_f_block_arg
                    {
                      result = args val
                    }
		| f_kwarg opt_f_block_arg
                    {
                      result = args val
                    }
		| f_kwrest opt_f_block_arg
                    {
                      result = args val
                    }
		| f_block_arg

   opt_args_tail: tCOMMA args_tail
                    {
                      result = val[1]
                    }
                |
                    {
                      result = nil
                    }

          f_args: f_arg tCOMMA f_optarg tCOMMA f_rest_arg opt_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_optarg tCOMMA f_rest_arg tCOMMA f_arg opt_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_optarg              opt_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_optarg tCOMMA f_arg opt_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA            f_rest_arg opt_args_tail
                    {
                      result = args val
                    }
                | f_arg tCOMMA f_rest_arg tCOMMA f_arg opt_args_tail
                    {
                      result = args val
                    }
                | f_arg                             opt_args_tail
                    {
                      result = args val
                    }
                |           f_optarg tCOMMA f_rest_arg opt_args_tail
                    {
                      result = args val
                    }
                | f_optarg tCOMMA f_rest_arg tCOMMA f_arg opt_args_tail
                    {
                      result = args val
                    }
                |           f_optarg                opt_args_tail
                    {
                      result = args val
                    }
                | f_optarg tCOMMA f_arg opt_args_tail
                    {
                      result = args val
                    }
                |                        f_rest_arg opt_args_tail
                    {
                      result = args val
                    }
                |           f_rest_arg tCOMMA f_arg opt_args_tail
                    {
                      result = args val
                    }
                |                                       args_tail
                    {
                      result = args val
                    }
                |
                    {
                      result = args val
                    }

       f_bad_arg: tCONSTANT
                    {
                      yyerror "formal argument cannot be a constant"
                    }
                | tIVAR
                    {
                      yyerror "formal argument cannot be an instance variable"
                    }
                | tGVAR
                    {
                      yyerror "formal argument cannot be a global variable"
                    }
                | tCVAR
                    {
                      yyerror "formal argument cannot be a class variable"
                    }

      f_norm_arg: f_bad_arg
                | tIDENTIFIER
                    {
                      identifier = val[0].to_sym
                      self.env[identifier] = :lvar

                      result = identifier
                    }

      f_arg_item: f_norm_arg
                | tLPAREN f_margs rparen
                    {
                      result = val[1]
                    }

           f_arg: f_arg_item
                    {
                      case val[0]
                      when Symbol then
                        result = s(:args)
                        result << val[0]
                      when Sexp then
                        result = val[0]
                      else
                        debug20 32
                        raise "Unknown f_arg type: #{val.inspect}"
                      end
                    }
                | f_arg tCOMMA f_arg_item
                    {
                      list, _, item = val

                      if list.sexp_type == :args then
                        result = list
                      else
                        result = s(:args, list)
                      end

                      result << item
                    }

         f_label: tLABEL

            f_kw: f_label arg_value
                    {
                      # TODO: call_args
                      label, _ = val[0] # TODO: fix lineno?
                      identifier = label.to_sym
                      self.env[identifier] = :lvar

                      result = s(:array, s(:kwarg, identifier, val[1]))
                    }
                | f_label
                    {
                      label, _ = val[0] # TODO: fix lineno?
                      identifier = label.to_sym
                      self.env[identifier] = :lvar

                      result = s(:array, s(:kwarg, identifier))
                    }

      f_block_kw: f_label primary_value
                    {
                      # TODO: call_args
                      label, _ = val[0] # TODO: fix lineno?
                      identifier = label.to_sym
                      self.env[identifier] = :lvar

                      result = s(:array, s(:kwarg, identifier, val[1]))
                    }
                | f_label
                    {
                      label, _ = val[0] # TODO: fix lineno?
                      identifier = label.to_sym
                      self.env[identifier] = :lvar

                      result = s(:array, s(:kwarg, identifier))
                    }

   f_block_kwarg: f_block_kw
                | f_block_kwarg tCOMMA f_block_kw
                    {
                      list, _, item = val
                      result = list << item.last
                    }

         f_kwarg: f_kw
                | f_kwarg tCOMMA f_kw
                    {
                      result = args val
                    }

     kwrest_mark: tPOW
                | tDSTAR

        f_kwrest: kwrest_mark tIDENTIFIER
                    {
                      result = :"**#{val[1]}"
                    }
                | kwrest_mark
                    {
                      debug20 36, val, result
                    }

           f_opt: f_norm_arg tEQL arg_value
                    {
                      result = self.assignable val[0], val[2]
                      # TODO: detect duplicate names
                    }

     f_block_opt: f_norm_arg tEQL primary_value
                    {
                      result = self.assignable val[0], val[2]
                    }

  f_block_optarg: f_block_opt
                    {
                      result = s(:block, val[0])
                    }
                | f_block_optarg tCOMMA f_block_opt
                    {
                      result = val[0]
                      result << val[2]
                    }

        f_optarg: f_opt
                    {
                      result = s(:block, val[0])
                    }
                | f_optarg tCOMMA f_opt
                    {
                      result = self.block_append val[0], val[2]
                    }

    restarg_mark: tSTAR2 | tSTAR

      f_rest_arg: restarg_mark tIDENTIFIER
                    {
                      # TODO: differs from parse.y - needs tests
                      name = val[1].to_sym
                      self.assignable name
                      result = :"*#{name}"
                    }
                | restarg_mark
                    {
                      name = :"*"
                      self.env[name] = :lvar
                      result = name
                    }

     blkarg_mark: tAMPER2 | tAMPER

     f_block_arg: blkarg_mark tIDENTIFIER
                    {
                      identifier = val[1].to_sym

                      self.env[identifier] = :lvar
                      result = "&#{identifier}".to_sym
                    }

 opt_f_block_arg: tCOMMA f_block_arg
                    {
                      result = val[1]
                    }
                |
                    {
                      result = nil
                    }

       singleton: var_ref
                | tLPAREN2
                    {
                      lexer.lex_state = :expr_beg
                    }
                    expr rparen
                    {
                      result = val[2]
                      yyerror "Can't define single method for literals." if
                        result[0] == :lit
                    }

      assoc_list: none # [!nil]
                    {
                      result = s(:array)
                    }
                | assocs trailer # [!nil]
                    {
                      result = val[0]
                    }

          assocs: assoc
                | assocs tCOMMA assoc
                    {
                      list = val[0].dup
                      more = val[2][1..-1]
                      list.push(*more) unless more.empty?
                      result = list
                      result[0] = :hash
                      # TODO: shouldn't this be a hash?
                    }

           assoc: arg_value tASSOC arg_value
                    {
                      result = s(:array, val[0], val[2])
                    }
                | tLABEL arg_value
                    {
                      result = s(:array, s(:lit, val[0][0].to_sym), val[1])
                    }
                | tDSTAR arg_value
                    {
                      result = s(:array, s(:kwsplat, val[1]))
                    }

       operation: tIDENTIFIER | tCONSTANT | tFID
      operation2: tIDENTIFIER | tCONSTANT | tFID | op
      operation3: tIDENTIFIER | tFID | op
    dot_or_colon: tDOT | tCOLON2
       opt_terms:  | terms
          opt_nl:  | tNL
          rparen: opt_nl tRPAREN
        rbracket: opt_nl tRBRACK
         trailer:  | tNL | tCOMMA

            term: tSEMI { yyerrok }
                | tNL

           terms: term
                | terms tSEMI { yyerrok }

            none: { result = nil; }
end

---- inner

require "ruby_lexer"
require "ruby_parser_extras"

# :stopdoc:

# Local Variables: **
# racc-token-length-max:14 **
# End: **
