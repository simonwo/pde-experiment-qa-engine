require_relative 'lib/compiler'
require_relative 'lib/parser'

class QueryEngine
  ATTRIBUTES = {
    :"dwp.pip.mobility" => lambda {|id| 6 },
    :"dwp.dla.higher" => lambda {|id| true }
  }

  def initialize compiler_class, parser_class
    @Compiler = compiler_class
    @Parser = parser_class
  end

  def run id, query_strings
    attributes = ATTRIBUTES.map do |pair|
       [pair.first, lambda { pair.last.call(id) }]
    end.to_h

    compiler = @Compiler.new attributes
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