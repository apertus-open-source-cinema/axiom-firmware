#include "RESTServer.h"

int main()
{
    Pistache::Port port(7070);
    Pistache::Address address(Pistache::Ipv4::any(), port);

    RESTServer server(address);
    server.Start();

    return 0;
}
