cmake_minimum_required(VERSION 3.21)

project(aoc)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

add_compile_options(-Wall -Wextra -Werror -Wshadow -Wdouble-promotion)

macro(aoc_start_year year)
  set(aoc_year ${year})
  add_custom_target(${aoc_year})
endmacro()

macro(aoc_end_year)
  unset(aoc_year)
endmacro()

function(aoc_add_day day)
  add_executable("${aoc_year}_${day}" "src/${aoc_year}/${day}/main.cpp")
  set_target_properties("${aoc_year}_${day}" PROPERTIES RUNTIME_OUTPUT_DIRECTORY "bin/${aoc_year}")
  set_target_properties("${aoc_year}_${day}" PROPERTIES OUTPUT_NAME ${day})
  add_dependencies(${aoc_year} "${aoc_year}_${day}")
endfunction()

aoc_start_year(2015)
aoc_add_day(1)
aoc_end_year()

aoc_start_year(2021)
aoc_add_day(1)
aoc_end_year()
