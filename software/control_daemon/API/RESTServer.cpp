#include "RESTServer.h"

RESTServer::RESTServer(Pistache::Address address) :
_httpEndpoint(std::make_shared<Http::Endpoint>(address)),
_messageHandler(std::make_shared<MessageHandler>())
{
    // Connect to daemon
    //SetupSocket();
    
    // Pistache setup
    auto opts = Http::Endpoint::options().threads(2).flags(Tcp::Options::ReuseAddr);
    _httpEndpoint->init(opts);
    
    //  allowedMethods.addMethods({Http::Method::Head, Http::Method::Get, Http::Method::Put, Http::Method::Post, Http::Method::Options});
    
    SetupRoutes();
}

RESTServer::~RESTServer()
{
}

void RESTServer::Start()
{
    _httpEndpoint->setHandler(router.handler());
    _httpEndpoint->serve();
}

void RESTServer::GetSettings(const Rest::Request& request, Http::ResponseWriter response)
{
    // TODO: Iterate through registered handlers and retrieve available settings
    // TODO: Evaluate how settings could be prepared for automatic data binding in HTML/JS

    std::string availableSettings = "{ \"id\": \"gain\"}";
    //response.headers().add<Http::Header::AccessControlAllowMethods>(allowedMethods);
    //response.headers().add<Http::Header::AccessControlAllowOrigin>("*");
    response.send(Http::Code::Ok, availableSettings);
}

void RESTServer::PostSettings(const Rest::Request& request, Http::ResponseWriter response)
{
    // TODO: Add return boolean value, responseMessage should be returned by reference
    std::string responseMessage;
    bool status = _messageHandler->ProcessMessage(request.body(), responseMessage);

    if(status)
    {
        response.send(Http::Code::Ok, responseMessage);
    }
    else
    {
        response.send(Http::Code::Bad_Request, responseMessage);
    }
}
    
void RESTServer::GetGeneral(const Rest::Request& request, Http::ResponseWriter response)
{
    response.send(Http::Code::Not_Acceptable, "Use specific sub-page");
}
    
void RESTServer::SetupRoutes()
{
    Rest::Routes::Get(router, "/", Rest::Routes::bind(&RESTServer::GetGeneral, this));
    Rest::Routes::Get(router, "/settings/", Rest::Routes::bind(&RESTServer::GetSettings, this));
    Rest::Routes::Post(router, "/settings/", Rest::Routes::bind(&RESTServer::PostSettings, this));
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
    
