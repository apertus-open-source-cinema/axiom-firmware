#include <sys/syslog.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <errno.h>
#include <string>
#include <iostream>
#include <pthread.h>

#include "Connection/Server.h"

#include <flatbuffers/idl.h>
#include <flatbuffers/util.h>
#include "Schema/axiom_daemon_generated.h"

int main(__attribute__((unused)) int argc, __attribute__((unused)) char *argv[])
{
    setlogmask (LOG_UPTO (LOG_NOTICE));
    openlog ("axiom_daemon", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL1);

    // TODO: Add smart pointer, to have more modern code
    Server* server = new Server();
    server->Setup();
    server->Start();

    closelog();

    if(server != nullptr)
    {
        delete server;
    }

    return 0;
}
