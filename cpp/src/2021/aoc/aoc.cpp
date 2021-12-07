#include "aoc.hpp"
#include <algorithm>
#include <cctype>
#include <fstream>
#include <locale>
#include <regex>
#include <sstream>

namespace aoc {

using namespace std;

optional<string> get_input(int argc, char *argv[]) {
  if (argc != 2) {
    return {};
  }
  ifstream file(argv[1]);
  return string((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
}

vector<string> split(const string &input, char delim) {
  vector<string> results;
  auto stream = stringstream{input};

  for (string part; getline(stream, part, delim);)
    results.emplace_back(part);

  return results;
}

vector<string> split(const string &input, const string &regex) {
  std::regex re(regex);
  sregex_token_iterator it{input.begin(), input.end(), re, -1};
  return vector<string>{it, {}};
}

void ltrim(string &s) {
  s.erase(s.begin(), find_if(s.begin(), s.end(),
                             [](unsigned char ch) { return !isspace(ch); }));
}

void rtrim(string &s) {
  s.erase(find_if(s.rbegin(), s.rend(),
                  [](unsigned char ch) { return !isspace(ch); })
              .base(),
          s.end());
}

void trim(string &s) {
  ltrim(s);
  rtrim(s);
}

} // namespace aoc
