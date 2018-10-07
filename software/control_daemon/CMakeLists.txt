CMAKE_MINIMUM_REQUIRED(VERSION 3.10)
PROJECT(axiom_daemon)

include(ExternalProject)

SET(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
#SET(CMAKE_VERBOSE_MAKEFILE ON)

OPTION(ENABLE_MOCK "Enable mock (e.g. memory-related code) implementation for developemnt" OFF) # Disabled by default
IF(ENABLE_MOCK)
    ADD_DEFINITIONS(-DENABLE_MOCK=ON)
ENDIF(ENABLE_MOCK)

# Required by flatbuffers also
ADD_COMPILE_OPTIONS(-std=c++11)

# Make GCC more strict
#SET(CMAKE_CXX_FLAGS "-Wall -Wextra")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Compiler flags
if (CMAKE_BUILD_TYPE STREQUAL "Release")
    SET(CMAKE_CXX_FLAGS "-O2") #Optimize
    SET(CMAKE_EXE_LINKER_FLAGS "-s") # Strip binary
endif()

# Switched back from fork to original, as GoAPI is not maintained at the moment
# Forked version contains Go generator adjustments for strong types for enums
ExternalProject_Add(flatbuffers_project
    PREFIX 3rdParty/flatbuffers
    GIT_REPOSITORY "https://github.com/google/flatbuffers.git"
    GIT_TAG "master"
    UPDATE_COMMAND ""
    INSTALL_COMMAND ""
    CMAKE_ARGS -DFLATBUFFERS_BUILD_TESTS=OFF -DFLATBUFFERS_INSTALL=OFF -DFLATBUFFERS_BUILD_FLATLIB=OFF -DFLATBUFFERS_BUILD_FLATHASH=OFF)

ExternalProject_Get_Property(flatbuffers_project BINARY_DIR)
MESSAGE(STATUS "flatbuffers binary dir: ${BINARY_DIR}")
ExternalProject_Get_Property(flatbuffers_project SOURCE_DIR)
MESSAGE(STATUS "flatbuffers source dir: ${SOURCE_DIR}")
include_directories(${SOURCE_DIR}/include)

# JSON
#INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/3rdParty/json/)

# Pistache
# ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/3rdParty/pistache)
# INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/3rdParty/pistache/include)

SET(FLATC ${BINARY_DIR}/flatc)
MESSAGE(STATUS "flatc location: ${FLATC}")

FILE(GLOB SOURCE_FILES "Adapter/*.cpp" "Adapter/*.h"
    "Daemon/*.cpp" "Daemon/*.h"
    "Schema/*.fbs"
    "Helpers/*.cpp" "Helpers/*.h"
    "Log/*.cpp" "Log/*.h")

FILE(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/Schema/)

# C/C++schema
ADD_CUSTOM_TARGET(flatc_cpp_gen
    COMMAND ${FLATC} --scoped-enums --gen-object-api --no-prefix --cpp ${PROJECT_SOURCE_DIR}/Schema/axiom_daemon.fbs
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src/Schema/
    COMMENT "Running flatc_cpp_gen action" DEPENDS flatbuffers_project)

# Copy systemd description files
FILE(COPY ${CMAKE_SOURCE_DIR}/systemd/ DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

ExternalProject_Add(uWebSockets
    GIT_REPOSITORY "https://github.com/uNetworking/uWebSockets.git"
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make
    BUILD_IN_SOURCE ON
    LOG_DOWNLOAD ON)

ExternalProject_Get_Property(uWebSockets SOURCE_DIR)
MESSAGE(STATUS "uWebSockets DIR: ${SOURCE_DIR}")
MESSAGE(STATUS "uWebSockets SRC_DIR: ${SOURCE_DIR}/src")

# Used for loading generated headers, e.g. #include <Schema/axiom_daemon_generated.h>
INCLUDE_DIRECTORIES(${SOURCE_DIR}/src/)


# Client example should be build separately for now
#ADD_SUBDIRECTORY(API_WS)
ADD_SUBDIRECTORY(CLI)
#ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/GoAPI/)

# Catch2 (unit test framework)
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/3rdParty/)

# Unit tests 
#ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/UnitTests/)

# Used for loading generated headers, e.g. #include <Schema/axiom_daemon_generated.h>
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/src/)

ADD_EXECUTABLE(${PROJECT_NAME} ${SOURCE_FILES})
ADD_DEPENDENCIES(${PROJECT_NAME} flatc_cpp_gen)

TARGET_LINK_LIBRARIES(${PROJECT_NAME} systemd)

find_program(
  CLANG_TIDY_EXE
  NAMES "clang-tidy"
  DOC "Path to clang-tidy executable"
  )
if(NOT CLANG_TIDY_EXE)
  message(STATUS "clang-tidy not found.")
else()
  message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
  set(DO_CLANG_TIDY "${CLANG_TIDY_EXE}" "-checks=*,-clang-analyzer-alpha.*")
endif()

set_target_properties(
  ${PROJECT_NAME} PROPERTIES
  CXX_STANDARD 11
  CXX_STANDARD_REQUIRED ON
  COMPILE_FLAGS "${WARNING_FLAGS}"
)

if(CLANG_TIDY_EXE)
  set_target_properties(
    ${PROJECT_NAME} PROPERTIES
    CXX_CLANG_TIDY "${DO_CLANG_TIDY}"
  )
endif()
