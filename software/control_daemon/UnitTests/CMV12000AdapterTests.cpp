#define CATCH_CONFIG_MAIN
#include <catch.hpp>

#include "../Adapter/CMV12000Adapter.h"

// Disabled writing to prevent SEGFAULT
class CMV12000AdapterMod : public CMV12000Adapter
{
public:
    virtual void SetConfigRegister(u_int8_t registerIndex, unsigned int value) override
    {
        // TODO: Add implementation
        //std::string message = "SetConfigRegister() - Register: " + std::to_string(registerIndex) + " | Value: " + std::to_string(value);
        //JournalLogger::Log(message);
        //_memoryAdapter->WriteWord(registerIndex, value);
    }
};

TEST_CASE( "Gain setting", "[CMV12000Adapter]" ) 
{
    CMV12000AdapterMod adapter;
    adapter.SetGain(3);
    REQUIRE( adapter.GetGain() == 3 );
}
