#include "MessageHandler.h"

//#include <sys/socket.h>
#include <errno.h>
#include <unistd.h>

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
        std::string status;
        std::string message;
        std::string timestamp;
    };

    void to_json(json& j, const JSONSetting& setting)
    {
        j = json{{"sender", setting.sender},
                 {"module", setting.module},
                 {"command", setting.command},
                 {"value", setting.value},
                 {"status", setting.status},
                 {"message", setting.message},
                 {"timestamp", setting.timestamp}};
    }

    void from_json(const json& j, JSONSetting& s)
    {
        s.sender = j.at("sender").get<std::string>();
        s.module = j.at("module").get<std::string>();
        s.command = j.at("command").get<std::string>();
        s.value = j.at("value").get<std::string>();
        s.status = j.at("status").get<std::string>();
        s.message = j.at("message").get<std::string>();
        s.timestamp = j.at("timestamp").get<std::string>();
    }
};

MessageHandler::MessageHandler() : 
    socketPath("/tmp/axiom_daemon.uds"),
    _builder(new flatbuffers::FlatBufferBuilder())
{
    SetupSocket();
}

MessageHandler::~MessageHandler()
{
    delete _builder;
}

bool MessageHandler::ProcessMessage(std::string message, std::string& response)
{
    ns::JSONSetting setting;
    try
    {
        setting = json::parse(message);
    }
    catch(std::exception&)
    {
        response = "Invalid format";
        return false;
    }

    AddDaemonRequest(setting.sender, setting.module, setting.command, setting.value);
    std::unique_ptr<DaemonRequestT> req;
    TransferData(req);

    setting.value = req.get()->value;
    setting.message = req.get()->message;
    setting.status = req.get()->status;
    //setting.timestamp = req.get()->timestamp;

    json j = setting;
    response = j.dump();

    return true;
}

void MessageHandler::Execute()
{
    // TODO: Implement packet to trigger applying/retrieving of settings sent to daemon
}

socklen_t len = sizeof(struct sockaddr_un);

void MessageHandler::TransferData(std::unique_ptr<DaemonRequestT>& req)
{
    std::cout << "TransferData() started" << std::endl;
    //auto setList = _builder->CreateVector(_settings);
    _builder->Finish(_settings[0]);
    
    //send(clientSocket, _builder->GetBufferPointer(), _builder->GetSize(), 0);

    sendto(clientSocket, _builder->GetBufferPointer(), _builder->GetSize(), 0, reinterpret_cast<struct sockaddr*>(&address), len);
    ssize_t i = recvfrom(clientSocket, &response, 1023, 0, reinterpret_cast<struct sockaddr*>(&address), &len);
    if(i < 0)
    {
        std::cout << "RECEIVE ERROR: " << strerror(errno) << std::endl;
        close(clientSocket);
        exit(1);
        //std::cout << "Response received" << std::enerrnodl;
    }


    req = UnPackDaemonRequest(response);//DaemonRequest::UnPack(req, receivedBuffer);
    std::cout << "RESPONSE MESSAGE: " << req.get()->status << std::endl;

    std::string message = "Data size: " + std::to_string(_builder->GetSize());
    std::cout << message.c_str() << std::endl;
    
    // Clear settings after sending
    _settings.clear();
    _builder->Clear();

    std::cout << "TransferData() completed" << std::endl;

    std::cout << "Response (message): " << req.get()->message << std::endl;
    std::cout << "Response (status): " << req.get()->status << std::endl;
}

void MessageHandler::SetupSocket()
{
    clientSocket = socket(AF_LOCAL, SOCK_SEQPACKET, 0);
    address.sun_family = AF_LOCAL;
    strcpy(address.sun_path, socketPath.c_str());

    int result = connect(clientSocket, reinterpret_cast<struct sockaddr*>(&address), sizeof(address));
    if(result < 0)
    {
        std::cout << "CONNECT ERROR: " << strerror(errno) << " [Is daemon running?]" << std::endl;
        close(clientSocket);
        exit(1);
    }
}

void MessageHandler::AddDaemonRequest(std::string sender, std::string module, std::string command, std::string value)
{
    DaemonRequestT request;
    request.sender = sender;
    request.module_ = module;
    request.command = command;
    request.value = value;

    auto req = CreateDaemonRequest(*_builder, &request);
    _settings.push_back(req);
}
