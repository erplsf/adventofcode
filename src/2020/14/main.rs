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

fn apply_decode_mask(value: usize, mask: &str) -> Vec<usize> {
    let binary_value = binarize(value);
    let zip: String = mask.chars().zip(binary_value.chars()).map(|(mask_bit, value_bit)| {
        if mask_bit == '0' {
            value_bit
        } else {
            mask_bit
        }
    }).collect();
    // dbg!(&zip);
    vec![]
}

fn expand_mem_addr(mask: &str) -> Vec<String> {
    let mut addr = String::with_capacity(mask.len());
    let mut addresses = vec![String::with_capacity(mask.len())];
    for bit in mask.chars() {
        if bit == 'X' {
            // TODO:
        } else {
            addr.push(bit);
        }
    }
    addresses.push(addr);
    addresses
}

fn main() {
    // let contents = parse_file().unwrap();
    // let mut mask: String = String::new();
    // let mut mem: HashMap<usize, usize> = HashMap::new();
    // for line in contents.lines() {
    //     if line.contains("mask") {
    //         mask = parse_mask_line(line);
    //     } else if line.contains("mem") {
    //         let (pos, value) = parse_mem_line(line);
    //         let masked_value = apply_mask(value, &mask);
    //         mem.insert(pos, masked_value);
    //     } else {
    //         panic!("unsupported line found!");
    //     }
    // }
    // let sum: usize = mem.values().sum();
    // dbg!(&sum);

    let mask = parse_mask_line("mask = 000000000000000000000000000000X1001X");
    let (pos, value) = parse_mem_line("mem[42] = 100");    
    // dbg!(mask, pos, value);
    let res = apply_decode_mask(pos, &mask);
}
