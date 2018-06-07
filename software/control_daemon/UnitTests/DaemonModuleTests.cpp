#include <catch/catch.hpp>

#include "../Adapter/CMV12000Adapter.h"

TEST_CASE( "Test available methods retrieval", "[DaemonModule]" ) 
{
    CMV12000Adapter adapter;

    std::vector<std::string> availableMethods = adapter.GetAvailableMethods();

    REQUIRE(availableMethods.size() == 3);
    //REQUIRE( responseMessage == expectedData );
}
