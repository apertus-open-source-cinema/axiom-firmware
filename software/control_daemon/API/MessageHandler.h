#ifndef MESSAGEHANDLER_H
#define MESSAGEHANDLER_H

#include "IMessageHandler.h"

#include <sys/un.h>
#include <sys/socket.h>

#include <Schema/axiom_daemon_generated.h>

namespace ns
{
    struct JSONSetting;
};

class MessageHandler : public IMessageHandler
{
    std::string socketPath;
    int clientSocket;
    struct sockaddr_un address;
    
    // Using separate lists for now as it seems that flatbuffers does not use inheritance for unions
    std::vector<flatbuffers::Offset<Payload>> _settings;

    std::vector<const ImageSensorSetting*> _settingsIS;

    flatbuffers::FlatBufferBuilder* _builder = nullptr;

public:
    MessageHandler();
    ~MessageHandler();

    // Process JSON message and return response
    virtual bool ProcessMessage(std::string message, std::string& response) override;

    void SetupSocket();

    void Execute();
    void TransferData(/*void* data, unsigned int length*/);

    void AddSettingSPI(RWMode mode, std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength);
    void AddSettingIS(RWMode mode, std::string setting, uint16_t parameter);

    void OutputReceivedData(ns::JSONSetting setting, std::string& message);
};

#endif //MESSAGEHANDLER_H