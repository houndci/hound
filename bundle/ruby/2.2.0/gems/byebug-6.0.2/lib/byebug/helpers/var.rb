require 'byebug/helpers/eval'

module Byebug
  module Helpers
    #
    # Utilities for variable subcommands
    #
    module VarHelper
      include EvalHelper

      def var_list(ary, binding = context.frame._binding)
        vars = ary.sort.map do |name|
          [name, safe_inspect(silent_eval(name.to_s, binding))]
        end

        puts prv(vars, 'instance')
      end

      def var_global
        globals = global_variables.reject do |v|
          [:$IGNORECASE, :$=, :$KCODE, :$-K, :$binding].include?(v)
        end

        var_list(globals)
      end

      def var_instance(str)
        obj = single_thread_eval(str || 'self')

        var_list(obj.instance_variables, obj.instance_eval { binding })
      end

      def var_local
        locals = context.frame.locals
        cur_self = context.frame._self
        locals[:self] = cur_self unless cur_self.to_s == 'main'
        puts prv(locals.keys.sort.map { |k| [k, locals[k]] }, 'instance')
      end

      def var_args
        args = context.frame.args
        return if args == [[:rest]]

        all_locals = context.frame.locals
        arg_values = args.map { |arg| arg[1] }

        locals = all_locals.select { |k, _| arg_values.include?(k) }
        puts prv(locals.keys.sort.map { |k| [k, locals[k]] }, 'instance')
      end

      private

      def safe_inspect(var)
        var.inspect
      rescue
        safe_to_s(var)
      end

      def safe_to_s(var)
        var.to_s
      rescue
        '*Error in evaluation*'
      end
    end
  end
end
