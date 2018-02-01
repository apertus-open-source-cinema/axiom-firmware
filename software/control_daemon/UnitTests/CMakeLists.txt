CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
PROJECT(DaemonTests)

SET(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
SET(CMAKE_VERBOSE_MAKEFILE, ON)
  
# Required by flatbuffers also
ADD_COMPILE_OPTIONS(-std=c++11)

OPTION(ENABLE_MOCK "For development: Enable mock classes which prevent crashes on PC" OFF)
IF(ENABLE_MOCK)
    ADD_DEFINITIONS(-DENABLE_MOCK)
ENDIF(ENABLE_MOCK)

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/..)

# Used for loading generated headers, e.g. #include <Schema/axiom_daemon_generated.h>
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/src/)

FILE(GLOB SOURCE_FILES "*.cpp" "*.h"
                       "../Adapter/*.cpp" "../Adapter/*.h"
                       "../API/*.cpp" "../API/*.h")

list(REMOVE_ITEM SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/../API/Main.cpp")
message("${SOURCE_FILES}")

ADD_EXECUTABLE(${PROJECT_NAME} ${SOURCE_FILES})
ADD_DEPENDENCIES(${PROJECT_NAME} flatc_cpp_gen)

TARGET_LINK_LIBRARIES(${PROJECT_NAME} systemd pistache)