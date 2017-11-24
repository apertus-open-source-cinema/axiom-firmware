#include "ILogger.h"

#include <systemd/sd-journal.h>

class JournalLogger : public ILogger
{
public:
    static void Log(std::string message)
    {
        sd_journal_print(LOG_INFO, message.c_str(), (unsigned long)getpid());
    }
};