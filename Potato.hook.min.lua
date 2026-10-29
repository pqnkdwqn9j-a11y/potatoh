-- Burmalda.hook | rost alpha | cleaned NullWave-derived build
-- Target: official rost alpha, PlaceId 13769775130; no PlaceId execution gate.
-- Removed: anti-dump, heartbeat, anti-spy, remote loaders, Force Hit and hitbox expansion.
-- Silent Aim below is an unverified Workspace Raycast compatibility path, not a live projectile proof.

local _burmaldaEnv = getgenv and getgenv() or _G
if _burmaldaEnv.PHOOKGATE ~= nil then
	if tostring(_burmaldaEnv.PHOOKGATE) ~= "1347571535" then
		warn("[Burmalda.hook] Invalid loader gate.")
		return
	end
	_burmaldaEnv.PHOOKGATE = nil
end
if _burmaldaEnv.BurmaldaRost and _burmaldaEnv.BurmaldaRost.Unload then
	pcall(_burmaldaEnv.BurmaldaRost.Unload)
end

local Runtime = {
	Unloaded = false,
	Cleanup = {},
	Drawings = {},
	Guis = {},
	SilentPath = "projectile-packet-with-raycast-fallback-unverified",
}
_burmaldaEnv.BurmaldaRost = Runtime
local ProjectileCore, ProjectileSilent

local function onCleanup(fn)
	table.insert(Runtime.Cleanup, fn)
end

local function trackDrawing(obj)
	table.insert(Runtime.Drawings, obj)
	return obj
end

local _drawingNew = Drawing.new
local function newDrawing(kind)
	return trackDrawing(_drawingNew(kind))
end

local _instanceNew = Instance.new
local function newScreenGui(parent)
	local gui = _instanceNew("ScreenGui")
	if parent then gui.Parent = parent end
	Runtime.Guis[gui] = true
	return gui
end

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local pGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local originalMouseIconEnabled = UIS.MouseIconEnabled
onCleanup(function() UIS.MouseIconEnabled = originalMouseIconEnabled end)

if pGui:FindFirstChild("BurmaldaHook") then pGui.BurmaldaHook:Destroy() end
if pGui:FindFirstChild("BurmaldaHookHUD") then pGui.BurmaldaHookHUD:Destroy() end

local sg = newScreenGui()
sg.Name = "BurmaldaHook"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.DisplayOrder = 999998
sg.Parent = pGui

local S = {
	ESPEnabled     = false,
	ESPRadius      = 500,
	ESPDist        = false,
	Tracers        = false,
	TracerOrigin   = 2,
	Names          = false,

	FOVCircle      = false,
	FOV            = 120,
	FOVFill        = false,
	FOVFillTransparency = 0.85,
	BoxFill        = false,
	BoxFillTransparency = 0.7,
	HPBar          = false,
	HPBarSide      = 1,
	SilentAim      = false,
	MBFovMode      = "mobile",
	MBHitChance    = 100,
	MBVisibleOnly  = false,
	MBMaxDist      = 500,
	MBTargetPart   = 1,
	MBPriority     = "distance",
	SpeedRostAlpha = false,
	HUDEnabled     = true,
	SpeedRostValue = 60,
	SpeedRostSmoothing = 0.5,
	Spider         = false,
	SpiderSpeed    = 20,
	NoRecoil       = false,
	NoRecoilMethod = 1,
	HighJump       = false,
	HighJumpHeight = 100,
}

local AC      = Color3.fromRGB(255, 255, 255)
local AC_ESP  = Color3.fromRGB(255, 255, 255)
local AC_FOV  = Color3.fromRGB(255, 255, 255)
local AC_FOV_FILL = Color3.fromRGB(255, 255, 255)
local AC_TR   = Color3.fromRGB(255, 255, 255)

local AC_NAME = Color3.fromRGB(255, 255, 255)
local AC_DIST = Color3.fromRGB(255, 255, 255)
local AC_FILL = Color3.fromRGB(255, 255, 255)
local AC_HP   = Color3.fromRGB(255, 255, 255)
local BK      = Color3.fromRGB(0, 0, 0)

local _visParams = RaycastParams.new()
_visParams.FilterType = Enum.RaycastFilterType.Exclude
local _visCache = {}
local _visCacheTime = {}
local _VIS_TTL = 0.08
local _visFilterList = {}
local function isVisible(part, char)
	local now = tick()
	if _visCacheTime[part] and (now - _visCacheTime[part]) < _VIS_TTL then
		return _visCache[part]
	end
	local myChar = LocalPlayer.Character
	if _visFilterList[1] ~= char or _visFilterList[2] ~= myChar then
		_visFilterList[1] = char
		_visFilterList[2] = myChar
		_visParams.FilterDescendantsInstances = _visFilterList
	end
	local origin = Camera.CFrame.Position
	local result = workspace:Raycast(origin, part.Position - origin, _visParams)
	local vis = result == nil
	_visCache[part] = vis
	_visCacheTime[part] = now
	return vis
end

local function isAimKeyHeld()
	return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		or UIS:IsKeyDown(Enum.KeyCode.LeftAlt)
end

local PickupNotifEnabled = false

local function createLogo(parent, size)
	local logo = Instance.new("Frame")
	logo.Size = UDim2.new(0, size, 0, size)
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.new(0.5, 0, 0.5, 0)
	logo.BackgroundTransparency = 1
	logo.Rotation = 12
	logo.Parent = parent
	local function p(x, y, sx, sy, rot)
		local f = Instance.new("Frame", logo)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.BackgroundColor3 = Color3.new(1,1,1)
		f.BorderSizePixel = 0
		f.Size = UDim2.new(0, (sx/32)*size, 0, (sy/32)*size)
		f.Position = UDim2.new(0, (x/32)*size, 0, (y/32)*size)
		f.Rotation = rot or 0
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 1)
	end
	p(5, 20, 5, 22, 0)
	p(27, 12, 5, 22, 0)
	p(16, 16, 5, 34, -48)
	return logo
end

local crosshairSettings = {
	crosshairEnabled   = false,
	crosshairType      = "Default",
	crosshairSize      = 8,
	crosshairThickness = 2,
	crosshairGap       = 4,
	crosshairLength    = 10,
	crosshairColor     = Color3.fromRGB(255, 255, 255),
	crosshairCenter    = true,
	crosshairSpin      = false,
	crosshairSpinSpeed = 2,
	crosshairRainbow   = false,
}

local Crosshair = {
	ScreenGui    = nil,
	MainFrame    = nil,
	Segments     = {},
	Enabled      = false,
	CurrentType  = nil,
	Rotation     = 0,
	RainbowHue   = 0,
}

local UserInputService = UIS

local function chGetParent()
	local p
	pcall(function()
		if gethui then p = gethui()
		else p = game:GetService("CoreGui") end
	end)
	return p or LocalPlayer:WaitForChild("PlayerGui")
end

local function chCreateSegment(parent, size, pos, rotation)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = crosshairSettings.crosshairColor
	f.BorderSizePixel  = 0
	f.Active           = false
	f.Selectable       = false
	f.AnchorPoint      = Vector2.new(0.5, 0.5)
	f.Size             = size
	f.Position         = pos
	f.Rotation         = rotation or 0
	f.Parent           = parent
	return f
end

local function chClear()
	if Crosshair.MainFrame then
		Crosshair.MainFrame:Destroy()
		Crosshair.MainFrame = nil
	end
	Crosshair.Segments = {}
end

local function chInit()
	if Crosshair.ScreenGui then return end
	local sg2 = newScreenGui()
	sg2.Name           = "BurmaldaHook_Crosshair"
	sg2.DisplayOrder   = 99998
	sg2.IgnoreGuiInset = true
	sg2.ResetOnSpawn   = false
	sg2.Parent         = chGetParent()
	Crosshair.ScreenGui = sg2
end

local function chBuild(t, size, thick)
	chClear()
	Crosshair.CurrentType = t
	Crosshair.Rotation    = 0
	Crosshair.MainFrame = Instance.new("Frame")
	Crosshair.MainFrame.BackgroundTransparency = 1
	Crosshair.MainFrame.Size        = UDim2.new(0, 0, 0, 0)
	Crosshair.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	Crosshair.MainFrame.Parent      = Crosshair.ScreenGui
	if t == "Default" then
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, size * 2), UDim2.new(0, 0, 0, 0)))
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, size * 2, 0, thick), UDim2.new(0, 0, 0, 0)))
	elseif t == "X" then
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, size * 2.5), UDim2.new(0, 0, 0, 0), 45))
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, size * 2.5), UDim2.new(0, 0, 0, 0), -45))
	elseif t == "Dot" then
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick * 2, 0, thick * 2), UDim2.new(0, 0, 0, 0)))
		local r2 = Instance.new("UICorner")
		r2.CornerRadius = UDim.new(0.5, 0)
		r2.Parent = Crosshair.Segments[1]
	elseif t == "Custom" then
		local gap = crosshairSettings.crosshairGap
		local len = crosshairSettings.crosshairLength

		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, len), UDim2.new(0, 0, 0, -(gap + len / 2))))

		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, len), UDim2.new(0, 0, 0, gap + len / 2)))

		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, len, 0, thick), UDim2.new(0, -(gap + len / 2), 0, 0)))

		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, len, 0, thick), UDim2.new(0, gap + len / 2, 0, 0)))
	end
end

local crosshairConn = nil
local function startCrosshair()
	chInit()
	if crosshairConn then crosshairConn:Disconnect(); crosshairConn = nil end
	crosshairConn = RunService.RenderStepped:Connect(function(dt)
		if Runtime.Unloaded then return end
		if not crosshairSettings.crosshairEnabled then
			if Crosshair.Enabled then
				chClear()
				Crosshair.Enabled = false
			end
			UIS.MouseIconEnabled = true
			return
		end
		Crosshair.Enabled = true
		local t2   = crosshairSettings.crosshairType
		local size = crosshairSettings.crosshairSize
		local thick= crosshairSettings.crosshairThickness
		if not Crosshair.MainFrame or Crosshair.CurrentType ~= t2 then
			chBuild(t2, size, thick)
		end
		local pos
		if crosshairSettings.crosshairCenter then
			-- mobile: crosshair fixed at screen center, keep system cursor visible
			UIS.MouseIconEnabled = true
			local ss2 = Camera.ViewportSize
			pos = Vector2.new(ss2.X / 2, ss2.Y / 2)
		else
			-- pc: pixel-perfect на точке взаимодействия курсора
			-- IgnoreGuiInset=true: GUI coords от (0,0) экрана
			-- GetMouseLocation() тоже от (0,0) => inset НЕ вычитаем
			UIS.MouseIconEnabled = false
			pos = UIS:GetMouseLocation()
		end
		if Crosshair.MainFrame.Position ~= UDim2.new(0, pos.X, 0, pos.Y) then
			Crosshair.MainFrame.Position = UDim2.new(0, pos.X, 0, pos.Y)
		end
		if crosshairSettings.crosshairSpin then
			Crosshair.Rotation = (Crosshair.Rotation + crosshairSettings.crosshairSpinSpeed * dt * 60) % 360
			Crosshair.MainFrame.Rotation = Crosshair.Rotation
		else
			Crosshair.MainFrame.Rotation = 0
		end
		local col
		if crosshairSettings.crosshairRainbow then
			Crosshair.RainbowHue = (Crosshair.RainbowHue + dt * 0.3) % 1
			col = Color3.fromHSV(Crosshair.RainbowHue, 1, 1)
		else
			col = crosshairSettings.crosshairColor
		end
		for idx, seg in ipairs(Crosshair.Segments) do
			seg.BackgroundColor3 = col
			if t2 == "Default" then
				if seg.Size.X.Offset > seg.Size.Y.Offset then
					seg.Size = UDim2.new(0, size * 2, 0, thick)
				else
					seg.Size = UDim2.new(0, thick, 0, size * 2)
				end
			elseif t2 == "X" then
				seg.Size = UDim2.new(0, thick, 0, size * 2.5)
			elseif t2 == "Dot" then
				seg.Size = UDim2.new(0, thick * 2, 0, thick * 2)
			elseif t2 == "Custom" then
				local gap = crosshairSettings.crosshairGap
				local len = crosshairSettings.crosshairLength
				if idx == 1 then
					seg.Size = UDim2.new(0, thick, 0, len)
					seg.Position = UDim2.new(0, 0, 0, -(gap + len / 2))
				elseif idx == 2 then
					seg.Size = UDim2.new(0, thick, 0, len)
					seg.Position = UDim2.new(0, 0, 0, gap + len / 2)
				elseif idx == 3 then
					seg.Size = UDim2.new(0, len, 0, thick)
					seg.Position = UDim2.new(0, -(gap + len / 2), 0, 0)
				elseif idx == 4 then
					seg.Size = UDim2.new(0, len, 0, thick)
					seg.Position = UDim2.new(0, gap + len / 2, 0, 0)
				end
			end
		end
	end)
end
startCrosshair()
onCleanup(function()
	crosshairSettings.crosshairEnabled = false
	if crosshairConn then crosshairConn:Disconnect(); crosshairConn = nil end
	chClear()
	Crosshair.Enabled = false
end)

local advGui = newScreenGui()
advGui.Name = "BurmaldaHookStats"
advGui.IgnoreGuiInset = true
advGui.ResetOnSpawn = false
advGui.DisplayOrder = 999999
advGui.Parent = pGui

local _isLargeScreen = Camera.ViewportSize.X >= 1024
local _hudScaleVal = _isLargeScreen and 1.5 or 1

local hudContainer = Instance.new("Frame", advGui)
hudContainer.Name = "HUDRoot"
hudContainer.Size = UDim2.new(1, 0, 1, 0)
hudContainer.BackgroundTransparency = 1
local function updateHUD() hudContainer.Visible = S.HUDEnabled end

local function hudMakeDrag(gui)
	local drag, di, ds, sp
	gui.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true; ds = i.Position; sp = gui.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
		end
	end)
	gui.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
	end)
	UIS.InputChanged:Connect(function(i)
		if i == di and drag then
			local d = i.Position - ds
			gui.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
end

local function hudBar(name, pos, anchor, pad)
	local f = Instance.new("Frame", hudContainer)
	f.Name = name; f.Size = UDim2.new(0,0,0,22)
	f.Position = pos; f.AnchorPoint = anchor
	f.BackgroundColor3 = Color3.fromRGB(8,8,8)
	f.BackgroundTransparency = 0.08; f.BorderSizePixel = 0
	f.AutomaticSize = Enum.AutomaticSize.X
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,6)
	Instance.new("UIStroke",f).Transparency = 0.92
	local p = Instance.new("UIPadding",f)
	p.PaddingLeft = UDim.new(0,pad or 8); p.PaddingRight = UDim.new(0,pad or 8)
	local l = Instance.new("UIListLayout",f)
	l.FillDirection = Enum.FillDirection.Horizontal
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	l.Padding = UDim.new(0,6)
	return f
end

local function hudSec(parent, iconId, txt, icoSz, gap)
	local sec = Instance.new("Frame",parent)
	sec.BackgroundTransparency = 1; sec.Size = UDim2.new(0,0,1,0)
	sec.AutomaticSize = Enum.AutomaticSize.X
	local l = Instance.new("UIListLayout",sec)
	l.FillDirection = Enum.FillDirection.Horizontal
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	l.Padding = UDim.new(0,gap or 4)
	local img = Instance.new("ImageLabel",sec)
	img.Size = UDim2.new(0,icoSz or 14,0,icoSz or 14)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://"..iconId
	local t = Instance.new("TextLabel",sec)
	t.Size = UDim2.new(0,0,1,0); t.AutomaticSize = Enum.AutomaticSize.X
	t.BackgroundTransparency = 1
	t.TextColor3 = Color3.fromRGB(255,255,255)
	t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.Text = txt
	return t
end

local function hudSep(parent)
	local s = Instance.new("Frame",parent)
	s.Size = UDim2.new(0,1,0,12)
	s.BackgroundColor3 = Color3.fromRGB(255,255,255)
	s.BackgroundTransparency = 0.85; s.BorderSizePixel = 0
end

-- mainBar вынесен из hudContainer чтобы UIScale не смещал центр
local mainBar = Instance.new("Frame", advGui)
mainBar.Name = "MainBar"
mainBar.Size = UDim2.new(0,0,0,22)
mainBar.Position = UDim2.new(0.5,0,0.015,0)
mainBar.AnchorPoint = Vector2.new(0.5,0)
mainBar.BackgroundColor3 = Color3.fromRGB(8,8,8)
mainBar.BackgroundTransparency = 0.08
mainBar.BorderSizePixel = 0
mainBar.AutomaticSize = Enum.AutomaticSize.X
Instance.new("UICorner",mainBar).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke",mainBar).Transparency = 0.92
local _mainBarScale = Instance.new("UIScale", mainBar)
_mainBarScale.Scale = _hudScaleVal
local _mbPad = Instance.new("UIPadding",mainBar)
_mbPad.PaddingLeft = UDim.new(0,8); _mbPad.PaddingRight = UDim.new(0,8)
local _mbL = Instance.new("UIListLayout",mainBar)
_mbL.FillDirection = Enum.FillDirection.Horizontal
_mbL.HorizontalAlignment = Enum.HorizontalAlignment.Center
_mbL.VerticalAlignment = Enum.VerticalAlignment.Center
_mbL.Padding = UDim.new(0,6)
hudSec(mainBar,"110686514699024","Burmalda.hook",21,2)
hudSep(mainBar)
local hudFpsLbl  = hudSec(mainBar,"12096147158","0 fps",14,4)
hudSep(mainBar)
local hudTimeLbl = hudSec(mainBar,"17824308575","00:00:00",14,4)

-- lowerHolder тоже вынесен из hudContainer чтобы корректно центрироваться на любом разрешении
-- mainBar имеет высоту 22 * scale, плюс 4px отступ
local _mainBarH = 22 * _hudScaleVal
local lowerHolder = Instance.new("Frame", advGui)
lowerHolder.Name = "LowerHolder"
lowerHolder.BackgroundTransparency = 1
lowerHolder.Size = UDim2.new(0, 0, 0, 22 * _hudScaleVal)
lowerHolder.AutomaticSize = Enum.AutomaticSize.X
lowerHolder.Position = UDim2.new(0.5, 0, 0.015, _mainBarH + 4)
lowerHolder.AnchorPoint = Vector2.new(0.5, 0)
local lhL = Instance.new("UIListLayout", lowerHolder)
lhL.FillDirection = Enum.FillDirection.Horizontal
lhL.HorizontalAlignment = Enum.HorizontalAlignment.Center
lhL.VerticalAlignment = Enum.VerticalAlignment.Center
lhL.Padding = UDim.new(0, 8)

local function subBar(parent)
	local f = Instance.new("Frame", parent)
	f.BackgroundColor3 = Color3.fromRGB(8,8,8)
	f.BackgroundTransparency = 0.08; f.BorderSizePixel = 0
	f.Size = UDim2.new(0, 0, 0, 22 * _hudScaleVal); f.AutomaticSize = Enum.AutomaticSize.X
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", f).Transparency = 0.92
	local p = Instance.new("UIPadding", f)
	p.PaddingLeft = UDim.new(0, 8); p.PaddingRight = UDim.new(0, 8)
	local l = Instance.new("UIListLayout", f)
	l.FillDirection = Enum.FillDirection.Horizontal
	l.VerticalAlignment = Enum.VerticalAlignment.Center
	l.Padding = UDim.new(0, 6)
	return f
end
local hb1 = subBar(lowerHolder)
local hudPingLbl  = hudSec(hb1,"84895557744908","0 ms", math.floor(14*_hudScaleVal), 3)
hudPingLbl.TextSize = math.floor(12*_hudScaleVal)
local hb2 = subBar(lowerHolder)
local hudSpdLbl   = hudSec(hb2,"105442920358687","0 studs/s", math.floor(12*_hudScaleVal), 3)
hudSpdLbl.TextSize = math.floor(12*_hudScaleVal)

task.spawn(function()
	while true do
		if Runtime.Unloaded then break end
		hudTimeLbl.Text = os.date("%H:%M:%S")
		hudFpsLbl.Text  = math.floor(workspace:GetRealPhysicsFPS()).." fps"
		local ok,pv = pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
		hudPingLbl.Text = (ok and pv or 0).." ms"
		local ch = LocalPlayer.Character
		if ch and ch:FindFirstChild("HumanoidRootPart") then
			local v = ch.HumanoidRootPart.AssemblyLinearVelocity
			hudSpdLbl.Text = math.floor(Vector3.new(v.X,0,v.Z).Magnitude).." studs/s"
		else
			hudSpdLbl.Text = "0 studs/s"
		end
		task.wait(0.5)
	end
end)

local openBtn = Instance.new("Frame")
openBtn.Name = "MenuBtn"
openBtn.Size = UDim2.new(0,32,0,32)
openBtn.Position = UDim2.new(0,20,0,100)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
openBtn.BackgroundTransparency = 0.15
openBtn.BorderSizePixel = 0
openBtn.Active = true
openBtn.Parent = sg
Instance.new("UICorner",openBtn).CornerRadius = UDim.new(0,8)
local btnIco = Instance.new("ImageLabel",openBtn)
btnIco.Size = UDim2.new(1,-8,1,-8)
btnIco.Position = UDim2.new(0.5,0,0.5,0)
btnIco.AnchorPoint = Vector2.new(0.5,0.5)
btnIco.BackgroundTransparency = 1
btnIco.Image = "rbxassetid://110686514699024"
btnIco.ScaleType = Enum.ScaleType.Fit
hudMakeDrag(openBtn)

-- UI v2: monochrome reference-style menu, themeable accent and motion.
local UIAnimations = true
local Theme = {
	Background = Color3.fromRGB(7, 7, 7),
	Panel = Color3.fromRGB(13, 13, 13),
	Panel2 = Color3.fromRGB(19, 19, 19),
	Off = Color3.fromRGB(38, 38, 38),
	Stroke = Color3.fromRGB(52, 52, 52),
	Text = Color3.fromRGB(242, 242, 242),
	Muted = Color3.fromRGB(135, 135, 135),
	Accent = Color3.fromRGB(255, 255, 255),
}
if typeof(_burmaldaEnv.BurmaldaAccent) == "Color3" then
	Theme.Accent = _burmaldaEnv.BurmaldaAccent
end

local accentObjects, accentUpdaters = {}, {}
local function uiTween(object, info, properties)
	if UIAnimations then
		return TS:Create(object, info, properties)
	end
	for key, value in pairs(properties) do object[key] = value end
	return { Play = function() end }
end
local function registerAccent(object, property)
	table.insert(accentObjects, { Object = object, Property = property })
	object[property] = Theme.Accent
	return object
end
local function registerAccentUpdater(fn)
	table.insert(accentUpdaters, fn)
	return fn
end
local function setMenuAccent(color)
	if typeof(color) ~= "Color3" then return end
	Theme.Accent = color
	_burmaldaEnv.BurmaldaAccent = color
	for _, entry in ipairs(accentObjects) do
		uiTween(entry.Object, TweenInfo.new(0.16), { [entry.Property] = color }):Play()
	end
	for _, update in ipairs(accentUpdaters) do update(color) end
end

local main = Instance.new("Frame")
main.Name = "MenuV2"
main.Size = UDim2.new(0, 620, 0, 380)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Theme.Background
main.BackgroundTransparency = 0.02
main.BorderSizePixel = 0
main.Visible = false
main.ClipsDescendants = true
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 4)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Theme.Stroke
mainStroke.Thickness = 1
local mainScale = Instance.new("UIScale", main)
local baseMenuScale = _isLargeScreen and 1 or 0.82
mainScale.Scale = baseMenuScale * 0.94

local topAccent = Instance.new("Frame", main)
topAccent.Size = UDim2.new(1, 0, 0, 2)
topAccent.BorderSizePixel = 0
registerAccent(topAccent, "BackgroundColor3")

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header)
title.Text = "Burmalda.hook"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Theme.Text
title.Position = UDim2.new(0, 18, 0, 8)
title.Size = UDim2.new(0, 250, 0, 20)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
local subtitle = Instance.new("TextLabel", header)
subtitle.Text = "rost alpha"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextColor3 = Theme.Muted
subtitle.Position = UDim2.new(0, 19, 0, 27)
subtitle.Size = UDim2.new(0, 200, 0, 12)
subtitle.BackgroundTransparency = 1
subtitle.TextXAlignment = Enum.TextXAlignment.Left
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = Theme.Panel
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.Code
closeBtn.TextSize = 12
closeBtn.TextColor3 = Theme.Muted
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)
closeBtn.MouseEnter:Connect(function() uiTween(closeBtn, TweenInfo.new(0.12), { TextColor3 = Theme.Accent }):Play() end)
closeBtn.MouseLeave:Connect(function() uiTween(closeBtn, TweenInfo.new(0.12), { TextColor3 = Theme.Muted }):Play() end)

local menuOpen = false
local menuOpenedViaShift = false
local tabFrames = {}
local tabs = { "COMBAT", "VISUALS", "MOVEMENT", "MISC", "CONFIG" }
local tabAliases = { ESP = "VISUALS", VISUAL = "VISUALS", HUD = "MISC" }
local activeBtn, activeFrame, activeLine = nil, nil, nil
local _fFS, _fDD = {}, {}

local function toggleMenu(viaSHIFT)
	menuOpen = not menuOpen
	if menuOpen then
		menuOpenedViaShift = viaSHIFT == true
		main.Visible = true
		openBtn.Visible = false
		hudContainer.Visible = false
		mainBar.Visible = false
		lowerHolder.Visible = false
		uiTween(mainScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = baseMenuScale }):Play()
		uiTween(main, TweenInfo.new(0.16), { BackgroundTransparency = 0.02 }):Play()
	else
		uiTween(mainScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = baseMenuScale * 0.94 }):Play()
		uiTween(main, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
		local function finishClose()
			if menuOpen then return end
			main.Visible = false
			openBtn.Visible = true
			menuOpenedViaShift = false
			if S.HUDEnabled then
				hudContainer.Visible = true
				mainBar.Visible = true
				lowerHolder.Visible = true
			end
		end
		if UIAnimations then task.delay(0.18, finishClose) else finishClose() end
	end
end
closeBtn.MouseButton1Click:Connect(function() if menuOpen then toggleMenu(false) end end)

-- Drag the window by its title bar.
local dragging, dragStart, dragOrigin = false, nil, nil
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		dragOrigin = main.Position
	end
end)
header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and dragStart and dragOrigin and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(dragOrigin.X.Scale, dragOrigin.X.Offset + delta.X, dragOrigin.Y.Scale, dragOrigin.Y.Offset + delta.Y)
	end
end)

local btnMoved, btnDragStart = false, Vector3.new()
openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		btnMoved = false
		btnDragStart = input.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if (input.Position - btnDragStart).Magnitude > 6 then btnMoved = true end
	end
end)
openBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if not btnMoved then toggleMenu(false) end
	end
end)
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu(true) end
end)

local tabsCont = Instance.new("Frame", main)
tabsCont.Size = UDim2.new(1, -28, 0, 30)
tabsCont.Position = UDim2.new(0, 14, 0, 42)
tabsCont.BackgroundTransparency = 1
local tabsLayout = Instance.new("UIListLayout", tabsCont)
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 2)
local tabRule = Instance.new("Frame", main)
tabRule.Size = UDim2.new(1, -28, 0, 1)
tabRule.Position = UDim2.new(0, 14, 0, 72)
tabRule.BackgroundColor3 = Theme.Stroke
tabRule.BorderSizePixel = 0
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -20, 1, -84)
content.Position = UDim2.new(0, 10, 0, 80)
content.BackgroundTransparency = 1
content.ClipsDescendants = true

local function createFeature(parent, name, default, callback, hasSettings)
	hasSettings = hasSettings ~= false
	local block = Instance.new("Frame", parent)
	block.Size = UDim2.new(1, 0, 0, 34)
	block.AutomaticSize = Enum.AutomaticSize.Y
	block.BackgroundColor3 = Theme.Panel
	block.BackgroundTransparency = 0.08
	block.BorderSizePixel = 0
	block.ClipsDescendants = true
	Instance.new("UICorner", block).CornerRadius = UDim.new(0, 3)
	local stripe = Instance.new("Frame", block)
	stripe.Size = UDim2.new(0, 2, 0, 18)
	stripe.Position = UDim2.new(0, 0, 0, 8)
	stripe.BorderSizePixel = 0
	registerAccent(stripe, "BackgroundColor3")

	local topBtn = Instance.new("TextButton", block)
	topBtn.Size = UDim2.new(1, 0, 0, 34)
	topBtn.BackgroundTransparency = 1
	topBtn.Text = ""
	topBtn.AutoButtonColor = false
	local lbl = Instance.new("TextLabel", topBtn)
	lbl.Text = name
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11
	lbl.TextColor3 = Theme.Text
	lbl.Size = UDim2.new(1, -92, 1, 0)
	lbl.Position = UDim2.new(0, 13, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	local expand = Instance.new("TextLabel", topBtn)
	expand.Text = hasSettings and "+" or ""
	expand.Font = Enum.Font.Code
	expand.TextSize = 13
	expand.TextColor3 = Theme.Muted
	expand.Size = UDim2.new(0, 18, 1, 0)
	expand.Position = UDim2.new(1, -69, 0, 0)
	expand.BackgroundTransparency = 1
	expand.TextXAlignment = Enum.TextXAlignment.Center

	local tbg = Instance.new("Frame", topBtn)
	tbg.Size = UDim2.new(0, 27, 0, 14)
	tbg.Position = UDim2.new(1, -43, 0.5, 0)
	tbg.AnchorPoint = Vector2.new(1, 0.5)
	tbg.BorderSizePixel = 0
	Instance.new("UICorner", tbg).CornerRadius = UDim.new(1, 0)
	local dot = Instance.new("Frame", tbg)
	dot.Size = UDim2.new(0, 8, 0, 8)
	dot.BorderSizePixel = 0
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	local tClick = Instance.new("TextButton", tbg)
	tClick.Size = UDim2.new(1, 0, 1, 0)
	tClick.BackgroundTransparency = 1
	tClick.Text = ""

	local state = default
	local function updateToggle()
		uiTween(tbg, TweenInfo.new(0.14), { BackgroundColor3 = state and Theme.Accent or Theme.Off }):Play()
		uiTween(dot, TweenInfo.new(0.14), {
			Position = state and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			BackgroundColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(220, 220, 220),
		}):Play()
		dot.AnchorPoint = Vector2.new(0, 0.5)
	end
	registerAccentUpdater(function() updateToggle() end)
	updateToggle()
	if callback then callback(state) end
	tClick.MouseButton1Click:Connect(function()
		state = not state
		if callback then callback(state) end
		updateToggle()
	end)

	local setCont = Instance.new("Frame", block)
	setCont.Size = UDim2.new(1, 0, 0, 0)
	setCont.Position = UDim2.new(0, 0, 0, 34)
	setCont.BackgroundTransparency = 1
	setCont.ClipsDescendants = true
	setCont.Visible = false
	local sLayout = Instance.new("UIListLayout", setCont)
	sLayout.Padding = UDim.new(0, 5)
	sLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local sPad = Instance.new("UIPadding", setCont)
	sPad.PaddingTop = UDim.new(0, 3)
	sPad.PaddingBottom = UDim.new(0, 7)
	sPad.PaddingLeft = UDim.new(0, 12)
	sPad.PaddingRight = UDim.new(0, 12)
	local expanded = false
	local function setExpanded(value)
		expanded = value
		setCont.Visible = value
		setCont.AutomaticSize = value and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
		expand.Text = value and "-" or (hasSettings and "+" or "")
	end
	topBtn.MouseButton1Click:Connect(function()
		if hasSettings then setExpanded(not expanded) end
	end)
	topBtn.MouseEnter:Connect(function()
		uiTween(block, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Panel2 }):Play()
	end)
	topBtn.MouseLeave:Connect(function()
		uiTween(block, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Panel }):Play()
	end)

	_fFS[name] = function(value)
		state = value
		if callback then callback(state) end
		updateToggle()
	end
	return setCont
end

local bindConnections = {}

local function addBind(p, name, def, onPress)
	local r = Instance.new("Frame", p)
	r.Size = UDim2.new(1, 0, 0, 18)
	r.BackgroundTransparency = 1
	local l = Instance.new("TextLabel", r)
	l.Text = name; l.TextColor3 = Color3.fromRGB(150,150,150); l.Font = Enum.Font.Gotham; l.TextSize = 10; l.Size = UDim2.new(0.5, 0, 1, 0); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
	local b = Instance.new("TextButton", r)
	b.Size = UDim2.new(0, 55, 0, 18); b.Position = UDim2.new(1, 0, 0.5, 0); b.AnchorPoint = Vector2.new(1, 0.5)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.BackgroundTransparency = 0
	b.Text = "["..def.."]"; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.TextSize = 10
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)

	local listening = false
	local boundKey = nil
	local inputConn = nil

	b.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		b.Text = "[...]"
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		if inputConn then inputConn:Disconnect() end
		inputConn = UIS.InputBegan:Connect(function(inp, gp)
			if gp then return end
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				local kn = inp.KeyCode.Name
				boundKey = inp.KeyCode
				b.Text = "["..kn.."]"
				b.TextColor3 = Color3.new(1,1,1)
				listening = false
				inputConn:Disconnect()

				if onPress then
					local pressConn = UIS.InputBegan:Connect(function(i2, gp2)
						if gp2 then return end
						if i2.KeyCode == boundKey then onPress() end
					end)
					table.insert(bindConnections, pressConn)
				end
			elseif inp.UserInputType == Enum.UserInputType.MouseButton1
				or inp.UserInputType == Enum.UserInputType.MouseButton2 then
				local mn = inp.UserInputType == Enum.UserInputType.MouseButton1 and "LMB" or "RMB"
				b.Text = "["..mn.."]"
				b.TextColor3 = Color3.new(1,1,1)
				listening = false
				inputConn:Disconnect()
			end
		end)
	end)
end

local function addSlider(p, name, min, max, def, callback)
	local f = Instance.new("Frame", p)
	f.Size = UDim2.new(1, 0, 0, 24)
	f.BackgroundTransparency = 1
	local l = Instance.new("TextLabel", f)
	l.Text = name; l.TextColor3 = Color3.fromRGB(150,150,150); l.Font = Enum.Font.Gotham; l.TextSize = 10; l.Size = UDim2.new(0.5, 0, 0, 12); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
	local v = Instance.new("TextLabel", f)
	v.Text = tostring(def); v.TextColor3 = Color3.fromRGB(150,150,150); v.Font = Enum.Font.Gotham; v.TextSize = 10; v.Size = UDim2.new(0.5, 0, 0, 12); v.Position = UDim2.new(0.5, 0, 0, 0); v.BackgroundTransparency = 1; v.TextXAlignment = Enum.TextXAlignment.Right

	local bg = Instance.new("Frame", f)
	bg.Size = UDim2.new(1, 0, 0, 2); bg.Position = UDim2.new(0, 0, 0, 20); bg.BackgroundColor3 = Color3.fromRGB(20,20,20); bg.BorderSizePixel = 0
	local fill = Instance.new("Frame", bg)
	fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Theme.Accent; registerAccent(fill, "BackgroundColor3"); fill.BorderSizePixel = 0

	bg.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			local function up(inp)
				local pos = math.clamp((inp.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(pos, 0, 1, 0)
				local val = math.floor(min + (max - min) * pos)
				v.Text = tostring(val)
				if callback then callback(val) end
			end
			up(i)
			local mv = UIS.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then up(inp) end end)
			UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then mv:Disconnect() end end)
		end
	end)
end

local function addDropdown(p, name, options, defIdx, callback)
	local r = Instance.new("Frame", p)
	r.Size = UDim2.new(1, 0, 0, 18)
	r.BackgroundTransparency = 1
	local l = Instance.new("TextLabel", r)
	l.Text = name; l.TextColor3 = Color3.fromRGB(150,150,150); l.Font = Enum.Font.Gotham; l.TextSize = 10; l.Size = UDim2.new(0.5, 0, 1, 0); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
	local b = Instance.new("TextButton", r)
	b.Size = UDim2.new(0, 50, 0, 18); b.Position = UDim2.new(1, 0, 0.5, 0); b.AnchorPoint = Vector2.new(1, 0.5)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.BackgroundTransparency = 0
	b.Text = options[defIdx]; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 9
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)

	local lc = Instance.new("Frame", p)
	lc.Size = UDim2.new(1, 0, 0, 0)
	lc.BackgroundTransparency = 1
	lc.ClipsDescendants = true
	local ll = Instance.new("UIListLayout", lc)
	ll.Padding = UDim.new(0, 2)
	ll.HorizontalAlignment = Enum.HorizontalAlignment.Right

	local optBtns = {}
	local currentVal = options[defIdx]

	local function refreshVisibility()
		for _, ob in pairs(optBtns) do
			ob.Visible = (ob.Text ~= currentVal)
		end
		uiTween(lc, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, ll.AbsoluteContentSize.Y)}):Play()
	end

	for _, opt in ipairs(options) do
		local ob = Instance.new("TextButton", lc)
		ob.Size = UDim2.new(0, 50, 0, 16)
		ob.BackgroundColor3 = Color3.fromRGB(25,25,25)
		ob.BorderSizePixel = 0
		ob.Text = opt
		ob.TextColor3 = Color3.fromRGB(150,150,150)
		ob.Font = Enum.Font.Gotham
		ob.TextSize = 9
		ob.Visible = (opt ~= currentVal)
		Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 3)
		table.insert(optBtns, ob)
		ob.MouseButton1Click:Connect(function()
			currentVal = opt
			b.Text = opt
			uiTween(lc, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
			if callback then callback(opt) end
		end)
	end

	b.MouseButton1Click:Connect(function()
		if lc.Size.Y.Offset == 0 then
			refreshVisibility()
		else
			uiTween(lc, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
		end
	end)

	-- force-state: переключает дропдаун программно без вызова callback
	local _ddKey = p.Name ~= "" and (p.Name .. "_" .. name) or name
	_fDD[_ddKey] = function(optVal, silent)
		currentVal = optVal
		b.Text = optVal
		uiTween(lc, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
		if not silent and callback then callback(optVal) end
	end

	return _fDD[_ddKey]
end

local function addColor(p, name, callback)
	local r = Instance.new("Frame", p)
	r.Size = UDim2.new(1, 0, 0, 18)
	r.BackgroundTransparency = 1
	local l = Instance.new("TextLabel", r)
	l.Text = name; l.TextColor3 = Color3.fromRGB(150,150,150); l.Font = Enum.Font.Gotham; l.TextSize = 10; l.Size = UDim2.new(0.5, 0, 1, 0); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
	local cBtn = Instance.new("TextButton", r)
	cBtn.Size = UDim2.new(0, 18, 0, 18); cBtn.Position = UDim2.new(1, 0, 0.5, 0); cBtn.AnchorPoint = Vector2.new(1, 0.5)
	cBtn.BackgroundColor3 = Color3.new(1,1,1); cBtn.Text = ""
	Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 4)

	local pal = Instance.new("Frame", p)
	pal.Size = UDim2.new(1, 0, 0, 0)
	pal.BackgroundTransparency = 1
	pal.ClipsDescendants = true

	local pBase = Instance.new("Frame", pal)
	pBase.Size = UDim2.new(1, 0, 1, -28)
	pBase.Position = UDim2.new(0, 0, 0, 5)
	pBase.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", pBase).CornerRadius = UDim.new(0, 4)

	local pRainbow = Instance.new("Frame", pBase)
	pRainbow.Size = UDim2.new(1, 0, 1, 0)
	pRainbow.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", pRainbow).CornerRadius = UDim.new(0, 4)
	local gradRainbow = Instance.new("UIGradient", pRainbow)
	gradRainbow.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,     Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5,   Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1,     Color3.fromRGB(255, 0, 0))
	})

	local pBlack = Instance.new("Frame", pBase)
	pBlack.Size = UDim2.new(1, 0, 0.5, 0)
	pBlack.Position = UDim2.new(0, 0, 0, 0)
	pBlack.BackgroundColor3 = Color3.new(0,0,0)
	Instance.new("UICorner", pBlack).CornerRadius = UDim.new(0, 4)
	local gradBlack = Instance.new("UIGradient", pBlack)
	gradBlack.Rotation = 90
	gradBlack.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	local pWhite = Instance.new("Frame", pBase)
	pWhite.Size = UDim2.new(1, 0, 0.5, 0)
	pWhite.Position = UDim2.new(0, 0, 0.5, 0)
	pWhite.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", pWhite).CornerRadius = UDim.new(0, 4)
	local gradWhite = Instance.new("UIGradient", pWhite)
	gradWhite.Rotation = 90
	gradWhite.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})

	local pBtn = Instance.new("TextButton", pBase)
	pBtn.Size = UDim2.new(1, 0, 1, 0)
	pBtn.BackgroundTransparency = 1
	pBtn.Text = ""

	local pOpen = false
	cBtn.MouseButton1Click:Connect(function()
		pOpen = not pOpen
		uiTween(pal, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = pOpen and UDim2.new(1, 0, 0, 70) or UDim2.new(1, 0, 0, 0)}):Play()
	end)

	pBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			local function up(inp)
				local mp = inp.Position
				local lp = pBase.AbsolutePosition
				local sz = pBase.AbsoluteSize
				local xP = math.clamp((mp.X - lp.X) / sz.X, 0, 1)
				local yP = math.clamp((mp.Y - lp.Y) / sz.Y, 0, 1)

				local hue = xP
				local col
				if yP <= 0.5 then
					local value = yP * 2
					col = Color3.fromHSV(hue, 1, value)
				else
					local sat = 1 - (yP - 0.5) * 2
					col = Color3.fromHSV(hue, sat, 1)
				end
				cBtn.BackgroundColor3 = col
				if callback then callback(col) end
			end
			up(i)
			local mv = UIS.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then up(inp) end end)
			UIS.InputEnded:Connect(function(ie) if ie.UserInputType == Enum.UserInputType.MouseButton1 or ie.UserInputType == Enum.UserInputType.Touch then mv:Disconnect() end end)
		end
	end)
end

local function selectTab(tabName, animate)
	local data = tabFrames[tabName]
	if not data then return end
	if activeBtn then activeBtn.TextColor3 = Theme.Muted end
	if activeLine then activeLine.Visible = false end
	if activeFrame then activeFrame.Visible = false end
	activeBtn = data.tb
	activeLine = data.ul
	activeFrame = data.tf
	activeBtn.TextColor3 = Theme.Text
	activeLine.Visible = true
	data.tf.Position = animate == false and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 8, 0, 0)
	data.tf.Visible = true
	uiTween(data.tf, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
end

for _, tabName in ipairs(tabs) do
	local tb = Instance.new("TextButton", tabsCont)
	tb.Size = UDim2.new(1 / #tabs, -2, 1, 0)
	tb.BackgroundTransparency = 1
	tb.Text = tabName == "CONFIG" and "Settings" or (tabName == "VISUALS" and "Visuals" or (tabName == "COMBAT" and "Combat" or (tabName == "MOVEMENT" and "Movement" or "Misc")))
	tb.Font = Enum.Font.GothamMedium
	tb.TextSize = 11
	tb.TextColor3 = Theme.Muted
	tb.AutoButtonColor = false
	local ul = Instance.new("Frame", tb)
	ul.Size = UDim2.new(0.72, 0, 0, 2)
	ul.Position = UDim2.new(0.5, 0, 1, -1)
	ul.AnchorPoint = Vector2.new(0.5, 1)
	ul.BorderSizePixel = 0
	ul.Visible = false
	registerAccent(ul, "BackgroundColor3")

	local tf = Instance.new("ScrollingFrame", content)
	tf.Size = UDim2.new(1, 0, 1, 0)
	tf.BackgroundTransparency = 1
	tf.BorderSizePixel = 0
	tf.Visible = false
	tf.ScrollBarThickness = 2
	tf.ScrollBarImageColor3 = Theme.Accent
	registerAccent(tf, "ScrollBarImageColor3")
	tf.CanvasSize = UDim2.new(0, 0, 0, 0)
	tf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tf.ScrollingDirection = Enum.ScrollingDirection.Y

	local lc = Instance.new("Frame", tf)
	lc.Size = UDim2.new(0.5, -9, 0, 0)
	lc.Position = UDim2.new(0, 5, 0, 6)
	lc.BackgroundTransparency = 1
	lc.AutomaticSize = Enum.AutomaticSize.Y
	local rc = Instance.new("Frame", tf)
	rc.Size = UDim2.new(0.5, -9, 0, 0)
	rc.Position = UDim2.new(0.5, 4, 0, 6)
	rc.BackgroundTransparency = 1
	rc.AutomaticSize = Enum.AutomaticSize.Y
	local lcLayout = Instance.new("UIListLayout", lc)
	lcLayout.Padding = UDim.new(0, 7)
	lcLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local rcLayout = Instance.new("UIListLayout", rc)
	rcLayout.Padding = UDim.new(0, 7)
	rcLayout.SortOrder = Enum.SortOrder.LayoutOrder

	tabFrames[tabName] = { tf = tf, lc = lc, rc = rc, tb = tb, ul = ul }
	tb.MouseButton1Click:Connect(function() selectTab(tabName, true) end)
	tb.MouseEnter:Connect(function()
		if activeBtn ~= tb then uiTween(tb, TweenInfo.new(0.12), { TextColor3 = Theme.Text }):Play() end
	end)
	tb.MouseLeave:Connect(function()
		if activeBtn ~= tb then uiTween(tb, TweenInfo.new(0.12), { TextColor3 = Theme.Muted }):Play() end
	end)
end
for alias, target in pairs(tabAliases) do tabFrames[alias] = tabFrames[target] end

local function getTab(name)
	local data = tabFrames[tabAliases[name] or name]
	return data.lc, data.rc
end

selectTab("COMBAT", false)

local function smartCol(tabName)
	local t = tabFrames[tabAliases[tabName] or tabName]
	local lh = t.lc.AbsoluteSize.Y + t.lc:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
	local rh = t.rc.AbsoluteSize.Y + t.rc:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
	if lh >= rh then return t.rc else return t.lc end
end



local recoilMod = nil

local function setupNoRecoil(enabled)
	if enabled then
		if not recoilMod then
			pcall(function()
				recoilMod = require(ReplicatedStorage:WaitForChild("Gun"):WaitForChild("Scripts"):WaitForChild("RecoilHandler"))
			end)
		end

		if recoilMod then
			if not recoilMod._o_nS then
				recoilMod._o_nS = recoilMod.nextStep
			end
			if not recoilMod._o_sRM then
				recoilMod._o_sRM = recoilMod.setRecoilMultiplier
			end

			recoilMod.nextStep = function() end
			recoilMod.setRecoilMultiplier = function() end
		end
	else
		if recoilMod then
			if recoilMod._o_nS then
				recoilMod.nextStep = recoilMod._o_nS
				recoilMod._o_nS = nil
			end
			if recoilMod._o_sRM then
				recoilMod.setRecoilMultiplier = recoilMod._o_sRM
				recoilMod._o_sRM = nil
			end
		end
	end
end
onCleanup(function() setupNoRecoil(false) end)

local JumpStunSettings = { Enabled = false, Height = 100 }

UIS.JumpRequest:Connect(function()
	if not JumpStunSettings.Enabled then return end
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.new(
			root.AssemblyLinearVelocity.X,
			JumpStunSettings.Height,
			root.AssemblyLinearVelocity.Z
		)
	end
end)

S.MBTargetLine = false
S.MBTargetLineColor = Color3.fromRGB(255, 255, 255)

do
	local lc, rc = getTab("COMBAT")

	local _mbSubState = {
		FOVCircle = false,
		FOVFill   = false,
		MBTargetLine = false,
	}
	local _mbWasOff = false

	local mbSet = createFeature(lc, "Silent Aim", false, function(v)
		S.SilentAim = v
		if not v then

			_mbSubState.FOVCircle    = S.FOVCircle
			_mbSubState.FOVFill      = S.FOVFill
			_mbSubState.MBTargetLine = S.MBTargetLine
			S.FOVCircle    = false
			S.FOVFill      = false
			S.MBTargetLine = false
			_mbWasOff = true
		else

			if _mbWasOff then
				S.FOVCircle    = _mbSubState.FOVCircle
				S.FOVFill      = _mbSubState.FOVFill
				S.MBTargetLine = _mbSubState.MBTargetLine
				_mbWasOff = false
			end
		end
	end)
	addSlider(mbSet, "FOV", 10, 250, 120, function(v) S.FOV = v end)
	addSlider(mbSet, "Hit Chance", 1, 100, 100, function(v) S.MBHitChance = v end)
	addSlider(mbSet, "Max Dist", 50, 1000, 500, function(v) S.MBMaxDist = v end)
	addDropdown(mbSet, "Target Part", {"Head", "Torso", "Random"}, 1, function(v)
		if v == "Head" then S.MBTargetPart = 1
		elseif v == "Torso" then S.MBTargetPart = 2
		else S.MBTargetPart = 3 end
	end)
	addDropdown(mbSet, "Visible Only", {"Off", "On"}, 1, function(v) S.MBVisibleOnly = v == "On" end)
	addDropdown(mbSet, "Target Priority", {"Distance", "HP"}, 1, function(v)
		S.MBPriority = v == "HP" and "hp" or "distance"
	end)
	addDropdown(mbSet, "FOV Mode", {"mobile", "pc"}, 1, function(v) S.MBFovMode = v end)
	addDropdown(mbSet, "FOV Circle", {"Off", "On"}, 1, function(v) S.FOVCircle = v == "On" end)
	addColor(mbSet, "FOV Color", function(c) AC_FOV = c end)
	addDropdown(mbSet, "FOV Fill", {"Off", "On"}, 1, function(v) S.FOVFill = v == "On" end)
	addSlider(mbSet, "Fill Alpha", 1, 9, 8, function(v) S.FOVFillTransparency = v / 10 end)
	addColor(mbSet, "Fill Color", function(c) AC_FOV_FILL = c end)
	local _forceTargetLineDD = addDropdown(mbSet, "Target Line", {"Off", "On"}, 1, function(v)
		local on = v == "On"
		if on and S.Tracers then
			if _fFS["Tracers"] then _fFS["Tracers"](false) end
		end
		S.MBTargetLine = on
	end)
	_fDD["TargetLine"] = _forceTargetLineDD
	addColor(mbSet, "Line Color", function(c) S.MBTargetLineColor = c end)
	addBind(mbSet, "Toggle Bind", "None", function() S.SilentAim = not S.SilentAim end)

	local noRecoilSet = createFeature(rc, "No Recoil", false, function(v)
		S.NoRecoil = v
		setupNoRecoil(v)
	end, false)
	addBind(noRecoilSet, "Toggle Bind", "None", function()
		S.NoRecoil = not S.NoRecoil
		setupNoRecoil(S.NoRecoil)
	end)

end

do
	local lc, rc = getTab("ESP")

	local espSet = createFeature(lc, "ESP", false, function(v) S.ESPEnabled = v end)
	addSlider(espSet, "Radius", 50, 1000, 500, function(v) S.ESPRadius = v end)
	addColor(espSet, "Box Color", function(c) AC_ESP = c end)
	addDropdown(espSet, "Box Fill", {"Off", "On"}, 1, function(v) S.BoxFill = v == "On" end)
	addSlider(espSet, "Fill Alpha", 1, 9, 7, function(v) S.BoxFillTransparency = v / 10 end)
	addColor(espSet, "Fill Color", function(c) AC_FILL = c end)

	local tracerSet = createFeature(lc, "Tracers", false, function(v)
		S.Tracers = v
		if v and S.MBTargetLine then
			S.MBTargetLine = false
			-- сбрасываем дропдаун Target Line визуально в меню
			if _fDD["TargetLine"] then _fDD["TargetLine"]("Off", true) end
		end
	end)
	addDropdown(tracerSet, "Origin", {"Top", "Bottom", "Center"}, 2, function(v)
		if v == "Top" then S.TracerOrigin = 1
		elseif v == "Bottom" then S.TracerOrigin = 2
		else S.TracerOrigin = 3 end
	end)
	addColor(tracerSet, "Color", function(c) AC_TR = c end)

	local hpSet = createFeature(rc, "HP Bar", false, function(v) S.HPBar = v end)
	addDropdown(hpSet, "Position", {"Side", "Top"}, 1, function(v)
		S.HPBarSide = v == "Side" and 1 or 2
	end)
	addColor(hpSet, "Color", function(c) AC_HP = c end)

	local namesSet = createFeature(rc, "Names", false, function(v) S.Names = v end)
	addColor(namesSet, "Color", function(c) AC_NAME = c end)

	local distSet = createFeature(lc, "Distance", false, function(v) S.ESPDist = v end)
	addColor(distSet, "Color", function(c) AC_DIST = c end)
end

do
	local lc, rc = getTab("MOVEMENT")

	local speedSet = createFeature(lc, "Speed", false, function(v)
		S.SpeedRostAlpha = v
		if not v and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end
	end)
	addSlider(speedSet, "Value", 10, 200, 60, function(v) S.SpeedRostValue = v end)
	addSlider(speedSet, "Smoothing", 1, 10, 5, function(v) S.SpeedRostSmoothing = v / 10 end)
	addBind(speedSet, "Toggle Bind", "None", function() S.SpeedRostAlpha = not S.SpeedRostAlpha end)

	local hjSet = createFeature(lc, "High Jump", false, function(v)
		S.HighJump = v
		JumpStunSettings.Enabled = v
	end)
	addSlider(hjSet, "Height", 1, 200, 100, function(v)
		S.HighJumpHeight = v
		JumpStunSettings.Height = v
	end)
	addBind(hjSet, "Toggle Bind", "None", function()
		S.HighJump = not S.HighJump
		JumpStunSettings.Enabled = S.HighJump
	end)

	local spiderSet = createFeature(rc, "Spider", false, function(v) S.Spider = v end)
	addSlider(spiderSet, "Speed", 5, 60, 20, function(v) S.SpiderSpeed = v end)
	addBind(spiderSet, "Toggle Bind", "None", function() S.Spider = not S.Spider end)

end

local HitSoundSettings = {
	Enabled = false,
	SoundId = "rbxassetid://8935436941",
	Volume  = 2,
	OriginalSounds = {}
}

do
	local lc, rc = getTab("MISC")

	local HitSoundIDs = {
		["Pop"]      = "rbxassetid://8935436941",
		["Neverlose"]= "rbxassetid://6607598351",
		["Bat"]      = "rbxassetid://99362374452374",
		["Tink"]     = "rbxassetid://134428986251283",
		["Blum"]     = "rbxassetid://79105299046226",
	}

	local _hsLastPlayTime = {}
	local _HS_COOLDOWN = 0.5

	local function applyHitSound(snd)
		if not snd or not snd.Parent then return end
		if not HitSoundSettings.OriginalSounds[snd] then
			HitSoundSettings.OriginalSounds[snd] = {SoundId = snd.SoundId, Volume = snd.Volume}
		end
		snd.SoundId = HitSoundSettings.SoundId
		snd.Volume  = HitSoundSettings.Volume

		-- Anti-spam: перехватываем воспроизведение через .Played
		if not snd:GetAttribute("_burmalda_hs_hooked") then
			snd:SetAttribute("_burmalda_hs_hooked", true)
			snd.Played:Connect(function()
				local now = tick()
				local last = _hsLastPlayTime[snd] or 0
				if (now - last) < _HS_COOLDOWN then
					snd:Stop()
				else
					_hsLastPlayTime[snd] = now
				end
			end)
		end
	end

	local function restoreHitSound(snd)
		if not snd or not snd.Parent then return end
		local orig = HitSoundSettings.OriginalSounds[snd]
		if orig then
			snd.SoundId = orig.SoundId
			snd.Volume  = orig.Volume
		end
	end

	local function applyHSTool(tool)
		if not tool or not tool:IsA("Tool") then return end
		task.spawn(function()
			local ba = tool:FindFirstChild("BodyAttach") or tool:WaitForChild("BodyAttach", 5)
			if not ba then return end
			for _, sName in ipairs({"HitClient", "HeadShotClient", "HitCharacterClient"}) do
				local s = ba:FindFirstChild(sName)
				if s and s:IsA("Sound") then
					if HitSoundSettings.Enabled then applyHitSound(s)
					else restoreHitSound(s) end
				end
			end
		end)
	end

	local _hsConns = {}
	local function hookHSContainers()

		for _, c in ipairs(_hsConns) do c:Disconnect() end
		_hsConns = {}

		local char    = LocalPlayer.Character
		local backpack = LocalPlayer:FindFirstChild("Backpack")

		local function hookContainer(container)
			if not container then return end

			for _, item in ipairs(container:GetChildren()) do
				applyHSTool(item)
			end

			table.insert(_hsConns, container.ChildAdded:Connect(function(child)
				task.delay(0.15, function() applyHSTool(child) end)
			end))
		end

		hookContainer(char)
		hookContainer(backpack)
	end

	-- Лёгкое обновление: только меняет SoundId/Volume на уже захуканных звуках
	local function refreshSounds()
		local char    = LocalPlayer.Character
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local function refreshContainer(container)
			if not container then return end
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") then
					local ba = item:FindFirstChild("BodyAttach")
					if ba then
						for _, sName in ipairs({"HitClient", "HeadShotClient", "HitCharacterClient"}) do
							local s = ba:FindFirstChild(sName)
							if s and s:IsA("Sound") and HitSoundSettings.Enabled then
								applyHitSound(s)
							end
						end
					end
				end
			end
		end
		refreshContainer(char)
		refreshContainer(backpack)
	end

	local _hsSoundDebounce = false
	local function debouncedRefresh()
		if _hsSoundDebounce then return end
		_hsSoundDebounce = true
		task.defer(function()
			refreshSounds()
			_hsSoundDebounce = false
		end)
	end

	local hsSet = createFeature(lc, "Hit Sound", false, function(v)
		HitSoundSettings.Enabled = v
		if v then
			refreshSounds()
			task.defer(hookHSContainers)
		else
			hookHSContainers()
		end
	end)

	addDropdown(hsSet, "Sound", {"Pop", "Neverlose", "Bat", "Tink", "Blum"}, 1, function(v)
		HitSoundSettings.SoundId = HitSoundIDs[v] or HitSoundIDs["Pop"]
		if HitSoundSettings.Enabled then debouncedRefresh() end
	end)

	addSlider(hsSet, "Volume", 1, 10, 2, function(v)
		HitSoundSettings.Volume = v
		if HitSoundSettings.Enabled then debouncedRefresh() end
	end)

	LocalPlayer.CharacterAdded:Connect(function()
		task.delay(0.3, function() if not Runtime.Unloaded then hookHSContainers() end end)
	end)

	LocalPlayer.CharacterRemoving:Connect(function()
		for _, c in ipairs(_hsConns) do pcall(function() c:Disconnect() end) end
		_hsConns = {}
	end)

	if LocalPlayer.Character then
		task.delay(0.3, function() if not Runtime.Unloaded then hookHSContainers() end end)
	end

	task.spawn(function()
		while true do
		if Runtime.Unloaded then break end
			task.wait(2)
			if HitSoundSettings.Enabled then
				refreshSounds()
			end
		end
	end)
	onCleanup(function()
		HitSoundSettings.Enabled = false
		for snd in pairs(HitSoundSettings.OriginalSounds) do restoreHitSound(snd) end
		for _, conn in ipairs(_hsConns) do conn:Disconnect() end
	end)
end

local HotbarSettings = {
	enabled   = false,
	maxFOV    = 180,
}

local HotbarUI = {
	frame = nil,
	icons = {},
	initialized = false,
}

local CustomIcons = {}

local function hotbarGetParent()
	local p
	pcall(function()
		if gethui then p = gethui()
		else p = game:GetService("CoreGui") end
	end)
	return p or LocalPlayer:WaitForChild("PlayerGui")
end

local function hotbarInit()
	if HotbarUI.initialized then return end
	local sg = newScreenGui()
	sg.Name = "BurmaldaHook_Hotbar"
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn = false
	sg.Parent = hotbarGetParent()

	local main = Instance.new("Frame")
	main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	main.BackgroundTransparency = 0.08
	main.BorderSizePixel = 0
	local _hbPC = Camera.ViewportSize.X >= 1024
	-- чуть меньше отступ снизу на PC, иконки тоже меньше
	main.Position = UDim2.new(0.5, 0, 1, _hbPC and -80 or -56)
	main.AnchorPoint = Vector2.new(0.5, 1)
	main.Visible = false
	main.Parent = sg
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, 4)
	list.Parent = main

	local pad = Instance.new("UIPadding", main)
	pad.PaddingLeft  = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)

	for i = 1, 6 do
		local icon = Instance.new("ImageLabel")
		local _ipc = Camera.ViewportSize.X >= 1024
		-- на PC иконки 40px вместо 60px — выглядят как телефонная версия но крупнее
		icon.Size = UDim2.new(0, _ipc and 40 or 24, 0, _ipc and 40 or 24)
		icon.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
		icon.BackgroundTransparency = 0.3
		icon.BorderSizePixel = 0
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Visible = false
		icon.Parent = main
		Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 4)

		HotbarUI.icons[i] = {slot = icon, icon = icon}
	end

	HotbarUI.frame = main
	HotbarUI.initialized = true
end

local function hotbarGetTarget()
	local closest, lastDist = nil, HotbarSettings.maxFOV
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if dist < lastDist then
					lastDist = dist
					closest = p
				end
			end
		end
	end
	return closest
end

local function hotbarGetItems(player)
	local items = {}
	local char = player.Character
	if not char then return items end
	local function collectTools(parent)
		for _, obj in pairs(parent:GetChildren()) do
			if obj:IsA("Tool") and #items < 6 then
				local id = (obj.TextureId ~= "") and obj.TextureId or CustomIcons[obj.Name]
				if id then table.insert(items, id) end
			end
		end
	end
	collectTools(char)
	if player:FindFirstChild("Backpack") then collectTools(player.Backpack) end
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("Accessory") and #items < 6 then
			local id = CustomIcons[obj.Name]
			if id then table.insert(items, id) end
		end
	end
	return items
end

task.spawn(function()
	while task.wait(0.1) do
		if Runtime.Unloaded then break end
		if not HotbarSettings.enabled then
			if HotbarUI.frame then HotbarUI.frame.Visible = false end
			continue
		end
		if not HotbarUI.initialized then hotbarInit() end
		local target = hotbarGetTarget()
		if target then
			local foundItems = hotbarGetItems(target)
			local count = #foundItems
			if count > 0 then
				HotbarUI.frame.Visible = true
				local _fpc = Camera.ViewportSize.X >= 1024
				local _isz = _fpc and 40 or 24
				local _igap = _fpc and 8 or 4
				HotbarUI.frame.Size = UDim2.new(0, (count * _isz) + ((count - 1) * _igap) + 12, 0, _fpc and 56 or 36)
				for i = 1, 6 do
					local slot = HotbarUI.icons[i].slot
					local icon = HotbarUI.icons[i].icon
					if i <= count then
						slot.Visible = true
						icon.Image = foundItems[i]
					else
						slot.Visible = false
					end
				end
			else
				HotbarUI.frame.Visible = false
			end
		else
			HotbarUI.frame.Visible = false
		end
	end
end)

do
	local lc, rc = getTab("HUD")

	local wmSet = createFeature(lc, "HUD", true, function(v)
		S.HUDEnabled = v
		updateHUD()
	end, false)

	createFeature(lc, "Hotbar Overlay", false, function(v)
		HotbarSettings.enabled = v
		hotbarInit()
	end, false)

	local chSet = createFeature(rc, "Crosshair", false, function(v)
		crosshairSettings.crosshairEnabled = v
	end)
	local chTypeDD = addDropdown(chSet, "Type", {"Default", "X", "Dot", "Custom"}, 1, function(v)
		crosshairSettings.crosshairType = v
		chBuild(v, crosshairSettings.crosshairSize, crosshairSettings.crosshairThickness)
	end)
	addDropdown(chSet, "Mode", {"mobile", "pc"}, 1, function(v)
		crosshairSettings.crosshairCenter = v == "mobile"
		if v == "pc" then
			-- скрываем системный курсор, прицел рисуется поверх
			UIS.MouseIconEnabled = false
		else
			UIS.MouseIconEnabled = true
		end
	end)
	addSlider(chSet, "Size", 2, 30, 8, function(v) crosshairSettings.crosshairSize = v end)
	addSlider(chSet, "Thickness", 1, 8, 2, function(v) crosshairSettings.crosshairThickness = v end)
	addSlider(chSet, "Length", 4, 40, 10, function(v)
		crosshairSettings.crosshairLength = v
		if crosshairSettings.crosshairType == "Custom" then
			chBuild("Custom", crosshairSettings.crosshairSize, crosshairSettings.crosshairThickness)
		end
	end)
	addSlider(chSet, "Gap", 0, 20, 4, function(v)
		crosshairSettings.crosshairGap = v
		if crosshairSettings.crosshairType == "Custom" then
			chBuild("Custom", crosshairSettings.crosshairSize, crosshairSettings.crosshairThickness)
		end
	end)
	addColor(chSet, "Color", function(c) crosshairSettings.crosshairColor = c end)
	addDropdown(chSet, "Spin", {"Off", "On"}, 1, function(v) crosshairSettings.crosshairSpin = v == "On" end)
	addSlider(chSet, "Spin Speed", 1, 20, 2, function(v) crosshairSettings.crosshairSpinSpeed = v end)
	addDropdown(chSet, "Rainbow", {"Off", "On"}, 1, function(v) crosshairSettings.crosshairRainbow = v == "On" end)

	createFeature(rc, "Pickup Notifications", false, function(v)
		PickupNotifEnabled = v
	end, false)
end

local customModelsEnabled = false
local glassColor          = Color3.fromRGB(255, 255, 255)
local glassTransparency   = 0.4
local glassMaterial       = Enum.Material.Glass

local fogEnabled = false
local fogColor   = Color3.fromRGB(0, 0, 0)
local fogDensity = 0.6
local _fogDirty  = false

local fovLockEnabled = false
local targetFOV      = 90

local _Lighting = game:GetService("Lighting")
local fogAtm    = nil
local _origFogColor, _origFogEnd, _origFogStart, _origClockTime, _origBrightness, _origOutdoorAmbient

local function applyFogSettings()
	if not fogAtm then return end
	fogAtm.Color   = fogColor
	fogAtm.Decay   = fogColor
	fogAtm.Density = fogDensity
	fogAtm.Haze    = 10
	_Lighting.ClockTime      = 0
	_Lighting.Brightness     = 0
	_Lighting.OutdoorAmbient = fogColor
	_Lighting.FogColor       = fogColor
	_Lighting.FogEnd         = 150
	_Lighting.FogStart       = 0
	_fogDirty = false
end

local function enableFog()
	if not _origFogColor then
		_origFogColor       = _Lighting.FogColor
		_origFogEnd         = _Lighting.FogEnd
		_origFogStart       = _Lighting.FogStart
		_origClockTime      = _Lighting.ClockTime
		_origBrightness     = _Lighting.Brightness
		_origOutdoorAmbient = _Lighting.OutdoorAmbient
	end
	fogAtm = Instance.new("Atmosphere", _Lighting)
	fogAtm.Name = "BurmaldaHookAtmosphere"
	applyFogSettings()
end

local function disableFog()
	if fogAtm then fogAtm:Destroy(); fogAtm = nil end
	if _origFogColor then
		_Lighting.FogColor       = _origFogColor
		_Lighting.FogEnd         = _origFogEnd
		_Lighting.FogStart       = _origFogStart
		_Lighting.ClockTime      = _origClockTime
		_Lighting.Brightness     = _origBrightness
		_Lighting.OutdoorAmbient = _origOutdoorAmbient
	end
end
onCleanup(function() fogEnabled = false; disableFog() end)

do
	local lc, rc = getTab("CONFIG")
	createFeature(lc, "Unload Burmalda.hook", false, function(v)
		if v and Runtime.Unload then task.defer(Runtime.Unload) end
	end, false)
	local accentSet = createFeature(lc, "Menu Accent", true, function() end)
	addColor(accentSet, "Accent Color", function(c) setMenuAccent(c) end)
	addDropdown(accentSet, "Preset", {"White", "Silver", "Graphite"}, 1, function(v)
		if v == "Silver" then setMenuAccent(Color3.fromRGB(190, 190, 190))
		elseif v == "Graphite" then setMenuAccent(Color3.fromRGB(105, 105, 105))
		else setMenuAccent(Color3.fromRGB(255, 255, 255)) end
	end)
	createFeature(lc, "UI Animations", true, function(v) UIAnimations = v end, false)
	local HS     = game:GetService("HttpService")
	local FOLDER = "burmalda_rost_config"

	pcall(function() if not isfolder(FOLDER) then makefolder(FOLDER) end end)

	local function c2t(c) return {r=math.floor(c.R*255),g=math.floor(c.G*255),b=math.floor(c.B*255)} end
	local function t2c(t) return Color3.fromRGB(t.r,t.g,t.b) end

	local function buildConfig()
		local cfg = {}

		for k,v in pairs(S) do cfg["S_"..k] = v end

		local cols = {AC_ESP=AC_ESP,AC_FOV=AC_FOV,AC_FOV_FILL=AC_FOV_FILL,
			AC_TR=AC_TR,AC_NAME=AC_NAME,AC_DIST=AC_DIST,
			AC_FILL=AC_FILL,AC_HP=AC_HP}
		for k,v in pairs(cols) do cfg[k] = c2t(v) end

		cfg["CH_enabled"]   = crosshairSettings.crosshairEnabled
		cfg["CH_type"]      = crosshairSettings.crosshairType
		cfg["CH_size"]      = crosshairSettings.crosshairSize
		cfg["CH_thickness"] = crosshairSettings.crosshairThickness
		cfg["CH_gap"]       = crosshairSettings.crosshairGap
		cfg["CH_length"]    = crosshairSettings.crosshairLength
		cfg["CH_center"]    = crosshairSettings.crosshairCenter
		cfg["CH_spin"]      = crosshairSettings.crosshairSpin
		cfg["CH_spinSpeed"] = crosshairSettings.crosshairSpinSpeed
		cfg["CH_rainbow"]   = crosshairSettings.crosshairRainbow
		cfg["CH_color"]     = c2t(crosshairSettings.crosshairColor)

		cfg["HS_enabled"] = HitSoundSettings.Enabled
		cfg["HS_soundId"] = HitSoundSettings.SoundId
		cfg["HS_volume"]  = HitSoundSettings.Volume

		cfg["FG_enabled"] = fogEnabled
		cfg["FG_color"]   = c2t(fogColor)
		cfg["FG_density"] = fogDensity

		cfg["CFOV_enabled"] = fovLockEnabled
		cfg["CFOV_value"]   = targetFOV

		cfg["CM_enabled"]      = customModelsEnabled
		cfg["CM_color"]        = c2t(glassColor)
		cfg["CM_transparency"] = glassTransparency
		cfg["CM_material"]     = tostring(glassMaterial)

		cfg["HB_enabled"] = HotbarSettings.enabled

		cfg["PN_enabled"] = PickupNotifEnabled
		cfg["UI_accent"] = c2t(Theme.Accent)
		cfg["UI_animations"] = UIAnimations
		return HS:JSONEncode(cfg)
	end

	local function applyConfig(str)
		local ok, cfg = pcall(HS.JSONDecode, HS, str)
		if not ok or type(cfg) ~= "table" then return false end

		for k in pairs(S) do
			if cfg["S_"..k] ~= nil then S[k] = cfg["S_"..k] end
		end

		if cfg.AC_ESP      then AC_ESP      = t2c(cfg.AC_ESP)      end
		if cfg.AC_FOV      then AC_FOV      = t2c(cfg.AC_FOV)      end
		if cfg.AC_FOV_FILL then AC_FOV_FILL = t2c(cfg.AC_FOV_FILL) end
		if cfg.AC_TR       then AC_TR       = t2c(cfg.AC_TR)       end
		if cfg.AC_NAME     then AC_NAME     = t2c(cfg.AC_NAME)     end
		if cfg.AC_DIST     then AC_DIST     = t2c(cfg.AC_DIST)     end
		if cfg.AC_FILL     then AC_FILL     = t2c(cfg.AC_FILL)     end
		if cfg.AC_HP       then AC_HP       = t2c(cfg.AC_HP)       end

		if cfg.CH_enabled   ~= nil then crosshairSettings.crosshairEnabled   = cfg.CH_enabled   end
		if cfg.CH_type      ~= nil then crosshairSettings.crosshairType      = cfg.CH_type      end
		if cfg.CH_size      ~= nil then crosshairSettings.crosshairSize      = cfg.CH_size      end
		if cfg.CH_thickness ~= nil then crosshairSettings.crosshairThickness = cfg.CH_thickness end
		if cfg.CH_gap       ~= nil then crosshairSettings.crosshairGap       = cfg.CH_gap       end
		if cfg.CH_length    ~= nil then crosshairSettings.crosshairLength    = cfg.CH_length    end
		if cfg.CH_center    ~= nil then crosshairSettings.crosshairCenter    = cfg.CH_center    end
		if cfg.CH_spin      ~= nil then crosshairSettings.crosshairSpin      = cfg.CH_spin      end
		if cfg.CH_spinSpeed ~= nil then crosshairSettings.crosshairSpinSpeed = cfg.CH_spinSpeed end
		if cfg.CH_rainbow   ~= nil then crosshairSettings.crosshairRainbow   = cfg.CH_rainbow   end
		if cfg.CH_color     ~= nil then crosshairSettings.crosshairColor     = t2c(cfg.CH_color) end

		if cfg.HS_enabled ~= nil then HitSoundSettings.Enabled = cfg.HS_enabled end
		if cfg.HS_soundId ~= nil then HitSoundSettings.SoundId = cfg.HS_soundId end
		if cfg.HS_volume  ~= nil then HitSoundSettings.Volume  = cfg.HS_volume  end

		if cfg.FG_enabled ~= nil then fogEnabled = cfg.FG_enabled end
		if cfg.FG_color   ~= nil then fogColor   = t2c(cfg.FG_color) end
		if cfg.FG_density ~= nil then fogDensity = cfg.FG_density end

		if cfg.CFOV_enabled ~= nil then fovLockEnabled = cfg.CFOV_enabled end
		if cfg.CFOV_value   ~= nil then targetFOV      = cfg.CFOV_value   end

		if cfg.CM_enabled      ~= nil then customModelsEnabled = cfg.CM_enabled      end
		if cfg.CM_color        ~= nil then glassColor          = t2c(cfg.CM_color)   end
		if cfg.CM_transparency ~= nil then glassTransparency   = cfg.CM_transparency end
		if cfg.CM_material     ~= nil then
			local mats = {Glass=Enum.Material.Glass, Neon=Enum.Material.Neon,
				ForceField=Enum.Material.ForceField, SmoothPlastic=Enum.Material.SmoothPlastic}
			glassMaterial = mats[cfg.CM_material] or Enum.Material.Glass
		end

		if cfg.HB_enabled ~= nil then HotbarSettings.enabled = cfg.HB_enabled end
		if cfg.PN_enabled ~= nil then PickupNotifEnabled      = cfg.PN_enabled end
		if cfg.UI_accent then setMenuAccent(t2c(cfg.UI_accent)) end
		if cfg.UI_animations ~= nil then UIAnimations = cfg.UI_animations end

		local function applyToggle(name, state)
			if _fFS[name] then _fFS[name](state) end
		end

		applyToggle("Silent Aim",            S.SilentAim)
		applyToggle("No Recoil",             S.NoRecoil)

		applyToggle("ESP",                   S.ESPEnabled)
		applyToggle("Tracers",               S.Tracers)
		applyToggle("HP Bar",                S.HPBar)
		applyToggle("Names",                 S.Names)
		applyToggle("Distance",              S.ESPDist)

		applyToggle("Speed",                 S.SpeedRostAlpha)
		applyToggle("High Jump",             S.HighJump)
		applyToggle("Spider",                S.Spider)

		applyToggle("Hit Sound",             HitSoundSettings.Enabled)

		applyToggle("HUD",                   S.HUDEnabled)
		applyToggle("Hotbar Overlay",        HotbarSettings.enabled)
		applyToggle("Crosshair",             crosshairSettings.crosshairEnabled)
		applyToggle("Pickup Notifications",  PickupNotifEnabled)

		applyToggle("Custom Models",         customModelsEnabled)
		applyToggle("Custom Fog",            fogEnabled)
		applyToggle("Custom FOV",            fovLockEnabled)
		applyToggle("UI Animations",         UIAnimations)

		if fovLockEnabled and targetFOV then Camera.FieldOfView = targetFOV end

		return true
	end

	local function saveToFile(name)
		local ok = false
		pcall(function() writefile(FOLDER.."/"..name..".cfg", buildConfig()); ok = true end)
		return ok
	end
	local function loadFromFile(name)
		local str
		pcall(function() str = readfile(FOLDER.."/"..name..".cfg") end)
		return str and applyConfig(str)
	end
	local function listFiles()
		local out = {}
		pcall(function()
			for _,f in ipairs(listfiles(FOLDER)) do
				local n = f:match("([^/\\]+)%.cfg$")
				if n then table.insert(out, n) end
			end
		end)
		return out
	end
	local function deleteFile(name)
		pcall(function() delfile(FOLDER.."/"..name..".cfg") end)
	end

	local HUD_BG = Color3.fromRGB(8,8,8)
	local HUD_BT = 0.08
	local HUD_ST = 0.92
	local HUD_R  = 6

	local function mkCorner(p)
		Instance.new("UICorner", p).CornerRadius = UDim.new(0, HUD_R)
	end
	local function mkStroke(p)
		Instance.new("UIStroke", p).Transparency = HUD_ST
	end
	local function mkBtn(parent, txt, w, h)
		local b = Instance.new("TextButton", parent)
		b.Size = w and UDim2.new(0, w, 0, h or 22) or UDim2.new(1, 0, 0, h or 22)
		b.BackgroundColor3 = HUD_BG
		b.BackgroundTransparency = HUD_BT
		b.BorderSizePixel = 0
		b.Text = txt
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 10
		b.AutoButtonColor = false
		mkCorner(b); mkStroke(b)
		b.MouseButton1Click:Connect(function()
			TS:Create(b, TweenInfo.new(0.08), {BackgroundTransparency = 0}):Play()
			task.delay(0.15, function()
				TS:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = HUD_BT}):Play()
			end)
		end)
		return b
	end

	local inputF = Instance.new("Frame", lc)
	inputF.Size = UDim2.new(1, 0, 0, 26)
	inputF.BackgroundColor3 = HUD_BG
	inputF.BackgroundTransparency = HUD_BT
	inputF.BorderSizePixel = 0
	mkCorner(inputF); mkStroke(inputF)
	local iPad = Instance.new("UIPadding", inputF)
	iPad.PaddingLeft = UDim.new(0, 8); iPad.PaddingRight = UDim.new(0, 8)
	local tb = Instance.new("TextBox", inputF)
	tb.Size = UDim2.new(1, 0, 1, 0)
	tb.BackgroundTransparency = 1
	tb.Text = ""; tb.PlaceholderText = "config name..."
	tb.Font = Enum.Font.GothamMedium; tb.TextSize = 10
	tb.TextColor3 = Color3.new(1,1,1)
	tb.PlaceholderColor3 = Color3.fromRGB(70,70,70)
	tb.ClearTextOnFocus = false
	tb.TextXAlignment = Enum.TextXAlignment.Center

	local rowF = Instance.new("Frame", lc)
	rowF.Size = UDim2.new(1, 0, 0, 22)
	rowF.BackgroundTransparency = 1
	local rowL = Instance.new("UIListLayout", rowF)
	rowL.FillDirection = Enum.FillDirection.Horizontal
	rowL.Padding = UDim.new(0, 4)

	local btnSave  = mkBtn(rowF, "Save")
	btnSave.Size   = UDim2.new(1/3, -3, 1, 0)
	local btnLoad2 = mkBtn(rowF, "Load")
	btnLoad2.Size  = UDim2.new(1/3, -3, 1, 0)
	local btnDel   = mkBtn(rowF, "Delete")
	btnDel.Size    = UDim2.new(1/3, -3, 1, 0)

	local listFrame = Instance.new("Frame", rc)
	listFrame.Size = UDim2.new(1, 0, 0, 0)
	listFrame.AutomaticSize = Enum.AutomaticSize.Y
	listFrame.BackgroundTransparency = 1
	local listLayout = Instance.new("UIListLayout", listFrame)
	listLayout.Padding = UDim.new(0, 4)

	local emptyLbl = Instance.new("TextLabel", listFrame)
	emptyLbl.Text = "No saved configs"
	emptyLbl.Font = Enum.Font.Gotham; emptyLbl.TextSize = 10
	emptyLbl.TextColor3 = Color3.fromRGB(60,60,60)
	emptyLbl.BackgroundTransparency = 1
	emptyLbl.Size = UDim2.new(1, 0, 0, 26)
	emptyLbl.TextXAlignment = Enum.TextXAlignment.Center

	local function refreshList()
		for _, ch in ipairs(listFrame:GetChildren()) do
			if ch ~= listLayout and ch ~= emptyLbl then ch:Destroy() end
		end
		local files = listFiles()
		emptyLbl.Visible = #files == 0
		for _, cfgName in ipairs(files) do
			local row = Instance.new("Frame", listFrame)
			row.Size = UDim2.new(1, 0, 0, 26)
			row.BackgroundColor3 = HUD_BG
			row.BackgroundTransparency = HUD_BT
			row.BorderSizePixel = 0
			mkCorner(row); mkStroke(row)

			local rPad = Instance.new("UIPadding", row)
			rPad.PaddingLeft = UDim.new(0, 8); rPad.PaddingRight = UDim.new(0, 5)
			local rL = Instance.new("UIListLayout", row)
			rL.FillDirection = Enum.FillDirection.Horizontal
			rL.VerticalAlignment = Enum.VerticalAlignment.Center
			rL.Padding = UDim.new(0, 4)

			local nLbl = Instance.new("TextLabel", row)
			nLbl.Text = cfgName
			nLbl.Font = Enum.Font.GothamMedium; nLbl.TextSize = 10
			nLbl.TextColor3 = Color3.new(1,1,1)
			nLbl.BackgroundTransparency = 1
			nLbl.Size = UDim2.new(1, -76, 1, 0)
			nLbl.TextXAlignment = Enum.TextXAlignment.Left
			nLbl.TextTruncate = Enum.TextTruncate.AtEnd

			local bLd = mkBtn(row, "Load", 34, 18)
			local bDl = mkBtn(row, "Del",  34, 18)

			bLd.MouseButton1Click:Connect(function()
				loadFromFile(cfgName)
			end)
			bDl.MouseButton1Click:Connect(function()
				deleteFile(cfgName); refreshList()
			end)
		end
	end

	refreshList()

	local function cleanName(raw)
		return raw:gsub("[^%w%-_]","_"):sub(1, 24)
	end

	btnSave.MouseButton1Click:Connect(function()
		local name = cleanName(tb.Text)
		if name == "" then return end
		local ok = saveToFile(name)
		if not ok then
			pcall(function() setclipboard(buildConfig()) end)
		end
		refreshList()
	end)

	btnLoad2.MouseButton1Click:Connect(function()
		local name = cleanName(tb.Text)
		if name == "" then return end
		loadFromFile(name)
	end)

	btnDel.MouseButton1Click:Connect(function()
		local name = cleanName(tb.Text)
		if name == "" then return end
		deleteFile(name); refreshList()
	end)
end

do
	local lc, rc = getTab("VISUAL")

	local customModelOriginals = {}
	local function applyGlassEffect(part)
		if not part:IsA("BasePart") or part.Transparency >= 0.9 then return end
		if not customModelOriginals[part] then
			customModelOriginals[part] = {
				Color = part.Color,
				Material = part.Material,
				Transparency = part.Transparency,
				Reflectance = part.Reflectance,
				CastShadow = part.CastShadow,
				TextureID = part:IsA("MeshPart") and part.TextureID or nil,
			}
		end
		local original = customModelOriginals[part]
		if original.TextureID ~= nil then pcall(function() part.TextureID = "" end) end
		part.Color = glassColor
		part.Material = glassMaterial
		part.Transparency = glassTransparency
		part.Reflectance = 0.3
		part.CastShadow = false
	end

	local function restoreCustomModels()
		for part, original in pairs(customModelOriginals) do
			if part and part.Parent then
				pcall(function()
					part.Color = original.Color
					part.Material = original.Material
					part.Transparency = original.Transparency
					part.Reflectance = original.Reflectance
					part.CastShadow = original.CastShadow
					if original.TextureID ~= nil then part.TextureID = original.TextureID end
				end)
			end
		end
		table.clear(customModelOriginals)
	end
	onCleanup(restoreCustomModels)

	local function scanForWeapons()
		if Runtime.Unloaded or not customModelsEnabled then return end
		local camera = workspace.CurrentCamera
		if camera then
			for _, obj in pairs(camera:GetChildren()) do
				if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
					pcall(function() applyGlassEffect(obj) end)
					for _, descendant in pairs(obj:GetDescendants()) do
						pcall(function() applyGlassEffect(descendant) end)
					end
				end
			end
		end
		local char = LocalPlayer.Character
		if char then
			local tool = char:FindFirstChildOfClass("Tool")
			if tool then
				for _, descendant in pairs(tool:GetDescendants()) do
					pcall(function() applyGlassEffect(descendant) end)
				end
			end
		end
	end

	local _cmLastChar = nil
	local function connectCMChar(char)
		if Runtime.Unloaded or not char then return end
		pcall(scanForWeapons)
		char.ChildAdded:Connect(function(child)
			if customModelsEnabled and (child:IsA("Tool") or child:IsA("Model")) then
				task.delay(0.05, function() pcall(scanForWeapons) end)
			end
		end)
	end
	LocalPlayer.CharacterAdded:Connect(connectCMChar)
	if LocalPlayer.Character then connectCMChar(LocalPlayer.Character) end

	local cmSet = createFeature(lc, "Custom Models", false, function(v)
		customModelsEnabled = v
		if v then pcall(scanForWeapons) else restoreCustomModels() end
	end)

	addColor(cmSet, "Glass Color", function(c)
		glassColor = c
	end)

	addDropdown(cmSet, "Material", {"Glass", "Neon", "ForceField", "SmoothPlastic"}, 1, function(v)
		if v == "Glass" then glassMaterial = Enum.Material.Glass
		elseif v == "Neon" then glassMaterial = Enum.Material.Neon
		elseif v == "ForceField" then glassMaterial = Enum.Material.ForceField
		else glassMaterial = Enum.Material.SmoothPlastic end
	end)

	addSlider(cmSet, "Transparency", 0, 9, 4, function(v)
		glassTransparency = v / 10
	end)

	addBind(cmSet, "Toggle Bind", "None", function()
		customModelsEnabled = not customModelsEnabled
		if customModelsEnabled then pcall(scanForWeapons) else restoreCustomModels() end
	end)

	local fogSet = createFeature(lc, "Custom Fog", false, function(v)
		fogEnabled = v
		if v then enableFog() else disableFog() end
	end)
	addColor(fogSet, "Fog Color", function(c)
		fogColor = c
		if fogEnabled then applyFogSettings() end
	end)
	addSlider(fogSet, "Density", 0, 10, 6, function(v)
		fogDensity = v / 10
		if fogEnabled then applyFogSettings() end
	end)

	local origFOV        = Camera.FieldOfView

	-- FOV: только собственный RenderStep hook; Camera:Interpolate не блокируется
	RunService:BindToRenderStep("BurmaldaHookFOV", Enum.RenderPriority.First.Value, function()
		if Runtime.Unloaded or not fovLockEnabled then return end
		Camera.FieldOfView = targetFOV
	end)
	onCleanup(function()
		fovLockEnabled = false
		RunService:UnbindFromRenderStep("BurmaldaHookFOV")
		Camera.FieldOfView = origFOV
	end)

	-- Доп. хук на изменение свойства
	Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
		if fovLockEnabled and Camera.FieldOfView ~= targetFOV then
			Camera.FieldOfView = targetFOV
		end
	end)

	local fovLockSet = createFeature(rc, "Custom FOV", false, function(v)
		fovLockEnabled = v
		if not v then Camera.FieldOfView = origFOV end
	end)
	addSlider(fovLockSet, "FOV Value", 30, 120, 90, function(v)
		targetFOV = v
	end)
	addBind(fovLockSet, "Toggle Bind", "None", function()
		fovLockEnabled = not fovLockEnabled
		if not fovLockEnabled then Camera.FieldOfView = origFOV end
	end)

	local nvEnabled = false
	local _nvOrig = {}

	local function enableNV()
		_nvOrig.Brightness     = _Lighting.Brightness
		_nvOrig.Ambient        = _Lighting.Ambient
		_nvOrig.OutdoorAmbient = _Lighting.OutdoorAmbient
		_nvOrig.ClockTime      = _Lighting.ClockTime
		_Lighting.Brightness     = 5
		_Lighting.Ambient        = Color3.fromRGB(180, 180, 180)
		_Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
		_Lighting.ClockTime      = 14
	end

	local function disableNV()
		if _nvOrig.Brightness ~= nil then
			_Lighting.Brightness     = _nvOrig.Brightness
			_Lighting.Ambient        = _nvOrig.Ambient
			_Lighting.OutdoorAmbient = _nvOrig.OutdoorAmbient
			_Lighting.ClockTime      = _nvOrig.ClockTime
			_nvOrig = {}
		end
	end

	onCleanup(function() nvEnabled = false; disableNV() end)
	local nvSet = createFeature(rc, "Night Vision", false, function(v)
		nvEnabled = v
		if v then
			if fogEnabled then disableFog() end
			enableNV()
		else
			disableNV()
			if fogEnabled then enableFog() end
		end
	end, false)

	-- Custom Hand Position
	local ViewmodelConfig = { X = 0, Y = 0, Z = 0 }
	local handPosEnabled = false
	local handPosConn = nil
	local handPosLastVM = nil
	local handPosApplied = CFrame.new()

	local function getViewmodel()
		for _, obj in ipairs(Camera:GetChildren()) do
			if obj:IsA("Model") and (obj.Name:lower():find("view") or obj.Name:lower():find("arm") or obj.Name:lower():find("hand")) then
				return obj
			end
		end
		for _, obj in ipairs(workspace:GetChildren()) do
			if obj:IsA("Model") and obj.Name:lower():find("viewmodel") then
				return obj
			end
		end
		return nil
	end

	local function startHandPos()
		if handPosConn then handPosConn:Disconnect(); handPosConn = nil end
		handPosConn = RunService.RenderStepped:Connect(function()
			if Runtime.Unloaded then return end
			local vm = getViewmodel()
			if vm ~= handPosLastVM then
				handPosLastVM = vm
				handPosApplied = CFrame.new()
			end
			if handPosEnabled and vm then
				local desired = CFrame.new(ViewmodelConfig.X, ViewmodelConfig.Y, ViewmodelConfig.Z)
				vm:PivotTo(vm:GetPivot() * handPosApplied:Inverse() * desired)
				handPosApplied = desired
			else
				handPosApplied = CFrame.new()
			end
		end)
	end
	startHandPos()
	onCleanup(function()
		handPosEnabled = false
		if handPosConn then handPosConn:Disconnect(); handPosConn = nil end
	end)

	local handSet = createFeature(lc, "Custom Hand Position", false, function(v)
		handPosEnabled = v
		if not v then
			ViewmodelConfig.X = 0
			ViewmodelConfig.Y = 0
			ViewmodelConfig.Z = 0
		end
	end)
	addSlider(handSet, "X (Лево/Право)", -50, 50, 0, function(v)
		ViewmodelConfig.X = v / 10
	end)
	addSlider(handSet, "Y (Низ/Верх)", -50, 50, 0, function(v)
		ViewmodelConfig.Y = v / 10
	end)
	addSlider(handSet, "Z (Назад/Вперёд)", -50, 50, 0, function(v)
		ViewmodelConfig.Z = v / 10
	end)

end

do
	local NA = Color3.fromRGB(255,255,255)
	local NB = Color3.fromRGB(0,0,0)
	local NT = 2.5

	local nGui = newScreenGui(pGui)
	nGui.Name = "BurmaldaHookPickup"; nGui.DisplayOrder = 9999; nGui.ResetOnSpawn = false

	local cont = Instance.new("Frame",nGui)
	local _isPC = Camera.ViewportSize.X >= 1024
	cont.Size = UDim2.new(0, _isPC and 440 or 220, 0.9, 0)
	cont.Position = UDim2.new(1,-10,1,-10)
	cont.AnchorPoint = Vector2.new(1,1)
	cont.BackgroundTransparency = 1
	local cList = Instance.new("UIListLayout",cont)
	cList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	cList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	cList.Padding = UDim.new(0,3)

	local function notify(msg)
		if not PickupNotifEnabled then return end
		local f = Instance.new("Frame",cont)
		f.BackgroundColor3 = NB; f.BackgroundTransparency = 1
		f.AutomaticSize = Enum.AutomaticSize.XY; f.ClipsDescendants = true
		Instance.new("UICorner",f).CornerRadius = UDim.new(0,4)
		local c = Instance.new("Frame",f)
		c.BackgroundTransparency = 1; c.AutomaticSize = Enum.AutomaticSize.XY
		local cl = Instance.new("UIListLayout",c)
		cl.FillDirection = Enum.FillDirection.Horizontal
		cl.VerticalAlignment = Enum.VerticalAlignment.Center; cl.Padding = UDim.new(0,4)
		local cp = Instance.new("UIPadding",c)
		cp.PaddingLeft=UDim.new(0,8);cp.PaddingRight=UDim.new(0,8)
		cp.PaddingTop=UDim.new(0,3);cp.PaddingBottom=UDim.new(0,3)
		local ico = Instance.new("ImageLabel",c)
		local _ps = Camera.ViewportSize.X >= 1024
		ico.Size=UDim2.new(0,_ps and 26 or 13,0,_ps and 26 or 13);ico.BackgroundTransparency=1
		ico.Image="rbxassetid://17824303745";ico.ImageTransparency=1
		local sep = Instance.new("TextLabel",c)
		sep.BackgroundTransparency=1;sep.TextColor3=NA;sep.TextTransparency=1
		local _pts = Camera.ViewportSize.X >= 1024
		sep.Font=Enum.Font.GothamBold;sep.TextSize=_pts and 20 or 10;sep.Text="|";sep.Size=UDim2.new(0,_pts and 12 or 6,0,_pts and 24 or 12)
		local txt = Instance.new("TextLabel",c)
		txt.BackgroundTransparency=1;txt.TextColor3=NA;txt.TextTransparency=1
		txt.Font=Enum.Font.GothamBold;txt.TextSize=Camera.ViewportSize.X >= 1024 and 20 or 10
		txt.Text=msg;txt.AutomaticSize=Enum.AutomaticSize.XY
		local bar = Instance.new("Frame",f)
		bar.Size=UDim2.new(1,0,0,1);bar.Position=UDim2.new(0,0,1,0)
		bar.AnchorPoint=Vector2.new(0,1);bar.BackgroundColor3=NA;bar.BorderSizePixel=0
		f.Position=UDim2.new(0,30,0,0)
		TS:Create(f,TweenInfo.new(0.25),{Position=UDim2.new(0,0,0,0),BackgroundTransparency=0.25}):Play()
		TS:Create(ico,TweenInfo.new(0.25),{ImageTransparency=0}):Play()
		TS:Create(sep,TweenInfo.new(0.25),{TextTransparency=0}):Play()
		TS:Create(txt,TweenInfo.new(0.25),{TextTransparency=0}):Play()
		local bt = TS:Create(bar,TweenInfo.new(NT),{Size=UDim2.new(0,0,0,1)})
		task.delay(0.2,function() bt:Play() end)
		bt.Completed:Connect(function()
			local o=TS:Create(f,TweenInfo.new(0.25),{Position=UDim2.new(1,20,0,0),BackgroundTransparency=1})
			o:Play(); o.Completed:Connect(function() f:Destroy() end)
		end)
	end

	task.spawn(function()
		while true do
		if Runtime.Unloaded then break end
			if PickupNotifEnabled then
				local ai = pGui:FindFirstChild("AddInfo")
				if ai then

					for _,ch in ipairs(ai:GetChildren()) do
						if ch:IsA("TextLabel") and ch.Name=="Example" and ch.Text~="" then
							local t=ch.Text; ch.Text=""; notify(t)
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)
end

local circle = newDrawing("Circle")
circle.Radius = S.FOV
circle.Thickness = 1
circle.Color = AC
circle.Transparency = 1
circle.Filled = false
circle.Visible = S.FOVCircle

local circleFill = newDrawing("Circle")
circleFill.Radius = S.FOV
circleFill.Thickness = 0
circleFill.Color = AC_FOV_FILL
circleFill.Transparency = 0.85
circleFill.Filled = true
circleFill.Visible = false

local TargetLine = newDrawing("Line")
TargetLine.Visible = false
TargetLine.Color = S.MBTargetLineColor
TargetLine.Thickness = 1
TargetLine.Transparency = 1

local ESPBoxes, TracerObjs, NameObjs, DistObjs, ESPCorners, ESPFills, HPBars = {}, {}, {}, {}, {}, {}, {}

local function newLine(col)
	local l = newDrawing("Line"); l.Color = col or AC; l.Thickness = 1; return l
end

local function createESP(p)
	if Runtime.Unloaded then return end
	local box = newDrawing("Square")
	box.Color = AC; box.Thickness = 1; box.Filled = false
	local fill = newDrawing("Square")
	fill.Color = AC; fill.Thickness = 0; fill.Filled = true; fill.Transparency = 0.7; fill.Visible = false
	local corners = {}
	for i = 1, 12 do
		local l = newDrawing("Line"); l.Color = AC; l.Thickness = 1; l.Visible = false
		table.insert(corners, l)
	end
	local t1 = newDrawing("Line"); t1.Color = AC; t1.Thickness = 1
	local t2 = newDrawing("Line"); t2.Color = AC; t2.Thickness = 1
	local name = newDrawing("Text")
	name.Size = 12; name.Center = true; name.Outline = true; name.Color = AC
	local dist = newDrawing("Text")
	dist.Size = 11; dist.Center = true; dist.Outline = true; dist.Color = AC; dist.Visible = false

	local hpBg = newDrawing("Square"); hpBg.Filled = true; hpBg.Color = Color3.fromRGB(0,0,0); hpBg.Transparency = 0.5; hpBg.Visible = false
	local hpFg = newDrawing("Square"); hpFg.Filled = true; hpFg.Color = Color3.fromRGB(255,255,255); hpFg.Transparency = 1; hpFg.Visible = false
	ESPBoxes[p] = box; ESPFills[p] = fill; ESPCorners[p] = corners
	TracerObjs[p] = {t1, t2}; NameObjs[p] = name; DistObjs[p] = dist
	HPBars[p] = {bg = hpBg, fg = hpFg}
end

local function w2sv(part)
	local p3 = Camera:WorldToViewportPoint(part.Position)
	return Vector2.new(p3.X, p3.Y)
end

local function drawESPBox(player, sp, hrp, col)
	local top3 = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
	local bot3 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
	local sy = math.abs(top3.Y - bot3.Y)
	local sx = sy * 0.6
	local box = ESPBoxes[player]
	box.Size = Vector2.new(sx, sy)
	box.Position = Vector2.new(sp.X - sx/2, sp.Y - sy/2)
	box.Color = col; box.Visible = true
	for _, l in ipairs(ESPCorners[player]) do l.Visible = false end

	local fill = ESPFills[player]
	if S.BoxFill then
		fill.Size = Vector2.new(sx, sy)
		fill.Position = Vector2.new(sp.X - sx/2, sp.Y - sy/2)
		fill.Color = AC_FILL
		fill.Transparency = S.BoxFillTransparency
		fill.Visible = true
	else
		fill.Visible = false
	end
end

local function drawTracers(player, sp, col, center, ss)
	local t1 = TracerObjs[player][1]
	local t2 = TracerObjs[player][2]
	local fromY
	if S.TracerOrigin == 1 then fromY = 0
	elseif S.TracerOrigin == 2 then fromY = ss.Y
	else fromY = center.Y end
	t1.From = Vector2.new(center.X, fromY)
	t1.To = sp; t1.Color = col; t1.Visible = true
	t2.Visible = false
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if not Runtime.Unloaded then createESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
	if ESPBoxes[p] then ESPBoxes[p]:Remove() end
	if ESPFills[p] then ESPFills[p]:Remove() end
	if NameObjs[p] then NameObjs[p]:Remove() end
	if DistObjs[p] then DistObjs[p]:Remove() end
	if TracerObjs[p] then for _, l in ipairs(TracerObjs[p]) do l:Remove() end end
	if HPBars[p] then HPBars[p].bg:Remove(); HPBars[p].fg:Remove() end
	for _, l in ipairs(ESPCorners[p] or {}) do l:Remove() end
	ESPBoxes[p]=nil; ESPFills[p]=nil; ESPCorners[p]=nil; TracerObjs[p]=nil; NameObjs[p]=nil; DistObjs[p]=nil; HPBars[p]=nil

	if p.Character then
		local head = p.Character:FindFirstChild("Head")
		if head then _visCache[head]=nil; _visCacheTime[head]=nil end
	end
end)

local SA_CurrentTarget = nil
local _espLastUpdate = 0
local _ESP_INTERVAL = 1/30

local espConnection
espConnection = RunService.Heartbeat:Connect(function()
	if Runtime.Unloaded then return end
	local now = tick()
	if now - _espLastUpdate < _ESP_INTERVAL then return end
	_espLastUpdate = now

	local ss     = Camera.ViewportSize
	local center = Vector2.new(ss.X * 0.5, ss.Y * 0.5)
	local camCF  = Camera.CFrame
	local camPos = camCF.Position
	local fovPos = S.MBFovMode == "pc"
		and game:GetService("UserInputService"):GetMouseLocation()
		or center

	if S.FOVCircle then
		circle.Visible  = true
		circle.Position = fovPos
		circle.Radius   = S.FOV
		circle.Color    = AC_FOV
		circleFill.Visible      = S.FOVFill
		circleFill.Position     = fovPos
		circleFill.Radius       = S.FOV
		circleFill.Color        = AC_FOV_FILL
		circleFill.Transparency = S.FOVFillTransparency
	else
		circle.Visible     = false
		circleFill.Visible = false
	end

	local espEnabled  = S.ESPEnabled
	local tracersOn   = S.Tracers
	local namesOn     = S.Names
	local hpBarOn     = S.HPBar
	local espRadius   = S.ESPRadius

	if not espEnabled and not tracersOn and not namesOn and not hpBarOn then
		for player, box in pairs(ESPBoxes) do
			box.Visible = false
			if ESPFills[player] then ESPFills[player].Visible = false end
			TracerObjs[player][1].Visible = false; TracerObjs[player][2].Visible = false
			NameObjs[player].Visible = false
			if DistObjs[player] then DistObjs[player].Visible = false end
			if HPBars[player] then HPBars[player].bg.Visible = false; HPBars[player].fg.Visible = false end
		end
		return
	end

	for player, box in pairs(ESPBoxes) do
		local char = player.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		local hum  = char and char:FindFirstChild("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then
			box.Visible = false
			if ESPFills[player] then ESPFills[player].Visible = false end
			for _, l in ipairs(ESPCorners[player]) do l.Visible = false end
			TracerObjs[player][1].Visible = false
			TracerObjs[player][2].Visible = false
			NameObjs[player].Visible = false
			if DistObjs[player] then DistObjs[player].Visible = false end
			if HPBars[player] then HPBars[player].bg.Visible = false; HPBars[player].fg.Visible = false end
			continue
		end

		local hrpPos = hrp.Position
		local dist3D = (camPos - hrpPos).Magnitude

		local inESPRange = dist3D <= espRadius
		if not inESPRange and not tracersOn then
			box.Visible = false
			if ESPFills[player] then ESPFills[player].Visible = false end
			TracerObjs[player][1].Visible = false; TracerObjs[player][2].Visible = false
			NameObjs[player].Visible = false
			if DistObjs[player] then DistObjs[player].Visible = false end
			if HPBars[player] then HPBars[player].bg.Visible = false; HPBars[player].fg.Visible = false end
			continue
		end

		local pos3, onScreen = Camera:WorldToViewportPoint(hrpPos)
		local sp = Vector2.new(pos3.X, pos3.Y)

		local head   = char:FindFirstChild("Head")
		local espCol = AC_ESP

		if onScreen then
			local sy, sx
			local needBox = (espEnabled and inESPRange) or (namesOn and inESPRange) or (hpBarOn and inESPRange) or (S.ESPDist and inESPRange)
			if needBox then
				local top3 = Camera:WorldToViewportPoint(hrpPos + Vector3.new(0,3,0))
				local bot3 = Camera:WorldToViewportPoint(hrpPos - Vector3.new(0,3,0))
				sy = math.abs(top3.Y - bot3.Y)
				sx = sy * 0.6
			end

			if espEnabled and inESPRange then
				local box2 = ESPBoxes[player]
				box2.Size = Vector2.new(sx, sy)
				box2.Position = Vector2.new(sp.X - sx*0.5, sp.Y - sy*0.5)
				box2.Color = espCol; box2.Visible = true
				for _, l in ipairs(ESPCorners[player]) do l.Visible = false end
				local fill = ESPFills[player]
				if S.BoxFill then
					fill.Size = Vector2.new(sx, sy)
					fill.Position = Vector2.new(sp.X - sx*0.5, sp.Y - sy*0.5)
					fill.Color = AC_FILL
					fill.Transparency = S.BoxFillTransparency
					fill.Visible = true
				else
					fill.Visible = false
				end
			else
				box.Visible = false
				if ESPFills[player] then ESPFills[player].Visible = false end
				for _, l in ipairs(ESPCorners[player]) do l.Visible = false end
			end

			if tracersOn and inESPRange then
				drawTracers(player, sp, AC_TR, center, ss)
			else
				TracerObjs[player][1].Visible = false
				TracerObjs[player][2].Visible = false
			end

			if inESPRange and namesOn then
				NameObjs[player].Text     = player.Name
				NameObjs[player].Position = Vector2.new(sp.X, sp.Y - sy * 0.5 - 12)
				NameObjs[player].Color    = AC_NAME
				NameObjs[player].Visible  = true
			else
				NameObjs[player].Visible = false
			end

			if inESPRange and S.ESPDist then
				local sy2 = sy or 40
				DistObjs[player].Text     = math.floor(dist3D) .. " m"
				DistObjs[player].Position = Vector2.new(sp.X, sp.Y + sy2 * 0.5 + 4)
				DistObjs[player].Color    = AC_DIST
				DistObjs[player].Visible  = true
			else
				DistObjs[player].Visible = false
			end

			if hpBarOn and inESPRange and HPBars[player] then
				local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
				local barW = 3
				local hpBg = HPBars[player].bg
				local hpFg = HPBars[player].fg
				if S.HPBarSide == 1 then
					local bx = sp.X - sx*0.5 - barW - 2
					local by = sp.Y - sy*0.5
					hpBg.Size = Vector2.new(barW, sy)
					hpBg.Position = Vector2.new(bx, by)
					hpFg.Size = Vector2.new(barW, sy * hpRatio)
					hpFg.Position = Vector2.new(bx, by + sy * (1 - hpRatio))
				else
					local bx = sp.X - sx*0.5
					local by = sp.Y - sy*0.5 - barW - 2
					hpBg.Size = Vector2.new(sx, barW)
					hpBg.Position = Vector2.new(bx, by)
					hpFg.Size = Vector2.new(sx * hpRatio, barW)
					hpFg.Position = Vector2.new(bx, by)
				end
				hpBg.Visible = true
				hpFg.Color   = AC_HP
				hpFg.Visible = true
			else
				if HPBars[player] then
					HPBars[player].bg.Visible = false
					HPBars[player].fg.Visible = false
				end
			end

		else
			box.Visible = false
			if ESPFills[player] then ESPFills[player].Visible = false end
			for _, l in ipairs(ESPCorners[player]) do l.Visible = false end
			TracerObjs[player][1].Visible = false
			TracerObjs[player][2].Visible = false
			NameObjs[player].Visible = false
			if DistObjs[player] then DistObjs[player].Visible = false end
			if HPBars[player] then HPBars[player].bg.Visible = false; HPBars[player].fg.Visible = false end
		end
	end

	if S.MBTargetLine and SA_CurrentTarget then
		local targetPos = Camera:WorldToViewportPoint(SA_CurrentTarget.Position)
		TargetLine.From = fovPos
		TargetLine.To = Vector2.new(targetPos.X, targetPos.Y)
		TargetLine.Color = S.MBTargetLineColor
		TargetLine.Visible = true
	else
		TargetLine.Visible = false
	end
end)
onCleanup(function() if espConnection then espConnection:Disconnect() end end)

-- Burmalda Next projectile/stack/packet path adapted to the new UI.
-- This is a compatibility integration; live rost alpha verification is still required.
local projectileInitOK, projectileInitError = pcall(function()
	ProjectileCore = {
		Running = true,
		Env = _burmaldaEnv,
		Players = Players,
		ReplicatedStorage = ReplicatedStorage,
		Workspace = workspace,
		LocalPlayer = LocalPlayer,
		Flags = { ["SilentAim Activation"] = { Active = true } },
		Status = {
			projectile = false, packet = false, recoil = false, bolt = false, toolinfo = false,
			target = "inactive", projectileCalls = 0, localShots = 0, stackWrites = 0,
			redirects = 0, packetWrites = 0, lastShotReason = "none", lastCaller = "none",
			lastStack = "not-scanned", lastPacket = "none", lastData = "none",
			lastError = "none", diagnosticFile = "not-saved",
		},
	}
	function ProjectileCore:Get(name)
		if name == "SilentAim" then return S.SilentAim end
		if name == "AlwaysTarget" then return true end
		if name == "FOVRadius" then return S.FOV end
		if name == "FOVColor" then return AC_FOV end
		if name == "VisualizeFOV" then return false end -- the new UI owns the visible circle
		if name == "SilentAimPart" then
			return S.MBTargetPart == 2 and "HumanoidRootPart" or "HeadHitbox"
		end
		if name == "VisibleCheck" then return S.MBVisibleOnly end
		if name == "RandomizeHitPart" then return S.MBTargetPart == 3 end
		if name == "TargetTeammates" then return false end
		if name == "TargetLine" then return false end -- the new UI owns the visible line
		if name == "TargetLineColor" then return S.MBTargetLineColor end
		if name == "PacketSilent" then return true end
		if name == "DropMultiplier" then return 1 end
		if name == "Prediction" then return 1 end
		-- No Force Hit, hitscan, wallbang, Reach or Instant Bullet flag is exposed here.
		if name == "InstantBullet" or name == "HitScan" or name == "ForcePenetration"
			or name == "WallbangPlus" or name == "Reach" then return false end
		return nil
	end
	function ProjectileCore:GetCamera()
		return workspace.CurrentCamera
	end
	function ProjectileCore:GetCharacter()
		return LocalPlayer.Character
	end
	function ProjectileCore:GetRoot()
		local character = LocalPlayer.Character
		return character and character:FindFirstChild("HumanoidRootPart") or nil
	end
	function ProjectileCore:Require(instance)
		return require(instance)
	end
	function ProjectileCore:AddCleanup(fn)
		onCleanup(fn)
	end

ProjectileSilent = (function(Core)
    local M = {
        TargetPart = nil,
        TargetPlayer = nil,
        TargetCharacter = nil,
        BulletStats = { speed = 1000, gravity = 0, range = 1000 },
        TTHShot = nil,
        Assigned = {},
        Installed = { Projectile = false, Packet = false, Reach = false },
        ModulePaths = { VFX = "missing", VectorUtil = "missing", RaycastUtil = "missing" },
        LastCaller = "none",
        GCStats = "not-scanned",
        VFXFunctionOnly = false,
        GCCache = { Time = 0, Values = nil },
        PenCache = { Time = 0, Items = {} },
    }
    local Modules, VFX, VectorUtil, RaycastUtil

    local function PathOf(instance)
        local parts, current = {}, instance
        for _ = 1, 10 do
            if not current then break end
            table.insert(parts, 1, tostring(current.Name))
            current = current.Parent
        end
        return table.concat(parts, "/")
    end

    local function RequireNamed(names)
        for _, name in ipairs(names) do
            local instance = Modules and Modules:FindFirstChild(name)
            instance = instance or Core.ReplicatedStorage:FindFirstChild(name, true)
            if instance then
                local loaded = Core:Require(instance)
                if type(loaded) == "table" then
                    return loaded, PathOf(instance)
                end
            end
        end
        if type(getloadedmodules) == "function" then
            local wanted = {}
            for _, name in ipairs(names) do wanted[name] = true end
            local ok, loadedModules = pcall(getloadedmodules)
            if ok and type(loadedModules) == "table" then
                for _, instance in pairs(loadedModules) do
                    if typeof(instance) == "Instance" and instance:IsA("ModuleScript") and wanted[instance.Name] then
                        local loaded = Core:Require(instance)
                        if type(loaded) == "table" then
                            return loaded, "getloadedmodules/" .. PathOf(instance)
                        end
                    end
                end
            end
        end
        return nil, "missing"
    end

    local function ResolveModules()
        Modules = Core.ReplicatedStorage:FindFirstChild("Modules") or Modules
        if type(VFX) ~= "table" or type(VFX.CreateProjectile) ~= "function" then
            VFX, M.ModulePaths.VFX = RequireNamed({ "VFXModule" })
        end
        if type(VectorUtil) ~= "table" or type(VectorUtil.FireRemote) ~= "function" then
            VectorUtil, M.ModulePaths.VectorUtil = RequireNamed({ "VectorUtil" })
        end
        if type(RaycastUtil) ~= "table" or type(RaycastUtil.Raycast) ~= "function" then
            RaycastUtil, M.ModulePaths.RaycastUtil = RequireNamed({ "roosterchickens", "RaycastUtil" })
        end
    end

    ResolveModules()

    local FOVCircle = newDrawing("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.NumSides = 80
    FOVCircle.Visible = false
    local TargetLine = newDrawing("Line")
    TargetLine.Thickness = 1
    TargetLine.Visible = false

    local function Active()
        if not Core:Get("SilentAim") then
            return false
        end
        if Core:Get("AlwaysTarget") then
            return true
        end
        local key = Core.Flags["SilentAim Activation"]
        return key and key.Active == true or false
    end

    local function HasLineOfSight(origin, destination, targetCharacter)
        if typeof(origin) ~= "Vector3" or typeof(destination) ~= "Vector3" then
            return false
        end
        local direction = destination - origin
        if direction.Magnitude < 0.1 then
            return true
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = { Core:GetCharacter() }
        local result = Core.Workspace:Raycast(origin, direction, params)
        if not result then
            return true
        end
        return targetCharacter and result.Instance and result.Instance:IsDescendantOf(targetCharacter) or false
    end

    local function IsTeammate(player)
        if player == Core.LocalPlayer then
            return false
        end
        if Core.LocalPlayer.Team ~= nil or player.Team ~= nil then
            return Core.LocalPlayer.Team ~= nil and player.Team == Core.LocalPlayer.Team
        end
        return Core.LocalPlayer.Neutral ~= true and player.Neutral ~= true
            and Core.LocalPlayer.TeamColor == player.TeamColor
    end

    local function SelectVisiblePart(character, preferred)
        local parts = {}
        for _, name in ipairs({ preferred, "Head", "UpperTorso", "HumanoidRootPart" }) do
            local part = character:FindFirstChild(name)
            if part then
                table.insert(parts, part)
            end
        end
        local camera = Core:GetCamera()
        if not camera then
            return nil
        end
        for _, part in ipairs(parts) do
            if part and part:IsA("BasePart") and HasLineOfSight(camera.CFrame.Position, part.Position, character) then
                return part
            end
        end
        return nil
    end

    local function UpdateTarget()
        local camera = Core:GetCamera()
        if not camera then
            M.TargetPart, M.TargetPlayer, M.TargetCharacter = nil, nil, nil
            Core.Env.BurmaldaTarget = nil
            Core.Status.target = "no-camera"
            FOVCircle.Visible = false
            TargetLine.Visible = false
            return
        end
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local radius = Core:Get("FOVRadius") or 250
        FOVCircle.Position = center
        FOVCircle.Radius = radius
        FOVCircle.Color = Core:Get("FOVColor") or Color3.new(1, 1, 1)
        FOVCircle.Visible = Core:Get("VisualizeFOV") and Core:Get("SilentAim") or false

        if not Active() then
            M.TargetPart, M.TargetPlayer, M.TargetCharacter = nil, nil, nil
            Core.Env.BurmaldaTarget = nil
            Core.Status.target = Core:Get("SilentAim") and "key-inactive" or "inactive"
            TargetLine.Visible = false
            return
        end

        local preferred = Core:Get("SilentAimPart") or "Head"
        local bestPart, bestPlayer, bestPoint = nil, nil, nil
        local bestDistance = radius * radius
        local sawOnscreen = false
        for _, player in ipairs(Core.Players:GetPlayers()) do
            if player ~= Core.LocalPlayer and (Core:Get("TargetTeammates") or not IsTeammate(player)) then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if character and humanoid and humanoid.Health > 0 then
                    local part = character:FindFirstChild(preferred)
                    if Core:Get("VisibleCheck") then
                        part = SelectVisiblePart(character, preferred)
                    end
                    if part then
                        local point, onscreen = camera:WorldToViewportPoint(part.Position)
                        if onscreen and point.Z > 0 then
                            sawOnscreen = true
                            local dx, dy = point.X - center.X, point.Y - center.Y
                            local distance = dx * dx + dy * dy
                            if distance <= bestDistance then
                                bestDistance = distance
                                bestPart, bestPlayer, bestPoint = part, player, point
                            end
                        end
                    end
                end
            end
        end

        if Core:Get("RandomizeHitPart") and bestPlayer and bestPlayer.Character then
            local candidates = {}
            for _, part in ipairs(bestPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and HasLineOfSight(camera.CFrame.Position, part.Position, bestPlayer.Character) then
                    table.insert(candidates, part)
                end
            end
            if #candidates > 0 then
                bestPart = candidates[math.random(1, #candidates)]
                bestPoint = camera:WorldToViewportPoint(bestPart.Position)
            end
        end

        M.TargetPart = bestPart
        M.TargetPlayer = bestPlayer
        M.TargetCharacter = bestPlayer and bestPlayer.Character or nil
        Core.Env.BurmaldaTarget = bestPart
        Core.Status.target = bestPart and "ok" or (sawOnscreen and "no-fov" or "no-onscreen")
        if bestPoint and Core:Get("TargetLine") then
            TargetLine.From = center
            TargetLine.To = Vector2.new(bestPoint.X, bestPoint.Y)
            TargetLine.Color = Core:Get("TargetLineColor") or Color3.new(1, 1, 1)
            TargetLine.Visible = true
        else
            TargetLine.Visible = false
        end
    end

    local function InstallHook(container, name, factory, allowAssignment)
        if type(container) ~= "table" then
            return false
        end
        local original = rawget(container, name) or container[name]
        if type(original) ~= "function" then
            return false
        end
        local callOriginal = original
        local replacement = factory(function(...)
            return callOriginal(...)
        end)
        local ok, old = pcall(function()
            if type(hookfunction) ~= "function" then
                return nil
            end
            return hookfunction(original, replacement)
        end)
        if ok and type(old) == "function" then
            callOriginal = old
            return true
        end
        if allowAssignment == false then
            return false
        end
        local assigned = pcall(function()
            container[name] = replacement
        end)
        if assigned and container[name] == replacement then
            table.insert(M.Assigned, { Table = container, Key = name, Original = original })
            return true
        end
        return false
    end

    local function IsLocalShot(data)
        if type(data) ~= "table" then
            return false
        end
        M.LastCaller = "not-resolved"
        if data.StepFunction == "FakeStepFunc" or data.HitFunction == "FakeHitFunc" or tostring(data.HitFunction):find("Ignore") then
            M.LastCaller = "fake-or-ignore"
            Core.Status.lastCaller = M.LastCaller
            return false
        end
        local callerName = ""
        pcall(function()
            local caller = getcallingscript and getcallingscript()
            if caller then
                callerName = caller.Name
            end
        end)
        if callerName == "" then
            pcall(function()
                callerName = tostring(debug.traceback())
            end)
        end
        M.LastCaller = callerName ~= "" and callerName or "unknown"
        Core.Status.lastCaller = M.LastCaller
        if callerName:find("ViewmodelController") or callerName:find("VFXController") then
            return true
        end
        local origin = data.Position or data.Origin
        local camera = Core:GetCamera()
        local root = Core:GetRoot()
        return typeof(origin) == "Vector3" and camera and ((origin - camera.CFrame.Position).Magnitude < 90
            or (root and (origin - root.Position).Magnitude < 90)) or false
    end

    local function IsBowShot()
        local vms = Core.Workspace:FindFirstChild("VFX") and Core.Workspace.VFX:FindFirstChild("VMs")
        local current = vms and vms:GetChildren()[1]
        return current and current.Name:lower():find("bow", 1, true) ~= nil or false
    end

    -- @STACK_CORE_BEGIN
    local function FindShotStack(getstack)
        local selected, selectedLevel, fallback, fallbackLevel = nil, 0, nil, 0
        local scan = {}
        for level = 2, 8 do
            local ok, candidate = pcall(getstack, level)
            if ok and type(candidate) == "table" then
                local cframes, vectors, recoil = 0, 0, nil
                for index = 1, 120 do
                    local value = rawget(candidate, index)
                    local kind = typeof(value)
                    if kind == "CFrame" then
                        cframes += 1
                    elseif kind == "Vector3" then
                        vectors += 1
                    elseif kind == "table" and rawget(value, "RecoilStart") and rawget(value, "RecoilFinish") then
                        recoil = value
                    end
                end
                table.insert(scan, string.format("%d:%dC/%dV/%s", level, cframes, vectors, recoil and "R" or "-"))
                if recoil and cframes >= 2 then
                    selected, selectedLevel = candidate, level
                    break
                end
                if not fallback and cframes >= 2 and vectors >= 1 then
                    fallback, fallbackLevel = candidate, level
                end
            end
        end
        if not selected then
            selected, selectedLevel = fallback, fallbackLevel
        end
        if not selected then
            Core.Status.lastStack = "not-found [" .. table.concat(scan, ",") .. "]"
            return nil
        end
        local cameraIndex, hrpIndex, flashIndex
        for index = 1, 80 do
            local kind = typeof(rawget(selected, index))
            if kind == "CFrame" then
                if not cameraIndex then cameraIndex = index elseif not hrpIndex then hrpIndex = index end
            elseif kind == "Vector3" and not flashIndex then
                flashIndex = index
            end
        end
        if not cameraIndex or not hrpIndex or not flashIndex then
            Core.Status.lastStack = string.format("indices-missing level=%d camera=%s hrp=%s flash=%s", selectedLevel, tostring(cameraIndex), tostring(hrpIndex), tostring(flashIndex))
            return nil
        end
        Core.Status.lastStack = string.format("level=%d camera=%d hrp=%d flash=%d", selectedLevel, cameraIndex, hrpIndex, flashIndex)
        return { Stack = selected, Level = selectedLevel, Camera = cameraIndex, HRP = hrpIndex, Flash = flashIndex }
    end
    -- @STACK_CORE_END

    local function IsBody(instance)
        local model = instance and instance.FindFirstAncestorOfClass and instance:FindFirstAncestorOfClass("Model")
        return model and model:FindFirstChildOfClass("Humanoid") ~= nil
    end

    local function PenWorldList()
        if os.clock() - M.PenCache.Time < 0.6 and #M.PenCache.Items > 0 then
            return M.PenCache.Items
        end
        local items = {}
        for _, child in ipairs(Core.Workspace:GetChildren()) do
            if (child:IsA("Folder") or child:IsA("Model")) and child.Name ~= "VFX" and child.Name ~= "Remotes"
                and not child:FindFirstChildOfClass("Humanoid") and not Core.Players:GetPlayerFromCharacter(child) then
                table.insert(items, child)
            end
        end
        M.PenCache.Time = os.clock()
        M.PenCache.Items = items
        return items
    end

    local function AddPenetration(list)
        if type(list) ~= "table" then
            list = {}
        elseif table.isfrozen and table.isfrozen(list) then
            list = table.clone(list)
        end
        local present = {}
        for _, value in ipairs(list) do
            present[value] = true
        end
        local terrain = Core.Workspace:FindFirstChildOfClass("Terrain")
        if terrain and not present[terrain] then
            table.insert(list, terrain)
            present[terrain] = true
        end
        for _, child in ipairs(PenWorldList()) do
            if not present[child] and child.Parent then
                table.insert(list, child)
                present[child] = true
            end
        end
        return list
    end

    local function FlatRoot(origin, destination)
        local frame = CFrame.lookAt(origin, destination)
        local _, yaw = frame:ToEulerAnglesYXZ()
        return CFrame.new(origin) * CFrame.fromEulerAnglesYXZ(0, yaw, 0)
    end

    local function GetGC()
        if type(getgc) ~= "function" then
            return {}
        end
        if M.GCCache.Values and os.clock() - M.GCCache.Time < 1 then
            return M.GCCache.Values
        end
        local ok, values = pcall(getgc, true)
        M.GCCache.Time = os.clock()
        M.GCCache.Values = ok and type(values) == "table" and values or {}
        return M.GCCache.Values
    end

    local function FindTableWithFunction(name)
        local tables, functions = 0, 0
        for _, value in pairs(GetGC()) do
            local kind = type(value)
            if kind == "table" then
                tables += 1
                if type(rawget(value, name)) == "function" then
                    M.GCStats = string.format("tables=%d functions=%d tableMatch=%s", tables, functions, name)
                    return value
                end
            elseif kind == "function" then
                functions += 1
            end
        end
        M.GCStats = string.format("tables=%d functions=%d tableMatch=none", tables, functions)
        return nil
    end

    local function FindProjectileFunction()
        local tables, functions = 0, 0
        local fallback, fallbackPath = nil, nil
        for _, value in pairs(GetGC()) do
            local kind = type(value)
            if kind == "table" then
                tables += 1
            elseif kind == "function" then
                functions += 1
                local ok, info = pcall(debug.getinfo, value)
                local name = ok and info and info.name or ""
                local source = ok and info and tostring(info.source or "") or ""
                local sourceLower = source:lower()
                if name == "CreateProjectile" and (source == "" or sourceLower:find("vfx") or sourceLower:find("projectile") or sourceLower:find("viewmodel")) then
                    M.GCStats = string.format("tables=%d functions=%d functionMatch=CreateProjectile", tables, functions)
                    return value, "getgc/function/" .. (source ~= "" and source or name)
                end
                if not fallback and sourceLower:find("vfxmodule", 1, true) and type(debug.getconstants) == "function" then
                    local constantsOK, constants = pcall(debug.getconstants, value)
                    if constantsOK and type(constants) == "table" then
                        for _, marker in ipairs({ "DirectionFirst", "MaxRange", "StepFunction", "HitFunction" }) do
                            if table.find(constants, marker) then
                                fallback = value
                                fallbackPath = "getgc/constants/" .. source .. "/" .. marker
                                break
                            end
                        end
                    end
                end
            end
        end
        if fallback then
            M.GCStats = string.format("tables=%d functions=%d functionMatch=constants", tables, functions)
            return fallback, fallbackPath
        end
        M.GCStats = string.format("tables=%d functions=%d functionMatch=none", tables, functions)
        return nil
    end

    local function InstallProjectile()
        if M.Installed.Projectile then
            return true
        end
        if type(VFX) ~= "table" or type(VFX.CreateProjectile) ~= "function" then
            VFX = FindTableWithFunction("CreateProjectile")
            if VFX then
                M.VFXFunctionOnly = false
                M.ModulePaths.VFX = "getgc/table/CreateProjectile"
            end
        end
        if (type(VFX) ~= "table" or type(VFX.CreateProjectile) ~= "function") and type(hookfunction) == "function" then
            local projectile, path = FindProjectileFunction()
            if projectile then
                VFX = { CreateProjectile = projectile }
                M.VFXFunctionOnly = true
                M.ModulePaths.VFX = path
            end
        end
        if type(VFX) ~= "table" or type(VFX.CreateProjectile) ~= "function" then
            Core.Status.projectile = false
            return false
        end
        Core.Status.projectile = InstallHook(VFX, "CreateProjectile", function(CallOriginal)
            return function(self, ...)
                if not Core.Running then
                    return CallOriginal(self, ...)
                end
                local args = { ... }
                local data = args[1]
                if type(data) ~= "table" then
                    Core.Status.lastShotReason = "non-table-data"
                    return CallOriginal(self, ...)
                end
                Core.Status.projectileCalls += 1
                Core.Status.lastData = string.format("speed=%s gravity=%s origin=%s range=%s step=%s hit=%s",
                    tostring(data.Speed), tostring(data.Gravity), typeof(data.Position or data.Origin),
                    tostring(data.MaxRange or data.Range), tostring(data.StepFunction), tostring(data.HitFunction))
                if IsBowShot() then
                    Core.Status.lastShotReason = "bow-skipped"
                    return CallOriginal(self, ...)
                end
                if not IsLocalShot(data) then
                    Core.Status.lastShotReason = "not-local"
                    return CallOriginal(self, ...)
                end
                Core.Status.localShots += 1
                Core.Status.lastShotReason = not Active() and "silent-inactive" or (M.TargetPart and "target-acquired" or "no-target")
                M.BulletStats = {
                    speed = tonumber(data.Speed) or 1000,
                    gravity = tonumber(data.Gravity) or 0,
                    range = tonumber(data.MaxRange or data.Range) or 1000,
                }

                if Active() and M.TargetPart and M.TargetPart.Parent then
                    if type(debug.getstack) == "function" and type(debug.setstack) == "function" then
                        local shot = FindShotStack(debug.getstack)
                        if shot then
                            local cameraStack = rawget(shot.Stack, shot.Camera)
                            local hrpStack = rawget(shot.Stack, shot.HRP)
                            local flashStack = rawget(shot.Stack, shot.Flash)
                            local root = Core:GetRoot()
                            local camera = Core:GetCamera()
                            local sane = camera ~= nil and typeof(cameraStack) == "CFrame" and typeof(hrpStack) == "CFrame" and typeof(flashStack) == "Vector3"
                            if sane and ((cameraStack.p - camera.CFrame.p).Magnitude > 60
                                or (root and (hrpStack.p - root.CFrame.p).Magnitude > 60)) then
                                sane = false
                            end
                            if sane then
                                local hitPosition = M.TargetPart.Position
                                if Core:Get("InstantBullet") and type(data.Speed) == "number" and data.Speed > 1 and type(data.Gravity) == "number" then
                                    local origin = typeof(data.Position) == "Vector3" and data.Position or camera.CFrame.Position
                                    local time = (hitPosition - origin).Magnitude / data.Speed
                                    local gravity = data.Gravity * -Core.Workspace.Gravity
                                    local drop = -0.5 * gravity * time * time
                                    if drop == drop then
                                        hitPosition += Vector3.new(0, drop, 0)
                                    end
                                end
                                local fakeCamera = CFrame.new(cameraStack.p, hitPosition)
                                local fakeHRP = CFrame.new(hrpStack.p, hitPosition)
                                local flashPosition = CFrame.new(flashStack, hitPosition).p
                                local cameraOK = pcall(debug.setstack, shot.Level, shot.Camera, fakeCamera)
                                local hrpOK = pcall(debug.setstack, shot.Level, shot.HRP, fakeHRP)
                                local flashOK = pcall(debug.setstack, shot.Level, shot.Flash, flashPosition)
                                local writes = (cameraOK and 1 or 0) + (hrpOK and 1 or 0) + (flashOK and 1 or 0)
                                Core.Status.stackWrites += writes
                                Core.Status.lastStack ..= " writes=" .. tostring(writes)
                                Core.Status.lastShotReason = writes == 3 and "stack-written" or "stack-write-failed"
                            else
                                Core.Status.lastShotReason = "stack-sanity"
                                Core.Status.lastStack ..= " sanity=failed"
                            end
                        else
                            Core.Status.lastShotReason = "stack-not-found"
                        end
                    else
                        Core.Status.lastShotReason = "stack-api-missing"
                        Core.Status.lastStack = "debug.getstack/setstack unavailable"
                    end
                end

                local instant = Core:Get("InstantBullet") or Core:Get("HitScan")
                if instant then
                    data.Speed = 9e9
                    data.Gravity = 0
                end
                local penetration = Core:Get("ForcePenetration") or Core:Get("HitScan") or Core:Get("WallbangPlus")
                if penetration then
                    data.RangeMult = 2
                    data.Filters = AddPenetration(data.Filters)
                    if type(data.FilterFunction) == "function" then
                        local previous = data.FilterFunction
                        data.FilterFunction = function(instance)
                            if IsBody(instance) then
                                return nil
                            end
                            return previous(instance) or instance
                        end
                    end
                end

                local target = M.TargetPart
                if target and target.Parent and Active() then
                    local hitPosition = target.Position
                    local origin = data.Position or data.Origin
                    local camera = Core:GetCamera()
                    if typeof(origin) ~= "Vector3" then
                        origin = camera.CFrame.Position
                    end
                    local speed, gravity = tonumber(data.Speed), tonumber(data.Gravity)
                    local aimPosition = hitPosition
                    if not instant and speed and speed > 1 and gravity and gravity > 0.01 then
                        local flightTime = (hitPosition - origin).Magnitude / speed
                        local drop = 0.5 * Core.Workspace.Gravity * gravity * flightTime * flightTime
                        if drop == drop and drop ~= math.huge then
                            aimPosition += Vector3.new(0, drop * (Core:Get("DropMultiplier") or 1), 0)
                        end
                        local velocity = target.AssemblyLinearVelocity
                        if typeof(velocity) == "Vector3" then
                            aimPosition += velocity * flightTime * (Core:Get("Prediction") or 1)
                        end
                    end
                    if HasLineOfSight(origin, hitPosition, M.TargetCharacter) or penetration then
                        local direction = aimPosition - origin
                        if direction.Magnitude > 0.05 then
                            local unitDirection = direction.Unit
                            data.Direction = unitDirection
                            data.DirectionFirst = unitDirection
                            local distance = (hitPosition - origin).Magnitude
                            local range = tonumber(data.MaxRange or data.Range)
                            if range and range < distance + 100 then
                                if data.MaxRange ~= nil then data.MaxRange = distance + 100 else data.Range = distance + 100 end
                            end
                            Core.Status.redirects += 1
                            Core.Status.lastShotReason = "redirected"
                            if Core:Get("PacketSilent") then
                                M.TTHShot = { dest = hitPosition, t = os.clock() }
                                Core.Status.lastPacket = "waiting"
                            else
                                Core.Status.lastPacket = "disabled"
                            end
                        else
                            Core.Status.lastShotReason = "direction-zero"
                        end
                    else
                        Core.Status.lastShotReason = "los-blocked"
                    end
                end
                return CallOriginal(self, unpack(args))
            end
        end, not M.VFXFunctionOnly)
        M.Installed.Projectile = Core.Status.projectile == true
        return M.Installed.Projectile
    end

    local function InstallPacket()
        if M.Installed.Packet then
            return true
        end
        if type(VectorUtil) ~= "table" or type(VectorUtil.FireRemote) ~= "function" then
            VectorUtil = FindTableWithFunction("FireRemote")
            if VectorUtil then
                M.ModulePaths.VectorUtil = "getgc/table/FireRemote"
            end
        end
        if type(VectorUtil) ~= "table" or type(VectorUtil.FireRemote) ~= "function" then
            Core.Status.packet = false
            return false
        end
        Core.Status.packet = InstallHook(VectorUtil, "FireRemote", function(CallOriginal)
            return function(self, ...)
                local args = { ... }
                if Core.Running then
                    local shot = M.TTHShot
                    Core.Status.lastPacket = "none-staged"
                    if shot then
                        if typeof(shot.dest) ~= "Vector3" or os.clock() - shot.t >= 0.25 then
                            Core.Status.lastPacket = "stale"
                        else
                            local matched = false
                            for index = #args, 1, -1 do
                                local payload = args[index]
                                if type(payload) == "table" and #payload >= 8 and typeof(payload[2]) == "string"
                                    and typeof(payload[3]) == "CFrame" and typeof(payload[4]) == "Vector3"
                                    and typeof(payload[5]) == "CFrame" and typeof(payload[8]) == "Vector3" then
                                    matched = true
                                    if HasLineOfSight(payload[3].Position, shot.dest, M.TargetCharacter)
                                        or Core:Get("ForcePenetration") or Core:Get("HitScan") or Core:Get("WallbangPlus") then
                                        payload[3] = CFrame.new(payload[3].Position, shot.dest)
                                        payload[5] = FlatRoot(payload[5].Position, shot.dest)
                                        payload[8] = shot.dest
                                        Core.Status.packetWrites += 1
                                        Core.Status.lastPacket = "written"
                                        Core.Status.lastShotReason = "packet-written"
                                    else
                                        Core.Status.lastPacket = "los-blocked"
                                    end
                                    break
                                end
                            end
                            if not matched then
                                local signatures = {}
                                for index = math.max(1, #args - 3), #args do
                                    local payload = args[index]
                                    if type(payload) == "table" then
                                        local fields = {}
                                        for field = 1, math.min(#payload, 12) do
                                            table.insert(fields, typeof(payload[field]))
                                        end
                                        if #fields == 0 then
                                            local count = 0
                                            for key, value in pairs(payload) do
                                                table.insert(fields, tostring(key) .. "=" .. typeof(value))
                                                count += 1
                                                if count >= 8 then break end
                                            end
                                        end
                                        table.insert(signatures, string.format("arg%d#%d:%s", index, #payload, table.concat(fields, ",")))
                                    else
                                        table.insert(signatures, "arg" .. tostring(index) .. "=" .. typeof(payload))
                                    end
                                end
                                Core.Status.lastPacket = "payload-mismatch [" .. table.concat(signatures, ";") .. "]"
                            end
                        end
                    end
                    M.TTHShot = nil
                end
                return CallOriginal(self, unpack(args))
            end
        end)
        M.Installed.Packet = Core.Status.packet == true
        return M.Installed.Packet
    end

    local function InstallReach()
        if M.Installed.Reach then
            return true
        end
        if type(RaycastUtil) ~= "table" or type(RaycastUtil.Raycast) ~= "function" then
            return false
        end
        M.Installed.Reach = InstallHook(RaycastUtil, "Raycast", function(CallOriginal)
            return function(self, ...)
                local args = { ... }
                if Core.Running and Core:Get("Reach") and typeof(args[2]) == "Vector3" then
                    local trace = debug.traceback()
                    if trace:find("ViewmodelController") or trace:find("VFXController") then
                        args[2] *= 10
                    end
                end
                return CallOriginal(self, unpack(args))
            end
        end)
        M.Installed.Reach = M.Installed.Reach == true
        return M.Installed.Reach
    end

    function M.Refresh(force)
        if not force and M.Installed.Projectile and M.Installed.Packet and M.Installed.Reach then
            return true
        end
        ResolveModules()
        InstallProjectile()
        InstallPacket()
        InstallReach()
        return M.Installed.Projectile and M.Installed.Packet or false
    end

    M.Refresh(true)
    Core:AddCleanup(function()
        M.TargetPart, M.TargetPlayer, M.TargetCharacter = nil, nil, nil
        M.TTHShot = nil
        Core.Env.BurmaldaTarget = nil
        pcall(function() FOVCircle:Remove() end)
        pcall(function() TargetLine:Remove() end)
        for _, record in ipairs(M.Assigned) do
            pcall(function()
                record.Table[record.Key] = record.Original
            end)
        end
    end)

    local function RelevantModule(name)
        local lower = tostring(name):lower()
        return lower:find("vfx", 1, true) or lower:find("projectile", 1, true) or lower:find("vector", 1, true)
            or lower:find("raycast", 1, true) or lower:find("toolinfo", 1, true) or lower:find("chicken", 1, true)
            or lower:find("recoil", 1, true) or lower:find("gun", 1, true) ~= nil
    end

    function M.ScanDiscovery()
        local result = { ModuleScripts = {}, LoadedModules = {}, GCCandidates = {}, GCStats = M.GCStats }
        pcall(function()
            for _, instance in ipairs(Core.ReplicatedStorage:GetDescendants()) do
                if instance:IsA("ModuleScript") and RelevantModule(instance.Name) then
                    table.insert(result.ModuleScripts, PathOf(instance))
                    if #result.ModuleScripts >= 40 then break end
                end
            end
        end)
        if type(getloadedmodules) == "function" then
            pcall(function()
                for _, instance in pairs(getloadedmodules()) do
                    if typeof(instance) == "Instance" and instance:IsA("ModuleScript") and RelevantModule(instance.Name) then
                        table.insert(result.LoadedModules, PathOf(instance))
                        if #result.LoadedModules >= 40 then break end
                    end
                end
            end)
        end
        local inspected, scanned = 0, 0
        for _, value in pairs(GetGC()) do
            scanned += 1
            if type(value) == "table" then
                for _, name in ipairs({ "CreateProjectile", "FireRemote", "Raycast" }) do
                    if type(rawget(value, name)) == "function" then
                        table.insert(result.GCCandidates, "table/" .. name)
                    end
                end
            elseif type(value) == "function" and inspected < 1500 then
                inspected += 1
                local ok, info = pcall(debug.getinfo, value)
                local name = ok and info and tostring(info.name or "") or ""
                local source = ok and info and tostring(info.source or "") or ""
                if name == "CreateProjectile" or name == "FireRemote" or source:lower():find("vfxmodule", 1, true) then
                    table.insert(result.GCCandidates, "function/" .. name .. "@" .. source)
                end
            end
            if #result.GCCandidates >= 40 or scanned >= 10000 then break end
        end
        result.GCStats = tostring(result.GCStats) .. " discoveryScanned=" .. tostring(scanned)
        return result
    end

    function M.GetDiagnostics()
        return {
            modulePaths = M.ModulePaths,
            installed = M.Installed,
            target = M.TargetPart,
            caller = M.LastCaller,
            gcStats = M.GCStats,
        }
    end

    M.Update = UpdateTarget
    M.Active = Active
    M.HasLineOfSight = HasLineOfSight
    return M
end)(ProjectileCore)

	Runtime.Projectile = ProjectileSilent
	Runtime.ProjectileStatus = ProjectileCore.Status
	Runtime.ProjectilePath = "VFX.CreateProjectile + VectorUtil.FireRemote"
	Runtime.GetSilentStatus = function()
		local status = ProjectileCore and ProjectileCore.Status or {}
		return {
			path = Runtime.SilentPath,
			projectile = status.projectile == true,
			packet = status.packet == true,
			target = status.target,
			lastShotReason = status.lastShotReason,
			lastStack = status.lastStack,
			lastPacket = status.lastPacket,
			error = Runtime.ProjectileError,
		}
	end
	onCleanup(function()
		if ProjectileCore then ProjectileCore.Running = false end
	end)
end)
if not projectileInitOK then
	Runtime.ProjectileError = tostring(projectileInitError)
	Runtime.ProjectileStatus = ProjectileCore and ProjectileCore.Status or nil
	ProjectileSilent = nil
end
if not Runtime.GetSilentStatus then
	Runtime.GetSilentStatus = function()
		return { path = Runtime.SilentPath, projectile = false, packet = false, error = Runtime.ProjectileError }
	end
end


task.spawn(function()
	while task.wait(0.05) do
		if Runtime.Unloaded then break end
		if ProjectileSilent then pcall(function() ProjectileSilent.Update() end) end
		if not S.SilentAim and not S.MBTargetLine then SA_CurrentTarget = nil; continue end
		local target = nil
		local shortestDistance = S.FOV
		local lowestHP = math.huge
		local camCF2 = Camera.CFrame
		local camPos2 = camCF2.Position
		local vp = Camera.ViewportSize
		local center = S.MBFovMode == "pc"
			and game:GetService("UserInputService"):GetMouseLocation()
			or Vector2.new(vp.X * 0.5, vp.Y * 0.5)
		local partName = S.MBTargetPart == 1 and "HeadHitbox" or S.MBTargetPart == 2 and "HumanoidRootPart" or nil
		local priority = S.MBPriority

		-- при приоритете HP сначала собираем всех в FOV, потом выбираем
		local candidates = {}
		for _, v in ipairs(Players:GetPlayers()) do
			if v == LocalPlayer then continue end
			local char = v.Character
			if not char then continue end
			local pn = partName or (math.random(2) == 1 and "HeadHitbox" or "HumanoidRootPart")
			local root = char:FindFirstChild(pn) or char:FindFirstChild("HeadHitbox") or char:FindFirstChild("Head")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not root or not hum or hum.Health <= 0 then continue end
			if (root.Position - camPos2).Magnitude > S.MBMaxDist then continue end
			if S.MBVisibleOnly and not isVisible(root, char) then continue end
			local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local distance = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if distance < S.FOV then
					table.insert(candidates, {root = root, hum = hum, dist = distance})
				end
			end
		end

		if priority == "hp" and #candidates > 0 then
			-- ищем с минимальным HP, при равном — ближайшего
			for _, c in ipairs(candidates) do
				local hp = c.hum.Health
				if hp < lowestHP or (hp == lowestHP and c.dist < shortestDistance) then
					lowestHP = hp
					shortestDistance = c.dist
					target = c.root
				end
			end
		else
			-- приоритет distance — ближайший в FOV
			for _, c in ipairs(candidates) do
				if c.dist < shortestDistance then
					shortestDistance = c.dist
					target = c.root
				end
			end
		end
		if ProjectileSilent and S.SilentAim and ProjectileSilent.TargetPart then
			target = ProjectileSilent.TargetPart
		end
		if target and math.random(100) > S.MBHitChance then
			target = nil
			if ProjectileSilent then
				ProjectileSilent.TargetPart = nil
				ProjectileSilent.TargetPlayer = nil
				ProjectileSilent.TargetCharacter = nil
			end
		end
		SA_CurrentTarget = target
	end
end)

local speedRostConn = nil
local function startSpeedRost()
	if speedRostConn then speedRostConn:Disconnect(); speedRostConn = nil end
	speedRostConn = RunService.Heartbeat:Connect(function()
		if Runtime.Unloaded or not S.SpeedRostAlpha then return end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 and hum.WalkSpeed ~= S.SpeedRostValue then
			hum.WalkSpeed = S.SpeedRostValue
		end
	end)
	onCleanup(function()
		if speedRostConn then speedRostConn:Disconnect(); speedRostConn = nil end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end)
end
startSpeedRost()

local spiderConn = nil
local spiderParams = RaycastParams.new()
spiderParams.FilterType = Enum.RaycastFilterType.Exclude
local _spiderOffsets = {Vector3.new(0,-1.6,0), Vector3.new(0,0,0), Vector3.new(0,1.6,0)}

local function startSpider()
	if spiderConn then spiderConn:Disconnect(); spiderConn = nil end
	local lastChar = nil
	local climbTimer = 0
	local pauseTimer = 0
	local pauseActive = false
	local noiseX, noiseZ = 0, 0
	spiderConn = RunService.Heartbeat:Connect(function(dt)
		if not S.Spider then return end
		local char = LocalPlayer.Character
		if not char then return end
		local Root = char:FindFirstChild("HumanoidRootPart")
		local Hum  = char:FindFirstChildOfClass("Humanoid")
		if not Root or not Hum then return end
		if char ~= lastChar then
			spiderParams.FilterDescendantsInstances = {char}
			lastChar = char; climbTimer = 0; pauseTimer = 0; pauseActive = false
		end
		if Hum.MoveDirection.Magnitude < 0.1 then return end
		local look = Root.CFrame.LookVector
		local flatX, flatZ = look.X, look.Z
		local flatMag = math.sqrt(flatX*flatX + flatZ*flatZ)
		if flatMag < 0.01 then return end
		local scale = 1.25 / flatMag
		local flatVec = Vector3.new(flatX * scale, 0, flatZ * scale)
		local rootPos = Root.Position
		local hitCount = 0
		for i = 1, 3 do
			local r = workspace:Raycast(rootPos + _spiderOffsets[i], flatVec, spiderParams)
			if r and math.abs(r.Normal.Y) < 0.4 then hitCount = hitCount + 1 end
		end
		if hitCount >= 2 then
			climbTimer = climbTimer + dt
			pauseTimer = pauseTimer + dt
			if pauseTimer >= 0.28 then
				pauseTimer = 0; pauseActive = true
				noiseX = (math.random() - 0.5) * 0.012
				noiseZ = (math.random() - 0.5) * 0.012
			end
			if pauseActive then pauseActive = false; return end
			local targetVY  = S.SpiderSpeed
			local currentVY = Root.AssemblyLinearVelocity.Y
			local smoothVY  = currentVY + (targetVY - currentVY) * math.min(dt * 10, 1)
			Root.CFrame = CFrame.new(rootPos.X + noiseX, rootPos.Y, rootPos.Z + noiseZ) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
			Root.AssemblyLinearVelocity = Vector3.new(Root.AssemblyLinearVelocity.X, smoothVY, Root.AssemblyLinearVelocity.Z)
		else
			climbTimer = 0
		end
	end)
end
startSpider()

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local executorCall = checkcaller and checkcaller() or false
	if Runtime.Unloaded or executorCall or not S.SilentAim or self ~= workspace then
		return oldNamecall(self, ...)
	end
	if method ~= "Raycast" and method ~= "FindPartOnRay" and method ~= "FindPartOnRayWithIgnoreList" then
		return oldNamecall(self, ...)
	end
	local char = LocalPlayer.Character
	local equippedTool = char and char:FindFirstChildOfClass("Tool")
	local target = SA_CurrentTarget
	if not equippedTool or not target or not target.Parent then
		return oldNamecall(self, ...)
	end

	local args = {...}
	if method == "Raycast" then
		local origin, direction = args[1], args[2]
		if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
			return oldNamecall(self, ...)
		end
		local delta = target.Position - origin
		local castDistance = direction.Magnitude
		if delta.Magnitude == 0 or castDistance == 0 then
			return oldNamecall(self, ...)
		end
		args[2] = delta.Unit * castDistance
		return oldNamecall(self, unpack(args))
	end

	local ray = args[1]
	if typeof(ray) ~= "Ray" then return oldNamecall(self, ...) end
	local delta = target.Position - ray.Origin
	local castDistance = ray.Direction.Magnitude
	if delta.Magnitude == 0 or castDistance == 0 then
		return oldNamecall(self, ...)
	end
	args[1] = Ray.new(ray.Origin, delta.Unit * castDistance)
	return oldNamecall(self, unpack(args))
end))
onCleanup(function()
	if oldNamecall then
		pcall(hookmetamethod, game, "__namecall", oldNamecall)
		oldNamecall = nil
	end
end)

function Runtime.Unload()
	if Runtime.Unloaded then return end
	Runtime.Unloaded = true
	if ProjectileCore then ProjectileCore.Running = false end
	for key, value in pairs(S) do
		if type(value) == "boolean" then S[key] = false end
	end
	JumpStunSettings.Enabled = false
	HitSoundSettings.Enabled = false
	HotbarSettings.enabled = false
	PickupNotifEnabled = false
	customModelsEnabled = false
	fogEnabled = false
	fovLockEnabled = false
	if spiderConn then spiderConn:Disconnect(); spiderConn = nil end
	for index = #Runtime.Cleanup, 1, -1 do
		pcall(Runtime.Cleanup[index])
	end
	for _, drawing in ipairs(Runtime.Drawings) do
		pcall(function() drawing:Remove() end)
	end
	table.clear(Runtime.Drawings)
	for gui in pairs(Runtime.Guis) do
		pcall(function() gui:Destroy() end)
	end
	table.clear(Runtime.Guis)
	if _burmaldaEnv.BurmaldaRost == Runtime then
		_burmaldaEnv.BurmaldaRost = nil
	end
end
