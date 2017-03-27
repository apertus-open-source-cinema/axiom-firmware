CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
PROJECT(axiom_daemon)

SET(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
SET(CMAKE_VERBOSE_MAKEFILE, ON)

# Required by flatbuffers also
ADD_COMPILE_OPTIONS(-std=c++11)

# Make GCC more strict
SET(CMAKE_CXX_FLAGS "-pedantic -pedantic-errors -Wall -Wextra")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

## Compiler flags
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    SET(CMAKE_CXX_FLAGS "-O2")        ## Optimize
    SET(CMAKE_EXE_LINKER_FLAGS "-s")  ## Strip binary
endif()

# Google flatbuffers
SET(FLATBUFFERS_BUILD_TESTS OFF CACHE BOOL "")
SET(FLATBUFFERS_INSTALL OFF CACHE BOOL "")
SET(FLATBUFFERS_BUILD_FLATLIB OFF CACHE BOOL "")
SET(FLATBUFFERS_BUILD_FLATHASH OFF CACHE BOOL "")
ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/3rdParty/flatbuffers/)
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/3rdParty/flatbuffers/include/)

# JSON
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/3rdParty/json/)

#SET(FLATC ${PROJECT_BINARY_DIR}/3rdParty/flatbuffers/flatc)
SET(FLATC ${PROJECT_BINARY_DIR}/flatc)
MESSAGE(STATUS "flatc location: ${FLATC}")

FILE(GLOB SOURCE_FILES "*.cpp" "*.h"
    "Adapter/*.cpp" "Adapter/*.h"
    "Connection/*.cpp" "Connection/*.h"
    "Schema/*.cpp" "Schema/*.h" "Schema/*.fbs")
#    "API/*.cpp" "API/*.h"

ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/API/)

ADD_CUSTOM_TARGET(flatc_gen
                    COMMAND ${FLATC} --scoped-enums --no-prefix --cpp ${PROJECT_SOURCE_DIR}/Schema/axiom_daemon.fbs
                    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/Schema/
                    COMMENT "Running PRE_BUILD action" DEPENDS flatc)

ADD_EXECUTABLE(${PROJECT_NAME} ${SOURCE_FILES})

ADD_DEPENDENCIES(${PROJECT_NAME} flatc_gen)
