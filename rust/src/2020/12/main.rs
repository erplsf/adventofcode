use adventofcode::lib::parse_file;
use std::convert::TryInto;

#[derive(Debug)]
enum Command {
    N(i64),
    S(i64),
    E(i64),
    W(i64),
    L(i16),
    R(i16),
    F(i64),
}

struct Ferry {
    w_dx: i64,
    w_dy: i64,
    x: i64,     // east (right) +, west (left) -
    y: i64,     // north (up) +, south (down) -
    angle: i16, // starting 0, (facing east), + (R) goes clockwise, - (L) goes counter clockwise
}

impl Ferry {
    pub fn new() -> Self {
        Ferry {
            w_dx: 10,
            w_dy: 1,
            x: 0,
            y: 0,
            angle: 0,
        }
    }

    pub fn execute_simple(&mut self, command: Command) {
        // dbg!(&command);
        // dbg!(self.x, self.y);
        match command {
            Command::N(step) => self.y += step,
            Command::S(step) => self.y -= step,
            Command::E(step) => self.x += step,
            Command::W(step) => self.x -= step,
            Command::L(angle) => {
                let mut new_angle = self.angle - angle;
                if new_angle < 0 {
                    new_angle = 360 + new_angle // + because new_angle is negative
                }
                self.angle = new_angle;
            }
            Command::R(angle) => self.angle = (self.angle + angle) % 360,
            Command::F(step) => {
                let rad = ((self.angle - 90) as f64) * std::f64::consts::PI / (180 as f64); // -90 correction for starting east heading
                // dbg!(self.x, self.y);
                let new_x = (step as f64) * f64::cos(rad);
                let new_y = (step as f64) * f64::sin(rad);
                // dbg!(new_x, new_y);
                self.x += new_x as i64;
                self.y += new_y as i64;
            }
        }
        // dbg!(self.x, self.y);
    }
    pub fn execute_complex(&mut self, command: Command) {
        // dbg!(&command);
        // dbg!(self.x, self.y);
        // dbg!(self.w_dx, self.w_dy);
        match command {
            Command::N(step) => self.w_dy += step,
            Command::S(step) => self.w_dy -= step,
            Command::E(step) => self.w_dx += step,
            Command::W(step) => self.w_dx -= step,
            Command::L(angle) => {
                let new_angle = angle % 360;
                let rad = (new_angle as f64) * std::f64::consts::PI / (180 as f64); // -90 correction for starting east heading
                let new_x = (self.w_dx as f64) * rad.cos() - (self.w_dy as f64) * rad.sin();
                let new_y = (self.w_dx as f64) * rad.sin() + (self.w_dy as f64) * rad.cos();
                self.w_dx = new_x.round() as i64;
                self.w_dy = new_y.round() as i64;
            }
            Command::R(angle) => {
                let mut new_angle = self.angle - angle;
                if new_angle < 0 {
                    new_angle = 360 + new_angle // + because new_angle is negative
                }

                let rad = (new_angle as f64) * std::f64::consts::PI / (180 as f64); // -90 correction for starting east heading
                let new_x = (self.w_dx as f64) * rad.cos() - (self.w_dy as f64) * rad.sin();
                let new_y = (self.w_dx as f64) * rad.sin() + (self.w_dy as f64) * rad.cos();
                self.w_dx = new_x.round() as i64;
                self.w_dy = new_y.round() as i64;
            }
            Command::F(step) => {
                self.x = self.x + self.w_dx * step;
                self.y = self.y + self.w_dy * step;
            }
        }
        // dbg!(self.x, self.y);
        // dbg!(self.w_dx, self.w_dy);
    }

    pub fn man_distance(&self) -> usize {
        (self.x.abs() + self.y.abs()).try_into().unwrap()
    }
}

fn parse_line(line: &str) -> Command {
    let mut iter = line.trim().chars();
    let command = iter.next().unwrap();
    let argument: String = iter.collect();
    match command {
        'N' => Command::N(argument.parse().unwrap()),
        'S' => Command::S(argument.parse().unwrap()),
        'E' => Command::E(argument.parse().unwrap()),
        'W' => Command::W(argument.parse().unwrap()),
        'L' => Command::L(argument.parse().unwrap()),
        'R' => Command::R(argument.parse().unwrap()),
        'F' => Command::F(argument.parse().unwrap()),
        _ => panic!("unsupported command found!"),
    }
}

fn main() {
    let contents = parse_file().unwrap();
    let commands: Vec<Command> = contents.lines().map(|line| parse_line(line)).collect();
    let mut ferry = Ferry::new();
    for command in commands {
        ferry.execute_complex(command);
    }
    dbg!(ferry.man_distance());
}
