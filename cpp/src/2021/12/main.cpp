#include <aoc/aoc.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/ut.hpp>
#include <unordered_map>

using namespace aoc;
using namespace std;
using namespace boost::ut;

struct node {
  string name;
  vector<shared_ptr<node>> neighbors;
  bool small;
};

template <> struct fmt::formatter<node> {
  constexpr auto parse(format_parse_context& ctx) -> decltype(ctx.begin()) {
    // Return an iterator past the end of the parsed range:
    auto it = ctx.end();
    return it++;
  }

  template <typename FormatContext>
  auto format(const node& v, FormatContext& ctx) -> decltype(ctx.out()) {
    // ctx.out() is an output iterator to write to.
    return format_to(ctx.out(), "name: {}, neighbors: {}", v.name, v.neighbors);
  }
};

template <> struct fmt::formatter<vector<shared_ptr<node>>> {
  constexpr auto parse(format_parse_context& ctx) -> decltype(ctx.begin()) {
    // Return an iterator past the end of the parsed range:
    auto it = ctx.end();
    return it++;
  }

  template <typename FormatContext>
  auto format(const vector<shared_ptr<node>>& v, FormatContext& ctx)
      -> decltype(ctx.out()) {
    // ctx.out() is an output iterator to write to.
    auto c = format_to(ctx.out(), "[");
    for (auto it = v.begin(); it != v.end(); it++) {
      if (it != v.begin()) {
        c = format_to(c, ",");
      }
      c = format_to(c, "{}", (*it)->name);
    }
    return format_to(c, "]");
  }
};

typedef unordered_map<string, node> nodemap;

auto sol_p1(string input) {
  nodemap nm;
  auto lines = split(input, '\n');
  for (auto&& line: lines) {
    auto parts = split(line, '-');
    fmt::print("{} -> {}\n", parts[0], parts[1]);
    if (!nm.contains(parts[0])) {
      node from = {.name = parts[0]};
      nm[from.name] = from;
    }
    if (!nm.contains(parts[1])) {
      node to = {.name = parts[1]};
      nm[to.name] = to;
    }
    nm[parts[0]].neighbors.emplace_back(make_shared<node>(nm[parts[1]]));
    nm[parts[1]].neighbors.emplace_back(make_shared<node>(nm[parts[0]]));
    fmt::print("{}\n", nm);
  }
  return 0;
}
auto sol_p2(string input) {
  (void)input;
  return 0;
}

auto solve(string input) {
  auto p1 = sol_p1(input);
  auto p2 = sol_p2(input);

  return make_pair(p1, p2);
}

suite tests = [] {
  test("example") = [] {
    auto example = R"(start-A
start-b
A-c
A-b
b-d
A-end
b-end)";

    expect(sol_p1(example) == 10_i);
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
