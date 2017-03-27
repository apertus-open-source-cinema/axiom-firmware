#include "Client.h"

int main()
{
    Client* client = new Client();
    //client->AddSetting(Mode::Write, );
    //client->AddSettingIS(Mode::Write, ImageSensorSettings::Gain, 2, 0x35e);

    delete client;
    return 0;
}
