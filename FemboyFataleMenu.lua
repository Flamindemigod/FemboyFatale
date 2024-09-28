FemboyFatale = FemboyFatale or {}
local r = FemboyFatale

function r.buildMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = r.name,
        displayName = r.displayName,
        author = r.author,
        version = "" .. r.version,
        slashCommand = "/ff",
        registerForDefaults = true,
        registerForRefresh = true
    }

    local generalOptions = {
        {
            type = "description",
            text = "A bunch of PvP Utils made for a certain Femboy"
        }
    }

    LAM:RegisterAddonPanel(r.name .. "GeneralOptions", panelData)
    LAM:RegisterOptionControls(r.name .. "GeneralOptions", generalOptions)
end
