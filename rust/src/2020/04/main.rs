use adventofcode::lib::parse_file;

struct Field<'a> {
    pub key: &'a str,
    pub rule: Box<dyn Fn(&str) -> bool>,
}

fn main() {
    let mut valid_count = 0;
    let required_fields = vec![
        Field {
            key: "byr",
            rule: Box::new(|v| {
                if v.len() == 4 {
                    let year: usize = v.parse().unwrap();
                    (1920..=2002).contains(&year)
                } else {
                    false
                }
            }),
        },
        Field {
            key: "iyr",
            rule: Box::new(|v| {
                if v.len() == 4 {
                    let year: usize = v.parse().unwrap();
                    (2010..=2020).contains(&year)
                } else {
                    false
                }
            }),
        },
        Field {
            key: "eyr",
            rule: Box::new(|v| {
                if v.len() == 4 {
                    let year: usize = v.parse().unwrap();
                    (2020..=2030).contains(&year)
                } else {
                    false
                }
            }),
        },
        Field {
            key: "hgt",
            rule: Box::new(|v| {
                // dbg!(&v);
                let measure = &v[v.len() - 2..];
                // dbg!(measure);
                if measure == "cm" {
                    let h: usize = v[0..v.len() - 2].parse().ok().unwrap();
                    if (150..=193).contains(&h) {
                        return true;
                    }
                } else if measure == "in" {
                    let h: usize = v[0..v.len() - 2].parse().ok().unwrap();
                    if (59..=76).contains(&h) {
                        return true;
                    }
                }
                false
            }),
        },
        Field {
            key: "hcl",
            rule: Box::new(|v| {
                if v.len() == 7
                    && v.chars().next() == Some('#')
                    && v[1..].chars().all(|c| char::is_ascii_hexdigit(&c))
                {
                    return true;
                }
                false
            }),
        },
        Field {
            key: "ecl",
            rule: Box::new(|v| {
                vec!["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].contains(&v)
            }),
        },
        Field {
            key: "pid",
            rule: Box::new(|v| {
                v.len() == 9 && v.parse::<usize>().ok().is_some()
            }),
        },
        ];
    // let required_fields = vec!["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"];
    let contents = parse_file().unwrap();
    let passports = contents.split("\n\n");
    for passport in passports {
        let mut passport_missing_fields = required_fields.len();
        let fields: Vec<&str> = passport.split_whitespace().collect();
        // dbg!(fields);
        for field in fields {
            let split = field.split(':').collect::<Vec<&str>>();
            let mut split_iter = split.iter();
            let key = split_iter.next().unwrap();
            let val = split_iter.next().unwrap();
            if let Some(index) = required_fields.iter().position(|x| &x.key == key) {
                if (required_fields[index].rule)(val) {
                    passport_missing_fields = passport_missing_fields - 1;
                }
            }
        }
        if passport_missing_fields == 0 {
            valid_count = valid_count + 1
        }
    }
    dbg!(valid_count);
}
