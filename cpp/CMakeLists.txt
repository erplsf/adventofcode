cmake_minimum_required(VERSION 3.21)

project(aoc)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# target_compile_options(aoc PRIVATE -Wall -Wextra -Wshadow)

add_executable(2015_1 src/2015/1/main.cpp)
