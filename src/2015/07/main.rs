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

    fn get_mut(&mut self, name: &str) -> &mut Wire {
        self.board.get_mut(name).unwrap()
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
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    let mut b = Board::new();
    let w = Wire::new(None, Some(Box::new(|| 15 )));
    b.insert("a", w);
    let w = b.get_mut("a");
    dbg!(w.value());
    Ok(())
}
