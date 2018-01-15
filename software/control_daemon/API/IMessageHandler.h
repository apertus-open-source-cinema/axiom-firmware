#ifndef IMESSAGEHANDLER_H
#define IMESSAGEHANDLER_H

#include <string>

// TODO: Add separate handlers for setting and getting data or a parameter for ProcessMessage
class IMessageHandler
{
public:
    // Process JSON message and return response
    virtual bool ProcessMessage(std::string message, std::string& response) = 0;
};

#endif //IMESSAGEHANDLER_H