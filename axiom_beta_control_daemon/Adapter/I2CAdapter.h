#ifndef I2CADAPTER_H
#define I2CADAPTER_H

#include <fstream>
#include <sys/syslog.h>

#include <json.hpp>
using json = nlohmann::json;

#include "IAdapter.h"

class I2CAdapter : public IAdapter
{
public:
    void ReadDescriptions(std::string descriptionFile)
    {
        std::ifstream in(descriptionFile);
        if(!in.is_open())
        {
            std::string errorMessage = "Description file " + descriptionFile + " not found.";
            syslog (LOG_ERR, "%s", errorMessage.c_str());
            return;
        }

        json j;
        in >> j;
    }

    void CheckDevices() {}

    void ReadByte(uint8_t data);
    void WriteByte(uint8_t data);
    void ReadBlock(uint8_t *data, unsigned int length);
    void WriteBlock(uint8_t *data, unsigned int length);

    void Execute();
};

void I2CAdapter::ReadByte(uint8_t data) {}
void I2CAdapter::WriteByte(uint8_t data) {}
void I2CAdapter::ReadBlock(uint8_t *data, unsigned int length) {}
void I2CAdapter::WriteBlock(uint8_t *data, unsigned int length) {}

void I2CAdapter::Execute() {}

#endif // I2CADAPTER_H


