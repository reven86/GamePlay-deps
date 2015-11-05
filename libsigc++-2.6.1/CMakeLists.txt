project(libsigc++)
cmake_minimum_required(VERSION 2.8)

set(PACKAGE_VERSION "2.6.1")
set(SIGCXX_MAJOR_VERSION "2")
set(SIGCXX_MINOR_VERSION "6")
set(SIGCXX_MICRO_VERSION "1")

include(Configure_config.cmake)

include_directories("${PROJECT_BINARY_DIR}/sigc++")
include_directories("${PROJECT_SOURCE_DIR}")

if(WIN32)
    add_definitions(-D_ALLOW_KEYWORD_MACROS)
    add_definitions(-Dnoexcept=)
endif(WIN32)

add_definitions(-std=c++11)
IF(APPLE AND NOT IOS)
add_definitions(-stdlib=libc++)
ENDIF(APPLE AND NOT IOS)

add_subdirectory(sigc++)