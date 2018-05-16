#include <catch/catch.hpp>

#include "../API_WS/MessageHandler.h"

TEST_CASE( "Process message", "[MessageHandler]" ) 
{
    std::string inputData = "{ \"id\" : \"gain\", \"value\" : 4, \"type\" : \"ImageSensor\", \"message\" : \"\" }";
    // Alphabetic order, like JSON lib outputs it, also no whitespaces
    std::string expectedData = "{\"id\":\"gain\",\"message\":\"OK\",\"type\":\"ImageSensor\",\"value\":4}";

    std::shared_ptr<IMessageHandler> messageHandler = std::make_shared<MessageHandler>();

    std::string responseMessage;
    bool status = messageHandler->ProcessMessage(inputData, responseMessage);

    REQUIRE( status == true );
    REQUIRE( responseMessage == expectedData );
}
