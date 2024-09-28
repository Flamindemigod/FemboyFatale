FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
local EM = GetEventManager()

r.name = "FemboyFatale"
r.author = "|cFFA500FlaminDemigod|r"
r.version = "0.0.1"
r.variableVersion = 1

function r.Initialize()
  r.buildMenu()
end

function r.OnAddOnLoaded(event, addonName)
    if addonName == r.name then
        r.Initialize()
        EVENT_MANAGER:UnregisterForEvent(r.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(r.name, EVENT_ADD_ON_LOADED, r.OnAddOnLoaded)
