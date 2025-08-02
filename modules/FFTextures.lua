FemboyFatale = FemboyFatale or {}
local r = FemboyFatale
FFTextures = FFTextures or {}
local s = FFTextures

s.name = r.name .. "Textures"
s.displayName = "FFTextures"
s.defaults = {enabled = false}

s.data = {
    -- Overrides are of the format of {Old Texture, New Texture}
    overrides = {
        {
            "/esoui/art/icons/ability_healer_019.dds",
            "FemboyFatale/icons/overrides/PA.dds", "Powerful Assult"
        }
    }
}

for _, v in pairs(s.data.overrides) do s.defaults[v[3]] = {enabled = true} end

local function reloadTexture(texture_name, old_texture_path, new_texture_path)
    if (s.sv[texture_name].enabled) then
        RedirectTexture(old_texture_path, new_texture_path)
    else
        RedirectTexture(old_texture_path, old_texture_path)
    end
end

function s.reset()
    for _, v in pairs(s.data.overrides) do RedirectTexture(v[1], v[1]) end
    s.init()
end

function s.init()
    if (s.sv.enabled ~= true) then return end
    for _, v in pairs(s.data.overrides) do reloadTexture(v[3], v[1], v[2]) end
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
    for _, v in pairs(s.data.overrides) do
        controls[#controls + 1] = {
            type = "submenu",
            name = "|c00FFCC" .. string.upper(v[3]) .. "|r",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable/Disable",
                    getFunc = function() return s.sv.enabled end,
                    setFunc = function(enable)
                        s.sv[v[3]].enabled = enable
                        reloadTexture(v[3], v[1], v[2])
                    end
                }

            },
            icon = v[2],
            disabled = false
        }
    end
    root[#root + 1] = parent
end

r.modules = r.modules or {}
r.modules[s.name] = s

r.defaults = r.defaults or {};
r.defaults[s.name] = s.defaults
