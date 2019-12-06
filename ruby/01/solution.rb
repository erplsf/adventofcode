def get_fuel(weight)
  amount = (weight / 3) - 2
  amount > 0 ? amount : 0
end

def get_total_fuel(weight)
  total = 0
  amount = get_fuel(weight)

  while amount > 0
    total += amount

    amount = get_fuel(amount)
  end

  return total
end

def mem_total_fuel(weight, mem: Hash.new(-1))
  if mem[weight] >= 0
    return [mem[weight], mem]
  else
    total = 0

    amount = get_fuel(weight)

    if amount > 0
      val, _mem = mem_total_fuel(amount, mem: mem)
    else
      val = 0
    end

    total += (amount + val)

    mem[weight] = total

    return [total, mem]
  end
end

require "benchmark"

if $0 == __FILE__
  filename = ARGV[0]
  fuels = File.read(filename).split.map(&:to_i)

  nv = fuels.inject(0) { |carry, fuel|
    carry += get_total_fuel(fuel)
  }

  ov = fuels.inject({ sum: 0, mem: Hash.new(-1) }) { |carry, fuel|
    sum, mem = mem_total_fuel(fuel, mem: carry[:mem])
    carry[:sum] = carry[:sum] + sum
    #carry[:mem] = mem
    carry
  }[:sum]

  p "naive run: #{nv}"
  p "'optimized' run: #{ov}"

  Benchmark.bmbm do |x|
    x.report("naive method") do
      fuels.inject(0) { |carry, fuel|
        carry += get_total_fuel(fuel)
      }
    end

    x.report("'optimized' method") do
      fuels.inject({ sum: 0, mem: Hash.new(-1) }) { |carry, fuel|
        sum, mem = mem_total_fuel(fuel, mem: carry[:mem])
        carry[:sum] = carry[:sum] + sum
        #carry[:mem] = mem
        carry
      }
    end
  end
end

# Conclusion: badly implemented recursion/memoization can worsen the performance
