#ifndef AOC_H_
#define AOC_H_

#include <fmt/core.h>
#include <fmt/format.h>
#include <optional>
#include <string>
#include <vector>

using namespace std;

namespace aoc {
constexpr size_t c_hash(const char *str) {
  const long long p = 131;
  const long long m = 4294967291; // 2^32 - 5, largest 32 bit prime
  long long total = 0;
  long long current_multiplier = 1;
  for (int i = 0; str[i] != '\0'; ++i) {
    total = (total + current_multiplier * str[i]) % m;
    current_multiplier = (current_multiplier * p) % m;
  }
  return total;
}

optional<string> get_input(int argc, char *argv[]);

vector<string> split(const string &input, char delim);

vector<string> split(const string &input, const string &regex);

void ltrim(string &s);

void rtrim(string &s);

void trim(string &s);

} // namespace aoc

template <typename value> struct fmt::formatter<vector<value>> {
  constexpr auto parse(format_parse_context &ctx) -> decltype(ctx.begin()) {
    // Return an iterator past the end of the parsed range:
    auto it = ctx.end();
    return it++;
  }

  template <typename FormatContext>
  auto format(const vector<value> &vec, FormatContext &ctx)
      -> decltype(ctx.out()) {
    // ctx.out() is an output iterator to write to.
    auto o = format_to(ctx.out(), "[");
    for (auto it = vec.begin(); it != vec.end(); it++) {
      if (it != vec.begin()) {
        o = format_to(o, ",");
      }
      o = format_to(o, "{}", *it);
    }
    return format_to(o, "]");
  }
};

#endif // AOC_H_
