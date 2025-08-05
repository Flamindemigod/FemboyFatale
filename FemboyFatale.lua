FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
r.EM = GetEventManager()
r.WM = GetWindowManager()

r.name = "FemboyFatale"
r.description = "A bunch of PvP Utils made for a certain Femboy"
r.author = "|cFFA500FlaminDemigod|r, bitrock, garlicmoon"
r.version = "0.0.3"
r.variableVersion = 1
r.modules = r.modules or {}

r.defaults = r.defaults or {};

function r.reset() for _, module in pairs(r.modules) do module.reset() end end

function r.Initialize()
    r.sv = ZO_SavedVars:NewAccountWide(r.name .. "Vars", r.variableVersion, nil,
                                       r.defaults, GetWorldName())
    for _, module in pairs(r.modules) do
        -- Link SVs within the modules
        module.sv = r.sv[module.name]
        -- Initialize The Modules
        module.init()
    end
    r.buildMenu()
end

function r.OnAddOnLoaded(event, addonName)
    if addonName == r.name then
        r.Initialize()
        r.EM:UnregisterForEvent(r.name, EVENT_ADD_ON_LOADED)
    end
end

r.EM:RegisterForEvent(r.name, EVENT_ADD_ON_LOADED, r.OnAddOnLoaded)
