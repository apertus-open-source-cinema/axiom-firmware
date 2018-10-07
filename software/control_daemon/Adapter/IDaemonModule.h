#ifndef IDAEMONMODULE_H
#define IDAEMONMODULE_H

#include <functional>
#include <vector>
#include <string>
#include <unordered_map>

#include "../Log/JournalLogger.h"

class IDaemonModule
{
    // string& value, string& message, returns: bool - success or fail
    typedef std::function<bool(std::string&, std::string&)> GetterFunc;
    // string value, string& message, returns: bool - success or fail
    typedef std::function<bool(std::string, std::string&)> SetterFunc;

    struct ParameterHandler
    {
        GetterFunc Getter;
        SetterFunc Setter;
    };

    std::unordered_map<std::string, ParameterHandler> parameterHandlers;

    // TODO: Don't remove commented and related parts yet, maybe we need individual methods later, to trigger special functionality, which ar not related to parameters directly
    //typedef std::function<bool(std::string&)> CallbackFunc;

    //std::unordered_map<std::string, CallbackFunc> _registeredMethods;
    //std::unordered_map<std::string, CallbackFunc>::const_iterator it;

    //void RegisterMethods(std::string name, CallbackFunc func)
    //{
    //    _registeredMethods.emplace(std::make_pair(name, func));
    //}

    //std::vector<std::string> GetRegisteredMethodNames()
    //{
    //    std::vector<std::string> keys;
    //
    //    for(auto kv : _registeredMethods)
    //    {
    //        keys.push_back(kv.first);
    //    }
    //
    //    return keys;
    //}

    //bool ProcessMethod(std::string methodName, std::string value)
    //{
    //    it = _registeredMethods.find(methodName);
    //
    //    if(it != _registeredMethods.end())
    //    {
    //        return it->second(value);
    //    }
    //}


    //std::vector<std::string> GetAvailableMethods()
    //{
    //    return GetRegisteredMethodNames();
    //}

protected:
    virtual void RegisterAvailableMethods() = 0;

    void AddParameterHandler(std::string name, GetterFunc getter, SetterFunc setter)
    {
        parameterHandlers.insert(std::make_pair(name, ParameterHandler{getter, setter}));
    }

public:
    virtual ~IDaemonModule() = default;

    //virtual std::vector<std::string>GetAvailableMethods() = 0;

    bool HandleParameter(std::string parameterName, std::string& parameterValue, std::string& message)
    {
        std::string originalParameterName = parameterName;
        std::unordered_map<std::string, ParameterHandler>::const_iterator got = parameterHandlers.find (parameterName.erase(0, 4));
        if ( got == parameterHandlers.end() )
        {
            JournalLogger::Log("Handler not found");
            message = "Handler not found: " + parameterName;
            return false;
        }
        else
        {
            JournalLogger::Log("Handler found");

            auto handler = got->second;
            // TODO: Maybe replace prefixes with separate command attribute in request (JSON)
            auto method = (originalParameterName.find("set_") == 0) ? handler.Setter : handler.Getter;

            return method(parameterValue, message);
        }
    }
};

#endif //IDAEMONMODULE_H
