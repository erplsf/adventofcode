#include <CLI/App.hpp>
#include <CLI/Config.hpp>
#include <CLI/Formatter.hpp>
#include <curlpp/cURLpp.hpp>

int main(int argc, char **argv) {
  CLI::App app{R"(Butler
	Helper that downloads inputs.)"};

  std::string token = "token";
  app.add_option("-t,--token", token, "AoC session token");

  CLI11_PARSE(app, argc, argv);

  if (token == "token") {
    std::cout << app.help();
  }

  return 0;
}
