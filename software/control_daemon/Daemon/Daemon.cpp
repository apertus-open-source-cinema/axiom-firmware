#include "Daemon.h"

Daemon::Daemon() :
    _running(true),
    _socketDesc(0)
{
    _socketPath = "/tmp/axiom_daemon";
    
    _processID = std::to_string(getpid());
    sd_journal_print(LOG_INFO, "Initialization");

    // TODO (BAndiT1983): Add real reading of revision/version
    //std::string/int?? revision = ReadRevision();
    std::string revision = "29";

    // TODO (BAndiT1983): Idea: Replace plain initialization with map of adapters, evaluation required
    _memoryAdapter = new MemoryAdapter();
    _i2cAdapter = new I2CAdapter();
    _cmvAdapter = new CMV12000Adapter();

    // TODO (BAndiT1983): Adjust paths to real ones, this ones are just for testing
    // TODO (BAndiT1983): Add fallback to older revision version if for current one no file is available
        
	//_memoryAdapter->ReadDescriptions("../Descriptions/Memory_rev" + revision + ".json");
    //_i2cAdapter->ReadDescriptions("../Descriptions/I2C_rev" + revision + ".json");
}

Daemon::~Daemon()
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

    void Daemon::Setup()
    {
        int fdCount = sd_listen_fds(0);
        if (fdCount  == 1)
        {
            sd_journal_print(LOG_INFO, "systemd socket activation");            
           _socketDesc = SD_LISTEN_FDS_START;
        }
        else if(fdCount > 1)
        {
            sd_journal_print(LOG_INFO, "Too many file descriptors");    
            exit(1);
        }
        else
        {
            std::string message = "Number of file descriptors: " + std::to_string(fdCount);
            sd_journal_print(LOG_INFO, message.c_str());    
            sd_journal_print(LOG_INFO, "legacy socket initialization");
        
            SetupSocket();
        }
    }

    void Daemon::Start()
    {
           Process();
    }

void Daemon::Process()
    {
        uint8_t* receivedBuffer = new uint8_t[1024];

        while(_running)
        {
            memset(receivedBuffer, 0, 1024);

            // Wait for packets to arrive
            int size = read(_socketDesc, receivedBuffer, 1024);

            std::string message = "Received data size: " + std::to_string(size);
            sd_journal_print(LOG_INFO, message.c_str());            

            auto packet = GetPacket(receivedBuffer);
            auto set = packet->settings();
            int size2 = set->size();

            for(int index = 0; index < size2; ++index)
            {
                auto t = set->Get(index);
                auto payload = t->payload_type();

                switch(payload)
                {
                    //  case Setting::DaemonRequest:
                    //      sd_journal_print(LOG_INFO, "Received: DaemonRequest");
                    //  break;
                // case Setting::ImageSensorSetting:
                // {
                //     sd_journal_print(LOG_INFO, "Received: Image Sensor setting");
                //     const ImageSensorSetting* is = t->payload_as_ImageSensorSetting();
                //     _cmvAdapter->SetParameter(is->setting()->str(), is->parameter());
                //     //is->mode(); // Just a dummy call to supress "unused" warning
                //     /*Mode mode = is->mode();
                //     uint16_t parameter = is->parameter();
                //     ImageSensorSettings s2 = is->setting();*/
                //     //_settingsIS.push_back(is);
                // }
                //     break;
                // case Setting::SPISetting:
                // {
                //     sd_journal_print(LOG_INFO, "Received: SPI setting");
                //     const SPISetting* is = t->payload_as_SPISetting();
                //     is->destination(); // Just a dummy call to supress "unused" warning
                // }
                //     break;
                default:
                    sd_journal_print(LOG_INFO, "Received: Unknown setting");
                    break;
                }
            }
        }
    }

    void Daemon::SetupSocket()
    {
        std::string errorMessage;

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
            sd_journal_print(LOG_ERR, "%s", _statusMessage.c_str());
            exit(1);
        }
    }