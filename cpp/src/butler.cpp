#include <CLI/App.hpp>
#include <CLI/Config.hpp>
#include <CLI/Formatter.hpp>
#include <curlpp/Easy.hpp>
#include <curlpp/Options.hpp>
#include <curlpp/cURLpp.hpp>
#include <filesystem>

using namespace std;
namespace fs = std::filesystem;

int main(int argc, char **argv) {
  CLI::App app{R"(butler
	Helper that downloads aoc inputs.)"};

  std::string token;
  app.add_option("token", token, "AoC session token")->required();

  fs::path output_path;
  app.add_option("output_path", output_path, "where to place files")
      ->required();

  std::string year;
  app.add_option("year", year, "year to download from")->required();

  std::string day;
  app.add_option("day", day, "day to download")->required();

  CLI11_PARSE(app, argc, argv);

  if (fs::exists(output_path)) {
    fs::path year_dir = output_path;
    year_dir.append(year);
    if (!fs::exists(year)) {
      fs::create_directory(year_dir);
    }
  } else {
    // throw
  }

  cURLpp::Easy handle;
  handle.setOpt(new cURLpp::Options::Url("http://www.example.com");

  return 0;
}
