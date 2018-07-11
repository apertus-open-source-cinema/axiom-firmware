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
    //std::string revision = "29";

    // TODO (BAndiT1983): Idea: Replace plain initialization with map of adapters, evaluation required
    _memoryAdapter = new MemoryAdapter();
    _i2cAdapter = new I2CAdapter();
    _cmvAdapter = new CMV12000Adapter();

    _modules["image_sensor"] = std::make_shared<CMV12000Adapter>();

    // TODO (BAndiT1983): Adjust paths to real ones, this ones are just for testing
    // TODO (BAndiT1983): Add fallback to older revision version if for current one no file is available

    //_memoryAdapter->ReadDescriptions("../Descriptions/Memory_rev" + revision + ".json");
    //_i2cAdapter->ReadDescriptions("../Descriptions/I2C_rev" + revision + ".json");
}

Daemon::~Daemon()
{
    delete _memoryAdapter;
    delete _i2cAdapter;
    delete _cmvAdapter;
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
        sd_journal_print(LOG_INFO, "Number of file descriptors: %d", fdCount);
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

    std::string moduleName;

    while(_running)
    {
        memset(receivedBuffer, 0, 1024);

        // Wait for packets to arrive
        ssize_t size = read(_socketDesc, receivedBuffer, 1024);

        sd_journal_print(LOG_INFO,  "Received data size: %lu", size);

        auto req = GetDaemonRequest(receivedBuffer);

        moduleName = req->module_()->c_str();

        std::cout << "Sender: " << req->sender()->c_str() << std::endl;
        std::cout << "Module: " << moduleName << std::endl;

        _module_iterator = _modules.find(moduleName);

        if (_module_iterator != _modules.end())
        {
            sd_journal_print(LOG_INFO, "Received: %s", moduleName.c_str());
            std::vector<std::string> availableMethods = _module_iterator->second->GetAvailableMethods();
        }
        else
        {
            sd_journal_print(LOG_INFO, "Received: Unknown setting");
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

    if (bind(_socketDesc, reinterpret_cast<struct sockaddr*>(&_name), SUN_LEN(&_name)) != 0)
    {
        _statusMessage = "Bind failed: " + std::string(strerror(errno));
        sd_journal_print(LOG_ERR, "%s", _statusMessage.c_str());
        exit(1);
    }
}
