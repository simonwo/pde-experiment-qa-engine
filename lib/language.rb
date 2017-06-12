module Language
  Operators = {
    :any? => lambda {|*procs| procs.any? &:call},
    :all? => lambda {|*procs| procs.all? &:call},
    :+    => lambda {|*procs| procs.map(&:call).inject(0, :+)},
    :-    => lambda {|*procs| procs.map(&:call).inject(0, :+)},
    :*    => lambda {|*procs| procs.map(&:call).inject(1, :*)},
    :/    => lambda {|*procs| procs.drop(1).map(&:call).inject(procs.first.call, :/)},
    :eq?  => lambda {|proc_a, proc_b| proc_a.call == proc_b.call},
    :>    => lambda {|proc_a, proc_b| proc_a.call > proc_b.call},
    :>=   => lambda {|proc_a, proc_b| proc_a.call >= proc_b.call}
  }

  LiteralTypes = [String, Symbol, Bignum, Float, Fixnum, TrueClass, FalseClass]
end