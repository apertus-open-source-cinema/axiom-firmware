#include <iostream>

#include "../API_WS/MessageHandler.h"

int main(int argc, char *argv[])
{
    if(argc != 4)
    {
        std::cout << "Not enough arguments." << std::endl;
        return 1;
    }

    MessageHandler messageHandler;
    messageHandler.AddDaemonRequest("DaemonCLI", argv[1], argv[2], argv[3]);
    std::unique_ptr<DaemonRequestT> req;
    messageHandler.TransferData(req);
    
    // TODO (balysche): Show reply using req

    return 0;
}
