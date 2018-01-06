#ifndef RESTSERVER_H
#define RESTSERVER_H

#include <iostream>

#include <sys/un.h>
#include <sys/socket.h>

#include <pistache/http.h>
#include <pistache/router.h>
#include <pistache/endpoint.h>

#include <json.hpp>

#include <Schema/axiom_daemon_generated.h>

#include "MessageHandler.h"

using namespace Pistache;

struct JSONSetting;

class RESTServer
{
    //HTTP_PROTOTYPE(RESTServer)

    std::string socketPath;

    // Using separate lists for now as it seems that flatbuffers does not use inheritance for unions
    std::vector<flatbuffers::Offset<Payload>> _settings;

    std::vector<const ImageSensorSetting*> _settingsIS;

    flatbuffers::FlatBufferBuilder* _builder = nullptr;

    Pistache::Address _address;

    std::shared_ptr<Pistache::Http::Endpoint> _httpEndpoint;
    Pistache::Rest::Router router;

    int clientSocket;
    struct sockaddr_un address;
    //Http::Header::AccessControlAllowMethods allowedMethods;

    std::shared_ptr<IMessageHandler> _messageHandler;

public:
    RESTServer(Pistache::Address address);
    ~RESTServer();

    void Start();

protected:
    void SetupRoutes();

    void GetGeneral(const Rest::Request& request, Http::ResponseWriter response);
    void GetSettings(const Rest::Request& request, Http::ResponseWriter response);
    void PutSettings(const Rest::Request& request, Http::ResponseWriter response);
    
    void OutputReceivedData(JSONSetting setting, std::string& message);

    void Options(const Rest::Request& request, Http::ResponseWriter response);

    void SetupSocket();

    void Execute();
    void TransferData(/*void* data, unsigned int length*/);

    void AddSettingSPI(RWMode mode, std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength);
    void AddSettingIS(RWMode mode, std::string setting, uint16_t parameter);
};

#endif //RESTSERVER_H
