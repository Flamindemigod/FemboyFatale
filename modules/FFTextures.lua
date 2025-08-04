FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
FFTextures = FFTextures or {}
local s = FFTextures

s.name = r.name .. "Textures"
s.displayName = "FFTextures"
s.defaults = {enabled = false}
-- Funky Hashmap
local overrides = {}

s.data = {
    overrides = {
        {
            abilityId = 61771,
            override = "FemboyFatale/icons/overrides/AstoPA.dds"
        }
    }
}

for idx, v in pairs(s.data.overrides) do
    v.source = GetAbilityIcon(v.abilityId)
    v.abilityName = GetAbilityName(v.abilityId)
    s.defaults[idx] = {enabled = false}
end

local function reloadTexture(texture_id)
    local texture = s.data.overrides[texture_id]
    if (s.sv.enabled and s.sv[texture_id].enabled) then
        overrides[texture.abilityId] = texture_id
        RedirectTexture(texture.source, texture.override)
    else
        overrides[texture.abilityId] = nil
        RedirectTexture(texture.source, texture.source)
    end
end

function s.reset()
    for _, v in pairs(s.data.overrides) do
        RedirectTexture(v.source, v.source)
        overrides = {}
    end
    s.init()
end

function s.init()
    if (s.sv.enabled ~= true) then return end
    for idx, _ in pairs(s.data.overrides) do reloadTexture(idx) end
end

function s.menu(root)
    parent = {
        type = "submenu",
        name = s.displayName,
        controls = {
            {
                type = "description",
                text = "Does Funny Texture Gatekeeping",
                width = "full"
            }, {
                type = "checkbox",
                name = "Enable/Disable",
                getFunc = function() return s.sv.enabled end,
                setFunc = function(enable)
                    s.sv.enabled = enable
                    s.reset()
                end
            }
        }
    }
    local controls = parent.controls
    for idx, v in pairs(s.data.overrides) do
        controls[#controls + 1] = {
            type = "submenu",
            name = "|c00FFCC" .. string.upper(v.abilityName) .. "|r",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable/Disable",
                    getFunc = function()
                        return s.sv[idx].enabled
                    end,
                    setFunc = function(enable)
                        s.sv[idx].enabled = enable
                        reloadTexture(idx)
                    end
                }

            },
            icon = function()
                return s.sv[idx].enabled and v.override or v.source
            end,
            disabled = function()
                return not s.sv.enabled and overrides[v.abilityId] ~= nil and
                           overrides[abilityId] ~= idx
            end
        }
    end
    root[#root + 1] = parent
end

r.modules = r.modules or {}
r.modules[s.name] = s

r.defaults = r.defaults or {};
r.defaults[s.name] = s.defaults
