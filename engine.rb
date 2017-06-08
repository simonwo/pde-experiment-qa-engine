require_relative 'lib/compiler'
require_relative 'lib/parser'

class QueryEngine
  def initialize compiler_class, parser_class
    @Compiler = compiler_class
    @Parser = parser_class
  end

  def run id, query_strings
    compiler = @Compiler.new
    parser = @Parser.new

    query_strings.map do |query_string|
      func = compiler.compile parser.parse query_string
      func.call
    end
  end
end

if __FILE__ == $0
  p QueryEngine.new(QueryCompiler, QueryParser).run(0, ARGV)
end