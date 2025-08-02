-- Stub Out Some ESO API Stuff
function GetEventManager() return {RegisterForEvent = function() end}; end

require("FemboyFatale")

print("## Title: " .. FemboyFatale.name)
print("## Description: " .. FemboyFatale.description)
print("## Author: " .. FemboyFatale.author)
print("## APIVersion: 101043")
print("## SavedVariables: " .. FemboyFatale.name .. "Vars")
print("## DependsOn: LibAddonMenu-2.0")
print("## Version: " .. FemboyFatale.version)
print("")
print("FemboyFatale.lua")
print("FemboyFatale.xml")
print("FemboyFataleMenu.lua")
print("")
for dir in io.popen("ls modules"):lines() do print("modules/" .. dir) end
