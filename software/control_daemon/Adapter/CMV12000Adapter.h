#ifndef CMVADAPTER_H
#define CMVADAPTER_H

#include <memory>

#include "MemoryAdapter.h"
#include "IImageSensorAdapter.h"

class CMV12000Adapter //: public IImageSensorAdapter
{
    //uint32_t address = 0x60000000;
    uint32_t address = 0x18000000;
    uint32_t memorySize = 0x00020000;

    std::shared_ptr<MemoryAdapter> _memoryAdapter;
    //uint32_t* mappedAddress;

public:
    CMV12000Adapter();

    ~CMV12000Adapter();

    void SetGain(unsigned int gain, unsigned int adcRAnge);

    void SetConfigRegister(u_int8_t registerIndex, unsigned int value);

    void Execute();
};

#endif // CMVADAPTER_H
