#ifndef CLIENT_H
#define CLIENT_H

#include <iostream>

#include <sys/un.h>
#include <sys/socket.h>

#include "../Schema/axiom_daemon_generated.h"

class Client
{
    std::string socketPath;

    // Using separate lists for now as it seems that flatbuffers does not use inheritance for unions
    std::vector<flatbuffers::Offset<Payload>> _settings;

    std::vector<const ImageSensorSetting*> _settingsIS;

    flatbuffers::FlatBufferBuilder* _builder = nullptr;

    int clientSocket;
    struct sockaddr_un address;

public:
    Client() :
        socketPath("/tmp/axiom_daemon"),
        _builder(new flatbuffers::FlatBufferBuilder())
    {
        SetupSocket();
    }

    ~Client()
    {
        if(_builder != nullptr)
        {
            delete _builder;
        }
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

    void AddSettingSPI(Mode mode, std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength)
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
    void AddSettingIS(Mode mode, ImageSensorSettings setting, uint16_t parameter)
    {
        auto settingFB = CreateImageSensorSetting(*_builder, mode, setting, parameter);
        auto payload = CreatePayload(*_builder, Setting::ImageSensorSetting, settingFB.Union());

        _settings.push_back(payload);
    }
};

#endif //CLIENT_H
