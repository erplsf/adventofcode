def read_tape(string)
  string.split(",").map(&:to_i)
end

class Halt < StandardError; end

OPCODE_MAP = {
  # MATH
  "01" => lambda do |tape, position, mode|
    args = process_mode(tape, position, mode)
    #p "position, args, mode: #{position} #{tape[position..-1].take(4)} #{mode}"
    p3 = tape[position + 3]

    tape[p3] = args.sum

    position = position + 4
    [tape, position]
  end,
  "02" => lambda do |tape, position, mode|
    args = process_mode(tape, position, mode)
    #p "position, args, mode: #{position} #{tape[position..-1].take(4)} #{mode}"
    p3 = tape[position + 3]

    tape[p3] = args.inject(:*)

    position = position + 4
    [tape, position]
  end,
  # IO
  # read from console ->
  "03" => lambda do |tape, position, _mode|
    #p "position, args, mode: #{position} #{tape[position..-1].take(2)} #{mode}"
    target = tape[position + 1]
    print "Input an integer: "
    input = gets.chomp.to_i
    tape[target] = input
    position = position + 2
    [tape, position]
  end,
  # write to console ->
  "04" => lambda do |tape, position, mode|
    args = process_mode(tape, position, mode)
    #p "position, args, mode: #{position} #{tape[position..-1].take(2)} #{mode}"
    p "Program output: #{args.first}"
    position = position + 2
    [tape, position]
  end,
  # TODO: Implement jumps
  # jmps
  "05" => lambda do |tape, position, mode|
    args = process_mode(tape, position, mode)
    if args[0] != 0
      position = args[1]
    else
      position = position + 3
    end
    [tape, position]
  end,
  "06" => lambda do |tape, position, mode|
    args = process_mode(tape, position, mode)
    if args[0] == 0
      position = args[1]
    else
      position = position + 3
    end
    [tape, position]
  end,
  "07" => lambda do |tape, position, mode|
    args = process_mode(tape, position, mode)
    p3 = tape[position + 3]
    if args[0] < args[1]
      tape[p3] = 1
    else
      tape[p3] = 0
    end
    position = position + 4
    [tape, position]
  end,
  "08" => lambda do |tape, position, mode|
    args = process_mode(tape, position, mode)
    p3 = tape[position + 3]
    if args[0] == args[1]
      tape[p3] = 1
    else
      tape[p3] = 0
    end
    position = position + 4
    [tape, position]
  end,
  # HALT
  "99" => lambda do |_tape, _position, _mode|
    raise Halt
  end,
}

def process_mode(tape, position, mode)
  raise "Target mode (last bit) should never be 1 (immediate)!" if mode.last == 1
  args = []

  mode.take(2).each_with_index do |m, i|
    if m == 0
      index = tape[position + 1 + i]
      args << tape[index]
    elsif m == 1
      args << tape[position + 1 + i]
    else
      raise "Unsupported mode: #{m}"
    end
  end

  args
end

def decode_opcode(tape, position)
  full_opcode = tape[position].to_s.rjust(5, "0")
  mode = full_opcode[0..2].split("").map(&:to_i).reverse
  opcode = full_opcode[-2..-1]
  [opcode, mode]
end

def process_tape(tape)
  tape = tape.dup
  position = 0
  halted = false

  while (!halted)
    begin
      #p "Instruction at head, position: #{tape[position]}, #{position}"
      opcode, mode = decode_opcode(tape, position)
      #p "mode: #{mode}"
      op = OPCODE_MAP[opcode]
      tape, position = op.call(tape, position, mode)
    rescue Halt
      halted = true
    end
  end
  nil
end

def brute_force
  standard_tape = read_tape(File.read("input.txt"))
  target = 19690720

  (0..99).each do |noun|
    (0..99).each do |verb|
      tape = standard_tape.dup
      tape[1] = noun
      tape[2] = verb
      tape = process_tape(tape)
      return 100 * noun + verb if tape[0] == target
    end
  end
end
