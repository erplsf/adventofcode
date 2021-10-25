// trait WrapAscii {
//     fn next_lowercase(&self) -> char;
// }

// impl WrapAscii for char {
//     fn next_lowercase(&self) -> char {
//         if (*self as u8) == 122 { // lowercase z
//             'a'
//         } else {
//             (*self as u8 + 1) as char
//         }
//     }
// }

// const FORBIDDEN: [char; 3] = ['i', 'o', 'l'];

// fn next_password(pass: &str) -> String {
//     FORBIDDEN.iter().map(|ch| pass.contains(ch)).any(|_| false);
//     // for (i, char) in pass.chars().enumerate() {

//     // }

//     "".to_string()
// }

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    let c = 'f';
    // println!("{:?}", c.next_lowercase());
    Ok(())
}
