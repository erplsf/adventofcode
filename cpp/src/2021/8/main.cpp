#include <aoc/aoc.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <fmt/core.h>
#include <math.h>
#include <set>
#include <string>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

typedef set<char> dset;
typedef unordered_map<dset, uint, boost::hash<dset>> u_map;
typedef unordered_map<uint, dset> ru_map;

template <> struct fmt::formatter<dset> {
  constexpr auto parse(format_parse_context& ctx) -> decltype(ctx.begin()) {
    // Return an iterator past the end of the parsed range:
    auto it = ctx.end();
    return it++;
  }

  template <typename FormatContext>
  auto format(const dset& s, FormatContext& ctx) -> decltype(ctx.out()) {
    // ctx.out() is an output iterator to write to.
    auto o = format_to(ctx.out(), "|");
    for (auto it = s.begin(); it != s.end(); it++) {
      if (it != s.begin()) {
        o = format_to(o, ",");
      }
      o = format_to(o, "{}", *it);
    }
    return format_to(o, "|");
  }
};

template <> struct fmt::formatter<u_map> {
  constexpr auto parse(format_parse_context& ctx) -> decltype(ctx.begin()) {
    // Return an iterator past the end of the parsed range:
    auto it = ctx.end();
    return it++;
  }

  template <typename FormatContext>
  auto format(const u_map& map, FormatContext& ctx) -> decltype(ctx.out()) {
    // ctx.out() is an output iterator to write to.
    auto o = format_to(ctx.out(), "{{\n");
    for (auto it = map.begin(); it != map.end(); it++) {
      if (it != map.begin()) {
        o = format_to(o, "\n");
      }
      o = format_to(o, "\t{} -> {}", it->first, it->second);
    }
    return format_to(o, "\n}}");
  }
};

template <> struct fmt::formatter<ru_map> {
  constexpr auto parse(format_parse_context& ctx) -> decltype(ctx.begin()) {
    // Return an iterator past the end of the parsed range:
    auto it = ctx.end();
    return it++;
  }

  template <typename FormatContext>
  auto format(const ru_map& map, FormatContext& ctx) -> decltype(ctx.out()) {
    // ctx.out() is an output iterator to write to.
    auto o = format_to(ctx.out(), "{{\n");
    for (auto it = map.begin(); it != map.end(); it++) {
      if (it != map.begin()) {
        o = format_to(o, "\n");
      }
      o = format_to(o, "\t{} -> {}", it->first, it->second);
    }
    return format_to(o, "\n}}");
  }
};

void simple_find(vector<dset>& numbers, uint segment_size, uint actual_number,
                 u_map& um, ru_map& rum) {
  auto val = find_if(numbers.begin(), numbers.end(),
                     [&](dset ds) { return ds.size() == segment_size; });

  if (val != (end(numbers))) {
    um[*val] = actual_number;
    rum[actual_number] = *val;
  }
}

auto oracle(vector<dset>& numbers) {
  u_map map;
  ru_map rmap;

  simple_find(numbers, 2, 1, map, rmap);
  simple_find(numbers, 4, 4, map, rmap);
  simple_find(numbers, 3, 7, map, rmap);
  simple_find(numbers, 7, 8, map, rmap);

  // find nine

  auto val = find_if(numbers.begin(), numbers.end(), [&](dset ds) {
    auto copy_val = ds;
    auto copy_seven = rmap[7];
    auto copy_four = rmap[4];
    copy_val.merge(copy_seven);
    copy_val.merge(copy_four);
    return ds.size() == 6 && copy_val.size() == ds.size();
  });

  if (val != (end(numbers))) {
    map[*val] = 9;
    rmap[9] = *val;
  }

  // find three
  val = find_if(numbers.begin(), numbers.end(), [&](dset ds) {
    auto copy_val = ds;
    auto copy_one = rmap[1];
    copy_val.merge(copy_one);

    return copy_val.size() == 5;
  });

  if (val != (end(numbers))) {
    map[*val] = 3;
    rmap[3] = *val;
  }

  // find zero
  val = find_if(numbers.begin(), numbers.end(), [&](dset ds) {
    auto copy_val = ds;
    auto copy_one = rmap[1];
    copy_val.merge(copy_one);

    return ds.size() == 6 && copy_val != rmap[9] &&
           copy_val.size() == ds.size();
  });

  if (val != (end(numbers))) {
    map[*val] = 0;
    rmap[0] = *val;
  }

  // find six
  val = find_if(numbers.begin(), numbers.end(), [&](dset ds) {
    return ds.size() == 6 && ds != rmap[9] && ds != rmap[0];
  });

  if (val != (end(numbers))) {
    map[*val] = 6;
    rmap[6] = *val;
  }

  // find two
  val = find_if(numbers.begin(), numbers.end(), [&](dset ds) {
    auto copy_val = ds;
    auto copy_four = rmap[4];
    copy_val.merge(copy_four);

    return ds.size() == 5 && copy_val == rmap[8];
  });

  if (val != (end(numbers))) {
    map[*val] = 2;
    rmap[2] = *val;
  }

  // find five
  val = find_if(numbers.begin(), numbers.end(), [&](dset ds) {
    return ds.size() == 5 && ds != rmap[2] && ds != rmap[3];
  });

  if (val != (end(numbers))) {
    map[*val] = 5;
    rmap[5] = *val;
  }

  // fmt::print("map: {}\n", map);
  // fmt::print("rmap: {}\n", rmap);

  return make_pair(map, rmap);
}

uint resolve(u_map& map, string& digits) {
  dset ds(digits.begin(), digits.end());
  return map[ds];
}

auto sol(string input, bool second_part = false) {
  auto lines = split(input, '\n');
  uint answer = 0;
  // cout << "s: " << lines.size() << "\n";
  for (auto&& line: lines) {
    // cout << "l: " << line;
    auto parts = split(line, '|');
    // cout << "s: " << parts.size() << "\n";
    auto left = parts[0];
    // cout << "here\n";
    trim(left);
    auto puzzle_digits = split(left, ' ');
    vector<dset> dsets;
    for (auto&& digit: puzzle_digits) {
      dset ds(digit.begin(), digit.end());
      dsets.emplace_back(ds);
    }

    auto [map, rmap] = oracle(dsets);

    auto right = parts[1];
    trim(right);
    auto digits = split(right, ' ');

    if (!second_part) {
      for (auto&& digit: digits) {
        auto value = resolve(map, digit);
        if (value == 1 || value == 4 || value == 7 || value == 8) {
          answer++;
        }
      }
    } else {
      auto total_right_value = 0;
      for (size_t i = 0; i < digits.size(); i++) {
        auto value = resolve(map, digits[i]);
        value *= pow(10, digits.size() - i - 1);
        total_right_value += value;
      }
      answer += total_right_value;
      // fmt::print("tot -> {}: {}\n", digits, total_right_value);
    }
  }
  return answer;
}

auto solve(string input) {
  auto p1 = sol(input);
  auto p2 = sol(input, true);

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
    expect(p2 == 61229_i);
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
