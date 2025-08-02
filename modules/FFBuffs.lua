-- A lot of this module is heavily derived from Buff The Group
-- https://github.com/Fostecks/BuffTheGroup
-- I'm moving a lot of the code into a this module but rewriting it to be a lot more maintainable than it is currently
-- However Bitrock(Fostecks) and garlicmoon should still be considered the primary author of this code.
-- As the functionailty will be unchanged
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

