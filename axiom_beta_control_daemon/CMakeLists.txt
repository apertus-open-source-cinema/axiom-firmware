CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
PROJECT(axiom_daemon)

include(ExternalProject)

SET(CMAKE_GENERATOR "Unix Makefiles" CACHE INTERNAL "" FORCE)
SET(CMAKE_VERBOSE_MAKEFILE, ON)

# Required by flatbuffers also
ADD_COMPILE_OPTIONS(-std=c++11)

# Make GCC more strict
SET(CMAKE_CXX_FLAGS "-pedantic -pedantic-errors -Wall -Wextra")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Compiler flags
if (CMAKE_BUILD_TYPE STREQUAL "Release")
    SET(CMAKE_CXX_FLAGS "-O2") #Optimize
    SET(CMAKE_EXE_LINKER_FLAGS "-s") # Strip binary
endif()

ExternalProject_Add(flatbuffers_project
                    PREFIX 3rdParty/flatbuffers
                    GIT_REPOSITORY "https://github.com/BAndiT1983/flatbuffers.git"
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
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/3rdParty/json/)

SET(FLATC ${BINARY_DIR}/flatc)
MESSAGE(STATUS "flatc location: ${FLATC}")

FILE(GLOB SOURCE_FILES "*.cpp" "*.h"
     "Adapter/*.cpp" "Adapter/*.h"
     "Connection/*.cpp" "Connection/*.h"
     "Schema/*.fbs"
     "Helpers/*.h")

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/Schema/)

# C/C++schema
ADD_CUSTOM_TARGET(flatc_cpp_gen
                  COMMAND ${FLATC} --scoped-enums --no-prefix --cpp ${PROJECT_SOURCE_DIR}/Schema/axiom_daemon.fbs
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src/Schema/
                  COMMENT "Running flatc_cpp_gen action" DEPENDS flatbuffers_project)

# Go schema
ADD_CUSTOM_TARGET(flatc_go_gen
                  COMMAND ${FLATC} --scoped-enums --go-namespace AxiomDaemon --go ${PROJECT_SOURCE_DIR}/Schema/axiom_daemon.fbs
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/src/Schema/
                  COMMENT "Running flatc_go_gen action" DEPENDS flatbuffers_project)

# Prepare flatbuffers Go package (source)
ADD_CUSTOM_COMMAND(TARGET flatbuffers_project PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy_directory
                          ${SOURCE_DIR}/go
                          ${SOURCE_DIR}/src/github.com/google/flatbuffers/go )

# Prepare mux Go package (source)
ExternalProject_Add(mux_project
                    PREFIX 3rdParty/mux
                    GIT_REPOSITORY "https://github.com/gorilla/mux.git"
                    GIT_TAG "master"
                    CONFIGURE_COMMAND ""
                    UPDATE_COMMAND ""
                    INSTALL_COMMAND ""
                    BUILD_COMMAND "")

ExternalProject_Get_Property(mux_project SOURCE_DIR)

file(MAKE_DIRECTORY ${SOURCE_DIR}/src/github.com/gorilla/mux )
ADD_CUSTOM_COMMAND(TARGET mux_project PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy
                          ${SOURCE_DIR}/*.go
                          ${SOURCE_DIR}/src/github.com/gorilla/mux )

# Prepare handlers Go package (source)
ExternalProject_Add(handlers_project
                    PREFIX 3rdParty/handlers
                    GIT_REPOSITORY "https://github.com/gorilla/handlers.git"
                    GIT_TAG "master"
                    CONFIGURE_COMMAND ""
                    UPDATE_COMMAND ""
                    INSTALL_COMMAND ""
                    BUILD_COMMAND "")

ExternalProject_Get_Property(handlers_project SOURCE_DIR)

file(MAKE_DIRECTORY ${SOURCE_DIR}/src/github.com/gorilla/handlers )
ADD_CUSTOM_COMMAND(TARGET handlers_project PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy
                          ${SOURCE_DIR}/*.go
                          ${SOURCE_DIR}/src/github.com/gorilla/handlers )

# Client example should be build separately for now
ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/API/)
ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/GoAPI/)

# Used for loading generated headers, e.g. #include <Schema/axiom_daemon_generated.h>
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR}/src/)

ADD_EXECUTABLE(${PROJECT_NAME} ${SOURCE_FILES})
ADD_DEPENDENCIES(${PROJECT_NAME} flatc_cpp_gen flatc_go_gen )

TARGET_LINK_LIBRARIES(${PROJECT_NAME} systemd)
