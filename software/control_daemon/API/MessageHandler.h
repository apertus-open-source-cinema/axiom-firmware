#ifndef MESSAGEHANDLER_H
#define MESSAGEHANDLER_H

#include "IMessageHandler.h"

class MessageHandler : public IMessageHandler
{
public:
    // Process JSON message and return response
    virtual std::string ProcessMessage(std::string message) override
    {
        if(message == "Test")
        {
            return "OK";
        }
    }
};

#endif //MESSAGEHANDLER_H