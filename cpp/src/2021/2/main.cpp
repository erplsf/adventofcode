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

struct submarine {
  uint dep = 0;
  uint hor = 0;
  uint aim = 0;
};

void nav_two(submarine* sub, string command, uint distance) {
  switch (c_hash(command.c_str())) {
  case c_hash("forward"): {
    sub->hor += distance;
    sub->dep += sub->aim * distance;
    break;
  }
  case c_hash("down"): {
    sub->aim += distance;
    break;
  }
  case c_hash("up"): {
    sub->aim -= distance;
    break;
  }
  }
}

void nav_one(submarine* sub, string command, uint distance) {
  switch (c_hash(command.c_str())) {
  case c_hash("forward"): {
    sub->hor += distance;
    break;
  }
  case c_hash("down"): {
    sub->dep += distance;
    break;
  }
  case c_hash("up"): {
    sub->dep -= distance;
    break;
  }
  }
}

auto solve(string input) {
  submarine sub_one;
  submarine sub_two;
  auto lines = split(input, '\n');
  for (auto&& line: lines) {
    auto parts = split(line, ' ');

    auto command = parts[0];
    auto distance = stoul(parts[1]);

    nav_one(&sub_one, command, distance);
    nav_two(&sub_two, command, distance);
  };
  auto p1 = sub_one.dep * sub_one.hor;
  auto p2 = sub_two.dep * sub_two.hor;
  return make_tuple(to_string(p1), to_string(p2));
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(forward 5
down 5
forward 8
up 3
down 8
forward 2)";

    auto results = solve(example);

    expect(get<0>(results) == "150"s);
    expect(get<1>(results) == "900"s);
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
