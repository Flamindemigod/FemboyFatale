FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
FFBuffs = FFBuffs or {}
local s = FFBuffs

r.modules = r.modules or {}
r.modules[#r.modules + 1] = s;

s.name = r.name .. "Buffs"
s.displayName = "FFBuffs"

s.data = {}

function s.reset() end

function s.init() end

function s.menu(root)
    parent = {
        type = "submenu",
        name = s.displayName,
        controls = {
            {type = "description", text = "Does Buff Tracking", width = "full"}
        }
    }
    root[#root + 1] = parent
end

