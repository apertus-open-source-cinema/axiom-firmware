#include <catch.hpp>

#include "../API/MessageHandler.h"

TEST_CASE( "Process message", "[MessageHandler]" ) 
{
    std::shared_ptr<IMessageHandler> messageHandler = std::make_shared<MessageHandler>();
    REQUIRE( messageHandler->ProcessMessage("Test") == "OK" );
}
