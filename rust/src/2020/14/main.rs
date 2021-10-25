use std::collections::HashMap;
use adventofcode::lib::parse_file;

fn parse_mask_line(string: &str) -> String {
    string.split("=").filter_map(|part| Some(part.trim())).last().unwrap().to_string()
}

fn parse_mem_line(string: &str) -> (usize, usize) {
    let mem_pos: usize;
    let val: usize;
    let split: Vec<&str> = string.split("=").map(|part| part.trim()).collect();
    val = split.last().unwrap().parse().unwrap();
    let mut v: String = split.first().unwrap().chars().skip(4).collect();
    v.pop();
    mem_pos = v.parse().unwrap();
    (mem_pos, val)
}

fn binarize(number: usize) -> String {
    format!("{:036b}", number)
}

fn apply_mask(value: usize, mask: &str) -> usize {
    let binary_value = binarize(value);
    let zip: String = mask.chars().zip(binary_value.chars()).map(|(mask_bit, value_bit)| {
        if mask_bit == 'X' {
            value_bit
        } else {
            mask_bit
        }
    }).collect();
    usize::from_str_radix(&zip, 2).unwrap()
}

fn apply_decode_mask(value: usize, mask: &str) -> Vec<String> {
    let binary_value = binarize(value);
    let mem_addr: String = mask.chars().zip(binary_value.chars()).map(|(mask_bit, value_bit)| {
        if mask_bit == '0' {
            value_bit
        } else {
            mask_bit
        }
    }).collect();
    expand_mem_addr(&mem_addr)
}

fn expand_mem_addr(mask: &str) -> Vec<String> {
    let mut addr = String::with_capacity(mask.len());
    let mut addresses = vec![];
    let mut plain = true;
    for (i, bit) in mask.chars().enumerate() {
        if bit == 'X' {
            // TODO:
            addresses.extend(expand_mem_addr(&(addr.clone() + "0" + &mask[i+1..])));
            addresses.extend(expand_mem_addr(&(addr.clone() + "1" + &mask[i+1..])));
            plain = false;
            break;
        } else {
            addr.push(bit);
        }
    }
    if plain {
        addresses.push(addr);
    }
    addresses
}

fn main() {
    let contents = parse_file().unwrap();
    let mut mask: String = String::new();
    let mut mem: HashMap<usize, usize> = HashMap::new();
    for line in contents.lines() {
        if line.contains("mask") {
            mask = parse_mask_line(line);
        } else if line.contains("mem") {
            let (pos, value) = parse_mem_line(line);
            let masked_value = apply_mask(value, &mask);
            mem.insert(pos, masked_value);
        } else {
            panic!("unsupported line found!");
        }
    }
    let sum: usize = mem.values().sum();
    dbg!(&sum);

    let mut mask: String = String::new();
    let mut mem: HashMap<usize, usize> = HashMap::new();
    for line in contents.lines() {
        if line.contains("mask") {
            mask = parse_mask_line(line);
        } else if line.contains("mem") {
            let (pos, value) = parse_mem_line(line);
            let mem_positions = apply_decode_mask(pos, &mask);
            for mem_position in mem_positions {
                // dbg!(&mem_position);
                // dbg!(&mem_position);
                let mem_pos = usize::from_str_radix(&mem_position, 2).unwrap();
                // dbg!(mem_pos);
                mem.insert(mem_pos, value);
            }
            let masked_value = apply_mask(value, &mask);
        } else {
            panic!("unsupported line found!");
        }
    }
    let sum: usize = mem.values().sum();
    dbg!(&sum);
}
