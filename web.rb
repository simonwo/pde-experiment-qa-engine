require 'sinatra'
require 'yaml'
require 'partialclass'
require 'json'
require_relative 'engine'
require_relative 'lib/compiler'
require_relative 'lib/parser'
require_relative 'lib/permissionchecker'

config = YAML.load_file(ARGV.first)
permissions = config["permissions"] || []
functions = (config["functions"] || []).inject({}) do |result, expansion|
  result.merge expansion["name"].to_sym => QueryParser.new.parse(expansion["expression"])
end

Checker = PermissionChecker.specialize(QueryParser, permissions)
Compiler = QueryCompiler.specialize(functions)
Engine = QueryEngine.specialize(Compiler, QueryParser, Checker)

get '/query' do
  # TODO: security
  queries = if params[:query].is_a?(Array) then params[:query] else [params[:query]] end
  engine = Engine.new params[:auth]
  engine.run(params[:id], queries).map(&method(:handle_query_result)).to_json
end

def handle_query_result result
  if result.right?
    { :status => :ok, :result => result.right }
  elsif result.left?
    { :status => result.left }
  else
    { :status => :internal_error }
  end
end