def read_range(string)
  f, l = string.split('-').map(&:to_i)
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
  has_pair = false
  index = 0
  
  while index < pw.length - 1
    range = index..index + 1
    #p "range: #{range}"
    pw[range].split('').each_slice(2) do |a, b|
      #p "a, b: #{a}, #{b}"
      valid = false if (a.to_i > b.to_i)
      has_pair = true if a.to_i == b.to_i
      break unless valid
    end
    index += 1
  end

  valid = has_pair if valid
  valid
end
