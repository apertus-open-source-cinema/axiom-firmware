#ifndef WSSERVER_H
#define WSSERVER_H

#include <iostream>

#include <uWS.h>

#include "MessageHandler.h"

struct JSONSetting;

class WSServer
{
    std::shared_ptr<uWS::Hub> hub;
    int _port;

    std::shared_ptr<IMessageHandler> _messageHandler;

public:
    WSServer(int port);
    ~WSServer();

    void Start();

protected:
    void Setup();
};

#endif //WSSERVER_H
