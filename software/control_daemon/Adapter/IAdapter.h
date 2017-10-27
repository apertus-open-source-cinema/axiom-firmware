#ifndef IADAPTER_H
#define IADAPTER_H

#include <iostream>

class IAdapter
{
public:
    // TODO: Move definition outside to remove vtable warnings
    virtual ~IAdapter() {}

    // TODO: Exposed it for tests, later it should reviewed again
    virtual void ReadDescriptions(std::string descriptionFile) = 0;

    // Checks all the devices for presence, if device is not accesible log some error
    virtual void CheckDevices() = 0;

    // Iterate through all received settings and apply them
    virtual void Execute() = 0;

    // General read/write methods
    virtual void ReadByte(uint8_t data) = 0;
    virtual void WriteByte(uint8_t data) = 0;

    virtual void ReadBlock(uint8_t* data, unsigned int length) = 0;
    virtual void WriteBlock(uint8_t* data, unsigned int length) = 0;
};

#endif // IADAPTER_H


