CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
PROJECT(GoAPI)

FILE(GLOB SOURCE_FILES "client.go" "RESTserver.go")

ExternalProject_Get_Property(flatbuffers_project SOURCE_DIR)
SET(GOPATH ${SOURCE_DIR})
SET(GOPATH ${GOPATH}:${CMAKE_BINARY_DIR})
#ExternalProject_Get_Property(mux_project SOURCE_DIR)
#SET(GOPATH ${GOPATH}:${SOURCE_DIR})
#ExternalProject_Get_Property(handlers_project SOURCE_DIR)
#SET(GOPATH ${GOPATH}:${SOURCE_DIR})

MESSAGE(STATUS "GOPATH: ${GOPATH}")

add_custom_target(${PROJECT_NAME} ALL DEPENDS ${PROJECT_NAME})
add_custom_command(TARGET ${PROJECT_NAME}
                   COMMAND env GOPATH=${GOPATH} go build 
                   -o "${CMAKE_BINARY_DIR}/go_client"
                   ${SOURCE_FILES})

ADD_DEPENDENCIES(${PROJECT_NAME} flatc_go_gen)