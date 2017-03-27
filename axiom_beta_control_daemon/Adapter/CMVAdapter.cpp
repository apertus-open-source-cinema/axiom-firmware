#include "CMVAdapter.h"

CMVAdapter::CMVAdapter()
{
    // Map the regions at start, to prevent repeating calls of mmap()
    mappedAddress = (uint32_t*)MemoryMap(baseAddress, memorySize);
}

CMVAdapter::~CMVAdapter()
{
    MemoryUnmap(baseAddress, memorySize);
}

void CMVAdapter::SetGain(unsigned int gain, unsigned int adcRAnge)
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
void CMVAdapter::SetCMVRegister(u_int8_t registerIndex, unsigned int value)
{
    // TODO: Add implementation
    //mappedAddress[registerIndex] = value;
}

void CMVAdapter::Execute()
{
    // TODO: Iterate through all added settings and apply them to SPI registers
}
