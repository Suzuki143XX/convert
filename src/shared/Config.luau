-- src/shared/Config.lua
-- Shared configuration between client and server

local Config = {
	-- DataStore Keys
	DATASTORE_NAME = "PhoneUserData_v1",
	CONTENT_PREFIX = "Content_",
	
	-- Content Limits
	MAX_VIDEO_LENGTH = 60, -- seconds
	MAX_DESCRIPTION_LENGTH = 200,
	MAX_DAILY_UPLOADS = 10,
	
	-- App Configs
	Apps = {
		TikTak = {
			Color = Color3.fromRGB(255, 0, 128),
			Icon = "♪",
			MaxVideoLength = 60,
			AllowedTypes = {"Dance", "LipSync", "Comedy"}
		},
		YouToz = {
			Color = Color3.fromRGB(255, 0, 0),
			Icon = "▶",
			MaxVideoLength = 300,
			AllowedTypes = {"Gaming", "Vlog", "Tutorial"}
		},
		DanceVerse = {
			Color = Color3.fromRGB(138, 43, 226),
			Icon = "✦",
			MaxVideoLength = 120,
			AllowedTypes = {"Freestyle", "Choreography", "Battle"}
		}
	},
	
	-- Network Keys (Security)
	VALIDATION_SALT = "PhoneGame2024", -- Change this to something unique
	
	-- GUI Constants
	PHONE_SIZE = UDim2.new(0, 320, 0, 640),
	ANIMATION_SPEED = 0.4
}

return Config