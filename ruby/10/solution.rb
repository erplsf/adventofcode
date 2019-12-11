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

def process_map(map)
  map.map { |location| [visible_neighbors(location, map - [location]), location] }
end

def visible_neighbors(location, neighbors)
  _origin_location, _location, neighbors = move_origin(location.dup, neighbors.dup)
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
  [[x, y], [0, 0], neighbors.map { |target| [target[0] - x, target[1] - y] }]
end

def distance_between(fa, sa)
  Math.sqrt((sa[0] - fa[0])**2 + (sa[1] - fa[1])**2)
end
