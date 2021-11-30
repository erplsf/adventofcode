cmake_minimum_required(VERSION 3.21)

project(aoc)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_compile_options(-Wall -Wextra -Werror -Wshadow -Wdouble-promotion)

# inputs downloader
add_executable(butler src/butler.cpp)
set_target_properties(butler PROPERTIES RUNTIME_OUTPUT_DIRECTORY bin)

include(cmake/CPM.cmake)

CPMAddPackage(gh:jpbarrette/curlpp@0.8.1)
target_link_libraries(butler curlpp)
target_include_directories(butler SYSTEM PUBLIC ${curlpp_SOURCE_DIR}/include)

CPMAddPackage(gh:CLIUtils/CLI11@2.1.2)
target_include_directories(butler SYSTEM PUBLIC ${CLI11_SOURCE_DIR}/include)

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

# aoc_start_year(2015)
# aoc_add_day(1)
# aoc_end_year()

aoc_start_year(2021)
aoc_add_day(1)
aoc_end_year()
