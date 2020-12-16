fn parse_mask(string: &str) -> Vec<char> {
    let res  = string.split("=").filter_map(|part| Some(part.trim())).last().unwrap();
    dbg!(res);
    vec![]
}

fn binarize_number(number: usize) -> String {
    format!("{:036b}", number)
}

fn main() {
    // let mask_string = "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X";
    // parse_mask(mask_string);
    println!("{}", binarize_number(11));
}
