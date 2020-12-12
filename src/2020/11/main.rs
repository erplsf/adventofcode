use adventofcode::lib::parse_file;

struct Room {
    // Row-major order
    rows: usize,
    columns: usize,
    seats: Vec<Vec<bool>>,
    floor_indices: Vec<(usize, usize)>,
}

impl Room {
    fn iterate(&self) {
        let new_state = self.seats.iter().enumerate().map(|(row_index, row_vec)| {
            row_vec.iter().enumerate().map(move |(column_index, seat)| {
                if self.floor_indices.contains(&(row_index, column_index)) {
                    return false; // we're on the floor, terminate early
                }
                let adjacent_count = self.calculate_neighbors(row_index, column_index);
                match seat {
                    true => {
                        if adjacent_count >= 4 {
                            false
                        } else {
                            *seat
                        }
                    }
                    false => {
                        if adjacent_count == 0 {
                            true
                        } else {
                            *seat
                        }
                    }
                }
            })
        });

        // self.vacate_floor_seats(); // change to check if current location is not in floor_indices
    }

    fn print_state(&self) {
        for (ri, row) in self.seats.iter().enumerate() {
            for (ci, seat) in row.iter().enumerate() {
                if self.floor_indices.contains(&(ri, ci)) {
                    print!(".");
                }
            }
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

    fn vacate_floor_seats(&self) {
        for (row, column) in self.floor_indices {}
    }
}

fn main() {
    // let contents = parse_file().unwrap();
}
