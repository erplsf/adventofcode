cmake_minimum_required(VERSION 3.21)

project(aoc)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

macro(aoc_start_year year)
  set(aoc_year ${year})
endmacro()

macro(aoc_end_year)
  unset(aoc_year)
endmacro()

function(aoc_add_day day)
  add_executable("${aoc_year}_${day}" "src/${aoc_year}/${day}/main.cpp")
  target_compile_options("${aoc_year}_${day}" PRIVATE -Wall -Wextra -Wshadow)
  set_target_properties("${aoc_year}_${day}" PROPERTIES RUNTIME_OUTPUT_DIRECTORY "bin/${aoc_year}")
  set_target_properties("${aoc_year}_${day}" PROPERTIES OUTPUT_NAME ${day})
endfunction()

aoc_start_year(2015)
aoc_add_day(1)
aoc_end_year()

aoc_start_year(2021)
aoc_add_day(1)
aoc_end_year()
