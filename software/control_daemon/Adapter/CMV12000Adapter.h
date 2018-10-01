#ifndef CMVADAPTER_H
#define CMVADAPTER_H

#include <memory>
#include <functional>
#include <unordered_map>
#include <utility>

#include "MemoryAdapter.h"
#include "IImageSensorAdapter.h"
#include "IDaemonModule.h"

class CMV12000Adapter : public IDaemonModule//: public IImageSensorAdapter
{
    //uint32_t address = 0x60000000;
    uintptr_t address = 0x18000000;
    uint32_t memorySize = 0x00020000;

    std::shared_ptr<MemoryAdapter> _memoryAdapter;
    //uint32_t* mappedAddress;

    unsigned int _gain[5] = {0, 1, 3, 7, 11};
    unsigned int _adcRAnge[5] = {0x3eb, 0x3d5, 0x3d5, 0x3d5, 0x3e9};

    // TODO: Evaluate to move to a base class

    // string& value, string& message, returns: bool - success or fail
    typedef std::function<bool(CMV12000Adapter&, std::string&, std::string&)> GetterFunc;
    // string value, string& message, returns: bool - success or fail
    typedef std::function<bool(CMV12000Adapter&, std::string, std::string&)> SetterFunc;

    struct ParameterHandler
    {
        GetterFunc Getter;
        SetterFunc Setter;
    };

    std::unordered_map<std::string, ParameterHandler> parameterHandlers;

    //ILogger* _logger = new JournalLogger();

    bool SetGain(std::string gainValue, std::string& message);

    bool GetGain(std::string& gainValue, std::string& message);

    bool TestMethod(std::string& value);

    void RegisterAvailableMethods();

public:
    CMV12000Adapter();

    ~CMV12000Adapter();

    virtual void SetConfigRegister(u_int8_t registerIndex, unsigned int value);

    void Execute();

    //bool SetParameter(std::string parameterName, std::string parameterValue);
    //std::string GetParameter(std::string parameterName);

    std::vector<std::string> GetAvailableMethods()
    {
        return GetRegisteredMethodNames();
    }

    bool HandleParameter(std::string parameterName, std::string& parameterValue, std::string& message);
};

#endif // CMVADAPTER_H
