#include "RESTServer.h"

int main()
{
    Pistache::Port port(7070);
    Pistache::Address address(Pistache::Ipv4::any(), port);

    RESTServer server(address);
    server.Start();

    // Pistache::Address addr(Pistache::Ipv4::any(), Pistache::Port(9080));
    
    //     auto opts = Http::Endpoint::options().threads(1);
    //     //opts.flags(Tcp::Options::InstallSignalHandler);
    //     Http::Endpoint server(addr);
    //     server.init(opts);
    //     server.setHandler(std::make_shared<RESTServer>());
    //     server.serveThreaded();

    //     while(true)
    //     {
    //     }

    //     server.shutdown();

    // RESTServer* server = new RESTServer();
    // uint8_t* testBuf = new uint8_t[2] {7, 5};
    // server->AddSettingSPI(Mode::Write, "Test", ConnectionType::I2C, testBuf, 2);
    // server->AddSettingIS(Mode::Write, ImageSensorSettings::Gain, 2);
    // server->AddSettingIS(Mode::Write, ImageSensorSettings::ADCRange, 0x35e);

    // server->TransferData();

    // server->Execute();

    // delete server;
    return 0;
}
