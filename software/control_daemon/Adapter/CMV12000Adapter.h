#ifndef CMVADAPTER_H
#define CMVADAPTER_H

#include <memory>
#include <functional>
#include <unordered_map>
#include <utility>

#include "MemoryAdapter.h"
#include "IDaemonModule.h"

class CMV12000Adapter : public IDaemonModule
{
    uint32_t address;
    uint32_t memorySize;

    std::shared_ptr<MemoryAdapter> _memoryAdapter;
    //uint32_t* mappedAddress;

    unsigned int _gain[5] = {0, 1, 3, 7, 11};
    unsigned int _adcRAnge[5] = {0x3eb, 0x3d5, 0x3d5, 0x3d5, 0x3e9};

    // TODO: Evaluate to move to a base class

    //ILogger* _logger = new JournalLogger();

    bool SetGain(std::string gainValue, std::string& message);
    bool GetGain(std::string& gainValue, std::string& message);

    bool TestMethod(std::string& value);

public:
    CMV12000Adapter();

    ~CMV12000Adapter();

    virtual void SetConfigRegister(u_int8_t registerIndex, unsigned int value);

    void Execute();

    //bool SetParameter(std::string parameterName, std::string parameterValue);
    //std::string GetParameter(std::string parameterName);

protected:
    void RegisterAvailableMethods();
};

#endif // CMVADAPTER_H
