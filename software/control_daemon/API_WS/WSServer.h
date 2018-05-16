#ifndef WSSERVER_H
#define WSSERVER_H

#include <iostream>

#include <uWS.h>

#include "MessageHandler.h"

struct JSONSetting;

class WSServer
{
public:
    WSServer();
    ~WSServer();

    void Start();

protected:

};

#endif //WSSERVER_H
