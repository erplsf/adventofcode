use adventofcode::lib::parse_file;
use std::collections::HashMap;

#[derive(Debug)]
struct Board {
    board: HashMap<String, Wire>
}

impl Board {
    fn new() -> Self {
        Self { board: HashMap::new() }
    }

    fn insert(&mut self, name: &str, wire: Wire) {
        self.board.insert(name.to_string(), wire);
    }

    fn get_mut(&mut self, name: &str) -> Option<&mut Wire> {
        self.board.get_mut(name)
    }

    fn resolve(&mut self, name: &str) -> u16 {
        // try checking if we got a number to lookup.
        // possible in the case if input to a recursive function is a parse-able string.
        // if we parsed it successfully, return it early
        if let Ok(parsed) = name.parse::<u16>() { return parsed }
        
        // otherwise, lookup number in the registry and check if we already have value for it
        let wire = self.board.get(name).expect("Can't resolve - supplied wire is not in the registry.");
        match wire.value {
            Some(value) => value, // if yes, return it early
            None => {
                // otherwise, resolve (recursively) all inputs and compute it
                let computed_inputs: Vec<u16> = wire.inputs.clone().unwrap().into_iter().map(|name| { // .clone() is the most important thing here - it allows us to satisfy borrow checker
                    self.resolve(&name)
                }).collect();
                let wire = self.board.get_mut(name).unwrap(); // rebind to the wire, now mutably, as we want to replace it's value later
                let result = wire.compute(computed_inputs); // compute the value with resolved inputs
                wire.value = Some(result); // set the value
                return result // return it
            }
        }
    }
}

#[derive(Debug,Clone,Copy)]
enum Gate {
    OR,
    AND,
    NOT,
    LSHIFT(u8),
    RSHIFT(u8),
    DIRECT
}

#[derive(Debug,Clone)]
struct Wire {
    inputs: Option<Vec<String>>,
    gate: Option<Gate>,
    value: Option<u16>,
}

impl Wire {
    fn new(inputs: Option<Vec<String>>, gate: Option<Gate>, value: Option<u16>) -> Self {
        if value.is_some() || (gate.is_some() && inputs.is_some()) {
            Self { inputs: inputs, gate: gate, value: value }
        } else {
            panic!("Either value or inputs AND gate must contain value.")
        }
    }

    fn compute(&self, inputs:Vec<u16>) -> u16 {
        match &self.gate {
            None => panic!("No gate - no way to compute!"),
            Some(op) => {
                match op {
                    Gate::OR => inputs[0] | inputs[1],
                    Gate::AND => inputs[0] & inputs[1],
                    Gate::NOT => !inputs[0],
                    Gate::LSHIFT(shift) => inputs[0] << shift,
                    Gate::RSHIFT(shift) => inputs[0] >> shift,
                    Gate::DIRECT => inputs[0]
                }
            }
        }
    }
}

fn parse_line(line: &str) -> (&str, Wire) {
    let sides: Vec<&str> = line.split("->").collect();
    let name = sides[1].trim();
    let expression = sides[0].trim().split(' ').collect::<Vec<&str>>();
    let wire = match expression.len() { // length of the split expression on the left
        1 => { // value or reference to another wire
            match expression[0].parse::<u16>() {
                Ok(val) => Wire::new(None, None, Some(val)),
                Err(_) => Wire::new(Some(vec![expression[0].to_string()]), Some(Gate::DIRECT), None)
            }
        },
        2 => Wire::new(Some(vec![expression[1].to_string()]), Some(Gate::NOT), None),
        3 => {
            let (left, right) = (expression[0].to_string(), expression[2].to_string());
            match expression[1] {
                "AND" => Wire::new(Some(vec![left, right]), Some(Gate::AND), None),
                "OR" => Wire::new(Some(vec![left, right]), Some(Gate::OR), None),
                "LSHIFT" => Wire::new(Some(vec![left]), Some(Gate::LSHIFT(right.parse().unwrap())), None),
                "RSHIFT" => Wire::new(Some(vec![left]), Some(Gate::RSHIFT(right.parse().unwrap())), None),
                _ => panic!("Unsupported operation found!")
            }
        },
        _ => panic!("Unsupported expression on the left found!")
    };
    (name, wire)
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    let mut first_board = Board::new();
    let mut second_board = Board::new();
    
    let contents = parse_file().unwrap();
    for line in contents.lines() {
        let (name, wire) = parse_line(line);
        first_board.insert(name, wire.clone());
        second_board.insert(name, wire);
    }
    dbg!(first_board.resolve("a"));
    let a = first_board.resolve("a");
    second_board.get_mut("b").unwrap().value = Some(a); // set the "b"-gate value to the "a" value of the first run
    dbg!(second_board.resolve("a"));
    Ok(())
}
