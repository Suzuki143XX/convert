-- StarterPlayerScripts/Client/Apps/YouTozApp.lua
local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage.Shared.Config)
local Network = require(game.ReplicatedStorage.Shared.Network)

local YouTozApp = {}
YouTozApp.Screen = nil
YouTozApp.Controller = nil

function YouTozApp:Initialize(parent, controller)
	self.Controller = controller
	
	self.Screen = Instance.new("Frame")
	self.Screen.Name = "YouTozScreen"
	self.Screen.Size = UDim2.new(1, 0, 1, 0)
	self.Screen.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	self.Screen.Visible = false
	self.Screen.Parent = parent
	
	-- Header (Red theme)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = Config.Apps.YouToz.Color
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
	title.Text = "YouToz"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.BackgroundTransparency = 1
	title.Parent = header
	
	-- Content
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, 0, 1, -50)
	content.Position = UDim2.new(0, 0, 0, 50)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 4
	content.Parent = self.Screen
	
	-- Sample Video Cards
	for i = 1, 3 do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -20, 0, 180)
		card.Position = UDim2.new(0, 10, 0, (i-1) * 190)
		card.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		card.Parent = content
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
		
		local thumb = Instance.new("Frame")
		thumb.Size = UDim2.new(1, 0, 0, 120)
		thumb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		thumb.Parent = card
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 12)
		
		local play = Instance.new("TextLabel")
		play.Size = UDim2.new(0, 50, 0, 50)
		play.Position = UDim2.new(0.5, -25, 0.5, -25)
		play.Text = "▶"
		play.TextColor3 = Color3.new(1, 1, 1)
		play.TextSize = 30
		play.Font = Enum.Font.GothamBold
		play.BackgroundTransparency = 0.5
		play.BackgroundColor3 = Color3.new(0, 0, 0)
		play.Parent = thumb
		Instance.new("UICorner", play).CornerRadius = UDim.new(1, 0)
		
		local vidTitle = Instance.new("TextLabel")
		vidTitle.Size = UDim2.new(1, -20, 0, 30)
		vidTitle.Position = UDim2.new(0, 10, 0, 130)
		vidTitle.Text = "Gaming Video #" .. i
		vidTitle.TextColor3 = Color3.new(1, 1, 1)
		vidTitle.TextSize = 18
		vidTitle.Font = Enum.Font.GothamBold
		vidTitle.BackgroundTransparency = 1
		vidTitle.TextXAlignment = Enum.TextXAlignment.Left
		vidTitle.Parent = card
		
		local views = Instance.new("TextLabel")
		views.Size = UDim2.new(1, -20, 0, 20)
		views.Position = UDim2.new(0, 10, 0, 155)
		views.Text = math.random(1, 999) .. "K views • " .. math.random(1, 12) .. " hours ago"
		views.TextColor3 = Color3.fromRGB(180, 180, 180)
		views.TextSize = 14
		views.Font = Enum.Font.GothamMedium
		views.BackgroundTransparency = 1
		views.TextXAlignment = Enum.TextXAlignment.Left
		views.Parent = card
	end
	
	content.CanvasSize = UDim2.new(0, 0, 0, 600)
	
	-- Upload Button
	local uploadBtn = Instance.new("TextButton")
	uploadBtn.Size = UDim2.new(0, 60, 0, 60)
	uploadBtn.Position = UDim2.new(1, -80, 1, -140)
	uploadBtn.Text = "+"
	uploadBtn.TextColor3 = Color3.new(1, 1, 1)
	uploadBtn.TextSize = 32
	uploadBtn.Font = Enum.Font.GothamBold
	uploadBtn.BackgroundColor3 = Config.Apps.YouToz.Color
	uploadBtn.Parent = self.Screen
	Instance.new("UICorner", uploadBtn).CornerRadius = UDim.new(1, 0)
end

function YouTozApp:OnShow()
	self.Screen.Visible = true
	self.Screen.Position = UDim2.new(1, 0, 0, 0)
	TweenService:Create(self.Screen, TweenInfo.new(0.3, Enum.EasingStyle.Quart), 
		{Position = UDim2.new(0, 0, 0, 0)}):Play()
end

function YouTozApp:OnHide()
	TweenService:Create(self.Screen, TweenInfo.new(0.3, Enum.EasingStyle.Quart), 
		{Position = UDim2.new(1, 0, 0, 0)}):Play()
	task.wait(0.3)
	self.Screen.Visible = false
end

function YouTozApp:Close()
	self:OnHide()
	if self.Controller then
		self.Controller.CurrentApp = nil
	end
end

return YouTozApp