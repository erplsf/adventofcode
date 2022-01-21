cmake_minimum_required(VERSION 3.21)

if(${APPLE})
  SET(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
endif()

project(aoc)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_BUILD_TYPE Debug)

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

CPMAddPackage(gh:boost-ext/ut@1.1.8)
add_library(ut INTERFACE)

SET(FMT_TEST FALSE)
CPMAddPackage("gh:fmtlib/fmt#8.0.1@8.0.1")

CPMAddPackage(
  NAME Boost
  VERSION 1.77.0
  URL https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz
  URL_HASH SHA256=5347464af5b14ac54bb945dc68f1dd7c56f0dad7262816b956138fc53bcc0131
)

if (Boost_ADDED)
  add_library(Boost::boost INTERFACE IMPORTED GLOBAL)
  target_include_directories(Boost::boost SYSTEM INTERFACE ${Boost_SOURCE_DIR})

  # Disable autolink
  target_compile_definitions(Boost::boost INTERFACE BOOST_ALL_NO_LIB=1)
endif()

add_library(aoc_util
  src/2021/aoc/aoc.hpp
  src/2021/aoc/aoc.cpp
  src/2021/aoc/tdm.hpp
  # src/2021/aoc/tdm.cpp
)

target_include_directories(aoc_util SYSTEM PUBLIC ${fmt_SOURCE_DIR}/include)
target_link_libraries(aoc_util PRIVATE fmt)

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
  target_include_directories("${aoc_year}_${day}" SYSTEM PUBLIC ${ut_SOURCE_DIR}/include)
  target_include_directories("${aoc_year}_${day}" PUBLIC src/2021)
  target_include_directories("${aoc_year}_${day}" SYSTEM PUBLIC ${fmt_SOURCE_DIR}/include)
  target_link_libraries("${aoc_year}_${day}" PRIVATE Boost::boost)
  target_link_libraries("${aoc_year}_${day}" PRIVATE ut)
  target_link_libraries("${aoc_year}_${day}" PRIVATE aoc_util)
  target_link_libraries("${aoc_year}_${day}" PRIVATE fmt)
  add_dependencies(${aoc_year} "${aoc_year}_${day}")
endfunction()

# aoc_start_year(2015)
# aoc_add_day(1)
# aoc_end_year()

aoc_start_year(2021)
aoc_add_day(1)
aoc_add_day(2)
aoc_add_day(3)
aoc_add_day(4)
aoc_add_day(5)
aoc_add_day(6)
aoc_add_day(7)
aoc_add_day(8)
aoc_add_day(9)
aoc_add_day(10)
aoc_add_day(11)
aoc_add_day(16)
aoc_add_day(18)
aoc_end_year()
