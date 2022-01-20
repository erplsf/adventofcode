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

char match(char c) {
  switch (c) {
  case '(':
    return ')';
  case '[':
    return ']';
  case '{':
    return '}';
  case '<':
    return '>';
  }
  return '!';
}

void pv(vector<uint> const& v) {
  cout << "[";
  for (uint i = 0; i < v.size(); i++) {
    if (i + 1 == v.size())
      cout << v[i];
    else
      cout << v[i] << ",";
  }
  cout << "]\n";
}
void pv(vector<char> const& v) {
  cout << "- ";
  for (uint i = 0; i < v.size(); i++) {
    if (i + 1 == v.size())
      cout << v[i];
    else
      cout << v[i] << ",";
  }
  cout << " -\n";
}

uint score_incomplete(char c) {
  switch (c) {
  case ')':
    return 1;
  case ']':
    return 2;
  case '}':
    return 3;
  case '>':
    return 4;
  }
  return 0;
}

uint64_t median(vector<uint64_t>& v) {
  size_t n = v.size() / 2;
  nth_element(v.begin(), v.begin() + n, v.end());
  return v[n];
}

uint64_t solve(string input, bool p1) {
  auto lines = split(input, '\n');
  uint corrupted_sum = 0;
  vector<uint64_t> incomplete_sums;

  for (auto&& line: lines) {
    vector<char> stack;
    uint64_t incomplete_sum = 0;
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
      corrupted_sum += score_corrupted(line[i]);
      continue;
    }

    // pv(stack);

    while (stack.size() >= 1) {
      char c = stack.back();
      auto amount = score_incomplete(match(c));
      incomplete_sum *= 5;
      incomplete_sum += amount;
      stack.pop_back();
    }

    // cout << " cost: " << incomplete_sum << "\n";
    incomplete_sums.emplace_back(incomplete_sum);
  }

  if (p1)
    return corrupted_sum;
  else
    return median(incomplete_sums);

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
    expect(p2 == 288957_i);
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
