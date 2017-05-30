class QueryCompiler
  DEFAULT_SYMBOLS = {
    :any? => lambda {|*procs| procs.any? &:call},
    :all? => lambda {|*procs| procs.all? &:call},
    :+    => lambda {|*procs| procs.map(&:call).inject(0, :+)},
    :-    => lambda {|*procs| procs.map(&:call).inject(0, :+)},
    :*    => lambda {|*procs| procs.map(&:call).inject(1, :*)},
    :/    => lambda {|*procs| procs.drop(1).map(&:call).inject(procs.first.call, :/)},
    :eq?  => lambda {|proc_a, proc_b| proc_a.call == proc_b.call},
    :gt?  => lambda {|proc_a, proc_b| proc_a.call > proc_b.call},
  }

  def compile ast
    case
    when ast.is_a?(Array)
      function = DEFAULT_SYMBOLS[ast.first]
      args = ast.drop(1).map(&method(:compile))
      raise "#{args.size} for function of #{function.arity} arguments" if function.arity >= 0 && function.arity != args.size
      lambda { function.call(*args) }
    else
      lambda { ast }
    end
  end
end