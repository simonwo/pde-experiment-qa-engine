require 'sinatra'
require 'yaml'
require 'partialclass'
require 'json'
require_relative 'engine'
require_relative 'lib/compiler'
require_relative 'lib/parser'
require_relative 'lib/permissionchecker'

ATTRIBUTES = {
  [:>=, [:"dwp.pip.mobility"], 8] => lambda {|id| false },
  [:"dwp.dla.higher"] => lambda {|id| true }
}

config = YAML.load_file(ARGV.first)
permissions = config["permissions"] || []
functions = (config["expansions"] || []).map do |expansion|
  parser = QueryParser.new
  [parser.parse(expansion["from"]), parser.parse(expansion["to"])]
end

Checker = PermissionChecker.specialize(QueryParser, permissions)
Compiler = QueryCompiler.specialize()
Engine = QueryEngine.specialize(Compiler, QueryParser, Checker, ATTRIBUTES.to_a, functions.to_a)

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