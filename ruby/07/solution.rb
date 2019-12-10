# frozen_string_literal: true

def read_tape(string)
  string.split(',').map(&:to_i)
end

class Halt < StandardError; end

OPCODE_MAP = {
  # MATH
  '01' => lambda do |args|
    tape, position, mode = args.take(3)
    args = process_mode(tape, position, mode)
    # p "position, args, mode: #{position} #{tape[position..-1].take(4)} #{mode}"
    p3 = tape[position + 3]

    tape[p3] = args.sum

    position += 4
    [tape, position]
  end,
  '02' => lambda do |args|
    tape, position, mode = args.take(3)
    args = process_mode(tape, position, mode)
    # p "position, args, mode: #{position} #{tape[position..-1].take(4)} #{mode}"
    p3 = tape[position + 3]

    tape[p3] = args.inject(:*)

    position += 4
    [tape, position]
  end,
  # IO
  # read from console ->
  '03' => lambda do |args|
    tape, position, _mode, io = args.take(4)
    # p "position, args, mode: #{position} #{tape[position..-1].take(2)} #{mode}"
    target = tape[position + 1]
    # io[:stdout].print "Input an integer: "
    input = io[:stdin].gets.chomp.to_i
    tape[target] = input
    position += 2
    [tape, position]
  end,
  # write to console ->
  '04' => lambda do |args|
    tape, position, mode, io = args.take(4)
    args = process_mode(tape, position, mode)
    # p "position, args, mode: #{position} #{tape[position..-1].take(2)} #{mode}"
    io[:stdout].puts args.first
    position += 2
    [tape, position]
  end,
  # TODO: Implement jumps
  # jmps
  '05' => lambda do |args|
    tape, position, mode = args.take(3)
    args = process_mode(tape, position, mode)
    position = if args[0] != 0
                 args[1]
               else
                 position + 3
               end
    [tape, position]
  end,
  '06' => lambda do |args|
    tape, position, mode = args.take(3)
    args = process_mode(tape, position, mode)
    position = if args[0] == 0
                 args[1]
               else
                 position + 3
               end
    [tape, position]
  end,
  '07' => lambda do |args|
    tape, position, mode = args.take(3)
    args = process_mode(tape, position, mode)
    p3 = tape[position + 3]
    tape[p3] = if args[0] < args[1]
                 1
               else
                 0
               end
    position += 4
    [tape, position]
  end,
  '08' => lambda do |args|
    tape, position, mode = args.take(3)
    args = process_mode(tape, position, mode)
    p3 = tape[position + 3]
    tape[p3] = if args[0] == args[1]
                 1
               else
                 0
               end
    position += 4
    [tape, position]
  end,
  # HALT
  '99' => lambda do |_args|
    raise Halt
  end
}.freeze

def process_mode(tape, position, mode)
  if mode.last == 1
    raise 'Target mode (last bit) should never be 1 (immediate)!'
  end

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
  full_opcode = tape[position].to_s.rjust(5, '0')
  mode = full_opcode[0..2].split('').map(&:to_i).reverse
  opcode = full_opcode[-2..-1]
  [opcode, mode]
end

def process_tape(tape, stdin = $stdin, stdout = $stdout)
  tape = tape.dup
  position = 0
  halted = false

  until halted
    begin
      # p "Instruction at head, position: #{tape[position]}, #{position}"
      opcode, mode = decode_opcode(tape, position)
      # p "mode: #{mode}"
      op = OPCODE_MAP[opcode]
      tape, position = op.call([tape, position, mode, { stdin: stdin, stdout: stdout }])
    rescue Halt
      halted = true
    end
  end
  tape
end

def wrap_process(tape, input_string)
  stdin = StringIO.new(input_string)
  stdout = StringIO.new
  tape = process_tape(tape, stdin, stdout)
  [tape, stdout.string.dup]
end

def max_amplifiers_1(tape)
  max = { val: -1, settings: '' }
  (0..4).to_a.permutation.to_a.each do |a, b, c, d, e|
    _, a_o = wrap_process(tape, (a.to_s + "\n0\n"))
    _, b_o = wrap_process(tape, (b.to_s + "\n" + a_o))
    _, c_o = wrap_process(tape, (c.to_s + "\n" + b_o))
    _, d_o = wrap_process(tape, (d.to_s + "\n" + c_o))
    _, e_o = wrap_process(tape, (e.to_s + "\n" + d_o))
    eo = e_o.to_i
    next unless eo > max[:val]

    max[:val] = eo
    max[:settings] = [a, b, c, d, e]
  end
  max
end
