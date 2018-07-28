#ifndef IDAEMONMODULE_H
#define IDAEMONMODULE_H

#include <functional>
#include <vector>
#include <string>
#include <unordered_map>

class IDaemonModule
{
    typedef std::function<std::string(std::string&)> CallbackFunc;

protected:
    std::unordered_map<std::string, CallbackFunc> _registeredMethods;
    std::unordered_map<std::string, CallbackFunc>::const_iterator it;

    void RegisterMethods(std::string name, CallbackFunc func)
    {
        _registeredMethods.emplace(std::make_pair(name, func));
    }

    std::vector<std::string> GetRegisteredMethodNames()
    {
        std::vector<std::string> keys;

        for(auto kv : _registeredMethods)
        {
            keys.push_back(kv.first);
        }

        return keys;
    }

public:
    virtual ~IDaemonModule() = default;

    virtual std::vector<std::string>GetAvailableMethods() = 0;

    std::string ProcessMethod(std::string methodName, std::string value)
    {
        it = _registeredMethods.find(methodName);

        if(it != _registeredMethods.end())
        {
            return it->second(value);
        }
    }
};

#endif //IDAEMONMODULE_H
