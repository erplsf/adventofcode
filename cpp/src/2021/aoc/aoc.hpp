#ifndef AOC_H_
#define AOC_H_

#include <optional>
#include <string>
#include <vector>

namespace aoc {
using namespace std;

optional<string> get_input(int argc, char *argv[]);

vector<string> split(const string &input, char delim);

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

} // namespace aoc

#endif // AOC_H_
