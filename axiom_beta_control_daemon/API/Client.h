#ifndef CLIENT_H
#define CLIENT_H

#include <iostream>

#include "../Schema/axiom_daemon_generated.h"

class Client
{
    std::vector<flatbuffers::Offset<Setting>> _settings;

    flatbuffers::FlatBufferBuilder* _builder = nullptr;

public:
    Client() :
        _builder(new flatbuffers::FlatBufferBuilder())
    {

    }

    ~Client()
    {
        if(_builder != nullptr)
        {
            delete _builder;
        }
    }

    void AddSetting(std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength)
    {
        auto destinationFB = _builder->CreateString(destination);
        auto payloadFB = _builder->CreateVector(payload, payloadLength);

        auto setting = CreateSetting(*_builder, destinationFB, type, payloadFB);
        _settings.push_back(setting);
    }

    void Execute()
    {
        auto settingList = _builder->CreateVector(_settings);
        //        for(SettingBuilder settingBuilder : _settings)
        //        {
        //            auto setting = settingBuilder.Finish();
        //            int i = 0;

        //        }

        SettingListBuilder listBuilder(*_builder);
        listBuilder.add_settings(settingList);
        _builder->Finish(listBuilder.Finish());

        TransferData(_builder->GetBufferPointer(), _builder->GetSize());
    }

    void TransferData(void* data, unsigned int length)
    {
        // TODO: Sending over socket to server(daemon)
        auto test = GetSettingList(data);

        for(int index = 0; index < test->settings()->size(); index++)
        {
            auto setting = test->settings()->Get(index);
            std::cout << "Setting:" << std::endl;
            std::cout << "destination: " << setting->destination()->data() << std::endl;
            std::cout << "Type: " << EnumNameConnectionType(setting->connectionType()) << std::endl;

            auto payload = setting->payload()->data();
            int payloadSize = setting->payload()->size();
            std::cout << "Payload: ";
            for(int dataIndex = 0; dataIndex < payloadSize; dataIndex++)
            {
                std::cout << payload[dataIndex];
            }
            std::cout << std::endl;
        }

        // Clear settings after sending
        _settings.clear();
    }
};

#endif //CLIENT_H
