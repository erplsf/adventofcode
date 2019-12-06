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
      r << { step: distance, x: [pos[:x], pos[:x]], y: [pos[:y], pos[:y] + distance] }
      pos[:y] = pos[:y] + distance
    when "D"
      r << { step: distance, x: [pos[:x], pos[:x]], y: [pos[:y] - distance, pos[:y]] }
      pos[:y] = pos[:y] - distance
    when "L"
      r << { step: distance, y: [pos[:y], pos[:y]], x: [pos[:x] - distance, pos[:x]] }
      pos[:x] = pos[:x] - distance
    when "R"
      r << { step: distance, y: [pos[:y], pos[:y]], x: [pos[:x], pos[:x] + distance] }
      pos[:x] = pos[:x] + distance
    end
  end
  r
end

KM = {
  h: [:v, :x],
  v: [:h, :y],
  x: :y,
  y: :x,
}

def minimal_distance(paths)
  intersections = []

  paths = paths.dup
  p1, p2 = paths

  p1.each_with_index do |p1_segment, p1_index|
    p2.each_with_index do |p2_segment, p2_index|
      x1, x2 = p1_segment[:x]
      y1, y2 = p1_segment[:y]
      x1r = x1..x2
      y1r = y1..y2

      x3, x4 = p2_segment[:x]
      y3, y4 = p2_segment[:y]
      x2r = x3..x4
      y2r = y3..y4

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

        # skip the starting point
        next if px == 0 && py == 0

        p "px, py: #{px} #{py}"

        # mark as an intersection
        p1_segment[:intersection] = true
        p2_segment[:intersection] = true

        # REWRITE TO CORRECTLY HANDLE DIRECTIONS (!)
        p "p1_segment[:step] before: #{p1_segment[:step]}", p1_segment, p2_segment
        if (x1r.size == 1)
          p1_segment[:step] = py
        else
          p1_segment[:step] = px
        end
        p "p1_segment[:step] after: #{p1_segment[:step]}"

        p "p2_segment[:step] before: #{p2_segment[:step]}", p1_segment, p2_segment
        if (x2r.size == 1)
          p2_segment[:step] = py
        else
          p2_segment[:step] = px
        end
        p "p2_segment[:step] before: #{p2_segment[:step]}"

        distance = px.abs + py.abs

        intersections << { index_w1: p1_index, index_w2: p2_index, distance: distance }
      end
    end
  end

  # update distances (steps)
  #paths.each do |p|
    #p.each_with_index do |p_segment, p_index|
      ## skip the starting point
      #next if p_index == 0
      ## find previous segment
      #prev_segment = p[p_index - 1]
      ## update the current segment with sum of all previous steps
      #p "#{p_index} #{p_segment[:step]} #{prev_segment[:step]}"
      #p_segment[:step] = p_segment[:step] + prev_segment[:step] if prev_segment
      #p "#{p_index} #{p_segment[:step]}"
    #end
  #end

  intersections.select! do |intersection|
    intersection[:distance] > 0
  end

  intersections.each do |intersection|
    w1_segment = p1[intersection[:index_w1]]
    w2_segment = p2[intersection[:index_w2]]

    intersection[:steps] = w1_segment[:step] + w2_segment[:step]
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
