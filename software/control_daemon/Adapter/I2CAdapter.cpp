#include "I2CAdapter.h"

I2CAdapter::I2CAdapter()
{
}

void I2CAdapter::ReadByte(uint8_t data)
{
    UNUSED(data);
}

void I2CAdapter::WriteByte(uint8_t data)
{
    UNUSED(data);
}

void I2CAdapter::ReadBlock(uint8_t *data, unsigned int length)
{
    UNUSED(data);
    UNUSED(length);
}

void I2CAdapter::WriteBlock(uint8_t *data, unsigned int length)
{
    UNUSED(data);
    UNUSED(length);
}

void I2CAdapter::Execute() {}
