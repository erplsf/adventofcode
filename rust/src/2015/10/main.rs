fn look_and_say(seq: &str) -> String {
    let mut frequencies: Vec<(char, usize)> = vec![];
    let mut sequence = seq.chars();
    let mut prev = sequence.next().unwrap();
    frequencies.push((prev, 1));
    for character in sequence {
        if character == prev {
            let freq = frequencies.last_mut().unwrap();
            freq.1 = freq.1 + 1;
        } else {
            frequencies.push((character, 1))
        }
        prev = character;
    }
    
    let mut result = String::new();
    for (ch, count) in frequencies {
        result.push_str(&count.to_string());
        result.push_str(&ch.to_string());
    }
    result
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    let mut res = "1".to_string();
    for _ in 0..5 {
        res = look_and_say(&res);
    }
    debug_assert_eq!(&res, "312211");

    let mut res = "3113322113".to_string();
    for _ in 0..40 {
        res = look_and_say(&res);
    }
    dbg!(res.len());

    let mut res = "3113322113".to_string();
    for _ in 0..50 {
        res = look_and_say(&res);
    }
    dbg!(res.len());
    
    Ok(())
}
