-- StarterPlayerScripts/Client/Apps/DanceApp.lua
local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage.Shared.Config)

local DanceApp = {}
DanceApp.Screen = nil
DanceApp.Controller = nil

function DanceApp:Initialize(parent, controller)
	self.Controller = controller
	
	self.Screen = Instance.new("Frame")
	self.Screen.Name = "DanceScreen"
	self.Screen.Size = UDim2.new(1, 0, 1, 0)
	self.Screen.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	self.Screen.Visible = false
	self.Screen.Parent = parent
	
	-- Header (Purple theme)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = Config.Apps.DanceVerse.Color
	header.BorderSizePixel = 0
	header.Parent = self.Screen
	
	local backBtn = Instance.new("TextButton")
	backBtn.Size = UDim2.new(0, 50, 1, 0)
	backBtn.Text = "<"
	backBtn.TextColor3 = Color3.new(1, 1, 1)
	backBtn.TextSize = 24
	backBtn.Font = Enum.Font.GothamBold
	backBtn.BackgroundTransparency = 1
	backBtn.Parent = header
	
	backBtn.MouseButton1Click:Connect(function()
		self:Close()
	end)
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 50, 0, 0)
	title.Text = "DanceVerse"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.BackgroundTransparency = 1
	title.Parent = header
	
	-- Dance Feed
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, 0, 1, -50)
	content.Position = UDim2.new(0, 0, 0, 50)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 4
	content.Parent = self.Screen
	
	-- Sample Dance Cards
	local dances = {
		{ name = "Freestyle Friday", dancer = "MoveMaster", color = Color3.fromRGB(138, 43, 226) },
		{ name = "Choreo Battle", dancer = "ProDancer", color = Color3.fromRGB(255, 0, 255) },
		{ name = "New Emote", dancer = "AnimationKing", color = Color3.fromRGB(75, 0, 130) }
	}
	
	for i, dance in ipairs(dances) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -20, 0, 200)
		card.Position = UDim2.new(0, 10, 0, (i-1) * 210)
		card.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		card.Parent = content
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 15)
		
		-- Dance Preview Area
		local preview = Instance.new("Frame")
		preview.Size = UDim2.new(1, 0, 0, 140)
		preview.BackgroundColor3 = dance.color
		preview.BackgroundTransparency = 0.7
		preview.Parent = card
		Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 15)
		
		-- Dance Icon
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 60, 0, 60)
		icon.Position = UDim2.new(0.5, -30, 0.5, -30)
		icon.Text = "💃"
		icon.TextSize = 40
		icon.BackgroundTransparency = 1
		icon.Parent = preview
		
		-- Title
		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, -20, 0, 25)
		t.Position = UDim2.new(0, 10, 0, 150)
		t.Text = dance.name
		t.TextColor3 = Color3.new(1, 1, 1)
		t.TextSize = 18
		t.Font = Enum.Font.GothamBold
		t.BackgroundTransparency = 1
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = card
		
		-- Dancer name
		local d = Instance.new("TextLabel")
		d.Size = UDim2.new(1, -20, 0, 20)
		d.Position = UDim2.new(0, 10, 0, 175)
		d.Text = "@" .. dance.dancer
		d.TextColor3 = Color3.fromRGB(180, 180, 180)
		d.TextSize = 14
		d.Font = Enum.Font.GothamMedium
		d.BackgroundTransparency = 1
		d.TextXAlignment = Enum.TextXAlignment.Left
		d.Parent = card
	end
	
	content.CanvasSize = UDim2.new(0, 0, 0, #dances * 210 + 20)
	
	-- Upload Button
	local uploadBtn = Instance.new("TextButton")
	uploadBtn.Size = UDim2.new(0, 60, 0, 60)
	uploadBtn.Position = UDim2.new(1, -80, 1, -140)
	uploadBtn.Text = "+"
	uploadBtn.TextColor3 = Color3.new(1, 1, 1)
	uploadBtn.TextSize = 32
	uploadBtn.Font = Enum.Font.GothamBold
	uploadBtn.BackgroundColor3 = Config.Apps.DanceVerse.Color
	uploadBtn.Parent = self.Screen
	Instance.new("UICorner", uploadBtn).CornerRadius = UDim.new(1, 0)
end

function DanceApp:OnShow()
	self.Screen.Visible = true
	self.Screen.Position = UDim2.new(1, 0, 0, 0)
	TweenService:Create(self.Screen, TweenInfo.new(0.3, Enum.EasingStyle.Quart), 
		{Position = UDim2.new(0, 0, 0, 0)}):Play()
end

function DanceApp:OnHide()
	TweenService:Create(self.Screen, TweenInfo.new(0.3, Enum.EasingStyle.Quart), 
		{Position = UDim2.new(1, 0, 0, 0)}):Play()
	task.wait(0.3)
	self.Screen.Visible = false
end

function DanceApp:Close()
	self:OnHide()
	if self.Controller then
		self.Controller.CurrentApp = nil
	end
end

return DanceApp