#include <cstdint>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <sstream>

using namespace std;

string read_input(string path) {
  ifstream file(path);
  if (file) {
    stringstream content;
    content << file.rdbuf();
    return content.str();
  }
  return "";
}

string resolve_input(int day, int argc, char** argv) {
  stringstream path;
  if (argc == 2) {
    path << argv[1];
  } else {
    path << "../../inputs/" << day << ".txt";
  }
  return path.str();
}

constexpr const int DAY = 1;

int main(int argc, char* argv[]) {
  string path = resolve_input(DAY, argc, argv);
  string content = read_input(path);

  // sol
  int floor = 0;
  uint index = 0;
  bool stop = false;
  for (char& ch: content) {
    if (ch == '(') {
      floor++;
    } else if (ch == ')') {
      floor--;
    }
    index++;
    if (floor == -1 && !stop) {
      stop = true;
      cout << index << "\n";
    }
  }

  cout << floor << "\n";

  return 0;
}
