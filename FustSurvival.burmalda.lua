-- Burmalda.hook | Fust Survival | standalone development build
-- Release: 2026-11-01. Target PlaceId: 79862723087324.
-- No HTTP loader or external UI/ESP library.
-- Executors: Real, Opiumware, Madium, Potassium, Synapse Z, Volt, Volcano.
-- Xeno is unsupported. Live game validation is still required.

local _fustEnv = getgenv and getgenv() or _G
if _fustEnv.BurmaldaFust and _fustEnv.BurmaldaFust.Unload then
	pcall(_fustEnv.BurmaldaFust.Unload)
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
if game.PlaceId ~= 79862723087324 then
	warn("Burmalda.hook: this build is only for Fust Survival")
	return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Runtime = {
	Unloaded = false,
	Ready = false,
	ExecutorName = executorName,
	PlaceId = 79862723087324,
	Cleanup = {},
	Drawings = {},
	Guis = {},
	BindApis = {},
	ConfigControls = {},
	FeatureHandlers = {},
	SettingHandlers = {},
	Diagnostics = {},
	TabNames = {"COMBAT", "VISUALS", "WORLD", "MOVEMENT", "MISC", "CONFIG"},
	SupportedExecutors = {"Real", "Opiumware", "Madium", "Potassium", "Synapse Z", "Volt", "Volcano"},
}
_fustEnv.BurmaldaFust = Runtime

local S = {
	Aimbot = false,
	AimFOV = 160,
	AimRange = 1500,
	AimSmoothing = 8,
	AimPart = "Head",
	AimPriority = "Crosshair",
	AimKey = "RMB",
	AimTeamCheck = true,
	AimWallCheck = true,
	AimNPC = false,
	AimHeli = false,
	AimPlayersFirst = true,
	AimPrediction = false,
	FOVCircle = true,
	TargetLine = false,

	SilentAim = false,
	SilentFOV = 240,
	SilentRange = 1500,
	SilentPart = "Head",
	SilentTeamCheck = true,
	SilentWallCheck = true,
	SilentNPC = false,
	SilentPrediction = true,

	AutoCross = false,

	Triggerbot = false,
	TriggerRadius = 6,
	TriggerReaction = 80,
	TriggerDelay = 60,
	TriggerKey = "Always",
	TriggerTeamCheck = true,
	TriggerWallCheck = true,
	TriggerNPC = false,

	WeaponPatches = false,
	WeaponFireRate = false,
	FireInterval = 90,
	WeaponClean = false,

	PlayerESP = false,
	PlayerBox = true,
	PlayerNames = true,
	PlayerDistance = true,
	PlayerHealth = true,
	PlayerHeldItem = true,
	PlayerTeamCheck = true,
	PlayerRange = 1500,
	PlayerTextSize = 13,

	NPCESP = false,
	NPCHeli = true,
	NPCBox = false,
	NPCNames = true,
	NPCDistance = true,
	NPCHealth = false,
	NPCRange = 300,
	NPCTextSize = 13,

	LootESP = false,
	LootBarrels = true,
	LootCrates = true,
	LootMilitary = true,
	LootElite = true,
	LootDistance = true,
	LootRange = 400,

	BaseESP = false,
	BaseBoxes = true,
	BaseCupboard = true,
	BaseLocker = true,
	BaseSleepingBag = true,
	BaseTraps = true,
	BaseDistance = true,
	BaseRange = 175,

	DropsESP = false,
	BodyBags = true,
	DroppedItems = true,
	DropsDistance = false,
	DropsRange = 400,

	NodesESP = false,
	NodeStone = true,
	NodeSulfur = true,
	NodeMetal = true,
	NodesDistance = true,
	NodesRange = 500,

	PickupsESP = false,
	PickupOres = true,
	PickupWood = true,
	PickupPlants = true,
	PickupsDistance = false,
	PickupsRange = 200,

	VehiclesESP = false,
	VehicleATV = true,
	VehicleBoats = true,
	VehicleHelis = true,
	VehiclesDistance = true,
	VehiclesRange = 1000,
	WorldTextSize = 13,

	Speed = false,
	SpeedValue = 24,
	HighJump = false,
	JumpHeight = 50,
	Noclip = false,

	HideGrass = false,
	LowPC = false,
	HUD = true,
	UIAnimations = true,
}

local Colors = {
	Accent = Color3.fromRGB(255, 255, 255),
	FOV = Color3.fromRGB(90, 175, 255),
	TargetLine = Color3.fromRGB(255, 90, 90),
	Player = Color3.fromRGB(90, 175, 255),
	PlayerText = Color3.fromRGB(240, 240, 240),
	NPC = Color3.fromRGB(255, 105, 95),
	Loot = Color3.fromRGB(255, 190, 80),
	Base = Color3.fromRGB(80, 210, 255),
	Drops = Color3.fromRGB(220, 160, 255),
	Nodes = Color3.fromRGB(230, 230, 190),
	Pickups = Color3.fromRGB(120, 230, 140),
	Vehicles = Color3.fromRGB(255, 145, 80),
}
Runtime.State = S
Runtime.Colors = Colors
Runtime.ExecutorName = executorName

local function onCleanup(fn)
	table.insert(Runtime.Cleanup, fn)
end
Runtime.AddCleanup = onCleanup

local function trackDrawing(object)
	table.insert(Runtime.Drawings, object)
	return object
end
local _drawingNew = Drawing and Drawing.new or nil
local function newDrawing(kind)
	if not _drawingNew then return nil end
	local ok, object = pcall(_drawingNew, kind)
	if not ok or not object then return nil end
	return trackDrawing(object)
end
Runtime.NewDrawing = newDrawing

local _instanceNew = Instance.new
local function newScreenGui()
	local gui = _instanceNew("ScreenGui")
	Runtime.Guis[gui] = true
	return gui
end

local uiParent
if type(gethui) == "function" then
	pcall(function() uiParent = gethui() end)
end
if not uiParent then uiParent = LocalPlayer:WaitForChild("PlayerGui") end
for _, name in ipairs({"BurmaldaHookFust", "BurmaldaHookFustStats"}) do
	local old = uiParent:FindFirstChild(name)
	if old then old:Destroy() end
end

local sg = newScreenGui()
sg.Name = "BurmaldaHookFust"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.DisplayOrder = 999998
sg.Parent = uiParent

-- Shared Burmalda.hook stats HUD. UI-only: no game-specific logic or assets.
-- The brand row intentionally has no left Logo/ImageLabel. The HUD is owned by
-- its caller's ScreenGui and remains visible when the main menu is hidden.
local function createBurmaldaStatsHud(options)
	options = options or {}
	local parent = assert(options.Parent, "Stats HUD parent is required")
	local world = options.Workspace or workspace
	local player = options.LocalPlayer
	local statsService = options.Stats
	local destroyed = false
	local isActive = options.IsActive or function() return true end

	local root = Instance.new("Frame", parent)
	root.Name = "BurmaldaStatsHUD"
	root.Size = UDim2.new(1, 0, 1, 0)
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Visible = options.Visible ~= false

	local camera = world and world.CurrentCamera
	local scaleValue = camera and camera.ViewportSize.X >= 1024 and 1.5 or 1

	local function bar(name, barParent, height)
		local frame = Instance.new("Frame", barParent)
		frame.Name = name
		frame.Size = UDim2.new(0, 0, 0, height)
		frame.AutomaticSize = Enum.AutomaticSize.X
		frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
		frame.BackgroundTransparency = 0.08
		frame.BorderSizePixel = 0
		local rounded = Instance.new("UICorner", frame)
		rounded.CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", frame)
		stroke.Transparency = 0.92
		local padding = Instance.new("UIPadding", frame)
		padding.PaddingLeft = UDim.new(0, 8)
		padding.PaddingRight = UDim.new(0, 8)
		local layout = Instance.new("UIListLayout", frame)
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0, 6)
		return frame
	end

	local function section(parent, iconId, text, iconSize, textSize)
		local holder = Instance.new("Frame", parent)
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.new(0, 0, 1, 0)
		holder.AutomaticSize = Enum.AutomaticSize.X
		holder.BorderSizePixel = 0
		local layout = Instance.new("UIListLayout", holder)
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0, iconId and 4 or 0)
		if iconId then
			local icon = Instance.new("ImageLabel", holder)
			icon.Name = "MetricIcon"
			icon.Size = UDim2.new(0, iconSize or 14, 0, iconSize or 14)
			icon.BackgroundTransparency = 1
			icon.BorderSizePixel = 0
			icon.Image = "rbxassetid://" .. tostring(iconId)
		end
		local label = Instance.new("TextLabel", holder)
		label.Name = iconId and "MetricText" or "BrandText"
		label.Size = UDim2.new(0, 0, 1, 0)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Font = iconId and Enum.Font.GothamBold or Enum.Font.GothamBold
		label.TextSize = textSize or 12
		label.Text = text
		return label
	end

	local function separator(parent)
		local line = Instance.new("Frame", parent)
		line.Size = UDim2.new(0, 1, 0, 12)
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.BackgroundTransparency = 0.85
		line.BorderSizePixel = 0
	end

	local mainBar = bar("MainBar", root, 22)
	mainBar.Position = UDim2.new(0.5, 0, 0.015, 0)
	mainBar.AnchorPoint = Vector2.new(0.5, 0)
	local mainScale = Instance.new("UIScale", mainBar)
	mainScale.Scale = scaleValue

	-- No icon is created before this label: this is the requested logo-free HUD.
	section(mainBar, nil, "Burmalda.hook", 0, 12)
	separator(mainBar)
	local fpsLabel = section(mainBar, "12096147158", "0 fps", 14, 12)
	separator(mainBar)
	local timeLabel = section(mainBar, "17824308575", "00:00:00", 14, 12)

	local lowerHolder = Instance.new("Frame", root)
	lowerHolder.Name = "LowerHolder"
	lowerHolder.BackgroundTransparency = 1
	lowerHolder.BorderSizePixel = 0
	lowerHolder.Size = UDim2.new(0, 0, 0, 22 * scaleValue)
	lowerHolder.AutomaticSize = Enum.AutomaticSize.X
	lowerHolder.Position = UDim2.new(0.5, 0, 0.015, 22 * scaleValue + 4)
	lowerHolder.AnchorPoint = Vector2.new(0.5, 0)
	local lowerLayout = Instance.new("UIListLayout", lowerHolder)
	lowerLayout.FillDirection = Enum.FillDirection.Horizontal
	lowerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	lowerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	lowerLayout.Padding = UDim.new(0, 8)

	local pingBar = bar("PingBar", lowerHolder, 22 * scaleValue)
	local pingLabel = section(pingBar, "84895557744908", "0 ms", math.floor(14 * scaleValue), math.floor(12 * scaleValue))
	local speedBar = bar("SpeedBar", lowerHolder, 22 * scaleValue)
	local speedLabel = section(speedBar, "105442920358687", "0 studs/s", math.floor(12 * scaleValue), math.floor(12 * scaleValue))

	local api = { Root = root, MainBar = mainBar, LowerHolder = lowerHolder }
	function api.SetVisible(value)
		if not destroyed then root.Visible = value == true end
	end
	function api.Destroy()
		if destroyed then return end
		destroyed = true
		root:Destroy()
	end

	task.spawn(function()
		while not destroyed and isActive() do
			if root.Parent == nil then break end
			local clockOk, clockText = pcall(function() return os.date("%H:%M:%S") end)
			if clockOk then timeLabel.Text = clockText end

			local fpsOk, fps = pcall(function() return world:GetRealPhysicsFPS() end)
			fpsLabel.Text = tostring(fpsOk and math.floor(fps + 0.5) or 0) .. " fps"

			local pingOk, ping = pcall(function()
				return math.floor(statsService.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			pingLabel.Text = tostring(pingOk and ping or 0) .. " ms"

			local speed = 0
			local character = player and player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local velocity = rootPart.AssemblyLinearVelocity
				speed = math.floor(Vector3.new(velocity.X, 0, velocity.Z).Magnitude + 0.5)
			end
			speedLabel.Text = tostring(speed) .. " studs/s"
			task.wait(0.5)
		end
	end)

	return api
end


local advGui = newScreenGui()
advGui.Name = "BurmaldaHookFustStats"
advGui.IgnoreGuiInset = true
advGui.ResetOnSpawn = false
advGui.DisplayOrder = 999999
advGui.Parent = uiParent
local _isLargeScreen = Camera and Camera.ViewportSize.X >= 1024 or false
local statsHud = createBurmaldaStatsHud({
	Parent = advGui,
	Workspace = workspace,
	LocalPlayer = LocalPlayer,
	Stats = Stats,
	Visible = S.HUD,
	IsActive = function() return not Runtime.Unloaded end,
})
onCleanup(function() statsHud.Destroy() end)

local function hudMakeDrag(gui)
	local drag, dragInput, dragStart, startPosition
	local changedConnection
	local connections = {}
	table.insert(connections, gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			drag = true
			dragStart = input.Position
			startPosition = gui.Position
			if changedConnection then changedConnection:Disconnect() end
			changedConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					drag = false
					if changedConnection then changedConnection:Disconnect(); changedConnection = nil end
				end
			end)
		end
	end))
	table.insert(connections, gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))
	table.insert(connections, UIS.InputChanged:Connect(function(input)
		if not Runtime.Unloaded and input == dragInput and drag then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
				startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end))
	onCleanup(function()
		drag = false
		if changedConnection then pcall(function() changedConnection:Disconnect() end) end
		for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
	end)
end

local openBtn = Instance.new("TextButton")
openBtn.Name = "MenuBtn"
openBtn.Text = ""
openBtn.AutoButtonColor = false
openBtn.Size = UDim2.new(0, 32, 0, 32)
openBtn.Position = UDim2.new(0, 20, 0, 100)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
openBtn.BackgroundTransparency = 0.15
openBtn.BorderSizePixel = 0
openBtn.Active = true
openBtn.Parent = sg
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)
local btnIco = Instance.new("ImageLabel", openBtn)
btnIco.Size = UDim2.new(1, -8, 1, -8)
btnIco.Position = UDim2.new(0.5, 0, 0.5, 0)
btnIco.AnchorPoint = Vector2.new(0.5, 0.5)
btnIco.BackgroundTransparency = 1
btnIco.Image = "rbxassetid://110686514699024"
btnIco.ScaleType = Enum.ScaleType.Fit
hudMakeDrag(openBtn)
Runtime.StartClosed = true

-- Burmalda.hook | Fust Survival | local 621x542 UI; no external library.
-- Source geometry: Window 621x542, Pages 30px, two scrolling columns,
-- Section topbar 25px, content (8,35), controls gap 6px, bottom padding 8px.
-- No external UI library, logo asset, glow asset or runtime HTTP dependency.
-- Only the gameplay/adapter API escapes this implementation scope. Keeping
-- helper locals inside the do-block avoids the Luau 200-register limit when
-- the menu is embedded into an already large game client.
local Theme, UIAnimations, main, mainStroke, mainScale, baseMenuScale
local tabs, tabFrames, tabButtons, activeFrame
local _fFS, _fDD, sectionContents, columnSections
local getTab, smartCol, getSection, defaultSectionName, selectTab, createFeature
local addBind, addSlider, addDropdown, addColor
local setMenuAccent, sourceText, sourceStroke, sourceGradient
local toggleMenu, menuOpen
do
Theme = {
	Background = Color3.fromRGB(8, 8, 8),
	Inline = Color3.fromRGB(12, 12, 12),
	Element = Color3.fromRGB(19, 19, 19),
	Border = Color3.fromRGB(40, 40, 40),
	Text = Color3.fromRGB(242, 242, 242),
	SubText = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(255, 255, 255),
}
UIAnimations = true
local SOURCE_WINDOW_WIDTH, SOURCE_WINDOW_HEIGHT = 621, 542
local SOURCE_PAGE_HEIGHT, SOURCE_SECTION_GAP = 30, 12
local SOURCE_SECTION_TOPBAR, SOURCE_CONTROL_GAP = 25, 6

main = Instance.new("Frame", sg)
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, SOURCE_WINDOW_WIDTH, 0, SOURCE_WINDOW_HEIGHT)
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 2
main.ClipsDescendants = true
mainStroke = Instance.new("UIStroke", main)
mainStroke.Name = "BurmaldaAccent"
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
do
	local mainStrokeGradient = Instance.new("UIGradient", mainStroke)
	mainStrokeGradient.Rotation = 90
	mainStrokeGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.696, 0.275),
		NumberSequenceKeypoint.new(0.84, 0.575),
		NumberSequenceKeypoint.new(1, 1),
	})
	local inlineWindow = Instance.new("Frame", main)
	inlineWindow.Name = "Inline"
	inlineWindow.Position = UDim2.new(0, 1, 0, 1)
	inlineWindow.Size = UDim2.new(1, -2, 1, -2)
	inlineWindow.BackgroundTransparency = 1
	inlineWindow.BorderSizePixel = 0
	local inlineStroke = Instance.new("UIStroke", inlineWindow)
	inlineStroke.Color = Color3.fromRGB(0, 0, 0)
	inlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

mainScale = Instance.new("UIScale", main)
baseMenuScale = _isLargeScreen and 1 or 0.82
mainScale.Scale = baseMenuScale

local header = Instance.new("Frame", main:FindFirstChild("Inline"))
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 39)
header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header)
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 8, 0, 10)
title.Size = UDim2.new(1, -16, 0, 15)
title.Font = Enum.Font.Gotham
title.Text = "Burmalda.hook"
title.TextSize = 14
title.TextColor3 = Theme.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center

local contentShell = Instance.new("Frame", main:FindFirstChild("Inline"))
contentShell.Name = "ContentShell"
contentShell.Position = UDim2.new(0, 7, 0, 39)
contentShell.Size = UDim2.new(1, -14, 1, -46)
contentShell.BackgroundTransparency = 1
contentShell.BorderSizePixel = 0
contentShell.ClipsDescendants = true
local contentStroke = Instance.new("UIStroke", contentShell)
contentStroke.Color = Theme.Border
contentStroke.Thickness = 1
contentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local pages = Instance.new("Frame", contentShell)
pages.Name = "Pages"
pages.Size = UDim2.new(1, 0, 0, SOURCE_PAGE_HEIGHT)
pages.BackgroundTransparency = 1
local pagesLayout = Instance.new("UIListLayout", pages)
pagesLayout.FillDirection = Enum.FillDirection.Horizontal
pagesLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
pagesLayout.Padding = UDim.new(0, 1)
pagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
local tabsHolder = Instance.new("Frame", contentShell)
tabsHolder.Name = "Tabs"
tabsHolder.Position = UDim2.new(0, 0, 0, 35)
tabsHolder.Size = UDim2.new(1, 0, 1, -35)
tabsHolder.BackgroundTransparency = 1

local tabNames = Runtime.TabNames or {"COMBAT", "VISUALS", "MOVEMENT", "MISC", "CONFIG"}
tabs = tabNames
tabFrames, tabButtons = {}, {}
local tabUnderlines, tabColumns = {}, {}
columnSections, sectionContents = {}, {}
local columnTabs = {}
local featureRecords = {}
_fFS, _fDD = {}, {}
Runtime.BindApis = {}
local openPopups = {}

local function connectUI(signal, fn)
	local connection = signal:Connect(fn)
	onCleanup(function() pcall(function() connection:Disconnect() end) end)
	return connection
end

local function uiTween(object, info, props)
	if UIAnimations then return TS:Create(object, info, props) end
	for key, value in pairs(props) do object[key] = value end
	return {Play = function() end}
end

function sourceStroke(parent, color)
	local stroke = Instance.new("UIStroke", parent)
	stroke.Color = color or Theme.Border
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return stroke
end

function sourceGradient(parent, rotation, bottom)
	local gradient = Instance.new("UIGradient", parent)
	gradient.Rotation = rotation or 90
	gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), bottom or Color3.fromRGB(205, 205, 205))
	return gradient
end

function sourceText(parent, text, size, color)
	local label = Instance.new("TextLabel", parent)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.Gotham
	label.Text = tostring(text or "")
	label.TextSize = 14
	label.TextColor3 = color or Theme.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Size = size or UDim2.new(1, 0, 0, 15)
	return label
end

local function hidePopups()
	for popup in pairs(openPopups) do popup.Visible = false end
end

function setMenuAccent(color)
	Theme.Accent = color
	local function recolor(root)
		for _, object in pairs(root:GetDescendants()) do
			if object.Name == "BurmaldaAccent" then
				if object:IsA("UIStroke") then object.Color = color
				elseif object:IsA("TextLabel") or object:IsA("TextButton") then object.TextColor3 = color
				else object.BackgroundColor3 = color end
			end
		end
	end
	recolor(sg)
	pcall(function() recolor(openBtn) end)
end

local function makeColumn(page, tabName, right)
	local column = Instance.new("ScrollingFrame", page)
	column.Name = right and "Right" or "Left"
	column.Size = UDim2.new(0, 100, 0, 100)
	column.Active = true
	column.BackgroundTransparency = 1
	column.BorderSizePixel = 0
	column.CanvasSize = UDim2.new(0, 0, 0, 0)
	column.AutomaticCanvasSize = Enum.AutomaticSize.Y
	column.ScrollBarThickness = 0
	column.ScrollBarImageColor3 = Theme.Border
	column.ScrollingDirection = Enum.ScrollingDirection.Y
	column.ElasticBehavior = Enum.ElasticBehavior.Never
	local padding = Instance.new("UIPadding", column)
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 8)
	local layout = Instance.new("UIListLayout", column)
	layout.Padding = UDim.new(0, SOURCE_SECTION_GAP)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	columnSections[column] = {}
	columnTabs[column] = tabName
	return column
end

for index, name in ipairs(tabNames) do
	local button = Instance.new("TextButton", pages)
	button.Name = name .. "Tab"
	button.LayoutOrder = index
	button.Size = UDim2.new(0, 0, 1, 0)
	button.BackgroundColor3 = Theme.Inline
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.Gotham
	button.Text = name
	button.TextSize = 14
	button.TextColor3 = Theme.SubText
	sourceStroke(button)
	local underline = Instance.new("Frame", button)
	underline.Name = "BurmaldaAccent"
	underline.AnchorPoint = Vector2.new(0, 0)
	underline.Position = UDim2.new(0, 0, 0, 0)
	underline.Size = UDim2.new(1, 0, 0, 1)
	underline.BackgroundColor3 = Theme.Accent
	underline.BorderSizePixel = 0
	underline.Visible = false
	tabButtons[name], tabUnderlines[name] = button, underline

	local page = Instance.new("Frame", tabsHolder)
	page.Name = name
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	local pageLayout = Instance.new("UIListLayout", page)
	pageLayout.FillDirection = Enum.FillDirection.Horizontal
	pageLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	pageLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local left = makeColumn(page, name, false)
	local right = makeColumn(page, name, true)
	tabFrames[name] = page
	tabColumns[name] = {left, right}
end
tabFrames.VISUAL = tabFrames.VISUALS
tabFrames.ESP = tabFrames.VISUALS
tabFrames.HUD = tabFrames.MISC
tabFrames.SETTINGS = tabFrames.CONFIG
-- Keep feature-column aliases in sync with page aliases. Without these,
-- getTab("ESP")/getTab("HUD") silently fell back to CONFIG.
tabColumns.VISUAL = tabColumns.VISUALS
tabColumns.ESP = tabColumns.VISUALS
tabColumns.HUD = tabColumns.MISC
tabColumns.SETTINGS = tabColumns.CONFIG

local function canonicalTabName(name)
	if name == "VISUAL" or name == "ESP" then return "VISUALS" end
	if name == "HUD" then return "MISC" end
	if name == "SETTINGS" then return "CONFIG" end
	return name
end

local currentTab = "COMBAT"
activeFrame = tabFrames.COMBAT
function selectTab(name)
	name = canonicalTabName(name)
	if not tabFrames[name] then return end
	currentTab = name
	activeFrame = tabFrames[name]
	for _, tabName in ipairs(tabNames) do
		tabFrames[tabName].Visible = tabName == name
	end
	for tabName, button in pairs(tabButtons) do
		local selected = tabName == name
		button.TextColor3 = selected and Theme.Text or Theme.SubText
		button.BackgroundColor3 = Theme.Inline
		button.BackgroundTransparency = 1
		tabUnderlines[tabName].Visible = selected
	end
	if Runtime.OnTabChanged then Runtime.OnTabChanged(name) end
end
for name, button in pairs(tabButtons) do
	button.MouseButton1Click:Connect(function() selectTab(name) end)
end
selectTab("COMBAT")

function smartCol(left, right)
	if type(left) == "string" then
		local name = canonicalTabName(left)
		local columns = tabColumns[name] or tabColumns.CONFIG
		left, right = columns[1], columns[2]
	end
	if (left.AbsoluteSize.Y + 40) < right.AbsoluteSize.Y then return left end
	return right
end
function getTab(name)
	name = canonicalTabName(name)
	local columns = tabColumns[name] or tabColumns.CONFIG
	return columns[1], columns[2], smartCol
end

function defaultSectionName(parent, featureName)
	local existing = sectionContents[parent]
	if existing then return existing.Name end
	local tabName = columnTabs[parent] or "MISC"
	if tabName == "COMBAT" then return "Aimbot" end
	if tabName == "VISUALS" then return "Players" end
	if tabName == "WORLD" then return "World" end
	if tabName == "MOVEMENT" then return "Movement" end
	if tabName == "CONFIG" then return "Configs" end
	return "Misc"
end

function getSection(parent, sectionName)
	local existingContent = sectionContents[parent]
	if existingContent and (not sectionName or existingContent.Name == sectionName) then
		return existingContent
	end
	local column = existingContent and existingContent.Column or parent
	if not columnSections[column] then
		error("Burmalda source sections require a page column or section content", 2)
	end
	sectionName = sectionName or defaultSectionName(column, "")
	if columnSections[column][sectionName] then return columnSections[column][sectionName] end

	local section = Instance.new("Frame", column)
	section.Name = sectionName
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = Theme.Inline
	section.BorderSizePixel = 0
	sourceStroke(section)
	local bottomPadding = Instance.new("UIPadding", section)
	bottomPadding.PaddingBottom = UDim.new(0, 8)

	local topbar = Instance.new("Frame", section)
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, SOURCE_SECTION_TOPBAR)
	topbar.BackgroundColor3 = Theme.Inline
	topbar.BorderSizePixel = 0
	sourceStroke(topbar)
	sourceGradient(topbar, 90, Color3.fromRGB(165, 165, 165))
	local liner = Instance.new("Frame", topbar)
	liner.Name = "BurmaldaAccent"
	liner.Size = UDim2.new(0, 1, 1, 0)
	liner.BackgroundColor3 = Theme.Accent
	liner.BorderSizePixel = 0
	sourceGradient(liner, 90, Color3.fromRGB(171, 171, 171))
	local sectionTitle = sourceText(topbar, sectionName, UDim2.new(0, 0, 0, 15))
	sectionTitle.Name = "Title"
	sectionTitle.Position = UDim2.new(0, 8, 0.5, -1)
	sectionTitle.AnchorPoint = Vector2.new(0, 0.5)
	sectionTitle.AutomaticSize = Enum.AutomaticSize.X

	local content = Instance.new("Frame", section)
	content.Name = "Content"
	content.Position = UDim2.new(0, 8, 0, 35)
	content.Size = UDim2.new(1, -16, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.BackgroundTransparency = 1
	local contentLayout = Instance.new("UIListLayout", content)
	contentLayout.Padding = UDim.new(0, SOURCE_CONTROL_GAP)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local record = {Name = sectionName, Frame = section, Content = content, Column = column}
	columnSections[column][sectionName] = record
	sectionContents[content] = record
	return record
end

function createFeature(parent, name, default, callback, hasSettings)
	local section = getSection(parent, defaultSectionName(parent, name))
	local toggle = Instance.new("TextButton", section.Content)
	toggle.Name = name
	toggle.Size = UDim2.new(1, 0, 0, 15)
	toggle.BackgroundTransparency = 1
	toggle.BorderSizePixel = 0
	toggle.AutoButtonColor = false
	toggle.Text = ""

	local indicator = Instance.new("Frame", toggle)
	indicator.Name = "Indicator"
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.Position = UDim2.new(0, 0, 0.5, 0)
	indicator.Size = UDim2.new(0, 12, 0, 12)
	indicator.BackgroundColor3 = Theme.Element
	indicator.BorderSizePixel = 0
	sourceStroke(indicator)
	local inline = Instance.new("Frame", indicator)
	inline.Name = "BurmaldaAccent"
	inline.AnchorPoint = Vector2.new(0.5, 0.5)
	inline.Position = UDim2.new(0.5, 0, 0.5, 0)
	inline.Size = UDim2.new(1, -2, 1, -2)
	inline.BackgroundColor3 = Theme.Accent
	inline.BorderSizePixel = 0
	inline.Visible = default == true

	local label = sourceText(toggle, name, UDim2.new(0, 0, 0, 15))
	label.Name = "Label"
	label.AutomaticSize = Enum.AutomaticSize.X
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 20, 0.5, 0)
	local subElements = Instance.new("Frame", toggle)
	subElements.Name = "SubElements"
	subElements.AnchorPoint = Vector2.new(1, 0)
	subElements.Position = UDim2.new(1, 0, 0, 0)
	subElements.Size = UDim2.new(0, 0, 1, 0)
	subElements.AutomaticSize = Enum.AutomaticSize.X
	subElements.BackgroundTransparency = 1
	local subLayout = Instance.new("UIListLayout", subElements)
	subLayout.FillDirection = Enum.FillDirection.Horizontal
	subLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	subLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	subLayout.Padding = UDim.new(0, 8)
	subLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local editor = Instance.new("Frame", section.Content)
	editor.Name = name .. "_Settings"
	editor.Size = UDim2.new(1, 0, 0, 0)
	editor.AutomaticSize = Enum.AutomaticSize.Y
	editor.BackgroundTransparency = 1
	editor.Visible = false
	local editorLayout = Instance.new("UIListLayout", editor)
	editorLayout.Padding = UDim.new(0, SOURCE_CONTROL_GAP)
	editorLayout.SortOrder = Enum.SortOrder.LayoutOrder
	featureRecords[editor] = {
		Name = name, Toggle = toggle, SubElements = subElements,
		Section = section, Column = section.Column,
	}

	local state = default == true
	local function visual()
		inline.Visible = state
		label.TextTransparency = state and 0 or 0.4
	end
	_fFS[name] = function(value)
		state = value == true
		visual()
		Runtime.LastFeatureName = name
		Runtime.LastFeatureState = state
		if callback and not Runtime.Unloaded then callback(state) end
	end
	toggle.MouseButton1Click:Connect(function() _fFS[name](not state) end)
	visual()
	if callback and not Runtime.Unloaded then callback(state) end
	return editor
end

-- The source library places sub-elements on the toggle row; there are no card arrows.
_fDD.RegisterEditor = function() end

function addBind(p, name, def, onPress, onChanged)
	_fDD.RegisterEditor(p)
	local record = featureRecords[p]
	local parent = record and record.SubElements or p
	local button = Instance.new("TextButton", parent)
	button.Name = name
	button.Size = UDim2.new(0, 0, 0, 15)
	button.AutomaticSize = Enum.AutomaticSize.X
	button.BackgroundColor3 = Theme.Element
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = Theme.SubText
	button.Text = "[" .. tostring(def or "None") .. "]"
	sourceStroke(button)
	local padding = Instance.new("UIPadding", button)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)

	local boundKey, boundMouse, picking = nil, nil, false
	local pressConn, captureConn
	local function keyName()
		if boundKey then return boundKey.Name end
		if boundMouse then return boundMouse == Enum.UserInputType.MouseButton1 and "LMB" or "RMB" end
		return "None"
	end
	local function installPress(ignoreInput)
		if pressConn then pressConn:Disconnect(); pressConn = nil end
		if not (boundKey or boundMouse) then return end
		pressConn = connectUI(UIS.InputBegan, function(input, gameProcessed)
			if gameProcessed or picking or input == ignoreInput then return end
			if (boundKey and input.KeyCode == boundKey) or (boundMouse and input.UserInputType == boundMouse) then
				if onPress then onPress() end
			end
		end)
	end
	local api = {}
	function api.Get() return keyName() end
	function api.Set(value, ignoreInput)
		value = value or "None"
		boundKey, boundMouse = nil, nil
		if value == "LMB" or value == "RMB" then
			boundMouse = value == "LMB" and Enum.UserInputType.MouseButton1 or Enum.UserInputType.MouseButton2
		elseif value ~= "None" then
			boundKey = Enum.KeyCode[value]
		end
		button.Text = "[" .. value .. "]"
		installPress(ignoreInput)
		if onChanged then onChanged(api.Get()) end
	end
	button.MouseButton1Click:Connect(function()
		if picking then return end
		picking = true
		button.Text = "[...]"
		if captureConn then captureConn:Disconnect() end
		captureConn = connectUI(UIS.InputBegan, function(input, gameProcessed)
			if gameProcessed then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then api.Set("None", input)
				else api.Set(input.KeyCode.Name, input) end
				picking = false
				if captureConn then captureConn:Disconnect(); captureConn = nil end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2 then
				api.Set(input.UserInputType == Enum.UserInputType.MouseButton1 and "LMB" or "RMB", input)
				picking = false
				if captureConn then captureConn:Disconnect(); captureConn = nil end
			end
		end)
	end)
	if def and def ~= "None" then api.Set(def) end
	local featureRecord = featureRecords[p]
	Runtime.BindApis[featureRecord and featureRecord.Name or name] = api
	return api
end

function addSlider(p, name, min, max, def, callback)
	_fDD.RegisterEditor(p)
	p.Visible = true
	local row = Instance.new("Frame", p)
	row.Name = name
	row.Size = UDim2.new(1, 0, 0, 35)
	row.BackgroundTransparency = 1
	local label = sourceText(row, name, UDim2.new(1, -55, 0, 15))
	label.Position = UDim2.new(0, 0, 0, 0)
	local valueLabel = sourceText(row, tostring(def), UDim2.new(0, 55, 0, 15), Theme.SubText)
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, 0, 0, 0)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	local bar = Instance.new("TextButton", row)
	bar.Name = "Bar"
	bar.AnchorPoint = Vector2.new(0, 1)
	bar.Position = UDim2.new(0, 0, 1, 0)
	bar.Size = UDim2.new(1, 0, 0, 12)
	bar.BackgroundColor3 = Theme.Element
	bar.BorderSizePixel = 0
	bar.AutoButtonColor = false
	bar.Text = ""
	sourceStroke(bar)
	local fill = Instance.new("Frame", bar)
	fill.Name = "BurmaldaAccent"
	fill.Position = UDim2.new(0, 1, 0, 1)
	fill.Size = UDim2.new((def - min) / math.max(1, max - min), -2, 1, -2)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0

	local dragging = false
	local function setValue(value, silent)
		local integer = math.clamp(math.floor(tonumber(value)), min, max)
		valueLabel.Text = tostring(integer)
		fill.Size = UDim2.new((integer - min) / math.max(1, max - min), -2, 1, -2)
		if not silent and callback then callback(integer) end
	end
	local function update(input)
		local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
		setValue(min + (max - min) * ratio)
	end
	connectUI(bar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)
	connectUI(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	connectUI(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
	end)
	return setValue
end

function addDropdown(p, name, options, defIdx, callback)
	-- On/Off options are ordinary buttons. Keep their string values and setter
	-- registry so existing configs and programmatic controls remain compatible.
	local onValue, offValue
	if #options == 2 then
		for _, value in ipairs(options) do
			if type(value) == "string" then
				local lower = string.lower(value)
				if lower == "on" then onValue = value
				elseif lower == "off" then offValue = value end
			end
		end
		if not onValue or not offValue then onValue, offValue = nil, nil end
	end
	if onValue and offValue then
		_fDD.RegisterEditor(p)
		p.Visible = true
		local currentValue = options[defIdx] == onValue and onValue or offValue
		local row = Instance.new("Frame", p)
		row.Name = name
		row.Size = UDim2.new(1, 0, 0, 20)
		row.BackgroundTransparency = 1
		local button = Instance.new("TextButton", row)
		button.Name = "BooleanToggle"
		button.Size = UDim2.fromScale(1, 1)
		button.BackgroundColor3 = Theme.Element
		button.BackgroundTransparency = 0
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = ""
		sourceStroke(button)
		local label = sourceText(button, name, UDim2.new(1, -50, 0, 20))
		label.Name = "Label"
		label.Position = UDim2.fromOffset(5, 0)
		label.TextTransparency = currentValue == onValue and 0 or 0.4
		local stateLabel = sourceText(button, currentValue, UDim2.fromOffset(40, 20), Theme.SubText)
		stateLabel.Name = "State"
		stateLabel.AnchorPoint = Vector2.new(1, 0)
		stateLabel.Position = UDim2.new(1, -5, 0, 0)
		stateLabel.TextXAlignment = Enum.TextXAlignment.Right
		stateLabel.TextSize = 12
		local function setValue(value, silent)
			if type(value) == "boolean" then
				currentValue = value and onValue or offValue
			elseif type(value) == "string" and string.lower(value) == "on" then
				currentValue = onValue
			else
				currentValue = offValue
			end
			local enabled = currentValue == onValue
			label.TextTransparency = enabled and 0 or 0.4
			stateLabel.Text = currentValue
			stateLabel.TextColor3 = enabled and Theme.Text or Theme.SubText
			if not silent and callback then callback(currentValue) end
		end
		button.MouseButton1Click:Connect(function() setValue(currentValue ~= onValue) end)
		local key = p.Name ~= "" and (p.Name .. "_" .. name) or name
		_fDD[key] = setValue
		return setValue
	end

	_fDD.RegisterEditor(p)
	p.Visible = true
	local row = Instance.new("Frame", p)
	row.Name = name
	row.Size = UDim2.new(1, 0, 0, 45)
	row.BackgroundTransparency = 1
	local label = sourceText(row, name, UDim2.new(1, 0, 0, 15))
	local button = Instance.new("TextButton", row)
	button.Name = "Dropdown"
	button.AnchorPoint = Vector2.new(0, 1)
	button.Position = UDim2.new(0, 0, 1, 0)
	button.Size = UDim2.new(1, 0, 0, 20)
	button.BackgroundColor3 = Theme.Element
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	sourceStroke(button)
	local valueLabel = sourceText(button, options[defIdx] or options[1] or "", UDim2.new(1, -24, 0, 15), Theme.SubText)
	valueLabel.Position = UDim2.new(0, 4, 0.5, 0)
	valueLabel.AnchorPoint = Vector2.new(0, 0.5)
	valueLabel.TextSize = 12
	local arrow = sourceText(button, "▾", UDim2.new(0, 14, 0, 15), Theme.SubText)
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -5, 0.5, 0)
	arrow.TextXAlignment = Enum.TextXAlignment.Right
	arrow.TextSize = 10

	local OPTION_HEIGHT, OPTION_GAP, MAX_POPUP_HEIGHT = 18, 2, 132
	local searchable = #options > 6
	local listTop = searchable and 23 or 4
	local popupWidth = 180
	local popup = Instance.new("Frame", sg)
	popup.Name = "DropdownPopup"
	popup.Size = UDim2.new(0, popupWidth, 0, 46)
	popup.BackgroundColor3 = Theme.Inline
	popup.BorderSizePixel = 0
	popup.Visible = false
	popup.ZIndex = 20
	sourceStroke(popup)
	openPopups[popup] = true
	local search = Instance.new("TextBox", popup)
	search.Position = UDim2.new(0, 4, 0, 4)
	search.Size = UDim2.new(1, -8, 0, 15)
	search.BackgroundTransparency = 1
	search.BorderSizePixel = 0
	search.Font = Enum.Font.Gotham
	search.TextSize = 12
	search.TextColor3 = Theme.Text
	search.PlaceholderColor3 = Theme.SubText
	search.PlaceholderText = "Search.."
	search.Text = ""
	search.ClearTextOnFocus = false
	search.Visible = searchable
	search.ZIndex = 21
	local list = Instance.new("ScrollingFrame", popup)
	list.Position = UDim2.new(0, 4, 0, listTop)
	list.Size = UDim2.new(1, -8, 0, 38)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 2
	list.ScrollBarImageColor3 = Theme.Border
	list.ZIndex = 21
	local listLayout = Instance.new("UIListLayout", list)
	listLayout.Padding = UDim.new(0, OPTION_GAP)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local currentValue = options[defIdx] or options[1]
	local optionButtons = {}
	local function updatePopupSize(visibleCount)
		local contentHeight = math.max(OPTION_HEIGHT,
			visibleCount * OPTION_HEIGHT + math.max(0, visibleCount - 1) * OPTION_GAP)
		local height = math.min(MAX_POPUP_HEIGHT, listTop + contentHeight + 4)
		popup.Size = UDim2.new(0, popupWidth, 0, height)
		list.Size = UDim2.new(1, -8, 0, height - listTop - 4)
	end
	local function refreshOptions()
		local filter = string.lower(search.Text or "")
		local visibleCount = 0
		for _, entry in ipairs(optionButtons) do
			local visible = filter == "" or string.find(string.lower(entry.Value), filter, 1, true) ~= nil
			local selected = entry.Value == tostring(currentValue)
			entry.Button.Visible = visible
			entry.Button.BackgroundTransparency = selected and 0 or 1
			entry.Button.TextColor3 = selected and Theme.Text or Theme.SubText
			entry.Liner.Visible = selected
			if visible then visibleCount += 1 end
		end
		updatePopupSize(visibleCount)
	end
	local function setValue(value, silent)
		currentValue = value
		valueLabel.Text = tostring(value)
		popup.Visible = false
		refreshOptions()
		if not silent and callback then callback(value) end
	end
	for order, option in ipairs(options) do
		local optionButton = Instance.new("TextButton", list)
		optionButton.LayoutOrder = order
		optionButton.Size = UDim2.new(1, 0, 0, OPTION_HEIGHT)
		optionButton.BackgroundColor3 = Theme.Element
		optionButton.BackgroundTransparency = 1
		optionButton.BorderSizePixel = 0
		optionButton.AutoButtonColor = false
		optionButton.Font = Enum.Font.Gotham
		optionButton.TextSize = 12
		optionButton.TextColor3 = Theme.SubText
		optionButton.TextXAlignment = Enum.TextXAlignment.Left
		optionButton.Text = tostring(option)
		optionButton.ZIndex = 22
		local padding = Instance.new("UIPadding", optionButton)
		padding.PaddingLeft = UDim.new(0, 7)
		padding.PaddingRight = UDim.new(0, 4)
		local liner = Instance.new("Frame", optionButton)
		liner.Name = "BurmaldaAccent"
		liner.Size = UDim2.new(0, 1, 1, 0)
		liner.BackgroundColor3 = Theme.Accent
		liner.BorderSizePixel = 0
		liner.Visible = false
		liner.ZIndex = 23
		optionButtons[#optionButtons + 1] = {Button = optionButton, Liner = liner, Value = tostring(option)}
		optionButton.MouseButton1Click:Connect(function() setValue(option) end)
	end
	search:GetPropertyChangedSignal("Text"):Connect(refreshOptions)
	button.MouseButton1Click:Connect(function()
		if popup.Visible then popup.Visible = false return end
		hidePopups()
		local position = button.AbsolutePosition
		popupWidth = math.max(120, button.AbsoluteSize.X)
		popup.Position = UDim2.new(0, position.X, 0, position.Y + 20)
		refreshOptions()
		popup.Visible = true
	end)
	refreshOptions()
	local key = p.Name ~= "" and (p.Name .. "_" .. name) or name
	_fDD[key] = setValue
	return setValue
end

function addColor(p, name, callback, defaultColor)
	_fDD.RegisterEditor(p)
	local record = featureRecords[p]
	local parent = record and record.SubElements or p
	local swatch = Instance.new("TextButton", parent)
	swatch.Name = name
	swatch.Size = UDim2.new(0, 15, 0, 15)
	swatch.BackgroundColor3 = defaultColor or Color3.new(1, 1, 1)
	swatch.BorderSizePixel = 0
	swatch.AutoButtonColor = false
	swatch.Text = ""
	sourceStroke(swatch)
	sourceGradient(swatch, 90, Color3.fromRGB(152, 152, 152))

	local popup = Instance.new("Frame", sg)
	popup.Name = "ColorpickerPopup"
	popup.Size = UDim2.new(0, 232, 0, 265)
	popup.BackgroundColor3 = Theme.Inline
	popup.BorderSizePixel = 2
	popup.Visible = false
	popup.ZIndex = 20
	sourceStroke(popup)
	openPopups[popup] = true
	local heading = sourceText(popup, name, UDim2.new(1, -16, 0, 15))
	heading.Position = UDim2.new(0, 8, 0, 8)
	heading.ZIndex = 21
	local palette = Instance.new("Frame", popup)
	palette.Position = UDim2.new(0, 8, 0, 31)
	palette.Size = UDim2.new(1, -16, 0, 144)
	palette.BackgroundColor3 = Theme.Element
	palette.BorderSizePixel = 0
	palette.ZIndex = 21
	local hue = Instance.new("Frame", palette)
	hue.Size = UDim2.new(1, 0, 1, 0)
	hue.BackgroundColor3 = Color3.new(1, 1, 1)
	hue.BorderSizePixel = 0
	hue.ZIndex = 21
	local hueGradient = Instance.new("UIGradient", hue)
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})
	local currentColor = defaultColor or Color3.new(1, 1, 1)
	local function setColor(color, silent)
		currentColor = color
		swatch.BackgroundColor3 = color
		if not silent and callback then callback(color) end
	end
	for row = 0, 5 do
		for column = 0, 17 do
			local cell = Instance.new("TextButton", palette)
			cell.Size = UDim2.new(1 / 18, 0, 1 / 6, 0)
			cell.Position = UDim2.new(column / 18, 0, row / 6, 0)
			cell.BorderSizePixel = 0
			cell.Text = ""
			cell.ZIndex = 23
			local h = column / 18
			local v = 1 - row / 7
			cell.BackgroundColor3 = Color3.fromHSV(h, 0.85, v)
			cell.MouseButton1Click:Connect(function() setColor(cell.BackgroundColor3) end)
		end
	end
	local hexBox = Instance.new("TextBox", popup)
	hexBox.Position = UDim2.new(0, 8, 0, 187)
	hexBox.Size = UDim2.new(1, -16, 0, 20)
	hexBox.BackgroundColor3 = Theme.Element
	hexBox.BorderSizePixel = 0
	hexBox.Font = Enum.Font.Gotham
	hexBox.TextSize = 14
	hexBox.TextColor3 = Theme.Text
	hexBox.PlaceholderText = "#FFFFFF"
	hexBox.Text = ""
	hexBox.ZIndex = 21
	sourceStroke(hexBox)
	hexBox.FocusLost:Connect(function()
		local value = hexBox.Text:gsub("#", "")
		if #value == 6 then
			local r, g, b = tonumber(value:sub(1, 2), 16), tonumber(value:sub(3, 4), 16), tonumber(value:sub(5, 6), 16)
			if r and g and b then setColor(Color3.fromRGB(r, g, b)) end
		end
	end)
	local applyButton = Instance.new("TextButton", popup)
	applyButton.Position = UDim2.new(0, 8, 1, -35)
	applyButton.Size = UDim2.new(1, -16, 0, 20)
	applyButton.BackgroundColor3 = Theme.Element
	applyButton.BorderSizePixel = 0
	applyButton.Font = Enum.Font.Gotham
	applyButton.TextSize = 14
	applyButton.TextColor3 = Theme.Text
	applyButton.Text = "Apply"
	applyButton.ZIndex = 21
	sourceStroke(applyButton)
	applyButton.MouseButton1Click:Connect(function()
		setColor(currentColor)
		popup.Visible = false
	end)
	swatch.MouseButton1Click:Connect(function()
		if popup.Visible then popup.Visible = false return end
		hidePopups()
		local position = swatch.AbsolutePosition
		popup.Position = UDim2.new(0, math.max(0, position.X - 217), 0, position.Y + 18)
		popup.Visible = true
	end)
	return setColor
end

menuOpen = true
Runtime.MenuOpen = true
main.Visible = true
openBtn.Visible = false

function toggleMenu(viaSHIFT)
	menuOpen = not menuOpen
	Runtime.MenuOpen = menuOpen
	hidePopups()
	if menuOpen then
		main.Visible = true
		openBtn.Visible = false
		if UIAnimations then
			main.BackgroundTransparency = 0.3
			mainScale.Scale = baseMenuScale * 0.94
			uiTween(main, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
			uiTween(mainScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = baseMenuScale}):Play()
		else
			main.BackgroundTransparency = 0
			mainScale.Scale = baseMenuScale
		end
	else
		main.Visible = false
		openBtn.Visible = true
	end
end
connectUI(openBtn.MouseButton1Click, function() toggleMenu() end)
connectUI(UIS.InputBegan, function(input, gameProcessed)
	if gameProcessed or Runtime.Unloaded then return end
	if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu(true) end
end)

-- Drag the source window by its 39px title bar.
do
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	local function finishDrag() dragging = false end
	connectUI(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then finishDrag() end
			end)
		end
	end)
	connectUI(header.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	connectUI(UIS.InputChanged, function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	connectUI(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then finishDrag() end
	end)
end

-- The reference window is resizeable; preserve its 621x542 minimum.
do
	local resize = Instance.new("TextButton", main)
	resize.Name = "Resize"
	resize.AnchorPoint = Vector2.new(1, 1)
	resize.Position = UDim2.new(1, 0, 1, 0)
	resize.Size = UDim2.new(0, 12, 0, 12)
	resize.BackgroundTransparency = 1
	resize.Text = ""
	resize.ZIndex = 10
	local resizing, startInput, startSize = false, nil, nil
	connectUI(resize.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startInput = input.Position
			startSize = main.Size
		end
	end)
	connectUI(UIS.InputChanged, function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startInput
			main.Size = UDim2.new(0, math.max(SOURCE_WINDOW_WIDTH, startSize.X.Offset + delta.X), 0,
				math.max(SOURCE_WINDOW_HEIGHT, startSize.Y.Offset + delta.Y))
		end
	end)
	connectUI(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
	end)
end

onCleanup(function()
	Runtime.Unloaded = true
	hidePopups()
end)

if Runtime.StartClosed and menuOpen then toggleMenu() end
end

do
	local Shared = {}
	local Entities = {NPCs = {}, Heli = nil, Scanning = false, ScanList = {}, ScanIndex = 1, Working = {}, NextScan = 0}
	local Team = {Ids = {}, Folder = nil, Next = 0}
	Runtime.Shared = Shared
	Runtime.Entities = Entities
	Runtime.TeamCache = Team

	function Shared.Character()
		return LocalPlayer and LocalPlayer.Character or nil
	end

	function Shared.Root(character)
		character = character or Shared.Character()
		if not character then return nil end
		return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	end

	function Shared.Humanoid(character)
		character = character or Shared.Character()
		return character and character:FindFirstChildOfClass("Humanoid") or nil
	end

	function Shared.FindPart(model, candidates)
		if not model then return nil end
		if model:IsA("BasePart") then return model end
		if candidates then
			for _, name in ipairs(candidates) do
				local child = model:FindFirstChild(name)
				if child and child:IsA("BasePart") then return child end
			end
		end
		local primary = model.PrimaryPart
		if primary and primary:IsA("BasePart") then return primary end
		for _, child in ipairs(model:GetChildren()) do
			if child:IsA("BasePart") then return child end
		end
		for _, child in ipairs(model:GetDescendants()) do
			if child:IsA("BasePart") then return child end
		end
		return nil
	end

	function Shared.Project(position)
		if not Camera or not position then return nil end
		local ok, point, onScreen = pcall(Camera.WorldToViewportPoint, Camera, position)
		if not ok or not point then return nil end
		local visible = point.Z > 0 and (onScreen == nil or onScreen == true)
		return point.X, point.Y, point.Z, visible
	end

	function Shared.ToolName(character)
		character = character or Shared.Character()
		local tool = character and character:FindFirstChildOfClass("Tool")
		return tool and tool.Name or ""
	end

	local function updateTeam()
		Team.Next = os.clock() + 1
		table.clear(Team.Ids)
		Team.Folder = nil
		local folder = Camera and Camera:FindFirstChild("FustTeamTags") or workspace:FindFirstChild("FustTeamTags")
		Team.Folder = folder
		if not folder then return end
		for _, child in ipairs(folder:GetChildren()) do
			local name = child.Name
			if string.sub(name, 1, 3) == "Tag" then
				local userId = tonumber(string.sub(name, 4))
				if userId then Team.Ids[userId] = true end
			end
		end
	end

	function Shared.IsTeammate(player)
		if not player then return false end
		if player == LocalPlayer then return true end
		if os.clock() >= Team.Next then updateTeam() end
		local userId = player.UserId
		if Team.Folder then return userId ~= nil and Team.Ids[userId] == true end
		if player.Neutral or LocalPlayer.Neutral then return false end
		return player.Team ~= nil and player.Team == LocalPlayer.Team
	end

	function Shared.WallClear(position, targetModel)
		if not Camera then return false end
		local origin = Camera.CFrame.Position
		local direction = position - origin
		if direction.Magnitude <= 0.01 then return true end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {Shared.Character()}
		params.IgnoreWater = true
		local ok, result = pcall(workspace.Raycast, workspace, origin, direction, params)
		if not ok then return true end
		if not result or not result.Instance then return true end
		if targetModel and result.Instance:IsDescendantOf(targetModel) then return true end
		return false
	end

	local function rigEntry(model)
		local humanoid = Shared.Humanoid(model)
		if not humanoid then return nil end
		local root = Shared.Root(model)
		if not root then return nil end
		local head = model:FindFirstChild("Head") or root
		return {
			Kind = "NPC",
			Model = model,
			Humanoid = humanoid,
			Root = root,
			Head = head,
			Name = model.Name,
		}
	end

	local function heliEntry()
		local folder = workspace:FindFirstChild("FustPatrolHeli")
		if not folder then return nil end
		local model = folder:FindFirstChild("PatrolHeliModel") or folder:FindFirstChild("PatrolHeli") or folder
		local root = Shared.FindPart(model, {"Engine", "Body", "Fuselage", "MainRotor", "Frame"})
		if not root then return nil end
		return {
			Kind = "Heli",
			Model = model,
			Root = root,
			Head = root,
			Name = "Patrol Helicopter",
			Health = 5000,
			MaxHealth = 5000,
		}
	end

	local function npcFolder()
		local folder = workspace:FindFirstChild("Npcs")
		if folder then return folder end
		for _, child in ipairs(workspace:GetChildren()) do
			if string.find(string.lower(child.Name), "npc", 1, true) then return child end
		end
		return nil
	end

	function Entities.Update()
		local needNPC = S.NPCESP or S.AimNPC or S.TriggerNPC or S.SilentNPC
		local needHeli = (S.NPCESP and S.NPCHeli) or S.AimHeli
		if not needNPC and not needHeli then
			if #Entities.NPCs > 0 or Entities.Heli then Entities.NPCs = {}; Entities.Heli = nil end
			Entities.Scanning = false
			return
		end
		local now = os.clock()
		if now >= Entities.NextScan and not Entities.Scanning then
			Entities.NextScan = now + 0.8
			Entities.Heli = needHeli and heliEntry() or nil
			if needNPC then
				local folder = npcFolder()
				Entities.ScanList = folder and folder:GetChildren() or {}
				Entities.ScanIndex = 1
				Entities.Working = {}
				Entities.Scanning = true
			else
				Entities.NPCs = {}
			end
		end
		if not Entities.Scanning then return end
		local budget = 8
		local list = Entities.ScanList
		while budget > 0 and Entities.ScanIndex <= #list do
			local model = list[Entities.ScanIndex]
			Entities.ScanIndex += 1
			budget -= 1
			local entry = rigEntry(model)
			if entry then table.insert(Entities.Working, entry) end
		end
		if Entities.ScanIndex > #list then
			Entities.NPCs = Entities.Working
			Entities.Scanning = false
			Entities.ScanList = {}
			Entities.Working = {}
		end
	end

	function Shared.NPCTargets()
		return Entities.NPCs
	end

	onCleanup(function()
		Entities.NPCs = {}
		Entities.Heli = nil
		Entities.Scanning = false
		table.clear(Team.Ids)
	end)
end

do
	local Shared = Runtime.Shared
	local World = {
		Entries = {},
		Tasks = {},
		TaskIndex = 1,
		ChildIndex = 1,
		Children = nil,
		Active = false,
		NextScan = 0,
		Working = {},
		Seen = {},
	}
	Runtime.World = World

	World.Categories = {
		Loot = {Master = "LootESP", Range = "LootRange", Distance = "LootDistance", Color = "Loot"},
		Base = {Master = "BaseESP", Range = "BaseRange", Distance = "BaseDistance", Color = "Base"},
		Drops = {Master = "DropsESP", Range = "DropsRange", Distance = "DropsDistance", Color = "Drops"},
		Nodes = {Master = "NodesESP", Range = "NodesRange", Distance = "NodesDistance", Color = "Nodes"},
		Pickups = {Master = "PickupsESP", Range = "PickupsRange", Distance = "PickupsDistance", Color = "Pickups"},
		Vehicles = {Master = "VehiclesESP", Range = "VehiclesRange", Distance = "VehiclesDistance", Color = "Vehicles"},
	}

	local lootRules = {
		{"barrel", "LootBarrels", "Loot Barrel"},
		{"elite", "LootElite", "Elite Crate"},
		{"military", "LootMilitary", "Military Crate"},
		{"crate", "LootCrates", "Loot Crate"},
	}
	local baseRules = {
		{"largebox", "BaseBoxes", "Large Box"},
		{"woodenbox", "BaseBoxes", "Small Box"},
		{"toolcupboard", "BaseCupboard", "Tool Cupboard"},
		{"cupboard", "BaseCupboard", "Tool Cupboard"},
		{"locker", "BaseLocker", "Locker"},
		{"sleepingbag", "BaseSleepingBag", "Sleeping Bag"},
		{"sleeping_bag", "BaseSleepingBag", "Sleeping Bag"},
		{"shotguntrap", "BaseTraps", "Shotgun Trap"},
		{"autoturret", "BaseTraps", "Auto Turret"},
		{"aaturret", "BaseTraps", "AA Turret"},
	}
	local nodeRules = {
		{"stone", "NodeStone", "Stone Node"},
		{"sulfur", "NodeSulfur", "Sulfur Node"},
		{"metal", "NodeMetal", "Metal Node"},
		{"iron", "NodeMetal", "Metal Node"},
	}
	local plantRules = {
		{"hemp", "Hemp (Cloth)"},
		{"corn", "Corn"},
		{"pumpkin", "Pumpkin"},
		{"berry", "Berries"},
		{"mushroom", "Mushroom"},
		{"carrot", "Carrot"},
		{"potato", "Potato"},
		{"apple", "Apple"},
	}
	local vehicleRules = {
		{"atv", "VehicleATV", "ATV", {"Chassis", "Hull", "Seat"}},
		{"rowboat", "VehicleBoats", "Rowboat", {"Hull", "Seat"}},
		{"rhib", "VehicleBoats", "RHIB", {"Hull", "Seat"}},
		{"tugboat", "VehicleBoats", "Tugboat", {"Hull", "Seat"}},
		{"boat", "VehicleBoats", "Boat", {"Hull", "Seat"}},
		{"minicopter", "VehicleHelis", "Minicopter", {"Frame", "Floor", "Body", "Chassis", "Engine", "Seat", "MainRotor"}},
		{"scrapheli", "VehicleHelis", "Scrap Heli", {"Body", "Chassis", "Frame", "Engine", "MainRotor"}},
		{"helicopter", "VehicleHelis", "Helicopter", {"Body", "Chassis", "Frame", "Engine", "MainRotor"}},
	}

	local function bagLabel(lower)
		if string.find(lower, "sleepingbag", 1, true) or string.find(lower, "sleeping_bag", 1, true) then return nil end
		if string.find(lower, "corpse", 1, true) or string.find(lower, "deadbody", 1, true)
			or string.find(lower, "dead_body", 1, true) or string.find(lower, "ragdoll", 1, true) then
			return "Dead Body"
		end
		for _, pattern in ipairs({"backpack", "lootsack", "loot_bag", "lootbag", "bodybag", "body_bag", "deathbag", "pack"}) do
			if string.find(lower, pattern, 1, true) then return "Body Bag" end
		end
		return nil
	end

	local function add(categoryName, model, label, candidates)
		if World.Seen[model] or #World.Working >= 512 then return end
		World.Seen[model] = true
		local part = Shared.FindPart(model, candidates)
		if not part then return end
		table.insert(World.Working, {Category = categoryName, Model = model, Part = part, Label = label})
	end

	local function classifyLootBase(model)
		local lower = string.lower(model.Name)
		for _, rule in ipairs(lootRules) do
			if string.find(lower, rule[1], 1, true) then
				if S.LootESP and S[rule[2]] then add("Loot", model, rule[3]) else World.Seen[model] = true end
				return
			end
		end
		for _, rule in ipairs(baseRules) do
			if string.find(lower, rule[1], 1, true) then
				if S.BaseESP and S[rule[2]] then add("Base", model, rule[3]) else World.Seen[model] = true end
				return
			end
		end
		if S.DropsESP and S.BodyBags then
			local label = bagLabel(lower)
			if label then add("Drops", model, label) end
		end
	end

	local function classify(kind, model)
		if World.Seen[model] then return end
		local lower = string.lower(model.Name)
		if kind == "LootBase" then
			classifyLootBase(model)
		elseif kind == "Bags" then
			if S.BodyBags then
				local label = bagLabel(lower)
				if label then add("Drops", model, label) end
			end
		elseif kind == "Top" then
			local label = bagLabel(lower)
			if label then
				if S.BodyBags then add("Drops", model, label) end
			elseif model:IsA("Tool") and S.DroppedItems then
				add("Drops", model, model.Name)
			end
		elseif kind == "Dropped" then
			if S.DroppedItems and not bagLabel(lower) then add("Drops", model, model.Name) end
		elseif kind == "Nodes" then
			for _, rule in ipairs(nodeRules) do
				if string.find(lower, rule[1], 1, true) then
					if S[rule[2]] then add("Nodes", model, rule[3]) end
					return
				end
			end
		elseif kind == "Pickups" then
			if S.PickupOres and (string.find(lower, "stone", 1, true) or string.find(lower, "ore", 1, true)) then
				local label = string.find(lower, "sulfur", 1, true) and "Sulfur Pickup"
					or string.find(lower, "metal", 1, true) and "Metal Pickup" or "Stone Pickup"
				add("Pickups", model, label)
				return
			end
			if S.PickupPlants then
				for _, rule in ipairs(plantRules) do
					if string.find(lower, rule[1], 1, true) then add("Pickups", model, rule[2]); return end
				end
			end
			if S.PickupWood and (string.find(lower, "wood", 1, true) or string.find(lower, "log", 1, true)) then
				add("Pickups", model, "Wood Pile")
			end
		elseif kind == "Vehicles" then
			for _, rule in ipairs(vehicleRules) do
				if string.find(lower, rule[1], 1, true) then
					if S[rule[2]] then add("Vehicles", model, rule[3], rule[4]) end
					return
				end
			end
		end
	end

	local function task(kind, folder)
		if folder then table.insert(World.Tasks, {Kind = kind, Folder = folder}) end
	end

	local function buildTasks()
		World.Tasks = {}
		World.TaskIndex = 1
		World.ChildIndex = 1
		World.Children = nil
		World.Working = {}
		World.Seen = {}
		if S.LootESP or S.BaseESP or (S.DropsESP and S.BodyBags) then
			task("LootBase", workspace:FindFirstChild("Loot"))
			task("LootBase", workspace:FindFirstChild("Deployables"))
		end
		if S.DropsESP and S.BodyBags then
			for _, name in ipairs({"WorldItems", "DroppedItems", "Dropped", "Debris", "Corpses", "DeadBodies", "Bags", "Dead", "LootBags", "DeathBags"}) do
				task("Bags", workspace:FindFirstChild(name))
			end
		end
		if S.DropsESP and (S.BodyBags or S.DroppedItems) then task("Top", workspace) end
		if S.DropsESP and S.DroppedItems then
			for _, name in ipairs({"WorldItems", "DroppedItems", "Dropped", "Debris", "LooseItems", "ItemDrops", "Drops"}) do
				task("Dropped", workspace:FindFirstChild(name))
			end
		end
		if S.NodesESP then task("Nodes", workspace:FindFirstChild("Nodes") or workspace:FindFirstChild("OreNodes")) end
		if S.PickupsESP then
			task("Pickups", workspace:FindFirstChild("Pickups") or workspace:FindFirstChild("SpawnedPickups") or workspace:FindFirstChild("GroundItems"))
		end
		if S.VehiclesESP then
			for _, name in ipairs({"FustAtvs", "FustBoats", "FustMinicopters", "FustMinicopter", "FustCars", "FustVehicles"}) do
				task("Vehicles", workspace:FindFirstChild(name))
			end
		end
		World.Active = #World.Tasks > 0
		if not World.Active then World.Entries = {} end
	end

	local function enabled()
		return S.LootESP or S.BaseESP or S.DropsESP or S.NodesESP or S.PickupsESP or S.VehiclesESP
	end

	function World.ForceScan()
		World.Active = false
		World.Children = nil
		World.Tasks = {}
		World.NextScan = 0
	end

	function World.Update()
		if not enabled() then
			if #World.Entries > 0 then World.Entries = {} end
			World.Active = false
			return
		end
		local now = os.clock()
		if not World.Active and now >= World.NextScan then buildTasks() end
		if not World.Active then return end
		local budget = 24
		while budget > 0 and World.Active do
			local current = World.Tasks[World.TaskIndex]
			if not current then
				World.Entries = World.Working
				World.Working = {}
				World.Active = false
				World.NextScan = now + 1
				Runtime.Diagnostics.WorldEntries = #World.Entries
				break
			end
			if not World.Children then
				World.Children = current.Folder:GetChildren()
				World.ChildIndex = 1
			end
			local child = World.Children[World.ChildIndex]
			if child then
				World.ChildIndex += 1
				budget -= 1
				classify(current.Kind, child)
			else
				World.Children = nil
				World.TaskIndex += 1
			end
		end
	end

	onCleanup(function()
		World.Entries = {}
		World.Tasks = {}
		World.Active = false
	end)
end

do
	local Weapons = {
		Dirty = false,
		Candidates = {},
		Originals = setmetatable({}, {__mode = "k"}),
		NextApply = 0,
		Retry = 0,
		Status = "off",
	}
	Runtime.Weapons = Weapons
	local cleanKeys = {"spread", "sway", "kickRoll", "adsKick", "bloom", "shakeDur"}
	local managedKeys = {"rate", "spread", "sway", "kickRoll", "adsKick", "bloom", "shakeDur"}

	local function isWeaponTable(value)
		if type(value) ~= "table" or type(rawget(value, "rate")) ~= "number" then return false end
		local score = 0
		for _, key in ipairs(cleanKeys) do
			if type(rawget(value, key)) == "number" then score += 1 end
		end
		return score >= 2 or (score >= 1 and (rawget(value, "rounds") ~= nil or rawget(value, "mag") ~= nil or rawget(value, "reload") ~= nil))
	end

	local function scan()
		Weapons.Candidates = {}
		if type(getgc) ~= "function" then
			Weapons.Status = "getgc unavailable"
			return false
		end
		local ok, values = pcall(getgc, true)
		if not ok or type(values) ~= "table" then ok, values = pcall(getgc) end
		if not ok or type(values) ~= "table" then
			Weapons.Status = "getgc failed"
			return false
		end
		for _, value in pairs(values) do
			if isWeaponTable(value) then table.insert(Weapons.Candidates, value) end
		end
		Runtime.Diagnostics.WeaponTables = #Weapons.Candidates
		return #Weapons.Candidates > 0
	end

	local function write(value, key, newValue)
		local readonly = false
		if type(isreadonly) == "function" then
			local ok, result = pcall(isreadonly, value)
			readonly = ok and result == true
		end
		if readonly and type(setreadonly) == "function" then pcall(setreadonly, value, false) end
		local ok = pcall(rawset, value, key, newValue)
		if readonly and type(setreadonly) == "function" then pcall(setreadonly, value, true) end
		return ok and rawget(value, key) == newValue
	end

	local function desired(key)
		if not S.WeaponPatches then return nil end
		if key == "rate" and S.WeaponFireRate then return S.FireInterval / 1000 end
		if S.WeaponClean then
			for _, cleanKey in ipairs(cleanKeys) do
				if key == cleanKey then return 0 end
			end
		end
		return nil
	end

	local function restoreKey(value, key)
		local saved = Weapons.Originals[value]
		if not saved or saved[key] == nil then return false end
		local ok = write(value, key, saved[key])
		if ok then saved[key] = nil end
		return ok
	end

	local function apply()
		local seen = {}
		local writes = 0
		for _, value in ipairs(Weapons.Candidates) do
			seen[value] = true
			for _, key in ipairs(managedKeys) do
				local newValue = desired(key)
				local current = rawget(value, key)
				if newValue ~= nil and type(current) == "number" then
					local saved = Weapons.Originals[value]
					if not saved then saved = {}; Weapons.Originals[value] = saved end
					if saved[key] == nil then saved[key] = current end
					if current ~= newValue and write(value, key, newValue) then writes += 1 end
				elseif Weapons.Originals[value] and Weapons.Originals[value][key] ~= nil then
					if restoreKey(value, key) then writes += 1 end
				end
			end
		end
		for value in pairs(Weapons.Originals) do
			if not seen[value] then
				for _, key in ipairs(managedKeys) do restoreKey(value, key) end
			end
		end
		Runtime.Diagnostics.WeaponWrites = (Runtime.Diagnostics.WeaponWrites or 0) + writes
		Weapons.Status = #Weapons.Candidates > 0 and "applied" or "no weapon tables"
	end

	function Weapons.MarkDirty()
		Weapons.Dirty = true
		Weapons.NextApply = os.clock() + 0.35
	end

	function Weapons.Restore()
		for value in pairs(Weapons.Originals) do
			for _, key in ipairs(managedKeys) do restoreKey(value, key) end
		end
		Weapons.Originals = setmetatable({}, {__mode = "k"})
		Weapons.Candidates = {}
		Weapons.Dirty = false
		Weapons.Status = "off"
		Runtime.Diagnostics.WeaponTables = 0
	end

	function Weapons.Update()
		local active = S.WeaponPatches and (S.WeaponFireRate or S.WeaponClean)
		if not active then
			if Weapons.Status ~= "off" then Weapons.Restore() end
			return
		end
		local now = os.clock()
		if not Weapons.Dirty and #Weapons.Candidates > 0 then return end
		if now < Weapons.NextApply or (not Weapons.Dirty and now < Weapons.Retry) then return end
		Weapons.Dirty = false
		scan()
		apply()
		Weapons.Retry = now + 3
		Weapons.NextApply = now + 0.35
	end

	onCleanup(function() Weapons.Restore() end)
end

do
	local Shared = Runtime.Shared
	local Movement = {NoclipOriginals = setmetatable({}, {__mode = "k"})}
	Runtime.Movement = Movement

	function Movement.Restore()
		for part, canCollide in pairs(Movement.NoclipOriginals) do
			pcall(function() part.CanCollide = canCollide end)
		end
		Movement.NoclipOriginals = setmetatable({}, {__mode = "k"})
	end

	function Movement.Update()
		local character = Shared.Character()
		local humanoid = Shared.Humanoid(character)
		local root = Shared.Root(character)
		if not character or not humanoid or not root or humanoid.Health <= 0 then return end
		if S.Speed and not humanoid.Sit then
			local direction = humanoid.MoveDirection
			if direction.Magnitude > 0.05 then
				direction = direction.Unit
				local velocity = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(direction.X * S.SpeedValue, velocity.Y, direction.Z * S.SpeedValue)
			end
		end
		if S.Noclip then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					if Movement.NoclipOriginals[part] == nil then Movement.NoclipOriginals[part] = part.CanCollide end
					part.CanCollide = false
				end
			end
		end
	end

	local jumpConnection = UIS.JumpRequest:Connect(function()
		if Runtime.Unloaded or not S.HighJump then return end
		local root = Shared.Root()
		local humanoid = Shared.Humanoid()
		if not root or not humanoid or humanoid.Health <= 0 then return end
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, S.JumpHeight, velocity.Z)
	end)
	onCleanup(function()
		if jumpConnection then pcall(function() jumpConnection:Disconnect() end); jumpConnection = nil end
	end)

	local characterConnection = LocalPlayer.CharacterAdded:Connect(function()
		Movement.NoclipOriginals = setmetatable({}, {__mode = "k"})
	end)
	onCleanup(function()
		if characterConnection then pcall(function() characterConnection:Disconnect() end); characterConnection = nil end
	end)
	onCleanup(function() Movement.Restore() end)
end

do
	local Environment = {
		GrassSaved = false,
		GrassOriginal = nil,
		LowSaved = false,
		ShadowOriginal = nil,
		QualityOriginal = nil,
		WaterOriginal = nil,
		Effects = setmetatable({}, {__mode = "k"}),
		Scanning = false,
		ScanList = {},
		ScanIndex = 1,
		NextScan = 0,
	}
	Runtime.Environment = Environment

	local effectClasses = {
		ParticleEmitter = true, Smoke = true, Fire = true, Sparkles = true,
		BloomEffect = true, BlurEffect = true, SunRaysEffect = true,
		ColorCorrectionEffect = true, DepthOfFieldEffect = true, Clouds = true,
	}

	local function terrain()
		return workspace.Terrain or workspace:FindFirstChildOfClass("Terrain")
	end

	local function setDecoration(value)
		local land = terrain()
		if not land then return end
		if type(sethiddenproperty) == "function" then
			local ok = pcall(sethiddenproperty, land, "Decoration", value)
			if ok then return end
		end
		pcall(function() land.Decoration = value end)
	end

	local function getDecoration()
		local land = terrain()
		if not land then return nil end
		if type(gethiddenproperty) == "function" then
			local ok, value = pcall(gethiddenproperty, land, "Decoration")
			if ok then return value end
		end
		return land.Decoration
	end

	local function restoreEffects()
		for object, enabled in pairs(Environment.Effects) do
			pcall(function() object.Enabled = enabled end)
		end
		Environment.Effects = setmetatable({}, {__mode = "k"})
		Environment.Scanning = false
		Environment.ScanList = {}
	end

	local function restoreLow()
		if Environment.LowSaved then
			pcall(function() Lighting.GlobalShadows = Environment.ShadowOriginal end)
			if Environment.QualityOriginal ~= nil then
				pcall(function() settings().Rendering.QualityLevel = Environment.QualityOriginal end)
			end
			local land = terrain()
			if land and Environment.WaterOriginal then
				for key, value in pairs(Environment.WaterOriginal) do pcall(function() land[key] = value end) end
			end
		end
		Environment.LowSaved = false
		Environment.WaterOriginal = nil
		restoreEffects()
	end

	function Environment.Apply()
		local land = terrain()
		if land and not Environment.GrassSaved then
			Environment.GrassOriginal = getDecoration()
			Environment.GrassSaved = true
		end
		if Environment.GrassSaved then
			if S.HideGrass or S.LowPC then setDecoration(false) else setDecoration(Environment.GrassOriginal) end
		end
		if S.LowPC then
			if not Environment.LowSaved then
				Environment.LowSaved = true
				Environment.ShadowOriginal = Lighting.GlobalShadows
				pcall(function() Environment.QualityOriginal = settings().Rendering.QualityLevel end)
				if land then
					Environment.WaterOriginal = {
						WaterWaveSize = land.WaterWaveSize,
						WaterWaveSpeed = land.WaterWaveSpeed,
						WaterReflectance = land.WaterReflectance,
					}
				end
			end
			pcall(function() Lighting.GlobalShadows = false end)
			pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
			if land then
				pcall(function()
					land.WaterWaveSize = 0
					land.WaterWaveSpeed = 0
					land.WaterReflectance = 0
				end)
			end
			Environment.NextScan = 0
		else
			restoreLow()
		end
	end

	function Environment.Restore()
		if Environment.GrassSaved then setDecoration(Environment.GrassOriginal) end
		Environment.GrassSaved = false
		Environment.GrassOriginal = nil
		restoreLow()
	end

	local function beginScan()
		Environment.ScanList = Lighting:GetDescendants()
		for _, object in ipairs(workspace:GetDescendants()) do table.insert(Environment.ScanList, object) end
		Environment.ScanIndex = 1
		Environment.Scanning = true
	end

	function Environment.Update()
		if not S.LowPC then return end
		local now = os.clock()
		if not Environment.Scanning and now >= Environment.NextScan then
			Environment.NextScan = now + 5
			beginScan()
		end
		if not Environment.Scanning then return end
		local budget = 40
		while budget > 0 and Environment.ScanIndex <= #Environment.ScanList do
			local object = Environment.ScanList[Environment.ScanIndex]
			Environment.ScanIndex += 1
			budget -= 1
			if effectClasses[object.ClassName] then
				if Environment.Effects[object] == nil then Environment.Effects[object] = object.Enabled end
				pcall(function() object.Enabled = false end)
			end
		end
		if Environment.ScanIndex > #Environment.ScanList then
			Environment.Scanning = false
			Environment.ScanList = {}
		end
	end

	onCleanup(function() Environment.Restore() end)
end

do
	local Shared = Runtime.Shared
	local Aim = {
		CurrentTarget = nil, CurrentPart = nil, CurrentScreen = nil, TriggerStatus = "off",
		SilentTarget = nil, SilentPart = nil, SilentAt = 0, SilentNextScan = 0,
		SilentStatus = "off", SilentHookStatus = "not installed",
	}
	Runtime.Aim = Aim

	local boneSets = {
		Head = {"Head"},
		Body = {"UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart"},
		Root = {"HumanoidRootPart", "Torso", "UpperTorso"},
		Closest = {"Head", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart",
			"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
			"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"},
	}
	local gunBallistics = {
		{"lr sniper", 2600, 24}, {"bolt action", 2200, 30}, {"l96", 2600, 24},
		{"semi-automatic rifle", 1425, 8}, {"semi auto rifle", 1425, 8},
		{"assault rifle", 1350, 8}, {"scar", 1450, 8}, {"m249", 1400, 8},
		{"drum smg", 880, 8}, {"tactical smg", 950, 8}, {"custom smg", 900, 8},
		{"dino hunt smg", 900, 8}, {"hunt smg", 900, 8}, {"lever carbine", 1250, 8},
		{"double barrel", 520, 15}, {"pump shotgun", 560, 15}, {"pipe shotgun", 560, 15},
		{"revolver", 950, 8}, {"service pistol", 950, 8}, {"semi-auto pistol", 900, 8},
		{"semi auto pistol", 900, 8}, {"shotgun", 560, 15}, {"smg", 900, 8},
		{"sniper", 2600, 24}, {"carbine", 1250, 8}, {"machine gun", 1400, 8},
		{"rifle", 1425, 8}, {"pistol", 900, 8}, {"rocket launcher", 80, 8},
	}
	local bowBallistics = {
		{"crossbow", 320, 0, 28}, {"compound", 120, 170, 40}, {"hunting", 95, 125, 50}, {"bow", 95, 125, 50},
	}

	local aimOptions = {FOV = 160, Range = 1500, PartMode = "Head"}
	local silentOptions = {FOV = 240, Range = 1500, PartMode = "Head", Priority = "Crosshair"}
	local triggerOptions = {FOV = 6, Range = 1500, PartMode = "Closest", Priority = "Crosshair"}
	local aimBest, silentBest, triggerBest = {}, {}, {}
	local fovCircle = newDrawing("Circle")
	local targetLine = newDrawing("Line")
	if fovCircle then
		fovCircle.NumSides = 48
		fovCircle.Thickness = 1
		fovCircle.Filled = false
		fovCircle.Transparency = 1
	end
	if targetLine then targetLine.Thickness = 1; targetLine.Transparency = 1 end

	local function keyDown(key)
		if key == "Always" then return true end
		if key == "RMB" or key == "LMB" then
			local button = key == "RMB" and Enum.UserInputType.MouseButton2 or Enum.UserInputType.MouseButton1
			local ok, down = pcall(UIS.IsMouseButtonPressed, UIS, button)
			return ok and down == true
		end
		local code = key == "LeftAlt" and Enum.KeyCode.LeftAlt or key == "LeftControl" and Enum.KeyCode.LeftControl or nil
		if not code then return false end
		local ok, down = pcall(UIS.IsKeyDown, UIS, code)
		return ok and down == true
	end

	local function resetBest(best)
		best.Score = math.huge
		best.Target = nil
		best.Part = nil
		best.Position = nil
		best.ScreenX = nil
		best.ScreenY = nil
	end

	local function consider(model, root, humanoid, player, kind, name, options, best, healthOverride)
		if not model or not root or not Camera then return end
		if humanoid and humanoid.Health <= 0 then return end
		if player and options.TeamCheck and Shared.IsTeammate(player) then return end
		local origin = Camera.CFrame.Position
		local parts = kind == "Heli" and {root} or boneSets[options.PartMode] or boneSets.Head
		local bestPart, bestPosition, bestX, bestY, bestScreenDistance, bestDistance
		for _, candidate in ipairs(parts) do
			local part = candidate
			if type(candidate) == "string" then part = model:FindFirstChild(candidate) end
			if part and part:IsA("BasePart") then
				local position = part.Position
				local distance = (position - origin).Magnitude
				if distance <= options.Range then
					local x, y, _, visible = Shared.Project(position)
					if visible then
						local dx, dy = x - Camera.ViewportSize.X * 0.5, y - Camera.ViewportSize.Y * 0.5
						local screenDistance = math.sqrt(dx * dx + dy * dy)
						if screenDistance <= options.FOV and (not bestScreenDistance or screenDistance < bestScreenDistance) then
							bestPart, bestPosition = part, position
							bestX, bestY = x, y
							bestScreenDistance, bestDistance = screenDistance, distance
						end
					end
				end
			end
		end
		if not bestPart then return end
		local health = humanoid and humanoid.Health or healthOverride or 100
		local score = bestScreenDistance
		if options.Priority == "Distance" then score = bestDistance + bestScreenDistance * 0.0001
		elseif options.Priority == "Low HP" then score = health + bestScreenDistance * 0.0001 end
		if options.PlayersFirst and not player then score += 1000000 end
		if score >= best.Score then return end
		if options.WallCheck and not Shared.WallClear(bestPosition, model) then return end
		best.Score = score
		best.Target = {
			Model = model, Root = root, Humanoid = humanoid, Player = player,
			Kind = kind, Name = name, Health = health,
		}
		best.Part = bestPart
		best.Position = bestPosition
		best.ScreenX, best.ScreenY = bestX, bestY
	end

	local function selectTarget(options, best)
		resetBest(best)
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local character = player.Character
				local humanoid = Shared.Humanoid(character)
				local root = Shared.Root(character)
				if character and humanoid and root then
					consider(character, root, humanoid, player, "Player", player.DisplayName or player.Name, options, best)
				end
			end
		end
		if options.IncludeNPC then
			for _, npc in ipairs(Runtime.Entities.NPCs) do
				consider(npc.Model, npc.Root, npc.Humanoid, nil, "NPC", npc.Name, options, best)
			end
		end
		if options.IncludeHeli and Runtime.Entities.Heli then
			local heli = Runtime.Entities.Heli
			consider(heli.Model, heli.Root, nil, nil, "Heli", heli.Name, options, best, heli.Health)
		end
		return best.Target and best or nil
	end
	Aim.SelectTarget = selectTarget

	local function updateSilent()
		if not S.SilentAim then
			Aim.SilentTarget = nil
			Aim.SilentPart = nil
			Aim.SilentStatus = "off"
			Aim.SilentNextScan = 0
			return
		end
		local now = os.clock()
		if now < Aim.SilentNextScan then return end
		Aim.SilentNextScan = now + 0.05
		silentOptions.FOV = S.SilentFOV
		silentOptions.Range = S.SilentRange
		silentOptions.PartMode = S.SilentPart
		silentOptions.TeamCheck = S.SilentTeamCheck
		silentOptions.WallCheck = S.SilentWallCheck
		silentOptions.IncludeNPC = S.SilentNPC
		silentOptions.IncludeHeli = false
		silentOptions.PlayersFirst = false
		local best = selectTarget(silentOptions, silentBest)
		Aim.SilentAt = now
		Aim.SilentTarget = best and best.Target or nil
		Aim.SilentPart = best and best.Part or nil
		Aim.SilentStatus = best and "target" or "no target"
	end

	local function normalizedToolName()
		local name = string.gsub(string.lower(Shared.ToolName()), "[_%-]+", " ")
		return string.gsub(name, "%s+", " ")
	end

	local function silentBallistics(remoteName, payload)
		local tool = normalizedToolName()
		if remoteName == "Fire" then
			for _, entry in ipairs(gunBallistics) do
				local pattern = string.gsub(entry[1], "[_%-]+", " ")
				if string.find(tool, pattern, 1, true) then return entry[2], entry[3] end
			end
			return 1200, 8
		end
		local charge = math.clamp(tonumber(payload.charge) or 1, 0.15, 1)
		return 220 + 125 * charge, 50
	end

	local function silentDirection(remoteName, payload, origin)
		if not S.SilentAim or Runtime.Unloaded then return nil end
		local target, part = Aim.SilentTarget, Aim.SilentPart
		if not target or not part or not part.Parent then return nil end
		if os.clock() - Aim.SilentAt > 0.35 then return nil end
		if target.Model and not part:IsDescendantOf(target.Model) then return nil end
		if target.Humanoid and target.Humanoid.Health <= 0 then return nil end
		local basePosition = part.Position
		if (basePosition - origin).Magnitude > S.SilentRange then return nil end
		local position = basePosition
		if S.SilentPrediction then
			local speed, gravity = silentBallistics(remoteName, payload)
			local root = target.Root
			local velocity = root and root.AssemblyLinearVelocity or part.AssemblyLinearVelocity or Vector3.zero
			if speed and speed > 0 then
				local travel = math.clamp((basePosition - origin).Magnitude / speed, 0, 1.5)
				for _ = 1, 2 do
					position = basePosition + velocity * travel + Vector3.new(0, gravity * travel * travel * 0.5, 0)
					travel = math.clamp((position - origin).Magnitude / speed, 0, 1.5)
				end
				position = basePosition + velocity * travel + Vector3.new(0, gravity * travel * travel * 0.5, 0)
			end
		end
		local delta = position - origin
		if delta.Magnitude <= 0.01 then return nil end
		return delta.Unit
	end

	local oldNamecall, wrappedHook, hookMode, hookMeta
	local function callOriginal(self, method, args)
		if method and type(setnamecallmethod) == "function" then pcall(setnamecallmethod, method) end
		return oldNamecall(self, table.unpack(args, 1, args.n))
	end

	local function isFustRemote(self, remoteName)
		local ok, result = pcall(function()
			if not self:IsA("RemoteEvent") and not self:IsA("UnreliableRemoteEvent") then return false end
			if self.Name ~= remoteName then return false end
			local remotes = self.Parent
			local fust = remotes and remotes.Parent
			return remotes ~= nil and remotes.Name == "Remotes" and fust ~= nil
				and fust.Name == "Fust" and fust.Parent == ReplicatedStorage
		end)
		return ok and result == true
	end

	local function isFustShotRemote(self)
		return isFustRemote(self, "Shoot") or isFustRemote(self, "Fire")
	end

	local function weakSpotPosition(payload)
		local target = payload.target
		if typeof(target) ~= "Instance" or not target:IsA("BasePart") then return nil end
		if not target:IsDescendantOf(workspace) then return nil end
		local node = target.Parent
		while node and node ~= workspace do
			local weakSpot = node:GetAttribute("WeakSpot")
			if typeof(weakSpot) == "Vector3" then
				if node:GetAttribute("Depleted") == true then return nil end
				return weakSpot
			end
			node = node.Parent
		end
		return nil
	end

	local function copyPayload(payload)
		local rewritten = {}
		for key, value in pairs(payload) do rewritten[key] = value end
		return rewritten
	end

	local function namecallHook(self, ...)
		if oldNamecall and Runtime.Unloaded then return oldNamecall(self, ...) end
		local args = table.pack(...)
		local method
		if type(getnamecallmethod) == "function" then
			local ok, value = pcall(getnamecallmethod)
			if ok then method = value end
		end
		if not oldNamecall then return nil end
		if type(method) ~= "string" or string.lower(method) ~= "fireserver" then
			return callOriginal(self, method, args)
		end
		if type(checkcaller) == "function" then
			local ok, executor = pcall(checkcaller)
			if ok and executor == true then return callOriginal(self, method, args) end
		end
		local calamari = Runtime.CalamariVisuals
		local visualShots = calamari and (calamari.State.Bullet.Enabled
			or calamari.State.HitEffects.Enabled or calamari.State.HitNotifications.Enabled) or false
		if not S.SilentAim and not S.AutoCross and not visualShots then return callOriginal(self, method, args) end
		local payload = args[1]
		if type(payload) ~= "table" then return callOriginal(self, method, args) end
		if S.AutoCross and self.Name == "Swing" then
			if not isFustRemote(self, "Swing") then return callOriginal(self, method, args) end
			local ok, weakSpot = pcall(weakSpotPosition, payload)
			if not ok then
				Runtime.Diagnostics.AutoCrossErrors = (Runtime.Diagnostics.AutoCrossErrors or 0) + 1
				return callOriginal(self, method, args)
			end
			if not weakSpot then return callOriginal(self, method, args) end
			local rewritten = copyPayload(payload)
			rewritten.pos = weakSpot
			args[1] = rewritten
			Runtime.Diagnostics.AutoCrossRedirects = (Runtime.Diagnostics.AutoCrossRedirects or 0) + 1
			return callOriginal(self, method, args)
		end
		if not isFustShotRemote(self) then return callOriginal(self, method, args) end
		if typeof(payload.origin) ~= "Vector3" or typeof(payload.dir) ~= "Vector3" then
			return callOriginal(self, method, args)
		end
		local direction
		if S.SilentAim then
			local ok, result = pcall(silentDirection, self.Name, payload, payload.origin)
			if ok then
				direction = result
			else
				Runtime.Diagnostics.SilentErrors = (Runtime.Diagnostics.SilentErrors or 0) + 1
			end
		end
		-- Visuals observe the real Shoot/Fire payload. They never create a second
		-- remote owner and use the rewritten direction only when Silent supplied it.
		if visualShots then pcall(calamari.TraceShot, payload.origin, direction or payload.dir, 1000) end
		if not S.SilentAim or not direction then return callOriginal(self, method, args) end
		local rewritten = copyPayload(payload)
		rewritten.dir = direction
		args[1] = rewritten
		Runtime.Diagnostics.SilentRedirects = (Runtime.Diagnostics.SilentRedirects or 0) + 1
		Runtime.Diagnostics.SilentLastRemote = self.Name
		return callOriginal(self, method, args)
	end

	function Aim.InstallSilent()
		if hookMode and oldNamecall then return true end
		if type(getnamecallmethod) ~= "function" then
			Aim.SilentHookStatus = "getnamecallmethod unavailable"
			return false
		end
		local wrapped = namecallHook
		if type(newcclosure) == "function" then
			local ok, closure = pcall(newcclosure, namecallHook)
			if ok and type(closure) == "function" then wrapped = closure end
		end
		if type(hookmetamethod) == "function" then
			local ok, original = pcall(hookmetamethod, game, "__namecall", wrapped)
			if ok and type(original) == "function" then
				oldNamecall, wrappedHook, hookMode = original, wrapped, "hookmetamethod"
				Aim.SilentHookStatus = "installed"
				return true
			end
		end
		if type(getrawmetatable) == "function" then
			local ok, mt = pcall(getrawmetatable, game)
			if ok and type(mt) == "table" and type(mt.__namecall) == "function" then
				local original = mt.__namecall
				if type(setreadonly) == "function" then pcall(setreadonly, mt, false) end
				local wrote = pcall(function() mt.__namecall = wrapped end)
				if type(setreadonly) == "function" then pcall(setreadonly, mt, true) end
				if wrote and mt.__namecall == wrapped then
					oldNamecall, wrappedHook, hookMode, hookMeta = original, wrapped, "metatable", mt
					Aim.SilentHookStatus = "installed"
					return true
				end
			end
		end
		Aim.SilentHookStatus = "namecall hook unavailable"
		return false
	end

	local function restoreSilentHook()
		if not hookMode then return end
		local mode, original, wrapped, mt = hookMode, oldNamecall, wrappedHook, hookMeta
		hookMode, wrappedHook, hookMeta = nil, nil, nil
		-- Keep the original closure referenced: if an executor refuses restore,
		-- the stale hook must still pass every call through instead of returning nil.
		oldNamecall = original
		if mode == "hookmetamethod" and type(hookmetamethod) == "function" then
			pcall(hookmetamethod, game, "__namecall", original)
		elseif mode == "metatable" and mt then
			pcall(function()
				if mt.__namecall ~= wrapped then return end
				if type(setreadonly) == "function" then pcall(setreadonly, mt, false) end
				mt.__namecall = original
				if type(setreadonly) == "function" then pcall(setreadonly, mt, true) end
			end)
		end
		Aim.SilentHookStatus = "not installed"
	end
	Aim.RestoreSilent = restoreSilentHook

	local function predictedPosition(target, part)
		local position = part.Position
		if not S.AimPrediction then return position end
		local tool = string.lower(Shared.ToolName())
		local speed, gravity
		for _, entry in ipairs(gunBallistics) do
			if string.find(tool, entry[1], 1, true) then speed, gravity = entry[2], entry[3]; break end
		end
		if not speed then
			for _, entry in ipairs(bowBallistics) do
				if string.find(tool, entry[1], 1, true) then speed, gravity = entry[2] + entry[3], entry[4]; break end
			end
		end
		if not speed or speed <= 0 then return position end
		local distance = (position - Camera.CFrame.Position).Magnitude
		local travel = math.clamp(distance / speed, 0, 1.5)
		local velocity = target.Root and target.Root.AssemblyLinearVelocity or Vector3.zero
		return position + velocity * travel + Vector3.new(0, gravity * travel * travel * 0.5, 0)
	end

	function Aim.Update(dt)
		updateSilent()
		if fovCircle then
			fovCircle.Visible = S.Aimbot and S.FOVCircle
			fovCircle.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
			fovCircle.Radius = S.AimFOV
			fovCircle.Color = Colors.FOV
		end
		Aim.CurrentTarget = nil
		Aim.CurrentPart = nil
		Aim.CurrentScreen = nil
		if targetLine then targetLine.Visible = false end
		if not S.Aimbot or Runtime.MenuOpen or not keyDown(S.AimKey) then return end
		aimOptions.FOV = S.AimFOV
		aimOptions.Range = S.AimRange
		aimOptions.PartMode = S.AimPart
		aimOptions.Priority = S.AimPriority
		aimOptions.TeamCheck = S.AimTeamCheck
		aimOptions.WallCheck = S.AimWallCheck
		aimOptions.IncludeNPC = S.AimNPC
		aimOptions.IncludeHeli = S.AimHeli
		aimOptions.PlayersFirst = S.AimPlayersFirst
		local best = selectTarget(aimOptions, aimBest)
		if not best then return end
		Aim.CurrentTarget = best.Target
		Aim.CurrentPart = best.Part
		local position = predictedPosition(best.Target, best.Part)
		local x, y, _, visible = Shared.Project(position)
		if visible then Aim.CurrentScreen = Vector2.new(x, y) end
		if targetLine and S.TargetLine and Aim.CurrentScreen then
			targetLine.Visible = true
			targetLine.From = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
			targetLine.To = Aim.CurrentScreen
			targetLine.Color = Colors.TargetLine
		end
		local smoothing = math.max(1, S.AimSmoothing)
		local alpha = math.clamp(1 - math.exp(-dt * 60 / smoothing), 0, 1)
		Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, position), alpha)
	end

	local trigger = {TargetKey = nil, Since = 0, NextClick = 0, Down = false}
	local virtualInput
	local function inputServices()
		if virtualInput == nil then
			local ok, service = pcall(game.GetService, game, "VirtualInputManager")
			virtualInput = ok and service or false
		end
		return virtualInput
	end

	local function release()
		if not trigger.Down then return end
		trigger.Down = false
		if type(mouse1release) == "function" then
			pcall(mouse1release)
		else
			local service = inputServices()
			if service then
				pcall(service.SendMouseButtonEvent, service, Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5, 0, false, game, 0)
			end
		end
	end
	Runtime.TriggerRelease = release

	local function click()
		if type(mouse1press) == "function" and type(mouse1release) == "function" then
			local ok = pcall(mouse1press)
			if not ok then return false end
			trigger.Down = true
			task.delay(0.025, release)
			return true
		end
		local service = inputServices()
		if not service then Aim.TriggerStatus = "mouse input unavailable"; return false end
		local ok = pcall(service.SendMouseButtonEvent, service, Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5, 0, true, game, 0)
		if not ok then return false end
		trigger.Down = true
		task.delay(0.025, release)
		return true
	end

	function Aim.UpdateTrigger()
		if not S.Triggerbot or Runtime.MenuOpen or not keyDown(S.TriggerKey) then
			trigger.TargetKey = nil
			trigger.Since = 0
			release()
			Aim.TriggerStatus = S.Triggerbot and "idle" or "off"
			return
		end
		triggerOptions.FOV = S.TriggerRadius
		triggerOptions.Range = S.AimRange
		triggerOptions.TeamCheck = S.TriggerTeamCheck
		triggerOptions.WallCheck = S.TriggerWallCheck
		triggerOptions.IncludeNPC = S.TriggerNPC
		triggerOptions.IncludeHeli = false
		triggerOptions.PlayersFirst = false
		local best = selectTarget(triggerOptions, triggerBest)
		if not best then
			trigger.TargetKey = nil
			trigger.Since = 0
			release()
			Aim.TriggerStatus = "no target"
			return
		end
		local target = best.Target
		local key = target.Player and target.Player.UserId or target.Model
		local now = os.clock()
		if trigger.TargetKey ~= key then
			trigger.TargetKey = key
			trigger.Since = now
			trigger.NextClick = 0
		end
		Aim.TriggerStatus = "target"
		if now - trigger.Since < S.TriggerReaction / 1000 then return end
		if trigger.Down or now < trigger.NextClick then return end
		if click() then trigger.NextClick = now + S.TriggerDelay / 1000 end
	end

	onCleanup(function()
		release()
		restoreSilentHook()
		Aim.CurrentTarget = nil
		Aim.CurrentPart = nil
		Aim.SilentTarget = nil
		Aim.SilentPart = nil
	end)
end

do
	local Shared = Runtime.Shared
	local Visuals = {Rigs = {}, Generation = 0, WorldLabels = {}, WorldIndex = 0, WorldClock = 0, Clock = 0, PruneClock = 0}
	Runtime.Visuals = Visuals

	local playerOptions = {}
	local npcOptions = {}
	local heliOptions = {Box = false, Names = true, Distance = true, Health = false, HeldItem = false}

	local function textObject()
		local object = newDrawing("Text")
		if object then
			object.Center = true
			object.Outline = true
			object.Font = 2
			object.Transparency = 1
		end
		return object
	end

	local function squareObject()
		local object = newDrawing("Square")
		if object then object.Thickness = 1; object.Transparency = 1 end
		return object
	end

	local function rigEntry(key)
		local entry = Visuals.Rigs[key]
		if entry then return entry end
		entry = {
			Box = squareObject(),
			HealthBG = squareObject(),
			Health = squareObject(),
			Name = textObject(),
			Info = textObject(),
			Seen = -1,
			LastSeen = 0,
		}
		Visuals.Rigs[key] = entry
		return entry
	end

	local function hide(entry)
		for _, key in ipairs({"Box", "HealthBG", "Health", "Name", "Info"}) do
			if entry[key] then entry[key].Visible = false end
		end
	end

	local function pruneRigs()
		local now = os.clock()
		local removed = {}
		for key, entry in pairs(Visuals.Rigs) do
			local detached = typeof(key) == "Instance" and key.Parent == nil
			if detached or now - (entry.LastSeen or 0) > 5 then
				for _, field in ipairs({"Box", "HealthBG", "Health", "Name", "Info"}) do
					local object = entry[field]
					if object then
						pcall(function() object:Remove() end)
						removed[object] = true
					end
				end
				Visuals.Rigs[key] = nil
			end
		end
		if next(removed) then
			for index = #Runtime.Drawings, 1, -1 do
				if removed[Runtime.Drawings[index]] then table.remove(Runtime.Drawings, index) end
			end
		end
	end

	local function renderRig(key, model, humanoid, root, head, name, options)
		if not model or not root or not head or (humanoid and humanoid.Health <= 0) then return end
		local distance = (root.Position - Camera.CFrame.Position).Magnitude
		if distance > options.Range then return end
		local topPosition, bottomPosition
		if options.Heli then
			topPosition = root.Position + Vector3.new(0, 5, 0)
			bottomPosition = root.Position - Vector3.new(0, 5, 0)
		else
			topPosition = head.Position + Vector3.new(0, 0.6, 0)
			bottomPosition = root.Position - Vector3.new(0, 3, 0)
		end
		local topX, topY, _, topVisible = Shared.Project(topPosition)
		local bottomX, bottomY, _, bottomVisible = Shared.Project(bottomPosition)
		if not topVisible or not bottomVisible then return end
		local height = math.abs(bottomY - topY)
		if height < 5 then return end
		local width = height * 0.55
		local centerX = (topX + bottomX) * 0.5
		local left = centerX - width * 0.5
		local top = math.min(topY, bottomY)
		local entry = rigEntry(key)
		entry.Seen = Visuals.Generation
		entry.LastSeen = os.clock()
		if entry.Box then
			entry.Box.Visible = options.Box == true
			entry.Box.Position = Vector2.new(left, top)
			entry.Box.Size = Vector2.new(width, height)
			entry.Box.Color = options.Color
			entry.Box.Filled = false
		end
		local health = humanoid and humanoid.Health or options.HealthValue
		local maxHealth = humanoid and humanoid.MaxHealth or options.MaxHealth
		local showHealth = options.Health and health ~= nil and maxHealth ~= nil and maxHealth > 0
		if entry.HealthBG then entry.HealthBG.Visible = showHealth == true end
		if entry.Health then entry.Health.Visible = showHealth == true end
		if showHealth then
			local percent = math.clamp(health / maxHealth, 0, 1)
			entry.HealthBG.Position = Vector2.new(left - 5, top)
			entry.HealthBG.Size = Vector2.new(2, height)
			entry.HealthBG.Color = Color3.fromRGB(15, 15, 15)
			entry.HealthBG.Filled = true
			entry.HealthBG.Transparency = 0.45
			entry.Health.Position = Vector2.new(left - 5, top + height * (1 - percent))
			entry.Health.Size = Vector2.new(2, height * percent)
			entry.Health.Color = Color3.fromRGB(math.floor(255 * (1 - percent)), math.floor(255 * percent), 60)
			entry.Health.Filled = true
			entry.Health.Transparency = 1
		end
		if entry.Name then
			entry.Name.Visible = options.Names == true
			entry.Name.Text = tostring(name)
			entry.Name.Position = Vector2.new(centerX, top - 16)
			entry.Name.Size = options.TextSize
			entry.Name.Color = options.TextColor or options.Color
		end
		local info = ""
		if options.Distance then info = tostring(math.floor(distance + 0.5)) .. "m" end
		if options.HeldItem then
			local tool = Shared.ToolName(model)
			if tool ~= "" then info = info ~= "" and info .. "\n" .. tool or tool end
		end
		if entry.Info then
			entry.Info.Visible = info ~= ""
			entry.Info.Text = info
			entry.Info.Position = Vector2.new(centerX, top + height + 2)
			entry.Info.Size = options.TextSize
			entry.Info.Color = options.Color
		end
		return true
	end

	local function worldLabel()
		local index = Visuals.WorldIndex
		local label = Visuals.WorldLabels[index]
		if not label then
			label = textObject()
			Visuals.WorldLabels[index] = label
		end
		return label
	end

	local function renderWorld()
		for index = 1, Visuals.WorldIndex do
			local label = Visuals.WorldLabels[index]
			if label then label.Visible = false end
		end
		Visuals.WorldIndex = 0
		local rendered = 0
		for _, entry in ipairs(Runtime.World.Entries) do
			if rendered >= 400 then break end
			local category = Runtime.World.Categories[entry.Category]
			if category and S[category.Master] and entry.Part then
				local position = entry.Part.Position
				local distance = (position - Camera.CFrame.Position).Magnitude
				if distance <= S[category.Range] then
					local x, y, _, visible = Shared.Project(position)
					if visible then
						Visuals.WorldIndex += 1
						local label = worldLabel()
						if label then
							label.Visible = true
							label.Text = entry.Label .. (S[category.Distance] and "\n" .. tostring(math.floor(distance + 0.5)) .. "m" or "")
							label.Position = Vector2.new(x, y)
							label.Size = S.WorldTextSize
							label.Color = Colors[category.Color]
						end
						rendered += 1
					end
				end
			end
		end
		Runtime.Diagnostics.WorldRendered = rendered
	end

	function Visuals.Update(dt)
		Visuals.Clock += dt
		if S.LowPC and Visuals.Clock < 0.05 then return end
		local step = Visuals.Clock
		Visuals.Clock = 0
		Visuals.Generation += 1
		local renderedPlayers, renderedNPCs = 0, 0
		if S.PlayerESP then
			playerOptions.Box = S.PlayerBox
			playerOptions.Names = S.PlayerNames
			playerOptions.Distance = S.PlayerDistance
			playerOptions.Health = S.PlayerHealth
			playerOptions.HeldItem = S.PlayerHeldItem
			playerOptions.Range = S.PlayerRange
			playerOptions.TextSize = S.PlayerTextSize
			playerOptions.Color = Colors.Player
			playerOptions.TextColor = Colors.PlayerText
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and not (S.PlayerTeamCheck and Shared.IsTeammate(player)) then
					local character = player.Character
					local humanoid = Shared.Humanoid(character)
					local root = Shared.Root(character)
					local head = character and character:FindFirstChild("Head") or root
					if character and humanoid and root and head and humanoid.Health > 0 then
						if renderRig(player, character, humanoid, root, head, player.DisplayName or player.Name, playerOptions) then
							renderedPlayers += 1
						end
					end
				end
			end
		end
		if S.NPCESP then
			npcOptions.Box = S.NPCBox
			npcOptions.Names = S.NPCNames
			npcOptions.Distance = S.NPCDistance
			npcOptions.Health = S.NPCHealth
			npcOptions.HeldItem = false
			npcOptions.Range = S.NPCRange
			npcOptions.TextSize = S.NPCTextSize
			npcOptions.Color = Colors.NPC
			for _, npc in ipairs(Runtime.Entities.NPCs) do
				if renderRig(npc.Model, npc.Model, npc.Humanoid, npc.Root, npc.Head, npc.Name, npcOptions) then
					renderedNPCs += 1
				end
			end
			local heli = Runtime.Entities.Heli
			if S.NPCHeli and heli then
				heliOptions.Box = S.NPCBox
				heliOptions.Names = S.NPCNames
				heliOptions.Distance = S.NPCDistance
				heliOptions.Health = S.NPCHealth
				heliOptions.Range = S.NPCRange
				heliOptions.TextSize = S.NPCTextSize
				heliOptions.Color = Colors.NPC
				heliOptions.Heli = true
				heliOptions.HealthValue = heli.Health
				heliOptions.MaxHealth = heli.MaxHealth
				renderRig(heli.Model, heli.Model, nil, heli.Root, heli.Root, heli.Name, heliOptions)
			end
		end
		for _, entry in pairs(Visuals.Rigs) do
			if entry.Seen ~= Visuals.Generation then hide(entry) end
		end
		Visuals.PruneClock += step
		if Visuals.PruneClock >= 1 then
			Visuals.PruneClock = 0
			pruneRigs()
		end
		Runtime.Diagnostics.PlayerESPCount = renderedPlayers
		Runtime.Diagnostics.NPCESPCount = renderedNPCs

		Visuals.WorldClock += step
		local worldInterval = S.LowPC and 0.2 or (1 / 30)
		if Visuals.WorldClock >= worldInterval then
			Visuals.WorldClock = 0
			renderWorld()
		end
	end

	onCleanup(function()
		for _, entry in pairs(Visuals.Rigs) do hide(entry) end
		for _, label in pairs(Visuals.WorldLabels) do if label then label.Visible = false end end
	end)
end

do
	local function section(parent, name)
		return getSection(parent, name).Content
	end

	local function changed(key)
		local handler = Runtime.SettingHandlers[key]
		if handler then pcall(handler) end
		handler = Runtime.FeatureHandlers[key]
		if handler then pcall(handler, S[key]) end
	end

	local function feature(parent, name, key)
		local editor = createFeature(parent, name, S[key], function(value)
			S[key] = value
			local handler = Runtime.FeatureHandlers[key]
			if handler then pcall(handler, value) end
		end)
		Runtime.ConfigControls[key] = {Kind = "feature", Feature = name}
		return editor
	end

	local function slider(editor, name, min, max, key)
		local setter = addSlider(editor, name, min, max, S[key], function(value)
			S[key] = value
			changed(key)
		end)
		Runtime.ConfigControls[key] = {Kind = "slider", Set = setter}
		return setter
	end

	local function dropdown(editor, name, options, key)
		local defaultIndex = 1
		for index, value in ipairs(options) do if value == S[key] then defaultIndex = index; break end end
		local setter = addDropdown(editor, name, options, defaultIndex, function(value)
			S[key] = value
			changed(key)
		end)
		Runtime.ConfigControls[key] = {Kind = "dropdown", Set = setter}
		return setter
	end

	local function onOff(editor, name, key)
		local setter = addDropdown(editor, name, {"Off", "On"}, S[key] and 2 or 1, function(value)
			S[key] = value == "On"
			changed(key)
		end)
		Runtime.ConfigControls[key] = {Kind = "dropdown", Set = function(value, silent)
			if type(value) == "boolean" then value = value and "On" or "Off" end
			return setter(value, silent)
		end}
		return setter
	end

	local function color(editor, name, key)
		local setter = addColor(editor, name, function(value)
			Colors[key] = value
			if key == "Accent" then setMenuAccent(value) end
		end, Colors[key])
		Runtime.ConfigControls["color:" .. key] = {Kind = "color", Set = setter, ColorKey = key}
		return setter
	end

	local function toggleBind(editor, name, key)
		addBind(editor, "Toggle Bind", "None", function()
			if _fFS[name] then _fFS[name](not S[key]) end
		end)
	end

	local function weaponDirty()
		Runtime.Weapons.MarkDirty()
		if not (S.WeaponPatches and (S.WeaponFireRate or S.WeaponClean)) then Runtime.Weapons.Restore() end
	end
	Runtime.FeatureHandlers.WeaponPatches = weaponDirty
	Runtime.FeatureHandlers.WeaponFireRate = weaponDirty
	Runtime.FeatureHandlers.WeaponClean = weaponDirty
	Runtime.SettingHandlers.FireInterval = function() if S.WeaponPatches then Runtime.Weapons.MarkDirty() end end
	Runtime.FeatureHandlers.HUD = function(value) statsHud.SetVisible(value) end
	Runtime.FeatureHandlers.HideGrass = function() Runtime.Environment.Apply() end
	Runtime.FeatureHandlers.LowPC = function() Runtime.Environment.Apply() end
	Runtime.FeatureHandlers.Noclip = function(value) if not value then Runtime.Movement.Restore() end end
	Runtime.FeatureHandlers.SilentAim = function(value)
		if value and not Runtime.Aim.InstallSilent() then
			S.SilentAim = false
			if _fFS["Silent Aim"] then _fFS["Silent Aim"](false) end
		end
	end
	Runtime.FeatureHandlers.AutoCross = function(value)
		if value and not Runtime.Aim.InstallSilent() then
			S.AutoCross = false
			if _fFS["Weak Spot Aim"] then _fFS["Weak Spot Aim"](false) end
		end
	end
	Runtime.FeatureHandlers.UIAnimations = function(value) UIAnimations = value end
	for _, key in ipairs({"LootESP", "BaseESP", "DropsESP", "NodesESP", "PickupsESP", "VehiclesESP",
		"LootBarrels", "LootCrates", "LootMilitary", "LootElite", "BaseBoxes", "BaseCupboard", "BaseLocker",
		"BaseSleepingBag", "BaseTraps", "BodyBags", "DroppedItems", "NodeStone", "NodeSulfur", "NodeMetal",
		"PickupOres", "PickupWood", "PickupPlants", "VehicleATV", "VehicleBoats", "VehicleHelis"}) do
		Runtime.FeatureHandlers[key] = function() Runtime.World.ForceScan() end
	end

	do
		local lc, rc = getTab("COMBAT")
		local aimSection = section(lc, "Aimbot")
		local editor = feature(aimSection, "Aimbot", "Aimbot")
		slider(editor, "FOV", 10, 900, "AimFOV")
		slider(editor, "Range", 20, 1500, "AimRange")
		slider(editor, "Smoothing", 1, 50, "AimSmoothing")
		dropdown(editor, "Target Part", {"Head", "Body", "Root", "Closest"}, "AimPart")
		dropdown(editor, "Priority", {"Crosshair", "Distance", "Low HP"}, "AimPriority")
		dropdown(editor, "Hold Key", {"RMB", "LMB", "LeftAlt", "LeftControl", "Always"}, "AimKey")
		onOff(editor, "Team Check", "AimTeamCheck")
		onOff(editor, "Wall Check", "AimWallCheck")
		onOff(editor, "Target NPC", "AimNPC")
		onOff(editor, "Target Patrol Heli", "AimHeli")
		onOff(editor, "Players First", "AimPlayersFirst")
		onOff(editor, "Prediction", "AimPrediction")
		onOff(editor, "FOV Circle", "FOVCircle")
		onOff(editor, "Target Line", "TargetLine")
		color(editor, "FOV Color", "FOV")
		color(editor, "Line Color", "TargetLine")
		toggleBind(editor, "Aimbot", "Aimbot")

		local silentSection = section(rc, "Silent Aim")
		editor = feature(silentSection, "Silent Aim", "SilentAim")
		slider(editor, "FOV", 10, 900, "SilentFOV")
		slider(editor, "Range", 20, 1500, "SilentRange")
		dropdown(editor, "Target Part", {"Head", "Body", "Root", "Closest"}, "SilentPart")
		onOff(editor, "Team Check", "SilentTeamCheck")
		onOff(editor, "Wall Check", "SilentWallCheck")
		onOff(editor, "Target NPC", "SilentNPC")
		onOff(editor, "Prediction", "SilentPrediction")
		toggleBind(editor, "Silent Aim", "SilentAim")

		local triggerSection = section(rc, "Triggerbot")
		editor = feature(triggerSection, "Triggerbot", "Triggerbot")
		slider(editor, "Crosshair Radius", 2, 80, "TriggerRadius")
		slider(editor, "Reaction Delay", 0, 500, "TriggerReaction")
		slider(editor, "Click Delay", 20, 400, "TriggerDelay")
		dropdown(editor, "Hold Key", {"Always", "RMB", "LMB", "LeftAlt", "LeftControl"}, "TriggerKey")
		onOff(editor, "Team Check", "TriggerTeamCheck")
		onOff(editor, "Wall Check", "TriggerWallCheck")
		onOff(editor, "Target NPC", "TriggerNPC")
		toggleBind(editor, "Triggerbot", "Triggerbot")

		local gunSection = section(rc, "Gun Mods")
		editor = feature(gunSection, "Weapon Patches", "WeaponPatches")
		onOff(editor, "Fire Rate", "WeaponFireRate")
		slider(editor, "Fire Interval", 80, 190, "FireInterval")
		onOff(editor, "Reduce Spread / Sway / Kick", "WeaponClean")

		local harvestSection = section(rc, "Harvesting")
		editor = feature(harvestSection, "Weak Spot Aim", "AutoCross")
		toggleBind(editor, "Weak Spot Aim", "AutoCross")
	end

	do
		local lc, rc = getTab("VISUALS")
		local playersSection = section(lc, "Players")
		local editor = feature(playersSection, "Player ESP", "PlayerESP")
		slider(editor, "Range", 50, 1500, "PlayerRange")
		slider(editor, "Text Size", 9, 18, "PlayerTextSize")
		onOff(editor, "Box", "PlayerBox")
		onOff(editor, "Names", "PlayerNames")
		onOff(editor, "Distance", "PlayerDistance")
		onOff(editor, "Health Bar", "PlayerHealth")
		onOff(editor, "Held Item", "PlayerHeldItem")
		onOff(editor, "Team Check", "PlayerTeamCheck")
		color(editor, "Box Color", "Player")
		color(editor, "Text Color", "PlayerText")
		toggleBind(editor, "Player ESP", "PlayerESP")

		local npcSection = section(rc, "NPCs")
		editor = feature(npcSection, "NPC ESP", "NPCESP")
		slider(editor, "Range", 50, 1000, "NPCRange")
		slider(editor, "Text Size", 9, 18, "NPCTextSize")
		onOff(editor, "Patrol Heli", "NPCHeli")
		onOff(editor, "Box", "NPCBox")
		onOff(editor, "Names", "NPCNames")
		onOff(editor, "Distance", "NPCDistance")
		onOff(editor, "Health Bar", "NPCHealth")
		color(editor, "Color", "NPC")
		toggleBind(editor, "NPC ESP", "NPCESP")
	end

	do
		local lc, rc = getTab("WORLD")
		local editor = feature(section(lc, "Loot Containers"), "Loot ESP", "LootESP")
		slider(editor, "Range", 25, 1000, "LootRange")
		onOff(editor, "Barrels", "LootBarrels")
		onOff(editor, "Crates", "LootCrates")
		onOff(editor, "Military", "LootMilitary")
		onOff(editor, "Elite", "LootElite")
		onOff(editor, "Distance", "LootDistance")
		color(editor, "Color", "Loot")

		editor = feature(section(lc, "Base"), "Base ESP", "BaseESP")
		slider(editor, "Range", 25, 500, "BaseRange")
		onOff(editor, "Boxes", "BaseBoxes")
		onOff(editor, "Tool Cupboard", "BaseCupboard")
		onOff(editor, "Locker", "BaseLocker")
		onOff(editor, "Sleeping Bag", "BaseSleepingBag")
		onOff(editor, "Traps / Turrets", "BaseTraps")
		onOff(editor, "Distance", "BaseDistance")
		color(editor, "Color", "Base")

		editor = feature(section(lc, "Body Bags & Dropped"), "Drops ESP", "DropsESP")
		slider(editor, "Range", 25, 1000, "DropsRange")
		onOff(editor, "Body Bags", "BodyBags")
		onOff(editor, "Dropped Items", "DroppedItems")
		onOff(editor, "Distance", "DropsDistance")
		color(editor, "Color", "Drops")

		editor = feature(section(rc, "Ore Nodes"), "Nodes ESP", "NodesESP")
		slider(editor, "Range", 25, 1000, "NodesRange")
		onOff(editor, "Stone", "NodeStone")
		onOff(editor, "Sulfur", "NodeSulfur")
		onOff(editor, "Metal / Iron", "NodeMetal")
		onOff(editor, "Distance", "NodesDistance")
		color(editor, "Color", "Nodes")

		editor = feature(section(rc, "Pickups & Food"), "Pickups ESP", "PickupsESP")
		slider(editor, "Range", 25, 500, "PickupsRange")
		onOff(editor, "Loose Ores", "PickupOres")
		onOff(editor, "Wood Logs", "PickupWood")
		onOff(editor, "Food & Plants", "PickupPlants")
		onOff(editor, "Distance", "PickupsDistance")
		color(editor, "Color", "Pickups")

		editor = feature(section(rc, "Vehicles"), "Vehicles ESP", "VehiclesESP")
		slider(editor, "Range", 50, 1500, "VehiclesRange")
		onOff(editor, "ATVs", "VehicleATV")
		onOff(editor, "Boats", "VehicleBoats")
		onOff(editor, "Minicopters", "VehicleHelis")
		onOff(editor, "Distance", "VehiclesDistance")
		onOff(editor, "Text Size", "WorldTextSize")
		color(editor, "Color", "Vehicles")
	end

	do
		local lc, rc = getTab("MOVEMENT")
		local editor = feature(section(lc, "Movement"), "Speed", "Speed")
		slider(editor, "Value", 16, 60, "SpeedValue")
		toggleBind(editor, "Speed", "Speed")
		editor = feature(section(lc, "Jump"), "High Jump", "HighJump")
		slider(editor, "Height", 20, 100, "JumpHeight")
		toggleBind(editor, "High Jump", "HighJump")
		editor = feature(section(rc, "Collision"), "Noclip", "Noclip")
		toggleBind(editor, "Noclip", "Noclip")
	end

	do
		local lc, rc = getTab("MISC")
		local editor = feature(section(lc, "Performance"), "Hide Grass", "HideGrass")
		toggleBind(editor, "Hide Grass", "HideGrass")
		editor = feature(section(lc, "Performance"), "Low PC", "LowPC")
		toggleBind(editor, "Low PC", "LowPC")
		editor = feature(section(rc, "HUD"), "Stats HUD", "HUD")
		toggleBind(editor, "Stats HUD", "HUD")
	end

	do
		local lc, rc = getTab("CONFIG")
		local interfaceSection = section(lc, "Interface")
		local editor = feature(interfaceSection, "UI Animations", "UIAnimations")
		local accentEditor = createFeature(interfaceSection, "Menu Accent", true, function() end)
		local accentSetter = color(accentEditor, "Color", "Accent")
		addDropdown(accentEditor, "Preset", {"White", "Blue", "Silver", "Graphite"}, 1, function(value)
			local preset = value == "Blue" and Color3.fromRGB(0, 82, 255)
				or value == "Silver" and Color3.fromRGB(190, 190, 190)
				or value == "Graphite" and Color3.fromRGB(105, 105, 105)
				or Color3.fromRGB(255, 255, 255)
			Colors.Accent = preset
			accentSetter(preset, true)
			setMenuAccent(preset)
		end)
		createFeature(interfaceSection, "Unload Burmalda.hook", false, function(value)
			if value then task.defer(Runtime.Unload) end
		end)

		local Config = {Folder = "Burmalda.hook/Fust", Session = {}}
		Runtime.Config = Config
		_fustEnv.BurmaldaFustConfigs = type(_fustEnv.BurmaldaFustConfigs) == "table" and _fustEnv.BurmaldaFustConfigs or {}
		Config.Session = _fustEnv.BurmaldaFustConfigs
		pcall(function()
			if type(makefolder) == "function" then
				makefolder("Burmalda.hook")
				makefolder(Config.Folder)
			end
		end)

		function Config.BuildTable()
			local state = {}
			for key, value in pairs(S) do
				local kind = type(value)
				if kind == "boolean" or kind == "number" or kind == "string" then state[key] = value end
			end
			local colors = {}
			for key, value in pairs(Colors) do
				colors[key] = {
					math.floor(value.R * 255 + 0.5),
					math.floor(value.G * 255 + 0.5),
					math.floor(value.B * 255 + 0.5),
				}
			end
			local binds = {}
			for name, api in pairs(Runtime.BindApis) do binds[name] = api.Get() end
			return {Version = 1, State = state, Colors = colors, Binds = binds,
				Calamari = Runtime.CalamariVisuals and Runtime.CalamariVisuals.State or nil}
		end

		function Config.Apply(data)
			if type(data) ~= "table" or type(data.State) ~= "table" then return false end
			local accepted = {}
			for key, value in pairs(data.State) do
				local current = S[key]
				if current ~= nil and type(current) == type(value) and (type(value) == "boolean" or type(value) == "number" or type(value) == "string") then
					S[key] = value
					accepted[key] = true
				end
			end
			if type(data.Colors) == "table" then
				for key, rgb in pairs(data.Colors) do
					if Colors[key] and type(rgb) == "table" and tonumber(rgb[1]) and tonumber(rgb[2]) and tonumber(rgb[3]) then
						Colors[key] = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
					end
				end
			end
			for key, control in pairs(Runtime.ConfigControls) do
				if control.Kind == "color" then
					local colorKey = control.ColorKey
					control.Set(Colors[colorKey], true)
					if colorKey == "Accent" then setMenuAccent(Colors.Accent) end
				elseif control.Kind ~= "feature" and accepted[key] then
					-- Editors own clamping and callback semantics; silent sync here could
					-- leave a manually edited config different from the runtime value.
					control.Set(S[key], false)
				end
			end
			for key in pairs(accepted) do
				local control = Runtime.ConfigControls[key]
				if control and control.Kind == "feature" and _fFS[control.Feature] then
					_fFS[control.Feature](S[key])
				end
			end
			if type(data.Binds) == "table" then
				for name, value in pairs(data.Binds) do
					local api = Runtime.BindApis[name]
					if api and type(value) == "string" then api.Set(value) end
				end
			end
			if type(data.Calamari) == "table" and Runtime.CalamariVisuals then
				local destination = Runtime.CalamariVisuals.State
				for key, value in pairs(data.Calamari) do destination[key] = value end
				Runtime.CalamariVisuals.SyncUI()
			end
			return true
		end

		function Config.Save(name)
			local ok, encoded = pcall(HttpService.JSONEncode, HttpService, Config.BuildTable())
			if not ok or type(encoded) ~= "string" then return false end
			Config.Session[name] = encoded
			pcall(function() if type(writefile) == "function" then writefile(Config.Folder .. "/" .. name .. ".cfg", encoded) end end)
			return true
		end

		function Config.Load(name)
			local encoded = Config.Session[name]
			pcall(function()
				if type(readfile) == "function" and type(isfile) == "function" and isfile(Config.Folder .. "/" .. name .. ".cfg") then
					encoded = readfile(Config.Folder .. "/" .. name .. ".cfg")
				end
			end)
			if type(encoded) ~= "string" then return false end
			local ok, data = pcall(HttpService.JSONDecode, HttpService, encoded)
			return ok and Config.Apply(data) or false
		end

		function Config.Delete(name)
			Config.Session[name] = nil
			pcall(function() if type(delfile) == "function" then delfile(Config.Folder .. "/" .. name .. ".cfg") end end)
		end

		function Config.List()
			local found, result = {}, {}
			for name in pairs(Config.Session) do found[name] = true; table.insert(result, name) end
			pcall(function()
				if type(listfiles) == "function" then
					for _, path in ipairs(listfiles(Config.Folder)) do
						local name = string.match(path, "([^/\\]+)%.cfg$")
						if name and not found[name] then found[name] = true; table.insert(result, name) end
					end
				end
			end)
			table.sort(result)
			return result
		end

		local configsSection = section(lc, "Configs")
		local savedSection = section(rc, "Saved Configs")
		local function corner(parent)
			if not parent:FindFirstChildOfClass("UICorner") then
				local object = Instance.new("UICorner", parent)
				object.CornerRadius = UDim.new(0, 5)
			end
		end
		local function button(parent, text)
			local object = Instance.new("TextButton", parent)
			object.Size = UDim2.new(1, 0, 0, 22)
			object.BackgroundColor3 = Theme.Element
			object.BorderSizePixel = 0
			object.Text = text
			object.TextColor3 = Color3.new(1, 1, 1)
			object.Font = Enum.Font.GothamMedium
			object.TextSize = 12
			object.AutoButtonColor = false
			corner(object)
			sourceStroke(object)
			return object
		end

		local inputFrame = Instance.new("Frame", configsSection)
		inputFrame.Size = UDim2.new(1, 0, 0, 45)
		inputFrame.BackgroundColor3 = Theme.Element
		inputFrame.BorderSizePixel = 0
		corner(inputFrame)
		sourceStroke(inputFrame)
		local inputLabel = sourceText(inputFrame, "Config Name", UDim2.new(1, -16, 0, 15), Theme.SubText)
		inputLabel.Position = UDim2.new(0, 8, 0, 4)
		local textbox = Instance.new("TextBox", inputFrame)
		textbox.Position = UDim2.new(0, 8, 0, 25)
		textbox.Size = UDim2.new(1, -16, 0, 20)
		textbox.BackgroundTransparency = 1
		textbox.Text = ""
		textbox.PlaceholderText = "config name..."
		textbox.Font = Enum.Font.Gotham
		textbox.TextSize = 12
		textbox.TextColor3 = Color3.new(1, 1, 1)
		textbox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
		textbox.ClearTextOnFocus = false

		local row = Instance.new("Frame", configsSection)
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundTransparency = 1
		local layout = Instance.new("UIListLayout", row)
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 4)
		local saveButton = button(row, "Save")
		saveButton.Size = UDim2.new(1 / 3, -3, 1, 0)
		local loadButton = button(row, "Load")
		loadButton.Size = UDim2.new(1 / 3, -3, 1, 0)
		local deleteButton = button(row, "Delete")
		deleteButton.Size = UDim2.new(1 / 3, -3, 1, 0)

		local listFrame = Instance.new("Frame", savedSection)
		listFrame.Size = UDim2.new(1, 0, 0, 0)
		listFrame.AutomaticSize = Enum.AutomaticSize.Y
		listFrame.BackgroundTransparency = 1
		local listLayout = Instance.new("UIListLayout", listFrame)
		listLayout.Padding = UDim.new(0, 4)
		local empty = sourceText(listFrame, "No saved configs", UDim2.new(1, 0, 0, 24), Theme.SubText)
		empty.TextXAlignment = Enum.TextXAlignment.Center

		local function cleanName(value)
			return string.sub(string.gsub(value, "[^%w%-_]", "_"), 1, 24)
		end
		local function refreshList()
			for _, child in ipairs(listFrame:GetChildren()) do
				if child ~= listLayout and child ~= empty then child:Destroy() end
			end
			local files = Config.List()
			empty.Visible = #files == 0
			for _, name in ipairs(files) do
				local entry = Instance.new("Frame", listFrame)
				entry.Size = UDim2.new(1, 0, 0, 25)
				entry.BackgroundColor3 = Theme.Element
				entry.BorderSizePixel = 0
				corner(entry)
				sourceStroke(entry)
				local label = sourceText(entry, name, UDim2.new(1, -78, 0, 18))
				label.Position = UDim2.new(0, 7, 0, 3)
				local load = button(entry, "Load")
				load.Size = UDim2.new(0, 34, 0, 18)
				load.Position = UDim2.new(1, -73, 0, 3)
				local delete = button(entry, "Del")
				delete.Size = UDim2.new(0, 32, 0, 18)
				delete.Position = UDim2.new(1, -36, 0, 3)
				load.MouseButton1Click:Connect(function() Config.Load(name) end)
				delete.MouseButton1Click:Connect(function() Config.Delete(name); refreshList() end)
			end
		end
		saveButton.MouseButton1Click:Connect(function()
			local name = cleanName(textbox.Text)
			if name ~= "" then Config.Save(name); refreshList() end
		end)
		loadButton.MouseButton1Click:Connect(function()
			local name = cleanName(textbox.Text)
			if name ~= "" then Config.Load(name) end
		end)
		deleteButton.MouseButton1Click:Connect(function()
			local name = cleanName(textbox.Text)
			if name ~= "" then Config.Delete(name); refreshList() end
		end)
		refreshList()
	end
end

do
	local calamariFactory = (function()
-- Calamari-inspired visuals adapted for Burmalda.hook's local menu and lifecycle.
-- No external UI/ESP library, HTTP loader, gameplay module or projectile owner.
-- State is plain JSON-safe data (colors are RGB arrays) for every game's configs.
local function createBurmaldaCalamariVisuals(options)
	options = options or {}
	local State = options.State or {}
	local Adapter = options.Adapter or {}
	local GameName = tostring(options.Game or "Burmalda")
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Lighting = game:GetService("Lighting")
	local Debris = game:GetService("Debris")
	local UIS = game:GetService("UserInputService")
	local LocalPlayer = Players.LocalPlayer
	local API = {State = State, Diagnostics = {}, Unloaded = false}
	local Revision = 0
	local controls = {}
	local connections = {}
	local gui, adornmentFolder, effectFolder
local defaults = {
	Player = {
		Enabled = false, MaxDistance = 2000, MaxTargets = 64,
		Box = true, BoxHigh = {255, 255, 255}, BoxLow = {255, 255, 255},
		BoxHighTransparency = 0, BoxLowTransparency = 0, BoxRotation = 90,
		Fill = false, FillHigh = {255, 255, 255}, FillLow = {255, 255, 255},
		FillHighTransparency = 0.5, FillLowTransparency = 0.5, FillRotation = 90,
		Glow = false, GlowHigh = {255, 255, 255}, GlowLow = {255, 255, 255},
		GlowHighTransparency = 0.5, GlowLowTransparency = 0.5, GlowRotation = 90,
		Healthbar = true, HealthText = false,
		HealthHigh = {0, 255, 0}, HealthMid = {255, 165, 0}, HealthLow = {255, 0, 0},
		Names = true, NameColor = {255, 255, 255},
		Distance = true, DistanceColor = {255, 255, 255},
		Weapon = false, WeaponColor = {255, 255, 255},
		Flags = false, FlagsColor = {255, 255, 255},
		Chams = false, ChamsInside = {255, 255, 255}, ChamsOutside = {255, 255, 255},
		ChamsInsideTransparency = 0.5, ChamsOutsideTransparency = 0,
	},
	World = {Enabled = false, Categories = {}},
	Gun = {Enabled = false, Color = {166, 147, 243}, Material = "ForceField", Texture = "None"},
	Arms = {Enabled = false, Color = {166, 147, 243}, Material = "ForceField", Texture = "None"},
	Viewmodel = {
		Highlight = false, Fill = {166, 147, 243}, FillTransparency = 0.5,
		Outline = {166, 147, 243}, OutlineTransparency = 0,
		Position = false, X = 0, Y = 0, Z = 0,
	},
	Bullet = {Enabled = false, Type = "Lightning", Color = {166, 147, 243}, Duration = 5},
	HitEffects = {Enabled = false, Type = "Spark", Color1 = {166, 147, 243}, Color2 = {166, 147, 243}},
	HitNotifications = {Enabled = false},
	Camera = {
		CustomFOV = false, FOV = 100, Zoom = false, ZoomAmount = 40, ZoomKey = "C",
		ThirdPerson = false, Distance = 5, ThirdPersonKey = "None",
	},
	Lighting = {
		CloudDensity = false, CloudDensityValue = 0.5,
		CloudCover = false, CloudCoverValue = 0.5,
		CloudColor = false, CloudColorValue = {166, 147, 243},
		NoFog = false, FogDensity = false, FogDensityValue = 0.5,
		FogHaze = false, FogHazeValue = 0.5, FogGlare = false, FogGlareValue = 0.5,
		FogColor = false, FogColorValue = {166, 147, 243},
		Fullbright = false, Brightness = 2,
		Ambient = false, AmbientColor = {166, 147, 243},
		Time = false, TimeValue = 12, Skybox = false, SkyboxPreset = "Galaxy",
		SunRays = false, SunIntensity = 0.25, SunSpread = 1,
		Bloom = false, BloomIntensity = 1, BloomSize = 1000, BloomThreshold = 0.36,
	},
}
local worldCategories = {
	["Stone"] = 400, ["Metal"] = 400, ["Phosphate"] = 400, ["Wool"] = 400,
	["Animals"] = 1000, ["Care Package"] = 3000, ["Drops"] = 1000,
	["Body Bag"] = 1000, ["Salvaged Flycopter"] = 3000, ["Eggs"] = 400,
	["Auto Turret"] = 400, ["Shotgun Turret"] = 400,
}
for name, distance in pairs(worldCategories) do
	defaults.World.Categories[name] = {Enabled = false, Color = {255, 80, 80}, MaxDistance = distance}
end

local function mergeDefaults(target, source)
	for key, value in pairs(source) do
		if type(value) == "table" then
			if value[1] ~= nil then
				if type(target[key]) ~= "table" then
					local copy = {}
					for index, item in ipairs(value) do copy[index] = item end
					target[key] = copy
				end
			else
				if type(target[key]) ~= "table" then target[key] = {} end
				mergeDefaults(target[key], value)
			end
		elseif target[key] == nil then
			target[key] = value
		end
	end
end
mergeDefaults(State, defaults)

local function splitPath(path)
	local result = {}
	for part in string.gmatch(tostring(path), "[^.]+") do result[#result + 1] = part end
	return result
end
function API.Get(path)
	local current = State
	for _, part in ipairs(splitPath(path)) do
		if type(current) ~= "table" then return nil end
		current = current[part]
	end
	return current
end
function API.Set(path, value)
	local parts = splitPath(path)
	local current = State
	for index = 1, #parts - 1 do
		local key = parts[index]
		if type(current[key]) ~= "table" then current[key] = {} end
		current = current[key]
	end
	local key = parts[#parts]
	if current[key] == value then return end
	current[key] = value
	Revision += 1
	API.Diagnostics.WorldScanAt = 0
	API.Diagnostics.ViewmodelScanAt = 0
	API.Diagnostics.LightingDirty = true
end
local function color3(value)
	if typeof(value) == "Color3" then return value end
	if type(value) == "table" then
		return Color3.fromRGB(tonumber(value[1]) or 255, tonumber(value[2]) or 255, tonumber(value[3]) or 255)
	end
	return Color3.new(1, 1, 1)
end
function API.SetColor(path, value)
	API.Set(path, {
		math.floor(value.R * 255 + 0.5),
		math.floor(value.G * 255 + 0.5),
		math.floor(value.B * 255 + 0.5),
	})
end
function API.Bind(path, setter, kind)
	controls[#controls + 1] = {Path = path, Set = setter, Kind = kind}
end
function API.SyncUI()
	for _, control in ipairs(controls) do
		local value = API.Get(control.Path)
		if control.Kind == "color" then value = color3(value) end
		pcall(control.Set, value)
	end
end

local function connect(connection)
	if connection then connections[#connections + 1] = connection end
	return connection
end
local function active()
	if API.Unloaded then return false end
	if type(options.IsActive) == "function" then
		local ok, result = pcall(options.IsActive)
		return ok and result ~= false
	end
	return true
end
local function lowPC()
	if type(options.IsLowPC) == "function" then
		local ok, result = pcall(options.IsLowPC)
		return ok and result == true
	end
	return false
end
local function guiParent()
	if type(gethui) == "function" then
		local ok, parent = pcall(gethui)
		if ok and parent then return parent end
	end
	local ok, parent = pcall(function() return game:GetService("CoreGui") end)
	if ok and parent then return parent end
	return LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") or nil
end
local function ensureGui()
	if gui and gui.Parent then return gui end
	local parent = guiParent()
	if not parent then return nil end
	gui = Instance.new("ScreenGui")
	gui.Name = "BurmaldaCalamariVisuals_" .. string.gsub(GameName, "[^%w]", "")
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999900
	gui.Parent = parent
	return gui
end
local function ensureAdornments()
	if adornmentFolder and adornmentFolder.Parent then return adornmentFolder end
	local parent = guiParent()
	if not parent then return nil end
	adornmentFolder = Instance.new("Folder")
	adornmentFolder.Name = "BurmaldaCalamariAdornments"
	adornmentFolder.Parent = parent
	return adornmentFolder
end
local function ensureEffects()
	if effectFolder and effectFolder.Parent then return effectFolder end
	effectFolder = Instance.new("Folder")
	effectFolder.Name = "BurmaldaCalamariEffects"
	effectFolder.Parent = workspace
	return effectFolder
end
local function create(className, parent, properties)
	local object = Instance.new(className)
	for key, value in pairs(properties or {}) do object[key] = value end
	if parent then object.Parent = parent end
	return object
end
local function setProperty(object, key, value)
	if object and object[key] ~= value then object[key] = value end
end
local function destroy(object)
	if object then pcall(function() object:Destroy() end) end
end

-- Player ESP: the same gradient/fill/glow/health layout as Calamari, but pooled
-- and capped. The normal renderer remains independent and can stay enabled.
local playerEntries = {}
local targetCache, targetCacheAt = {}, 0
local playerWasActive = false
local function textLabel(parent, size)
	return create("TextLabel", parent, {
		BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.Gotham,
		TextSize = size or 12, TextColor3 = Color3.new(1, 1, 1), Text = "",
		ZIndex = 3,
	})
end
local function addTextStroke(label)
	return create("UIStroke", label, {Thickness = 1, Color = Color3.new(0, 0, 0), Transparency = 0.35})
end
local function newPlayerEntry()
	local parent = ensureGui()
	if not parent then return nil end
	local main = create("Frame", parent, {
		Visible = false, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(150, 250),
		BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2,
	})
	local fillGradient = create("UIGradient", main, {Rotation = 90})
	local outline = create("UIStroke", main, {
		Thickness = 3, LineJoinMode = Enum.LineJoinMode.Miter,
		BorderOffset = UDim.new(0, -1), Transparency = 0.5,
	})
	local accent = create("UIStroke", main, {LineJoinMode = Enum.LineJoinMode.Miter, Thickness = 1})
	local boxGradient = create("UIGradient", accent, {Rotation = 90})
	local glow = create("ImageLabel", main, {
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1,
		Image = "rbxassetid://18245826428", ImageTransparency = 0.8, ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(80, 80)),
		Size = UDim2.new(1, 45, 1, 45), Position = UDim2.new(0, -23, 0, -23),
	})
	local glowGradient = create("UIGradient", glow, {Rotation = 90})
	local healthBack = create("Frame", main, {
		Position = UDim2.new(0, -7, 0, 0), Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, BorderSizePixel = 0,
	})
	local health = create("Frame", healthBack, {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 1, 1, -1),
		Size = UDim2.new(1, -2, 1, 0), BorderSizePixel = 0,
	})
	local healthGradient = create("UIGradient", health, {Rotation = 90})
	local healthText = textLabel(main, 12)
	healthText.Size = UDim2.new(0, 34, 0, 14)
	healthText.Position = UDim2.new(0, -42, 1, -14)
	healthText.TextXAlignment = Enum.TextXAlignment.Right
	addTextStroke(healthText)
	local name = textLabel(main, 12)
	name.Size = UDim2.new(1, 0, 0, 14)
	name.Position = UDim2.new(0, 0, 0, -18)
	addTextStroke(name)
	local distance = textLabel(main, 12)
	distance.Size = UDim2.new(1, 0, 0, 14)
	distance.Position = UDim2.new(0, 0, 1, 3)
	addTextStroke(distance)
	local weapon = textLabel(main, 12)
	weapon.Size = UDim2.new(1, 0, 0, 14)
	weapon.Position = UDim2.new(0, 0, 1, 19)
	addTextStroke(weapon)
	local flags = textLabel(main, 12)
	flags.Size = UDim2.new(0, 130, 0, 14)
	flags.AutomaticSize = Enum.AutomaticSize.Y
	flags.Position = UDim2.new(1, 5, 0, 0)
	flags.TextXAlignment = Enum.TextXAlignment.Left
	flags.RichText = true
	addTextStroke(flags)
	return {
		Main = main, FillGradient = fillGradient, Outline = outline, Accent = accent,
		BoxGradient = boxGradient, Glow = glow, GlowGradient = glowGradient,
		HealthBack = healthBack, Health = health, HealthGradient = healthGradient,
		HealthText = healthText, Name = name, Distance = distance, Weapon = weapon, Flags = flags,
		LastStyle = -1,
	}
end
local function hidePlayerEntry(entry)
	if not entry then return end
	setProperty(entry.Main, "Visible", false)
	if entry.Highlight then entry.Highlight.Enabled = false end
end
local function removePlayerEntry(key)
	local entry = playerEntries[key]
	if not entry then return end
	destroy(entry.Main)
	destroy(entry.Highlight)
	playerEntries[key] = nil
end
local function hideAllPlayers()
	for _, entry in pairs(playerEntries) do hidePlayerEntry(entry) end
end
local function defaultTargets()
	local result = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local model = player.Character
			local humanoid = model and model:FindFirstChildOfClass("Humanoid")
			local root = model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso"))
			if model and humanoid and root then
				result[#result + 1] = {
					Key = player, Player = player, Model = model, Humanoid = humanoid,
					Root = root, Head = model:FindFirstChild("Head") or root,
					Name = player.DisplayName or player.Name,
				}
			end
		end
	end
	return result
end
local function refreshTargets(now)
	if now < targetCacheAt then return end
	targetCacheAt = now + (lowPC() and 0.5 or 0.2)
	local result
	if type(Adapter.GetTargets) == "function" then
		local ok, value = pcall(Adapter.GetTargets)
		if ok and type(value) == "table" then result = value end
	end
	result = result or defaultTargets()
	local camera = workspace.CurrentCamera
	if camera then
		for _, target in ipairs(result) do
			local root = target.Root or target.root
			if root then target.__calamariDistance = (root.Position - camera.CFrame.Position).Magnitude end
		end
		table.sort(result, function(a, b)
			return (a.__calamariDistance or math.huge) < (b.__calamariDistance or math.huge)
		end)
	end
	targetCache = result
end
local function weaponName(target)
	if type(Adapter.GetWeapon) == "function" then
		local ok, value = pcall(Adapter.GetWeapon, target)
		if ok and value then return tostring(value) end
	end
	local model = target.Model or target.model
	if not model then return "None" end
	local tool = model:FindFirstChildOfClass("Tool")
	if tool then return tool.Name end
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("Model") and child.Name ~= "HolsterModel" and child.Name ~= "Hair"
			and (child:FindFirstChild("Detail") or child:FindFirstChild("Main") or child:FindFirstChild("Handle")
			or child:FindFirstChild("Attachments") or child:FindFirstChild("ArrowAttach") or child:FindFirstChild("Attach")) then
			return child.Name
		end
	end
	return "None"
end
local function richEscape(value)
	return tostring(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end
local function flagText(target)
	local player = target.Player or target.player
	if not player or not player.GetAttribute then return "" end
	local lines = {}
	local clan = player:GetAttribute("ClanTag")
	if clan and tostring(clan) ~= "" then
		local clanColor = player:GetAttribute("ClanColor")
		local c = typeof(clanColor) == "Color3" and clanColor or Color3.new(1, 1, 1)
		lines[#lines + 1] = string.format('<font color="rgb(%d,%d,%d)">%s</font>',
			math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255), richEscape(clan))
	end
	if player:GetAttribute("VIP") then lines[#lines + 1] = '<font color="rgb(255,215,0)">VIP</font>' end
	if player:GetAttribute("SafeZone") then lines[#lines + 1] = '<font color="rgb(0,255,120)">Safezone</font>' end
	return table.concat(lines, "\n")
end
local function applyPlayerStyle(entry)
	if entry.LastStyle == Revision then return end
	entry.LastStyle = Revision
	local p = State.Player
	entry.FillGradient.Color = ColorSequence.new(color3(p.FillHigh), color3(p.FillLow))
	entry.FillGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, p.FillHighTransparency),
		NumberSequenceKeypoint.new(1, p.FillLowTransparency),
	})
	entry.FillGradient.Rotation = p.FillRotation
	entry.BoxGradient.Color = ColorSequence.new(color3(p.BoxHigh), color3(p.BoxLow))
	entry.BoxGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, p.BoxHighTransparency),
		NumberSequenceKeypoint.new(1, p.BoxLowTransparency),
	})
	entry.BoxGradient.Rotation = p.BoxRotation
	entry.GlowGradient.Color = ColorSequence.new(color3(p.GlowHigh), color3(p.GlowLow))
	entry.GlowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, p.GlowHighTransparency),
		NumberSequenceKeypoint.new(1, p.GlowLowTransparency),
	})
	entry.GlowGradient.Rotation = p.GlowRotation
	entry.HealthGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color3(p.HealthHigh)),
		ColorSequenceKeypoint.new(0.5, color3(p.HealthMid)),
		ColorSequenceKeypoint.new(1, color3(p.HealthLow)),
	})
	setProperty(entry.Name, "TextColor3", color3(p.NameColor))
	setProperty(entry.Distance, "TextColor3", color3(p.DistanceColor))
	setProperty(entry.Weapon, "TextColor3", color3(p.WeaponColor))
	setProperty(entry.Flags, "TextColor3", color3(p.FlagsColor))
	if entry.Highlight then
		entry.Highlight.FillColor = color3(p.ChamsInside)
		entry.Highlight.OutlineColor = color3(p.ChamsOutside)
		entry.Highlight.FillTransparency = p.ChamsInsideTransparency
		entry.Highlight.OutlineTransparency = p.ChamsOutsideTransparency
	end
end
local function updatePlayers(now)
	local enabled = active() and State.Player.Enabled
	if not enabled then
		if playerWasActive then hideAllPlayers() end
		playerWasActive = false
		return
	end
	playerWasActive = true
	refreshTargets(now)
	local camera = workspace.CurrentCamera
	if not camera then hideAllPlayers() return end
	local seen, rendered = {}, 0
	local cap = lowPC() and math.min(24, State.Player.MaxTargets) or State.Player.MaxTargets
	local theta = math.tan(math.rad(camera.FieldOfView) * 0.5)
	for _, target in ipairs(targetCache) do
		if rendered >= cap then break end
		local model = target.Model or target.model
		local root = target.Root or target.root
		local humanoid = target.Humanoid or target.hum or target.humanoid
		local key = target.Key or target.Player or target.player or model
		if model and root and key and model.Parent and root.Parent and (not humanoid or humanoid.Health > 0) then
			local distance = (root.Position - camera.CFrame.Position).Magnitude
			if distance <= State.Player.MaxDistance then
				local point, onScreen = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 0.5, 0))
				if point.Z > 0 and onScreen then
					local entry = playerEntries[key]
					if not entry then
						entry = newPlayerEntry()
						playerEntries[key] = entry
					end
					if entry then
						rendered += 1
						seen[key] = true
						entry.Model = model
						entry.LastSeen = now
						applyPlayerStyle(entry)
						local depth = 2 * math.max(0.01, point.Z) * theta
						local scale = camera.ViewportSize.Y / math.max(0.01, depth * 1.5)
						local width = math.floor(math.max(scale * 6, 4))
						local height = math.floor(math.max(scale * 8, 4))
						setProperty(entry.Main, "Position", UDim2.fromOffset(point.X, point.Y))
						setProperty(entry.Main, "Size", UDim2.fromOffset(width, height))
						setProperty(entry.Main, "Visible", true)
						setProperty(entry.Main, "BackgroundTransparency", State.Player.Fill and 0 or 1)
						setProperty(entry.Outline, "Enabled", State.Player.Box)
						setProperty(entry.Accent, "Enabled", State.Player.Box)
						setProperty(entry.Glow, "Visible", State.Player.Glow)
						local percent = 1
						if humanoid and humanoid.MaxHealth > 0 then percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) end
						setProperty(entry.HealthBack, "Visible", State.Player.Healthbar)
						if State.Player.Healthbar then
							setProperty(entry.Health, "Size", UDim2.new(1, -2, percent, 0))
						end
						setProperty(entry.HealthText, "Visible", State.Player.HealthText)
						if State.Player.HealthText then
							setProperty(entry.HealthText, "Text", tostring(math.floor(percent * 100 + 0.5)))
							local low, mid, high = color3(State.Player.HealthLow), color3(State.Player.HealthMid), color3(State.Player.HealthHigh)
							setProperty(entry.HealthText, "TextColor3", low:Lerp(mid, percent):Lerp(high, percent))
						end
						setProperty(entry.Name, "Visible", State.Player.Names)
						if State.Player.Names then setProperty(entry.Name, "Text", tostring(target.Name or target.name or model.Name)) end
						setProperty(entry.Distance, "Visible", State.Player.Distance)
						if State.Player.Distance then setProperty(entry.Distance, "Text", string.format("%.1fst", distance)) end
						setProperty(entry.Weapon, "Visible", State.Player.Weapon)
						if State.Player.Weapon then setProperty(entry.Weapon, "Text", weaponName(target)) end
						setProperty(entry.Flags, "Visible", State.Player.Flags)
						if State.Player.Flags then setProperty(entry.Flags, "Text", flagText(target)) end
						if State.Player.Chams then
							if not entry.Highlight then
								local parent = ensureAdornments()
								if parent then
									entry.Highlight = create("Highlight", parent, {
										DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
										Enabled = false,
									})
									entry.LastStyle = -1
									applyPlayerStyle(entry)
								end
							end
							if entry.Highlight then
								if entry.Highlight.Adornee ~= model then entry.Highlight.Adornee = model end
								entry.Highlight.Enabled = true
							end
						elseif entry.Highlight then
							entry.Highlight.Enabled = false
						end
					end
				end
			end
		end
	end
	for key, entry in pairs(playerEntries) do
		if not seen[key] then
			hidePlayerEntry(entry)
			if (now - (entry.LastSeen or 0) > 5) or (entry.Model and not entry.Model.Parent) then removePlayerEntry(key) end
		end
	end
	API.Diagnostics.PlayerESP = rendered
end

-- Calamari Misc ESP. Traversal is incremental and limited to known world roots;
-- adapters may add game-specific cached objects without another full workspace scan.
local worldLabels = {}
local worldEntries = {}
local worldScan = {Active = false, Queue = {}, Index = 1, Working = {}, Seen = {}, Processed = 0}
local worldWasActive = false
local worldRoots = {
	"Nodes", "OreNodes", "Resources", "Loot", "Deployables", "Bases", "Drops",
	"DroppedItems", "WorldItems", "Plants", "Animals", "Pickups", "SpawnedPickups", "GroundItems",
}
local function worldCategory(object, rootName)
	local name = string.lower(object.Name)
	local compact = name:gsub("[%s_%-]", "")
	if string.find(compact, "carepackage", 1, true) then return "Care Package" end
	if string.find(compact, "salvagedflycopter", 1, true) or string.find(compact, "flycopter", 1, true) then return "Salvaged Flycopter" end
	if string.find(compact, "shotgunturret", 1, true) or string.find(compact, "shotguntrap", 1, true) then return "Shotgun Turret" end
	if string.find(compact, "autoturret", 1, true) or string.find(compact, "aaturret", 1, true) then return "Auto Turret" end
	if string.find(compact, "bodybag", 1, true) or string.find(compact, "backpack", 1, true)
		or string.find(compact, "lootbag", 1, true) or string.find(compact, "deathbag", 1, true) then return "Body Bag" end
	if string.find(compact, "phosphate", 1, true) or string.find(compact, "sulfur", 1, true) or string.find(compact, "sulphur", 1, true) then return "Phosphate" end
	if string.find(compact, "metal", 1, true) or string.find(compact, "iron", 1, true) then return "Metal" end
	if string.find(compact, "stone", 1, true) then return "Stone" end
	if string.find(compact, "egg", 1, true) then return "Eggs" end
	if string.find(compact, "wool", 1, true) or string.find(compact, "cloth", 1, true) or string.find(compact, "hemp", 1, true) then return "Wool" end
	if rootName == "Animals" and object:IsA("Model") then return "Animals" end
	if (rootName == "Drops" or rootName == "DroppedItems" or rootName == "WorldItems")
		and (object:IsA("Model") or object:IsA("Tool") or object:IsA("BasePart")) then return "Drops" end
	if object:IsA("Tool") then return "Drops" end
	return nil
end
local function addWorldEntry(object, category, label)
	if not object or not category or worldScan.Seen[object] then return end
	worldScan.Seen[object] = true
	worldScan.Working[#worldScan.Working + 1] = {Object = object, Category = category, Name = label or object.Name}
end
local function beginWorldScan()
	worldScan.Active = true
	worldScan.Queue, worldScan.Index, worldScan.Working, worldScan.Seen, worldScan.Processed = {}, 1, {}, {}, 0
	local queued = {}
	for _, name in ipairs(Adapter.WorldRoots or worldRoots) do
		local folder = workspace:FindFirstChild(name)
		if folder and not queued[folder] then
			queued[folder] = true
			worldScan.Queue[#worldScan.Queue + 1] = {Object = folder, Depth = 0, MaxDepth = 3, Root = name}
		end
	end
	-- Top-level Tools and named bags are Drops; root folders are not traversed twice.
	if State.World.Categories.Drops.Enabled or State.World.Categories["Body Bag"].Enabled then
		worldScan.Queue[#worldScan.Queue + 1] = {Object = workspace, Depth = 0, MaxDepth = 0, Root = "Workspace"}
	end
	if type(Adapter.GetWorldEntries) == "function" then
		local ok, entries = pcall(Adapter.GetWorldEntries)
		if ok and type(entries) == "table" then
			for _, entry in ipairs(entries) do
				local object = entry.Object or entry.Model or entry.Part
				if object then addWorldEntry(object, entry.Category or worldCategory(object, ""), entry.Name or entry.Label) end
			end
		end
	end
end
local function processWorldScan()
	local budget = lowPC() and 16 or 32
	while budget > 0 and worldScan.Active do
		local taskItem = worldScan.Queue[worldScan.Index]
		if not taskItem or worldScan.Processed >= 1024 then
			worldEntries = worldScan.Working
			worldScan.Active = false
			API.Diagnostics.WorldEntries = #worldEntries
			return
		end
		worldScan.Index += 1
		worldScan.Processed += 1
		budget -= 1
		local object, rootName = taskItem.Object, taskItem.Root
		if object and object.Parent then
			local matched = false
			if object ~= workspace and (object:IsA("Model") or object:IsA("BasePart") or object:IsA("Tool")) then
				local category = worldCategory(object, rootName)
				if category then
					addWorldEntry(object, category)
					matched = true
				end
			end
			if not matched and taskItem.Depth < taskItem.MaxDepth and not object:IsA("BasePart") and not object:IsA("Tool") then
				for _, child in ipairs(object:GetChildren()) do
					worldScan.Queue[#worldScan.Queue + 1] = {
						Object = child, Depth = taskItem.Depth + 1,
						MaxDepth = taskItem.MaxDepth, Root = rootName,
					}
				end
			end
		end
	end
end
local function worldPosition(object)
	if object:IsA("BasePart") then return object.Position end
	local ok, pivot = pcall(function() return object:GetPivot() end)
	if ok and pivot and pivot.Position then return pivot.Position end
	local primary = object.PrimaryPart
	if primary and primary:IsA("BasePart") then return primary.Position end
	-- A model can be supplied by a game adapter before its pivot is available.
	-- Use an existing part as a read-only fallback; never move or mutate the model.
	for _, child in ipairs(object:GetChildren()) do
		if child:IsA("BasePart") then return child.Position end
	end
	return nil
end
local function updateWorld(now)
	local enabled = active() and State.World.Enabled
	if not enabled then
		if worldWasActive then
			for _, label in ipairs(worldLabels) do setProperty(label, "Visible", false) end
		end
		worldWasActive = false
		worldScan.Active = false
		return
	end
	worldWasActive = true
	if now >= (API.Diagnostics.WorldScanAt or 0) and not worldScan.Active then
		API.Diagnostics.WorldScanAt = now + (lowPC() and 2 or 1)
		beginWorldScan()
	end
	if worldScan.Active then processWorldScan() end
	local camera = workspace.CurrentCamera
	if not camera then return end
	local index, cap = 0, lowPC() and 32 or 96
	local previousCount = API.Diagnostics.WorldLabelCount or 0
	for _, entry in ipairs(worldEntries) do
		if index >= cap then break end
		local category = State.World.Categories[entry.Category]
		local object = entry.Object
		if category and category.Enabled and object and object.Parent then
			local position = worldPosition(object)
			if position then
				local distance = (position - camera.CFrame.Position).Magnitude
				if distance <= category.MaxDistance then
					local point, onScreen = camera:WorldToViewportPoint(position)
					if point.Z > 0 and onScreen then
						index += 1
						local label = worldLabels[index]
						if not label then
							local parent = ensureGui()
							if parent then
								label = textLabel(parent, 14)
								label.AnchorPoint = Vector2.new(0.5, 0.5)
								label.AutomaticSize = Enum.AutomaticSize.XY
								label.Size = UDim2.fromOffset(0, 0)
								addTextStroke(label)
								worldLabels[index] = label
							end
						end
						if label then
							setProperty(label, "Text", tostring(entry.Name or entry.Category) .. "\n" .. tostring(math.floor(distance + 0.5)) .. " Studs")
							setProperty(label, "TextColor3", color3(category.Color))
							setProperty(label, "Position", UDim2.fromOffset(point.X, point.Y))
							setProperty(label, "Visible", true)
						end
					end
				end
			end
		end
	end
	for labelIndex = index + 1, previousCount do
		local label = worldLabels[labelIndex]
		if label then setProperty(label, "Visible", false) end
	end
	API.Diagnostics.WorldLabelCount = index
	API.Diagnostics.WorldESP = index
end

-- Gun/Arms materials, textures, Viewmodel Highlight and owned position offsets.
local textures = {
	Web = "rbxassetid://301464986", Swirl = "rbxassetid://8133639623",
	Checkers = "rbxassetid://5790215150", CandyCane = "rbxassetid://6853532738",
	Dots = "rbxassetid://5830615971", Scanning = "rbxassetid://5843010904",
	Bubbles = "rbxassetid://1461576423", ["Player FF Texture"] = "rbxassetid://4494641460",
	["Shield Forcefield"] = "rbxassetid://361073795", Water = "rbxasset://textures/water/normal_21.dds",
	America = "rbxassetid://936775406", Rainbow = "rbxassetid://252684207",
	Akatsuki = "rbxassetid://10913193650", None = "",
}
local materialNames = {
	ForceField = "ForceField", Neon = "Neon", Glass = "Glass", Ice = "Ice",
	Wood = "Wood", Plastic = "SmoothPlastic", Metal = "Metal",
}
local vmCache, vmParts, vmOriginals, vmHighlights, vmPositions = {}, {}, {}, {}, {}
local vmWasActive = false
local function viewmodels()
	local result, seen = {}, {}
	if type(Adapter.GetViewmodels) == "function" then
		local ok, models = pcall(Adapter.GetViewmodels)
		if ok and type(models) == "table" then
			for _, model in ipairs(models) do
				if typeof(model) == "Instance" and not seen[model] then seen[model] = true; result[#result + 1] = model end
			end
		end
	end
	local vfx = workspace:FindFirstChild("VFX")
	local containers = {}
	local vmFolder = vfx and vfx:FindFirstChild("VMs")
	if vmFolder then containers[#containers + 1] = vmFolder end
	vmFolder = workspace:FindFirstChild("VMs")
	if vmFolder then containers[#containers + 1] = vmFolder end
	if workspace.CurrentCamera then containers[#containers + 1] = workspace.CurrentCamera end
	for _, container in ipairs(containers) do
		if container then
			for _, model in ipairs(container:GetChildren()) do
				if model:IsA("Model") and model.Name ~= "IgnoreMe" and not seen[model] then
					seen[model] = true
					result[#result + 1] = model
				end
			end
		end
	end
	return result
end
local function armPart(part, model)
	local current = part.Parent
	while current and current ~= model do
		local name = string.lower(current.Name)
		if current.Name == "Arms" or string.find(name, "arm", 1, true) or string.find(name, "hand", 1, true)
			or string.find(name, "glove", 1, true) then return true end
		current = current.Parent
	end
	return false
end
local function restorePart(part)
	local original = vmOriginals[part]
	if not original then return end
	vmOriginals[part] = nil
	pcall(function()
		if part.Color == original.LastColor then part.Color = original.Color end
		if part.Material == original.LastMaterial then part.Material = original.Material end
		if part:IsA("MeshPart") and part.TextureID == original.LastTexture then part.TextureID = original.TextureID end
	end)
	destroy(original.OwnedTexture)
end
local function applyPart(part, settings)
	if (part.Transparency or 0) >= 0.95 or (part.Size and part.Size.Magnitude or 1) < 0.05 then return end
	local original = vmOriginals[part]
	if not original then
		original = {
			Color = part.Color, Material = part.Material,
			TextureID = part:IsA("MeshPart") and part.TextureID or nil,
		}
		vmOriginals[part] = original
	end
	local color = color3(settings.Color)
	local material = Enum.Material[materialNames[settings.Material] or "ForceField"]
	local texture = textures[settings.Texture] or ""
	pcall(function()
		if part.Color ~= original.LastColor and original.LastColor ~= nil and part.Color ~= color then original.Color = part.Color end
		if part.Material ~= original.LastMaterial and original.LastMaterial ~= nil and part.Material ~= material then original.Material = part.Material end
		part.Color = color
		part.Material = material
		original.LastColor, original.LastMaterial = color, material
		if part:IsA("MeshPart") then
			if part.TextureID ~= original.LastTexture and original.LastTexture ~= nil and part.TextureID ~= texture then original.TextureID = part.TextureID end
			part.TextureID = texture
			original.LastTexture = texture
		else
			if not original.OwnedTexture then
				original.OwnedTexture = create("Texture", part, {StudsPerTileU = 1, StudsPerTileV = 1})
			end
			original.OwnedTexture.Texture = texture
			original.OwnedTexture.Enabled = texture ~= ""
		end
	end)
end
local function restoreViewmodels()
	for part in pairs(vmOriginals) do restorePart(part) end
	for model, highlight in pairs(vmHighlights) do destroy(highlight); vmHighlights[model] = nil end
	for model, position in pairs(vmPositions) do
		pcall(function()
			if model:GetPivot() == position.Last then model:PivotTo(position.Original) end
		end)
		vmPositions[model] = nil
	end
	table.clear(vmParts)
	table.clear(vmCache)
end
local function updateViewmodels(now)
	local enabled = active() and (State.Gun.Enabled or State.Arms.Enabled or State.Viewmodel.Highlight or State.Viewmodel.Position)
	if not enabled then
		if vmWasActive then restoreViewmodels() end
		vmWasActive = false
		return
	end
	vmWasActive = true
	if now >= (API.Diagnostics.ViewmodelScanAt or 0) then
		API.Diagnostics.ViewmodelScanAt = now + (lowPC() and 1 or 0.5)
		vmCache = viewmodels()
		table.clear(vmParts)
		for _, model in ipairs(vmCache) do
			if model and model.Parent then
				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then vmParts[#vmParts + 1] = {Part = part, Model = model, Arms = armPart(part, model)} end
				end
			end
		end
	end
	local activeModels, activeParts = {}, {}
	for _, item in ipairs(vmParts) do
		local part, model = item.Part, item.Model
		if part and part.Parent and model and model.Parent then
			activeModels[model] = true
			activeParts[part] = true
			local settings = item.Arms and State.Arms or State.Gun
			if settings.Enabled then applyPart(part, settings) elseif vmOriginals[part] then restorePart(part) end
		end
	end
	for part in pairs(vmOriginals) do
		if not activeParts[part] then restorePart(part) end
	end
	for _, model in ipairs(vmCache) do
		if model and model.Parent then
			if State.Viewmodel.Highlight then
				local highlight = vmHighlights[model]
				if not highlight then
					local parent = ensureAdornments()
					if parent then
						highlight = create("Highlight", parent, {DepthMode = Enum.HighlightDepthMode.AlwaysOnTop})
						vmHighlights[model] = highlight
					end
				end
				if highlight then
					highlight.Adornee = model
					highlight.Enabled = true
					highlight.FillColor = color3(State.Viewmodel.Fill)
					highlight.OutlineColor = color3(State.Viewmodel.Outline)
					highlight.FillTransparency = State.Viewmodel.FillTransparency
					highlight.OutlineTransparency = State.Viewmodel.OutlineTransparency
				end
			elseif vmHighlights[model] then
				destroy(vmHighlights[model]); vmHighlights[model] = nil
			end
			if State.Viewmodel.Position then
				local position = vmPositions[model]
				local current = model:GetPivot()
				if not position then
					position = {Original = current, Last = current}
					vmPositions[model] = position
				elseif current ~= position.Last then
					position.Original = current
				end
				local written = position.Original * CFrame.new(State.Viewmodel.X, State.Viewmodel.Y, State.Viewmodel.Z)
				model:PivotTo(written)
				position.Last = written
			elseif vmPositions[model] then
				local position = vmPositions[model]
				if model:GetPivot() == position.Last then model:PivotTo(position.Original) end
				vmPositions[model] = nil
			end
		end
	end
	for model, highlight in pairs(vmHighlights) do
		if not activeModels[model] then destroy(highlight); vmHighlights[model] = nil end
	end
	for model, position in pairs(vmPositions) do
		if not activeModels[model] then
			if model and model.Parent and model:GetPivot() == position.Last then model:PivotTo(position.Original) end
			vmPositions[model] = nil
		end
	end
end

-- Shot visuals use existing game events through API.Impact/TraceShot. They never
-- redirect a shot, install another Silent hook or change remote arguments.
local activeEffects = {}
local function ownEffect(object, lifetime)
	if not object then return end
	activeEffects[object] = true
	local count = 0
	for _ in pairs(activeEffects) do count += 1 end
	if count > 32 then
		for old in pairs(activeEffects) do activeEffects[old] = nil; destroy(old); break end
	end
	pcall(function() Debris:AddItem(object, lifetime or 2) end)
	task.delay((lifetime or 2) + 0.1, function()
		if activeEffects[object] then activeEffects[object] = nil; destroy(object) end
	end)
end
function API.Bullet(origin, position)
	if not active() or not State.Bullet.Enabled or typeof(origin) ~= "Vector3" or typeof(position) ~= "Vector3" then return end
	local parent = ensureEffects()
	local part = create("Part", parent, {
		Name = "CalamariTracer", Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
		Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1),
	})
	local a0 = create("Attachment", part, {WorldPosition = origin})
	local a1 = create("Attachment", part, {WorldPosition = position})
	local beam = create("Beam", part, {
		Attachment0 = a0, Attachment1 = a1, FaceCamera = true, Brightness = 10,
		LightEmission = State.Bullet.Type == "Dark" and 0.25 or 1,
		LightInfluence = State.Bullet.Type == "Dark" and 1 or 0,
		Width0 = State.Bullet.Type == "Water" and 0.3 or 0.5,
		Width1 = State.Bullet.Type == "Water" and 0.3 or 0.5,
		Color = ColorSequence.new(color3(State.Bullet.Color)),
	})
	if State.Bullet.Type == "Dark" then
		beam.Texture = "rbxassetid://12781848822"
		beam.TextureLength, beam.TextureSpeed = 20, 0.9
		beam.TextureMode = Enum.TextureMode.Static
	elseif State.Bullet.Type == "Water" then
		beam.Texture = "rbxassetid://12788927812"
		beam.TextureLength, beam.TextureSpeed = 10, 1
		beam.TextureMode = Enum.TextureMode.Wrap
		beam.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color3(State.Bullet.Color)),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, color3(State.Bullet.Color)),
		})
	else
		beam.Texture = "rbxassetid://12781800668"
		beam.TextureLength, beam.TextureSpeed = 4, 10
		beam.TextureMode = Enum.TextureMode.Wrap
	end
	ownEffect(part, math.max(0.1, State.Bullet.Duration) + 1)
	API.Diagnostics.BulletTracers = (API.Diagnostics.BulletTracers or 0) + 1
	return part
end
local function hitNotification(instance, partName, damage)
	if not State.HitNotifications.Enabled then return end
	local parent = ensureGui()
	if not parent then return end
	local player
	if typeof(instance) == "Instance" then
		local model = instance:IsA("Model") and instance or nil
		if not model then
			local current = instance.Parent
			while current do
				if current:IsA("Model") then model = current; break end
				current = current.Parent
			end
		end
		if model then player = Players:GetPlayerFromCharacter(model) end
	end
	local text = "Hit"
	if player then text ..= " " .. (player.DisplayName or player.Name) end
	if partName then text ..= " / " .. tostring(partName) end
	if tonumber(damage) and damage > 0 then text ..= " / " .. tostring(math.floor(damage + 0.5)) end
	local label = textLabel(parent, 15)
	label.AnchorPoint = Vector2.new(0.5, 0, 0)
	label.Position = UDim2.new(0.5, 0, 0, 90)
	label.AutomaticSize = Enum.AutomaticSize.XY
	label.Size = UDim2.fromOffset(0, 0)
	label.Text = text
	label.TextColor3 = color3(State.Bullet.Color)
	addTextStroke(label)
	task.delay(3, function() destroy(label) end)
end
function API.Hit(position, instance, partName, damage)
	if not active() or typeof(position) ~= "Vector3" then return end
	if State.HitEffects.Enabled then
		local parent = ensureEffects()
		local part = create("Part", parent, {
			Name = "CalamariHitEffect", Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
			Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2), Position = position,
		})
		local emitter = create("ParticleEmitter", part, {
			Lifetime = NumberRange.new(State.HitEffects.Type == "Spark" and 0.4 or 1),
			Rate = 0, Speed = NumberRange.new(0, 0), Brightness = State.HitEffects.Type == "Spark" and 5 or 2,
			Color = ColorSequence.new(color3(State.HitEffects.Color1), color3(State.HitEffects.Color2)),
			Size = NumberSequence.new(State.HitEffects.Type == "Spark" and 8 or 4),
			Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
		})
		emitter.Texture = State.HitEffects.Type == "Spark" and "rbxassetid://10198439352"
			or State.HitEffects.Type == "SmokeRing" and "rbxassetid://12906276200" or "rbxassetid://14354336687"
		pcall(function() emitter:Emit(State.HitEffects.Type == "particles.js" and 6 or 1) end)
		ownEffect(part, 2)
		API.Diagnostics.HitEffects = (API.Diagnostics.HitEffects or 0) + 1
	end
	hitNotification(instance, partName, damage)
end
function API.Impact(origin, position, instance, partName, damage)
	API.Bullet(origin, position)
	API.Hit(position, instance, partName, damage)
end
function API.TraceShot(origin, direction, maxDistance, ignore)
	if not active() or typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then return nil end
	if not (State.Bullet.Enabled or State.HitEffects.Enabled or State.HitNotifications.Enabled) then return nil end
	if direction.Magnitude <= 0.001 then return nil end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	params.FilterDescendantsInstances = {ignore or (LocalPlayer and LocalPlayer.Character)}
	local result = workspace:Raycast(origin, direction.Unit * (tonumber(maxDistance) or 1000), params)
	local position = result and result.Position or origin + direction.Unit * (tonumber(maxDistance) or 1000)
	API.Bullet(origin, position)
	if result and result.Instance then
		API.Hit(position, result.Instance, result.Instance.Name)
	end
	return result
end

-- Lighting and optional Camera controls use per-property ownership. Off/Unload
-- restores only values still owned by this runtime; later game writes win.
local ownedGroups = {}
local createdLighting = {}
local skyboxes = {
	Galaxy = {"15125283003", "15125281008", "15125277539", "15125279325", "15125274388", "15125275800"},
	Vaporwave = {"1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643"},
	Redshift = {"401664839", "401664862", "401664960", "401664881", "401664901", "401664936"},
	Desert = {"1013852", "1013853", "1013850", "1013851", "1013849", "1013854"},
	Blaze = {"150939022", "150939038", "150939047", "150939056", "150939063", "150939082"},
	["Among Us"] = {"5752463190", "5752463190", "5752463190", "5752463190", "5752463190", "5752463190"},
	["Space Wave2"] = {"1233158420", "1233158838", "1233157105", "1233157640", "1233157995", "1233159158"},
	["Turquoise Wave"] = {"47974894", "47974690", "47974821", "47974776", "47974859", "47974909"},
	["Dark Night"] = {"6285719338", "6285721078", "6285722964", "6285724682", "6285726335", "6285730635"},
	["Bright Pink"] = {"271042516", "271077243", "271042556", "271042310", "271042467", "271077958"},
	["Oblivion Lost"] = {"5103110171", "5102993828", "5103111020", "5103112417", "5103113734", "5102993828"},
	["Setting Sun"] = {"626460377", "626460216", "626460513", "626473032", "626458639", "626460625"},
}
local function groupWrite(group, object, property, value)
	if not object then return end
	local groups = ownedGroups[group]
	if not groups then groups = {}; ownedGroups[group] = groups end
	local entries = groups[object]
	if not entries then entries = {}; groups[object] = entries end
	local entry = entries[property]
	if not entry then
		entry = {Original = object[property]}; entries[property] = entry
	end
	pcall(function()
		local current = object[property]
		if entry.Last ~= nil and current ~= entry.Last and current ~= value then entry.Original = current end
		if current ~= value then object[property] = value end
		entry.Last = value
	end)
end
local function groupRestore(group)
	local groups = ownedGroups[group]
	if not groups then return end
	for object, entries in pairs(groups) do
		for property, entry in pairs(entries) do
			pcall(function() if object[property] == entry.Last then object[property] = entry.Original end end)
		end
	end
	ownedGroups[group] = nil
end
local function effectObject(className, key)
	local existing = Lighting:FindFirstChildOfClass(className)
	if existing then return existing end
	local object = createdLighting[key]
	if object and object.Parent then return object end
	object = Instance.new(className)
	object.Name = "BurmaldaCalamari" .. key
	object.Parent = Lighting
	createdLighting[key] = object
	return object
end
local function applyLightingGroup(name, enabled, writes)
	if enabled then
		for _, write in ipairs(writes) do groupWrite(name, write[1], write[2], write[3]) end
	elseif ownedGroups[name] or createdLighting[name] then
		groupRestore(name)
		if createdLighting[name] then destroy(createdLighting[name]); createdLighting[name] = nil end
	end
end
local function updateLighting()
	local s = State.Lighting
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	local clouds = terrain and terrain:FindFirstChild("Clouds")
	local atmosphere = Lighting:FindFirstChild("Atmosphere")
	applyLightingGroup("CloudDensity", s.CloudDensity, {{clouds, "Density", s.CloudDensityValue}})
	applyLightingGroup("CloudCover", s.CloudCover, {{clouds, "Cover", s.CloudCoverValue}})
	applyLightingGroup("CloudColor", s.CloudColor, {{clouds, "Color", color3(s.CloudColorValue)}})
	local fog = s.NoFog or s.FogDensity or s.FogHaze or s.FogGlare
	local fogWrites = {}
	if s.NoFog then
		fogWrites[#fogWrites + 1] = {Lighting, "FogStart", 999999}
		fogWrites[#fogWrites + 1] = {Lighting, "FogEnd", 999999}
		fogWrites[#fogWrites + 1] = {atmosphere, "Offset", 0}
	end
	if atmosphere and (s.NoFog or s.FogDensity) then fogWrites[#fogWrites + 1] = {atmosphere, "Density", s.NoFog and 0 or s.FogDensityValue} end
	if atmosphere and (s.NoFog or s.FogHaze) then fogWrites[#fogWrites + 1] = {atmosphere, "Haze", s.NoFog and 0 or s.FogHazeValue} end
	if atmosphere and (s.NoFog or s.FogGlare) then fogWrites[#fogWrites + 1] = {atmosphere, "Glare", s.NoFog and 0 or s.FogGlareValue} end
	applyLightingGroup("Fog", fog, fogWrites)
	applyLightingGroup("FogColor", s.FogColor and atmosphere ~= nil, {{atmosphere, "Color", color3(s.FogColorValue)}})
	applyLightingGroup("Fullbright", s.Fullbright, {{Lighting, "Brightness", s.Brightness}})
	applyLightingGroup("Ambient", s.Ambient, {{Lighting, "Ambient", color3(s.AmbientColor)}, {Lighting, "OutdoorAmbient", color3(s.AmbientColor)}})
	applyLightingGroup("Time", s.Time, {{Lighting, "ClockTime", s.TimeValue}})
	if s.Skybox then
		local sky = effectObject("Sky", "Skybox")
		local ids = skyboxes[s.SkyboxPreset] or skyboxes.Galaxy
		applyLightingGroup("Skybox", true, {
			{sky, "SkyboxBk", "rbxassetid://" .. ids[1]}, {sky, "SkyboxDn", "rbxassetid://" .. ids[2]},
			{sky, "SkyboxFt", "rbxassetid://" .. ids[3]}, {sky, "SkyboxLf", "rbxassetid://" .. ids[4]},
			{sky, "SkyboxRt", "rbxassetid://" .. ids[5]}, {sky, "SkyboxUp", "rbxassetid://" .. ids[6]},
		})
	else
		applyLightingGroup("Skybox", false, {})
	end
	local sun = s.SunRays and effectObject("SunRaysEffect", "SunRays") or nil
	applyLightingGroup("SunRays", s.SunRays, {{sun, "Enabled", true}, {sun, "Intensity", s.SunIntensity}, {sun, "Spread", s.SunSpread}})
	local bloom = s.Bloom and effectObject("BloomEffect", "Bloom") or nil
	applyLightingGroup("Bloom", s.Bloom, {{bloom, "Enabled", true}, {bloom, "Intensity", s.BloomIntensity}, {bloom, "Size", s.BloomSize}, {bloom, "Threshold", s.BloomThreshold}})
end

local function keyHeld(name)
	if name == "LMB" or name == "RMB" then
		return UIS:IsMouseButtonPressed(name == "LMB" and Enum.UserInputType.MouseButton1 or Enum.UserInputType.MouseButton2)
	end
	local key = Enum.KeyCode[name]
	return key ~= nil and UIS:IsKeyDown(key)
end
local function updateCamera()
	if not options.Camera or options.Camera == "None" then return end
	local s = State.Camera
	local camera = workspace.CurrentCamera
	local zoom = s.Zoom and keyHeld(s.ZoomKey)
	if camera then
		local enabled = s.CustomFOV or zoom
		applyLightingGroup("CalamariCameraFOV", enabled, {{camera, "FieldOfView", zoom and s.ZoomAmount or s.FOV}})
	end
	local third = options.Camera == "Full" or options.Camera == "ThirdPerson"
	if third and LocalPlayer then
		applyLightingGroup("CalamariThirdPerson", s.ThirdPerson, {
			{LocalPlayer, "CameraMode", s.ThirdPerson and Enum.CameraMode.Classic or LocalPlayer.CameraMode},
			{LocalPlayer, "CameraMinZoomDistance", s.Distance},
			{LocalPlayer, "CameraMaxZoomDistance", s.Distance},
		})
	end
end

local lightingClock = 0
local function restoreAll()
	hideAllPlayers()
	for _, label in ipairs(worldLabels) do setProperty(label, "Visible", false) end
	restoreViewmodels()
	for group in pairs(ownedGroups) do groupRestore(group) end
	for key, object in pairs(createdLighting) do destroy(object); createdLighting[key] = nil end
	for object in pairs(activeEffects) do destroy(object) end
	table.clear(activeEffects)
end
function API.DisableAll()
	for _, path in ipairs({
		"Player.Enabled", "World.Enabled", "Gun.Enabled", "Arms.Enabled",
		"Viewmodel.Highlight", "Viewmodel.Position", "Bullet.Enabled",
		"HitEffects.Enabled", "HitNotifications.Enabled",
		"Camera.CustomFOV", "Camera.Zoom", "Camera.ThirdPerson",
	}) do API.Set(path, false) end
	for key, value in pairs(State.Lighting) do
		if type(value) == "boolean" then State.Lighting[key] = false end
	end
	Revision += 1
	restoreAll()
end
function API.Update(dt)
	if API.Unloaded or not active() then return end
	local now = os.clock()
	if options.Camera and options.Camera ~= "None" then
		local cameraOk, cameraErr = pcall(updateCamera)
		if not cameraOk then API.Diagnostics.CameraError = tostring(cameraErr) end
	end
	local interval = lowPC() and 0.1 or 0.05
	API.Diagnostics.Accumulator = (API.Diagnostics.Accumulator or 0) + dt
	if API.Diagnostics.Accumulator < interval then return end
	local step = API.Diagnostics.Accumulator
	API.Diagnostics.Accumulator = 0
	local ok, err
	ok, err = pcall(updatePlayers, now); if not ok then API.Diagnostics.PlayerError = tostring(err) end
	ok, err = pcall(updateWorld, now); if not ok then API.Diagnostics.WorldError = tostring(err) end
	ok, err = pcall(updateViewmodels, now); if not ok then API.Diagnostics.ViewmodelError = tostring(err) end
	lightingClock += step
	if lightingClock >= 0.2 or API.Diagnostics.LightingDirty then
		lightingClock = 0
		API.Diagnostics.LightingDirty = nil
		ok, err = pcall(updateLighting); if not ok then API.Diagnostics.LightingError = tostring(err) end
	end
end
function API.Unload()
	if API.Unloaded then return end
	API.Unloaded = true
	API.Diagnostics.Unloaded = true
	API.Diagnostics.RenderDisconnected = true
	for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
	table.clear(connections)
	restoreAll()
	for key in pairs(playerEntries) do removePlayerEntry(key) end
	destroy(gui); gui = nil
	destroy(adornmentFolder); adornmentFolder = nil
	destroy(effectFolder); effectFolder = nil
end
connect(RunService.RenderStepped:Connect(function(dt) API.Update(dt) end))
if type(options.OnCleanup) == "function" then options.OnCleanup(API.Unload) end
API.Skyboxes = skyboxes
API.Textures = textures
API.WorldCategories = worldCategories
return API
end
return createBurmaldaCalamariVisuals

	end)()
	local calamari = calamariFactory({
		Game = "Fust Survival",
		State = {},
		Camera = "Full",
		IsActive = function() return Runtime.Ready and not Runtime.Unloaded end,
		IsLowPC = function() return S.LowPC == true end,
		Adapter = {
			WorldRoots = {
				"Loot", "Deployables", "WorldItems", "DroppedItems", "Dropped", "Debris", "Corpses",
				"DeadBodies", "Bags", "Dead", "LootBags", "DeathBags", "Drops", "Nodes", "OreNodes",
				"Pickups", "SpawnedPickups", "GroundItems", "Animals", "FustAtvs", "FustBoats",
				"FustMinicopters", "FustMinicopter", "FustCars", "FustVehicles",
			},
			GetWorldEntries = function()
				local result = {}
				for _, entry in ipairs(Runtime.World and Runtime.World.Entries or {}) do
					local category, label = nil, tostring(entry.Label or "")
					local lower = string.lower(label)
					if entry.Category == "Nodes" then
						category = string.find(lower, "sulfur", 1, true) and "Phosphate"
							or string.find(lower, "metal", 1, true) and "Metal" or "Stone"
					elseif entry.Category == "Drops" then
						category = (string.find(lower, "body", 1, true) or string.find(lower, "bag", 1, true)
							or string.find(lower, "corpse", 1, true)) and "Body Bag" or "Drops"
					elseif entry.Category == "Base" then
						category = string.find(lower, "shotgun", 1, true) and "Shotgun Turret"
							or string.find(lower, "turret", 1, true) and "Auto Turret" or nil
					elseif entry.Category == "Loot" and string.find(lower, "care", 1, true) then
						category = "Care Package"
					elseif entry.Category == "Vehicles" and string.find(lower, "flycopter", 1, true) then
						category = "Salvaged Flycopter"
					elseif entry.Category == "Pickups" and string.find(lower, "hemp", 1, true) then
						category = "Wool"
					end
					if category and entry.Model then
						result[#result + 1] = {Object = entry.Model, Category = category, Name = label}
					end
				end
				return result
			end,
		},
	})
	Runtime.CalamariVisuals = calamari
	Runtime.CalamariVisualHookOwned = false
	Runtime.CalamariVisualHookNext = 0
	onCleanup(function()
		calamari.Unload()
		if Runtime.CalamariVisuals == calamari then Runtime.CalamariVisuals = nil end
	end)
	local mountCalamari = (function()
-- Shared control layout for the local 621x542 Burmalda menu.
-- The host owns createFeature/addSlider/addDropdown/addColor/addBind/getTab/getSection.
local function mountBurmaldaCalamariMenu(API, menuOptions)
	menuOptions = menuOptions or {}
	local function section(parent, name)
		return getSection(parent, name).Content
	end
	local function caption(name)
		name = tostring(name)
		return string.sub(name, 1, 9) == "Calamari " and name or "Calamari " .. name
	end
	local function feature(parent, name, path)
		local container = createFeature(parent, name, API.Get(path) == true, function(value)
			API.Set(path, value == true)
		end)
		API.Bind(path, function(value)
			if _fFS[name] then _fFS[name](value == true) end
		end)
		return container
	end
	local function onOff(parent, name, path)
		local setter = addDropdown(parent, caption(name), {"Off", "On"}, API.Get(path) and 2 or 1, function(value)
			API.Set(path, value == "On")
		end)
		API.Bind(path, function(value) setter(value and "On" or "Off") end)
		return setter
	end
	local function slider(parent, name, path, minimum, maximum, scale)
		scale = scale or 1
		local setter = addSlider(parent, caption(name), minimum, maximum, (tonumber(API.Get(path)) or 0) * scale, function(value)
			API.Set(path, value / scale)
		end)
		API.Bind(path, function(value) setter((tonumber(value) or 0) * scale) end)
		return setter
	end
	local function dropdown(parent, name, path, values)
		local current, defaultIndex = API.Get(path), 1
		for index, value in ipairs(values) do if value == current then defaultIndex = index; break end end
		local setter = addDropdown(parent, caption(name), values, defaultIndex, function(value) API.Set(path, value) end)
		API.Bind(path, function(value) setter(value) end)
		return setter
	end
	local function color(parent, name, path)
		local value = API.Get(path)
		local initial = Color3.fromRGB(value[1] or 255, value[2] or 255, value[3] or 255)
		local setter = addColor(parent, caption(name), function(value) API.SetColor(path, value) end, initial)
		API.Bind(path, function(rgb)
			setter(Color3.fromRGB(rgb[1] or 255, rgb[2] or 255, rgb[3] or 255))
		end)
		return setter
	end
	local function bind(parent, name, path, onPress)
		local api = addBind(parent, caption(name), API.Get(path) or "None", onPress, function(value) API.Set(path, value) end)
		API.Bind(path, function(value) api.Set(value or "None") end)
		return api
	end

	local left, right = getTab("VISUALS")
	local playerSection = section(left, "Calamari Player ESP")
	local player = feature(playerSection, "Calamari Player ESP", "Player.Enabled")
	slider(player, "Calamari Max Distance", "Player.MaxDistance", 100, 10000)
	slider(player, "Calamari Max Targets", "Player.MaxTargets", 8, 128)
	onOff(player, "Box", "Player.Box")
	color(player, "High Contrast Box", "Player.BoxHigh")
	color(player, "Low Contrast Box", "Player.BoxLow")
	slider(player, "Box High Alpha %", "Player.BoxHighTransparency", 0, 100, 100)
	slider(player, "Box Low Alpha %", "Player.BoxLowTransparency", 0, 100, 100)
	slider(player, "Box Gradient Rotation", "Player.BoxRotation", -180, 180)
	onOff(player, "Calamari Box Fill", "Player.Fill")
	color(player, "High Contrast Fill", "Player.FillHigh")
	color(player, "Low Contrast Fill", "Player.FillLow")
	slider(player, "Fill High Transparency %", "Player.FillHighTransparency", 0, 100, 100)
	slider(player, "Fill Low Transparency %", "Player.FillLowTransparency", 0, 100, 100)
	slider(player, "Box Fill Rotation", "Player.FillRotation", -180, 180)
	onOff(player, "Box Glow", "Player.Glow")
	color(player, "High Contrast Glow", "Player.GlowHigh")
	color(player, "Low Contrast Glow", "Player.GlowLow")
	slider(player, "Glow High Transparency %", "Player.GlowHighTransparency", 0, 100, 100)
	slider(player, "Glow Low Transparency %", "Player.GlowLowTransparency", 0, 100, 100)
	slider(player, "Box Glow Rotation", "Player.GlowRotation", -180, 180)
	onOff(player, "Healthbar", "Player.Healthbar")
	onOff(player, "Healthbar Text", "Player.HealthText")
	color(player, "High Health", "Player.HealthHigh")
	color(player, "Mid Health", "Player.HealthMid")
	color(player, "Low Health", "Player.HealthLow")
	onOff(player, "Calamari Names", "Player.Names")
	color(player, "Names Text Color", "Player.NameColor")
	onOff(player, "Distance Text", "Player.Distance")
	color(player, "Distance Text Color", "Player.DistanceColor")
	onOff(player, "Weapon Text", "Player.Weapon")
	color(player, "Weapon Text Color", "Player.WeaponColor")
	onOff(player, "Flags", "Player.Flags")
	color(player, "Flags Text Color", "Player.FlagsColor")
	onOff(player, "Calamari Chams", "Player.Chams")
	color(player, "Chams Inside Color", "Player.ChamsInside")
	color(player, "Chams Outside Color", "Player.ChamsOutside")
	slider(player, "Chams Inside Transparency %", "Player.ChamsInsideTransparency", 0, 100, 100)
	slider(player, "Chams Outline Transparency %", "Player.ChamsOutsideTransparency", 0, 100, 100)

	local worldSection = section(right, "Calamari Misc ESP")
	local world = feature(worldSection, "Calamari Misc ESP", "World.Enabled")
	for _, name in ipairs({
		"Stone", "Metal", "Phosphate", "Wool", "Animals", "Care Package", "Drops",
		"Body Bag", "Salvaged Flycopter", "Eggs", "Auto Turret", "Shotgun Turret",
	}) do
		local path = "World.Categories." .. name
		onOff(world, "Calamari " .. name, path .. ".Enabled")
		color(world, "Calamari " .. name .. " Color", path .. ".Color")
		slider(world, "Calamari " .. name .. " Max Distance", path .. ".MaxDistance", 10, 5000)
	end

	local vfxSection = section(right, "Calamari Gun VFX")
	local gun = feature(vfxSection, "Calamari Gun Chams", "Gun.Enabled")
	color(gun, "Gun Color", "Gun.Color")
	dropdown(gun, "Gun Material", "Gun.Material", {"ForceField", "Neon", "Glass", "Ice", "Wood", "Plastic", "Metal"})
	dropdown(gun, "Gun Texture", "Gun.Texture", {
		"Web", "Swirl", "Checkers", "CandyCane", "Dots", "Scanning", "Bubbles",
		"Player FF Texture", "Shield Forcefield", "Water", "America", "Rainbow", "Akatsuki", "None",
	})
	local arms = feature(vfxSection, "Calamari Arms Chams", "Arms.Enabled")
	color(arms, "Arms Color", "Arms.Color")
	dropdown(arms, "Arms Material", "Arms.Material", {"ForceField", "Neon", "Glass", "Ice", "Wood", "Plastic", "Metal"})
	dropdown(arms, "Arms Texture", "Arms.Texture", {
		"Web", "Swirl", "Checkers", "CandyCane", "Dots", "Scanning", "Bubbles",
		"Player FF Texture", "Shield Forcefield", "Water", "America", "Rainbow", "Akatsuki", "None",
	})
	local highlight = feature(vfxSection, "Calamari Viewmodel Highlight", "Viewmodel.Highlight")
	color(highlight, "Calamari VM Fill Color", "Viewmodel.Fill")
	slider(highlight, "Fill Transparency %", "Viewmodel.FillTransparency", 0, 100, 100)
	color(highlight, "Outline Color", "Viewmodel.Outline")
	slider(highlight, "Outline Transparency %", "Viewmodel.OutlineTransparency", 0, 100, 100)
	local position = feature(vfxSection, "Calamari Viewmodel Position", "Viewmodel.Position")
	slider(position, "X pos", "Viewmodel.X", -20, 20, 10)
	slider(position, "Y pos", "Viewmodel.Y", -20, 20, 10)
	slider(position, "Z pos", "Viewmodel.Z", -20, 20, 10)
	local bullet = feature(vfxSection, "Calamari Bullet Tracers", "Bullet.Enabled")
	dropdown(bullet, "Tracer Type", "Bullet.Type", {"Dark", "Lightning", "Water"})
	color(bullet, "Calamari Tracer Color", "Bullet.Color")
	slider(bullet, "Tracer Duration", "Bullet.Duration", 1, 50, 10)
	local effects = feature(vfxSection, "Calamari Hit Effects", "HitEffects.Enabled")
	dropdown(effects, "Hit Effect Type", "HitEffects.Type", {"Spark", "SmokeRing", "particles.js"})
	color(effects, "Hit Effect Color 1", "HitEffects.Color1")
	color(effects, "Hit Effect Color 2", "HitEffects.Color2")
	feature(vfxSection, "Calamari Hit Notifications", "HitNotifications.Enabled")

	local lightSection = section(left, "Calamari Lighting")
	local cloudDensity = feature(lightSection, "Calamari Cloud Density", "Lighting.CloudDensity")
	slider(cloudDensity, "Density", "Lighting.CloudDensityValue", 0, 1000, 1000)
	local cloudCover = feature(lightSection, "Calamari Cloud Cover", "Lighting.CloudCover")
	slider(cloudCover, "Cover", "Lighting.CloudCoverValue", 0, 1000, 1000)
	local cloudColor = feature(lightSection, "Calamari Cloud Color", "Lighting.CloudColor")
	color(cloudColor, "Cloud Color", "Lighting.CloudColorValue")
	feature(lightSection, "Calamari No Fog", "Lighting.NoFog")
	local fogDensity = feature(lightSection, "Calamari Fog Density", "Lighting.FogDensity")
	slider(fogDensity, "Fog Density", "Lighting.FogDensityValue", 0, 1000, 1000)
	local fogHaze = feature(lightSection, "Calamari Fog Haze", "Lighting.FogHaze")
	slider(fogHaze, "Haze", "Lighting.FogHazeValue", 0, 1000, 1000)
	local fogGlare = feature(lightSection, "Calamari Fog Glare", "Lighting.FogGlare")
	slider(fogGlare, "Glare", "Lighting.FogGlareValue", 0, 1000, 1000)
	local fogColor = feature(lightSection, "Calamari Fog Color", "Lighting.FogColor")
	color(fogColor, "Fog Color", "Lighting.FogColorValue")
	local fullbright = feature(lightSection, "Calamari Fullbright", "Lighting.Fullbright")
	slider(fullbright, "Brightness", "Lighting.Brightness", 0, 60, 10)
	local ambient = feature(lightSection, "Calamari Ambient", "Lighting.Ambient")
	color(ambient, "Ambient Color", "Lighting.AmbientColor")
	local time = feature(lightSection, "Calamari Time Changer", "Lighting.Time")
	slider(time, "Clock Time", "Lighting.TimeValue", 0, 240, 10)
	local sky = feature(lightSection, "Calamari Skybox", "Lighting.Skybox")
	local skyNames = {}
	for name in pairs(API.Skyboxes) do skyNames[#skyNames + 1] = name end
	table.sort(skyNames)
	dropdown(sky, "Skybox Preset", "Lighting.SkyboxPreset", skyNames)

	local postSection = section(right, "Calamari Lighting FX")
	local sun = feature(postSection, "Calamari Sun Rays", "Lighting.SunRays")
	slider(sun, "Sun Intensity", "Lighting.SunIntensity", 0, 50, 10)
	slider(sun, "Sun Spread", "Lighting.SunSpread", 0, 10, 10)
	local bloom = feature(postSection, "Calamari Bloom", "Lighting.Bloom")
	slider(bloom, "Bloom Intensity", "Lighting.BloomIntensity", 0, 100, 100)
	slider(bloom, "Bloom Size", "Lighting.BloomSize", 0, 1000)
	slider(bloom, "Bloom Threshold", "Lighting.BloomThreshold", 0, 200, 100)

	if menuOptions.Camera and menuOptions.Camera ~= "None" then
		local cameraSection = section(left, "Calamari Camera")
		if menuOptions.Camera == "Full" then
			local fov = feature(cameraSection, "Calamari Field Of View", "Camera.CustomFOV")
			slider(fov, "Calamari FOV Value", "Camera.FOV", 70, 120)
			local zoom = feature(cameraSection, "Calamari Zoom", "Camera.Zoom")
			slider(zoom, "Zoom Amount", "Camera.ZoomAmount", 20, 100)
			bind(zoom, "Zoom Key", "Camera.ZoomKey")
		end
		local third = feature(cameraSection, "Calamari Third Person", "Camera.ThirdPerson")
		slider(third, "Third Person Distance", "Camera.Distance", 5, 20)
		bind(third, "Third Person Key", "Camera.ThirdPersonKey", function()
			if _fFS["Calamari Third Person"] then
				_fFS["Calamari Third Person"](not API.Get("Camera.ThirdPerson"))
			end
		end)
	end
end
return mountBurmaldaCalamariMenu

	end)()
	mountCalamari(calamari, {Camera = "Full"})
end


function Runtime.Unload()
	if Runtime.Unloaded then return end
	Runtime.Unloaded = true
	for key, value in pairs(S) do
		if type(value) == "boolean" then S[key] = false end
	end
	if Runtime.TriggerRelease then pcall(Runtime.TriggerRelease) end
	if Runtime.Weapons and Runtime.Weapons.Restore then pcall(Runtime.Weapons.Restore) end
	if Runtime.Movement and Runtime.Movement.Restore then pcall(Runtime.Movement.Restore) end
	if Runtime.Environment and Runtime.Environment.Restore then pcall(Runtime.Environment.Restore) end
	for index = #Runtime.Cleanup, 1, -1 do
		pcall(Runtime.Cleanup[index])
	end
	for _, drawing in ipairs(Runtime.Drawings) do
		pcall(function() drawing:Remove() end)
	end
	table.clear(Runtime.Drawings)
	for gui in pairs(Runtime.Guis) do pcall(function() gui:Destroy() end) end
	table.clear(Runtime.Guis)
	if _fustEnv.BurmaldaFust == Runtime then _fustEnv.BurmaldaFust = nil end
end

local function guardedStep(name, callback, dt)
	if Runtime.Unloaded or type(callback) ~= "function" then return end
	local ok, err = pcall(callback, dt)
	if not ok then
		Runtime.Diagnostics.LastError = name .. ": " .. tostring(err)
		Runtime.Diagnostics[name .. "Errors"] = (Runtime.Diagnostics[name .. "Errors"] or 0) + 1
	end
end

local renderConnection
renderConnection = RunService.RenderStepped:Connect(function(dt)
	if Runtime.Unloaded or not Runtime.Ready then return end
	Camera = workspace.CurrentCamera or Camera
	if not Camera then return end
	Runtime.Camera = Camera
	guardedStep("Entities", Runtime.Entities and Runtime.Entities.Update, dt)
	guardedStep("World", Runtime.World and Runtime.World.Update, dt)
	guardedStep("Weapons", Runtime.Weapons and Runtime.Weapons.Update, dt)
	guardedStep("Movement", Runtime.Movement and Runtime.Movement.Update, dt)
	guardedStep("Environment", Runtime.Environment and Runtime.Environment.Update, dt)
	local calamari = Runtime.CalamariVisuals
	if calamari and Runtime.Aim then
		local visualShots = calamari.State.Bullet.Enabled or calamari.State.HitEffects.Enabled or calamari.State.HitNotifications.Enabled
		local now = os.clock()
		if visualShots and Runtime.Aim.SilentHookStatus ~= "installed" and now >= (Runtime.CalamariVisualHookNext or 0) then
			Runtime.CalamariVisualHookNext = now + 0.5
			local gameplayOwned = S.SilentAim or S.AutoCross
			local ok, installed = pcall(Runtime.Aim.InstallSilent)
			if ok and installed and not gameplayOwned then Runtime.CalamariVisualHookOwned = true end
		elseif not visualShots and not S.SilentAim and not S.AutoCross and Runtime.CalamariVisualHookOwned then
			if Runtime.Aim.RestoreSilent then pcall(Runtime.Aim.RestoreSilent) end
			Runtime.CalamariVisualHookOwned = false
		end
	end
	guardedStep("Aim", Runtime.Aim and Runtime.Aim.Update, dt)
	guardedStep("Trigger", Runtime.Aim and Runtime.Aim.UpdateTrigger, dt)
	guardedStep("Visuals", Runtime.Visuals and Runtime.Visuals.Update, dt)
end)
onCleanup(function()
	if renderConnection then pcall(function() renderConnection:Disconnect() end); renderConnection = nil end
end)

Runtime.Ready = true
