--// Advanced Phone GUI System - Part 1 (Client)
--// Place this in StarterPlayer > StarterPlayerScripts as a LocalScript

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Configuration
local CONFIG = {
	PhoneColor = Color3.fromRGB(20, 20, 25),
	ScreenColor = Color3.fromRGB(10, 10, 15),
	AccentColor = Color3.fromRGB(0, 170, 255),
	NeonColor = Color3.fromRGB(255, 0, 128),
	TextColor = Color3.fromRGB(255, 255, 255),
	SecondaryText = Color3.fromRGB(180, 180, 180),
	AnimationSpeed = 0.4,
	PhoneSize = UDim2.new(0, 320, 0, 640),
	OpenPosition = UDim2.new(0.5, -160, 0.5, -320),
	ClosedPosition = UDim2.new(0.5, -160, 1.5, 0), -- Below screen
	ToggleButtonPos = UDim2.new(1, -120, 1, -80),
}

--// Main GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhoneSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

--// Utility Functions
local function CreateInstance(class, properties)
	local instance = Instance.new(class)
	for prop, value in pairs(properties) do
		instance[prop] = value
	end
	return instance
end

local function CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 20)
	corner.Parent = parent
	return corner
end

local function CreateShadow(parent)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://13131587293" -- Shadow asset
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(50, 50, 50, 50)
	shadow.Size = UDim2.new(1, 40, 1, 40)
	shadow.Position = UDim2.new(0, -20, 0, -20)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Parent = parent
	return shadow
end

local function Tween(object, properties, duration, easingStyle, easingDirection)
	local tween = TweenService:Create(
		object,
		TweenInfo.new(duration or CONFIG.AnimationSpeed, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out),
		properties
	)
	tween:Play()
	return tween
end

--// Phone Frame (Main Container)
local PhoneFrame = CreateInstance("Frame", {
	Name = "PhoneFrame",
	Size = CONFIG.PhoneSize,
	Position = CONFIG.ClosedPosition,
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = CONFIG.PhoneColor,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 100,
	Parent = ScreenGui,
})

CreateCorner(PhoneFrame, 40)
CreateShadow(PhoneFrame)

-- Phone Bezel/Notch
local Notch = CreateInstance("Frame", {
	Name = "Notch",
	Size = UDim2.new(0, 150, 0, 30),
	Position = UDim2.new(0.5, -75, 0, 0),
	BackgroundColor3 = CONFIG.PhoneColor,
	BorderSizePixel = 0,
	ZIndex = 101,
	Parent = PhoneFrame,
})
CreateCorner(Notch, 15)

local NotchCamera = CreateInstance("Frame", {
	Name = "Camera",
	Size = UDim2.new(0, 12, 0, 12),
	Position = UDim2.new(0.5, -6, 0.5, -6),
	BackgroundColor3 = Color3.fromRGB(10, 10, 10),
	BorderSizePixel = 0,
	ZIndex = 102,
	Parent = Notch,
})
CreateCorner(NotchCamera, 6)

-- Screen Container
local ScreenContainer = CreateInstance("Frame", {
	Name = "Screen",
	Size = UDim2.new(1, -20, 1, -40),
	Position = UDim2.new(0, 10, 0, 30),
	BackgroundColor3 = CONFIG.ScreenColor,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 100,
	Parent = PhoneFrame,
})
CreateCorner(ScreenContainer, 30)

--// Home Screen
local HomeScreen = CreateInstance("Frame", {
	Name = "HomeScreen",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Parent = ScreenContainer,
})

-- Wallpaper
local Wallpaper = CreateInstance("ImageLabel", {
	Name = "Wallpaper",
	Size = UDim2.new(1, 0, 1, 0),
	Image = "rbxassetid://12345678", -- Replace with your gradient/image
	BackgroundColor3 = Color3.fromRGB(15, 15, 20),
	ScaleType = Enum.ScaleType.Crop,
	Parent = HomeScreen,
})

-- Gradient Overlay
local Gradient = CreateInstance("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 15)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
	}),
	Rotation = 45,
	Parent = Wallpaper,
})

-- Time Display
local TimeLabel = CreateInstance("TextLabel", {
	Name = "Time",
	Size = UDim2.new(1, 0, 0, 60),
	Position = UDim2.new(0, 0, 0, 40),
	Text = "12:00",
	TextColor3 = CONFIG.TextColor,
	TextScaled = true,
	Font = Enum.Font.GothamBold,
	BackgroundTransparency = 1,
	Parent = HomeScreen,
})

-- Date Display
local DateLabel = CreateInstance("TextLabel", {
	Name = "Date",
	Size = UDim2.new(1, 0, 0, 25),
	Position = UDim2.new(0, 0, 0, 95),
	Text = "Monday, Jan 1",
	TextColor3 = CONFIG.SecondaryText,
	TextScaled = true,
	Font = Enum.Font.GothamMedium,
	BackgroundTransparency = 1,
	Parent = HomeScreen,
})

-- App Grid Container
local AppGrid = CreateInstance("ScrollingFrame", {
	Name = "AppGrid",
	Size = UDim2.new(1, -20, 0, 400),
	Position = UDim2.new(0, 10, 0, 140),
	BackgroundTransparency = 1,
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	CanvasSize = UDim2.new(0, 0, 0, 500),
	Parent = HomeScreen,
})

local GridLayout = CreateInstance("UIGridLayout", {
	CellSize = UDim2.new(0, 70, 0, 90),
	CellPadding = UDim2.new(0, 20, 0, 20),
	StartCorner = Enum.StartCorner.TopLeft,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	Parent = AppGrid,
})

--// App Creation Function
local Apps = {}
local CurrentApp = nil

local function CreateApp(name, iconColor, iconText, callback)
	local AppButton = CreateInstance("TextButton", {
		Name = name.."App",
		Size = UDim2.new(0, 70, 0, 90),
		BackgroundTransparency = 1,
		Text = "",
		Parent = AppGrid,
	})
	
	local IconBg = CreateInstance("Frame", {
		Name = "Icon",
		Size = UDim2.new(0, 60, 0, 60),
		Position = UDim2.new(0.5, -30, 0, 0),
		BackgroundColor3 = iconColor,
		BorderSizePixel = 0,
		Parent = AppButton,
	})
	CreateCorner(IconBg, 15)
	
	-- Neon glow effect
	local Glow = CreateInstance("ImageLabel", {
		Name = "Glow",
		Size = UDim2.new(1.4, 0, 1.4, 0),
		Position = UDim2.new(-0.2, 0, -0.2, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://13131587293",
		ImageColor3 = iconColor,
		ImageTransparency = 0.8,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(50, 50, 50, 50),
		ZIndex = IconBg.ZIndex - 1,
		Parent = IconBg,
	})
	
	local IconText = CreateInstance("TextLabel", {
		Name = "IconText",
		Size = UDim2.new(1, 0, 1, 0),
		Text = iconText,
		TextColor3 = CONFIG.TextColor,
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Parent = IconBg,
	})
	
	local AppName = CreateInstance("TextLabel", {
		Name = "AppName",
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 65),
		Text = name,
		TextColor3 = CONFIG.TextColor,
		TextScaled = true,
		Font = Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		Parent = AppButton,
	})
	
	AppButton.MouseButton1Click:Connect(function()
		-- Bounce animation
		Tween(IconBg, {Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0.5, -27.5, 0, 2.5)}, 0.1)
		task.wait(0.1)
		Tween(IconBg, {Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0.5, -30, 0, 0)}, 0.1)
		
		if callback then
			callback()
		end
	end)
	
	return AppButton
end

--// App Screens Container (For sliding)
local AppsContainer = CreateInstance("Frame", {
	Name = "AppsContainer",
	Size = UDim2.new(1, 0, 1, 0),
	Position = UDim2.new(1, 0, 0, 0), -- Hidden to right
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Parent = ScreenContainer,
})

-- Function to create app screen
local function CreateAppScreen(appName, accentColor)
	local Screen = CreateInstance("Frame", {
		Name = appName.."Screen",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = CONFIG.ScreenColor,
		BorderSizePixel = 0,
		Visible = false,
		Parent = AppsContainer,
	})
	
	-- Header
	local Header = CreateInstance("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = accentColor,
		BorderSizePixel = 0,
		Parent = Screen,
	})
	CreateCorner(Header, 0)
	
	local BackButton = CreateInstance("TextButton", {
		Name = "Back",
		Size = UDim2.new(0, 60, 0, 50),
		Text = "<",
		TextColor3 = CONFIG.TextColor,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Parent = Header,
	})
	
	local Title = CreateInstance("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -120, 0, 50),
		Position = UDim2.new(0, 60, 0, 0),
		Text = appName,
		TextColor3 = CONFIG.TextColor,
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Parent = Header,
	})
	
	-- Content Area
	local Content = CreateInstance("ScrollingFrame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 50),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = accentColor,
		CanvasSize = UDim2.new(0, 0, 2, 0),
		Parent = Screen,
	})
	
	-- Upload Button (Universal for all apps)
	local UploadButton = CreateInstance("TextButton", {
		Name = "UploadBtn",
		Size = UDim2.new(0, 60, 0, 60),
		Position = UDim2.new(1, -80, 1, -140),
		Text = "+",
		TextColor3 = CONFIG.TextColor,
		TextSize = 32,
		Font = Enum.Font.GothamBold,
		BackgroundColor3 = accentColor,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = Screen,
	})
	CreateCorner(UploadButton, 30)
	
	-- Upload button shadow
	local UploadShadow = CreateInstance("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 10, 1, 10),
		Position = UDim2.new(0, -5, 0, -5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://13131587293",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
		ZIndex = 9,
		Parent = UploadButton,
	})
	
	BackButton.MouseButton1Click:Connect(function()
		Tween(Screen, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		Screen.Visible = false
		CurrentApp = nil
	end)
	
	return Screen, Content, UploadButton
end

--// Create Apps
local TikTakScreen, TikTakContent, TikTakUpload = CreateAppScreen("TikTak", CONFIG.NeonColor)
local YouTozScreen, YouTozContent, YouTozUpload = CreateAppScreen("YouToz", Color3.fromRGB(255, 0, 0))
local DanceScreen, DanceContent, DanceUpload = CreateAppScreen("DanceVerse", Color3.fromRGB(138, 43, 226))

-- Populate TikTak (Social feed style)
local function CreateContentCard(parent, title, author, color)
	local Card = CreateInstance("Frame", {
		Size = UDim2.new(1, -20, 0, 200),
		Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 210),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		BorderSizePixel = 0,
		Parent = parent,
	})
	CreateCorner(Card, 15)
	
	local VideoPlaceholder = CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 140),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = Card,
	})
	CreateCorner(VideoPlaceholder, 15)
	
	local PlayIcon = CreateInstance("TextLabel", {
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(0.5, -20, 0.5, -20),
		Text = "▶",
		TextColor3 = CONFIG.TextColor,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(0, 0, 0),
		Parent = VideoPlaceholder,
	})
	CreateCorner(PlayIcon, 20)
	
	local Title = CreateInstance("TextLabel", {
		Size = UDim2.new(1, -20, 0, 25),
		Position = UDim2.new(0, 10, 0, 150),
		Text = title,
		TextColor3 = CONFIG.TextColor,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Card,
	})
	
	local Author = CreateInstance("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 175),
		Text = "@"..author,
		TextColor3 = CONFIG.SecondaryText,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Card,
	})
end

-- Add sample content
CreateContentCard(TikTakContent, "Epic Dance Move #1", "dancer123", CONFIG.NeonColor)
CreateContentCard(TikTakContent, "New Emote Drop!", "official_user", Color3.fromRGB(0, 255, 128))
CreateContentCard(TikTakContent, "Tutorial: How to vibe", "teacher_pro", Color3.fromRGB(255, 165, 0))

--// Toggle Button (Bottom Right)
local ToggleButton = CreateInstance("TextButton", {
	Name = "PhoneToggle",
	Size = UDim2.new(0, 110, 0, 45),
	Position = CONFIG.ToggleButtonPos,
	Text = "Open Phone",
	TextColor3 = CONFIG.TextColor,
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	BackgroundColor3 = CONFIG.AccentColor,
	BorderSizePixel = 0,
	ZIndex = 50,
	Parent = ScreenGui,
})
CreateCorner(ToggleButton, 22)

local ToggleShadow = CreateInstance("ImageLabel", {
	Name = "Shadow",
	Size = UDim2.new(1, 20, 1, 20),
	Position = UDim2.new(0, -10, 0, -10),
	BackgroundTransparency = 1,
	Image = "rbxassetid://13131587293",
	ImageColor3 = Color3.new(0, 0, 0),
	ImageTransparency = 0.6,
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(50, 50, 50, 50),
	ZIndex = 49,
	Parent = ToggleButton,
})

-- Close Button (Inside Phone)
local CloseButton = CreateInstance("TextButton", {
	Name = "ClosePhone",
	Size = UDim2.new(0, 40, 0, 40),
	Position = UDim2.new(0.5, -20, 1, -50),
	Text = "—",
	TextColor3 = CONFIG.TextColor,
	TextSize = 24,
	Font = Enum.Font.GothamBold,
	BackgroundColor3 = Color3.fromRGB(40, 40, 45),
	BorderSizePixel = 0,
	ZIndex = 102,
	Parent = PhoneFrame,
})
CreateCorner(CloseButton, 20)

--// App Click Handlers
CreateApp("TikTak", CONFIG.NeonColor, "♪", function()
	TikTakScreen.Visible = true
	TikTakScreen.Position = UDim2.new(1, 0, 0, 0)
	Tween(TikTakScreen, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
	CurrentApp = "TikTak"
end)

CreateApp("YouToz", Color3.fromRGB(255, 0, 0), "▶", function()
	YouTozScreen.Visible = true
	YouTozScreen.Position = UDim2.new(1, 0, 0, 0)
	Tween(YouTozScreen, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
	CurrentApp = "YouToz"
end)

CreateApp("Dance", Color3.fromRGB(138, 43, 226), "✦", function()
	DanceScreen.Visible = true
	DanceScreen.Position = UDim2.new(1, 0, 0, 0)
	Tween(DanceScreen, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
	CurrentApp = "Dance"
end)

CreateApp("Camera", Color3.fromRGB(100, 100, 100), "📷", function()
	-- Camera functionality placeholder
	print("Camera app opened")
end)

CreateApp("Gallery", Color3.fromRGB(50, 150, 255), "🖼", function()
	-- Gallery functionality placeholder
	print("Gallery app opened")
end)

CreateApp("Settings", Color3.fromRGB(80, 80, 80), "⚙", function()
	-- Settings functionality placeholder
	print("Settings app opened")
end)

--// Upload Functionality
local function ShowUploadInterface(appName)
	local UploadFrame = CreateInstance("Frame", {
		Name = "UploadInterface",
		Size = UDim2.new(1, -40, 0, 300),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(35, 35, 40),
		BorderSizePixel = 0,
		ZIndex = 200,
		Parent = ScreenGui,
	})
	CreateCorner(UploadFrame, 20)
	
	local Overlay = CreateInstance("Frame", {
		Name = "Overlay",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		ZIndex = 199,
		Parent = ScreenGui,
	})
	
	local Title = CreateInstance("TextLabel", {
		Size = UDim2.new(1, -20, 0, 40),
		Position = UDim2.new(0, 10, 0, 10),
		Text = "Upload to "..appName,
		TextColor3 = CONFIG.TextColor,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Parent = UploadFrame,
	})
	
	local DescriptionBox = CreateInstance("TextBox", {
		Size = UDim2.new(1, -40, 0, 100),
		Position = UDim2.new(0, 20, 0, 60),
		Text = "Enter description...",
		TextColor3 = CONFIG.SecondaryText,
		TextSize = 16,
		Font = Enum.Font.GothamMedium,
		BackgroundColor3 = Color3.fromRGB(25, 25, 30),
		ClearTextOnFocus = true,
		MultiLine = true,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = UploadFrame,
	})
	CreateCorner(DescriptionBox, 10)
	
	local UploadConfirm = CreateInstance("TextButton", {
		Size = UDim2.new(1, -40, 0, 45),
		Position = UDim2.new(0, 20, 0, 240),
		Text = "Upload Content",
		TextColor3 = CONFIG.TextColor,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		BackgroundColor3 = CONFIG.AccentColor,
		BorderSizePixel = 0,
		Parent = UploadFrame,
	})
	CreateCorner(UploadConfirm, 10)
	
	-- Animate in
	UploadFrame.Size = UDim2.new(0, 0, 0, 0)
	Tween(UploadFrame, {Size = UDim2.new(1, -40, 0, 300)}, 0.3, Enum.EasingStyle.Back)
	
	local function CloseUpload()
		Tween(UploadFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
		Tween(Overlay, {BackgroundTransparency = 1}, 0.2)
		task.wait(0.2)
		UploadFrame:Destroy()
		Overlay:Destroy()
	end
	
	Overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			CloseUpload()
		end
	end)
	
	UploadConfirm.MouseButton1Click:Connect(function()
		-- Here you would fire a remote event to server
		print("Uploading content:", DescriptionBox.Text, "to", appName)
		
		-- Visual feedback
		UploadConfirm.Text = "✓ Uploaded!"
		UploadConfirm.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
		task.wait(1)
		CloseUpload()
	end)
end

TikTakUpload.MouseButton1Click:Connect(function() ShowUploadInterface("TikTak") end)
YouTozUpload.MouseButton1Click:Connect(function() ShowUploadInterface("YouToz") end)
DanceUpload.MouseButton1Click:Connect(function() ShowUploadInterface("DanceVerse") end)

--// Phone Toggle Logic
local IsOpen = false

local function OpenPhone()
	IsOpen = true
	ToggleButton.Text = "Close Phone"
	ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	Tween(PhoneFrame, {Position = CONFIG.OpenPosition}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	Tween(ToggleButton, {Position = UDim2.new(1, -120, 1, -20)}, 0.3) -- Move up slightly
end

local function ClosePhone()
	IsOpen = false
	ToggleButton.Text = "Open Phone"
	ToggleButton.BackgroundColor3 = CONFIG.AccentColor
	
	-- Close any open apps first
	if CurrentApp then
		for _, screen in pairs(AppsContainer:GetChildren()) do
			if screen:IsA("Frame") and screen.Visible then
				Tween(screen, {Position = UDim2.new(1, 0, 0, 0)}, 0.2)
			end
		end
		task.wait(0.2)
		for _, screen in pairs(AppsContainer:GetChildren()) do
			screen.Visible = false
		end
		CurrentApp = nil
	end
	
	Tween(PhoneFrame, {Position = CONFIG.ClosedPosition}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	Tween(ToggleButton, {Position = CONFIG.ToggleButtonPos}, 0.3)
end

ToggleButton.MouseButton1Click:Connect(function()
	if IsOpen then
		ClosePhone()
	else
		OpenPhone()
	end
end)

CloseButton.MouseButton1Click:Connect(ClosePhone)

--// Time Update
local function UpdateTime()
	local timeString = os.date("%I:%M")
	local dateString = os.date("%A, %b %d")
	TimeLabel.Text = timeString
	DateLabel.Text = dateString
end

spawn(function()
	while true do
		UpdateTime()
		task.wait(60)
	end
end)

UpdateTime()

--// Drag Functionality for Phone (Optional)
local Dragging = false
local DragStart = nil
local StartPos = nil

PhoneFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPos = PhoneFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - DragStart
		PhoneFrame.Position = UDim2.new(
			StartPos.X.Scale, 
			StartPos.X.Offset + delta.X, 
			StartPos.Y.Scale, 
			StartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = false
	end
end)

--// Swipe Detection for Apps (Slidable GUI)
local TouchStart = nil
local MinSwipeDistance = 50

ScreenContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		TouchStart = input.Position
	end
end)

ScreenContainer.InputEnded:Connect(function(input)
	if not TouchStart then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local delta = input.Position.X - TouchStart.X
		if math.abs(delta) > MinSwipeDistance then
			if delta < 0 and not CurrentApp then
				-- Swipe left on home - could open app drawer
				print("Swipe left detected")
			elseif delta > 0 and CurrentApp then
				-- Swipe right to go back
				if CurrentApp == "TikTak" then
					TikTakScreen.Back.MouseButton1Click:Fire()
				elseif CurrentApp == "YouToz" then
					YouTozScreen.Back.MouseButton1Click:Fire()
				elseif CurrentApp == "Dance" then
					DanceScreen.Back.MouseButton1Click:Fire()
				end
			end
		end
		TouchStart = nil
	end
end)

print("✓ Advanced Phone System Loaded - Part 1 Complete")