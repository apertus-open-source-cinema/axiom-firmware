#ifndef JOURNALLOGGER_H
#define JOURNALLOGGER_H

#include "ILogger.h"

#include <string>
#include <unistd.h>

#include <systemd/sd-journal.h>

class JournalLogger : public ILogger
{
public:
    static void Log(std::string message)
    {
        sd_journal_print(LOG_INFO, "%s", message.c_str(), (unsigned long)getpid());
    }
};

#endif //JOURNALLOGGER_H
