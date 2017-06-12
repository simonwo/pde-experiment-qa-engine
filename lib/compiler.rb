require_relative 'language'

class QueryCompiler
  DEFAULT_SYMBOLS = Language::Operators

  def initialize symbols={}
    @symbols = DEFAULT_SYMBOLS.merge symbols
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