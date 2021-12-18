#include <algorithm>
#include <aoc/aoc.hpp>
#include <boost/ut.hpp>
#include <fmt/core.h>
#include <numeric>
#include <string>
#include <unordered_map>
#include <variant>

using namespace aoc;
using namespace std;
using namespace boost::ut;

typedef uint64_t ull;

struct sn {
  ull value;
  ull level;
  sn *left;
  sn *right;
};

auto parse(string input) {
  sn *num, *curr_sn, *prev_sn;
  num = new sn();
  curr_sn = num;
  ull level = 0;
  for (auto &&c : input) {
    switch (c) {
    case '[': {
      level++;
      break;
    }
    case ']': {
      level--;
      break;
    }
    case ',': {
      prev_sn = curr_sn;
      curr_sn = new sn();
      prev_sn->right = curr_sn;
      curr_sn->left = prev_sn;
      break;
    }
    default: {
      curr_sn->value = atoll(&c);
      curr_sn->level = level;
    }
    }
  }
  return num;
}

// void plsn(sn &num) {
// }

void psn(string &s, sn &num, ull prev_level = 0, ull sl = 0) {
  // fmt::print("{}", num.level - prev_level);
  int64_t diff = num.level - prev_level;
  if (diff > 0) {
    s += fmt::format("{}", string(diff, '['));
  } else if (diff == 0 && sl == 2) {
    s += fmt::format("],[");
    sl = 0;
  } else if (diff < 0) {
    s += fmt::format("{},", string(abs(diff), ']'));
  } else {
    s += fmt::format(",");
  }
  s += fmt::format("{}", num.value);
  sl++;
  if (num.right) {
    psn(s, *num.right, num.level, sl);
  } else if (diff > 0) {
    s += fmt::format("{}", string(diff, ']'));
  } else {
    s += fmt::format("]");
  }
}

string o_psn(sn &num) {
  string s;
  psn(s, num);
  return s;
}

auto solve(string) { return make_pair(0, 0); }

suite tests = [] {
  test("example") = [] {
    sn *num;
    string inp;

    inp = "[1,2]";
    num = parse(inp);
    expect(o_psn(*num) == inp);

    inp = "[[1,2],3]";
    num = parse(inp);
    expect(o_psn(*num) == inp);

    inp = "[9,[8,7]]";
    num = parse(inp);
    expect(o_psn(*num) == inp);
  };
};

int main(int argc, char *argv[]) {
  auto contents = get_input(argc, argv);
  if (!contents)
    return 1;

  auto results = solve(*contents);

  fmt::print("part one: {}\n", get<0>(results));
  fmt::print("part two: {}\n", get<1>(results));
}
