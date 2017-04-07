#include <unistd.h>
#include <string>
#include <iostream>
#include <pthread.h>

//#include <systemd/sd-daemon.h>

#include "Connection/Server.h"

#include <flatbuffers/idl.h>
#include <flatbuffers/util.h>
#include "Schema/axiom_daemon_generated.h"

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

// Requirement: package libi2c-dev, otherwise shorter one from kernel is used
#include <linux/i2c-dev.h>

#include "API/Client.h"

#include "Adapter/CMVAdapter.h"

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
