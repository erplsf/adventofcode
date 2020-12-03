use adventofcode::lib::parse_file;

#[derive(Debug)]
struct Map {
    repeat: usize,
    rows: Vec<Vec<usize>>,
}

impl Map {
    pub fn new(repeat: usize) -> Self {
        Self {
            repeat,
            rows: vec![],
        }
    }

    pub fn add_row(&mut self, row: Vec<usize>) {
        self.rows.push(row);
    }

    pub fn walk(&self, (row_step, index_step): (usize, usize)) -> usize {
        let mut trees = 0;
        let row_count = self.rows.len();
        let mut row = row_step;
        let mut index = index_step;
        loop {
            if row < row_count {
                let local_index = index % self.repeat;
                if self.rows[row].contains(&local_index) {
                    trees = trees + 1;
                }
                row = row + row_step;
                index = index + index_step;
            } else {
                break;
            }
        }
        trees
    }
}

fn main() {
    let contents = parse_file().unwrap();
    let rows: Vec<&str> = contents.split("\n").filter(|r| r.len() > 0).collect();
    let repeat = rows.first().unwrap().len();
    let mut map = Map::new(repeat);
    for row in rows {
        let trees: Vec<usize> = row
            .chars()
            .enumerate()
            .filter_map(|(i, val)| if val == '#' { Some(i) } else { None })
            .collect();
        map.add_row(trees);
    }
    let trees_seen = map.walk((1, 3));
    dbg!(trees_seen);
    let walks = vec![(1, 1), (1, 3), (1, 5), (1, 7), (2, 1)];
    let total_trees_seen: usize = walks.iter().map(|&walk| map.walk(walk)).product();
    dbg!(total_trees_seen);
}
