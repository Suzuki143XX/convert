-- ServerScriptService/Server/Init.server.lua
print("Server starting...")

local success, err = pcall(function()
	local ContentService = require(script.Parent:WaitForChild("ContentService"))
	ContentService:Initialize()
end)

if not success then
	warn("Server init error:", err)
end

print("Server ready!")