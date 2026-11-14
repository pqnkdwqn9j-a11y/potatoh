local _degradeEnv = getgenv and getgenv() or _G
if _degradeEnv.BurmaldaDEGRADE and _degradeEnv.BurmaldaDEGRADE.Unload then
	pcall(_degradeEnv.BurmaldaDEGRADE.Unload)
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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Runtime = {
	Unloaded = false,
	Ready = false,
	ExecutorName = executorName,
	PlaceId = 129437813830973,
	Cleanup = {},
	Drawings = {},
	Guis = {},
	BindApis = {},
	ConfigControls = {},
	FeatureHandlers = {},
	SettingHandlers = {},
	Diagnostics = {},
	RaycastBypass = 0,
	TabNames = {"COMBAT", "VISUALS", "MOVEMENT", "MISC", "CONFIG"},
	SupportedExecutors = {"Real", "Opiumware", "Madium", "Potassium", "Synapse Z", "Volt", "Volcano", "Solara"},
}
_degradeEnv.BurmaldaDEGRADE = Runtime

local S = {
	Aimbot = false,
	AimFOV = 180,
	AimRange = 1200,
	AimSmoothing = 8,
	AimPart = "Head",
	AimPriority = "Crosshair",
	AimKey = "RMB",
	AimTeamCheck = true,
	AimWallCheck = true,
	AimPrediction = false,
	BulletSpeed = 1000,
	FOVCircle = true,
	TargetLine = false,

	SilentAim = false,
	SilentFOV = 140,
	SilentRange = 1000,
	SilentPart = "Head",
	SilentPriority = "Crosshair",
	SilentTeamCheck = true,
	SilentWallCheck = true,
	SilentPrediction = false,
	AutoFire = false,
	AutoFireDelay = 90,

	PlayerESP = false,
	PlayerBox = true,
	BoxStyle = "2D",
	PlayerNames = true,
	PlayerDistance = true,
	PlayerHealth = true,
	PlayerHeldItem = true,
	PlayerTracers = false,
	TracerStart = "Bottom",
	PlayerChams = false,
	PlayerTeamCheck = true,
	PlayerRainbow = false,
	PlayerRange = 1500,
	PlayerTextSize = 13,

	Speed = false,
	SpeedValue = 24,
	Fly = false,
	FlySpeed = 50,
	Noclip = false,
	TeleportMouse = false,
	TeleportDistance = 1000,

	FullBright = false,
	RemoveFog = false,
	HideGrass = false,
	LowPC = false,
	HUD = true,
	UIAnimations = true,
	Freecam = false,
	FreecamSpeed = 50,
}

local Colors = {
	Accent = Color3.fromRGB(255, 255, 255),
	FOV = Color3.fromRGB(90, 175, 255),
	TargetLine = Color3.fromRGB(255, 90, 90),
	Player = Color3.fromRGB(90, 175, 255),
	PlayerText = Color3.fromRGB(240, 240, 240),
}
Runtime.State = S
Runtime.Colors = Colors

local function onCleanup(fn)
	table.insert(Runtime.Cleanup, fn)
end
Runtime.AddCleanup = onCleanup

local function trackDrawing(object)
	Runtime.Drawings[object] = true
	return object
end
local function releaseDrawing(object)
	if not object then return end
	Runtime.Drawings[object] = nil
	pcall(function() object:Remove() end)
end
Runtime.TrackDrawing = trackDrawing
Runtime.ReleaseDrawing = releaseDrawing

local _drawingNew = Drawing and Drawing.new or nil
local function newDrawing(kind)
	if not _drawingNew then return nil end
	local ok, object = pcall(_drawingNew, kind)
	if not ok or not object then return nil end
	object.Visible = false
	object.Transparency = 1
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
if type(gethui) == "function" then pcall(function() uiParent = gethui() end) end
if not uiParent then uiParent = LocalPlayer:WaitForChild("PlayerGui") end
for _, name in ipairs({"BurmaldaHookDEGRADE", "BurmaldaHookDEGRADEStats"}) do
	local old = uiParent:FindFirstChild(name)
	if old then old:Destroy() end
end

local sg = newScreenGui()
sg.Name = "BurmaldaHookDEGRADE"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.DisplayOrder = 999998
sg.Parent = uiParent

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
advGui.Name = "BurmaldaHookDEGRADEStats"
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

end

do
	local Shared = {}
	Runtime.Shared = Shared

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

	function Shared.Project(position)
		if not Camera or not position then return nil end
		local ok, point, onScreen = pcall(Camera.WorldToViewportPoint, Camera, position)
		if not ok or not point then return nil end
		return point.X, point.Y, point.Z, onScreen == nil or onScreen == true
	end

	function Shared.ToolName(character)
		local tool = character and character:FindFirstChildOfClass("Tool")
		return tool and tool.Name or ""
	end

	function Shared.IsTeammate(player)
		if not player then return false end
		if player == LocalPlayer then return true end
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
		Runtime.RaycastBypass += 1
		local ok, result = pcall(workspace.Raycast, workspace, origin, direction, params)
		Runtime.RaycastBypass -= 1
		if not ok then return true end
		if not result or not result.Instance then return true end
		if targetModel and result.Instance:IsDescendantOf(targetModel) then return true end
		return false
	end

	function Shared.KeyDown(key)
		if key == "Always" then return true end
		if key == "RMB" or key == "LMB" then
			local button = key == "RMB" and Enum.UserInputType.MouseButton2 or Enum.UserInputType.MouseButton1
			local ok, down = pcall(UIS.IsMouseButtonPressed, UIS, button)
			return ok and down == true
		end
		local code = key == "LeftAlt" and Enum.KeyCode.LeftAlt
			or key == "LeftControl" and Enum.KeyCode.LeftControl
			or key == "LeftShift" and Enum.KeyCode.LeftShift
			or type(key) == "string" and Enum.KeyCode[key] or nil
		if not code then return false end
		local ok, down = pcall(UIS.IsKeyDown, UIS, code)
		return ok and down == true
	end
end

do
	local Shared = Runtime.Shared
	local Movement = {
		NoclipOriginals = setmetatable({}, {__mode = "k"}),
		NoclipParts = {},
		NoclipCharacter = nil,
		NextNoclipScan = 0,
		FlyVelocity = nil,
		FlyGyro = nil,
		FlyHumanoid = nil,
		FlyPlatformStand = false,
	}
	Runtime.Movement = Movement

	function Movement.RestoreNoclip()
		for part, canCollide in pairs(Movement.NoclipOriginals) do
			pcall(function() part.CanCollide = canCollide end)
		end
		Movement.NoclipOriginals = setmetatable({}, {__mode = "k"})
		Movement.NoclipParts = {}
		Movement.NoclipCharacter = nil
		Movement.NextNoclipScan = 0
	end

	function Movement.RestoreFly()
		if Movement.FlyVelocity then pcall(function() Movement.FlyVelocity:Destroy() end) end
		if Movement.FlyGyro then pcall(function() Movement.FlyGyro:Destroy() end) end
		Movement.FlyVelocity = nil
		Movement.FlyGyro = nil
		if Movement.FlyHumanoid then
			pcall(function() Movement.FlyHumanoid.PlatformStand = Movement.FlyPlatformStand end)
		end
		Movement.FlyHumanoid = nil
		Movement.FlyPlatformStand = false
	end

	function Movement.Restore()
		Movement.RestoreNoclip()
		Movement.RestoreFly()
	end

	local function updateNoclip(character)
		local now = os.clock()
		if Movement.NoclipCharacter ~= character or now >= Movement.NextNoclipScan then
			Movement.NoclipCharacter = character
			Movement.NextNoclipScan = now + 1
			Movement.NoclipParts = {}
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					if Movement.NoclipOriginals[part] == nil then Movement.NoclipOriginals[part] = part.CanCollide end
					table.insert(Movement.NoclipParts, part)
				end
			end
		end
		for _, part in ipairs(Movement.NoclipParts) do
			if part.Parent then part.CanCollide = false end
		end
	end

	local function updateFly(character, humanoid, root)
		if Movement.FlyHumanoid ~= humanoid then
			Movement.RestoreFly()
			Movement.FlyHumanoid = humanoid
			Movement.FlyPlatformStand = humanoid.PlatformStand == true
		end
		if not Movement.FlyVelocity or Movement.FlyVelocity.Parent ~= root then
			if Movement.FlyVelocity then pcall(function() Movement.FlyVelocity:Destroy() end) end
			Movement.FlyVelocity = Instance.new("BodyVelocity")
			Movement.FlyVelocity.Name = "BurmaldaFlyVelocity"
			Movement.FlyVelocity.MaxForce = Vector3.new(1000000000, 1000000000, 1000000000)
			Movement.FlyVelocity.P = 1250
			Movement.FlyVelocity.Parent = root
		end
		if not Movement.FlyGyro or Movement.FlyGyro.Parent ~= root then
			if Movement.FlyGyro then pcall(function() Movement.FlyGyro:Destroy() end) end
			Movement.FlyGyro = Instance.new("BodyGyro")
			Movement.FlyGyro.Name = "BurmaldaFlyGyro"
			Movement.FlyGyro.MaxTorque = Vector3.new(1000000000, 1000000000, 1000000000)
			Movement.FlyGyro.P = 90000
			Movement.FlyGyro.Parent = root
		end
		humanoid.PlatformStand = true
		local direction = Vector3.zero
		local look = Camera.CFrame.LookVector or Vector3.new(0, 0, -1)
		local right = Camera.CFrame.RightVector or Vector3.new(1, 0, 0)
		if Shared.KeyDown("W") then direction += look end
		if Shared.KeyDown("S") then direction -= look end
		if Shared.KeyDown("D") then direction += right end
		if Shared.KeyDown("A") then direction -= right end
		if Shared.KeyDown("Space") then direction += Vector3.new(0, 1, 0) end
		if Shared.KeyDown("LeftControl") then direction -= Vector3.new(0, 1, 0) end
		Movement.FlyVelocity.Velocity = direction.Magnitude > 0.05 and direction.Unit * S.FlySpeed or Vector3.zero
		Movement.FlyGyro.CFrame = Camera.CFrame
	end

	function Movement.TeleportToMouse()
		if Runtime.Unloaded or not Camera then return false end
		local character = Shared.Character()
		local root = Shared.Root(character)
		if not character or not root then return false end
		local mouse = UIS:GetMouseLocation()
		local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {character}
		params.IgnoreWater = true
		Runtime.RaycastBypass += 1
		local ok, result = pcall(workspace.Raycast, workspace, ray.Origin, ray.Direction * S.TeleportDistance, params)
		Runtime.RaycastBypass -= 1
		if not ok then return false end
		local destination
		if result and result.Position then
			destination = result.Position + Vector3.new(0, 3, 0)
		else
			destination = ray.Origin + ray.Direction * 100
		end
		root.CFrame = CFrame.new(destination)
		return true
	end

	function Movement.Update()
		local character = Shared.Character()
		local humanoid = Shared.Humanoid(character)
		local root = Shared.Root(character)
		if not character or not humanoid or not root or humanoid.Health <= 0 then
			if Movement.FlyHumanoid or Movement.FlyVelocity or Movement.FlyGyro then Movement.RestoreFly() end
			return
		end
		if S.Speed and not S.Fly and not humanoid.Sit then
			local direction = humanoid.MoveDirection
			if direction.Magnitude > 0.05 then
				direction = direction.Unit
				local velocity = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(direction.X * S.SpeedValue, velocity.Y, direction.Z * S.SpeedValue)
			end
		end
		if S.Fly then
			updateFly(character, humanoid, root)
		elseif Movement.FlyHumanoid or Movement.FlyVelocity or Movement.FlyGyro then
			Movement.RestoreFly()
		end
		if S.Noclip then
			updateNoclip(character)
		elseif Movement.NoclipCharacter then
			Movement.RestoreNoclip()
		end
	end

	local characterConnection = LocalPlayer.CharacterAdded:Connect(function()
		Movement.RestoreNoclip()
		Movement.RestoreFly()
	end)
	local removingConnection = LocalPlayer.CharacterRemoving:Connect(function()
		Movement.RestoreNoclip()
		Movement.RestoreFly()
	end)
	onCleanup(function()
		if characterConnection then pcall(function() characterConnection:Disconnect() end) end
		if removingConnection then pcall(function() removingConnection:Disconnect() end) end
		Movement.Restore()
	end)
end

do
	local Environment = {Captured = false, NextApply = 0}
	Runtime.Environment = Environment
	local Terrain = workspace.Terrain or workspace:FindFirstChildOfClass("Terrain")
	local lightingProperties = {
		"Brightness", "ClockTime", "TimeOfDay", "Ambient", "OutdoorAmbient",
		"ExposureCompensation", "FogEnd", "FogStart", "FogColor", "GlobalShadows",
		"EnvironmentDiffuseScale", "EnvironmentSpecularScale",
	}
	local savedLighting = {}
	local savedEffects = setmetatable({}, {__mode = "k"})
	local savedTerrainDecoration
	local fullBrightValues = {
		Brightness = 2,
		ClockTime = 14,
		TimeOfDay = "14:00:00",
		Ambient = Color3.fromRGB(200, 200, 200),
		OutdoorAmbient = Color3.fromRGB(200, 200, 200),
		ExposureCompensation = 0,
		FogColor = Color3.fromRGB(210, 210, 210),
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 0,
	}
	local fogValues = {FogStart = 100000, FogEnd = 1000000}
	local effectProperties = {
		Atmosphere = {"Density", "Haze", "Glare", "Offset"},
		BloomEffect = {"Enabled"},
		ColorCorrectionEffect = {"Enabled"},
		SunRaysEffect = {"Enabled"},
		DepthOfFieldEffect = {"Enabled"},
	}

	local function active()
		return S.FullBright or S.RemoveFog or S.HideGrass or S.LowPC
	end
	local function read(object, property)
		local ok, value = pcall(function() return object[property] end)
		if ok then return true, value end
		return false, nil
	end
	local function write(object, property, value)
		pcall(function() object[property] = value end)
	end
	local function capture()
		if Environment.Captured then return end
		Environment.Captured = true
		for _, property in ipairs(lightingProperties) do
			local ok, value = read(Lighting, property)
			if ok then savedLighting[property] = value end
		end
		if Terrain then
			local ok, value = read(Terrain, "Decoration")
			if ok then savedTerrainDecoration = value end
		end
	end
	local function captureEffect(effect)
		if savedEffects[effect] then return end
		local properties = effectProperties[effect.ClassName]
		if not properties then return end
		local values = {}
		for _, property in ipairs(properties) do
			local ok, value = read(effect, property)
			if ok then values[property] = value end
		end
		savedEffects[effect] = values
	end
	local function applyLighting()
		for property, original in pairs(savedLighting) do
			local value = original
			if S.FullBright and fullBrightValues[property] ~= nil then value = fullBrightValues[property] end
			if (S.FullBright or S.RemoveFog) and fogValues[property] ~= nil then value = fogValues[property] end
			if (S.FullBright or S.LowPC) and property == "GlobalShadows" then value = false end
			write(Lighting, property, value)
		end
	end
	local function applyEffects()
		for _, effect in ipairs(Lighting:GetChildren()) do
			local properties = effectProperties[effect.ClassName]
			if properties then
				captureEffect(effect)
				local values = savedEffects[effect]
				for _, property in ipairs(properties) do
					local value = values[property]
					if S.FullBright and effect.ClassName == "Atmosphere" then value = 0 end
					if S.LowPC and property == "Enabled" and effect.ClassName ~= "Atmosphere" then value = false end
					if value ~= nil then write(effect, property, value) end
				end
			end
		end
	end

	function Environment.Apply()
		if not active() then
			Environment.Restore()
			return
		end
		capture()
		applyLighting()
		applyEffects()
		if Terrain and savedTerrainDecoration ~= nil then
			local decoration = savedTerrainDecoration
			if S.HideGrass or S.LowPC then decoration = false end
			write(Terrain, "Decoration", decoration)
		end
		Environment.NextApply = os.clock() + 0.5
	end

	function Environment.Restore()
		if not Environment.Captured then return end
		for property, value in pairs(savedLighting) do write(Lighting, property, value) end
		for effect, values in pairs(savedEffects) do
			for property, value in pairs(values) do write(effect, property, value) end
		end
		if Terrain and savedTerrainDecoration ~= nil then write(Terrain, "Decoration", savedTerrainDecoration) end
		savedLighting = {}
		savedEffects = setmetatable({}, {__mode = "k"})
		savedTerrainDecoration = nil
		Environment.Captured = false
		Environment.NextApply = 0
	end

	function Environment.Update()
		if active() and os.clock() >= Environment.NextApply then Environment.Apply() end
	end
	onCleanup(Environment.Restore)
end

do
	local Shared = Runtime.Shared
	local Aim = {
		CurrentTarget = nil,
		CurrentPosition = nil,
		SilentTarget = nil,
		SilentPosition = nil,
		HookStatus = "not installed",
		NextAutoFire = 0,
	}
	Runtime.Aim = Aim

	local boneSets = {
		Head = {"Head"},
		Body = {"UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart"},
		Root = {"HumanoidRootPart", "Torso", "UpperTorso"},
		Closest = {"Head", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart"},
	}
	local aimOptions = {}
	local silentOptions = {}
	local aimBest, silentBest = {}, {}
	local fovCircle = newDrawing("Circle")
	local targetLine = newDrawing("Line")
	if fovCircle then
		fovCircle.NumSides = 40
		fovCircle.Thickness = 1
		fovCircle.Filled = false
		fovCircle.Transparency = 1
	end
	if targetLine then
		targetLine.Thickness = 1
		targetLine.Transparency = 1
	end

	local function resetBest(best)
		best.Score = math.huge
		best.Target = nil
		best.Part = nil
		best.Position = nil
		best.ScreenX = nil
		best.ScreenY = nil
	end

	local function consider(player, options, best)
		if player == LocalPlayer then return end
		local character = player.Character
		local humanoid = Shared.Humanoid(character)
		local root = Shared.Root(character)
		if not character or not humanoid or not root or humanoid.Health <= 0 then return end
		if options.TeamCheck and Shared.IsTeammate(player) then return end
		local origin = Camera.CFrame.Position
		local parts = boneSets[options.PartMode] or boneSets.Head
		for _, name in ipairs(parts) do
			local part = character:FindFirstChild(name)
			if part and part:IsA("BasePart") then
				local position = part.Position
				local distance = (position - origin).Magnitude
				if distance <= options.Range then
			local x, y, z = Shared.Project(position)
				if x and z > 0 then
					local dx = x - Camera.ViewportSize.X * 0.5
					local dy = y - Camera.ViewportSize.Y * 0.5
					local screenDistance = math.sqrt(dx * dx + dy * dy)
					if screenDistance <= options.FOV then
						local score = screenDistance
						if options.Priority == "Distance" then
							score = distance + screenDistance * 0.0001
						elseif options.Priority == "Low HP" then
							score = humanoid.Health + screenDistance * 0.0001
						end
						if score < best.Score then
							if not options.WallCheck or Shared.WallClear(position, character) then
								best.Score = score
								best.Target = {
									Model = character,
									Root = root,
									Humanoid = humanoid,
									Player = player,
								}
								best.Part = part
								best.Position = position
								best.ScreenX = x
								best.ScreenY = y
							end
						end
					end
				end
				end
			end
		end
	end

	local function selectTarget(options, best)
		resetBest(best)
		for _, player in ipairs(Players:GetPlayers()) do consider(player, options, best) end
		return best.Target and best or nil
	end
	Aim.SelectTarget = selectTarget

	local function predictedPosition(best, enabled)
		local position = best.Position
		if not enabled or not Camera then return position end
		local speed = math.max(1, tonumber(S.BulletSpeed) or 1000)
		local travel = math.clamp((position - Camera.CFrame.Position).Magnitude / speed, 0, 0.5)
		local velocity = best.Target.Root.AssemblyLinearVelocity or Vector3.zero
		return position + velocity * travel
	end
	Aim.PredictedPosition = predictedPosition

	local originalRaycast, wrappedRaycast
	local hookInstalled = false
	local function raycastReplacement(self, origin, direction, params, ...)
		if not originalRaycast then return nil end
		if Runtime.Unloaded or not S.SilentAim or Runtime.MenuOpen or Runtime.RaycastBypass > 0 or self ~= workspace then
			return originalRaycast(self, origin, direction, params, ...)
		end
		if type(checkcaller) == "function" then
			local ok, executor = pcall(checkcaller)
			if ok and executor == true then return originalRaycast(self, origin, direction, params, ...) end
		end
		local position = Aim.SilentPosition
		if typeof(position) ~= "Vector3" or typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
			return originalRaycast(self, origin, direction, params, ...)
		end
		local redirected = position - origin
		if redirected.Magnitude <= 0.01 then return originalRaycast(self, origin, direction, params, ...) end
		Runtime.Diagnostics.SilentRedirects = (Runtime.Diagnostics.SilentRedirects or 0) + 1
		return originalRaycast(self, origin, redirected, params, ...)
	end

	function Aim.InstallRaycast()
		if hookInstalled then return true end
		if type(hookfunction) ~= "function" or type(workspace.Raycast) ~= "function" then
			Aim.HookStatus = "unavailable"
			return false
		end
		originalRaycast = workspace.Raycast
		wrappedRaycast = raycastReplacement
		local ok, previous = pcall(hookfunction, workspace.Raycast, wrappedRaycast)
		if not ok then
			Aim.HookStatus = "failed"
			originalRaycast = nil
			return false
		end
		if type(previous) == "function" then originalRaycast = previous end
		hookInstalled = true
		Aim.HookStatus = "installed"
		return true
	end

	function Aim.RestoreRaycast()
		if not hookInstalled then return end
		if type(hookfunction) == "function" and originalRaycast then
			pcall(hookfunction, workspace.Raycast, originalRaycast)
		end
		hookInstalled = false
		Aim.HookStatus = "restored"
		Aim.SilentTarget = nil
		Aim.SilentPosition = nil
	end
	Aim.IsRaycastInstalled = function() return hookInstalled end

	local inputDown = false
	local virtualInput
	local function inputService()
		if virtualInput == nil then
			local ok, service = pcall(game.GetService, game, "VirtualInputManager")
			virtualInput = ok and service or false
		end
		return virtualInput
	end
	local function release()
		if not inputDown then return end
		inputDown = false
		if type(mouse1release) == "function" then
			pcall(mouse1release)
		else
			local service = inputService()
			if service and Camera then
				pcall(service.SendMouseButtonEvent, service, Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5, 0, false, game, 0)
			end
		end
	end
	local function click()
		if type(mouse1press) == "function" and type(mouse1release) == "function" then
			local ok = pcall(mouse1press)
			if not ok then return false end
			inputDown = true
			task.delay(0.025, release)
			return true
		end
		local service = inputService()
		if not service or not Camera then return false end
		local ok = pcall(service.SendMouseButtonEvent, service, Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5, 0, true, game, 0)
		if not ok then return false end
		inputDown = true
		task.delay(0.025, release)
		return true
	end

	local function fillOptions(options, silent)
		options.FOV = silent and S.SilentFOV or S.AimFOV
		options.Range = silent and S.SilentRange or S.AimRange
		options.PartMode = silent and S.SilentPart or S.AimPart
		options.Priority = silent and S.SilentPriority or S.AimPriority
		options.TeamCheck = silent and S.SilentTeamCheck or S.AimTeamCheck
		options.WallCheck = silent and S.SilentWallCheck or S.AimWallCheck
	end

	function Aim.Update(dt)
		Aim.CurrentTarget = nil
		Aim.CurrentPosition = nil
		Aim.SilentTarget = nil
		Aim.SilentPosition = nil
		if targetLine then targetLine.Visible = false end
		local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
		if fovCircle then
			fovCircle.Position = center
			fovCircle.Radius = S.Aimbot and S.AimFOV or S.SilentFOV
			fovCircle.Color = Colors.FOV
			fovCircle.Visible = S.FOVCircle and (S.Aimbot or S.SilentAim) and not Runtime.MenuOpen
		end
		if Runtime.MenuOpen then
			release()
			return
		end
		if S.Aimbot and Shared.KeyDown(S.AimKey) then
			fillOptions(aimOptions, false)
			local best = selectTarget(aimOptions, aimBest)
			if best then
				Aim.CurrentTarget = best.Target
				Aim.CurrentPosition = predictedPosition(best, S.AimPrediction)
				local smoothing = math.max(1, S.AimSmoothing)
				local alpha = math.clamp(1 - math.exp(-dt * 60 / smoothing), 0, 1)
				Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, Aim.CurrentPosition), alpha)
			end
		end
		if S.SilentAim and hookInstalled then
			fillOptions(silentOptions, true)
			local best = selectTarget(silentOptions, silentBest)
			if best then
				Aim.SilentTarget = best.Target
				Aim.SilentPosition = predictedPosition(best, S.SilentPrediction)
			end
		end
		local linePosition = Aim.CurrentPosition or Aim.SilentPosition
		if targetLine and S.TargetLine and linePosition then
			local x, y, z = Shared.Project(linePosition)
			if x and z > 0 then
				targetLine.Visible = true
				targetLine.From = center
				targetLine.To = Vector2.new(x, y)
				targetLine.Color = Colors.TargetLine
			end
		end
		if S.AutoFire and linePosition and not inputDown then
			local now = os.clock()
			if now >= Aim.NextAutoFire and click() then
				Aim.NextAutoFire = now + math.max(20, S.AutoFireDelay) / 1000
			end
		end
	end

	function Aim.Restore()
		release()
		Aim.RestoreRaycast()
		Aim.CurrentTarget = nil
		Aim.CurrentPosition = nil
		Aim.SilentTarget = nil
		Aim.SilentPosition = nil
		if fovCircle then fovCircle.Visible = false end
		if targetLine then targetLine.Visible = false end
	end
	onCleanup(Aim.Restore)
end

do
	local Shared = Runtime.Shared
	local Visuals = {Rigs = {}, Accumulator = 0}
	Runtime.Visuals = Visuals
	local edges = {{1, 2}, {1, 3}, {1, 5}, {2, 4}, {2, 6}, {3, 4}, {3, 7}, {4, 8}, {5, 6}, {5, 7}, {6, 8}, {7, 8}}

	local function hide(entry)
		for _, object in pairs(entry.Objects) do object.Visible = false end
		if entry.Highlight then entry.Highlight.Enabled = false end
	end

	local function remove(player)
		local entry = Visuals.Rigs[player]
		if not entry then return end
		for _, object in pairs(entry.Objects) do releaseDrawing(object) end
		if entry.Highlight then pcall(function() entry.Highlight:Destroy() end) end
		Visuals.Rigs[player] = nil
	end

	function Visuals.Clear()
		for player in pairs(Visuals.Rigs) do remove(player) end
		Runtime.Diagnostics.PlayerESPCount = 0
	end

	local function ensure(entry, kind, key)
		local object = entry.Objects[key]
		if object then return object end
		if entry.Missing[key] then return nil end
		object = newDrawing(kind)
		if not object then
			entry.Missing[key] = true
			return nil
		end
		entry.Objects[key] = object
		object.Visible = false
		object.Transparency = 1
		if kind == "Text" then
			object.Font = 2
			object.Center = true
			object.Outline = true
			object.OutlineColor = Color3.new(0, 0, 0)
		elseif kind == "Square" then
			object.Filled = false
			object.Thickness = 1
		elseif kind == "Line" then
			object.Thickness = 1
		end
		return object
	end

	local function text(entry, key, value, position, color)
		local object = ensure(entry, "Text", key)
		if not object then return end
		object.Visible = true
		object.Text = value
		object.Position = position
		object.Size = S.PlayerTextSize
		object.Color = color
		object.Transparency = 1
	end

	local function line(entry, key, from, to, color, thickness)
		local object = ensure(entry, "Line", key)
		if not object then return end
		object.Visible = true
		object.From = from
		object.To = to
		object.Color = color
		object.Thickness = thickness or 1
		object.Transparency = 1
	end

	local function bounds(model, root)
		local ok, cf, size = pcall(model.GetBoundingBox, model)
		if not ok or not cf or not size then
			cf = root.CFrame
			size = Vector3.new(4, 6, 2)
		end
		local points = {}
		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		for x = -1, 1, 2 do
			for y = -1, 1, 2 do
				for z = -1, 1, 2 do
					local world = cf:PointToWorldSpace(Vector3.new(size.X * x * 0.5, size.Y * y * 0.5, size.Z * z * 0.5))
					local sx, sy, sz = Shared.Project(world)
					if not sx or sz <= 0 then return nil end
					points[#points + 1] = Vector2.new(sx, sy)
					minX = math.min(minX, sx)
					minY = math.min(minY, sy)
					maxX = math.max(maxX, sx)
					maxY = math.max(maxY, sy)
				end
			end
		end
		local width, height = Camera.ViewportSize.X, Camera.ViewportSize.Y
		if maxX < 0 or minX > width or maxY < 0 or minY > height then return nil end
		local left = math.clamp(minX, 0, width)
		local right = math.clamp(maxX, 0, width)
		local top = math.clamp(minY, 0, height)
		local bottom = math.clamp(maxY, 0, height)
		if right - left < 2 or bottom - top < 2 then return nil end
		return points, left, right, top, bottom
	end

	local function drawBox(entry, style, points, left, right, top, bottom, color)
		if style == "3D" then
			for index, edge in ipairs(edges) do
				line(entry, "D" .. index, points[edge[1]], points[edge[2]], color)
			end
			return
		end
		if style == "Corners" then
			local length = math.max(3, math.min(right - left, bottom - top) * 0.25)
			line(entry, "C1", Vector2.new(left, top), Vector2.new(left + length, top), color)
			line(entry, "C2", Vector2.new(left, top), Vector2.new(left, top + length), color)
			line(entry, "C3", Vector2.new(right, top), Vector2.new(right - length, top), color)
			line(entry, "C4", Vector2.new(right, top), Vector2.new(right, top + length), color)
			line(entry, "C5", Vector2.new(left, bottom), Vector2.new(left + length, bottom), color)
			line(entry, "C6", Vector2.new(left, bottom), Vector2.new(left, bottom - length), color)
			line(entry, "C7", Vector2.new(right, bottom), Vector2.new(right - length, bottom), color)
			line(entry, "C8", Vector2.new(right, bottom), Vector2.new(right, bottom - length), color)
			return
		end
		local object = ensure(entry, "Square", "Box")
		if object then
			object.Visible = true
			object.Position = Vector2.new(left, top)
			object.Size = Vector2.new(right - left, bottom - top)
			object.Color = color
			object.Transparency = 1
		end
	end

	local function updateChams(entry, character, color)
		if not S.PlayerChams then return end
		if not entry.Highlight then
			local highlight = Instance.new("Highlight")
			highlight.Name = "BurmaldaChams"
			highlight.Parent = sg
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			entry.Highlight = highlight
		end
		entry.Highlight.Adornee = character
		entry.Highlight.FillColor = color
		entry.Highlight.OutlineColor = color
		entry.Highlight.FillTransparency = 0.75
		entry.Highlight.OutlineTransparency = 0
		entry.Highlight.Enabled = true
	end

	local function renderPlayer(player, seen, color)
		if player == LocalPlayer then return end
		seen[player] = true
		local entry = Visuals.Rigs[player]
		if not entry then
			entry = {Objects = {}, Missing = {}, Highlight = nil}
			Visuals.Rigs[player] = entry
		end
		hide(entry)
		local character = player.Character
		local humanoid = Shared.Humanoid(character)
		local root = Shared.Root(character)
		if not character or not humanoid or not root or humanoid.Health <= 0 then return end
		if S.PlayerTeamCheck and Shared.IsTeammate(player) then return end
		local distance = (root.Position - Camera.CFrame.Position).Magnitude
		if distance > S.PlayerRange then return end
		updateChams(entry, character, color)
		if not S.PlayerESP and not S.PlayerTracers then return end
		local points, left, right, top, bottom = bounds(character, root)
		if not points then return end
		local centerX = (left + right) * 0.5
		if S.PlayerESP then
			Runtime.Diagnostics.PlayerESPCount += 1
			if S.PlayerBox then drawBox(entry, S.BoxStyle, points, left, right, top, bottom, color) end
			if S.PlayerNames then
				text(entry, "Name", player.DisplayName or player.Name, Vector2.new(centerX, top - 17), Colors.PlayerText)
			end
			local below = bottom + 2
			if S.PlayerDistance then
				text(entry, "Distance", tostring(math.floor(distance + 0.5)) .. "m", Vector2.new(centerX, below), Colors.PlayerText)
				below += S.PlayerTextSize + 2
			end
			if S.PlayerHeldItem then
				local tool = Shared.ToolName(character)
				if tool ~= "" then text(entry, "Tool", tool, Vector2.new(centerX, below), Colors.PlayerText) end
			end
			if S.PlayerHealth then
				local fraction = math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0, 1)
				local x = left - 5
				line(entry, "HealthBack", Vector2.new(x, top), Vector2.new(x, bottom), Color3.new(0, 0, 0), 3)
				line(entry, "HealthFill", Vector2.new(x, bottom), Vector2.new(x, bottom - (bottom - top) * fraction),
					Color3.fromRGB(math.floor(255 * (1 - fraction)), math.floor(255 * fraction), 60), 2)
			end
		end
		if S.PlayerTracers then
			local from
			if S.TracerStart == "Center" then
				from = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
			elseif S.TracerStart == "Mouse" then
				from = UIS:GetMouseLocation()
			else
				from = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
			end
			line(entry, "Tracer", from, Vector2.new(centerX, bottom), color)
		end
	end

	function Visuals.Update(dt)
		Visuals.Accumulator += dt
		local interval = S.LowPC and 0.05 or 1 / 30
		if Visuals.Accumulator < interval then return end
		Visuals.Accumulator = 0
		if not (S.PlayerESP or S.PlayerChams or S.PlayerTracers) then
			if next(Visuals.Rigs) then Visuals.Clear() end
			Runtime.Diagnostics.PlayerESPCount = 0
			return
		end
		Runtime.Diagnostics.PlayerESPCount = 0
		local seen = {}
		local color = S.PlayerRainbow and Color3.fromHSV((os.clock() * 0.15) % 1, 0.8, 1) or Colors.Player
		for _, player in ipairs(Players:GetPlayers()) do renderPlayer(player, seen, color) end
		for player in pairs(Visuals.Rigs) do
			if not seen[player] then remove(player) end
		end
	end

	local removingConnection = Players.PlayerRemoving:Connect(function(player) remove(player) end)
	onCleanup(function()
		if removingConnection then pcall(function() removingConnection:Disconnect() end) end
		Visuals.Clear()
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

	Runtime.FeatureHandlers.HUD = function(value) statsHud.SetVisible(value) end
	Runtime.FeatureHandlers.Noclip = function(value) if not value then Runtime.Movement.RestoreNoclip() end end
	Runtime.FeatureHandlers.Fly = function(value) if not value then Runtime.Movement.RestoreFly() end end
	Runtime.FeatureHandlers.PlayerESP = function(value)
		if not value and not (S.PlayerChams or S.PlayerTracers) then Runtime.Visuals.Clear() end
	end
	Runtime.FeatureHandlers.PlayerChams = function(value)
		if not value then
			for _, entry in pairs(Runtime.Visuals.Rigs) do
				if entry.Highlight then entry.Highlight.Enabled = false end
			end
		end
	end
	Runtime.FeatureHandlers.SilentAim = function(value)
		if value and not Runtime.Aim.InstallRaycast() then
			S.SilentAim = false
			if _fFS["Silent Aim"] then _fFS["Silent Aim"](false) end
		end
	end
	Runtime.FeatureHandlers.UIAnimations = function(value) UIAnimations = value end
	for _, key in ipairs({"FullBright", "RemoveFog", "HideGrass", "LowPC"}) do
		Runtime.FeatureHandlers[key] = function() Runtime.Environment.Apply() end
	end

	do
		local lc, rc = getTab("COMBAT")
		local editor = feature(section(lc, "Aimbot"), "Aimbot", "Aimbot")
		slider(editor, "FOV", 10, 900, "AimFOV")
		slider(editor, "Range", 20, 2000, "AimRange")
		slider(editor, "Smoothing", 1, 50, "AimSmoothing")
		slider(editor, "Bullet Speed", 50, 5000, "BulletSpeed")
		dropdown(editor, "Target Part", {"Head", "Body", "Root", "Closest"}, "AimPart")
		dropdown(editor, "Priority", {"Crosshair", "Distance", "Low HP"}, "AimPriority")
		dropdown(editor, "Hold Key", {"RMB", "LMB", "LeftAlt", "LeftControl", "Always"}, "AimKey")
		onOff(editor, "Team Check", "AimTeamCheck")
		onOff(editor, "Wall Check", "AimWallCheck")
		onOff(editor, "Prediction", "AimPrediction")
		onOff(editor, "FOV Circle", "FOVCircle")
		onOff(editor, "Target Line", "TargetLine")
		color(editor, "FOV Color", "FOV")
		color(editor, "Line Color", "TargetLine")
		toggleBind(editor, "Aimbot", "Aimbot")

		editor = feature(section(rc, "Silent Aim"), "Silent Aim", "SilentAim")
		slider(editor, "FOV", 10, 900, "SilentFOV")
		slider(editor, "Range", 20, 2000, "SilentRange")
		dropdown(editor, "Target Part", {"Head", "Body", "Root", "Closest"}, "SilentPart")
		dropdown(editor, "Priority", {"Crosshair", "Distance", "Low HP"}, "SilentPriority")
		onOff(editor, "Team Check", "SilentTeamCheck")
		onOff(editor, "Wall Check", "SilentWallCheck")
		onOff(editor, "Prediction", "SilentPrediction")
		onOff(editor, "Auto Fire", "AutoFire")
		slider(editor, "Click Delay", 20, 500, "AutoFireDelay")
		toggleBind(editor, "Silent Aim", "SilentAim")
	end

	do
		local lc, rc = getTab("VISUALS")
		local editor = feature(section(lc, "Players"), "Player ESP", "PlayerESP")
		slider(editor, "Range", 50, 2000, "PlayerRange")
		slider(editor, "Text Size", 9, 18, "PlayerTextSize")
		dropdown(editor, "Box Style", {"2D", "Corners", "3D"}, "BoxStyle")
		onOff(editor, "Box", "PlayerBox")
		onOff(editor, "Names", "PlayerNames")
		onOff(editor, "Distance", "PlayerDistance")
		onOff(editor, "Health Bar", "PlayerHealth")
		onOff(editor, "Held Item", "PlayerHeldItem")
		onOff(editor, "Team Check", "PlayerTeamCheck")
		onOff(editor, "Rainbow", "PlayerRainbow")
		color(editor, "Player Color", "Player")
		color(editor, "Text Color", "PlayerText")
		toggleBind(editor, "Player ESP", "PlayerESP")

		editor = feature(section(rc, "Chams"), "Chams", "PlayerChams")
		toggleBind(editor, "Chams", "PlayerChams")
		editor = feature(section(rc, "Tracers"), "Tracers", "PlayerTracers")
		dropdown(editor, "Start", {"Bottom", "Center", "Mouse"}, "TracerStart")
		toggleBind(editor, "Tracers", "PlayerTracers")
	end

	do
		local lc, rc = getTab("MOVEMENT")
		local editor = feature(section(lc, "Speed"), "Speed", "Speed")
		slider(editor, "Value", 16, 100, "SpeedValue")
		toggleBind(editor, "Speed", "Speed")
		editor = feature(section(lc, "Fly"), "Fly", "Fly")
		slider(editor, "Speed", 16, 250, "FlySpeed")
		toggleBind(editor, "Fly", "Fly")
		editor = feature(section(rc, "Collision"), "Noclip", "Noclip")
		toggleBind(editor, "Noclip", "Noclip")
		editor = feature(section(rc, "Camera"), "Freecam", "Freecam")
		slider(editor, "Speed", 10, 200, "FreecamSpeed")
		toggleBind(editor, "Freecam", "Freecam")
		editor = feature(section(rc, "Teleport"), "Teleport To Mouse", "TeleportMouse")
		slider(editor, "Raycast Distance", 100, 5000, "TeleportDistance")
		addBind(editor, "Teleport Bind", "None", function()
			if S.TeleportMouse and not Runtime.MenuOpen then pcall(Runtime.Movement.TeleportToMouse) end
		end)
	end

	do
		local lc, rc = getTab("MISC")
		local editor = feature(section(lc, "Lighting"), "FullBright", "FullBright")
		toggleBind(editor, "FullBright", "FullBright")
		editor = feature(section(lc, "Fog"), "Remove Fog", "RemoveFog")
		toggleBind(editor, "Remove Fog", "RemoveFog")
		editor = feature(section(rc, "Terrain"), "Hide Grass", "HideGrass")
		toggleBind(editor, "Hide Grass", "HideGrass")
		editor = feature(section(rc, "Performance"), "Low PC", "LowPC")
		toggleBind(editor, "Low PC", "LowPC")
		editor = feature(section(rc, "HUD"), "Stats HUD", "HUD")
		toggleBind(editor, "Stats HUD", "HUD")
	end

	do
		local lc, rc = getTab("CONFIG")
		local interfaceSection = section(lc, "Interface")
		local editor = feature(interfaceSection, "UI Animations", "UIAnimations")
		local accentSetter = color(editor, "Menu Accent", "Accent")
		addDropdown(editor, "Accent Preset", {"White", "Blue", "Silver", "Graphite"}, 1, function(value)
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

		local Config = {Folder = "Burmalda.hook/DEGRADE", Session = {}}
		Runtime.Config = Config
		_degradeEnv.BurmaldaDEGRADEConfigs = type(_degradeEnv.BurmaldaDEGRADEConfigs) == "table" and _degradeEnv.BurmaldaDEGRADEConfigs or {}
		Config.Session = _degradeEnv.BurmaldaDEGRADEConfigs
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
			return {Version = 1, State = state, Colors = colors, Binds = binds}
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

local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Freecam = {
	Active = false,
	OriginalCamera = nil,
	Offset = CFrame.new(),
	Keys = {},
	MouseDelta = Vector2.new(),
}
Runtime.Freecam = Freecam

local keys = {
	[Enum.KeyCode.W] = Vector3.new(0, 0, -1),
	[Enum.KeyCode.S] = Vector3.new(0, 0, 1),
	[Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
	[Enum.KeyCode.D] = Vector3.new(1, 0, 0),
	[Enum.KeyCode.Q] = Vector3.new(0, -1, 0),
	[Enum.KeyCode.E] = Vector3.new(0, 1, 0),
}

local keyDown, keyUp, mouseMoved

function Freecam.Enable()
	if Freecam.Active then return end
	Freecam.Active = true
	Freecam.OriginalCamera = Camera.CFrame
	Freecam.Offset = CFrame.new()
	table.clear(Freecam.Keys)

	keyDown = UIS.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local direction = keys[input.KeyCode]
		if direction then Freecam.Keys[input.KeyCode] = direction end
	end)

	keyUp = UIS.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		Freecam.Keys[input.KeyCode] = nil
	end)

	mouseMoved = UIS.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		Freecam.MouseDelta = input.Delta
	end)
end

function Freecam.Disable()
	if not Freecam.Active then return end
	Freecam.Active = false
	if keyDown then keyDown:Disconnect() end
	if keyUp then keyUp:Disconnect() end
	if mouseMoved then mouseMoved:Disconnect() end
	keyDown, keyUp, mouseMoved = nil, nil, nil
	table.clear(Freecam.Keys)
	Freecam.MouseDelta = Vector2.new()
	if Freecam.OriginalCamera then
		Camera.CFrame = Freecam.OriginalCamera
		Freecam.OriginalCamera = nil
	end
	Freecam.Offset = CFrame.new()
end

function Freecam.Update(dt)
	if not Freecam.Active or not Camera then return end
	local speed = (S.FreecamSpeed or 50) * (dt or 0)
	local direction = Vector3.zero
	for _, delta in pairs(Freecam.Keys) do
		direction = direction + delta
	end
	if direction.Magnitude > 0 then
		direction = direction.Unit * speed
	end
	local yaw, pitch = Freecam.MouseDelta.X * 0.003, Freecam.MouseDelta.Y * 0.003
	Freecam.MouseDelta = Vector2.new()
	local rotation = CFrame.Angles(-pitch, -yaw, 0)
	local forward = Freecam.Offset.LookVector * direction.Z
	local right = Freecam.Offset.RightVector * direction.X
	local up = Freecam.Offset.UpVector * direction.Y
	Freecam.Offset = Freecam.Offset * CFrame.new(forward + right + up) * rotation
	Camera.CFrame = Freecam.OriginalCamera * Freecam.Offset
end

Runtime.FeatureHandlers.Freecam = function(value)
	if value then
		Freecam.Enable()
	else
		Freecam.Disable()
	end
end

function Runtime.Unload()
	if Runtime.Unloaded then return end
	Runtime.Unloaded = true
	for key, value in pairs(S) do
		if type(value) == "boolean" then S[key] = false end
	end
	if Runtime.Aim and Runtime.Aim.Restore then pcall(Runtime.Aim.Restore) end
	if Runtime.Movement and Runtime.Movement.Restore then pcall(Runtime.Movement.Restore) end
	if Runtime.Environment and Runtime.Environment.Restore then pcall(Runtime.Environment.Restore) end
	if Runtime.Visuals and Runtime.Visuals.Clear then pcall(Runtime.Visuals.Clear) end
	for index = #Runtime.Cleanup, 1, -1 do pcall(Runtime.Cleanup[index]) end
	for drawing in pairs(Runtime.Drawings) do pcall(function() drawing:Remove() end) end
	table.clear(Runtime.Drawings)
	for gui in pairs(Runtime.Guis) do pcall(function() gui:Destroy() end) end
	table.clear(Runtime.Guis)
	if _degradeEnv.BurmaldaDEGRADE == Runtime then _degradeEnv.BurmaldaDEGRADE = nil end
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
	guardedStep("Movement", Runtime.Movement and Runtime.Movement.Update, dt)
	guardedStep("Environment", Runtime.Environment and Runtime.Environment.Update, dt)
	guardedStep("Aim", Runtime.Aim and Runtime.Aim.Update, dt)
	guardedStep("Freecam", Runtime.Freecam and Runtime.Freecam.Update, dt)
	guardedStep("Visuals", Runtime.Visuals and Runtime.Visuals.Update, dt)
end)
onCleanup(function()
	if renderConnection then pcall(function() renderConnection:Disconnect() end); renderConnection = nil end
end)

Runtime.Ready = true
