def list_visited(search_algorithm, *args)
  visited = []
  search_algorithm.call(*args) do |node|
    visited << node.value
  end

  visited
end

class Node < Struct.new(:value, :children)
end

#               5
#              /|\
#             / | \
#            2  6  7
#           / \  \
#          /   \  \
#         1     3  4

# BFS: 5, 2, 6, 7, 1, 3, 4
# DFS: 1, 3, 2, 4, 6, 7, 5

tree = Node.new(
  5,
  [
    Node.new(
      2,
      [
        Node.new(
          1,
          []
        ),

        Node.new(
          3,
          []
        )
      ]
    ),

    Node.new(
      6,
      [
        Node.new(
          4,
          []
        )
      ]
    ),

    Node.new(
      7,
      []
    )
  ]
)

def iterative_bfs_with_multiple_children(root, &visitor)
  queue = [root]

  while queue.any?
    node = queue.shift
    visitor.call(node)

    queue += node.children
  end
end

puts "=== Iterative BFS with multiple children ==="
puts list_visited(method(:iterative_bfs_with_multiple_children), tree).inspect

def recursive_dfs_with_multiple_children(root, &visitor)
  root.children.each { |child| recursive_dfs_with_multiple_children(child, &visitor) }
  visitor.call(root)
end

puts "=== Recursive DFS with multiple children ==="
puts list_visited(method(:recursive_dfs_with_multiple_children), tree).inspect

class BinaryNode < Struct.new(:value, :left, :right, :visited)
end

#               5
#              / \
#             /   \
#            2     6
#           / \     \
#          /   \     \
#         1     3     4
#              /
#             /
#            7
#
# DFS:
#   Pre-order: 5, 2, 1, 3, 7, 6, 4
#   In-order: 1, 2, 7, 3, 5, 6, 4
#   Post-order: 1, 7, 3, 2, 4, 6, 5

tree = BinaryNode.new(
  5,

  BinaryNode.new(
    2,

    BinaryNode.new(
      1
    ),

    BinaryNode.new(
      3,

      BinaryNode.new(
        7
      )
    )
  ),

  BinaryNode.new(
    6,

    nil,

    BinaryNode.new(
      4,
    )
  )
)

def recursive_binary_dfs(root, order, &visitor)
  case order
  when :pre
    visitor.call(root)
    recursive_binary_dfs(root.left, order, &visitor) if root.left
    recursive_binary_dfs(root.right, order, &visitor) if root.right

  when :in
    recursive_binary_dfs(root.left, order, &visitor) if root.left
    visitor.call(root)
    recursive_binary_dfs(root.right, order, &visitor) if root.right

  when :post
    recursive_binary_dfs(root.left, order, &visitor) if root.left
    recursive_binary_dfs(root.right, order, &visitor) if root.right
    visitor.call(root)

  else fail "Unrecognized order: #{order}"
  end
end

puts "=== Recursive Binary Pre-order DFS ==="
puts list_visited(method(:recursive_binary_dfs), tree, :pre).inspect

puts "=== Recursive Binary In-order DFS ==="
puts list_visited(method(:recursive_binary_dfs), tree, :in).inspect

puts "=== Recursive Binary Post-order DFS ==="
puts list_visited(method(:recursive_binary_dfs), tree, :post).inspect

def iterative_binary_dfs(root, order, &visitor)
  stack = [root]

  while stack.any?
    node = stack.pop

    if !node.visited
      node.visited = true

      case order
      when :pre
        stack.push(node.right) if node.right
        stack.push(node.left) if node.left
        stack.push(node)
      when :in
        stack.push(node.right) if node.right
        stack.push(node)
        stack.push(node.left) if node.left

      when :post
        stack.push(node)
        stack.push(node.right) if node.right
        stack.push(node.left) if node.left

      else fail "Unrecognized order: #{order}"
      end
    else
      visitor.call(node)
    end
  end
end

puts "=== Iterative Binary Pre-order DFS ==="
puts list_visited(method(:iterative_binary_dfs), tree, :pre).inspect

# Using an algorithm that doesn't depend on the
# Node#visited attribute to reset their values
def reset_visited_nodes(tree)
  recursive_binary_dfs(tree, :pre) do |node|
    node.visited = false
  end
end

reset_visited_nodes(tree)

puts "=== Iterative Binary In-order DFS ==="
puts list_visited(method(:iterative_binary_dfs), tree, :in).inspect

reset_visited_nodes(tree)

puts "=== Iterative Binary Post-order DFS ==="
puts list_visited(method(:iterative_binary_dfs), tree, :post).inspect

reset_visited_nodes(tree)
