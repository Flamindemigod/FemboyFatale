FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
FFTextures = FFTextures or {}
local s = FFTextures

s.name = r.name .. "Textures"
s.displayName = "FFTextures"
s.defaults = {enabled = false}
s.debug = 1
s.data = {
    rev = {},
    textures = {
        {
            abilityId = 61771,
            overrides = {
                "FemboyFatale/icons/overrides/AstoPA.dds",
                "FemboyFatale/icons/overrides/AstoTransmutation.dds"
            }
        }, -- Powerful Assualt
        {
            abilityId = 76936,
            overrides = {"FemboyFatale/icons/overrides/AstoTransmutation.dds"}
        }, -- Robes of Transmutation
        {
            abilityId = 166731,
            overrides = {"FemboyFatale/icons/overrides/AstoRC.dds"}
        } -- Rallying Cry
    }
}

for idx, v in pairs(s.data.textures) do
    v.source = GetAbilityIcon(v.abilityId)
    v.abilityName = GetAbilityName(v.abilityId)
    s.data.rev[v.abilityId] = idx
    s.defaults[idx] = {enabled = false}
end

local function reloadTexture(abilityId)
    local old_texture = s.data.textures[s.data.rev[abilityId]].source
    RedirectTexture(old_texture, old_texture)
    if (s.sv.enabled and s.sv[abilityId] ~= nil) then
        local new_texture =
            s.data.textures[s.data.rev[abilityId]].overrides[s.sv[abilityId]]
        RedirectTexture(old_texture, new_texture)
    end
    s.logger.trace("Loaded Texture for " .. abilityId)
end

function s.reset()
    for _, v in pairs(s.data.textures) do RedirectTexture(v.source, v.source) end
    s.logger.trace("Reset All Textures")
    s.init()
end

function s.init()
    s.logger = FFUtils.Logger(s.displayName, s.debug)
    s.logger.trace("Initialized Logger")
    if (s.sv.enabled ~= true) then return end
    for _, v in pairs(s.data.textures) do reloadTexture(v.abilityId) end
    s.logger.trace("Initialized Textures")
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
    for _, v in pairs(s.data.textures) do
        controls[#controls + 1] = {
            type = "submenu",
            name = "|c00FFCC" .. string.upper(v.abilityName) .. "|r",
            controls = {},
            icon = v.source
        }
        local c = controls[#controls].controls
        for idx, tex in pairs(v.overrides) do
            c[#c + 1] = {
                type = "texture",
                image = tex,
                imageWidth = 64,
                imageHeight = 64,
                width = "half"
            }
            c[#c + 1] = {
                type = "checkbox",
                name = "Enable/Disable",
                getFunc = function()
                    return s.sv[v.abilityId] == idx
                end,
                setFunc = function(val)
                    s.sv[v.abilityId] = val and idx or nil
                    s.logger.trace("Setting Texture for " .. v.abilityId)
                    reloadTexture(v.abilityId)
                end,
                width = "half"
            }
        end
    end
    root[#root + 1] = parent
end

r.modules = r.modules or {}
r.modules[1] = s

r.defaults = r.defaults or {};
r.defaults[1] = s.defaults
