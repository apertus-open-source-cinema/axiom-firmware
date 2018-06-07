#ifndef IDAEMONMODULE_H
#define IDAEMONMODULE_H

#include <vector>
#include <string>

class IDaemonModule
{
public:
    virtual ~IDaemonModule() = default;

    virtual std::vector<std::string>GetAvailableMethods() = 0;
};

#endif //IDAEMONMODULE_H