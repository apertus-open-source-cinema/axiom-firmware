#include "MessageHandler.h"

#include <json/json.hpp>
using json = nlohmann::json;

namespace ns
{
    struct JSONSetting
    {
        std::string id;
        int value;
        std::string type;
        std::string message;
    };

    void to_json(json& j, const JSONSetting& setting) 
    {
        j = json{{"id", setting.id}, {"value", setting.value}, {"type", setting.type}, {"message", setting.message}};
    }

    void from_json(const json& j, JSONSetting& s) 
    {
        s.id = j.at("id").get<std::string>();
        s.value = j.at("value").get<int>();
        s.type = j.at("type").get<std::string>();
        s.message = j.at("message").get<std::string>();
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
    if(message == "Test")
    {
        return "OK";
    }
    
    std::string receivedContent  = message;
    //std::string message = "Received (raw): " + receivedContent + '\n';
    ns::JSONSetting setting = json::parse(receivedContent);
    // JSONSetting setting = receivedJSON;
    
    std::string receivedData = "";
    OutputReceivedData(setting, receivedData);
    std::cout << "Received data: " << std::endl << receivedData << std::endl;
    
    // TODO: Dumb test, replace by more sophisticated code
    if(setting.type == "ImageSensor")
    {
        AddSettingIS(RWMode::Write, setting.id, 2);
        TransferData();
        
        setting.message = "OK";
        json j = setting;
        std::cout << "Convert JSON: " << j << std::endl;
        response = j.dump();        
        //message += "|Setting applied|\n";
    }
    else
    {
        response = "Handler not implemented yet!";
        return false;
    }
    
    return true;
}

void MessageHandler::Execute()
{
    // TODO: Implement packet to trigger applying/retrieving of settings sent to daemon
}

void MessageHandler::TransferData(/*void* data, unsigned int length*/)
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
    _builder->Clear();
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
    auto destinationFB = _builder->CreateString(destination);
    auto payloadFB = _builder->CreateVector(payload, payloadLength);
    
    auto setting = CreateSPISetting(*_builder, mode, destinationFB, type, payloadFB);
    auto pay = CreatePayload(*_builder, Setting::SPISetting, setting.Union());
    _settings.push_back(pay);
    
    //_settings.push_back(setting);
}

// Write/read setting of image sensor
// Fixed to 2 bytes for now, as CMV used 128 x 2 bytes registers and it should be sufficient for first tests
void MessageHandler::AddSettingIS(RWMode mode, std::string setting, uint16_t parameter)
{
    auto settingFB = CreateImageSensorSetting(*_builder, mode, _builder->CreateString(setting), parameter);
    auto payload = CreatePayload(*_builder, Setting::ImageSensorSetting, settingFB.Union());
    
    _settings.push_back(payload);
}

void MessageHandler::OutputReceivedData(ns::JSONSetting setting, std::string& message)
{
    message += "Received (JSON): " + '\n';
    message += "JSON ID: " + setting.id + '\n';
    message += "JSON Value: " + std::to_string(setting.value) + '\n';
    message += "JSON Type: " + setting.type +'\n';
    message += "JSON Message: " + setting.message +'\n';
}