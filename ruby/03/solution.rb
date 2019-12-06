def read_path(string)
  string.split(",").map do |segment|
    segment = segment.scan(/\d+|\D/)
    segment[1] = segment.last.to_i
    segment
  end
end

def process_path(path)
  path = path.dup
  v = [] # {x: num, y: range}
  h = [] # {x: range, y: num}
  pos = { x: 0, y: 0 }
  path.each_with_index do |segment, index|
    direction, distance = segment
    case direction
    when "U"
      v << { index: index, step: distance, x: [pos[:x], pos[:x]], y: [pos[:y], pos[:y] + distance] }
      pos[:y] = pos[:y] + distance
    when "D"
      v << { index: index, step: distance, x: [pos[:x], pos[:x]], y: [pos[:y] - distance, pos[:y]] }
      pos[:y] = pos[:y] - distance
    when "L"
      h << { index: index, step: distance, y: [pos[:y], pos[:y]], x: [pos[:x] - distance, pos[:x]] }
      pos[:x] = pos[:x] - distance
    when "R"
      h << { index: index, step: distance, y: [pos[:y], pos[:y]], x: [pos[:x], pos[:x] + distance] }
      pos[:x] = pos[:x] + distance
    end
  end
  { h: h, v: v }
end

KM = {
  h: [:v, :x],
  v: [:h, :y],
  x: :y,
  y: :x,
}

def minimal_distance(w1, w2)
  intersections = []
  w1.each do |k, w1_segments|
    op_k, _dir = KM[k]
    w1_segments.each do |w1_segment|
      w2[op_k].each do |w2_segment|
        x1, x2 = w1_segment[:x]
        y1, y2 = w1_segment[:y]
        x1r = x1..x2
        y1r = y1..y2

        x3, x4 = w2_segment[:x]
        y3, y4 = w2_segment[:y]
        x2r = x3..x4
        y2r = y3..y4

        if (!(w1_segment[:intersection] || w2_segment[:intersection]) &&
            (x1r.cover?(x2r) || x2r.cover?(x1r)) &&
            (y1r.cover?(y2r) || y2r.cover?(y1r)))
          # mark as an intersection
          w1_segment[:intersection] = true
          w2_segment[:intersection] = true

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

          if (x1 != x2)
            w1_segment[:step] = w1_segment[:step] - (x2 - px)
          else
            w1_segment[:step] = w1_segment[:step] - (y2 - py)
          end

          if (x3 != x4)
            w2_segment[:step] = w2_segment[:step] - (x4 - px)
          else
            w2_segment[:step] = w2_segment[:step] - (y4 - py)
          end

          distance = px.abs + py.abs

          intersections << { index_w1: w1_segment[:index], index_w2: w2_segment[:index], distance: distance }
        end
      end
    end
  end

  # update distances (steps)
  [w1, w2].each do |w|
    w.each do |_k, w_segments|
      w_segments.each do |w_segment|
        # find previous segment
        prev_segment = w_segments.select { |s| s[:index] == (w_segment[:index] - 1) }.first
        p w_segments
        raise
        p w_segment[:index], prev_segment if w_segment[:index]
        # update the current segment with sum of all previous steps
        w_segment[:step] = w_segment[:step] + prev_segment[:step] if prev_segment
      end
    end
  end

  intersections.select! do |intersection|
    intersection[:distance] > 0
  end

  intersections.each do |intersection|
    w1_segment = w1.values.flatten.select do |segment|
      segment[:index] == intersection[:index_w1]
    end.first

    w2_segment = w2.values.flatten.select do |segment|
      segment[:index] == intersection[:index_w2]
    end.first

    intersection[:steps] = w1_segment[:step] + w2_segment[:step]
  end

  #intersections.sort_by { |intersection| intersection[:steps] }

  [q1w1, w2]
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
