use adventofcode::lib::parse_file;


fn parse_pass(pass: &str) -> usize {
    let rows = &pass[..7];
    let columns = &pass[7..];
    
    let mut rll = 0;
    let mut rul = 127;

    // dbg!(rows);
    for direction in rows.chars() {
        match direction {
            'F' => {
                rul = rul - (rul - rll) / 2 - 1;
            },
            'B' => {
                rll = rll + (rul - rll) / 2 + 1;
            },
            _ => {},
        }
        // dbg!(direction, rul, rll);
    }

    let mut cll = 0;
    let mut cul = 7;
    for direction in columns.chars() {
        match direction {
            'L' => {
                cul = cul - (cul - cll) / 2 - 1;
            },
            'R' => {
                cll = cll + (cul - cll) / 2 + 1;
            },
            _ => {},
        }
        // dbg!(direction, rul, rll);
    }
    debug_assert!(rll == rul);
    debug_assert!(cll == cul);
    rll * 8 + cll
}

fn main() {
    debug_assert!(parse_pass("FBFBBFFRLR") == 357);
    let contents = parse_file().unwrap();
    let mut max_seat_id = 0;
    let mut seats: Vec<usize> = vec![];
    for pass in contents.lines() {
        let seat_id = parse_pass(pass);
        seats.push(seat_id);
        if seat_id > max_seat_id {
            max_seat_id = seat_id;
        }
    }
    dbg!(max_seat_id);
    seats.sort();
    for chunk in seats.windows(2) {
        if chunk.len() == 2 {
            let p = chunk[0];
            let n = chunk[1];
            let d = n - p;
            if d == 2 {
                dbg!(p + 1);
            }
        }
    }
}
