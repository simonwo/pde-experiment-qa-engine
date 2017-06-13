require 'functional/either'

class QueryEngine
  def initialize compiler_class, parser_class, checker_class, datastores, functions, runner_id
    @Compiler = compiler_class
    @Parser = parser_class
    @PermissionChecker = checker_class
    @runner = runner_id
    @functions = functions
    @datastores = datastores
  end

  def run target_id, query_strings
    datastores = @datastores.map do |ds|
      [ds.first, lambda { ds.last.call(target_id) }]
    end
    compiler = @Compiler.new datastores.to_a.concat(@functions)
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