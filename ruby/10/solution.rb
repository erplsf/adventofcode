# frozen_string_literal: true

def read_map(string)
  map = []
  string.split.each_with_index do |row, y|
    row.split('').each_with_index do |p, x|
      map << [x, y] if p == '#'
    end
  end
  map
end

def visible_neighbors(location, neighbors)
  #_origin_location, location, neighbors = move_origin(location, neighbors)
  sorted = neighbors.sort { |target| distance_between(location, target) }
  # find the closest asteroid that is located at coprime coordinates and remove all other asteroids that have the same minimized form
end

def minimize(target)
  x, y = target
  d = gcd(x, y)
  [x/d, y/d]
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
