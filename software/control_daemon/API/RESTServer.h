#ifndef RESTSERVER_H
#define RESTSERVER_H

#include <iostream>

#include <pistache/http.h>
#include <pistache/router.h>
#include <pistache/endpoint.h>

#include "MessageHandler.h"

using namespace Pistache;

struct JSONSetting;

class RESTServer
{
    Pistache::Address _address;

    std::shared_ptr<Pistache::Http::Endpoint> _httpEndpoint;
    Pistache::Rest::Router router;

    std::shared_ptr<IMessageHandler> _messageHandler;

public:
    RESTServer(Pistache::Address address);
    ~RESTServer();

    void Start();

protected:
    void SetupRoutes();

    void GetGeneral(const Rest::Request& request, Http::ResponseWriter response);
    void GetSettings(const Rest::Request& request, Http::ResponseWriter response);
    void PostSettings(const Rest::Request& request, Http::ResponseWriter response);

    void Options(const Rest::Request& request, Http::ResponseWriter response);
};

#endif //RESTSERVER_H
