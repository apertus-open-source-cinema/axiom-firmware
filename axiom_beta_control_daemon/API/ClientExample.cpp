#include "Client.h"

int main()
{
    Client* client = new Client();
    uint8_t* testBuf = new uint8_t[2] {7, 5};
    client->AddSettingSPI(Mode::Write, "Test", ConnectionType::I2C, testBuf, 2);
    client->AddSettingIS(Mode::Write, ImageSensorSettings::Gain, 2);
    client->AddSettingIS(Mode::Write, ImageSensorSettings::ADCRange, 0x35e);

    client->TransferData();

    client->Execute();

    delete client;
    return 0;
}
