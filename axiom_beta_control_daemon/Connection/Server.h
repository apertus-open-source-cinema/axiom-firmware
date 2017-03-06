#ifndef SERVER_H
#define SERVER_H

class Server
{
    std::string _socketPath;

    bool running;

    // TODO: Allow multiple connections
    int socketDesc;
    sockaddr_un name;

    std::string _statusMessage;

public:
    Server() :
        _socketPath("/tmp/axiom_daemon"),
        running(true)
    {

    }

    void Setup()
    {
        SetupSocket();
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

        while(running)
        {
            memset(buf2, 0, 1024);
            int size = read(socketDesc, buf2, 1024);
            std::cout << "Output: " << buf2 << std::endl;
        }
    }

    void SetupSocket()
    {
        std::string errorMessage = "";

        socketDesc = socket(PF_LOCAL, SOCK_DGRAM, 0);
        if (socketDesc < 0)
        {
            errorMessage = "Socket error: " + std::string(strerror(errno));
        }

        unlink(_socketPath.c_str()); // Unlink socket to ensure that new connection will not be refused

        name.sun_family=AF_LOCAL;
        strcpy(name.sun_path, _socketPath.c_str());

        if (bind(socketDesc, (struct sockaddr*)&name, SUN_LEN(&name)) != 0)
        {
            _statusMessage = "Bind failed: " + std::string(strerror(errno));
            syslog (LOG_ERR, _statusMessage.c_str());
            exit(1);
        }
    }
};

#endif //SERVER_H
