### Modeling the graph as objects

class Edge < Struct.new(:source, :destination, :length); end
class Node < Struct.new(:label, :distance, :previous); end

class Graph
  attr_reader :edges

  def initialize(edges)
    @edges = edges
  end

  def nodes
    edges.flat_map { |edge| [edge.source, edge.destination] }.uniq
  end

  def neighbours(node)
    edges
      .select { |edge| edge.source == node }
      .map(&:destination)
  end

  def distance_between(source, destination)
    edges
      .find { |edge| edge.source == source && edge.destination == destination }
      .length
  end

  def dijkstra(origin, destination)
    unvisited = nodes.clone
    unvisited.each do |node|
      node.distance = Float::INFINITY
    end

    origin.distance = 0

    while unvisited.any?
      current = unvisited.min_by(&:distance)
      unvisited.delete(current)

      neighbours(current)
        .select { |neighbour| unvisited.include? neighbour }
        .each do |neighbour|
          new_distance = current.distance + distance_between(current, neighbour)

          if new_distance < neighbour.distance
            neighbour.distance = new_distance
            neighbour.previous = current
          end

          if neighbour == destination
            path = [destination]

            current = destination
            loop do
              path << current.previous
              current = current.previous
              break if current == origin
            end

            return {
              path: path.reverse,
              distance: destination.distance
            }
          end
        end
    end
  end
end

new_york = Node.new(:new_york)
brooklyn = Node.new(:brooklyn)
queens = Node.new(:queens)
chicago = Node.new(:chicago)
atlanta = Node.new(:atlanta)
denver = Node.new(:denver)
san_diego = Node.new(:san_diego)
los_angeles = Node.new(:los_angeles)
washington = Node.new(:washington)

usa = Graph.new([
  Edge.new(new_york, brooklyn, 1),
  Edge.new(new_york, queens, 1),
  Edge.new(new_york, chicago, 2),
  Edge.new(queens, chicago, 1),
  Edge.new(brooklyn, chicago, 1),
  Edge.new(brooklyn, queens, 1),
  Edge.new(chicago, atlanta, 3),
  Edge.new(chicago, denver, 2),
  Edge.new(atlanta, denver, 1),
  Edge.new(denver, san_diego, 3),
  Edge.new(denver, washington, 4),
  Edge.new(san_diego, los_angeles, 4),
  Edge.new(washington, los_angeles, 3)
])

shortest_path = usa.dijkstra(new_york, los_angeles)
puts "Distance: #{shortest_path[:distance]}, path: #{shortest_path[:path].map(&:label).join(", ")}"

### Modeling the graph as a matrix
class MatrixGraph
  attr_reader :edges

  def initialize(edges)
    @edges = edges

    # Pre-calculating all neighbours
    @neighbours = []
    edges
      .each_with_index do |nodes, node|
        @neighbours[node] = nodes.each_with_index
                              .select { |length, neighbour| length > 0 }
                              .map { |length, neighbour| neighbour }
      end
  end

  def nodes
    (0..edges.length - 1).to_a
  end

  def neighbours(node)
    @neighbours[node]
  end

  def distance_between(source, destination)
    edges[source][destination]
  end

  def dijkstra(origin, destination)
    distances = []
    previouses = []

    unvisited = nodes.clone
    unvisited.each do |node|
      distances[node] = Float::INFINITY
    end

    distances[origin] = 0

    while unvisited.any?
      current = unvisited.min_by { |node| distances[node] }
      unvisited.delete(current)

      neighbours(current)
        .select { |neighbour| unvisited.include? neighbour }
        .each do |neighbour|
          new_distance = distances[current] + distance_between(current, neighbour)

          if new_distance < distances[neighbour]
            distances[neighbour] = new_distance
            previouses[neighbour] = current
          end

          if neighbour == destination
            path = [destination]

            current = destination
            loop do
              path << previouses[current]
              current = previouses[current]
              break if current == origin
            end

            return {
              path: path.reverse,
              distance: distances[destination]
            }
          end
        end
    end
  end
end

new_york = 0
brooklyn = 1
queens = 2
chicago = 3
atlanta = 4
denver = 5
san_diego = 6
washington = 7
los_angeles = 8

# Using a representation like this, we can define any
# edge ij (edge between node i to node j) with a non-zero positive number
# in the matrix at the position ij. For a non-oriented graph, the matrix is
# going to be mirrored. For an oriented graph, the length at ij may be different
# than the length at ji (maybe it's a one-way road, or to get back you need to
# stop at a toll so it takes longer).
usa = MatrixGraph.new([
  [0, 1, 1, 2, 0, 0, 0, 0, 0],
  [1, 0, 1, 1, 0, 0, 0, 0, 0],
  [1, 0, 0, 1, 0, 0, 0, 0, 0],
  [2, 0, 0, 0, 3, 2, 0, 0, 0],
  [0, 0, 0, 0, 0, 1, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 3, 4, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 4],
  [0, 0, 0, 0, 0, 0, 0, 0, 3],
  [0, 0, 0, 0, 0, 0, 0, 0, 0]
])

labels = [
  :new_york,
  :brooklyn,
  :queens,
  :chicago,
  :atlanta,
  :denver,
  :san_diego,
  :washington,
  :los_angeles
]

shortest_path = usa.dijkstra(new_york, los_angeles)
puts "Distance: #{shortest_path[:distance]}, path: #{shortest_path[:path].map { |node| labels[node] }.join(", ")}"

### Benchmark

require 'benchmark'
puts "Building sample set..."

# The build time take approximately 2 seconds
matrix_nodes = matrix_edges = object_nodes = object_edges = nil
build_time = Benchmark.realtime do
  matrix_nodes = (0...1000).to_a

  # Adding a fail-safe to ensure there's always going
  # to be a path from origin to the destination.
  # If the random steps below can't provide a path,
  # at least there's going to be a direct path between
  # origin and destination with the length of 999,999.
  matrix_edges = Array.new(matrix_nodes.length) { Array.new(matrix_nodes.length) { 999_999 } }

  matrix_nodes.each do |origin|
    edges = 0

    while edges < 100
      edges += 1
      destination = nil

      while destination == nil
        # Randomly chooses a node that's not the current origin
        # node and didn't have already an edge with the current origin,
        # attempting to increase the density of edges
        destination = rand(0..matrix_nodes.length - 1)
        destination = nil if destination == origin || matrix_edges[origin][destination] < 999_999
      end

      matrix_edges[origin][destination] = rand(1..100)
    end
  end

  object_nodes = matrix_nodes.map { |node| Node.new(node) }
  object_edges = []
  for i in (0..matrix_edges.length - 1)
    for j in (0..matrix_edges.length - 1)
      object_edges << Edge.new(object_nodes[i], object_nodes[j], matrix_edges[i][j])
    end
  end
end

puts "Finished building sample set with #{build_time} seconds"

# In all the tests I've ran, the matrix
# version performed more than 10 times better
# than the object version.
# It takes approximately 0.4 seconds to solve
# the problem with the matrix version and
# 4.5 seconds with the object version.

matrix_result = object_result = nil
Benchmark.bm do |x|
  x.report(:matrix) { matrix_result = MatrixGraph.new(matrix_edges).dijkstra(0, matrix_nodes.length - 1) }
  x.report(:object) { object_result = Graph.new(object_edges).dijkstra(object_nodes.first, object_nodes.last) }
end

# Just a sanity check, to be sure both of them are working correctly
fail "Results are different: from matrix is #{matrix_result[:distance]} and from object is #{object_result[:distance]}" unless matrix_result[:distance] == object_result[:distance]
fail "Number of nodes in the path is different: from matrix is #{matrix_result[:path].length} and from object is #{object_result[:path].length}" unless matrix_result[:path].length == object_result[:path].length
puts "Shortest distance for benchmark problem: #{matrix_result[:distance]}"
puts "Number of nodes in the path: #{matrix_result[:path].length}"
