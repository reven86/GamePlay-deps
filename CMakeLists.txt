cmake_minimum_required(VERSION 3.10...3.27)

project(GamePlay-deps)

IF(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT ANDROID)
    SET(LINUX 1)
ENDIF(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT ANDROID)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    SET(EMSCRIPTEN 1)
endif(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    
SET(BUILD_SHARED_LIBS 0)

MESSAGE("Platform: ${CMAKE_SYSTEM_NAME} ${PLATFORM}")
MESSAGE("Build shared: ${BUILD_SHARED_LIBS}")
MESSAGE("Configuration: ${CMAKE_BUILD_TYPE}")

# ARCH detection
if (ANDROID)
    set(ARCH ${ANDROID_ARCH_NAME})
elseif(IOS)
    if (PLATFORM STREQUAL "OS64")
        set(ARCH "arm")
    else (PLATFORM STREQUAL "OS64")
        set(ARCH "x86")
    endif (PLATFORM STREQUAL "OS64")
else(IOS)
    # Skip any introspection for cross-compiling targets
    include(${PROJECT_SOURCE_DIR}/cmake/TargetArch.cmake)
    target_architecture(ARCH)
endif(ANDROID)

string(TOLOWER ${CMAKE_SYSTEM_NAME} LOWER_SYSTEM_NAME)
set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/out")
set(LIBRARY_OUTPUT_PATH "${PROJECT_SOURCE_DIR}/out/lib/${LOWER_SYSTEM_NAME}/${ARCH}")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH})

file(MAKE_DIRECTORY ${LIBRARY_OUTPUT_PATH})
message(STATUS "Directory: ${LIBRARY_OUTPUT_PATH}")

IF(NOT WIN32)
    # For Windows, let the user pick since we need to generate both Debug and
    # Release variants of all the libs.
    IF(NOT DEFINED CMAKE_BUILD_TYPE)
        SET(CMAKE_BUILD_TYPE "Release")
    ENDIF(NOT DEFINED CMAKE_BUILD_TYPE)
ENDIF(NOT WIN32)

IF(ANDROID)
    add_definitions(-include "string.h")
ENDIF(ANDROID)

add_compile_options(
    "$<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>"
)

IF(BUILD_EXTRA_LIBS)
    #add_subdirectory(sqlite-3.8.7)
ENDIF(BUILD_EXTRA_LIBS)

#add_subdirectory(Box2D-2.3.0)

#add_subdirectory(tinyxml2-2.1.0)
add_subdirectory(lua-5.4.8)
add_subdirectory(yaml-0.1.5)
add_subdirectory(libsigc++-2.6.1)
add_subdirectory(jpeg-8d)

if (NOT APPLE AND NOT EMSCRIPTEN)
    # We can safely skip GLEW and OpenAL for any Apple based platforms
    add_subdirectory(glew-1.10.0)
    if(ANDROID AND CMAKE_HOST_WIN32)
        set(ALSOFT_NATIVE_TOOLS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/build_windows_x64/openal-1.20.1/native-tools")
    endif()
    add_subdirectory(openal-1.20.1)
endif(NOT APPLE AND NOT EMSCRIPTEN)

# zlib must be built before png and curl
add_subdirectory(zlib-1.2.8)
add_subdirectory(png-1.6.15)
add_subdirectory(libzip-1.5.1a)
add_subdirectory(openssl-1.1.1w)

if(NOT EMSCRIPTEN)
    add_subdirectory(curl-7.49.1)
    add_dependencies(libcurl ssl)

    add_subdirectory(clickhouse-2.5.1)
    target_compile_options(clickhouse-cpp-lib PRIVATE -frtti)
endif(NOT EMSCRIPTEN)

# Ogg needs to be built before vorbis
add_subdirectory(ogg-1.3.2)
add_subdirectory(vorbis-1.3.4)

add_subdirectory(bullet-2.82-r2704)

set(protobuf_MSVC_STATIC_RUNTIME OFF)
add_subdirectory(protobuf-3.21.5)

set(HB_BUILD_TESTS OFF CACHE BOOL "Disable HarfBuzz tests")
set(HB_HAVE_FREETYPE OFF CACHE BOOL "Disable HarfBuzz's FreeType integration")
set(HB_HAVE_ICU OFF CACHE BOOL "Disable ICU integration")
set(HB_BUILD_SUBSET OFF CACHE BOOL "Disable HB Subset" FORCE)

add_subdirectory(harfbuzz-11.3.3)

# Bypass find_package by pre-setting variables
set(HarfBuzz_FOUND TRUE)
set(HarfBuzz_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/harfbuzz-11.3.3/src")
set(HarfBuzz_LIBRARY harfbuzz)
set(FT_REQUIRE_HARFBUZZ ON)
set(FT_DYNAMIC_HARFBUZZ OFF)

add_subdirectory(freetype-2.13.3)
add_library(Freetype::Freetype ALIAS freetype)

set(LUNASVG_BUILD_EXAMPLES OFF CACHE BOOL "Build examples" FORCE)
set(PLUTOVG_BUILD_EXAMPLES OFF CACHE BOOL "Build examples" FORCE)
add_subdirectory(lunasvg-3.3.0)

set(RMLUI_LUA_BINDINGS ON CACHE BOOL "Enable Lua bindings" FORCE)
set(RMLUI_SVG_PLUGIN ON CACHE BOOL "Enable plugin for SVG images. Requires the lunasvg library." FORCE)
set(RMLUI_CUSTOM_RTTI ON CACHE BOOL "RmlUi Custom RTTI" FORCE)

# Tell RmlUi where to find our built Lua
set(LUA_LIBRARIES lua CACHE INTERNAL "Lua library target")
set(LUA_INCLUDE_DIR "${PROJECT_SOURCE_DIR}/lua-5.4.8/src" CACHE INTERNAL "Lua includes")

include(FetchContent)

FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt
  GIT_TAG        12.1.0)
FetchContent_MakeAvailable(fmt)

set(BUILD_TARGETS
    #Box2D
    BulletDynamics
    LinearMath
    BulletCollision
    vorbisfile
    vorbisenc
    vorbis
    ogg
    png_static
    zlibstatic
    lua
    #tinyxml2static
    yaml
    zip
    sigcpp
    jpeg
    ssl
    libprotobuf-lite
    harfbuzz
    freetype
    lunasvg
    fmt::fmt
)

# build RmlUi for windows separately (to allow making changes there and push to upstream)
# if (NOT WIN32)
    add_subdirectory(RmlUi-6.2)
    list(APPEND BUILD_TARGETS rmlui_core)
    list(APPEND BUILD_TARGETS rmlui_debugger)
    list(APPEND BUILD_TARGETS rmlui_lua)
# endif (NOT WIN32)

if (NOT EMSCRIPTEN)
    list(APPEND BUILD_TARGETS libcurl)
    list(APPEND BUILD_TARGETS clickhouse-cpp-lib)

    if (NOT APPLE)
        list(APPEND BUILD_TARGETS GLEW)
        list(APPEND BUILD_TARGETS OpenAL)
    endif(NOT APPLE)
endif (NOT EMSCRIPTEN)

if(WIN32)
    set(GAMEPLAY_DEPS gameplay-deps.lib)
else(WIN32)
    set(GAMEPLAY_DEPS libgameplay-deps.a)
endif(WIN32)

if(LINUX OR ANDROID)
    add_custom_command(
        OUTPUT ${GAMEPLAY_DEPS}
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake/gnu-amalgamate.sh ${CMAKE_AR} ${LIBRARY_OUTPUT_PATH}
    )
elseif(APPLE)
    add_custom_command(
        OUTPUT ${GAMEPLAY_DEPS}
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake/xcode-amalgamate.sh ${LIBRARY_OUTPUT_PATH}
    )
elseif(WIN32)
    # Windows
    add_custom_command(
        OUTPUT ${GAMEPLAY_DEPS}
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake/msvc-amalgamate.bat ${LIBRARY_OUTPUT_PATH}/${CMAKE_CFG_INTDIR}
    )
else()
    # Emscripten
    add_custom_command(
        OUTPUT ${GAMEPLAY_DEPS}
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake/emscripten-amalgamate.sh ${CMAKE_AR} ${LIBRARY_OUTPUT_PATH}
    )
endif(LINUX OR ANDROID)

add_custom_target(gameplay-deps ALL DEPENDS ${GAMEPLAY_DEPS})
add_dependencies(gameplay-deps ${BUILD_TARGETS})

SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES ${LIBRARY_OUTPUT_PATH}/${GAMEPLAY_DEPS})
