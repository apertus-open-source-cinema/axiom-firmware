#ifndef IMESSAGEHANDLER_H
#define IMESSAGEHANDLER_H

// TODO: Add separate handlers for setting and getting data or a parameter for ProcessMessage
class IMessageHandler
{
public:
    // Process JSON message and return response
    virtual std::string ProcessMessage(std::string message) = 0;
};

#endif //IMESSAGEHANDLER_H