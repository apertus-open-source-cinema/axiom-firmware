#include "CMV12000Adapter.h"

CMV12000Adapter::CMV12000Adapter()
{
    parameterHandlers.insert(std::make_pair("gain", ParameterHandler{&CMV12000Adapter::GetGain, &CMV12000Adapter::SetGain}));

    _memoryAdapter = std::make_shared<MemoryAdapter>();
    // Map the regions at start, to prevent repeating calls of mmap()
    _memoryAdapter->MemoryMap(address, memorySize);
}

CMV12000Adapter::~CMV12000Adapter()
{
    _memoryAdapter->MemoryUnmap(address, memorySize);
}

unsigned int gain[] = {0, 1, 3, 7, 11};
unsigned int adcRAnge[] = {0x3eb, 0x3d5, 0x3d5, 0x3d5, 0x3e9};

bool CMV12000Adapter::SetGain(int gainValue)
{
    std::string message = "SetGain() | Value: " + std::to_string(gainValue);
    JournalLogger::Log(message);
    // TODO: Add handling of 3/3 gain value
    if(gainValue < 0 || gainValue > 4)
    {
        // TODO: Log error for unsuitable parameter
        return false;
    }


    // TODO: Replace script code, extracted from set_gain.sh
    //cmv_reg 115 $GAIN      # gain
    //cmv_reg 116 $ADC_RANGE # ADC_range fine-tuned for each gain
    //cmv_reg 100 1          # ADC_range_mult2
    //cmv_reg 87 2000        # offset 1
    //cmv_reg 88 2000        # offset 2

    SetConfigRegister(115, gain[gainValue]);
    SetConfigRegister(116, adcRAnge[gainValue]);
    SetConfigRegister(100, 1);
    SetConfigRegister(87, 2000);
    SetConfigRegister(88, 2000);

    return true;
}

int CMV12000Adapter::GetGain()
{
    
    return 2;
}

// CAUTION: Deactivated this method for now, as the development/testing is done on PC and this would constantly result in SEGFAULT (or similar)
void CMV12000Adapter::SetConfigRegister(u_int8_t registerIndex, unsigned int value)
{
    // TODO: Add implementation
    std::string message = "SetConfigRegister() - Register: " + std::to_string(registerIndex) + " | Value: " + std::to_string(value);
    JournalLogger::Log(message);
    _memoryAdapter->WriteWord(registerIndex, value);
}

void CMV12000Adapter::Execute()
{
    // TODO: Iterate through all added settings and apply them to SPI registers
}

bool CMV12000Adapter::SetParameter(std::string parameterName, int parameterValue)
{
    std::unordered_map<std::string, ParameterHandler>::const_iterator got = parameterHandlers.find (parameterName);
    if ( got == parameterHandlers.end() )
    {
        JournalLogger::Log("ImageSensor: Handler not found");
        return false;
    }
    else
    {
        JournalLogger::Log("ImageSensor: Handler found");

        auto handler = got->second;
        return handler.Setter(*this, parameterValue);
    } 
}

int CMV12000Adapter::GetParameter(std::string parameterName)
{
    std::unordered_map<std::string, ParameterHandler>::const_iterator got = parameterHandlers.find (parameterName);
    if ( got == parameterHandlers.end() )
    {
        JournalLogger::Log("ImageSensor: Handler not found");
        return false;
    }
    else
    {
        JournalLogger::Log("ImageSensor: Handler found");

        auto handler = got->second;
        return handler.Getter(*this);
    } 
}