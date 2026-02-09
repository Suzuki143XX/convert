-- src/client/PhoneClient.lua
-- Main client controller

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Config = require(game.ReplicatedStorage.Shared.Config)
local Network = require(game.ReplicatedStorage.Shared.Network)

local PhoneClient = {}
PhoneClient.Apps = {}
PhoneClient.CurrentApp = nil
PhoneClient.IsOpen = false

-- GUI References (will be created or found)
PhoneClient.GUI = nil
PhoneClient.PhoneFrame = nil
PhoneClient.ToggleButton = nil

-- Utility
local function CreateInstance(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do obj[k] = v end
	return obj
end

local function Tween(obj, props, duration, style, dir)
	TweenService:Create(obj, TweenInfo.new(
		duration or Config.ANIMATION_SPEED,
		style or Enum.EasingStyle.Quart,
		dir or Enum.EasingDirection.Out
	), props):Play()
end

-- Initialize GUI
function PhoneClient:InitGUI()
	local screenGui = CreateInstance("ScreenGui", {
		Name = "AdvancedPhone",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui
	})
	
	self.GUI = screenGui
	
	-- Toggle Button (Bottom Right)
	self.ToggleButton = CreateInstance("TextButton", {
		Name = "PhoneToggle",
		Size = UDim2.new(0, 120, 0, 45),
		Position = UDim2.new(1, -140, 1, -90),
		Text = "Open Phone",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		BackgroundColor3 = Config.Apps.TikTak.Color,
		BorderSizePixel = 0,
		Parent = screenGui
	})
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 22)
	corner.Parent = self.ToggleButton
	
	-- Phone Frame
	self.PhoneFrame = CreateInstance("Frame", {
		Name = "Phone",
		Size = Config.PHONE_SIZE,
		Position = UDim2.new(0.5, -160, 1.5, 0), -- Start below screen
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = true,
		Parent = screenGui
	})
	
	Instance.new("UICorner", self.PhoneFrame).CornerRadius = UDim.new(0, 40)
	
	-- Screen Container
	local screen = CreateInstance("Frame", {
		Name = "Screen",
		Size = UDim2.new(1, -20, 1, -40),
		Position = UDim2.new(0, 10, 0, 30),
		BackgroundColor3 = Color3.fromRGB(10, 10, 15),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.PhoneFrame
	})
	
	Instance.new("UICorner", screen).CornerRadius = UDim.new(0, 30)
	
	self.ScreenContainer = screen
	
	-- Close Button
	local closeBtn = CreateInstance("TextButton", {
		Name = "CloseBtn",
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(0.5, -20, 1, -50),
		Text = "—",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		BackgroundColor3 = Color3.fromRGB(40, 40, 45),
		Parent = self.PhoneFrame
	})
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
	
	closeBtn.MouseButton1Click:Connect(function() self:ClosePhone() end)
	self.ToggleButton.MouseButton1Click:Connect(function()
		if self.IsOpen then self:ClosePhone() else self:OpenPhone() end
	end)
end

function PhoneClient:OpenPhone()
	self.IsOpen = true
	self.ToggleButton.Text = "Close Phone"
	self.ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	Tween(self.PhoneFrame, {Position = UDim2.new(0.5, -160, 0.5, -320)}, 0.5)
	Tween(self.ToggleButton, {Position = UDim2.new(1, -140, 1, -20)}, 0.3)
	
	-- Notify current app
	if self.CurrentApp and self.Apps[self.CurrentApp].OnOpen then
		self.Apps[self.CurrentApp].OnOpen()
	end
end

function PhoneClient:ClosePhone()
	self.IsOpen = false
	self.ToggleButton.Text = "Open Phone"
	self.ToggleButton.BackgroundColor3 = Config.Apps.TikTak.Color
	
	-- Close any open app screens
	for name, app in pairs(self.Apps) do
		if app.Close then app.Close() end
	end
	self.CurrentApp = nil
	
	Tween(self.PhoneFrame, {Position = UDim2.new(0.5, -160, 1.5, 0)}, 0.5)
	Tween(self.ToggleButton, {Position = UDim2.new(1, -140, 1, -90)}, 0.3)
end

function PhoneClient:RegisterApp(name, appModule)
	self.Apps[name] = appModule
	appModule:Initialize(self.ScreenContainer, self)
end

function PhoneClient:SwitchToApp(appName)
	if self.CurrentApp == appName then return end
	
	-- Close current
	if self.CurrentApp and self.Apps[self.CurrentApp].OnHide then
		self.Apps[self.CurrentApp].OnHide()
	end
	
	self.CurrentApp = appName
	
	-- Open new
	if self.Apps[appName] and self.Apps[appName].OnShow then
		self.Apps[appName].OnShow()
	end
end

-- Initialize
function PhoneClient:Start()
	self:InitGUI()
	
	-- Load apps
	local TikTak = require(script.Parent.Apps.TikTakApp)
	local YouToz = require(script.Parent.Apps.YouTozApp)
	local Dance = require(script.Parent.Apps.DanceApp)
	
	self:RegisterApp("TikTak", TikTak)
	self:RegisterApp("YouToz", YouToz)
	self:RegisterApp("DanceVerse", Dance)
	
	-- Create Home Screen with app icons
	self:CreateHomeScreen()
	
	-- Listen for server events
	Network.getEvent("UploadSuccess").OnClientEvent:Connect(function(metadata)
		-- Show success notification
		self:ShowNotification("Upload successful!", "success")
		-- Refresh current app
		if self.CurrentApp and self.Apps[self.CurrentApp].Refresh then
			self.Apps[self.CurrentApp].Refresh()
		end
	end)
	
	Network.getEvent("UploadFailed").OnClientEvent:Connect(function(errorMsg)
		self:ShowNotification(errorMsg or "Upload failed", "error")
	end)
	
	Network.getEvent("NewContent").OnClientEvent:Connect(function(metadata)
		-- Refresh feed if viewing that app
		if self.CurrentApp == metadata.appType and self.Apps[self.CurrentApp].AddContent then
			self.Apps[self.CurrentApp].AddContent(metadata)
		end
	end)
	
	print("✓ Phone Client initialized")
end

function PhoneClient:CreateHomeScreen()
	-- Home Screen Frame
	local home = CreateInstance("Frame", {
		Name = "HomeScreen",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = self.ScreenContainer
	})
	
	-- Time
	local timeLabel = CreateInstance("TextLabel", {
		Name = "Time",
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 20),
		Text = "12:00",
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Parent = home
	})
	
	spawn(function()
		while true do
			timeLabel.Text = os.date("%I:%M")
			task.wait(60)
		end
	end)
	
	-- App Grid
	local grid = CreateInstance("ScrollingFrame", {
		Name = "AppGrid",
		Size = UDim2.new(1, -20, 0, 400),
		Position = UDim2.new(0, 10, 0, 100),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		Parent = home
	})
	
	local layout = CreateInstance("UIGridLayout", {
		CellSize = UDim2.new(0, 70, 0, 90),
		CellPadding = UDim2.new(0, 20, 0, 20),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = grid
	})
	
	-- Create app buttons
	for appName, appConfig in pairs(Config.Apps) do
		local btn = CreateInstance("TextButton", {
			Name = appName.."Btn",
			Size = UDim2.new(0, 70, 0, 90),
			BackgroundTransparency = 1,
			Text = "",
			Parent = grid
		})
		
		local icon = CreateInstance("Frame", {
			Size = UDim2.new(0, 60, 0, 60),
			Position = UDim2.new(0.5, -30, 0, 0),
			BackgroundColor3 = appConfig.Color,
			BorderSizePixel = 0,
			Parent = btn
		})
		Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 15)
		
		CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = appConfig.Icon,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			BackgroundTransparency = 1,
			Parent = icon
		})
		
		CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 65),
			Text = appName,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			Font = Enum.Font.GothamMedium,
			BackgroundTransparency = 1,
			Parent = btn
		})
		
		btn.MouseButton1Click:Connect(function()
			self:SwitchToApp(appName)
		end)
	end
end

function PhoneClient:ShowNotification(text, type)
	-- Simple notification implementation
	local notif = CreateInstance("Frame", {
		Size = UDim2.new(0, 200, 0, 50),
		Position = UDim2.new(0.5, -100, 0, -60),
		BackgroundColor3 = type == "success" and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 50, 50),
		BorderSizePixel = 0,
		Parent = self.GUI
	})
	Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
	
	CreateInstance("TextLabel", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Parent = notif
	})
	
	Tween(notif, {Position = UDim2.new(0.5, -100, 0, 20)}, 0.3)
	task.wait(3)
	Tween(notif, {Position = UDim2.new(0.5, -100, 0, -60)}, 0.3)
	game.Debris:AddItem(notif, 0.35)
end

return PhoneClient