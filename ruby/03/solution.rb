def read_path(string)
  string.split(",").map do |segment|
    segment = segment.scan(/\d+|\D/)
    segment[1] = segment.last.to_i
    segment
  end
end

def process_path(path)
  path = path.dup
  r = [] # {x: range, y: num}
  pos = { x: 0, y: 0 }
  path.each_with_index do |segment, index|
    direction, distance = segment
    case direction
    # REWRITE TO USE CORRECT DIRECTION OF RANGES (?)
    when "U"
      r << { step: distance, x: pos[:x], y: pos[:y]..pos[:y]+distance }
      pos[:y] = pos[:y] + distance
    when "D"
      r << { step: distance, x: pos[:x], y: pos[:y]..pos[:y]-distance }
      pos[:y] = pos[:y] - distance
    when "L"
      r << { step: distance, x: pos[:x]..pos[:x]-distance, y: pos[:y] }
      pos[:x] = pos[:x] - distance
    when "R"
      r << { step: distance, x: pos[:x]..pos[:x]+distance, y: pos[:y] }
      pos[:x] = pos[:x] + distance
    end
  end
  r
end

def unpack_coord(coord)
  case coord
  when Range
    [coord.first, coord.last]
  when Numeric
    [coord, coord]
  end
end

def intersects?(fs, ss)
    x1, x2 = unpack_coord(fs[:x]).sort
    y1, y2 = unpack_coord(fs[:y]).sort

    x3, x4 = unpack_coord(ss[:x]).sort
    y3, y4 = unpack_coord(ss[:y]).sort

    x1r = x1..x2
    y1r = y1..y2

    x2r = x3..x4
    y2r = y3..y4

    px = nil
    py = nil

    if ((x1r.cover?(x2r) || x2r.cover?(x1r)) &&
        (y1r.cover?(y2r) || y2r.cover?(y1r)))
      px = if x1r.size == 1
             x1r.first
           else
             x2r.first
           end
      py = if y1r.size == 1
             y1r.first
           else
             y2r.first
           end
    end

    if px && py
      [px, py]
    else
      nil
    end
end

def calculate_distance(segment, px, py)
  sx = segment[:x]
  sy = segment[:y]
  if sx.is_a? Range
    (px - unpack_coord(sx).first).abs
  else
    (py - unpack_coord(sy).first).abs
  end
end

def distance_to_segment(path, original_index, target_index)
  total_distance = 0
  current_index = original_index
  while true
    segment = path[current_index]
    distance = segment[:step]
    total_distance += distance
    current_index -= 1
    break if current_index <= target_index
  end
  total_distance
end

def minimal_distance(paths)
  intersections = []

  paths = paths.dup
  p1, p2 = paths

  p1.each_with_index do |p1_segment, p1_index|
    p2.each_with_index do |p2_segment, p2_index|
      result = intersects?(p1_segment, p2_segment)
      
      # skip not an intersection
      next unless result
      px, py = result

      # skip the starting point
      next if px == 0 && py == 0

      # mark as an intersection
      p1_segment[:intersections] ||= []
      p1_segment[:intersections] << [x: px, y: py, distance: calculate_distance(p1_segment, px, py), opposite_index: p2_index]

      p2_segment[:intersections] ||= []
      p2_segment[:intersections] << [x: px, y: py, distance: calculate_distance(p2_segment, px, py), opposite_index: p1_index]

      distance = px.abs + py.abs

      intersections << { index_w1: p1_index, index_w2: p2_index, distance: distance }
    end
  end
  
  pp paths

  intersections.select! do |intersection|
    intersection[:distance] > 0
  end

  # update steps required to reach each segment

  # calculate distance for each intersection
  intersections.each do |intersection|
    total_steps = 0

    index = intersection[:index_w1]
    while true
      total_steps += paths[0][index][:step]
      index -= 1
      break if index < 0
    end

    index = intersection[:index_w2]
    while true
      total_steps += paths[1][index][:step]
      index -= 1
      break if index < 0
    end

    intersection[:steps] = total_steps
  end

  pp paths
  intersections.sort_by { |intersection| intersection[:steps] }

  #paths
end

def read_file(filename)
  paths = File.read(filename).split
  paths.map { |string| read_path(string) }
end

def solve_file(filename)
  paths = read_file(filename)
  pps = paths.map { |path| process_path(path) }
  minimal_distance(pps[0], pps[1])
end
