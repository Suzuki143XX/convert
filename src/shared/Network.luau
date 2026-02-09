-- src/shared/Network.lua
-- Safe networking wrapper

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Network = {}
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

function Network.getEvent(name: string): RemoteEvent
	local event = Remotes:FindFirstChild(name)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = Remotes
	end
	return event
end

function Network.getFunction(name: string): RemoteFunction
	local func = Remotes:FindFirstChild(name)
	if not func then
		func = Instance.new("RemoteFunction")
		func.Name = name
		func.Parent = Remotes
	end
	return func
end

-- Client-side fire server
function Network.fireServer(eventName: string, ...): ()
	if RunService:IsClient() then
		local event = Network.getEvent(eventName)
		event:FireServer(...)
	else
		warn("Cannot FireServer from server")
	end
end

-- Server-side fire client
function Network.fireClient(eventName: string, player: Player, ...): ()
	if RunService:IsServer() then
		local event = Network.getEvent(eventName)
		event:FireClient(player, ...)
	else
		warn("Cannot FireClient from client")
	end
end

-- Safe invoke (for RemoteFunctions)
function Network.invokeServer(funcName: string, ...): any
	if RunService:IsClient() then
		local func = Network.getFunction(funcName)
		return func:InvokeServer(...)
	end
	return nil
end

return Network