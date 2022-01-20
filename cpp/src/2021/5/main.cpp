#include <algorithm>
#include <aoc/aoc.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <fstream>
#include <iostream>
#include <numeric>
#include <optional>
#include <sstream>
#include <streambuf>
#include <string>
#include <unordered_map>
#include <vector>

using namespace aoc;
using namespace std;
using namespace boost::ut;

typedef unordered_map<pair<uint, uint>, uint, boost::hash<pair<uint, uint>>>
    u_map;

void print_map(u_map& map) {
  uint max_x = 0;
  uint max_y = 0;
  for (auto&& kv: map) {
    if (kv.first.first > max_x)
      max_x = kv.first.first;
    if (kv.first.second > max_y)
      max_y = kv.first.second;
  }

  for (uint y = 0; y <= max_y; y++) {
    for (uint x = 0; x <= max_x; x++) {
      auto val = map[make_pair(x, y)];
      if (val == 0) {
        cout << ".";
      } else {
        cout << val;
      }
    }
    cout << "\n";
  }
}

void step(uint& v, uint t) {
  int dv = v - t;
  if (dv != 0) {
    int s = (dv < 0) ? 1 : -1;
    v += 1 * s;
  }
}

auto solve(string input, bool p1) {
  u_map map;
  auto lines = split(input, '\n');
  for (auto&& line: lines) {
    // cout << "line: " << line << "\n";
    auto parts = split(line, "->");
    auto begin = parts[0];
    trim(begin);
    auto end = parts[1];
    trim(end);
    auto b_parts = split(begin, ',');
    uint x1 = stoul(b_parts[0]);
    uint y1 = stoul(b_parts[1]);
    auto e_parts = split(end, ',');
    uint x2 = stoul(e_parts[0]);
    uint y2 = stoul(e_parts[1]);

    if (p1 && x1 != x2 && y1 != y2) // hack for part 1
      continue;

    uint x = x1;
    uint y = y1;

    // cout << "\n";
    while (true) {
      // cout << "x: " << x << " y: " << y << "\n";
      map[make_pair(x, y)] += 1;

      if (x == x2 && y == y2)
        break;

      step(x, x2);
      step(y, y2);
    }
  }

  // print_map(map);
  // cout << "\n";

  uint total = 0;
  for (auto&& kv: map) {
    if (kv.second >= 2) {
      // cout << "first: " << kv.first.first << "," << kv.first.second
      //      << " second: " << kv.second << "\n";
      total++;
    }
  }

  return total;
}

auto solve(string input) {
  auto p1 = solve(input, true);
  auto p2 = solve(input, false);

  return make_pair(to_string(p1), to_string(p2));
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2)";

    auto results = solve(example);

    expect(results.first == "5"s);
    expect(results.second == "12"s);
  };
};

int main(int argc, char* argv[]) {
  auto contents = get_input(argc, argv);
  if (!contents)
    return 1;

  auto results = solve(*contents);

  cout << "part one: " << get<0>(results) << "\n";
  cout << "part two: " << get<1>(results) << "\n";
}
