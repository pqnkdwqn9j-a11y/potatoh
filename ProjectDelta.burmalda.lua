local __burmaldaProjectDeltaEnv = getgenv and getgenv() or _G
local __burmaldaProjectDeltaGame = tostring(__burmaldaProjectDeltaEnv.BURMALDA_GAME or ""):match("^%s*(.-)%s*$")
local __burmaldaProjectDeltaKey = tostring(__burmaldaProjectDeltaEnv.SCRIPT_KEY or ""):match("^%s*(.-)%s*$")
if game.PlaceId ~= 7336302630
    or __burmaldaProjectDeltaGame ~= "project delta"
    or tostring(__burmaldaProjectDeltaEnv.PHOOKGATE or "") ~= "1347571535"
    or __burmaldaProjectDeltaKey == ""
    or __burmaldaProjectDeltaKey:upper() == "BETA"
then
    __burmaldaProjectDeltaEnv.PHOOKGATE = nil
    __burmaldaProjectDeltaEnv.SCRIPT_KEY = nil
    __burmaldaProjectDeltaEnv.BURMALDA_GAME = nil
    return
end
__burmaldaProjectDeltaEnv.PHOOKGATE = nil
__burmaldaProjectDeltaEnv.SCRIPT_KEY = nil
__burmaldaProjectDeltaEnv.BURMALDA_GAME = nil

local Env = getgenv and getgenv() or _G
if Env.BurmaldaProjectDelta and Env.BurmaldaProjectDelta.Unload then
	pcall(Env.BurmaldaProjectDelta.Unload)
end

local executorName = "unknown"
if type(identifyexecutor) == "function" then
	local ok, name = pcall(identifyexecutor)
	if ok and name ~= nil then executorName = tostring(name) end
elseif type(getexecutorname) == "function" then
	local ok, name = pcall(getexecutorname)
	if ok and name ~= nil then executorName = tostring(name) end
end

if string.find(string.lower(executorName), "xeno", 1, true) then return end
local supported = false
for _, name in ipairs({ "Real", "Opiumware", "Madium", "Potassium", "Synapse Z", "Volt", "Volcano" }) do
	if string.find(string.lower(executorName), string.lower(name), 1, true) then supported = true break end
end
if not supported then return end
if game.PlaceId ~= 7336302630 then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Runtime = {
	Unloaded = false,
	Ready = false,
	Connections = {},
	Drawings = {},
	Guis = {},
	Owned = {},
	MenuOpen = true,
	TabNames = { "COMBAT", "VISUALS", "MOVEMENT", "MISC", "CONFIG" },
	PlaceId = 7336302630,
	SupportedExecutors = { "Real", "Opiumware", "Madium", "Potassium", "Synapse Z", "Volt", "Volcano", "Solara" },
}
Env.BurmaldaProjectDelta = Runtime

local State = {
	Aimbot = false,
	AimFOV = 180,
	AimRange = 1200,
	AimSmoothing = 8,
	AimPart = "Head",
	AimTeamCheck = false,
	AimWallCheck = false,
	AimVisibleOnly = false,
	AimNPCs = false,
	AimPrediction = false,
	BulletSpeed = 1000,
	FOVCircle = false,
	TargetLine = false,
	PlayerESP = false,
	NPCESP = false,
	LootESP = false,
	ShowNames = false,
	ShowHealth = false,
	ShowDistance = false,
	ShowBoxes = false,
	ShowTracers = false,
	TeamColors = false,
	ESPRange = 600,
	ESPUpdateRate = 20,
	Speed = false,
	SpeedValue = 30,
	Fly = false,
	FlySpeed = 60,
	Noclip = false,
	InfiniteJump = false,
	Freecam = false,
	FreecamSpeed = 60,
	TeleportMouse = false,
	FullBright = false,
	RemoveFog = false,
	HideGrass = false,
	LowPC = false,
	BuildingXRay = false,
	CustomFOV = false,
	FOVValue = 90,
	StatsHUD = false,
	MenuAccent = false,
	UIAnimations = false,
	SilentAim = false,
	HitChance = 100,
	AimStrength = 8,
	PredictionStrength = 1,
	SkipPlayers = false,
	SkipBandits = false,
	TargetHighlight = false,
	TargetIndicator = false,
	Crosshair = false,
	ContainerESP = false,
	CrateESP = false,
	ExtractionESP = false,
	LandmineESP = false,
	CorpseESP = false,
	QuestItemESP = false,
	BotESP = false,
	InventoryESP = false,
	LootFilter = "All",
	ESPTransparency = 100,
	ESPTextSize = 13,
	ColourPlayer = "White",
	ColourNPC = "White",
	ColourLoot = "White",
	ColourContainer = "White",
	ColourExtraction = "White",
	ColourMine = "White",
	ColourCorpse = "White",
	ShowWeapon = false,
	WallcheckESP = false,
	HighlightESP = false,
	NightMode = false,
	NoShadow = false,
	AntiAFK = false,
	AutoRejoin = false,
	JumpBoost = false,
	JumpValue = 50,
	AntiAim = false,
	AntiAimMode = "Under Ground",
	AntiAimDepth = 3,
	AntiAimSpin = 180,
}
Runtime.State = State

local Binds = {
	Aimbot = "None",
	Fly = "None",
	Noclip = "None",
	Freecam = "None",
	TeleportMouse = "None",
	AntiAim = "None",
	TeleportExtraction = "None",
}
Runtime.Binds = Binds

local ConfigPath = "burmalda/project_delta_config.json"
local ConfigControls = {}
local FeatureHandlers = {}
local SettingHandlers = {}
local EspObjects = {}
local EspConnections = {}
local OriginalLighting = {}
local OriginalGrass = {}
local OriginalTerrainDecoration = Workspace.Terrain and Workspace.Terrain.Decoration or nil
local OriginalXRay = {}
local OriginalFOV = Camera and Camera.FieldOfView or 90
local OriginalGravity = Workspace.Gravity
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local OriginalJumpHeight = 7.2
local OriginalCameraType = Camera and Camera.CameraType or nil
local OriginalCameraCFrame = Camera and Camera.CFrame or nil
local OriginalCameraSubject = Camera and Camera.CameraSubject or nil

local function fromRGB(r, g, b)
	if Color3.fromRGB then return Color3.fromRGB(r, g, b) end
	return Color3.new(r / 255, g / 255, b / 255)
end

local function applyTerrainDecoration()
	if not Workspace.Terrain or OriginalTerrainDecoration == nil then return end
	if State.HideGrass or State.LowPC then
		Workspace.Terrain.Decoration = false
	else
		Workspace.Terrain.Decoration = OriginalTerrainDecoration
	end
end

local function trackConnection(connection)
	if connection then Runtime.Connections[#Runtime.Connections + 1] = connection end
	return connection
end

local function trackDrawing(object)
	if object then Runtime.Drawings[object] = true end
	return object
end

local function trackGui(object)
	if object then Runtime.Guis[object] = true end
	return object
end

local function onCleanup(callback)
	if type(callback) == "function" then Runtime.Owned[#Runtime.Owned + 1] = callback end
end

local function newScreenGui(name)
	local parent
	if type(gethui) == "function" then
		pcall(function() parent = gethui() end)
	end
	if not parent then parent = LocalPlayer:WaitForChild("PlayerGui") end
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999990
	gui.Parent = parent
	return trackGui(gui)
end

local sg = newScreenGui("BurmaldaHookProjectDelta")
local hudGui = newScreenGui("BurmaldaHookProjectDeltaStats")

local Theme = {
	Background = fromRGB(8, 8, 8),
	Inline = fromRGB(12, 12, 12),
	Element = fromRGB(19, 19, 19),
	Border = fromRGB(40, 40, 40),
	Text = fromRGB(242, 242, 242),
	SubText = fromRGB(150, 150, 150),
	Accent = fromRGB(255, 255, 255),
	Red = fromRGB(237, 105, 105),
	Green = fromRGB(105, 237, 150),
}

local main = Instance.new("Frame", sg)
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 621, 0, 542)
main.Visible = true
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 2
main.ClipsDescendants = true
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Name = "BurmaldaAccent"
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Theme.Inline
header.BorderSizePixel = 0
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Burmalda.hook | Project Delta"
title.TextColor3 = Theme.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -30, 0, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Theme.SubText
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16

local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 30)
tabBar.BackgroundColor3 = Theme.Inline
tabBar.BorderSizePixel = 0
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 1)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -60)
content.Position = UDim2.new(0, 0, 0, 60)
content.BackgroundTransparency = 1

local tabButtons = {}
local tabFrames = {}
local Columns = {}
for i, name in ipairs(Runtime.TabNames) do
	local button = Instance.new("TextButton", tabBar)
	button.Name = name
	button.Size = UDim2.new(0, 123, 1, 0)
	button.BackgroundColor3 = Theme.Element
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = Theme.SubText
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 12
	button.LayoutOrder = i
	tabButtons[name] = button
	local frame = Instance.new("ScrollingFrame", content)
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ScrollBarThickness = 4
	frame.ScrollingEnabled = true
	frame.Visible = i == 1
	tabFrames[name] = frame
	local columns = Instance.new("Frame", frame)
	columns.Size = UDim2.new(1, 0, 1, 0)
	columns.BackgroundTransparency = 1
	local left = Instance.new("Frame", columns)
	left.Size = UDim2.new(0.5, -6, 1, 0)
	left.Position = UDim2.new(0, 6, 0, 0)
	left.BackgroundTransparency = 1
	local right = Instance.new("Frame", columns)
	right.Size = UDim2.new(0.5, -6, 1, 0)
	right.Position = UDim2.new(0.5, 0, 0, 0)
	right.BackgroundTransparency = 1
	Columns[frame] = { Left = left, Right = right }
	button.MouseButton1Click:Connect(function()
		for _, tab in pairs(tabFrames) do tab.Visible = false end
		for _, btn in pairs(tabButtons) do btn.TextColor3 = Theme.SubText end
		frame.Visible = true
		button.TextColor3 = Theme.Accent
	end)
end
tabButtons.COMBAT.TextColor3 = Theme.Accent

local activeSection = nil
local function section(parent, name)
	local holder = Instance.new("Frame", parent)
	holder.Size = UDim2.new(1, 0, 0, 25)
	holder.BackgroundColor3 = Theme.Inline
	holder.BorderSizePixel = 0
	local label = Instance.new("TextLabel", holder)
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Theme.SubText
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 12
	activeSection = holder
	return holder
end

local function nextPosition(parent)
	local count = 0
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextButton") then count += 1 end
	end
	return UDim2.new(0, 0, 0, count * 30)
end

local function feature(tabName, column, label, key, callback)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new("TextLabel", row)
	text.Size = UDim2.new(1, -92, 1, 0)
	text.Position = UDim2.new(0, 8, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 12
	local button = Instance.new("TextButton", row)
	button.Size = UDim2.new(0, 76, 0, 20)
	button.Position = UDim2.new(1, -80, 0.5, -10)
	button.BackgroundColor3 = Theme.Inline
	button.BorderSizePixel = 0
	button.Text = State[key] == true and "On" or "Off"
	button.TextColor3 = State[key] == true and Theme.Green or Theme.SubText
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 11
	local handler = {
		Key = key,
		Set = function(_, value)
			State[key] = value == true
			button.Text = State[key] and "On" or "Off"
			button.TextColor3 = State[key] and Theme.Green or Theme.SubText
			if type(callback) == "function" then callback(State[key]) end
		end,
		Get = function() return State[key] end,
	}
	FeatureHandlers[label] = handler
	SettingHandlers[key] = function(value) handler:Set(value) end
	button.MouseButton1Click:Connect(function() handler:Set(not State[key]) end)
	return row
end

local function slider(tabName, column, label, key, minimum, maximum, callback)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, 0, 0, 34)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new("TextLabel", row)
	text.Size = UDim2.new(1, -10, 0, 14)
	text.Position = UDim2.new(0, 8, 0, 2)
	text.BackgroundTransparency = 1
	text.Text = label .. ": " .. tostring(State[key])
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 11
	local fill = Instance.new("Frame", row)
	fill.Size = UDim2.new(0, 0, 0, 6)
	fill.Position = UDim2.new(0, 8, 0, 22)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	local function apply(value)
		local number = math.clamp(tonumber(value) or State[key], minimum, maximum)
		State[key] = number
		text.Text = label .. ": " .. tostring(math.floor(number * 100) / 100)
		fill.Size = UDim2.new((number - minimum) / (maximum - minimum), 0, 0, 6)
		if type(callback) == "function" then callback(number) end
	end
	ConfigControls[key] = apply
	row.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local moving = true
		local function update(position)
			local relative = math.clamp((position.X - row.AbsolutePosition.X - 8) / (row.AbsoluteSize.X - 16), 0, 1)
			apply(minimum + relative * (maximum - minimum))
		end
		update(Vector2.new(input.Position.X, input.Position.Y))
		local changed
		changed = UserInputService.InputChanged:Connect(function(changedInput)
			if not moving then return end
			if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
				update(Vector2.new(changedInput.Position.X, changedInput.Position.Y))
			end
		end)
		local ended
		ended = UserInputService.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
				moving = false
				if changed then changed:Disconnect() end
				if ended then ended:Disconnect() end
			end
		end)
	end)
	return row
end

local function dropdown(tabName, column, label, key, options, callback)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new("TextLabel", row)
	text.Size = UDim2.new(1, -100, 1, 0)
	text.Position = UDim2.new(0, 8, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 12
	local button = Instance.new("TextButton", row)
	button.Size = UDim2.new(0, 88, 0, 20)
	button.Position = UDim2.new(1, -92, 0.5, -10)
	button.BackgroundColor3 = Theme.Inline
	button.BorderSizePixel = 0
	button.Text = tostring(State[key])
	button.TextColor3 = Theme.SubText
	button.Font = Enum.Font.SourceSans
	button.TextSize = 11
	local index = 1
	for i, option in ipairs(options) do
		if option == State[key] then index = i end
	end
	local function apply(value)
		State[key] = value
		button.Text = tostring(value)
		if type(callback) == "function" then callback(value) end
	end
	ConfigControls[key] = apply
	button.MouseButton1Click:Connect(function()
		index = index % #options + 1
		apply(options[index])
	end)
	return row
end

local function bind(tabName, column, label, key, callback)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new("TextLabel", row)
	text.Size = UDim2.new(1, -100, 1, 0)
	text.Position = UDim2.new(0, 8, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 12
	local button = Instance.new("TextButton", row)
	button.Size = UDim2.new(0, 88, 0, 20)
	button.Position = UDim2.new(1, -92, 0.5, -10)
	button.BackgroundColor3 = Theme.Inline
	button.BorderSizePixel = 0
	button.Text = Binds[key]
	button.TextColor3 = Theme.SubText
	button.Font = Enum.Font.SourceSans
	button.TextSize = 11
	local picking = false
	local function apply(value)
		Binds[key] = value
		button.Text = value
	end
	ConfigControls[key .. "Bind"] = apply
	button.MouseButton1Click:Connect(function()
		picking = true
		button.Text = "..."
		button.TextColor3 = Theme.Accent
	end)
	trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
		if not picking or processed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			apply(input.KeyCode.Name)
			picking = false
			button.TextColor3 = Theme.SubText
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			apply("RMB")
			picking = false
			button.TextColor3 = Theme.SubText
		end
	end))
	return row
end

local function button(tabName, column, label, callback)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new("TextButton", parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	row.Text = label
	row.TextColor3 = Theme.Text
	row.Font = Enum.Font.SourceSansBold
	row.TextSize = 12
	row.MouseButton1Click:Connect(function()
		if type(callback) == "function" then pcall(callback) end
	end)
	return row
end

local function newEspText()
	local wrapper = {}
	local drawing
	local label
	if Drawing and type(Drawing.new) == "function" then
		drawing = Drawing.new("Text")
		drawing.Center = true
		drawing.Outline = true
		drawing.Font = 2
		drawing.Size = 13
		drawing.Visible = false
		trackDrawing(drawing)
	else
		label = Instance.new("TextLabel", sg)
		label.BackgroundTransparency = 1
		label.TextColor3 = Theme.Text
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 12
		label.Visible = false
	end
	function wrapper:Show(text, position, color)
		if Runtime.Unloaded then return end
		if drawing then
			drawing.Text = text
			drawing.Position = position
			drawing.Color = color or Theme.Text
			drawing.Size = State.ESPTextSize
			drawing.Transparency = State.ESPTransparency / 100
			drawing.Visible = true
		elseif label then
			label.Text = text
			label.Position = UDim2.new(0, position.X, 0, position.Y)
			label.TextColor3 = color or Theme.Text
			label.TextSize = State.ESPTextSize
			label.TextTransparency = 1 - State.ESPTransparency / 100
			label.Visible = true
		end
	end
	function wrapper:Hide()
		if drawing then drawing.Visible = false end
		if label then label.Visible = false end
	end
	function wrapper:Remove()
		if drawing and drawing.Remove then pcall(drawing.Remove, drawing) end
		if label then label:Destroy() end
		Runtime.Drawings[drawing] = nil
	end
	return wrapper
end

local function newEspLine()
	local wrapper = {}
	local drawing
	local line
	if Drawing and type(Drawing.new) == "function" then
		drawing = Drawing.new("Line")
		drawing.Thickness = 1
		drawing.Visible = false
		trackDrawing(drawing)
	else
		line = Instance.new("Frame", sg)
		line.BackgroundColor3 = Theme.Text
		line.BorderSizePixel = 0
		line.Visible = false
	end
	function wrapper:Show(from, to, color)
		if Runtime.Unloaded then return end
		if drawing then
			drawing.From = from
			drawing.To = to
			drawing.Color = color or Theme.Text
			drawing.Transparency = State.ESPTransparency / 100
			drawing.Visible = true
		elseif line then
			local delta = to - from
			local length = math.max(1, delta.Magnitude)
			line.Size = UDim2.new(0, length, 0, 1)
			line.Position = UDim2.new(0, from.X, 0, from.Y)
			line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			line.BackgroundColor3 = color or Theme.Text
			line.Visible = true
		end
	end
	function wrapper:Hide()
		if drawing then drawing.Visible = false end
		if line then line.Visible = false end
	end
	function wrapper:Remove()
		if drawing and drawing.Remove then pcall(drawing.Remove, drawing) end
		if line then line:Destroy() end
		Runtime.Drawings[drawing] = nil
	end
	return wrapper
end

local function getRoot(model)
	if not model then return nil end
	return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model.PrimaryPart
end

local function getHumanoid(model)
	if not model then return nil end
	return model:FindFirstChildOfClass("Humanoid")
end

local function isTeammate(player)
	if not State.AimTeamCheck then return false end
	if not LocalPlayer.Team or not player.Team then return false end
	return LocalPlayer.Team == player.Team
end

local function isVisible(point, model)
	if not State.AimWallCheck or not Camera then return true end
	local origin = Camera.CFrame.Position
	local direction = point - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { LocalPlayer.Character, model }
	local result = Workspace:Raycast(origin, direction, params)
	return result == nil
end

local function predictedPosition(root, enabled)
	if not enabled or not root then return root and root.Position or nil end
	local velocity = root.AssemblyLinearVelocity or Vector3.new()
	local distance = (root.Position - Camera.CFrame.Position).Magnitude
	local time = distance / math.max(State.BulletSpeed, 1)
	return root.Position + velocity * time * math.max(State.PredictionStrength, 0)
end

local function getTargetPart(character)
	local partName = State.AimPart
	local part
	if partName == "Head" then part = character:FindFirstChild("Head")
	elseif partName == "Torso" then part = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	elseif partName == "Root" then part = getRoot(character)
	elseif partName == "Random" then
		local parts = { character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso"), getRoot(character) }
		part = parts[math.random(1, #parts)]
	elseif partName == "Left Arm" then part = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
	elseif partName == "Right Arm" then part = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
	elseif partName == "Left Leg" then part = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
	elseif partName == "Right Leg" then part = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
	else
		part = getRoot(character)
	end
	return part
end

local function getTargets()
	local list = {}
	local function addPlayer(player)
		if player == LocalPlayer or isTeammate(player) then return end
		if State.SkipPlayers then return end
		local character = player.Character
		if not character or not getRoot(character) then return end
		local humanoid = getHumanoid(character)
		if humanoid and humanoid.Health <= 0 then return end
		list[#list + 1] = { Player = player, Character = character, Model = character }
	end
	if Players.GetPlayers then
		for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end
	else
		for _, player in ipairs(Players:GetChildren()) do addPlayer(player) end
	end
	if State.AimNPCs and Workspace.FindFirstChild(Workspace, "Characters") then
		for _, object in ipairs(Workspace.Characters:GetChildren()) do
			if object:IsA("Model") and getRoot(object) and not State.SkipBandits then
				list[#list + 1] = { Player = nil, Character = object, Model = object, NPC = true }
			end
		end
	end
	return list
end

local function getAimTarget()
	if not Camera then return nil end
	local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
	local best = nil
	local bestScore = math.huge
	for _, entry in ipairs(getTargets()) do
		local part = getTargetPart(entry.Character)
		if part then
			local position = predictedPosition(part, State.AimPrediction)
			if position then
				local screen, visible = Camera:WorldToViewportPoint(position)
				if visible then
					local distance2 = (Vector2.new(screen.X, screen.Y) - mousePosition).Magnitude
					local worldDistance = (position - Camera.CFrame.Position).Magnitude
					if distance2 <= State.AimFOV and worldDistance <= State.AimRange then
						if not State.AimVisibleOnly or isVisible(position, entry.Model) then
							if distance2 < bestScore then
								bestScore = distance2
								best = { Entry = entry, Part = part, Position = position, Screen = Vector2.new(screen.X, screen.Y) }
							end
						end
					end
				end
			end
		end
	end
	return best
end

local fovCircle
local targetLine
if Drawing and type(Drawing.new) == "function" then
	fovCircle = Drawing.new("Circle")
	fovCircle.Radius = State.AimFOV
	fovCircle.NumSides = 64
	fovCircle.Thickness = 1
	fovCircle.Filled = false
	fovCircle.Visible = false
	trackDrawing(fovCircle)
	targetLine = Drawing.new("Line")
	targetLine.Thickness = 1
	targetLine.Visible = false
	trackDrawing(targetLine)
end

local targetHighlight
local targetIndicator
local crosshairLines = {}
local silentRestore = nil
if Drawing and type(Drawing.new) == "function" then
	targetIndicator = Drawing.new("Square")
	targetIndicator.Filled = false
	targetIndicator.Thickness = 2
	targetIndicator.Size = Vector2.new(14, 14)
	targetIndicator.Visible = false
	trackDrawing(targetIndicator)
	for index = 1, 4 do
		local line = Drawing.new("Line")
		line.Thickness = 1
		line.Visible = false
		trackDrawing(line)
		crosshairLines[index] = line
	end
end

local function hideAimVisuals()
	if targetIndicator then targetIndicator.Visible = false end
	if targetHighlight then pcall(function() targetHighlight.Enabled = false end) end
	for _, line in ipairs(crosshairLines) do line.Visible = false end
end

local function updateAim()
	if Runtime.Unloaded or not Camera then return end
	if State.FOVCircle and fovCircle then
		fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
		fovCircle.Radius = State.AimFOV
		fovCircle.Visible = true
	elseif fovCircle then
		fovCircle.Visible = false
	end
	if State.Crosshair then
		local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
		local gap, length = 4, 8
		local pairsList = {
			{ Vector2.new(cx - gap - length, cy), Vector2.new(cx - gap, cy) },
			{ Vector2.new(cx + gap, cy), Vector2.new(cx + gap + length, cy) },
			{ Vector2.new(cx, cy - gap - length), Vector2.new(cx, cy - gap) },
			{ Vector2.new(cx, cy + gap), Vector2.new(cx, cy + gap + length) },
		}
		for index, pair in ipairs(pairsList) do
			local line = crosshairLines[index]
			if line then
				line.From = pair[1]
				line.To = pair[2]
				line.Visible = true
			end
		end
	else
		for _, line in ipairs(crosshairLines) do line.Visible = false end
	end
	if silentRestore then
		Camera.CFrame = silentRestore
		silentRestore = nil
	end
	if not State.Aimbot or Runtime.MenuOpen then
		if targetLine then targetLine.Visible = false end
		hideAimVisuals()
		return
	end
	local target = getAimTarget()
	if not target or math.random(1, 100) > State.HitChance then
		if targetLine then targetLine.Visible = false end
		hideAimVisuals()
		return
	end
	if target then
		local current = Camera.CFrame
		local direction = (target.Position - current.Position).Unit
		local blended = current.LookVector + (direction - current.LookVector) * math.clamp(1 / math.max(State.AimStrength, 1), 0.01, 1)
		if State.SilentAim then
			silentRestore = current
			Camera.CFrame = CFrame.new(current.Position, current.Position + direction)
		else
			Camera.CFrame = CFrame.new(current.Position, current.Position + blended)
		end
		if State.TargetIndicator and targetIndicator then
			targetIndicator.Position = target.Screen
			targetIndicator.Visible = true
		elseif targetIndicator then
			targetIndicator.Visible = false
		end
		if State.TargetHighlight or State.HighlightESP then
			if not targetHighlight then
				pcall(function()
					targetHighlight = Instance.new("Highlight")
					targetHighlight.FillTransparency = 0.75
					targetHighlight.OutlineTransparency = 0
					targetHighlight.Parent = sg
					trackGui(targetHighlight)
				end)
			end
			if targetHighlight then
				pcall(function()
					targetHighlight.Adornee = target.Entry.Model
					targetHighlight.FillColor = EspColours[State.ColourPlayer] or EspColours.White
					targetHighlight.Enabled = true
				end)
			end
		elseif targetHighlight then
			pcall(function() targetHighlight.Enabled = false end)
		end
		if State.TargetLine and targetLine then
			targetLine.From = Vector2.new(Mouse.X, Mouse.Y)
			targetLine.To = target.Screen
			targetLine.Visible = true
		elseif targetLine then
			targetLine.Visible = false
		end
	elseif targetLine then
		targetLine.Visible = false
	end
end

local ValueCache = {
	["6B45"] = 16,
	["AS Val"] = 16,
	["ATC Key"] = 4,
	["Airfield Key"] = 6,
	["Altyn"] = 16,
	["Altyn Visor"] = 8,
	["Attak-5 60L"] = 16,
	["Bolts"] = 1,
	["Crane Key"] = 6,
	["DAGR"] = 8,
	["Duct Tape"] = 1,
	["Fast MT"] = 10,
	["Flare Gun"] = 8,
	["Fueling Station Key"] = 4,
	["Garage Key"] = 4,
	["Hammer"] = 1,
	["JPC"] = 10,
	["Lighthouse Key"] = 6,
	["M4A1"] = 12,
	["Nails"] = 1,
	["Nuts"] = 1,
	["Saiga 12"] = 8,
	["Super Glue"] = 1,
	["Village Key"] = 4,
	["Wrench"] = 1,
}

local EspColours = {
	White = fromRGB(255, 255, 255), Red = fromRGB(237, 105, 105), Green = fromRGB(105, 237, 150),
	Blue = fromRGB(120, 180, 255), Yellow = fromRGB(255, 215, 15), Orange = fromRGB(255, 150, 60),
	Purple = fromRGB(180, 110, 240), Cyan = fromRGB(80, 220, 255),
}
local ColourNames = { "White", "Red", "Green", "Blue", "Yellow", "Orange", "Purple", "Cyan" }
local ExtraEspCategories = {
	ContainerESP = { Label = "Container", Colour = "ColourContainer", Names = { "Container", "Loot Container", "Stash" } },
	CrateESP = { Label = "Crate", Colour = "ColourContainer", Names = { "Crate", "Military Crate", "KGB Cache", "Safe", "Cash Register", "Medbag" } },
	ExtractionESP = { Label = "Extraction", Colour = "ColourExtraction", Names = { "Extraction", "Extract", "Extraction Point" } },
	LandmineESP = { Label = "Landmine", Colour = "ColourMine", Names = { "Landmine", "Mine" } },
	CorpseESP = { Label = "Corpse", Colour = "ColourCorpse", Names = { "Corpse", "Dead Body", "Body Bag" } },
	QuestItemESP = { Label = "Quest Item", Colour = "ColourLoot", Names = { "Quest Item", "QuestItem" } },
	BotESP = { Label = "Bot", Colour = "ColourNPC", Names = { "Bandit", "Bot", "Scav" } },
	InventoryESP = { Label = "Inventory", Colour = "ColourLoot", Names = { "Inventory", "Item", "Dropped Item" } },
}
local LootFilters = { "All", "Valuables", "Medical", "Weapons", "Quest" }
local AimParts = { "Head", "Torso", "Root", "Random", "Closest", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
local ValueColors = {
	[0] = fromRGB(255, 255, 255),
	[4] = fromRGB(76, 187, 23),
	[8] = fromRGB(218, 112, 214),
	[16] = fromRGB(233, 116, 81),
	[32] = fromRGB(255, 36, 0),
}

local function colorForValue(value)
	local best = 0
	local color = ValueColors[0]
	for threshold, candidate in pairs(ValueColors) do
		if value >= threshold and threshold >= best then
			best = threshold
			color = candidate
		end
	end
	return color
end

local function containerText(container)
	local inventory = container:FindFirstChild("Inventory")
	if not inventory then return "", 0, 0 end
	local totalPrice = 0
	local value = 0
	local loot = ""
	for _, item in ipairs(inventory:GetChildren()) do
		local properties = item:FindFirstChild("ItemProperties")
		if properties then
			local amount = properties:GetAttribute("Amount") or 1
			local callSign = properties:GetAttribute("CallSign") or "Item"
			local price = properties:GetAttribute("Price") or 0
			totalPrice += price
			value += (ValueCache[callSign] or 0) * amount
			loot ..= callSign .. " x" .. tostring(amount) .. "\n"
		end
	end
	return loot, totalPrice, value
end

local extraCache = { clock = 0, items = {} }
local function collectExtra()
	local enabled = false
	for flag in pairs(ExtraEspCategories) do if State[flag] then enabled = true break end end
	if not enabled then return {} end
	if os.clock() - extraCache.clock < 0.5 then return extraCache.items end
	extraCache.clock = os.clock()
	extraCache.items = {}
	for _, object in ipairs(Workspace:GetDescendants()) do
		local position = nil
		if object:IsA("Model") then
			local part = object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
			if part and part.Position then position = part.Position end
		elseif object:IsA("BasePart") and object.Position then
			position = object.Position
		end
		if not position then continue end
		for flag, category in pairs(ExtraEspCategories) do
			if not State[flag] then continue end
			for _, name in ipairs(category.Names) do
				if string.find(string.lower(object.Name), string.lower(name), 1, true) then
					local label = category.Label
					if flag == "InventoryESP" then
						local loot = containerText(object)
						if loot ~= "" then label = label .. "\n" .. loot end
					end
					extraCache.items[#extraCache.items + 1] = { Object = object, Label = label, Color = EspColours[State[category.Colour]] or Theme.Text }
					break
				end
			end
		end
	end
	return extraCache.items
end

local function updateESP()
	if Runtime.Unloaded or not Camera then return end
	local root = getRoot(LocalPlayer.Character)
	if not root then return end
	for _, object in pairs(EspObjects) do object.text:Hide() object.line:Hide() end
	local function drawEntry(model, label, color, position)
		if not position then return end
		local screen, visible = Camera:WorldToViewportPoint(position)
		if not visible then return end
		local distance = (position - root.Position).Magnitude
		if distance > State.ESPRange then return end
		if State.WallcheckESP and not isVisible(position, model) then return end
		local object = EspObjects[model]
		if not object then
			object = { text = newEspText(), line = newEspLine() }
			EspObjects[model] = object
		end
		local text = ""
		if State.ShowNames then text = label end
		if State.ShowHealth then
			local humanoid = getHumanoid(model)
			if humanoid then text ..= "\nHP " .. tostring(math.floor(humanoid.Health)) end
		end
		if State.ShowDistance then text ..= "\n" .. tostring(math.floor(distance)) .. "m" end
		if State.ShowWeapon then
			local tool = model:FindFirstChildOfClass("Tool") or model:FindFirstChild("Tool")
			if tool then text ..= "\n" .. tool.Name end
		end
		if State.ShowBoxes then text = "[ " .. text .. " ]" end
		object.text:Show(text, Vector2.new(screen.X, screen.Y), color)
		if State.ShowTracers then
			object.line:Show(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), Vector2.new(screen.X, screen.Y), color)
		end
	end
	if State.PlayerESP then
		local players = Players.GetPlayers and Players:GetPlayers() or Players:GetChildren()
		for _, player in ipairs(players) do
			if player ~= LocalPlayer and player.Character and getRoot(player.Character) then
				local color = EspColours[State.ColourPlayer] or Theme.Text
				if State.TeamColors and player.Team and LocalPlayer.Team then
					color = player.Team == LocalPlayer.Team and Theme.Green or Theme.Red
				end
				drawEntry(player.Character, player.Name, color, getRoot(player.Character).Position)
			end
		end
	end
	if State.NPCESP and Workspace.FindFirstChild(Workspace, "Characters") then
		for _, model in ipairs(Workspace.Characters:GetChildren()) do
			if model:IsA("Model") and getRoot(model) then
				drawEntry(model, model.Name, EspColours[State.ColourNPC] or Theme.SubText, getRoot(model).Position)
			end
		end
	end
	if State.LootESP then
		local containers = Workspace.FindFirstChild(Workspace, "Containers")
		if containers then
			for _, model in ipairs(containers:GetDescendants()) do
				if model:IsA("Model") and model.PrimaryPart then
					local loot, totalPrice, value = containerText(model)
					local name = model:GetAttribute("DisplayName") or model.Name
					local filter = State.LootFilter
					local lowered = string.lower(name .. "\n" .. loot)
					local allowed = filter == "All"
						or (filter == "Valuables" and totalPrice >= 8)
						or (filter == "Medical" and string.find(lowered, "med", 1, true) ~= nil)
						or (filter == "Weapons" and (string.find(lowered, "m4", 1, true) ~= nil or string.find(lowered, "val", 1, true) ~= nil or string.find(lowered, "saiga", 1, true) ~= nil))
						or (filter == "Quest" and string.find(lowered, "quest", 1, true) ~= nil)
					if not allowed then continue end
					local text = "$" .. tostring(totalPrice) .. "\n" .. name
					if loot ~= "" then text ..= "\n" .. loot end
					local screen, visible = Camera:WorldToViewportPoint(model.PrimaryPart.Position)
					if visible and (model.PrimaryPart.Position - root.Position).Magnitude <= State.ESPRange then
						local object = EspObjects[model]
						if not object then
							object = { text = newEspText(), line = newEspLine() }
							EspObjects[model] = object
						end
						object.text:Show(text, Vector2.new(screen.X, screen.Y), EspColours[State.ColourLoot] or colorForValue(value))
					end
				end
			end
		end
	end
	for _, item in ipairs(collectExtra()) do
		drawEntry(item.Object, item.Label, item.Color, item.Object.Position or (item.Object.PrimaryPart and item.Object.PrimaryPart.Position) or nil)
	end
end

local espAccumulator = 0
local function updateESPThrottled(dt)
	local rate = State.LowPC and 8 or State.ESPUpdateRate
	espAccumulator += dt or 0
	if espAccumulator < 1 / math.max(rate, 1) then return end
	espAccumulator = 0
	updateESP()
end

local function setFOV()
	if Camera then Camera.FieldOfView = State.CustomFOV and State.FOVValue or OriginalFOV end
end

local function setFullBright(enabled)
	if enabled then
		OriginalLighting.Brightness = Lighting.Brightness
		OriginalLighting.Ambient = Lighting.Ambient
		OriginalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
		OriginalLighting.ClockTime = Lighting.ClockTime
		Lighting.Brightness = 2
		Lighting.Ambient = fromRGB(180, 180, 180)
		Lighting.OutdoorAmbient = fromRGB(180, 180, 180)
		Lighting.ClockTime = 12
	else
		if OriginalLighting.Brightness ~= nil then Lighting.Brightness = OriginalLighting.Brightness end
		if OriginalLighting.Ambient ~= nil then Lighting.Ambient = OriginalLighting.Ambient end
		if OriginalLighting.OutdoorAmbient ~= nil then Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient end
		if OriginalLighting.ClockTime ~= nil then Lighting.ClockTime = OriginalLighting.ClockTime end
	end
end

local function setFog(enabled)
	if enabled then
		OriginalLighting.FogEnd = Lighting.FogEnd
		OriginalLighting.FogStart = Lighting.FogStart
		OriginalLighting.FogColor = Lighting.FogColor
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
	else
		if OriginalLighting.FogEnd ~= nil then Lighting.FogEnd = OriginalLighting.FogEnd end
		if OriginalLighting.FogStart ~= nil then Lighting.FogStart = OriginalLighting.FogStart end
		if OriginalLighting.FogColor ~= nil then Lighting.FogColor = OriginalLighting.FogColor end
	end
end

local function setGrass(enabled)
	if not Workspace.Terrain then return end
	local terrain = Workspace.Terrain
	if enabled then
		applyTerrainDecoration()
		for _, object in ipairs(Workspace:GetDescendants()) do
			if (object.Name == "Grass" or object.Name == "Leaves" or object.Name == "Bush") and object:IsA("BasePart") then
				if OriginalGrass[object] == nil then OriginalGrass[object] = object.LocalTransparencyModifier end
				object.LocalTransparencyModifier = 1
			end
		end
	else
		applyTerrainDecoration()
		for object, value in pairs(OriginalGrass) do
			if object ~= "Decoration" and object.Parent then object.LocalTransparencyModifier = value end
		end
		table.clear(OriginalGrass)
	end
end

local function setBuildingXRay(enabled)
	if enabled then
		local containers = Workspace.FindFirstChild(Workspace, "Map") or Workspace.FindFirstChild(Workspace, "Buildings") or Workspace
		for _, object in ipairs(containers:GetDescendants()) do
			if object:IsA("BasePart") and (not LocalPlayer.Character or not object:IsDescendantOf(LocalPlayer.Character)) then
				if OriginalXRay[object] == nil then OriginalXRay[object] = object.LocalTransparencyModifier end
				object.LocalTransparencyModifier = 0.72
			end
		end
	else
		for object, value in pairs(OriginalXRay) do
			if object.Parent then object.LocalTransparencyModifier = value end
		end
		table.clear(OriginalXRay)
	end
end

local function setLowPC(enabled)
	if enabled then
		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
				OriginalLighting[effect] = effect.Enabled
				effect.Enabled = false
			end
		end
		applyTerrainDecoration()
	else
		for effect, value in pairs(OriginalLighting) do
			if typeof(effect) == "Instance" then effect.Enabled = value end
		end
		applyTerrainDecoration()
	end
end

local OriginalWorld = {}
local idleConnection
local function setNightMode(enabled)
	if enabled then
		OriginalWorld.ClockTime = Lighting.ClockTime
		OriginalWorld.Brightness = Lighting.Brightness
		Lighting.ClockTime = 0
		Lighting.Brightness = 3
	else
		if OriginalWorld.ClockTime ~= nil then Lighting.ClockTime = OriginalWorld.ClockTime end
		if OriginalWorld.Brightness ~= nil then Lighting.Brightness = OriginalWorld.Brightness end
	end
end
local function setNoShadow(enabled)
	if enabled then
		OriginalWorld.GlobalShadows = Lighting.GlobalShadows
		Lighting.GlobalShadows = false
	elseif OriginalWorld.GlobalShadows ~= nil then
		Lighting.GlobalShadows = OriginalWorld.GlobalShadows
	end
end
local function setAntiAFK(enabled)
	if idleConnection then idleConnection:Disconnect(); idleConnection = nil end
	if not enabled then return end
	pcall(function()
		idleConnection = LocalPlayer.Idled:Connect(function()
			if State.AutoRejoin then
				pcall(function()
					local service = game:GetService("TeleportService")
					if service and service.Teleport then service:Teleport(game.PlaceId, LocalPlayer) end
				end)
				return
			end
			local ok, service = pcall(function() return game:GetService("VirtualUser") end)
			if ok and service then
				pcall(function() service:CaptureController(); service:ClickButton2(Vector2.new()) end)
			end
		end)
		trackConnection(idleConnection)
	end)
end
local function serverHop()
	pcall(function()
		local service = game:GetService("TeleportService")
		if service and service.TeleportToPlaceInstance then
			service:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end
	end)
end
local function teleportToExtraction()
	local root = getRoot(LocalPlayer.Character)
	if not root then return end
	for _, object in ipairs(Workspace:GetDescendants()) do
		if string.find(string.lower(object.Name), "extract", 1, true) then
			local part = object:IsA("BasePart") and object or (object:IsA("Model") and (object.PrimaryPart or object:FindFirstChildOfClass("BasePart")))
			if part and part.Position then
				root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
				return
			end
		end
	end
end

local noclipParts = {}
local function restoreMovement()
	local character = LocalPlayer.Character
	if character then
		local humanoid = getHumanoid(character)
		if humanoid then
			humanoid.WalkSpeed = OriginalWalkSpeed
			if humanoid.UseJumpPower then humanoid.JumpPower = OriginalJumpPower else humanoid.JumpHeight = OriginalJumpHeight end
		end
		for part, value in pairs(noclipParts) do
			if part.Parent then part.CanCollide = value end
		end
		table.clear(noclipParts)
	end
	Workspace.Gravity = OriginalGravity
	if Camera then
		Camera.CameraType = OriginalCameraType or Enum.CameraType.Custom
		Camera.CameraSubject = OriginalCameraSubject
		if OriginalCameraCFrame then Camera.CFrame = OriginalCameraCFrame end
		Camera.FieldOfView = OriginalFOV
	end
end

local flyVelocity = Vector3.new()
local flyConnection
local freecam = { active = false, position = Vector3.new(), yaw = 0, pitch = 0 }
local speedConnection

local function updateMovement(dt)
	if Runtime.Unloaded then return end
	local character = LocalPlayer.Character
	local root = getRoot(character)
	local humanoid = getHumanoid(character)
	if not root or not humanoid or not Camera then return end
	humanoid.WalkSpeed = State.Speed and State.SpeedValue or OriginalWalkSpeed
	if State.JumpBoost then
		if humanoid.UseJumpPower then humanoid.JumpPower = State.JumpValue else humanoid.JumpHeight = State.JumpValue / 7.2 end
	else
		if humanoid.UseJumpPower then humanoid.JumpPower = OriginalJumpPower else humanoid.JumpHeight = OriginalJumpHeight end
	end
	if State.Speed and not State.Freecam then
		local direction = humanoid.MoveDirection
		if direction.Magnitude > 0 then
			root.AssemblyLinearVelocity = Vector3.new(direction.X * State.SpeedValue, root.AssemblyLinearVelocity.Y, direction.Z * State.SpeedValue)
		end
	end
	if State.Fly and not State.Freecam then
		local direction = Vector3.new()
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
		if direction.Magnitude > 0 then flyVelocity = direction.Unit * State.FlySpeed else flyVelocity = Vector3.new() end
		root.AssemblyLinearVelocity = flyVelocity
	end
	if State.Noclip then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if noclipParts[part] == nil then noclipParts[part] = part.CanCollide end
				part.CanCollide = false
			end
		end
	elseif next(noclipParts) ~= nil then
		for part, value in pairs(noclipParts) do
			if part.Parent then part.CanCollide = value end
		end
		table.clear(noclipParts)
	end
	if State.Freecam and freecam.active then
		local direction = Vector3.new()
		local forward = Vector3.new(math.cos(freecam.yaw) * math.cos(freecam.pitch), math.sin(freecam.pitch), math.sin(freecam.yaw) * math.cos(freecam.pitch))
		local right = Vector3.new(-forward.Z, 0, forward.X).Unit
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.W) then direction += forward end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.S) then direction -= forward end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.A) then direction -= right end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.D) then direction += right end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
		if direction.Magnitude > 0 then freecam.position += direction.Unit * State.FreecamSpeed * (dt or 0) end
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.new(freecam.position) * CFrame.Angles(0, freecam.yaw, 0) * CFrame.Angles(freecam.pitch, 0, 0)
	end
end

local function setFreecam(enabled)
	State.Freecam = enabled == true
	if State.Freecam then
		if not freecam.active and Camera then
			freecam.active = true
			freecam.position = Camera.CFrame.Position
			local look = Camera.CFrame.LookVector
			freecam.yaw = math.atan2(look.Z, look.X)
			freecam.pitch = math.asin(math.clamp(look.Y, -1, 1))
			Camera.CameraType = Enum.CameraType.Scriptable
		end
	else
		freecam.active = false
		if Camera then
			Camera.CameraType = OriginalCameraType or Enum.CameraType.Custom
			Camera.CameraSubject = OriginalCameraSubject
			if OriginalCameraCFrame then Camera.CFrame = OriginalCameraCFrame end
		end
	end
end

local function teleportMouse()
	if not State.TeleportMouse then return end
	local root = getRoot(LocalPlayer.Character)
	if not root or not Mouse then return end
	local target = Mouse.Hit and Mouse.Hit.Position or nil
	if target then
		root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
	end
end

local antiAimState = { Saved = nil, Angle = 0 }
local function restoreAntiAim()
	local saved = antiAimState.Saved
	antiAimState.Saved = nil
	if not saved or not saved.Root or not saved.Root.Parent then return end
	pcall(function() saved.Root.CFrame = saved.CFrame end)
end
trackConnection(RunService.Heartbeat:Connect(function(dt)
	if Runtime.Unloaded or not State.AntiAim then restoreAntiAim(); return end
	restoreAntiAim()
	local root = getRoot(LocalPlayer.Character)
	if not root then return end
	local current = root.CFrame
	local position = current.Position
	local spoof
	if State.AntiAimMode == "Spin" then
		antiAimState.Angle = (antiAimState.Angle + State.AntiAimSpin * (dt or 0)) % 360
		spoof = CFrame.new(position) * CFrame.Angles(0, math.rad(antiAimState.Angle), 0)
	else
		spoof = CFrame.new(position - Vector3.new(0, State.AntiAimDepth, 0))
	end
	antiAimState.Saved = { Root = root, CFrame = current }
	pcall(function() root.CFrame = spoof end)
end))

local function saveConfig()
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, { State = State, Binds = Binds })
	if not ok or type(writefile) ~= "function" then return false end
	if type(makefolder) == "function" then pcall(makefolder, "burmalda") end
	local saved = pcall(writefile, ConfigPath, encoded)
	return saved
end

local function loadConfig()
	if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(ConfigPath) then return false end
	local ok, raw = pcall(readfile, ConfigPath)
	if not ok or type(raw) ~= "string" then return false end
	local decodedOk, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
	if not decodedOk or type(decoded) ~= "table" then return false end
	local loadedState = type(decoded.State) == "table" and decoded.State or decoded
	local loadedBinds = type(decoded.Binds) == "table" and decoded.Binds or decoded
	for key, value in pairs(loadedState) do
		if State[key] ~= nil and type(State[key]) == type(value) then State[key] = value end
	end
	for key, value in pairs(Binds) do
		if loadedBinds[key] ~= nil then Binds[key] = loadedBinds[key]
		elseif loadedBinds[key .. "Bind"] ~= nil then Binds[key] = loadedBinds[key .. "Bind"] end
	end
	return true
end

local function syncUI()
	for _, handler in pairs(FeatureHandlers) do
		if handler.Key then handler:Set(State[handler.Key]) end
	end
	for key, apply in pairs(ConfigControls) do
		if State[key] ~= nil then apply(State[key]) end
	end
	for key, value in pairs(Binds) do
		local apply = ConfigControls[key .. "Bind"]
		if apply then apply(value) end
	end
end

local function toggleMenu()
	Runtime.MenuOpen = not Runtime.MenuOpen
	main.Visible = Runtime.MenuOpen
end

trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
	if processed or Runtime.Unloaded then return end
	if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
	for key, value in pairs(Binds) do
		local match = false
		if value ~= "None" then
			if value == "RMB" and input.UserInputType == Enum.UserInputType.MouseButton2 then match = true end
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == value then match = true end
		end
		if match then
			if key == "Freecam" and SettingHandlers[key] then SettingHandlers[key](not State[key])
			elseif key == "TeleportMouse" then teleportMouse()
			elseif key == "TeleportExtraction" then teleportToExtraction()
			elseif SettingHandlers[key] then SettingHandlers[key](not State[key]) end
		end
	end
end))

trackConnection(UserInputService.InputChanged:Connect(function(input)
	if not State.Freecam or not freecam.active or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	local delta = input.Delta
	if delta then
		freecam.yaw -= delta.X * 0.003
		freecam.pitch = math.clamp(freecam.pitch - delta.Y * 0.003, -1.5, 1.5)
	end
end))

trackConnection(UserInputService.JumpRequest:Connect(function()
	if not State.InfiniteJump or Runtime.Unloaded then return end
	local humanoid = getHumanoid(LocalPlayer.Character)
	if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

local hudLabel = Instance.new("TextLabel", hudGui)
hudLabel.Name = "StatsHUD"
hudLabel.Size = UDim2.new(0, 220, 0, 54)
hudLabel.Position = UDim2.new(0, 8, 0, 8)
hudLabel.BackgroundTransparency = 1
hudLabel.TextColor3 = Theme.Text
hudLabel.TextStrokeTransparency = 0
hudLabel.TextXAlignment = Enum.TextXAlignment.Left
hudLabel.TextYAlignment = Enum.TextYAlignment.Top
hudLabel.Font = Enum.Font.SourceSansBold
hudLabel.TextSize = 12
hudLabel.Visible = State.StatsHUD

local hudAccumulator = 0
local lastFrames = 0
local fps = 0
local function updateHUD(dt)
	hudAccumulator += dt or 0
	lastFrames += 1
	if hudAccumulator >= 0.5 then
		fps = math.floor(lastFrames / hudAccumulator)
		lastFrames = 0
		hudAccumulator = 0
	end
	hudLabel.Visible = State.StatsHUD and not Runtime.Unloaded
	if not hudLabel.Visible then return end
	local root = getRoot(LocalPlayer.Character)
	local speed = root and root.AssemblyLinearVelocity and math.floor(root.AssemblyLinearVelocity.Magnitude) or 0
	local ping = 0
	if StatsService and StatsService.Network and StatsService.Network.ServerStatsItem and StatsService.Network.ServerStatsItem["Data Ping"] then
		local ok, value = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		if ok then ping = math.floor(tonumber(value) or 0) end
	end
	hudLabel.Text = string.format("Burmalda.hook | Project Delta\nFPS %d | Ping %d | Speed %d | %s", fps, ping, speed, executorName)
end

local function guardedStep(name, callback, dt)
	if Runtime.Unloaded or type(callback) ~= "function" then return end
	local ok, err = pcall(callback, dt)
	if not ok then Runtime.LastError = name .. ": " .. tostring(err) end
end

local renderConnection
renderConnection = trackConnection(RunService.RenderStepped:Connect(function(dt)
	if Runtime.Unloaded or not Runtime.Ready then return end
	Camera = Workspace.CurrentCamera or Camera
	if not Camera then return end
	guardedStep("Aim", updateAim, dt)
	guardedStep("ESP", updateESPThrottled, dt)
	guardedStep("Movement", updateMovement, dt)
	guardedStep("HUD", updateHUD, dt)
end))

section(Columns[tabFrames.COMBAT].Left, "Aim")
feature("COMBAT", "Left", "Aimbot", "Aimbot")
slider("COMBAT", "Left", "FOV", "AimFOV", 10, 400)
slider("COMBAT", "Left", "Range", "AimRange", 50, 3000)
slider("COMBAT", "Left", "Smoothing", "AimSmoothing", 1, 30)
dropdown("COMBAT", "Left", "Aim Part", "AimPart", AimParts)
slider("COMBAT", "Left", "Hit Chance", "HitChance", 1, 100)
slider("COMBAT", "Left", "Aim Strength", "AimStrength", 1, 30)
slider("COMBAT", "Left", "Prediction Strength", "PredictionStrength", 0, 3)
feature("COMBAT", "Left", "Team Check", "AimTeamCheck")
feature("COMBAT", "Left", "Wall Check", "AimWallCheck")
feature("COMBAT", "Left", "Visible Only", "AimVisibleOnly")
feature("COMBAT", "Left", "Target NPCs", "AimNPCs")
feature("COMBAT", "Left", "Prediction", "AimPrediction")
feature("COMBAT", "Left", "Silent Aim", "SilentAim")
feature("COMBAT", "Left", "Skip Players", "SkipPlayers")
feature("COMBAT", "Left", "Skip Bandits", "SkipBandits")
slider("COMBAT", "Left", "Bullet Speed", "BulletSpeed", 100, 3000)
bind("COMBAT", "Left", "Aimbot Bind", "Aimbot")

section(Columns[tabFrames.COMBAT].Right, "Aim Visuals")
feature("COMBAT", "Right", "FOV Circle", "FOVCircle")
feature("COMBAT", "Right", "Target Line", "TargetLine")
feature("COMBAT", "Right", "Target Indicator", "TargetIndicator")
feature("COMBAT", "Right", "Target Highlight", "TargetHighlight")
feature("COMBAT", "Right", "Crosshair", "Crosshair")

section(Columns[tabFrames.VISUALS].Left, "Player ESP")
feature("VISUALS", "Left", "Player ESP", "PlayerESP")
feature("VISUALS", "Left", "NPC ESP", "NPCESP")
feature("VISUALS", "Left", "Loot ESP", "LootESP")
feature("VISUALS", "Left", "Show Names", "ShowNames")
feature("VISUALS", "Left", "Show Health", "ShowHealth")
feature("VISUALS", "Left", "Show Distance", "ShowDistance")
feature("VISUALS", "Left", "Show Boxes", "ShowBoxes")
feature("VISUALS", "Left", "Show Tracers", "ShowTracers")
feature("VISUALS", "Left", "Show Weapon", "ShowWeapon")
feature("VISUALS", "Left", "Wallcheck ESP", "WallcheckESP")
feature("VISUALS", "Left", "Highlight ESP", "HighlightESP")
feature("VISUALS", "Left", "Container ESP", "ContainerESP")
feature("VISUALS", "Left", "Crate ESP", "CrateESP")
feature("VISUALS", "Left", "Extraction ESP", "ExtractionESP")
feature("VISUALS", "Left", "Landmine ESP", "LandmineESP")
feature("VISUALS", "Left", "Corpse ESP", "CorpseESP")
feature("VISUALS", "Left", "Quest Item ESP", "QuestItemESP")
feature("VISUALS", "Left", "Bot ESP", "BotESP")
feature("VISUALS", "Left", "Inventory ESP", "InventoryESP")
feature("VISUALS", "Left", "Team Colors", "TeamColors")

section(Columns[tabFrames.VISUALS].Right, "ESP Settings")
slider("VISUALS", "Right", "ESP Range", "ESPRange", 50, 3000)
slider("VISUALS", "Right", "Update Rate", "ESPUpdateRate", 5, 60)
slider("VISUALS", "Right", "Transparency", "ESPTransparency", 10, 100)
slider("VISUALS", "Right", "Text Size", "ESPTextSize", 8, 24)
dropdown("VISUALS", "Right", "Loot Filter", "LootFilter", LootFilters)
dropdown("VISUALS", "Right", "Player Colour", "ColourPlayer", ColourNames)
dropdown("VISUALS", "Right", "NPC Colour", "ColourNPC", ColourNames)
dropdown("VISUALS", "Right", "Loot Colour", "ColourLoot", ColourNames)
dropdown("VISUALS", "Right", "Container Colour", "ColourContainer", ColourNames)
dropdown("VISUALS", "Right", "Extraction Colour", "ColourExtraction", ColourNames)
dropdown("VISUALS", "Right", "Mine Colour", "ColourMine", ColourNames)
dropdown("VISUALS", "Right", "Corpse Colour", "ColourCorpse", ColourNames)

section(Columns[tabFrames.MOVEMENT].Left, "Movement")
feature("MOVEMENT", "Left", "Speed", "Speed")
slider("MOVEMENT", "Left", "Speed Value", "SpeedValue", 0, 60)
feature("MOVEMENT", "Left", "Fly", "Fly")
slider("MOVEMENT", "Left", "Fly Speed", "FlySpeed", 10, 250)
feature("MOVEMENT", "Left", "Noclip", "Noclip")
feature("MOVEMENT", "Left", "Infinite Jump", "InfiniteJump")
feature("MOVEMENT", "Left", "Freecam", "Freecam", setFreecam)
slider("MOVEMENT", "Left", "Freecam Speed", "FreecamSpeed", 10, 300)
feature("MOVEMENT", "Left", "Teleport Mouse", "TeleportMouse")
feature("MOVEMENT", "Left", "Jump Boost", "JumpBoost")
slider("MOVEMENT", "Left", "Jump Value", "JumpValue", 10, 200)
feature("MOVEMENT", "Left", "Anti Aim", "AntiAim")
dropdown("MOVEMENT", "Left", "Anti Aim Mode", "AntiAimMode", { "Under Ground", "Spin" })
slider("MOVEMENT", "Left", "Anti Aim Depth", "AntiAimDepth", 1, 12)
slider("MOVEMENT", "Left", "Spin Speed", "AntiAimSpin", 30, 720)

section(Columns[tabFrames.MOVEMENT].Right, "Binds")
bind("MOVEMENT", "Right", "Fly Bind", "Fly")
bind("MOVEMENT", "Right", "Noclip Bind", "Noclip")
bind("MOVEMENT", "Right", "Freecam Bind", "Freecam")
bind("MOVEMENT", "Right", "Teleport Bind", "TeleportMouse")
bind("MOVEMENT", "Right", "Anti Aim Bind", "AntiAim")
bind("MOVEMENT", "Right", "Extraction Bind", "TeleportExtraction")

section(Columns[tabFrames.MISC].Left, "World")
feature("MISC", "Left", "FullBright", "FullBright", setFullBright)
feature("MISC", "Left", "Remove Fog", "RemoveFog", setFog)
feature("MISC", "Left", "Hide Grass", "HideGrass", setGrass)
feature("MISC", "Left", "Building X-Ray", "BuildingXRay", setBuildingXRay)
feature("MISC", "Left", "Low PC", "LowPC", setLowPC)
feature("MISC", "Left", "Custom FOV", "CustomFOV", setFOV)
feature("MISC", "Left", "Night Mode", "NightMode", setNightMode)
feature("MISC", "Left", "No Shadow", "NoShadow", setNoShadow)
feature("MISC", "Left", "Anti AFK", "AntiAFK", setAntiAFK)
feature("MISC", "Left", "Auto Rejoin", "AutoRejoin")
slider("MISC", "Left", "FOV Value", "FOVValue", 60, 120, setFOV)

section(Columns[tabFrames.MISC].Right, "Interface")
feature("MISC", "Right", "Stats HUD", "StatsHUD")
feature("MISC", "Right", "Menu Accent", "MenuAccent", function(value)
	mainStroke.Color = value and Theme.Green or Theme.Accent
end)
feature("MISC", "Right", "UI Animations", "UIAnimations")
button("MISC", "Right", "Server Hop", serverHop)
button("MISC", "Right", "Teleport To Extraction", teleportToExtraction)
button("MISC", "Right", "Save Config", saveConfig)
button("MISC", "Right", "Load Config", function()
	if loadConfig() then syncUI() end
end)
button("MISC", "Right", "Unload Burmalda.hook", function()
	local defer = task.defer or task.spawn or function(callback) callback() end
	defer(Runtime.Unload)
end)

section(Columns[tabFrames.CONFIG].Left, "Config")
button("CONFIG", "Left", "Save Config", saveConfig)
button("CONFIG", "Left", "Load Config", function()
	if loadConfig() then syncUI() end
end)

section(Columns[tabFrames.CONFIG].Right, "Info")
local info = Instance.new("TextLabel", Columns[tabFrames.CONFIG].Right)
info.Size = UDim2.new(1, -12, 0, 120)
info.Position = UDim2.new(0, 6, 0, 0)
info.BackgroundTransparency = 1
info.Text = "Project Delta\nPlaceId 7336302630\nExecutor " .. executorName .. "\nAll features Off at startup"
info.TextColor3 = Theme.SubText
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Font = Enum.Font.SourceSans
info.TextSize = 12
info.TextWrapped = true

for _, frame in pairs(tabFrames) do
	frame.CanvasSize = UDim2.new(0, 0, 0, 480)
end

closeBtn.MouseButton1Click:Connect(toggleMenu)

function Runtime.Unload()
	if Runtime.Unloaded then return end
	Runtime.Unloaded = true
	Runtime.Ready = false
	for key in pairs(State) do
		if type(State[key]) == "boolean" then State[key] = false end
	end
	hudLabel.Visible = false
	for _, connection in ipairs(Runtime.Connections) do
		if connection and connection.Disconnect then pcall(connection.Disconnect, connection) end
	end
	table.clear(Runtime.Connections)
	for _, object in pairs(EspObjects) do
		object.text:Remove()
		object.line:Remove()
	end
	table.clear(EspObjects)
	for drawing in pairs(Runtime.Drawings) do
		if drawing and drawing.Remove then pcall(drawing.Remove, drawing) end
	end
	table.clear(Runtime.Drawings)
	setFullBright(false)
	setFog(false)
	setGrass(false)
	setBuildingXRay(false)
	setLowPC(false)
	setNightMode(false)
	setNoShadow(false)
	setAntiAFK(false)
	hideAimVisuals()
	restoreAntiAim()
	if targetHighlight then pcall(function() targetHighlight:Destroy() end) end
	restoreMovement()
	for index = #Runtime.Owned, 1, -1 do pcall(Runtime.Owned[index]) end
	for gui in pairs(Runtime.Guis) do
		if gui and gui.Destroy then pcall(gui.Destroy, gui) end
	end
	table.clear(Runtime.Guis)
	if Env.BurmaldaProjectDelta == Runtime then Env.BurmaldaProjectDelta = nil end
end

loadConfig()
syncUI()
Runtime.Ready = true
return Runtime
