#include "Daemon.h"

#include <chrono>
#include <iomanip>
#include <sstream>

std::string return_current_time_and_date()
{
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);

    std::stringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");
    return ss.str();
}

Daemon::Daemon() :
    _running(true),
    _socketDesc(0)
{
    _socketPath = "/tmp/axiom_daemon.uds";
    
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
    if (fdCount == 1)
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

    int new_socket;
    unsigned int addrlen = sizeof (_socketDesc);

    new_socket = accept (_socketDesc, (struct sockaddr*) &_socketDesc, &addrlen);
    if(new_socket < 0)
    {
        printf("ACCEPT ERROR = %s\n", strerror(errno));
        close(_socketDesc);
        exit(1);

    }

    while(_running)
    {
        memset(receivedBuffer, 0, 1024);

        // Wait for packets to arrive
        RetrieveIncomingData(new_socket, receivedBuffer, 1024);

        //sd_journal_print(LOG_INFO,  "Received data size: %lu", size);

        auto req = GetDaemonRequest(receivedBuffer);

        moduleName = req->module_()->c_str();

        std::cout << "Sender: " << req->sender()->c_str() << std::endl;
        std::cout << "Module: " << moduleName << std::endl;
        std::cout << "Command: " << req->command()->c_str() << std::endl;
        std::cout << "Value: " << req->value()->c_str() << std::endl;

        _module_iterator = _modules.find(moduleName);

        if (_module_iterator != _modules.end())
        {
            auto module = _module_iterator->second;
            sd_journal_print(LOG_INFO, "Received: %s", moduleName.c_str());
            std::vector<std::string> availableMethods = module->GetAvailableMethods();
            std::string value = req->value()->c_str();
            std::string message = "";
            bool result = ((CMV12000Adapter*)_cmvAdapter)->HandleParameter(req->command()->c_str(), value, message);

            std::cout << "Send response" << std::endl;
            std::string response = return_current_time_and_date();
            ssize_t error = send(new_socket, response.c_str(), response.length(), 0);
            if(error < 0)
            {
                std::cout << "Error while sending response." << std::endl;
                printf("SEND ERROR = %s\n", strerror(errno));
            }

            int i = 0;
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

    unlink(_socketPath.c_str()); // Unlink socket to ensure that new connection will not be refused

    _socketDesc = socket(AF_LOCAL, SOCK_SEQPACKET, 0);
    if (_socketDesc < 0)
    {
        errorMessage = "Socket error: " + std::string(strerror(errno));
    }

    _name.sun_family = AF_LOCAL;
    strcpy(_name.sun_path, _socketPath.c_str());

    int result = bind(_socketDesc, (struct sockaddr*) &_name, sizeof(_name));
    if (result < 0)
    {
        _statusMessage = "Bind failed: " + std::string(strerror(errno));
        sd_journal_print(LOG_ERR, "%s", _statusMessage.c_str());
        exit(1);
    }

    listen(_socketDesc, 5);
}

void Daemon::RetrieveIncomingData(int socket, uint8_t* receivedBuffer, unsigned int bufferSize)
{
    ssize_t size = recv(socket, receivedBuffer, size, 0);
    if(size < 0)
    {
        printf("RECV ERROR = %s\n", strerror(errno));
        close(_socketDesc);
        exit(1);
    }
    else if(size == 0)
    {
        exit(0);
    }
}
