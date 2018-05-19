#include "WSServer.h"

using namespace uWS;

WSServer::WSServer(int port):
_messageHandler(std::make_shared<MessageHandler>())
{
    _port = port;

    Setup();
}

WSServer::~WSServer()
{    
}

void WSServer::Setup()
{
    hub = std::make_shared<Hub>();

    auto messageHandler = [&](uWS::WebSocket<uWS::SERVER> *ws, char *message, size_t length, uWS::OpCode opCode) 
    {
        ws->send("ACK", 3, opCode);
        std::string convertedMessage = std::string(message, message + length);
        std::string responseMessage;
        bool status = _messageHandler->ProcessMessage(convertedMessage, responseMessage);
        ws->send(responseMessage.c_str(), responseMessage.length(), opCode);
    };

    hub->onMessage(messageHandler);
}

void WSServer::Start()
{
    if (hub->listen(_port)) 
    {
        hub->run();
    }
}
