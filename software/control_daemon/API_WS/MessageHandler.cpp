#include "MessageHandler.h"

#include <json/json.hpp>
using json = nlohmann::json;

namespace ns
{
    struct JSONSetting
    {
        std::string sender;
        std::string module;
        std::string command;
        std::string value;
        std::string timestamp;
        std::string status;
    };

    void to_json(json& j, const JSONSetting& setting) 
    {
        j = json{{"sender", setting.sender}, {"module", setting.module}, {"command", setting.command}, {"value", setting.value}, {"timestamp", setting.timestamp}, {"status", setting.status}};
    }

    void from_json(const json& j, JSONSetting& s) 
    {
        s.sender = j.at("sender").get<std::string>();
        s.module = j.at("module").get<std::string>();
        s.command = j.at("command").get<std::string>();
        s.value = j.at("value").get<std::string>();
        s.timestamp = j.at("timestamp").get<std::string>();
        s.status = j.at("status").get<std::string>();
    }
};

MessageHandler::MessageHandler() : 
socketPath("/tmp/axiom_daemon"),
_builder(new flatbuffers::FlatBufferBuilder())
{
    SetupSocket();
}

MessageHandler::~MessageHandler()
{
    if(_builder != nullptr)
    {
        delete _builder;
    }
}

bool MessageHandler::ProcessMessage(std::string message, std::string& response)
{
    ns::JSONSetting setting;
    try 
    {
        setting = json::parse(message);
    }
    catch(std::exception& ex)
    {
        response = "Invalid format";
        return false;
    }
    
    // JSONSetting setting = receivedJSON;
    
    std::string receivedData = "";
    //OutputReceivedData(setting, receivedData);
    std::cout << "Received data: " << std::endl << receivedData << std::endl;

    //AddDaemonRequest();
    TransferData();
    
    return true;
}

void MessageHandler::Execute()
{
    // TODO: Implement packet to trigger applying/retrieving of settings sent to daemon
}

void MessageHandler::TransferData(/*void* data, unsigned int length*/)
{
    std::cout << "TransferData() started" << std::endl;
    auto setList = _builder->CreateVector(_settings);
    PacketBuilder _packetBuilder(*_builder);
    _packetBuilder.add_settings(setList.o);
    _builder->Finish(_packetBuilder.Finish());
    
    send(clientSocket, _builder->GetBufferPointer(), _builder->GetSize(), 0);
    std::string message = "Data size: " + std::to_string(_builder->GetSize());
    std::cout << message.c_str() << std::endl;
    
    // Clear settings after sending
    _settings.clear();
    _builder->Clear();

    std::cout << "TransferData() completed" << std::endl;
}

void MessageHandler::SetupSocket()
{
    clientSocket = socket(PF_LOCAL, SOCK_DGRAM, 0);
    address.sun_family = AF_LOCAL;
    strcpy(address.sun_path, socketPath.c_str());
    connect(clientSocket, (struct sockaddr*) &address, sizeof (address));
}

void MessageHandler::AddSettingSPI(RWMode mode, std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength)
{
    // auto destinationFB = _builder->CreateString(destination);
    // auto payloadFB = _builder->CreateVector(payload, payloadLength);
    
    // auto setting = CreateSPISetting(*_builder, mode, destinationFB, type, payloadFB);
    // auto pay = CreatePayload(*_builder, Setting::SPISetting, setting.Union());
    // _settings.push_back(pay);
    
    //_settings.push_back(setting);
}

// Write/read setting of image sensor
// Fixed to 2 bytes for now, as CMV used 128 x 2 bytes registers and it should be sufficient for first tests
void MessageHandler::AddSettingIS(RWMode mode, std::string setting, uint16_t parameter)
{
    // auto settingFB = CreateImageSensorSetting(*_builder, mode, _builder->CreateString(setting), parameter);
    // auto payload = CreatePayload(*_builder, Setting::ImageSensorSetting, settingFB.Union());
    
    // _settings.push_back(payload);
}

// table DaemonRequest
// {
//     sender: string; // e.g. "WSServer" for now
//     module: string; // e.g. "image_sensor"
//     command: string; // e.g. "set_gain"
//     value: string; // e.g. "2.4"
//     status: string; // used for reply from Daemon
// }
void MessageHandler::AddDaemonRequest(std::string sender, std::string module, std::string command, std::string value)
{
    std::cout << "AddDaemonRequest()message" << std::endl;

    auto senderFB = _builder->CreateString(sender);
    auto moduleFB = _builder->CreateString(module);
    auto commandFB = _builder->CreateString(command);
    auto valueFB = _builder->CreateString(command);
    auto statusFB = _builder->CreateString("");

    auto request = CreateDaemonRequest(*_builder, senderFB, moduleFB, commandFB, valueFB, statusFB);
    _settings.push_back(request);
}

// void MessageHandler::OutputReceivedData(ns::JSONSetting setting, std::string& message)
// {
//     message += "Received (JSON): \n" + setting;
//     message += "JSON ID: " + setting.id + "\n";
//     message += "JSON Value: " + std::to_string(setting.value) + "\n";
//     message += "JSON Type: " + setting.type + "\n";
//     message += "JSON Message: " + setting.message + "\n";
// }
