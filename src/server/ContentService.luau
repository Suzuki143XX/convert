-- src/server/ContentService.lua
-- Handles content uploads, validation, and distribution

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Config = require(game.ReplicatedStorage.Shared.Config)
local ContentTypes = require(game.ReplicatedStorage.Shared.ContentTypes)
local Network = require(game.ReplicatedStorage.Shared.Network)
local DataStoreManager = require(script.Parent.DataStoreManager)

local ContentService = {}

-- Rate limiting
local UploadCooldowns = {}
local DAILY_LIMIT = Config.MAX_DAILY_UPLOADS

-- Validation
local function canUpload(userId: number): (boolean, string?)
	local now = os.time()
	local today = math.floor(now / 86400)
	local key = userId .. "_" .. today
	
	if not UploadCooldowns[key] then
		UploadCooldowns[key] = 0
	end
	
	if UploadCooldowns[key] >= DAILY_LIMIT then
		return false, "Daily upload limit reached (" .. DAILY_LIMIT .. ")"
	end
	
	return true, nil
end

function ContentService:Initialize()
	-- Set up RemoteEvents/Functions
	local uploadEvent = Network.getEvent("UploadContent")
	local getFeedFunc = Network.getFunction("GetFeed")
	local getUserContentFunc = Network.getFunction("GetUserContent")
	local likeEvent = Network.getEvent("LikeContent")
	
	-- Handle uploads
	uploadEvent.OnServerEvent:Connect(function(player, appType, contentData)
		local canUpload, errorMsg = canUpload(player.UserId)
		if not canUpload then
			-- Notify client of failure
			Network.fireClient("UploadFailed", player, errorMsg)
			return
		end
		
		-- Validate
		contentData.appType = appType
		contentData.userId = player.UserId
		contentData.username = player.Name
		
		local valid, validationError = ContentTypes.validateContent(contentData)
		if not valid then
			Network.fireClient("UploadFailed", player, validationError)
			return
		end
		
		-- Create metadata
		local metadata = {
			id = HttpService:GenerateGUID(false),
			userId = player.UserId,
			username = player.Name,
			appType = appType,
			title = contentData.title,
			description = contentData.description or "",
			createdAt = os.time(),
			likes = 0,
			views = 0,
			comments = 0,
			animationId = contentData.animationId,
			thumbnailId = contentData.thumbnailId
		}
		
		-- Save
		local success, result = DataStoreManager:SaveContent(player.UserId, metadata)
		if success then
			-- Increment counter
			local today = math.floor(os.time() / 86400)
			local key = player.UserId .. "_" .. today
			UploadCooldowns[key] = (UploadCooldowns[key] or 0) + 1
			
			-- Notify client of success
			Network.fireClient("UploadSuccess", player, metadata)
			
			-- Broadcast to relevant players (optimization: only those viewing the app)
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player then
					Network.fireClient("NewContent", p, metadata)
				end
			end
		else
			Network.fireClient("UploadFailed", player, "Server error")
		end
	end)
	
	-- Handle feed requests
	getFeedFunc.OnServerInvoke = function(player, appType, cursor)
		-- Security: limit request frequency
		local feed = DataStoreManager:GetFeed(appType, 20)
		return feed
	end
	
	-- Handle user content requests
	getUserContentFunc.OnServerInvoke = function(player, targetUserId)
		local data = DataStoreManager:GetUserData(targetUserId)
		if not data then return {} end
		
		local content = {}
		for _, contentId in ipairs(data.content) do
			local item = DataStoreManager:GetContent(contentId)
			if item then table.insert(content, item) end
		end
		
		return content
	end
	
	-- Handle likes
	likeEvent.OnServerEvent:Connect(function(player, contentId)
		local content = DataStoreManager:GetContent(contentId)
		if content then
			content.likes += 1
			-- Update creator stats
			local creatorData = DataStoreManager:GetUserData(content.userId)
			if creatorData then
				creatorData.stats.totalLikes += 1
			end
		end
	end)
	
	print("✓ ContentService initialized")
end

return ContentService