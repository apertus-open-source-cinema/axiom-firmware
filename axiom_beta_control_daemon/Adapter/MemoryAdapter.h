#ifndef MEMORYADAPTER_H
#define MEMORYADAPTER_H

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>
#include <string.h>
#include <sys/syslog.h>

#include "IAdapter.h"


class MemoryAdapter : public IAdapter
{
public:
    void ReadDescriptions(std::string descriptionFile) {}
    void CheckDevices() {}

    void ReadByte(uint8_t data) {}
    void WriteByte(uint8_t data) {}

    void ReadBlock(uint8_t *data, unsigned int length) {}
    void WriteBlock(uint8_t *data, unsigned int length) {}

    void* MemoryMap(uint32_t address, uint32_t size)
    {
        // TODO: Check if alignment is required
        int fd = open("/dev/mem", O_RDWR | O_SYNC);
        if (fd == -1)
        {
            std::string _statusMessage = "Error (open /dev/mem): " + std::string(strerror(errno));
            syslog (LOG_ERR, "%s", _statusMessage.c_str());
            return (void*)-1;
        }

        // TODO: Needs review
        uint32_t tempAddress = 0x00000000;

        void* result = mmap((void*)tempAddress, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, address);
        if(result == (void*)-1)
        {
            // TODO: Add error log

        }

        return result;
    }

    int MemoryUnmap(uint32_t address, uint32_t size)
    {
        return munmap((void*)address, size);
    }

    virtual void Execute()
    {

    }
};

#endif // MEMORYADAPTER_H
