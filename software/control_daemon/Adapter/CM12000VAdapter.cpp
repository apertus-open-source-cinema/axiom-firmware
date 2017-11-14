#include "CMV12000Adapter.h"

CMV12000Adapter::CMV12000Adapter()
{
    // Map the regions at start, to prevent repeating calls of mmap()
    MemoryMap(address, memorySize);
}

CMVA12000dapter::~CMV12000Adapter()
{
    MemoryUnmap(address, memorySize);
}

void CMV12000Adapter::SetGain(unsigned int gain, unsigned int adcRAnge)
{
    // TODO: Add handling of 3/3 gain value
    if(gain < 1 || gain > 3)
    {
        // TODO: Log error for unsuitable parameter
    }


    // TODO: Replace script code, extracted from set_gain.sh
    //cmv_reg 115 $GAIN      # gain
    //cmv_reg 116 $ADC_RANGE # ADC_range fine-tuned for each gain
    //cmv_reg 100 1          # ADC_range_mult2
    //cmv_reg 87 2000        # offset 1
    //cmv_reg 88 2000        # offset 2

    SetCMVRegister(115, gain);
    SetCMVRegister(116, adcRAnge);
    SetCMVRegister(100, 1);
    SetCMVRegister(87, 2000);
    SetCMVRegister(88, 2000);
}

// CAUTION: Deactivated this method for now, as the development/testing is done on PC and this would constantly result in SEGFAULT (or similar)
void CMV12000Adapter::SetConfigRegister(u_int8_t registerIndex, unsigned int value)
{
    // TODO: Add implementation
    std::string message = "SetCMVRegister() - Register: " + std::to_string(registerIndex) + " | Value: " + std::to_string(value);
    sd_journal_print(LOG_INFO, message.c_str(), (unsigned long)getpid());
    WriteWord(registerIndex, value);
}

void CMV12000Adapter::Execute()
{
    // TODO: Iterate through all added settings and apply them to SPI registers
}
