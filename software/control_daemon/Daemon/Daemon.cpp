#include "Daemon.h"

#include <chrono>
#include <iomanip>
#include <sstream>

std::string GetCurrentTimestamp()
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

    // TODO (BAndiT1983): Rework to map, see image_sensor example below
    _memoryAdapter = new MemoryAdapter();
    _i2cAdapter = new I2CAdapter();

    _modules["image_sensor"] = std::make_shared<CMV12000Adapter>();

    // TODO (BAndiT1983): Add real reading of revision/version
    //std::string/int?? revision = ReadRevision();
    //std::string revision = "29";

    // TODO (BAndiT1983): Adjust paths to real ones, this ones are just for testing
    // TODO (BAndiT1983): Add fallback to older revision version if for current one no file is available
    //_memoryAdapter->ReadDescriptions("../Descriptions/Memory_rev" + revision + ".json");
    //_i2cAdapter->ReadDescriptions("../Descriptions/I2C_rev" + revision + ".json");
}

Daemon::~Daemon()
{
    delete _memoryAdapter;
    delete _i2cAdapter;
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
        sd_journal_print(LOG_INFO, "Legacy socket initialization");
        
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

    unsigned int addrlen = sizeof (_socketDesc);
    int new_socket = accept (_socketDesc, reinterpret_cast<struct sockaddr*>(&new_socket), &addrlen);
    while(_running)
    {
        // TODO (BAndiT1983): Add handling of multiple clients, e.g. each processing in new thread, also check thread-safety of STL vector, to place requests in a queue

        if(new_socket < 0)
        {
            printf("ACCEPT ERROR = %s\n", strerror(errno));
            close(_socketDesc);
            exit(1);
        }

        // Wait for packets to arrive
        RetrieveIncomingData(new_socket, receivedBuffer, 1024);

        ProcessReceivedData(receivedBuffer);

        ssize_t error = send(new_socket, _builder.GetBufferPointer(), _builder.GetSize(), 0);
        if(error < 0)
        {
            std::cout << "Error while sending response." << std::endl;
            printf("SEND ERROR = %s\n", strerror(errno));
        }

        //close(new_socket);
    }
}

void Daemon::ProcessReceivedData(uint8_t* receivedBuffer)
{
    auto req= UnPackDaemonRequest(receivedBuffer);

    std::string moduleName = req.get()->module_;

    if(moduleName == "general")
    {
        bool result = ProcessGeneralRequest(req);

        req.get()->status = result == true ? "success" : "fail";
        req.get()->timestamp = GetCurrentTimestamp();

        _builder.Finish(CreateDaemonRequest(_builder, req.get()));

        return;
    }

    _module_iterator = _modules.find(moduleName);
     std::string message = "";
    if (_module_iterator == _modules.end())
    {        
        message = "Received: Unknown module";
        sd_journal_print(LOG_INFO, "Received: Unknown module");
        req.get()->message = message;
        _builder.Finish(CreateDaemonRequest(_builder, req.get()));
        return;
    }

    auto module = _module_iterator->second;

    std::string value = req->value;

    bool result = module->HandleParameter(req->command, req.get()->value, req.get()->message);

    // TODO (BAndiT1983):Check if assignments are really required, or if it's suitable of just passing reference to req attirbutes
    req.get()->status = result == true ? "success" : "fail";
    req.get()->timestamp = GetCurrentTimestamp();

    _builder.Finish(CreateDaemonRequest(_builder, req.get()));
}

bool Daemon::ProcessGeneralRequest(std::unique_ptr<DaemonRequestT> &req)
{
    if(req.get()->command == "get_available_methods")
    {
        req.get()->message = "Available Methods: NONE";
        return true;
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
