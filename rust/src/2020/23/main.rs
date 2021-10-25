fn parse_line(line: &str) -> Vec<usize> {
    line.chars()
        .filter_map(|ch| ch.to_string().parse::<usize>().ok())
        .collect()
}

fn crab_move(cups: &Vec<usize>, moves: usize) -> Vec<usize> {
    let min = *cups.iter().min().unwrap();
    let max = *cups.iter().max().unwrap();

    let len = cups.len();
    let mut list = vec![0; max + 1];
    (0..len).for_each(|i| list[cups[i]] = cups[(i + 1) % len]);

    let mut cur_cup = cups[0];
    for _ in 0..moves {
        let p1 = list[cur_cup];
        let p2 = list[p1];
        let p3 = list[p2];
        list[cur_cup] = list[p3];

        let mut dest_cup = if cur_cup > min { cur_cup - 1 } else { max };
        while [p1, p2, p3].contains(&dest_cup) || dest_cup < min || dest_cup > max {
            dest_cup = if dest_cup > min { dest_cup - 1 } else { max };
        }

        let tmp = list[dest_cup];
        list[dest_cup] = p1;
        list[p1] = p2;
        list[p2] = p3;
        list[p3] = tmp;

        cur_cup = list[cur_cup];
    }

    list
}

fn collect_line(cups: &Vec<usize>) -> String {
    let one_pos = cups.iter().position(|&el| el == 1).unwrap();
    let mut line = String::with_capacity(cups.len());
    for i in 1..cups.len() {
        let pos = (one_pos + i) % cups.len();
        line.push_str(&cups[pos].to_string());
    }
    line
}

fn fill_cups(cups: &mut Vec<usize>, upto: usize) {
    let max = cups.iter().max().unwrap().clone();
    for i in 1..=(upto - cups.len()) {
        cups.push(max + i);
    }
}

fn main() {
    let mut cups = parse_line("318946572");
    fill_cups(&mut cups, 1000000);
    let res = crab_move(&cups, 10000000);
    let x = res[1];
    let y = res[x];
    dbg!(x * y);
}
