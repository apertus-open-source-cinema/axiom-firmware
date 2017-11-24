#ifndef CLIENT_H
#define CLIENT_H

#include <iostream>

#include <sys/un.h>
#include <sys/socket.h>

#include <pistache/http.h>
#include <pistache/router.h>
#include <pistache/endpoint.h>

#include <json.hpp>

#include <Schema/axiom_daemon_generated.h>

using namespace Pistache;
using json = nlohmann::json;

struct JSONSetting
{
    std::string id;
    int value;
    RWMode Mode;
    std::string type;
};

void from_json(const json& j, JSONSetting& s) {
    s.id = j.at("id").get<std::string>();
    s.value = j.at("value").get<int>();
    s.type = j.at("type").get<std::string>();

    if(j.at("mode").get<std::string>() == "write")
    {
        s.Mode = RWMode::Write;
    }
    else if(j.at("mode").get<std::string>() == "read")
    {
        s.Mode = RWMode::Read;
    }
}

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

public:
    RESTServer(Pistache::Address address) :
        socketPath("/tmp/axiom_daemon"),
        _builder(new flatbuffers::FlatBufferBuilder()),
        _httpEndpoint(std::make_shared<Http::Endpoint>(address))
    {
        // Connect to daemon
        SetupSocket();

        // Pistache setup
        auto opts = Http::Endpoint::options().threads(2).flags(Tcp::Options::ReuseAddr);
        _httpEndpoint->init(opts);

        SetupRoutes();
    }

    ~RESTServer()
    {
        if(_builder != nullptr)
        {
            delete _builder;
        }
    }

    void Start()
    {
        _httpEndpoint->setHandler(router.handler());
        _httpEndpoint->serve();
    }

    void GetSettings(const Rest::Request& request, Http::ResponseWriter response)
    {
        std::string availableSettings = "Available Settings:\n";
        availableSettings += "gain";
        response.send(Http::Code::Ok, availableSettings);
    }

    void PutSettings(const Rest::Request& request, Http::ResponseWriter response)
    {
        std::string receivedContent  = request.body();
        std::string message = "Received (raw): " + receivedContent + '\n';
        JSONSetting setting = json::parse(receivedContent);
        // JSONSetting setting = receivedJSON;

        OutputReceivedData(setting, message);

        // TODO: Dumb test, replace by more sophisticated code
        if(setting.type == "ImageSensor")
        {
            AddSettingIS(setting.Mode, ImageSensorSettings::Gain, 2);
            TransferData();
            message += "|Setting applied|\n";
        }
        else
        {
            message = "Handler not implemented yet!";
        }

        // std::string availableSettings = "Available Settings:\n";
        // availableSettings += "gain"

        // TODO: Dumb test, replace by more sophisticated code
        // if(s.type == "ImageSensor")
        // {
        //     AddSettingIS(s.Mode, ImageSensorSettings::Gain, 2);
        //     TransferData();
        //     message += "|Setting applied|\n";
        // }
        response.send(Http::Code::Ok, message);
    }

    void OutputReceivedData(JSONSetting setting, std::string& message)
    {
        message += "Received (JSON): " + '\n';
        message += "JSON ID: " + setting.id + '\n';
        message += "JSON Value: " + std::to_string(setting.value) + '\n';
        if(setting.Mode == RWMode::Write)
        {
            message += "JSON Mode: write\n";
        }
        else if(setting.Mode == RWMode::Read)
        {
            message += "JSON Mode: read \n";
        }
        else
        {
            message += "JSON Mode: unknown\n";
        }
        
        message += "JSON Type: " + setting.type +'\n';
    }

    void GetGeneral(const Rest::Request& request, Http::ResponseWriter response)
    {
        response.send(Http::Code::Not_Acceptable, "Use specific sub-page");
    }

    void SetupRoutes()
    {
        Rest::Routes::Get(router, "/", Rest::Routes::bind(&RESTServer::GetGeneral, this));
        Rest::Routes::Get(router, "/settings/", Rest::Routes::bind(&RESTServer::GetSettings, this));
        Rest::Routes::Put(router, "/settings/", Rest::Routes::bind(&RESTServer::PutSettings, this));
    }

    void Execute()
    {
        // TODO: Implement packet to trigger applying/retrieving of settings sent to daemon
    }

    void TransferData(/*void* data, unsigned int length*/)
    {
        auto setList = _builder->CreateVector(_settings);
        PacketBuilder _packetBuilder(*_builder);
        _packetBuilder.add_settings(setList.o);
        _builder->Finish(_packetBuilder.Finish());

        send(clientSocket, _builder->GetBufferPointer(), _builder->GetSize(), 0);
        std::string message = "Data size: " + std::to_string(_builder->GetSize());
        std::cout << message.c_str() << std::endl;
        
        // Clear settings after sending
        _settings.clear();
    }

    void SetupSocket()
    {
        clientSocket = socket(PF_LOCAL, SOCK_DGRAM, 0);
        address.sun_family = AF_LOCAL;
        strcpy(address.sun_path, socketPath.c_str());
        connect(clientSocket, (struct sockaddr*) &address, sizeof (address));
    }

    void AddSettingSPI(RWMode mode, std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength)
    {
        auto destinationFB = _builder->CreateString(destination);
        auto payloadFB = _builder->CreateVector(payload, payloadLength);

        auto setting = CreateSPISetting(*_builder, mode, destinationFB, type, payloadFB);
        auto pay = CreatePayload(*_builder, Setting::SPISetting, setting.Union());
        _settings.push_back(pay);


        //_settings.push_back(setting);
    }

    // Write/read setting of image sensor
    // Fixed to 2 bytes for now, as CMV used 128 x 2 bytes registers and it should be sufficient for first tests
    void AddSettingIS(RWMode mode, ImageSensorSettings setting, uint16_t parameter)
    {
        auto settingFB = CreateImageSensorSetting(*_builder, mode, setting, parameter);
        auto payload = CreatePayload(*_builder, Setting::ImageSensorSetting, settingFB.Union());

        _settings.push_back(payload);
    }
};

#endif //CLIENT_H
