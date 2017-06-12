require_relative 'language'

class PermissionChecker
  def initialize parser_class, config=[]
    @Parser = parser_class
    parser = @Parser.new
    # TODO: this is a stupid interface and only here for config, make this better and handle config elsewhere
    @permissions = config.inject({}) do |result, hash|
      result.update hash["id"] => (hash["trees"] || []).map(&parser.method(:parse)).to_a
    end
  end

  # Returns true if the named entity is allowed
  # to execute the passed tree.
  def check who, tree
    return false unless @permissions.has_key?(who)
    return tree_permitted? tree, @permissions[who]
  end

  # Returns true if every branch of the passed tree
  # either is a subtree in the permitted array or
  # ends in a literal.
  def tree_permitted? tree, permitted_trees
    return true if is_literal? tree
    
    input_tree_equal = lambda {|permitted_tree| tree_equal? tree, permitted_tree}
    return true if permitted_trees.any? &input_tree_equal
    
    return Language::Operators.has_key?(tree.first) &&
      tree.drop(1).all? {|subtree| tree_permitted? subtree, permitted_trees}
  end

  # Returns true if the object is a literal
  def is_literal? obj
    return Language::LiteralTypes.any? {|type| obj.is_a? type }
  end

  # Checks whether two ASTs are equal.
  # AST = [:x, :child, [:child, :grandchild], :child]
  def tree_equal? a, b
    if a.is_a?(Array) && b.is_a?(Array)
      return a.zip(b).all? {|child_a, child_b| tree_equal?(child_a, child_b) }
    else
      return a == b
    end
  end
end