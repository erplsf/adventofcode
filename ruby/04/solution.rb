require "byebug"

def read_range(string)
  f, l = string.split("-").map(&:to_i)
  f..l
end

def count_range(range)
  count = 0

  range.each do |pw|
    count += 1 if matches?(pw)
  end

  count
end

def matches?(password)
  pw = password.to_s

  valid = true
  pairs_count = Hash.new(0)
  index = 0

  while index < pw.length - 1
    range = index..index + 1
    #p "range: #{range}"
    pw[range].split("").each_slice(2) do |a, b|
      #p "a, b: #{a}, #{b}"
      valid = false if (a.to_i > b.to_i)
      pairs_count[a.to_i] += 1 if a.to_i == b.to_i
      break unless valid
    end
    index += 1
  end

  #byebug
  pairs_count = pairs_count.values
  valid = if valid
            if pairs_count.select { |c| c >= 2 }
              if !pairs_count.select { |c| c == 1 }.empty?
                true
              else
                false
              end
            else
              if !pairs_count.select { |c| c == 1 }.empty?
                true
              end
            end
          end
  valid
end
