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
                    '#' => true,
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

    fn iterate_v1(&mut self) {
        let occupancy_map: Vec<Vec<usize>> = self
            .seats
            .iter()
            .enumerate()
            .map(|(ri, rv)| {
                rv.iter()
                    .enumerate()
                    .map(|(ci, _s)| self.calculate_occupancy(Room::adjacent_seats(ri, ci)))
                    .collect()
            })
            .collect();
        // dbg!(&occupancy_map);
        let new_state: Vec<Vec<bool>> = occupancy_map
            .iter()
            .enumerate()
            .map(|(ri, rv)| {
                rv.iter()
                    .enumerate()
                    .map(|(ci, o)| {
                        if *o == 0 {
                            true
                        } else if *o >= 4 {
                            false
                        } else {
                            self.seats[ri][ci]
                        }
                    })
                    .collect()
            })
            .collect();
        // dbg!(&new_state);
        self.seats = new_state;
    }

    fn iterate_v2(&mut self) {
        let occupancy_map: Vec<Vec<usize>> = self
            .seats
            .iter()
            .enumerate()
            .map(|(ri, rv)| {
                rv.iter()
                    .enumerate()
                    .map(|(ci, _s)| self.calculate_occupancy(self.visible_seats(ri, ci)))
                    .collect()
            })
            .collect();
        // dbg!(&occupancy_map);
        let new_state: Vec<Vec<bool>> = occupancy_map
            .iter()
            .enumerate()
            .map(|(ri, rv)| {
                rv.iter()
                    .enumerate()
                    .map(|(ci, o)| {
                        if *o == 0 {
                            true
                        } else if *o >= 5 {
                            false
                        } else {
                            self.seats[ri][ci]
                        }
                    })
                    .collect()
            })
            .collect();
        // dbg!(&new_state);
        self.seats = new_state;
    }

    fn print_state(&self) {
        let row_len = self.rows;
        print!("┌{}┐\n", str::repeat("─", row_len));
        for (ri, row) in self.seats.iter().enumerate() {
            print!("│");
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
            print!("│");
            println!();
        }
        print!("└{}┘\n", str::repeat("─", row_len));
    }

    fn adjacent_seats(ri: usize, ci: usize) -> Vec<(usize, usize)> {
        vec![
            (ri.wrapping_sub(1), ci.wrapping_sub(1)),
            (ri, ci.wrapping_sub(1)),
            (ri + 1, ci.wrapping_sub(1)),
            (ri + 1, ci),
            (ri + 1, ci + 1),
            (ri, ci + 1),
            (ri.wrapping_sub(1), ci + 1),
            (ri.wrapping_sub(1), ci),
        ]
    }

    fn visible_seats(&self, ri: usize, ci: usize) -> Vec<(usize, usize)> {
        vec![
            self.ray_to_seat((ri, ci), (-1, -1)),
            self.ray_to_seat((ri, ci), (0, -1)),
            self.ray_to_seat((ri, ci), (1, -1)),
            self.ray_to_seat((ri, ci), (1, 0)),
            self.ray_to_seat((ri, ci), (1, 1)),
            self.ray_to_seat((ri, ci), (0, 1)),
            self.ray_to_seat((ri, ci), (-1, 1)),
            self.ray_to_seat((ri, ci), (-1, 0)),
        ]
            .iter()
            .filter_map(|&el| el)
            .collect()
    }

    fn ray_to_seat(
        &self,
        (ri, ci): (usize, usize),
        (sr, sc): (i64, i64),
    ) -> Option<(usize, usize)> {
        // apply step (sr, sc) to indices and exit on first found seat

        let rl = self.rows;
        let cl = self.columns;
        let mut new_ri = ri;
        let mut new_ci = ci;
        loop {
            new_ri = ((new_ri as i64) + sr) as usize;
            new_ci = ((new_ci as i64) + sc) as usize;
            if (0..rl).contains(&new_ri) && (0..cl).contains(&new_ci) {
                if !self.floor_indices.contains(&(new_ri, new_ci)) {
                    return Some((new_ri, new_ci));
                }
            } else {
                break;
            }
        }
        return None;
    }

    fn calculate_occupancy(&self, seat_indices: Vec<(usize, usize)>) -> usize {
        seat_indices
            .iter()
            .map(|(ri, ci)| self.get_occupancy(*ri, *ci))
            .sum()
    }

    fn get_occupancy(&self, row: usize, column: usize) -> usize {
        if let Some(rows) = self.seats.get(row) {
            if let Some(_seat) = rows.get(column) {
                if *_seat == true {
                    if self.floor_indices.contains(&(row, column)) {
                        0
                    } else {
                        1
                    }
                } else {
                    0
                }
            } else {
                0
            }
        } else {
            0
        }
    }

    fn run_until_stable_v1(&mut self) {
        let mut prev_state = self.seats.clone();
        self.iterate_v1();
        while self.seats != prev_state {
            prev_state = self.seats.clone();
            self.iterate_v1()
        }
    }

    fn run_until_stable_v2(&mut self) {
        let mut prev_state = self.seats.clone();
        self.iterate_v2();
        while self.seats != prev_state {
            prev_state = self.seats.clone();
            self.iterate_v2()
        }
    }

    fn count_occupied_seats(&self) -> usize {
        let mut count = 0;
        for (ri, rv) in self.seats.iter().enumerate() {
            for (ci, seat) in rv.iter().enumerate() {
                if *seat && !self.floor_indices.contains(&(ri, ci)) {
                    count += 1;
                }
            }
        }
        count
    }
}

fn main() {
    let contents = parse_file().unwrap();
    let mut room = Room::new(contents);
    room.run_until_stable_v2();
    // room.print_state();
    dbg!(room.count_occupied_seats());
}
