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

TEST_CASE( "Process WS message (new specs)", "[MessageHandler]" ) 
{
    // Reference: http://tomeko.net/online_tools/cpp_text_escape.php?lang=en
    std::string inputData = "{ \
                            \"message:WebRemote:whoami\": \
                            { \
                            \"sender\": \"6F29\", \
                            \"modules\": \"general\", \
                            \"status\": \"online\" \
                            } \
                            }";

    std::string expectedData = "{ \
                                \"message:WebRemote:whoami\" : \
                                { \
                                \"DAEMON_UUID\": UUID, \
                                \"ACCESS\" : one.of(messages.access) \
                                } \
                                }";

    std::shared_ptr<IMessageHandler> messageHandler = std::make_shared<MessageHandler>();

    std::string responseMessage;
    bool status = messageHandler->ProcessMessage(inputData, responseMessage);

    REQUIRE( status == true );
    REQUIRE( responseMessage == expectedData );                    
}