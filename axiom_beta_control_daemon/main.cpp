#include <unistd.h>
#include <string>
#include <iostream>
#include <pthread.h>

//#include <systemd/sd-daemon.h>

#include "Daemon/Daemon.h"

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
    sd_journal_print(LOG_INFO, "Initialization", (unsigned long)getpid());
    
    // TODO: Add smart pointer, to have more modern code
    Daemon* daemon = new Daemon();
    daemon->Setup();
    daemon->Start();

    //closelog();

    if(daemon != nullptr)
    {
        delete daemon;
    }

    return 0;
}
