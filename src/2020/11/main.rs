use adventofcode::lib::parse_file;

struct Room {
    // Row-major order
    rows: usize,
    columns: usize,
    seats: Vec<Vec<bool>>,
    floor_indices: Vec<(usize, usize)>,
}

impl Room {
    pub fn new(room: String) -> Self {
        let mut seats: Vec<Vec<bool>> = vec![];
        let mut floor_indices: Vec<(usize, usize)> = vec![];
        let mut rows = 0;
        let mut columns = 0;
        for (ri, row) in room.lines().enumerate() {
            let mut row_seats: Vec<bool> = vec![];
            columns = room.len();
            rows += 1;
            for (ci, ch) in row.chars().enumerate() {
                let seat = match ch {
                    '.' => {
                        floor_indices.push((ri, ci));
                        false
                    }
                    'L' => false,
                    _ => false,
                };
                row_seats.push(seat);
            }
            seats.push(row_seats);
        }

        Room {
            rows,
            columns,
            seats,
            floor_indices,
        }
    }
    fn iterate(&mut self) {
        let occupancy_map: Vec<Vec<usize>> = self.seats.iter().enumerate().map(|(ri, rv)| {
            rv.iter().enumerate().map(|(ci, _s)| {
                self.calculate_neighbors(ri, ci)
            }).collect()
        }).collect();
        dbg!(occupancy_map);
    }

    fn print_state(&self) {
        for (ri, row) in self.seats.iter().enumerate() {
            for (ci, seat) in row.iter().enumerate() {
                if self.floor_indices.contains(&(ri, ci)) {
                    print!(".");
                    continue;
                }
                match seat {
                    true => print!("#"),
                    false => print!("L"),
                }
            }
            println!();
        }
    }

    fn calculate_neighbors(&self, ri: usize, ci: usize) -> usize {
        [
            (ri - 1, ci - 1),
            (ri, ci - 1),
            (ri + 1, ci - 1),
            (ri + 1, ci),
            (ri + 1, ci + 1),
            (ri, ci + 1),
            (ri - 1, ci + 1),
            (ri - 1, ci),
        ]
        .iter()
            .map(|(ri, ci)| self.get_occupancy(*ri, *ci))
            .sum()
    }
    fn get_occupancy(&self, row: usize, column: usize) -> usize {
        if let Some(rows) = self.seats.get(row) {
            if let Some(_seat) = rows.get(column) {
                1
            } else {
                0
            }
        } else {
            0
        }
    }
}

fn main() {
    let contents = parse_file().unwrap();
    let mut room = Room::new(contents);
    room.print_state();
    room.iterate();
}
