#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

int oracle(string segments) {
  switch (segments.size()) {
  case 2:
    return 1;
  case 3:
    return 7;
  case 4:
    return 4;
  case 7:
    return 8;
  }

  return -1;
}

auto sol(string input) {
  auto lines = split(input, '\n');
  uint count = 0;
  // cout << "s: " << lines.size() << "\n";
  for (auto &&line : lines) {
    // cout << "l: " << line;
    auto parts = split(line, '|');
    // cout << "s: " << parts.size() << "\n";
    auto right = parts[1];
    // cout << "here\n";
    trim(right);
    auto digits = split(right, ' ');
    for (auto &&digit : digits) {
      auto guess = oracle(digit);
      if (guess > -1)
        count++;
    }
  }
  return count;
}

auto solve(string input) {
  auto p1 = sol(input);
  auto p2 = sol(input);

  return make_pair(p1, p2);
}

suite tests = [] {
  test("example") = [] {
    auto example =
        R"(be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce)";

    auto [p1, p2] = solve(example);

    expect(p1 == 26_i);
    expect(p2 == 288957_i);
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
