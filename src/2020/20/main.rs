use adventofcode::lib::parse_file;

const SIZE: usize = 10;

// sides are read from top to bottom and from right to left
// size is 10x10
#[derive(Debug)]
struct Tile {
    id: usize,
    field: Vec<char>,
}

impl Tile {
    pub fn new(id: usize, field: Vec<char>) -> Self {
        Self {
            id: id,
            field: field,
        }
    }

    pub fn top(&self) -> Vec<char> {
        let mut res: Vec<char> = vec![];
        for i in 0..SIZE {
            let idx = flatten(i, 0);
            res.push(self.field[idx].clone());
        }
        res
    }

    pub fn right(&self) -> Vec<char> {
        let mut res: Vec<char> = vec![];
        for i in 0..SIZE {
            let idx = flatten(SIZE-1, i);
            res.push(self.field[idx].clone());
        }
        res
    }

    pub fn bottom(&self) -> Vec<char> {
        let mut res: Vec<char> = vec![];
        for i in 0..SIZE {
            let idx = flatten(i, SIZE-1);
            res.push(self.field[idx].clone());
        }
        res
    }

    pub fn left(&self) -> Vec<char> {
        let mut res: Vec<char> = vec![];
        for i in 0..SIZE {
            let idx = flatten(0, i);
            res.push(self.field[idx].clone());
        }
        res
    }
}

fn flatten(r: usize, c: usize) -> usize {
    SIZE * c + r
}

fn parse_tile_block(tile_block: &str) -> Tile {
    let mut iter = tile_block.lines();
    let title = iter.next().unwrap();
    let id: usize = title.split(" ").last().unwrap().replace(":", "").parse().unwrap();
    let mut field: Vec<char> = vec![];
    for line in iter {
        field.extend(line.chars());
    }
    Tile::new(id, field)
}

fn main() {
    let contents = parse_file().unwrap();
    for tile_block in contents.split("\n\n") {
        let tile = parse_tile_block(tile_block);
        println!("id:     {:?}", tile.id);
        println!("top:    {:?}", tile.top());
        println!("right:  {:?}", tile.right());
        println!("bottom: {:?}", tile.bottom());
        println!("left:   {:?}", tile.left());
    }
    // // println!("{}", &input);
    // let mut res = build_map(iter.next().unwrap());
    // res.insert("8".to_string(), "42 | 42 8".to_string());
    // res.insert("11".to_string(), "42 31 | 42 11 31".to_string());
    // // TODO: Solve part 2
    // let tests = iter.next().unwrap();
    // // dbg!(&res);
    // let regex_string = build_regex_string(&mut res, "0");
    // let regex = Regex::new(&regex_string).unwrap();
    // // dbg!(&regex);
    // let matched = tests
    //     .lines()
    //     .map(|case| regex.is_match(case))
    //     .filter(|res| *res)
    //     .count();
    // dbg!(matched);
}
