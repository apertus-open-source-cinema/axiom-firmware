#ifndef SERVER_H
#define SERVER_H

#include <sys/un.h>
#include <sys/socket.h>
#include <string>

// For systemd
#include <systemd/sd-daemon.h>
#include <systemd/sd-journal.h>

#include "../Adapter/I2CAdapter.h"
#include "../Adapter/MemoryAdapter.h"
#include "../Adapter/CMV12000Adapter.h"

#include <Schema/axiom_daemon_generated.h>

class Daemon
{
    std::string _socketPath;

    bool _running;

    // TODO: Allow multiple connections
    int _socketDesc;
    sockaddr_un _name;

    std::string _statusMessage;

    IAdapter* _memoryAdapter = nullptr;
    IAdapter* _i2cAdapter = nullptr;
    CMV12000Adapter* _cmvAdapter = nullptr;

public:
    Daemon() :
        _socketPath("/tmp/axiom_daemon"),
        _running(true)
    {
        // TODO: Add real reading of revision/version
        //std::string/int?? revision = ReadRevision();
        std::string revision = "29";

        // TODO: Idea: Replace plain initialization with map of adapters, evaluation required
        _memoryAdapter = new MemoryAdapter();
        _i2cAdapter = new I2CAdapter();
        _cmvAdapter = new CMV12000Adapter();

        // TODO: Adjust paths to real ones, this ones are just for testing
        // TODO: Add fallback to older revision version if for current one no file is available
        
	//_memoryAdapter->ReadDescriptions("../Descriptions/Memory_rev" + revision + ".json");
        //_i2cAdapter->ReadDescriptions("../Descriptions/I2C_rev" + revision + ".json");
    }

    ~Daemon()
    {
        if(_memoryAdapter != nullptr)
        {
            delete _memoryAdapter;
        }

        if(_i2cAdapter != nullptr)
        {
            delete _i2cAdapter;
        }

        if(_cmvAdapter != nullptr)
        {
            delete _cmvAdapter;
        }
    }

    void Setup()
    {
        int fdCount = sd_listen_fds(0);
        if (fdCount  == 1)
        {
            sd_journal_print(LOG_INFO, "systemd socket activation", (unsigned long)getpid());            
           _socketDesc = SD_LISTEN_FDS_START;
        }
        else if(fdCount > 1)
        {
            sd_journal_print(LOG_INFO, "Too many file descriptors", (unsigned long)getpid());    
            exit(1);
        }
            else
            {
                std::string message = "Number of file descriptors: " + std::to_string(fdCount);
                sd_journal_print(LOG_INFO, message.c_str(), (unsigned long)getpid());    
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

            std::string message = "Received data size: " + std::to_string(size);
            sd_journal_print(LOG_INFO, message.c_str(), (unsigned long)getpid());            

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
                    sd_journal_print(LOG_INFO, "Received: Image Sensor setting", (unsigned long)getpid());
                    const ImageSensorSetting* is = t->payload_as_ImageSensorSetting();
                    _cmvAdapter->SetCMVRegister((u_int8_t)is->setting(), is->parameter());
                    //is->mode(); // Just a dummy call to supress "unused" warning
                    /*Mode mode = is->mode();
                    uint16_t parameter = is->parameter();
                    ImageSensorSettings s2 = is->setting();*/
                    //_settingsIS.push_back(is);
                }
                    break;
                case Setting::SPISetting:
                {
                    sd_journal_print(LOG_INFO, "Received: SPI setting", (unsigned long)getpid());
                    const SPISetting* is = t->payload_as_SPISetting();
                    is->destination(); // Just a dummy call to supress "unused" warning
                }
                    break;
                default:
                    sd_journal_print(LOG_INFO, "Received: Unknown setting", (unsigned long)getpid());
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
