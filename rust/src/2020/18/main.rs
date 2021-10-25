use adventofcode::lib::parse_file;
use std::collections::VecDeque;

fn precedence(string: &str) -> usize {
    // dbg!(&string);
    match string {
        "+" => 2,
        "*" => 1,
        _ => 0,
    }
}

fn postfixize(string: &str) -> Vec<String> {
    let mut stack = vec![];
    let mut postfix_stack = vec![];
    let m: Vec<_> = string.split_ascii_whitespace().collect();
    for atom in m {
        if atom.contains('(') {
            let c = atom.matches('(').count();
            for _ in 0..c {
                stack.push("(".to_string());
            }
            postfix_stack.push(atom.replace("(", ""));
        } else if atom.contains(')') {
            // dbg!(&atom);
            let c = atom.matches(')').count();
            // for _ in 0..c {
            //     stack.push(")".to_string());
            // }
            postfix_stack.push(atom.replace(")", ""));
            // dbg!(&postfix_stack, &stack);
            for _ in 0..c {
                while stack.len() > 0 && stack.last().unwrap() != "(" {
                    postfix_stack.push(stack.pop().unwrap());
                }
                stack.pop();
            }
            // dbg!(&postfix_stack, &stack);
        } else if atom.chars().all(|c| c.is_digit(10)) {
            postfix_stack.push(atom.to_string());
        } else {
            if stack.len() > 0 && precedence(atom) > precedence(stack.last().unwrap()) {
                stack.push(atom.to_string());
            } else {
                // dbg!(atom, &stack);
                while stack.len() > 0 && precedence(atom) <= precedence(stack.last().unwrap()) {
                    postfix_stack.push(stack.pop().unwrap());
                }
                // dbg!(&stack, &postfix_stack);
                // dbg!(&stack);
                stack.push(atom.to_string());
            }
        }
    }

    while stack.len() > 0 {
        postfix_stack.push(stack.pop().unwrap());
    }
    // dbg!(postfix_stack, stack);
    postfix_stack
}

fn math(pvn: &Vec<String>) -> usize {
    // dbg!(&pvn);
    let mut math_stack = vec![];
    for atom in pvn {
        if atom.chars().all(char::is_numeric) {
            let num: usize = atom.parse().unwrap();
            math_stack.push(num);
        } else {
            // dbg!(&math_stack, atom);
            match atom.as_ref() {
                "+" => {
                    let n1 = math_stack.pop().unwrap();
                    let n2 = math_stack.pop().unwrap();
                    math_stack.push(n1 + n2);
                }
                "*" => {
                    let n1 = math_stack.pop().unwrap();
                    let n2 = math_stack.pop().unwrap();
                    math_stack.push(n1 * n2);
                }
                _ => {}
            }
        }
    }
    math_stack.pop().unwrap()
}

fn main() {
    dbg!(math(&postfixize("1 + 2 * 3 + 4 * 5 + 6")));
    dbg!(math(&postfixize("1 + (2 * 3) + (4 * (5 + 6))")));
    dbg!(math(&postfixize("2 * 3 + (4 * 5)")));
    dbg!(math(&postfixize("5 + (8 * 3 + 9 + 3 * 4 * 3)")));
    dbg!(math(&postfixize(
        "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"
    )));
    dbg!(math(&postfixize(
        "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
    )));

    // let post  = postfixize("5 + ((6 * 9 + 5 + 5) + 2 * (4 + 4 + 2 * 6 + 3 + 9)) * ((3 * 5 * 2 * 8 * 5) + 2 * (4 + 9 + 5 * 9 * 8) + (2 + 6 * 6 * 5 + 3 + 9)) * (2 + 9 * 9) + 2 * 6");
    // dbg!(math(&post));
    // before: [src/2020/18/main.rs:76] math(&post) =   4722410034948
    // after:  [src/2020/18/main.rs:76] math(&post) =   4397872159301
    // after_v2: [src/2020/18/main.rs:86] math(&post) = 4402499492964
    let contents = parse_file().unwrap();
    let mut res: Vec<_> = contents
        .lines()
        .map(|line| {
            let post = postfixize(line);
            math(&post)
        })
        .collect();
    let sum: usize = res.iter().sum();
    dbg!(sum);
}
