require 'sinatra'
require_relative 'engine'
require_relative 'lib/compiler'
require_relative 'lib/parser'

engine = QueryEngine.new(QueryCompiler, QueryParser)

get '/query' do
  # TODO: security
  queries = if params[:query].is_a?(Array) then params[:query] else [params[:query]] end
  engine.run(params[:id], queries).to_s
end