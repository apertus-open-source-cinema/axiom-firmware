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
    std::vector<flatbuffers::Offset<Setting>> _settings;
    std::vector<flatbuffers::Offset<ImageSensorSetting>> _settingsIS;

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

    void AddSetting(Mode mode, std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength)
    {
        auto destinationFB = _builder->CreateString(destination);
        auto payloadFB = _builder->CreateVector(payload, payloadLength);

        //auto setting = CreateSetting(*_builder, mode, destinationFB, type, payloadFB);
        //_settings.push_back(setting);
    }

    void Execute()
    {
        auto settingList = _builder->CreateVector(_settings);
        //        for(SettingBuilder settingBuilder : _settings)
        //        {
        //            auto setting = settingBuilder.Finish();
        //            int i = 0;

        //        }

        //SettingListBuilder listBuilder(*_builder);
        //listBuilder.add_settings(settingList);
        //_builder->Finish(listBuilder.Finish());

        //TransferData(_builder->GetBufferPointer(), _builder->GetSize());
    }

    void TransferData(void* data, unsigned int length)
    {
        // TODO: Sending over socket to server(daemon)
        auto test = GetSettingList(data);

        for(unsigned int index = 0; index < test->settings()->size(); index++)
        {
//            auto setting = test->settings()->Get(index);
//            std::cout << "Setting:" << std::endl;
//            std::cout << "destination: " << setting->destination()->data() << std::endl;
//            std::cout << "Type: " << EnumNameConnectionType(setting->connectionType()) << std::endl;

//            auto payload = setting->payload()->data();
//            int payloadSize = setting->payload()->size();
//            std::cout << "Payload: ";
//            for(int dataIndex = 0; dataIndex < payloadSize; dataIndex++)
//            {
//                std::cout << payload[dataIndex];
//            }
//            std::cout << std::endl;
        }

        // Clear settings after sending
        _settings.clear();
    }

    void SetupSocket()
    {
        clientSocket = socket(PF_LOCAL, SOCK_DGRAM, 0);
        address.sun_family = AF_LOCAL;
        strcpy(address.sun_path, socketPath.c_str());
        connect(clientSocket, (struct sockaddr*) &address, sizeof (address));

        send(clientSocket, "Test123", 7, 0);
    }

    // Write/read setting of image sensor
    // Fixed to 2 bytes for now, as CMV used 128 x 2 bytes registers and it should be sufficient for first tests
    void AddSettingIS(Mode mode, ImageSensorSettings setting, uint16_t parameter1, uint16_t parameter2 = 0)
    {
        //auto destinationFB = ConnectionType::ImageSensor;
        //auto payloadFB = payload;

        auto settingFB = CreateImageSensorSetting(*_builder, mode, setting, parameter1, parameter2);
        _settingsIS.push_back(settingFB);
    }
};

#endif //CLIENT_H
