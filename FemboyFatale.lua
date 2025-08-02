FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
r.EM = GetEventManager()
-- r.WM = GetWindowManager()

r.name = "FemboyFatale"
r.description = "A bunch of PvP Utils made for a certain Femboy"
r.author = "|cFFA500FlaminDemigod|r"
r.version = "0.0.2"
r.variableVersion = 1
-- r.stack = {w = 0, h = 0, items = {}}
r.modules = r.modules or {}

r.defaults = r.defaults or {};

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
    -- r.stack.parent = r.WM:GetControlByName(r.name .. "Stack")
    -- r.pool = ZO_ControlPool:New("FFSlice", r.stack.parent, "")
end

function r.OnAddOnLoaded(event, addonName)
    if addonName == r.name then
        r.Initialize()
        r.EM:UnregisterForEvent(r.name, EVENT_ADD_ON_LOADED)
    end
end

-- function r.Test()
--     local control, key = r.pool:AcquireObject()
--     control:SetAnchor(TOPLEFT, r.stack.parent, TOPLEFT, 0,
--                       control:GetHeight() * (key - 1))
--     table.insert(r.stack.items, control)
-- end

r.EM:RegisterForEvent(r.name, EVENT_ADD_ON_LOADED, r.OnAddOnLoaded)
