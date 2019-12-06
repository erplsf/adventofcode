def read_tape(string)
  string.split(",").map(&:to_i)
end

class Halt < StandardError; end

OPCODE_MAP = {
  1 => lambda do |tape, position|
    p1 = tape[position + 1]
    p2 = tape[position + 2]
    p3 = tape[position + 3]

    tape[p3] = tape[p1] + tape[p2]

    position = position + 4
    [tape, position]
  end,
  2 => lambda do |tape, position|
    p1 = tape[position + 1]
    p2 = tape[position + 2]
    p3 = tape[position + 3]

    tape[p3] = tape[p1] * tape[p2]

    position = position + 4
    [tape, position]
  end,
  99 => lambda do |tape, position|
    raise Halt
  end,
}

def process_tape(tape)
  tape = tape.dup
  position = 0
  halted = false

  while (!halted)
    begin
      opcode = tape[position]
      op = OPCODE_MAP[opcode]
      tape, position = op.call(tape, position)
    rescue Halt
      halted = true
    end
  end

  tape
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
