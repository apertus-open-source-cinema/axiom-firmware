#include "WSServer.h"

int main()
{
    int port = 7070;
    WSServer server(port);
    server.Start();

    return 0;
}
