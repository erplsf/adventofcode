# system: [node, node]
# node: {name: str, objects: [node]}

def find_node(tree, name, depth = 0, ancestors = [])
  if tree[:name] == name
    [tree, depth, ancestors]
  else
    if tree[:objects] && !tree[:objects].empty?
      tree[:objects].map { |o| find_node(o, name, depth + 1, ancestors.push(tree[:name])) }.select { |o| o && o[0] }.first
    else
      [nil, depth, ancestors]
    end
  end
end

def distance(tree, fn, sn)
  _n, _d, fa = find_node(tree, fn)
  _n, _d, sa = find_node(tree, sn)
  [fa, sa]
end

def assign_child_to_map(system, parent_name, child_name)
  #p "S -> sm, pn, cn #{system} #{parent_name} #{child_name}"

  parent = nil

  #p "looking for #{parent_name}"
  system.find do |n|
    node, _depth, _ancestors = find_node(n, parent_name)
    if node
      #p "found #{parent_name}"
      parent = node
    end
  end

  child = nil
  child_depth = 0

  child_index = system.find_index do |n|
    node, child_depth, ancestors = find_node(n, child_name)
    child = node if node
  end

  system.delete_at(child_index) if child_depth == 0 && child_index

  #p "parent, child: ' #{parent}' '#{child}'"
  if parent
    parent[:objects] ||= []
    if child
      #p "p c"
      parent[:objects] << child
    else
      #p "p !c"
      parent[:objects] << { name: child_name }
    end
  else
    if child
      #p "!p c"
      system << { name: parent_name, objects: [child] }
    else
      #p "!p !c"
      system << { name: parent_name, objects: [{ name: child_name }] }
    end
  end
  #p "E -> s #{system}"
end

def read_map(string)
  string.split.map { |o| o.split(")") }
end

def process_map(map)
  system = []
  map.each do |pair|
    assign_child_to_map(system, pair[0], pair[1])
  end
  system
end

def calculate_orbits(system)
  raise "Only 1 main ibject should be present!" if system.count > 1
  calculate_orbits_rec(system[0])
end

def calculate_orbits_rec(tree, depth = 0)
  if tree[:objects] && !tree[:objects].empty?
    depth + tree[:objects].map { |o| calculate_orbits_rec(o, depth + 1) }.sum
  else
    depth
  end
end

# TODO: Implement moving portions of the tree to another location!
# TODO: Use proper trees?
