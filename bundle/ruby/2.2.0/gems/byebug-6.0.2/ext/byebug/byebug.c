#include <byebug.h>

static VALUE mByebug;   /* Ruby Byebug Module object */

static VALUE tracing = Qfalse;
static VALUE post_mortem = Qfalse;
static VALUE verbose = Qfalse;

static VALUE catchpoints = Qnil;
static VALUE breakpoints = Qnil;
static VALUE tracepoints = Qnil;

static VALUE raised_exception = Qnil;

static ID idPuts;

/* Hash table with active threads and their associated contexts */
VALUE threads = Qnil;

/*
 *  call-seq:
 *    Byebug.breakpoints -> array
 *
 *  Returns an array of breakpoints.
 */
static VALUE
Breakpoints(VALUE self)
{
  UNUSED(self);

  if (NIL_P(breakpoints))
    breakpoints = rb_ary_new();

  return breakpoints;
}

/*
 *  call-seq:
 *    Byebug.catchpoints -> array
 *
 *  Returns an array of catchpoints.
 */
static VALUE
Catchpoints(VALUE self)
{
  UNUSED(self);

  return catchpoints;
}

/*
 *  call-seq:
 *    Byebug.raised_exception -> exception
 *
 *  Returns raised exception when in post_mortem mode.
 */
static VALUE
Raised_exception(VALUE self)
{
  UNUSED(self);

  return raised_exception;
}

#define IS_STARTED  (catchpoints != Qnil)
static void
check_started()
{
  if (!IS_STARTED)
  {
    rb_raise(rb_eRuntimeError, "Byebug is not started yet.");
  }
}

static void
trace_print(rb_trace_arg_t * trace_arg, debug_context_t * dc,
            const char *file_filter, const char *debug_msg)
{
  char *fullpath = NULL;
  const char *basename;
  int filtered = 0;
  const char *event = rb_id2name(SYM2ID(rb_tracearg_event(trace_arg)));

  VALUE rb_path = rb_tracearg_path(trace_arg);
  const char *path = NIL_P(rb_path) ? "" : RSTRING_PTR(rb_path);

  int line = NUM2INT(rb_tracearg_lineno(trace_arg));

  VALUE rb_mid = rb_tracearg_method_id(trace_arg);
  const char *mid = NIL_P(rb_mid) ? "(top level)" : rb_id2name(SYM2ID(rb_mid));

  VALUE rb_cl = rb_tracearg_defined_class(trace_arg);
  VALUE rb_cl_name = NIL_P(rb_cl) ? rb_cl : rb_mod_name(rb_cl);
  const char *defined_class = NIL_P(rb_cl_name) ? "" : RSTRING_PTR(rb_cl_name);

  if (!trace_arg)
    return;

  if (file_filter)
  {
#ifndef _WIN32
    fullpath = realpath(path, NULL);
#endif
    basename = fullpath ? strrchr(fullpath, '/') : path;

    if (!basename || strncmp(basename + 1, file_filter, strlen(file_filter)))
      filtered = 1;

#ifndef _WIN32
    free(fullpath);
#endif
  }

  if (!filtered)
  {
    if (debug_msg)
      rb_funcall(mByebug, idPuts, 1,
                 rb_sprintf("[#%d] %s\n", dc->thnum, debug_msg));
    else
      rb_funcall(mByebug, idPuts, 1,
                 rb_sprintf("%*s [#%d] %s@%s:%d %s#%s\n", dc->calced_stack_size,
                            "", dc->thnum, event, path, line, defined_class,
                            mid));
  }
}

static void
cleanup(debug_context_t * dc)
{
  dc->stop_reason = CTX_STOP_NONE;

  release_lock();
}

#define EVENT_TEARDOWN cleanup(dc);

#define EVENT_SETUP                                     \
  debug_context_t *dc;                                  \
  VALUE context;                                        \
  rb_trace_arg_t *trace_arg;                            \
                                                        \
  UNUSED(data);                                         \
                                                        \
  if (!is_living_thread(rb_thread_current()))           \
    return;                                             \
                                                        \
  thread_context_lookup(rb_thread_current(), &context); \
  Data_Get_Struct(context, debug_context_t, dc);        \
                                                        \
  if (CTX_FL_TEST(dc, CTX_FL_IGNORE))                   \
    return;                                             \
                                                        \
  acquire_lock(dc);                                     \
                                                        \
  trace_arg = rb_tracearg_from_tracepoint(trace_point); \
  if (verbose == Qtrue)                                 \
    trace_print(trace_arg, dc, 0, 0);                   \


/* Functions that return control to byebug after the different events */

static VALUE
call_at(VALUE context_obj, debug_context_t * dc, ID mid, int argc, VALUE a0,
        VALUE a1)
{
  struct call_with_inspection_data cwi;
  VALUE argv[2];

  argv[0] = a0;
  argv[1] = a1;

  cwi.dc = dc;
  cwi.context_obj = context_obj;
  cwi.id = mid;
  cwi.argc = argc;
  cwi.argv = &argv[0];

  return call_with_debug_inspector(&cwi);
}

static VALUE
call_at_line(VALUE context_obj, debug_context_t * dc, VALUE file, VALUE line)
{
  return call_at(context_obj, dc, rb_intern("at_line"), 2, file, line);
}

static VALUE
call_at_tracing(VALUE context_obj, debug_context_t * dc, VALUE file, VALUE line)
{
  return call_at(context_obj, dc, rb_intern("at_tracing"), 2, file, line);
}

static VALUE
call_at_breakpoint(VALUE context_obj, debug_context_t * dc, VALUE breakpoint)
{
  dc->stop_reason = CTX_STOP_BREAKPOINT;
  return call_at(context_obj, dc, rb_intern("at_breakpoint"), 1, breakpoint, 0);
}

static VALUE
call_at_catchpoint(VALUE context_obj, debug_context_t * dc, VALUE exp)
{
  dc->stop_reason = CTX_STOP_CATCHPOINT;
  return call_at(context_obj, dc, rb_intern("at_catchpoint"), 1, exp, 0);
}

static VALUE
call_at_return(VALUE context_obj, debug_context_t * dc, VALUE file, VALUE line)
{
  dc->stop_reason = CTX_STOP_BREAKPOINT;
  return call_at(context_obj, dc, rb_intern("at_return"), 2, file, line);
}

static void
call_at_line_check(VALUE context_obj, debug_context_t * dc, VALUE breakpoint,
                   VALUE file, VALUE line)
{
  dc->stop_reason = CTX_STOP_STEP;

  if (breakpoint != Qnil)
    call_at_breakpoint(context_obj, dc, breakpoint);

  reset_stepping_stop_points(dc);
  call_at_line(context_obj, dc, file, line);
}


/* TracePoint API event handlers */

static void
line_event(VALUE trace_point, void *data)
{
  VALUE brkpnt, file, line, binding;

  EVENT_SETUP;

  file = rb_tracearg_path(trace_arg);
  line = rb_tracearg_lineno(trace_arg);
  binding = rb_tracearg_binding(trace_arg);

  if (RTEST(tracing))
    call_at_tracing(context, dc, file, line);

  if (!CTX_FL_TEST(dc, CTX_FL_IGNORE_STEPS))
    dc->steps = dc->steps <= 0 ? -1 : dc->steps - 1;

  if (dc->calced_stack_size <= dc->dest_frame)
  {
    dc->dest_frame = dc->calced_stack_size;
    CTX_FL_UNSET(dc, CTX_FL_IGNORE_STEPS);

    dc->lines = dc->lines <= 0 ? -1 : dc->lines - 1;
  }

  if (dc->steps == 0 || dc->lines == 0)
    call_at_line_check(context, dc, Qnil, file, line);

  brkpnt = Qnil;

  if (!NIL_P(breakpoints))
    brkpnt = find_breakpoint_by_pos(breakpoints, file, line, binding);

  if (!NIL_P(brkpnt))
    call_at_line_check(context, dc, brkpnt, file, line);

  EVENT_TEARDOWN;
}

static void
call_event(VALUE trace_point, void *data)
{
  VALUE brkpnt, klass, msym, mid, binding, self, file, line;

  EVENT_SETUP;

  if (dc->calced_stack_size <= dc->dest_frame)
    CTX_FL_UNSET(dc, CTX_FL_IGNORE_STEPS);

  dc->calced_stack_size++;

  dc->steps_out = dc->steps_out <= 0 ? -1 : dc->steps_out + 1;

  /* nil method_id means we are at top level so there can't be a method
   * breakpoint here. Just leave then. */
  msym = rb_tracearg_method_id(trace_arg);
  if (NIL_P(msym))
  {
    EVENT_TEARDOWN;
    return;
  }

  mid = SYM2ID(msym);
  klass = rb_tracearg_defined_class(trace_arg);
  binding = rb_tracearg_binding(trace_arg);
  self = rb_tracearg_self(trace_arg);
  file = rb_tracearg_path(trace_arg);
  line = rb_tracearg_lineno(trace_arg);

  brkpnt = Qnil;

  if (!NIL_P(breakpoints))
    brkpnt = find_breakpoint_by_method(breakpoints, klass, mid, binding, self);

  if (!NIL_P(brkpnt))
  {
    call_at_breakpoint(context, dc, brkpnt);
    call_at_line(context, dc, file, line);
  }

  EVENT_TEARDOWN;
}

static void
return_event(VALUE trace_point, void *data)
{
  EVENT_SETUP;

  dc->calced_stack_size--;

  if (dc->steps_out == 1)
    dc->steps = 1;
  else if ((dc->steps_out == 0) && (CTX_FL_TEST(dc, CTX_FL_STOP_ON_RET)))
  {
    VALUE file, line;

    reset_stepping_stop_points(dc);
    file = rb_tracearg_path(trace_arg);
    line = rb_tracearg_lineno(trace_arg);
    call_at_return(context, dc, file, line);
  }

  dc->steps_out = dc->steps_out <= 0 ? -1 : dc->steps_out - 1;

  EVENT_TEARDOWN;
}

static void
raw_call_event(VALUE trace_point, void *data)
{
  EVENT_SETUP;

  dc->calced_stack_size++;

  EVENT_TEARDOWN;
}

static void
raw_return_event(VALUE trace_point, void *data)
{
  EVENT_SETUP;

  dc->calced_stack_size--;

  EVENT_TEARDOWN;
}

static void
raise_event(VALUE trace_point, void *data)
{
  VALUE expn_class, ancestors, path, lineno, pm_context;
  int i;
  debug_context_t *new_dc;

  EVENT_SETUP;

  path = rb_tracearg_path(trace_arg);
  lineno = rb_tracearg_lineno(trace_arg);
  raised_exception = rb_tracearg_raised_exception(trace_arg);

  if (post_mortem == Qtrue)
  {
    pm_context = context_dup(dc);
    rb_ivar_set(raised_exception, rb_intern("@__bb_context"), pm_context);

    Data_Get_Struct(pm_context, debug_context_t, new_dc);
    rb_debug_inspector_open(context_backtrace_set, (void *)new_dc);
  }

  if (catchpoints == Qnil || dc->calced_stack_size == 0
      || RHASH_TBL(catchpoints)->num_entries == 0)
  {
    EVENT_TEARDOWN;
    return;
  }

  expn_class = rb_obj_class(raised_exception);
  ancestors = rb_mod_ancestors(expn_class);
  for (i = 0; i < RARRAY_LENINT(ancestors); i++)
  {
    VALUE ancestor_class, module_name, hit_count;

    ancestor_class = rb_ary_entry(ancestors, i);
    module_name = rb_mod_name(ancestor_class);
    hit_count = rb_hash_aref(catchpoints, module_name);

    /* increment exception */
    if (hit_count != Qnil)
    {
      rb_hash_aset(catchpoints, module_name, INT2FIX(FIX2INT(hit_count) + 1));
      call_at_catchpoint(context, dc, raised_exception);
      call_at_line(context, dc, path, lineno);
      break;
    }
  }

  EVENT_TEARDOWN;
}


/* Setup TracePoint functionality */

static void
register_tracepoints(VALUE self)
{
  int i;
  VALUE traces = tracepoints;

  UNUSED(self);

  if (NIL_P(traces))
  {
    int line_msk = RUBY_EVENT_LINE;
    int call_msk = RUBY_EVENT_CALL;
    int ret_msk = RUBY_EVENT_RETURN | RUBY_EVENT_B_RETURN | RUBY_EVENT_END;
    int raw_call_msk = RUBY_EVENT_C_CALL | RUBY_EVENT_B_CALL | RUBY_EVENT_CLASS;
    int raw_ret_msk = RUBY_EVENT_C_RETURN;
    int raise_msk = RUBY_EVENT_RAISE;

    VALUE tpLine = rb_tracepoint_new(Qnil, line_msk, line_event, 0);
    VALUE tpCall = rb_tracepoint_new(Qnil, call_msk, call_event, 0);
    VALUE tpReturn = rb_tracepoint_new(Qnil, ret_msk, return_event, 0);
    VALUE tpCCall = rb_tracepoint_new(Qnil, raw_call_msk, raw_call_event, 0);
    VALUE tpCReturn = rb_tracepoint_new(Qnil, raw_ret_msk, raw_return_event, 0);
    VALUE tpRaise = rb_tracepoint_new(Qnil, raise_msk, raise_event, 0);

    traces = rb_ary_new();
    rb_ary_push(traces, tpLine);
    rb_ary_push(traces, tpCall);
    rb_ary_push(traces, tpReturn);
    rb_ary_push(traces, tpCCall);
    rb_ary_push(traces, tpCReturn);
    rb_ary_push(traces, tpRaise);

    tracepoints = traces;
  }

  for (i = 0; i < RARRAY_LENINT(traces); i++)
    rb_tracepoint_enable(rb_ary_entry(traces, i));
}

static void
clear_tracepoints(VALUE self)
{
  int i;

  UNUSED(self);

  for (i = RARRAY_LENINT(tracepoints) - 1; i >= 0; i--)
    rb_tracepoint_disable(rb_ary_entry(tracepoints, i));
}


/* Byebug's Public API */

/*
 *  call-seq:
 *    Byebug.contexts -> array
 *
 *   Returns an array of all contexts.
 */
static VALUE
Contexts(VALUE self)
{
  volatile VALUE list;
  volatile VALUE new_list;
  VALUE context;
  threads_table_t *t_tbl;
  debug_context_t *dc;
  int i;

  UNUSED(self);

  check_started();

  new_list = rb_ary_new();
  list = rb_funcall(rb_cThread, rb_intern("list"), 0);

  for (i = 0; i < RARRAY_LENINT(list); i++)
  {
    VALUE thread = rb_ary_entry(list, i);

    thread_context_lookup(thread, &context);
    rb_ary_push(new_list, context);
  }

  Data_Get_Struct(threads, threads_table_t, t_tbl);
  st_clear(t_tbl->tbl);

  for (i = 0; i < RARRAY_LENINT(new_list); i++)
  {
    context = rb_ary_entry(new_list, i);
    Data_Get_Struct(context, debug_context_t, dc);
    st_insert(t_tbl->tbl, dc->thread, context);
  }

  return new_list;
}

/*
 *  call-seq:
 *    Byebug.thread_context(thread) -> context
 *
 *   Returns context of the thread passed as an argument.
 */
static VALUE
Thread_context(VALUE self, VALUE thread)
{
  VALUE context;

  UNUSED(self);

  check_started();

  thread_context_lookup(thread, &context);

  return context;
}

/*
 *  call-seq:
 *    Byebug.current_context -> context
 *
 *  Returns the current context.
 *    <i>Note:</i> Byebug.current_context.thread == Thread.current
 */
static VALUE
Current_context(VALUE self)
{
  VALUE context;

  UNUSED(self);

  check_started();

  thread_context_lookup(rb_thread_current(), &context);

  return context;
}

/*
 *  call-seq:
 *    Byebug.started? -> bool
 *
 *  Returns +true+ byebug is started.
 */
static VALUE
Started(VALUE self)
{
  UNUSED(self);

  return IS_STARTED;
}

/*
 *  call-seq:
 *    Byebug.stop -> bool
 *
 *  This method disables byebug. It returns +true+ if byebug was already
 *  disabled, otherwise it returns +false+.
 */
static VALUE
Stop(VALUE self)
{
  UNUSED(self);

  if (IS_STARTED)
  {
    clear_tracepoints(self);

    breakpoints = Qnil;
    catchpoints = Qnil;
    threads = Qnil;

    return Qfalse;
  }

  return Qtrue;
}

/*
 *  call-seq:
 *    Byebug.start -> bool
 *
 *  The return value is the value of !Byebug.started? <i>before</i> issuing the
 *  +start+; That is, +true+ is returned, unless byebug was previously started.
 */
static VALUE
Start(VALUE self)
{
  if (IS_STARTED)
    return Qfalse;

  catchpoints = rb_hash_new();

  threads = create_threads_table();

  register_tracepoints(self);

  return Qtrue;
}

/*
 *  call-seq:
 *    Byebug.debug_load(file, stop = false) -> nil
 *
 *  Same as Kernel#load but resets current context's frames.
 *  +stop+ parameter forces byebug to stop at the first line of code in +file+
 */
static VALUE
Debug_load(int argc, VALUE * argv, VALUE self)
{
  VALUE file, stop, context;
  debug_context_t *dc;
  VALUE status = Qnil;
  int state = 0;

  UNUSED(self);

  if (rb_scan_args(argc, argv, "11", &file, &stop) == 1)
    stop = Qfalse;

  Start(self);

  context = Current_context(self);
  Data_Get_Struct(context, debug_context_t, dc);

  dc->calced_stack_size = 1;

  if (RTEST(stop))
    dc->steps = 1;

  rb_load_protect(file, 0, &state);
  if (0 != state)
  {
    status = rb_errinfo();
    reset_stepping_stop_points(dc);
  }

  return status;
}

/*
 *  call-seq:
 *    Byebug.tracing? -> bool
 *
 *  Returns +true+ if global tracing is enabled.
 */
static VALUE
Tracing(VALUE self)
{
  UNUSED(self);

  return tracing;
}

/*
 *  call-seq:
 *    Byebug.tracing = bool
 *
 *  Sets the global tracing flag.
 */
static VALUE
Set_tracing(VALUE self, VALUE value)
{
  UNUSED(self);

  tracing = RTEST(value) ? Qtrue : Qfalse;
  return value;
}

/*
 *  call-seq:
 *    Byebug.post_mortem? -> bool
 *
 *  Returns +true+ if post-mortem debugging is enabled.
 */
static VALUE
Post_mortem(VALUE self)
{
  UNUSED(self);

  return post_mortem;
}

/*
 *  call-seq:
 *    Byebug.post_mortem = bool
 *
 *  Sets post-moterm flag.
 */
static VALUE
Set_post_mortem(VALUE self, VALUE value)
{
  UNUSED(self);

  post_mortem = RTEST(value) ? Qtrue : Qfalse;
  return value;
}

/*
 *  call-seq:
 *    Byebug.add_catchpoint(exception) -> exception
 *
 *  Adds a new exception to the catchpoints array.
 */
static VALUE
Add_catchpoint(VALUE self, VALUE value)
{
  UNUSED(self);

  if (TYPE(value) != T_STRING)
    rb_raise(rb_eTypeError, "value of a catchpoint must be String");

  rb_hash_aset(catchpoints, rb_str_dup(value), INT2FIX(0));
  return value;
}

/*
 *   Document-class: Byebug
 *
 *   == Summary
 *
 *   This is a singleton class allows controlling byebug. Use it to start/stop
 *   byebug, set/remove breakpoints, etc.
 */
void
Init_byebug()
{
  mByebug = rb_define_module("Byebug");

  rb_define_module_function(mByebug, "add_catchpoint", Add_catchpoint, 1);
  rb_define_module_function(mByebug, "breakpoints", Breakpoints, 0);
  rb_define_module_function(mByebug, "catchpoints", Catchpoints, 0);
  rb_define_module_function(mByebug, "contexts", Contexts, 0);
  rb_define_module_function(mByebug, "current_context", Current_context, 0);
  rb_define_module_function(mByebug, "debug_load", Debug_load, -1);
  rb_define_module_function(mByebug, "post_mortem?", Post_mortem, 0);
  rb_define_module_function(mByebug, "post_mortem=", Set_post_mortem, 1);
  rb_define_module_function(mByebug, "raised_exception", Raised_exception, 0);
  rb_define_module_function(mByebug, "start", Start, 0);
  rb_define_module_function(mByebug, "started?", Started, 0);
  rb_define_module_function(mByebug, "stop", Stop, 0);
  rb_define_module_function(mByebug, "thread_context", Thread_context, 1);
  rb_define_module_function(mByebug, "tracing?", Tracing, 0);
  rb_define_module_function(mByebug, "tracing=", Set_tracing, 1);

  Init_threads_table(mByebug);
  Init_context(mByebug);
  Init_breakpoint(mByebug);

  rb_global_variable(&breakpoints);
  rb_global_variable(&catchpoints);
  rb_global_variable(&tracepoints);
  rb_global_variable(&raised_exception);
  rb_global_variable(&threads);

  idPuts = rb_intern("puts");
}
