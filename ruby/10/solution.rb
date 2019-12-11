# frozen_string_literal: true

def parse_map(string)
  map = []
  string.split.each_with_index do |row, y|
    row.split('').each_with_index do |p, x|
      map << [x, y] if p == '#'
    end
  end
  map
end

def read_map(string)
  string.split
end

def find_max(map)
  process_map(map).max_by { |a| a[0] }
end

def find_200(map)
  _, center = find_max(map)
  neighbors = map - [center]
  p center
  origin, neighbors = move_origin(center.dup, neighbors.dup)
  final_list = neighbors.group_by do |target|
    (Math.atan2(*target.reverse) + (Math::PI / 2)) % Math::PI
    # Add Math::PI / 2 but with a proper roll over
  end.sort.map do |target_group|
    #binding.pry
    target_group.last.sort_by do |target|
      distance_between(target)
    end
  end
  asteroid_count = 1
  final_list.cycle do |target_group|
    if target_group.empty?
      final_list.delete(target_group)
      next
    else
      asteroid = move_origin(origin, [target_group.shift]).last.last
      p "it, a: #{asteroid_count} -> #{asteroid}" if [1, 2, 3, 10, 20, 50].include? asteroid_count
      asteroid_count += 1
      return asteroid if asteroid_count == 200
    end
  end
end

def process_map(map)
  map.map { |location| [visible_neighbors(location, map - [location]), location] }
end

def visible_neighbors(location, neighbors)
  _origin_location, neighbors = move_origin(location.dup, neighbors.dup)
  neighbors.map { |target| minimize(target) }.uniq.count
end

def draw_map(map, original_map)
  om = original_map.dup
  map.each do |m, coords|
    x, y = coords
    om[y][x] = m.to_s
  end
  puts om
end

def minimize(target)
  x, y = target
  d = gcd(x, y).abs
  [(x / d), (y / d)]
end

def coprime?(target)
  x, y = target
  gcd(x, y) == 1
end

def gcd(a, b)
  t = 0
  while b != 0
    t = a
    a = b
    b = t % b
  end
  a
end

def move_origin(location, neighbors)
  x, y = location
  [[-x, -y], neighbors.map { |target| [target[0] - x, target[1] - y] }]
end

def distance_between(fa, sa=[0,0])
  Math.sqrt((sa[0] - fa[0])**2 + (sa[1] - fa[1])**2)
end
