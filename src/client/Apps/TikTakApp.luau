-- StarterPlayerScripts/Client/Apps/TikTakApp.lua
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)
local Network = require(game.ReplicatedStorage.Shared.Network)

local TikTakApp = {}
TikTakApp.Screen = nil
TikTakApp.ContentFrame = nil
TikTakApp.Controller = nil

function TikTakApp:Initialize(parent, controller)
	self.Controller = controller
	
	-- Create App Screen (initially hidden)
	self.Screen = Instance.new("Frame")
	self.Screen.Name = "TikTakScreen"
	self.Screen.Size = UDim2.new(1, 0, 1, 0)
	self.Screen.BackgroundColor3 = Config.ScreenColor or Color3.fromRGB(10, 10, 15)
	self.Screen.Visible = false
	self.Screen.Parent = parent
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = Config.Apps.TikTak.Color
	header.BorderSizePixel = 0
	header.Parent = self.Screen
	
	local backBtn = Instance.new("TextButton")
	backBtn.Name = "Back"
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
	title.Text = "TikTak"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.BackgroundTransparency = 1
	title.Parent = header
	
	-- Content Frame
	self.ContentFrame = Instance.new("ScrollingFrame")
	self.ContentFrame.Name = "Content"
	self.ContentFrame.Size = UDim2.new(1, 0, 1, -50)
	self.ContentFrame.Position = UDim2.new(0, 0, 0, 50)
	self.ContentFrame.BackgroundTransparency = 1
	self.ContentFrame.ScrollBarThickness = 4
	self.ContentFrame.ScrollBarImageColor3 = Config.Apps.TikTak.Color
	self.ContentFrame.Parent = self.Screen
	
	-- Upload Button
	local uploadBtn = Instance.new("TextButton")
	uploadBtn.Size = UDim2.new(0, 60, 0, 60)
	uploadBtn.Position = UDim2.new(1, -80, 1, -140)
	uploadBtn.Text = "+"
	uploadBtn.TextColor3 = Color3.new(1, 1, 1)
	uploadBtn.TextSize = 32
	uploadBtn.Font = Enum.Font.GothamBold
	uploadBtn.BackgroundColor3 = Config.Apps.TikTak.Color
	uploadBtn.BorderSizePixel = 0
	uploadBtn.ZIndex = 10
	uploadBtn.Parent = self.Screen
	Instance.new("UICorner", uploadBtn).CornerRadius = UDim.new(1, 0)
	
	uploadBtn.MouseButton1Click:Connect(function()
		self:ShowUploadInterface()
	end)
	
	-- Load initial sample content
	self:LoadSampleContent()
end

function TikTakApp:OnShow()
	self.Screen.Visible = true
	self.Screen.Position = UDim2.new(1, 0, 0, 0)
	TweenService:Create(
		self.Screen,
		TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 0, 0, 0)}
	):Play()
end

function TikTakApp:OnHide()
	TweenService:Create(
		self.Screen,
		TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{Position = UDim2.new(1, 0, 0, 0)}
	):Play()
	task.wait(0.3)
	self.Screen.Visible = false
end

function TikTakApp:Close()
	self:OnHide()
	if self.Controller then
		self.Controller.CurrentApp = nil
	end
end

function TikTakApp:LoadSampleContent()
	-- Sample content for testing
	local sampleData = {
		{title = "Epic Dance Move #1", author = "dancer123", likes = 42, color = Config.Apps.TikTak.Color},
		{title = "New Trend!", author = "trendsetter", likes = 128, color = Color3.fromRGB(0, 255, 128)},
		{title = "How to vibe", author = "teacher", likes = 67, color = Color3.fromRGB(255, 165, 0)}
	}
	
	for i, data in ipairs(sampleData) do
		self:CreateContentCard(data, (i-1) * 210)
	end
	
	self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, #sampleData * 210 + 20)
end

function TikTakApp:CreateContentCard(data, yPos)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -20, 0, 200)
	card.Position = UDim2.new(0, 10, 0, yPos)
	card.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	card.BorderSizePixel = 0
	card.Parent = self.ContentFrame
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 15)
	
	-- Video Placeholder
	local video = Instance.new("Frame")
	video.Size = UDim2.new(1, 0, 0, 140)
	video.BackgroundColor3 = data.color
	video.BackgroundTransparency = 0.8
	video.BorderSizePixel = 0
	video.Parent = card
	Instance.new("UICorner", video).CornerRadius = UDim.new(0, 15)
	
	local playIcon = Instance.new("TextLabel")
	playIcon.Size = UDim2.new(0, 40, 0, 40)
	playIcon.Position = UDim2.new(0.5, -20, 0.5, -20)
	playIcon.Text = "▶"
	playIcon.TextColor3 = Color3.new(1, 1, 1)
	playIcon.TextSize = 24
	playIcon.Font = Enum.Font.GothamBold
	playIcon.BackgroundTransparency = 0.5
	playIcon.BackgroundColor3 = Color3.new(0, 0, 0)
	playIcon.Parent = video
	Instance.new("UICorner", playIcon).CornerRadius = UDim.new(1, 0)
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 25)
	title.Position = UDim2.new(0, 10, 0, 150)
	title.Text = data.title
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card
	
	-- Author & Likes
	local author = Instance.new("TextLabel")
	author.Size = UDim2.new(1, -20, 0, 20)
	author.Position = UDim2.new(0, 10, 0, 175)
	author.Text = "@" .. data.author .. " • " .. data.likes .. " likes"
	author.TextColor3 = Color3.fromRGB(180, 180, 180)
	author.TextSize = 14
	author.Font = Enum.Font.GothamMedium
	author.BackgroundTransparency = 1
	author.TextXAlignment = Enum.TextXAlignment.Left
	author.Parent = card
end

function TikTakApp:ShowUploadInterface()
	local modal = Instance.new("Frame")
	modal.Size = UDim2.new(1, -40, 0, 300)
	modal.Position = UDim2.new(0.5, 0, 0.5, 0)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	modal.BorderSizePixel = 0
	modal.ZIndex = 200
	modal.Parent = self.Controller.GUI
	Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 20)
	
	-- Overlay
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.ZIndex = 199
	overlay.Parent = self.Controller.GUI
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.Text = "Upload to TikTak"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.BackgroundTransparency = 1
	title.Parent = modal
	
	-- Title Input
	local titleBox = Instance.new("TextBox")
	titleBox.Size = UDim2.new(1, -40, 0, 40)
	titleBox.Position = UDim2.new(0, 20, 0, 60)
	titleBox.PlaceholderText = "Title..."
	titleBox.Text = ""
	titleBox.TextColor3 = Color3.new(1, 1, 1)
	titleBox.TextSize = 16
	titleBox.Font = Enum.Font.GothamMedium
	titleBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	titleBox.ClearTextOnFocus = false
	titleBox.Parent = modal
	Instance.new("UICorner", titleBox).CornerRadius = UDim.new(0, 10)
	
	-- Description
	local descBox = Instance.new("TextBox")
	descBox.Size = UDim2.new(1, -40, 0, 80)
	descBox.Position = UDim2.new(0, 20, 0, 110)
	descBox.PlaceholderText = "Description..."
	descBox.Text = ""
	descBox.TextColor3 = Color3.new(1, 1, 1)
	descBox.TextSize = 16
	descBox.Font = Enum.Font.GothamMedium
	descBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	descBox.MultiLine = true
	descBox.TextWrapped = true
	descBox.ClearTextOnFocus = false
	descBox.TextXAlignment = Enum.TextXAlignment.Left
	descBox.TextYAlignment = Enum.TextYAlignment.Top
	descBox.Parent = modal
	Instance.new("UICorner", descBox).CornerRadius = UDim.new(0, 10)
	
	-- Upload Button
	local uploadBtn = Instance.new("TextButton")
	uploadBtn.Size = UDim2.new(1, -40, 0, 45)
	uploadBtn.Position = UDim2.new(0, 20, 0, 210)
	uploadBtn.Text = "Upload"
	uploadBtn.TextColor3 = Color3.new(1, 1, 1)
	uploadBtn.TextSize = 18
	uploadBtn.Font = Enum.Font.GothamBold
	uploadBtn.BackgroundColor3 = Config.Apps.TikTak.Color
	uploadBtn.Parent = modal
	Instance.new("UICorner", uploadBtn).CornerRadius = UDim.new(0, 10)
	
	local function close()
		TweenService:Create(modal, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		task.wait(0.2)
		modal:Destroy()
		overlay:Destroy()
	end
	
	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			close()
		end
	end)
	
	uploadBtn.MouseButton1Click:Connect(function()
		if #titleBox.Text < 1 then return end
		
		-- Send to server
		Network.fireServer("UploadContent", "TikTak", {
			title = titleBox.Text,
			description = descBox.Text
		})
		
		close()
	end)
	
	-- Animate in
	modal.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(modal, TweenInfo.new(0.3, Enum.EasingStyle.Back), 
		{Size = UDim2.new(1, -40, 0, 300)}):Play()
end

return TikTakApp