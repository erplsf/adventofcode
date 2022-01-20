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

vector<uint> csp(uint s, uint t,
                 uint c = 7) { // s - starting day, t - total days, c - on which
                               // day it will spawn a new one
  vector<uint> days;

  int times = (t - s) / c; // total count of times it will reproduce
  for (int i = 1; i <= times && (s + (i * c) <= t);
       i++) { // if it's less then count and not over the final time
    days.emplace_back(s + (i * c));
  }

  return days;
}

vector<uint>
ncsp(uint s, uint t,
     uint c = 7) { // wrapper which also returns the first time it reproduces
  uint fs = s + 9;
  auto days = csp(fs, t, c);
  days.insert(days.begin(), fs);
  return days;
}

// 0 -> 6 + 8
unsigned long long sim_two(vector<uint> input, uint t_days) {
  unsigned long long count = 0;
  unordered_map<uint, unsigned long long> map;
  count += input.size();

  for (uint cd: input) {
    // cout << "first run: ";
    uint fs = cd + 1; // day when it will first spawn a new offspring (cooldown
                      // + 1)
    map[fs] += 1;

    // cout << "fs: " << fs << "\n";

    auto days = csp(fs, t_days);
    for (uint day: days)
      map[day] += 1;
    // then it goes in cycles
  }

  for (uint day = 1; day <= t_days; day++) {
    auto amount = map[day];
    if (amount == 0)
      continue;

    // cout << "nsp on day: " << day << " amount: " << amount << "\n";

    count += amount;

    // uint fs = day + 9; // new spawns reproduce every 8+1 days
    // map[fs] += amount;

    auto days = ncsp(day, t_days);
    for (uint d: days)
      map[d] += amount;
  }

  return count;
}

auto solve(string input) {
  auto inp = parse(input);
  auto p1 = sim_two(inp, 80);
  auto p2 = sim_two(inp, 256);
  // auto p2 = sim_two(inp, 256);
  // cout << "p1: " << p1 << " p2: " << p2 << "\n";

  // auto days = ncsp(2, 80);
  // cout << "[";
  // for (auto day : days)
  //   cout << day << ",";
  // cout << "]\n";

  return make_pair(to_string(p1), to_string(p2));
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(3,4,3,1,2)";

    auto [p1, p2] = solve(example);

    expect(p1 == "5934"s);
    expect(p2 == "26984457539"s);
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
