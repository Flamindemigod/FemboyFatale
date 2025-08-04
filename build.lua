-- Stub Out Some ESO API Stuff
function GetEventManager() return {RegisterForEvent = function() end}; end
function GetWindowManager() return {} end

require("FemboyFatale")

-- Write ESO's Addon Txt file
function generateESOConfig()
    local file = io.open("FemboyFatale.txt", "w")
    file:write("## Title: " .. FemboyFatale.name .. "\n")
    file:write("## Description: " .. FemboyFatale.description .. "\n")
    file:write("## Author: " .. FemboyFatale.author .. "\n")
    file:write("## APIVersion: 101043\n")
    file:write("## SavedVariables: " .. FemboyFatale.name .. "Vars\n")
    file:write("## DependsOn: LibAddonMenu-2.0\n")
    file:write("## Version: " .. FemboyFatale.version .. "\n")
    file:write("\n")
    file:write("FemboyFatale.lua\n")
    file:write("FemboyFatale.xml\n")
    file:write("FemboyFataleMenu.lua\n")
    file:write("FemboyFataleUtils.lua\n")
    file:write("\n")
    for dir in io.popen("ls modules"):lines() do
        file:write("modules/" .. dir .. "\n")
    end
    file:close()
end

function generateNewModule(moduleName)
    local file = io.open("modules/" .. moduleName .. ".lua", "w")
    file:write(FemboyFatale.name .. " = " .. FemboyFatale.name .. " or {}\n")
    file:write("local r = " .. FemboyFatale.name .. "\n")
    file:write(moduleName .. " = " .. moduleName .. " or {}\n")
    file:write("local s = " .. moduleName .. "\n")
    file:write("s.name = r.name .. " .. moduleName .. "\n")
    file:write("s.displayName = " .. moduleName .. "\n")
    file:write("s.defaults = {}\n")
    file:write("s.debug = 4\n")
    file:write("s.data = {}\n")
    file:write("\n")
    file:write("function s.reset()\nend\n\n")
    file:write("function s.init()\n")
    file:write("\ts.logger = FFUtils.Logger(s.displayName, s.debug)\n")
    file:write("\ts.logger.trace(\"Initialized Logger\")\n")
    file:write("end\n")
    file:write("\n")
    file:write("function s.menu(root)\n")
    file:write("parent = {\n")
    file:write("type = \"submenu\",\n")
    file:write("name = \"s.displayName\",\n")
    file:write("controls = {\n")
    file:write(
        "{type = \"description\", text = \"TODO: Add Description\", width = \"full\"}\n")
    file:write("},\n")
    file:write("}\n")
    file:write("root[#root + 1] = parent\n")
    file:write("end\n")
    file:write("\n")
    file:write("r.modules = r.modules or {}\n")
    file:write("r.modules[s.name] = s\n")
    file:write("r.defaults = r.defaults or {}\n")
    file:write("r.defaults[s.name] = s.defaults\n")

    file:close()
end

local i = 1
while #arg >= i do
    if (arg[i] == "-b") then
        generateESOConfig()
        i = i + 1
    elseif (arg[i] == "-n" and arg[i + 1] ~= nil) then
        generateNewModule(arg[i + 1])
        i = i + 2
    end
end
