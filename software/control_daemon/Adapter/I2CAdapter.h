#ifndef I2CADAPTER_H
#define I2CADAPTER_H

#include <fstream>
#include <sys/syslog.h>

// #include <json/json.hpp>
// using json = nlohmann::json;

#include "IAdapter.h"

#include "../Helpers/Helpers.h"

class I2CAdapter : public IAdapter
{
public:
    I2CAdapter();
    
    void ReadDescriptions(std::string descriptionFile) override
    {
        std::ifstream in(descriptionFile);
        if(!in.is_open())
        {
            std::string errorMessage = "Description file " + descriptionFile + " not found.";
            syslog (LOG_ERR, "%s", errorMessage.c_str());
            return;
        }

        //json j;
        //in >> j;
    }

    void CheckDevices() override {}

    void ReadByte(uint8_t data) override;
    void WriteByte(uint8_t data) override;
    void ReadBlock(uint8_t *data, unsigned int length) override;
    void WriteBlock(uint8_t *data, unsigned int length) override;

    void Execute();

    std::vector<std::string> GetAvailableMethods()
    {
        std::vector<std::string> availableMethods;
        availableMethods.push_back("Test1");
        availableMethods.push_back("Test2");

        return availableMethods;
    }
};

#endif //I2CADAPTER_H
