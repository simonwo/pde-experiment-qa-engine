require_relative 'language'
require_relative 'ast'

class QueryCompiler
  include AST

  DEFAULT_SYMBOLS = Language::Operators

  def initialize expansions=[], symbols={} 
    @symbols = DEFAULT_SYMBOLS.merge symbols
    expansions.each do |expansion|
      puts "Pre-compiling expansion #{expansion.first} => #{expansion.last}"
      @expansions = (@expansions || {}).merge expansion.first => compile(expansion.last)
    end 
  end

  def compile ast
    if ast.is_a?(Array)
      if match = (@expansions || {}).keys.select {|exp| tree_equal? ast, exp }.first
        lambda { @expansions[match].call }
      else
        function = @symbols[ast.first]
        args = ast.drop(1).map(&method(:compile))
        raise "No such function: #{ast.first}" if function.nil?
        raise "#{args.size} for function of #{function.arity} arguments" if function.arity >= 0 && function.arity != args.size
        lambda { function.call(*args) }
      end
    elsif ast.is_a?(Proc)
      ast
    else
      lambda { ast }
    end
  end
end