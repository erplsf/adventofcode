def read_string(string, width, height)
  layer_size = width * height
  string.scan(/.{#{layer_size}}/)
end

def form_layer(layer, width, height)
  layer.scan(/.{#{width}}/)
end

def print_layer(layer)
  layer.each do |line|
    line.split("").each do |pixel|
      case pixel
      when "0"
        print "[30m.[0m"
      when "1", "2"
        print "[44m[30m.[0m[0m"
      end
    end
    puts
  end
end

def find_checksum(image)
  minimal_layer = image.min_by { |layer| layer.split("").count { |p| p == "0" } }
  minimal_layer.split("").count { |p| p == "1" } * minimal_layer.split("").count { |p| p == "2" }
end

def minimize_image(image)
  image = image.dup
  final_layer = ""
  top_layer = image.shift
  top_layer.split("").each_with_index do |p, i|
    case p
    when "0"
      final_layer << "0"
    when "1"
      final_layer << "1"
    when "2"
      final_layer << find_pixel_color(image, i)
    end
  end
  final_layer
end

def pixel_stack(image, i)
  image.map do |layer|
    layer.split("")[i]
  end
end

def find_pixel_color(image, i)
  pixel_stack(image, i).uniq.find { |c| c != "2" }
end

if __FILE__ == $0
  image = read_string(File.read(ARGV[0]), 25, 6)
  layer = minimize_image(image)
  layer = form_layer(layer, 25, 6)
  print_layer(layer)
end
