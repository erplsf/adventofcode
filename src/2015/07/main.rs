use adventofcode::lib::parse_file;
use std::collections::HashMap;

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

    fn value(&self, name: &str) -> Option<u16> {
        match self.board.get(name) {
            Some(wire) => wire.value,
            None => None
        }
    }

    fn resolve(&self, name: &str) -> u16 {
        let wire = self.board.get(name).unwrap();
        match wire.value {
            Some(value) => value,
            None => { // implement the recursive input-loop stuff here
                let computed_inputs: Vec<u16> = wire.inputs.as_ref().unwrap().into_iter().map(|name| {
                    self.resolve(&name)
                }).collect();
                let wire = self.board.get(name).unwrap();
                let result = wire.compute(computed_inputs);
                // wire.value = Some(result);
                result
            }
        }
    }
}

enum Gate {
    OR,
    AND,
    NOT,
    LSHIFT(u8),
    RSHIFT(u8)
}

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
            panic!("Either value or inputs and gate must contain value.")
        }
    }
    
    fn value(&mut self) -> u16 {
        // if there is static value, or precomputed - return it
        if let Some(value) = self.value {
            return value
        } else {
            panic!("Unreachable branch!");
        }
    }

    fn compute(&self, mut inputs:Vec<u16>) -> u16 {
        match &self.gate {
            None => panic!("No gate - no way to compute!"),
            Some(op) => {
                match op {
                    Gate::OR => inputs[0] | inputs[1],
                    Gate::AND => inputs[0] & inputs[1],
                    Gate::NOT => !inputs[0],
                    Gate::LSHIFT(shift) => inputs[0] << shift,
                    Gate::RSHIFT(shift) => inputs[0] >> shift
                }
            }
        }
    }
}

// enum ParseResult {
//     Value(u8),
    
// }

fn parse_line(line: &str) -> Wire {
    let mut sides: Vec<&str> = line.split("->").collect();
    let name = sides[0].trim();
    let mut expression = sides[1].trim().split(' ').collect::<Vec<&str>>();
    match expression.len() {
        1 => Wire::new(None, None, Some(expression[0].parse::<u16>().unwrap())),
        2 => Wire::new(Some(vec![expression[1].to_string()]), Some(Gate::NOT), None),
        3 => {
            let (left, right) = (expression[0].to_string(), expression[1].to_string());
            match expression[1] {
                "AND" => Wire::new(Some(vec![left, right]), Some(Gate::AND), None),
                "OR" => Wire::new(Some(vec![left, right]), Some(Gate::OR), None),
                "LSHIFT" => Wire::new(Some(vec![left]), Some(Gate::LSHIFT(right.parse().unwrap())), None),
                "RSHIFT" => Wire::new(Some(vec![left]), Some(Gate::RSHIFT(right.parse().unwrap())), None),
                _ => panic!("Unsupported operation found!")
            }
        },
        _ => panic!("Unsupported string found!")
        }
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    let contents = parse_file().unwrap();
    for line in contents.lines() {
        parse_line(line);
    }
    let mut board = Board::new();
    Ok(())
}
