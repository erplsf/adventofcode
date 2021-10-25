use adventofcode::lib::parse_file;
use std::collections::HashSet;
use std::collections::VecDeque;

fn play_combat(p1_deck: &mut VecDeque<usize>, p2_deck: &mut VecDeque<usize>) {
    while p1_deck.len() > 0 && p2_deck.len() > 0 {
        let p1_card = p1_deck.pop_front().unwrap();
        let p2_card = p2_deck.pop_front().unwrap();
        if p1_card > p2_card {
            p1_deck.push_back(p1_card);
            p1_deck.push_back(p2_card);
        } else {
            p2_deck.push_back(p2_card);
            p2_deck.push_back(p1_card);
        }
    }
}

fn play_recursive_combat(p1_deck: &mut VecDeque<usize>, p2_deck: &mut VecDeque<usize>) -> usize {
    let mut round_counter = 1;
    let (mut p1_game_log, mut p2_game_log) = (HashSet::new(), HashSet::new());
    while p1_deck.len() > 0 && p2_deck.len() > 0 {
        // dbg!(&p1_deck, &p2_deck);
        if determine_recursive_winner((&mut p1_game_log, &mut p2_game_log), p1_deck, p2_deck) == 0 {
            // p1 won
            let p1_card = p1_deck.pop_front().unwrap();
            let p2_card = p2_deck.pop_front().unwrap();
            // dbg!(&p1_card, &p2_card);
            // println!("p1 won round {}", round_counter);
            p1_deck.push_back(p1_card);
            p1_deck.push_back(p2_card);
        } else {
            // p2 won
            let p1_card = p1_deck.pop_front().unwrap();
            let p2_card = p2_deck.pop_front().unwrap();
            // dbg!(&p1_card, &p2_card);
            // println!("p2 won round {}", round_counter);
            p2_deck.push_back(p2_card);
            p2_deck.push_back(p1_card);
        }
        round_counter += 1;
    }
    if p1_deck.len() == 0 {
        return 1;
    } else {
        return 0;
    }
}

fn determine_recursive_winner(
    game_log: (&mut HashSet<Vec<usize>>, &mut HashSet<Vec<usize>>),
    p1_deck: &mut VecDeque<usize>,
    p2_deck: &mut VecDeque<usize>,
) -> usize {
    if game_log.0.contains(&p1_deck.iter().cloned().collect::<Vec<usize>>())
        && game_log.1.contains(&p2_deck.iter().cloned().collect::<Vec<usize>>())
    {
        return 0;
    }
    game_log.0.insert(p1_deck.iter().cloned().collect());
    game_log.1.insert(p2_deck.iter().cloned().collect());
    let p1_card = p1_deck.pop_front().unwrap();
    let p2_card = p2_deck.pop_front().unwrap();
    if p1_deck.len() >= p1_card && p2_deck.len() >= p2_card {
        let mut p1_sub_deck: VecDeque<usize> = p1_deck.iter().cloned().take(p1_card).collect();
        let mut p2_sub_deck: VecDeque<usize> = p2_deck.iter().cloned().take(p2_card).collect();
        p1_deck.push_front(p1_card);
        p2_deck.push_front(p2_card);
        return play_recursive_combat(&mut p1_sub_deck, &mut p2_sub_deck);
    } else {
        p1_deck.push_front(p1_card);
        p2_deck.push_front(p2_card);
        if p1_card > p2_card {
            return 0;
        } else {
            return 1;
        }
    }
}

fn main() {
    let contents = parse_file().unwrap();
    let mut iter = contents.split("\n\n");
    let mut p1_deck: VecDeque<usize> = iter
        .next()
        .unwrap()
        .lines()
        .skip(1)
        .filter_map(|card| card.parse().ok())
        .collect();
    let mut p2_deck: VecDeque<usize> = iter
        .next()
        .unwrap()
        .lines()
        .skip(1)
        .filter_map(|card| card.parse().ok())
        .collect();

    // play_combat(&mut p1_deck, &mut p2_deck);
    play_recursive_combat(&mut p1_deck, &mut p2_deck);

    if p1_deck.len() > 0 {
        let score: usize = p1_deck
            .iter()
            .rev()
            .enumerate()
            .map(|(i, v)| (i + 1) * v)
            .sum();
        dbg!(&score);
    } else {
        let score: usize = p2_deck
            .iter()
            .rev()
            .enumerate()
            .map(|(i, v)| (i + 1) * v)
            .sum();
        dbg!(&score);
    }
}
