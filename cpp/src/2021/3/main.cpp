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

tuple<uint, uint> cb(vector<string> reports, uint col) { // most common bit
  array<uint, 2> counts{};

  for (auto &&report : reports) {
    auto pos = report[col] - 48;
    counts[pos] += 1;
  }
  return make_tuple(counts[0], counts[1]);
}

optional<uint> mcb(tuple<uint, uint> bits) {
  if (get<0>(bits) > get<1>(bits)) {
    return 0;
  } else if (get<0>(bits) < get<1>(bits)) {
    return 1;
  } else {
    return nullopt;
  }
}

auto solve_p1(vector<string> reports) {
  vector<array<uint, 2>> nums;
  for (auto &&line : reports) {
    if (nums.size() != line.size()) {
      nums.reserve(line.size());
      for (uint i = 0; i < line.size(); i++) {
        nums.emplace_back(array<uint, 2>());
      }
    }
    for (uint i = 0; i < line.size(); i++) {
      auto bit = line[i] - 48; // ascii conversion to number
      nums[i][bit] += 1;
    }
  }

  // count
  vector<uint> gamma;
  vector<uint> epsilon;
  for (auto &&col : nums) {
    if (col[0] > col[1]) {
      gamma.emplace_back(0);
      epsilon.emplace_back(1);
    } else {
      gamma.emplace_back(1);
      epsilon.emplace_back(0);
    }
  }

  // convert
  uint i = 0;
  uint gamma_num = 0;
  uint epsilon_num = 0;
  for (auto ri = gamma.rbegin(); ri != gamma.rend(); ++ri) {
    gamma_num += *ri * (1 << i);
    i++;
  }

  i = 0;
  for (auto ri = epsilon.rbegin(); ri != epsilon.rend(); ++ri) {
    epsilon_num += *ri * (1 << i);
    i++;
  }
  return to_string(gamma_num * epsilon_num);
}

auto solve_p2(vector<string> reports) {
  auto oxy_reports = reports;
  auto co2_reports = reports;
  int length = reports[0].size();
  for (int i = 0; i < length; i++) {
    // oxy part
    auto oxy_bc = cb(oxy_reports, i);
    auto o_bit = mcb(oxy_bc);
    int oxy_bit;
    if (!o_bit.has_value()) {
      oxy_bit = 1;
    } else {
      oxy_bit = *o_bit;
    }
    oxy_reports.erase(
        remove_if(oxy_reports.begin(), oxy_reports.end(),
                  [=](string report) { return (report[i] - 48) != oxy_bit; }),
        oxy_reports.end());

    // co2 part
    auto co2_bc = cb(co2_reports, i);
    auto c_bit = mcb(co2_bc);
    int co2_bit;
    if (!c_bit.has_value()) {
      co2_bit = 0;
    } else {
      co2_bit = 1 - *c_bit;
    }

    co2_reports.erase(
        remove_if(co2_reports.begin(), co2_reports.end(),
                  [=](string report) { return (report[i] - 48) != co2_bit; }),
        co2_reports.end());
  }
  uint oxy_rating = stoul(oxy_reports[0], nullptr, 2);
  uint co2_rating = stoul(co2_reports[0], nullptr, 2);

  return to_string(oxy_rating * co2_rating);
}

auto solve(string input) {
  auto lines = split(input, '\n');
  auto p1 = solve_p1(lines);
  auto p2 = solve_p2(lines);

  return make_tuple(p1, p2);
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010)";

    auto results = solve(example);

    expect(get<0>(results) == "198"s);
    expect(get<1>(results) == "230"s);
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
