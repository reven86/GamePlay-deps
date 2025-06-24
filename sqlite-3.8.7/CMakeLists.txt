cmake_minimum_required(VERSION 3.10)

add_library(sqlite sqlite3.c)

install(FILES sqlite3.h DESTINATION include)
