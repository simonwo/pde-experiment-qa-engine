require 'functional/either'

class QueryEngine
  ATTRIBUTES = {
    :"dwp.pip.mobility" => lambda {|id| 6 },
    :"dwp.dla.higher" => lambda {|id| true }
  }

  def initialize compiler_class, parser_class, checker_class, runner_id
    @Compiler = compiler_class
    @Parser = parser_class
    @PermissionChecker = checker_class
    @runner = runner_id
  end

  def run target_id, query_strings
    attributes = ATTRIBUTES.map do |pair|
       [pair.first, lambda { pair.last.call(target_id) }]
    end.to_h

    compiler = @Compiler.new attributes
    parser = @Parser.new
    permissionchecker = @PermissionChecker.new

    query_strings.map do |query_string|
      parsed_query = parser.parse query_string
      if permissionchecker.check @runner, parsed_query
        func = compiler.compile parsed_query
        Functional::Either.value func.call
      else
        Functional::Either.error :permission_denied
      end
    end
  end
end

if __FILE__ == $0
  require 'partialclass'
  require_relative 'lib/compiler'
  require_relative 'lib/parser'
  require_relative 'lib/permissionchecker'

  p QueryEngine.new(QueryCompiler.specialize({}), QueryParser, PermissionChecker.specialize(QueryParser, []), nil).run(0, ARGV)
end