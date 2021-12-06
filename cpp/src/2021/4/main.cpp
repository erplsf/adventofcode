#include <algorithm>
#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <fstream>
#include <iostream>
#include <numeric>
#include <optional>
#include <sstream>
#include <streambuf>
#include <string>
#include <vector>

using namespace aoc;
using namespace std;
using namespace boost::ut;

const uint B_SIZE = 5;

typedef array<array<uint, B_SIZE>, B_SIZE> board;

struct board_set {
  board nums = {};
  board marks = {};
};

void print_board(board &board) {
  for (uint ri = 0; ri < B_SIZE; ri++) {
    for (uint ci = 0; ci < B_SIZE; ci++) {
      cout << setw(2) << board[ri][ci] << " ";
    }
    cout << "\n";
  }
}

void read_row(board &board, uint ri, string row) {
  auto nums = split(row, ' ');
  nums.erase(
      remove_if(nums.begin(), nums.end(), [](string num) { return num == ""; }),
      nums.end());

  for (uint i = 0; i < nums.size(); i++) {
    board[ri][i] = stoul(nums[i]);
  }
}

optional<tuple<uint, uint>> mark(board_set &bs, uint number) {
  uint f_ri, f_ci;
  for (uint ri = 0; ri < B_SIZE; ri++) {
    for (uint ci = 0; ci < B_SIZE; ci++) {
      if (bs.nums[ri][ci] == number) {
        f_ri = ri;
        f_ci = ci;
        bs.marks[ri][ci] = 1;
        return make_tuple(f_ri, f_ci);
      }
    }
  }
  return nullopt;
}

bool filled(board &board, uint fixed, bool row) {
  // cout << "in filled"
  //      << "\n";
  // print_board(board);
  uint count = 0;
  for (uint ii = 0; ii < B_SIZE; ii++) {
    if (row) {
      count += board[fixed][ii];
    } else {
      count += board[ii][fixed];
    }
  }
  // cout << "filled? " << count << "\n";
  if (count == B_SIZE) {
    return true;
  } else {
    return false;
  }
}

bool filled(board &board, tuple<uint, uint> idx) {
  return filled(board, get<0>(idx), true) || filled(board, get<1>(idx), false);
}

uint sum_unmarked(board_set &bs) {
  uint sum = 0;

  for (uint ri = 0; ri < B_SIZE; ri++) {
    for (uint ci = 0; ci < B_SIZE; ci++) {
      if (bs.marks[ri][ci] == 0)
        sum += bs.nums[ri][ci];
    }
    // cout << "\n";
  }

  return sum;
}

auto solve(string input) {
  auto lines = split(input, '\n');
  auto draws = split(lines[0], ',');
  // cout << "draws: ";
  // for (auto &&draw : draws)
  //   cout << draw << " ";
  vector<board_set> bss;
  for (auto it = lines.begin() + 2; it < lines.end(); ++it) {
    board_set bs;
    // skip empty line, process B_SIZE lines at a time
    if (*it == "")
      continue;
    for (uint i = 0; i < B_SIZE; i++) {
      read_row(bs.nums, i, *it);
      ++it;
    }
    // print_board(bs.nums);
    // cout << "\n";
    bss.emplace_back(bs);
  }

  uint first_win_board_id = 0;
  uint first_win_board_num = 0;
  uint last_win_board_id = 0;
  uint last_win_board_num = 0;
  uint win_count = 0;
  uint p1 = 0;
  uint p2 = 0;
  vector<bool> won;
  for (uint bsi = 0; bsi < bss.size(); bsi++)
    won.emplace_back(false);

  for (uint dni = 0; dni < draws.size(); dni++) {
    uint dn = stoul(draws[dni]);
    for (uint bsi = 0; bsi < bss.size(); bsi++) {
      auto idx = mark(bss[bsi], dn);
      // if (bsi == 2) {
      //   cout << "third board: "
      //        << "\n";
      //   print_board(bss[2].marks);
      // }
      if (idx.has_value()) {
        // cout << "num: " << dn << " idx: " << get<0>(*idx) << " " <<
        // get<1>(*idx)
        //      << "\n";
        if (filled(bss[bsi].marks, *idx)) {
          if (!won[bsi]) {
            won[bsi] = true;
            win_count++;
          }
          // cout << "filled at! " << dn << " " << bsi << "\n";
          if (win_count == 1) {
            first_win_board_id = bsi;
            first_win_board_num = dn;
            p1 = sum_unmarked(bss[first_win_board_id]) * first_win_board_num;
          } else if (win_count == bss.size()) {
            last_win_board_id = bsi;
            last_win_board_num = dn;
            p2 = sum_unmarked(bss[last_win_board_id]) * last_win_board_num;
            goto lastWin;
          }
        }
        // check if row/column filled, return index of the winning board
      }
    }
  }
lastWin:

  return make_tuple(to_string(p1), to_string(p2));
}

suite tests = [] {
  test("example") = [] {
    auto example =
        R"(7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7)";

    auto results = solve(example);

    expect(get<0>(results) == "4512"s);
    expect(get<1>(results) == "1924"s);
  };
};

int main(int argc, char *argv[]) {
  auto contents = get_input(argc, argv);
  if (!contents)
    return 1;

  auto results = solve(*contents);

  cout << "part one: " << get<0>(results) << "\n";
  cout << "part two: " << get<1>(results) << "\n";
}
