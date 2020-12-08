use adventofcode::lib::parse_file;
use std::collections::HashMap;
use std::convert::TryInto;

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
enum Code {
    NOP,
    ACC,
    JMP,
}

type Implementation = Box<dyn Fn(i32, usize, i32) -> (usize, i32)>;

struct Machine {
    tape: Vec<(Code, i32)>,
    executed: Vec<usize>,
    accumulator: i32,
    head: usize,
    instructions: HashMap<Code, Implementation>,
}

impl Machine {
    pub fn new(tape: Vec<(Code, i32)>) -> Self {
        let mut instructions: HashMap<Code, Implementation> = HashMap::new();
        instructions.insert(Code::NOP, Box::new(|_arg, head, acc| (head + 1, acc)));
        instructions.insert(Code::ACC, Box::new(|arg, head, acc| (head + 1, acc + arg)));
        instructions.insert(
            Code::JMP,
            Box::new(|arg, head, acc| (((head as i32) + arg).try_into().unwrap(), acc)),
        );
        Self {
            tape,
            executed: vec![],
            accumulator: 0,
            head: 0,
            instructions,
        }
    }

    fn execute(&self, code: Code, arg: i32) -> (usize, i32) {
        let (head, acc) = (self.instructions[&code])(arg, self.head, self.accumulator);
        (head, acc)
    }

    pub fn run(&mut self) {
        self.reset();
        loop {
            if self.executed.contains(&self.head) || self.head == self.tape.len() {
                // TODO: return break reason - end of tape or loop
                break;
            }
            let (code, arg) = self.tape[self.head];
            let (head, acc) = self.execute(code, arg);
            self.executed.push(self.head);
            // dbg!(self.head, head);
            self.head = head;
            self.accumulator = acc;
        }
    }

    pub fn filter_executed_to_jmp_nop(&self) -> Vec<usize> {
        self.executed
            .iter()
            .filter_map(|pos| {
                let (code, _arg) = self.tape[*pos];
                if code == Code::JMP || code == Code::NOP {
                    return Some(*pos);
                }
                None
            })
            .collect()
    }

    fn toogle_code(&mut self, pos: usize) {
        let (code, arg) = self.tape[pos];
        let new_code = match code {
            Code::NOP => Code::JMP,
            Code::JMP => Code::NOP,
            Code::ACC => Code::ACC,
        };
        self.tape[pos] = (new_code, arg);
    }

    fn reset(&mut self) {
        self.head = 0;
        self.accumulator = 0;
        self.executed = vec![];
    }

    pub fn fix_tape(&mut self) {
        self.reset();
        self.run();
        let original_tape = self.tape.clone();
        let possible_codes = self.filter_executed_to_jmp_nop();
        for code_pos in possible_codes {
            self.toogle_code(code_pos);
            self.run();
            if self.head == self.tape.len() {
                break;
            }
            self.reset();
            self.tape = original_tape.clone();
        }
    }
}

fn parse_line(line: &str) -> (Code, i32) {
    let mut iter = line.trim().split_whitespace();
    let code = match iter.next().unwrap() {
        "nop" => Code::NOP,
        "acc" => Code::ACC,
        "jmp" => Code::JMP,
        _ => panic!("Unsupported operation found!"),
    };
    let num = iter.next().unwrap();
    let sign = match num.chars().nth(0).unwrap() {
        '-' => -1,
        '+' => 1,
        _ => panic!("Unsupported math sign found!"),
    };
    let mut arg = num[1..].parse().unwrap();
    arg *= sign;
    (code, arg)
}

fn main() {
    let contents = parse_file().unwrap();
    let tape: Vec<(Code, i32)> = contents.lines().map(|line| parse_line(line)).collect();
    let mut machine = Machine::new(tape);
    machine.run();
    dbg!(&machine.accumulator);
    machine.fix_tape();
    dbg!(&machine.accumulator);
}
