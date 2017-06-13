require_relative 'language'

class QueryCompiler
  DEFAULT_SYMBOLS = Language::Operators

  def initialize expansions={}, symbols={} 
    @symbols = DEFAULT_SYMBOLS.merge symbols
    functions = expansions.inject({}) do |result, expansion|
      result.merge expansion.first => compile(expansion.last)
    end
    @symbols = @symbols.update functions
    puts "Loaded symbols: #{@symbols.inspect}"
  end

  def compile ast
    case
    when ast.is_a?(Array)
      function = @symbols[ast.first]
      args = ast.drop(1).map(&method(:compile))
      if function.nil?
        raise "No such function: #{ast.first}"
      elsif function.arity >= 0 && function.arity != args.size
        raise "#{args.size} for function of #{function.arity} arguments"
      end
      lambda { function.call(*args) }
    else
      lambda { ast }
    end
  end
end