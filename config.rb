require 'net/http'
require 'json'

class YAMLConfig
  def initialize parser_class, file
    @config = YAML.load_file file
    @parser = parser_class.new 
  end

  def datastores
    (@config["datastores"] || []).map do |store|
      case store["type"]
      when "hash"
        columns = []
        hash = store["contents"].inject({}) do |result, item|
          id = item.delete "id"
          columns.push *item.keys
          result.merge id => item
        end
        columns.uniq.map do |column|
          [[column.to_sym], lambda {|id| hash[id][column] }]
        end
      when 'remote'
        store["permissions"].map do |expr|
          get_attr = lambda do |id|
            uri = URI(store['url'])
            uri.query = URI.encode_www_form query: expr, id: id, auth: "blue-badge-service"
            json = Net::HTTP.get uri
            hash = JSON.parse json
            p hash
            hash.first["result"]
          end
          [@parser.parse(expr), get_attr]
        end
      end
    end.flatten(1)
  end

  def permissions
    @config["permissions"] || []
  end

  def expansions
    (@config["expansions"] || []).map do |expansion|
      [@parser.parse(expansion["from"]), @parser.parse(expansion["to"])]
    end
  end
end