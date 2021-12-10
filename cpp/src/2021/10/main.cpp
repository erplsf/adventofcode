#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

bool is_opening(char c) {
  switch (c) {
  case '(':
    return true;
  case '[':
    return true;
  case '{':
    return true;
  case '<':
    return true;
  }
  return false;
}

bool is_closing(char c) {
  switch (c) {
  case ')':
    return true;
  case ']':
    return true;
  case '}':
    return true;
  case '>':
    return true;
  }
  return false;
}

bool is_matching(char c, char p) {
  if ((p == '(' && c == ')') || (p == '[' && c == ']') ||
      (p == '{' && c == '}') || (p == '<' && c == '>'))
    return true;
  return false;
}

uint score_corrupted(char c) {
  switch (c) {
  case ')':
    return 3;
  case ']':
    return 57;
  case '}':
    return 1197;
  case '>':
    return 25137;
  }
  return 0;
}

uint solve(string input, bool p1) {
  if (p1) {
    vector<char> stack;
    auto lines = split(input, '\n');
    uint sum = 0;

    for (auto &&line : lines) {
      uint i = 0;
      bool corrupted = false;
      auto size = line.size();
      for (; i < size; i++) {
        // cout << "cl: " << line[i] << "\n";
        if (is_opening(line[i]))
          stack.emplace_back(line[i]);
        else if (is_closing(line[i])) {
          if (is_matching(line[i], stack.back()))
            stack.pop_back();
          else {
            corrupted = true;
            break;
          }
        }
      }

      if (corrupted) {
        // cout << "c: " << line[i] << " score: " << score(line[i]) << "\n";
        sum += score_corrupted(line[i]);
      }
    }
    return sum;
  } else {
  }

  return 0;
}

auto solve(string input) {
  auto p1 = solve(input, true);
  auto p2 = solve(input, false);

  return make_pair(p1, p2);
}

suite tests = [] {
  test("example") = [] {
    auto example = R"([({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]])";

    auto [p1, p2] = solve(example);

    expect(p1 == 26397_i);
    expect(p2 == 0_i);
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
