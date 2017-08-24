#ifndef SERVER_H
#define SERVER_H

#include <sys/un.h>
#include <sys/socket.h>

// For systemd
#include <systemd/sd-daemon.h>
#include <systemd/sd-journal.h>

#include "../Adapter/I2CAdapter.h"
#include "../Adapter/MemoryAdapter.h"

#include <Schema/axiom_daemon_generated.h>

class Server
{
    std::string _socketPath;

    bool _running;

    // TODO: Allow multiple connections
    int _socketDesc;
    sockaddr_un _name;

    std::string _statusMessage;

    IAdapter* _memoryAdapter = nullptr;
    IAdapter* _i2cAdapter = nullptr;

public:
    Server() :
        _socketPath("/tmp/axiom_daemon"),
        _running(true)
    {
        // TODO: Add real reading of revision/version
        //std::string/int?? revision = ReadRevision();
        std::string revision = "29";

        // TODO: Idea: Replace plain initialization with map of adapters, evaluation required
        _memoryAdapter = new MemoryAdapter();
        _i2cAdapter = new I2CAdapter();

        // TODO: Adjust paths to real ones, this ones are just for testing
        // TODO: Add fallback to older revision version if for current one no file is available
        
	//_memoryAdapter->ReadDescriptions("../Descriptions/Memory_rev" + revision + ".json");
        //_i2cAdapter->ReadDescriptions("../Descriptions/I2C_rev" + revision + ".json");
    }

    ~Server()
    {
        if(_memoryAdapter != nullptr)
        {
            delete _memoryAdapter;
        }

        if(_i2cAdapter != nullptr)
        {
            delete _i2cAdapter;
        }
    }

    void Setup()
    {
        if (sd_listen_fds(0) != 1)
        {
            sd_journal_print(LOG_INFO, "systemd socket activation", (unsigned long)getpid());            
           _socketDesc = SD_LISTEN_FDS_START;
        }
        else
        {
            sd_journal_print(LOG_INFO, "legacy socket initialization", (unsigned long)getpid());
            SetupSocket();
        }
    }

    void Start()
    {
           Process();
    }

private:
    // TODO: Move processing to a thread, so it doesn't block main thread in the future
    void Process()
    {
        uint8_t* buf2 = new uint8_t[1024];

        while(_running)
        {
            memset(buf2, 0, 1024);
            int size = read(_socketDesc, buf2, 1024);

            auto packet = GetPacket(buf2);
            auto set = packet->settings();
            int size2 = set->size();

            for(int index = 0; index < size2; ++index)
            {
                auto t = set->Get(index);
                auto p = t->payload_type();

                switch(p)
                {
                case Setting::ImageSensorSetting:
                {
                    const ImageSensorSetting* is = t->payload_as_ImageSensorSetting();
                    is->mode(); // Just a dummy call to supress "unused" warning
                    /*Mode mode = is->mode();
                    uint16_t parameter = is->parameter();
                    ImageSensorSettings s2 = is->setting();*/
                    //_settingsIS.push_back(is);
                }
                    break;
                case Setting::SPISetting:
                {
                    const SPISetting* is = t->payload_as_SPISetting();
                    is->destination(); // Just a dummy call to supress "unused" warning
                }
                    break;
                default:
                    break;
                }
            }
        }
    }

    void SetupSocket()
    {
        std::string errorMessage = "";

        _socketDesc = socket(PF_LOCAL, SOCK_DGRAM, 0);
        if (_socketDesc < 0)
        {
            errorMessage = "Socket error: " + std::string(strerror(errno));
        }

        unlink(_socketPath.c_str()); // Unlink socket to ensure that new connection will not be refused

        _name.sun_family=AF_LOCAL;
        strcpy(_name.sun_path, _socketPath.c_str());

        if (bind(_socketDesc, (struct sockaddr*)&_name, SUN_LEN(&_name)) != 0)
        {
            _statusMessage = "Bind failed: " + std::string(strerror(errno));
            syslog (LOG_ERR, "%s", _statusMessage.c_str());
            exit(1);
        }
    }
};

#endif //SERVER_H
