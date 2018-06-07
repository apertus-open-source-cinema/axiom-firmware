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
    messageHandler.TransferData();
    
    // TODO (balysche): Show reply

    return 0;
}
