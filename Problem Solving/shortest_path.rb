def dijkstra(graph, start)
  distances = {}
  previous = {}
  unvisited = graph.keys

  unvisited.each do |node|
    distances[node] = node == start ? 0 : Float::INFINITY
  end

  # unvisited = nodes.dup

  until unvisited.empty?
    current = unvisited.min_by { |node| distances[node] }

    break if distances[current] == Float::INFINITY

    graph[current].each do |neighbor, weight|
      alt_distance = distances[current] + weight
      if alt_distance < distances[neighbor]
        distances[neighbor] = alt_distance
        previous[neighbor] = current
      end
    end

    unvisited.delete(current)
  end

  [distances, previous]
end

def shortest_path(previous, start, target)
  path = []
  current = target

  while current != start
    path.unshift(current)
    current = previous[current]
    return nil unless current # Target is unreachable
  end

  path.unshift(start)
  path
end

# Example usage
graph = {
  'A' => { 'B' => 6, 'D' => 1 },
  'B' => { 'A' => 6, 'D' => 2, 'E' => 2 },
  'D' => { 'A' => 1, 'B' => 2, 'E' => 1 },
  'E' => { 'B' => 2, 'D' => 1, 'C' => 5 },
  'C' => { 'E' => 5 }
}

start_node = 'A'
distances, previous = dijkstra(graph, start_node)

puts "Shortest distances from #{start_node}:"
distances.each { |node, dist| puts "#{node}: #{dist}" }

target = 'C'
path = shortest_path(previous, start_node, target)

if path
  puts "\nShortest path to #{target}: #{path.join(' -> ')}"
else
  puts "\nNo path to #{target}"
end
