#include <unistd.h>
#include <string>
#include <iostream>
#include <pthread.h>

//#include <systemd/sd-daemon.h>

#include "Connection/Server.h"

#include <flatbuffers/idl.h>
#include <flatbuffers/util.h>
#include "Schema/axiom_daemon_generated.h"

//#include <json.hpp>
//using json = nlohmann::json;

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

// Requirement: package libi2c-dev, otherwise shorter one from kernel is used
#include <linux/i2c-dev.h>

#include "API/Client.h"

#include "Adapter/CMVAdapter.h"


int main(__attribute__((unused)) int argc, __attribute__((unused)) char *argv[])
{
//    json j2 = {
//        {"pi", 3.141},
//        {"happy", true},
//        {"name", "Niels"},
//        {"nothing", nullptr},
//        {"answer", {
//             {"everything", 42}
//         }},
//        {"list", {1, 0, 2}},
//        {"object", {
//             {"currency", "USD"},
//             {"value", 42.99}
//         }}
//    };

//    std::ofstream o("pretty.json");
//    o << std::setw(4) << j2 << std::endl;

//    std::ifstream i("pretty.json");
//    json j;
//    i >> j;

//    auto t2 = j2["object"]["currency"];
//    std::cout << t2 << std::endl;

//    int file = open("/dev/i2c-14", O_RDWR);
//    std::cout << strerror(errno) << std::endl;
//    unsigned long funcs;
//    int result = ioctl(file, I2C_FUNCS, &funcs);

//    result = ioctl(file, I2C_SLAVE, 0x57);
//    std::cout << strerror(errno) << std::endl;
//    uint8_t buf[256] = {0};
//    i2c_smbus_ioctl_data buf2;
//    result = i2c_smbus_read_byte_data(file, 0);
//    result = i2c_smbus_read_byte_data(file, 1);
//    result = i2c_smbus_read_byte_data(file, 2);
//    result = i2c_smbus_read_byte_data(file, 3);
//    result = i2c_smbus_read_byte_data(file, 4);
//    result = i2c_smbus_read_byte(file);
//    result = i2c_smbus_read_block_data(file, I2C_SMBUS_READ, buf);
//    std::cout << strerror(errno) << std::endl;
//    i2c_smbus_read_i2c_block_data(file, I2C_SMBUS_READ, 32, buf);
//    std::cout << strerror(errno) << std::endl;
//    result = read(file, buf, 8);
//    std::cout << strerror(errno) << std::endl;

//    Client client;
//    uint8_t payload[] = {1, 2 , 5};
//    client.AddSetting(Mode::Write, "Test123", ConnectionType::Memory, payload, 3);
//    uint8_t payload2[] = {8, 2 , 3, 6, 12};
//    client.AddSetting(Mode::Read, "Test456abc", ConnectionType::Memory, payload2, 5);
//    client.Execute();

    setlogmask (LOG_UPTO (LOG_NOTICE));
    openlog ("axiom_daemon", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL1);

    // TODO: Add smart pointer, to have more modern code
    Server* server = new Server();
    server->Setup();
    server->Start();

    closelog();

    if(server != nullptr)
    {
        delete server;
    }

    return 0;
}
