module AST
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