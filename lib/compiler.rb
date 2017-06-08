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

  def initialize symbols={}
    @symbols = DEFAULT_SYMBOLS.update symbols
  end

  def compile ast
    case
    when ast.is_a?(Array)
      function = @symbols[ast.first]
      args = ast.drop(1).map(&method(:compile))
      if function.arity >= 0 && function.arity != args.size
        raise "#{args.size} for function of #{function.arity} arguments"
      end
      lambda { function.call(*args) }
    else
      lambda { ast }
    end
  end
end