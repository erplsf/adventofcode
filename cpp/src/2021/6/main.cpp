#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

// pair<string, string> solve(string, bool);

vector<uint> parse(string input) {
  auto parts = split(input, ',');
  vector<uint> vec;
  transform(parts.begin(), parts.end(), back_inserter(vec),
            [](string s) -> uint { return stoul(s); });
  return vec;
}

// 0 -> 6 + 8
uint sim_two(vector<uint> input, uint days) {
  uint count = 0;
  unordered_map<uint, uint> map;
  count += input.size();

  for (uint cd : input) {
    uint fs = cd + 1; // day when it will first spawn a new offspring (cooldown
                      // + 1)
    map[fs] += 1;
    // then it goes in cycles
  }

  return count;
}

auto solve(string input) {
  auto inp = parse(input);
  auto p1 = sim(inp, 80);
  auto p2 = sim(inp, 256);

  return make_pair(to_string(p1.size()), to_string(p2.size()));
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(3,4,3,1,2)";

    auto [p1, p2] = solve(example);

    expect(p1 == "5934"s);
    expect(p2 == "26984457539"s);
    // expect(results.second == "12"s);
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
