#include <catch/catch.hpp>

#include "../Adapter/CMV12000Adapter.h"

// When enabled, then modified class is used to prevent crashes on PC (as RAM access is different from ARM)
#ifdef ENABLE_MOCK
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

    using CMV12000AdapterClass = CMV12000AdapterMod;    
#else    
    using CMV12000AdapterClass = CMV12000Adapter;
#endif

TEST_CASE( "Gain setting", "[CMV12000Adapter]" ) 
{
    CMV12000AdapterClass adapter;
    CHECK( adapter.SetParameter("gain", 3) == true );
    REQUIRE( adapter.GetParameter("gain") == 3 );
}

TEST_CASE( "Dummy parameter test, test should succeed if SetParameter() returns false (no handler found)", "[CMV12000Adapter]" ) 
{
    CMV12000AdapterClass adapter;
    REQUIRE( adapter.SetParameter("dummyParameter", 3) == false );
}