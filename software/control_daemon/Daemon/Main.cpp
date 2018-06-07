#include <memory>

#include "Daemon.h"

int main(__attribute__((unused)) int argc, __attribute__((unused)) char *argv[])
{    
    const std::unique_ptr<Daemon> daemon(new Daemon());
    daemon->Setup();
    daemon->Start();

    return 0;
}
