#include "CMV12000Adapter.h"

CMV12000Adapter::CMV12000Adapter() :
    address(0x60000000),
    memorySize(0x00020000)
{
    _memoryAdapter = std::make_shared<MemoryAdapter>();
    // Map the regions at start, to prevent repeating calls of mmap()
    _memoryAdapter->MemoryMap(address, memorySize);

    RegisterAvailableMethods();
}

void CMV12000Adapter::RegisterAvailableMethods()
{
    //RegisterMethods("set_gain", std::bind(&CMV12000Adapter::SetGain, this, std::placeholders::_1));

    // TODO: Add macros to simplify registering of getter and setter, e.g. GETTER_FUNC(CMV12000Adapter, GetGain)
    AddParameterHandler("gain", std::bind(&CMV12000Adapter::GetGain, this, std::placeholders::_1, std::placeholders::_2),
                        std::bind(&CMV12000Adapter::SetGain, this, std::placeholders::_1, std::placeholders::_2));
}

CMV12000Adapter::~CMV12000Adapter()
{
    _memoryAdapter->MemoryUnmap(address, memorySize);
}

bool CMV12000Adapter::SetGain(std::string gainValue, std::string& message)
{
    message = "SetGain() | Value: " + gainValue;
    JournalLogger::Log(message);

    if(gainValue.length() > 1)
    {
        message = "SetGain() | Gain out of range 0 -> 4";
        return false;
    }

    int gainIndex = stoi(gainValue);
    // TODO: Add handling of 3/3 gain value
    if(gainIndex < 0 || gainIndex > 4)
    {
        // TODO: Log error for unsuitable parameter
        message = "SetGain() | Gain out of range 0 -> 4";
        return false;
    }


    // TODO: Replace script code, extracted from set_gain.sh
    //cmv_reg 115 $GAIN      # gain
    //cmv_reg 116 $ADC_RANGE # ADC_range fine-tuned for each gain
    //cmv_reg 100 1          # ADC_range_mult2
    //cmv_reg 87 2000        # offset 1
    //cmv_reg 88 2000        # offset 2

    SetConfigRegister(115, _gain[gainIndex]);
    SetConfigRegister(116, _adcRAnge[gainIndex]);
    SetConfigRegister(100, 1);
    SetConfigRegister(87, 2000);
    SetConfigRegister(88, 2000);

    return true;
}

bool CMV12000Adapter::GetGain(std::string& gainValue, std::string& message)
{
    gainValue = 2;
    return true;
}

// CAUTION: Deactivated this method for now, as the development/testing is done on PC and this would constantly result in SEGFAULT (or similar)
void CMV12000Adapter::SetConfigRegister(u_int8_t registerIndex, unsigned int value)
{
    // TODO: Add implementation
    std::string message = "SetConfigRegister() - Register: " + std::to_string(registerIndex) + " | Value: " + std::to_string(value);
    JournalLogger::Log(message);

#ifndef ENABLE_MOCK
    _memoryAdapter->WriteWord(registerIndex, value);
#endif
}

void CMV12000Adapter::Execute()
{
    // TODO: Iterate through all added settings and apply them to SPI registers
}

//std::string CMV12000Adapter::GetParameter(std::string parameterName)
//{
//    std::unordered_map<std::string, ParameterHandler>::const_iterator got = parameterHandlers.find (parameterName);
//    if ( got == parameterHandlers.end() )
//    {
//        JournalLogger::Log("ImageSensor: Handler not found");
//        return false;
//    }
//    else
//    {
//        JournalLogger::Log("ImageSensor: Handler found");

//        auto handler = got->second;
//        return handler.Getter(*this);
//    }
//}

bool CMV12000Adapter::TestMethod(std::string& value)
{
    int val = std::stoi(value);
    val += 4;
    return true;
}
