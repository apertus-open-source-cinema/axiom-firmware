#include "RESTServer.h"

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

RESTServer::RESTServer(Pistache::Address address) :
socketPath("/tmp/axiom_daemon"),
_builder(new flatbuffers::FlatBufferBuilder()),
_httpEndpoint(std::make_shared<Http::Endpoint>(address)),
_messageHandler(std::make_shared<MessageHandler>())
{
    // Connect to daemon
    SetupSocket();
    
    // Pistache setup
    auto opts = Http::Endpoint::options().threads(2).flags(Tcp::Options::ReuseAddr);
    _httpEndpoint->init(opts);
    
    //  allowedMethods.addMethods({Http::Method::Head, Http::Method::Get, Http::Method::Put, Http::Method::Post, Http::Method::Options});
    
    SetupRoutes();
}

RESTServer::~RESTServer()
{
    if(_builder != nullptr)
    {
        delete _builder;
    }
}

void RESTServer::Start()
{
    _httpEndpoint->setHandler(router.handler());
    _httpEndpoint->serve();
}

void RESTServer::GetSettings(const Rest::Request& request, Http::ResponseWriter response)
{
    std::string availableSettings = "{ \"id\": \"gain\"}";
    //response.headers().add<Http::Header::AccessControlAllowMethods>(allowedMethods);
    //response.headers().add<Http::Header::AccessControlAllowOrigin>("*");
    response.send(Http::Code::Ok, availableSettings);
}

void RESTServer::PutSettings(const Rest::Request& request, Http::ResponseWriter response)
{
    std::string receivedContent  = request.body();
    //std::string message = "Received (raw): " + receivedContent + '\n';
    JSONSetting setting = json::parse(receivedContent);
    // JSONSetting setting = receivedJSON;
    
    //OutputReceivedData(setting, message);
    
    // TODO: Dumb test, replace by more sophisticated code
    if(setting.type == "ImageSensor")
    {
        AddSettingIS(setting.Mode, setting.id, 2);
        TransferData();
        //message += "|Setting applied|\n";
    }
    else
    {
        //message = "Handler not implemented yet!";
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
        //response.headers().add<Http::Header::AccessControlAllowOrigin>("*");
        //response.headers().add<Http::Header::AccessControlAllowMethods>(allowedMethods);
        //response.headers().add<Http::Header::ContentType>(MIME(Application, Json));
        response.send(Http::Code::Ok, "{\"message\": \"OK\"}");
    }
    
void RESTServer::OutputReceivedData(JSONSetting setting, std::string& message)
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
    
void RESTServer::GetGeneral(const Rest::Request& request, Http::ResponseWriter response)
{
    response.send(Http::Code::Not_Acceptable, "Use specific sub-page");
}
    
void RESTServer::SetupRoutes()
{
    Rest::Routes::Get(router, "/", Rest::Routes::bind(&RESTServer::GetGeneral, this));
    Rest::Routes::Get(router, "/settings/", Rest::Routes::bind(&RESTServer::GetSettings, this));
    Rest::Routes::Post(router, "/settings/", Rest::Routes::bind(&RESTServer::PutSettings, this));
    Rest::Routes::Options(router, "/settings/", Rest::Routes::bind(&RESTServer::Options, this));
}
    
void RESTServer::Options(const Rest::Request& request, Http::ResponseWriter response)
{
    //response.headers().add(U("Allow"), U("GET, POST, OPTIONS"));
    //response.headers().add(U("Access-Control-Allow-Origin"), U("*"));
    //response.headers().add(U("Access-Control-Allow-Methods"), U("GET, POST, OPTIONS"));
    //response.headers().add(U("Access-Control-Allow-Headers"), U("Content-Type"));

    //Http::Method::Get, Http::Method::Put, Http::Method::Options

    //response.headers().add<Http::Header::AccessControlAllowOrigin>("*");
    //response.headers().add<Http::Header::AccessControlAllowMethods>(allowedMethods);
    //response.headers().add<Http::Header::ContentType>(MIME(Application, Json));
    //response.headers().addRaw(Http::Header::Raw("ABC", "Test123"));
    response.send(Http::Code::Ok, "{\"message\": \"OK\"}");
}
    
void RESTServer::Execute()
{
    // TODO: Implement packet to trigger applying/retrieving of settings sent to daemon
}
    
void RESTServer::TransferData(/*void* data, unsigned int length*/)
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
    
void RESTServer::SetupSocket()
{
    clientSocket = socket(PF_LOCAL, SOCK_DGRAM, 0);
    address.sun_family = AF_LOCAL;
    strcpy(address.sun_path, socketPath.c_str());
    connect(clientSocket, (struct sockaddr*) &address, sizeof (address));
}

void RESTServer::AddSettingSPI(RWMode mode, std::string destination, ConnectionType type, uint8_t* payload, unsigned int payloadLength)
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
void RESTServer::AddSettingIS(RWMode mode, std::string setting, uint16_t parameter)
{
    auto settingFB = CreateImageSensorSetting(*_builder, mode, _builder->CreateString(setting), parameter);
    auto payload = CreatePayload(*_builder, Setting::ImageSensorSetting, settingFB.Union());

    _settings.push_back(payload);
}
