-- src/server/DataStoreManager.lua
-- Handles all DataStore operations with retry logic

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(game.ReplicatedStorage.Shared.Config)
local ContentTypes = require(game.ReplicatedStorage.Shared.ContentTypes)

local DataStoreManager = {}
local PlayerData = {} -- Cache
local ContentCache = {} -- Temporary content storage (MemoryStore would be better for large scale)

local UserDataStore = DataStoreService:GetDataStore(Config.DATASTORE_NAME)

-- Retry logic for DataStore
local function safeCall(func, maxRetries)
	maxRetries = maxRetries or 5
	local success, result
	for i = 1, maxRetries do
		success, result = pcall(func)
		if success then return success, result end
		if i < maxRetries then task.wait(2^i) end -- Exponential backoff
	end
	return success, result
end

function DataStoreManager:LoadUserData(userId: number)
	local key = tostring(userId)
	local success, data = safeCall(function()
		return UserDataStore:GetAsync(key)
	end)
	
	if success then
		if not data then
			-- New user
			data = {
				userId = userId,
				joinedAt = os.time(),
				content = {},
				stats = {
					followers = 0,
					following = {},
					totalLikes = 0
				}
			}
		end
		PlayerData[userId] = data
		return data
	else
		warn("Failed to load data for user:", userId)
		return nil
	end
end

function DataStoreManager:SaveUserData(userId: number)
	local data = PlayerData[userId]
	if not data then return false end
	
	local key = tostring(userId)
	local success, err = safeCall(function()
		return UserDataStore:SetAsync(key, data)
	end)
	
	if not success then
		warn("Failed to save data:", err)
	end
	return success
end

function DataStoreManager:GetUserData(userId: number)
	return PlayerData[userId] or self:LoadUserData(userId)
end

-- Content Management
function DataStoreManager:SaveContent(userId: number, contentData: ContentTypes.ContentMetadata)
	local userData = self:GetUserData(userId)
	if not userData then return false, "User data not found" end
	
	-- Add to user's content list
	table.insert(userData.content, contentData.id)
	
	-- Save to global content cache (in production, use MemoryStore or separate DataStore)
	ContentCache[contentData.id] = contentData
	
	-- Update user data
	self:SaveUserData(userId)
	
	return true, contentData.id
end

function DataStoreManager:GetContent(contentId: string)
	return ContentCache[contentId]
end

function DataStoreManager:GetFeed(appType: string?, limit: number?)
	limit = limit or 50
	local feed = {}
	
	-- In production, this would query a sorted database
	for id, content in pairs(ContentCache) do
		if not appType or content.appType == appType then
			table.insert(feed, content)
		end
	end
	
	-- Sort by newest first
	table.sort(feed, function(a, b) return a.createdAt > b.createdAt end)
	
	-- Limit results
	local result = {}
	for i = 1, math.min(limit, #feed) do
		result[i] = feed[i]
	end
	
	return result
end

-- Auto-save on player leave
Players.PlayerRemoving:Connect(function(player)
	DataStoreManager:SaveUserData(player.UserId)
	PlayerData[player.UserId] = nil
end)

-- Periodic auto-save (every 60 seconds)
task.spawn(function()
	while true do
		task.wait(60)
		for userId, _ in pairs(PlayerData) do
			DataStoreManager:SaveUserData(userId)
		end
	end
end)

return DataStoreManager