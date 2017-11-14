#include <memory>

#include "Daemon/Daemon.h"

int main(__attribute__((unused)) int argc, __attribute__((unused)) char *argv[])
{
    sd_journal_print(LOG_INFO, "Initialization", (unsigned long)getpid());
    
    const std::unique_ptr<Daemon> daemon(new Daemon());
    daemon->Setup();
    daemon->Start();

    return 0;
}
