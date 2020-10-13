use adventofcode::lib::parse_file;
use std::ops::RangeInclusive;

const SIZE: usize = 1000;

type Lights = [[bool; SIZE]; SIZE];
type BrightLights = [[usize; SIZE]; SIZE];

const fn init_lights() -> Lights {
    [[false; SIZE]; SIZE]
}

const fn init_bright_lights() -> BrightLights {
    [[0; SIZE]; SIZE]
}

#[derive(Debug,PartialEq)]
enum Operation {
    On, Toggle, Off
}

#[derive(Debug,PartialEq)]
struct Command {
    operation: Operation,
    row_range: RangeInclusive<usize>,
    column_range: RangeInclusive<usize>
}

impl Command {
    fn new(operation: Operation, row_range: RangeInclusive<usize>, column_range: RangeInclusive<usize>) -> Self {
        Self { operation: operation, row_range: row_range, column_range: column_range }
    }
}

fn control_lights(ligths: &mut Lights, command: &Command) -> () {
    for sub in ligths[command.row_range.clone()].iter_mut() {
        for element in sub[command.column_range.clone()].iter_mut() {
            let new_state = match command.operation {
                Operation::On => true,
                Operation::Toggle => !*element,
                Operation::Off => false
            };
            *element = new_state;
        }
    }
}

fn control_bright_lights(ligths: &mut BrightLights, command: &Command) -> () {
    for sub in ligths[command.row_range.clone()].iter_mut() {
        for element in sub[command.column_range.clone()].iter_mut() {
            *element = match command.operation {
                Operation::On => *element + 1,
                Operation::Toggle => *element + 2,
                Operation::Off => *element - 1
            };
        }
    }
}

fn count_turned_lights(lights: &Lights) -> usize {
    let mut count = 0;
    for row in lights.iter() {
        for column in row.iter() {
            if *column {
                count += 1;
            }
        }
    }
    count
}

fn count_turned_bright_lights(lights: &BrightLights) -> usize {
    let mut count = 0;
    for row in lights.iter() {
        for column in row.iter() {
            count += column;
        }
    }
    count
}

fn parse_line(line: &str) -> Command {
    let words: Vec<&str> = line.split(' ').collect();
    let operation: Operation;
    let (rx, ry): (RangeInclusive<usize>, RangeInclusive<usize>);
    
    if words.len() == 4 {
        operation = Operation::Toggle;
        let range_one: Vec<usize> = words[1].split(',').map(|n| n.parse::<usize>().unwrap()).collect();
        let range_two: Vec<usize> = words.last().unwrap().split(',').map(|n| n.parse::<usize>().unwrap()).collect();
        let (rxs, rys) = (range_one[0], range_one[1]);
        let (rxe, rye) = (range_two[0], range_two[1]);
        rx = rxs..=rxe;
        ry = rys..=rye;
    } else if words.len() == 5 {
        operation = match words[1] {
            "on" => Operation::On,
            "off" => Operation::Off,
            _ => panic!()
        };
        let range_one: Vec<usize> = words[2].split(',').map(|n| n.parse::<usize>().unwrap()).collect();
        let range_two: Vec<usize> = words.last().unwrap().split(',').map(|n| n.parse::<usize>().unwrap()).collect();
        let (rxs, rys) = (range_one[0], range_one[1]);
        let (rxe, rye) = (range_two[0], range_two[1]);
        rx = rxs..=rxe;
        ry = rys..=rye;
    } else {
        panic!()
    }
    Command::new(operation, rx, ry)
}

fn process_file(string : &str) -> Vec<Command> {
    let mut commands = Vec::new();
    for line in string.lines() {
        commands.push(parse_line(line));
    }
    commands
}

fn main() -> Result<(), Box<dyn std::error::Error + 'static>> {
    // tests
    let mut lights = init_lights();
    control_lights(&mut lights, &Command::new(Operation::On, 0..=999, 0..=999));
    assert_eq!(count_turned_lights(&lights), 1000 * 1000);
    assert_eq!(parse_line("turn on 0,0 through 999,999"), Command::new(Operation::On, 0..=999 as usize, 0..=999 as usize));
    assert_eq!(parse_line("toggle 0,0 through 999,0"), Command::new(Operation::Toggle, 0..=999 as usize, 0..=0 as usize));
    assert_eq!(parse_line("turn off 499,499 through 500,500"), Command::new(Operation::Off, 499..=500 as usize, 499..=500 as usize));

    lights = init_lights();
//    let mut bright_lights = init_bright_lights();
    let contents = parse_file().unwrap();
    let commands = process_file(&contents);

    for command in commands {
        control_lights(&mut lights, &command);
    //    control_bright_lights(&mut bright_lights, &command);
    }

    dbg!(count_turned_lights(&lights));
    
    Ok(())
}
