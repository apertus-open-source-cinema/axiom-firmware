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
    _builder->Finish(_settings[0]);
    
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
