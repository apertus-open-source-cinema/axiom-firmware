#ifndef CMVADAPTER_H
#define CMVADAPTER_H

#include <memory>
#include <functional>
#include <unordered_map>
#include <utility>

#include "MemoryAdapter.h"
#include "IImageSensorAdapter.h"

class CMV12000Adapter //: public IImageSensorAdapter
{
    //uint32_t address = 0x60000000;
    uint32_t address = 0x18000000;
    uint32_t memorySize = 0x00020000;

    std::shared_ptr<MemoryAdapter> _memoryAdapter;
    //uint32_t* mappedAddress;

    // TODO: Evaluate to move to a base class
    typedef std::function<int(CMV12000Adapter&)> GetterFunc;
    typedef std::function<void(CMV12000Adapter&, int)> SetterFunc;

    struct ParameterHandler
    {
        GetterFunc Getter;
        SetterFunc Setter;
    };

    std::unordered_map<std::string, ParameterHandler> parameterHandlers;

    //ILogger* _logger = new JournalLogger();
public:
    CMV12000Adapter();

    ~CMV12000Adapter();

    void SetGain(int gainValue);

    int GetGain();

    virtual void SetConfigRegister(u_int8_t registerIndex, unsigned int value);

    void Execute();
};

#endif // CMVADAPTER_H
