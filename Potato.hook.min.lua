







local _burmaldaEnv = getgenv and getgenv() or _G
local _burmaldaKey = tostring(_burmaldaEnv.SCRIPT_KEY or ""):match("^%s*(.-)%s*$")
if tostring(_burmaldaEnv.PHOOKGATE or "") ~= "1347571535"
	or _burmaldaKey == ""
	or _burmaldaKey:upper() == "BETA"
then
	_burmaldaEnv.PHOOKGATE = nil
	_burmaldaEnv.SCRIPT_KEY = nil
	return
end
_burmaldaEnv.PHOOKGATE = nil
_burmaldaEnv.SCRIPT_KEY = nil
if _burmaldaEnv.BurmaldaRost and _burmaldaEnv.BurmaldaRost.Unload then
	pcall(_burmaldaEnv.BurmaldaRost.Unload)
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
local Runtime = {
	EnableCraftingIntegration = true,
	Unloaded = false,
	Cleanup = {},
	Drawings = {},
	Guis = {},
	CraftingMenuOpen = false,
	SilentPath = "GunBase.fire + FireServer + Workspace Raycast",
	SupportedExecutors = { "Real", "Opiumware", "Madium", "Potassium", "Synapse Z", "Volt", "Volcano", "Solara" },
}
_burmaldaEnv.BurmaldaRost = Runtime
Runtime.ExecutorName = executorName
Runtime.ModuleRequireMode = "standard"
Runtime.ModuleRequirePolicy = "feature-lazy + success-cache + 2s-error-backoff"
Runtime.ModuleRequireBackoffSeconds = 2
Runtime.ModuleRequireCache = {}
Runtime.ModuleRequireRetry = {}
do
	Runtime.RequireGameModule = function(module)
		if not module then return nil, "module-missing" end

		local cached = Runtime.ModuleRequireCache[module]
		if cached ~= nil then
			Runtime.LastModuleRequireError = nil
			return cached, nil
		end

		
		
		
		local retry = Runtime.ModuleRequireRetry[module]
		local now = os.clock()
		if retry and now < retry.Until then
			Runtime.LastModuleRequireError = retry.Error
			return nil, retry.Error
		end

		local ok, result = pcall(require, module)
		if not ok or result == nil then
			local message = ok and "module-returned-nil" or tostring(result)
			Runtime.LastModuleRequireError = message
			Runtime.ModuleRequireRetry[module] = {
				Until = now + Runtime.ModuleRequireBackoffSeconds,
				Error = message,
			}
			return nil, message
		end

		Runtime.ModuleRequireCache[module] = result
		Runtime.ModuleRequireRetry[module] = nil
		Runtime.LastModuleRequireError = nil
		return result, nil
	end
end
local ProjectileCore, ProjectileSilent

local function onCleanup(fn)
	table.insert(Runtime.Cleanup, fn)
end

onCleanup(function()
	table.clear(Runtime.ModuleRequireCache)
	table.clear(Runtime.ModuleRequireRetry)
end)

local function trackDrawing(obj)
	table.insert(Runtime.Drawings, obj)
	return obj
end

local _drawingNew = Drawing.new
local function newDrawing(kind)
	return trackDrawing(_drawingNew(kind))
end
local function removeDrawing(object)
	if not object then return end
	pcall(function() object:Remove() end)
	for index = #Runtime.Drawings, 1, -1 do
		if Runtime.Drawings[index] == object then
			table.remove(Runtime.Drawings, index)
			break
		end
	end
end
Runtime.RemoveDrawing = removeDrawing

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
	ESPBoxType     = "Normal",
	ESPDist        = false,
	ESPWeapon      = false,
	ESPChams       = false,
	ChamsFillTransparency = 0.5,
	ChamsOutlineTransparency = 0.2,
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
	HPHealthNumber = false,
	HPDynamicColor = false,
	SilentAim      = false,
	MBFovMode      = "mobile",
	MBHitChance    = 100,
	MBVisibleOnly  = true,
	MBUseFOV       = true,
	Manipulation   = false,
	MBMaxDist      = 500,
	MBTargetPart   = 1,
	MBPriority     = "distance",
	SpeedRostAlpha = false,
	HUDEnabled     = true,
	SpeedRostValue = 30,
	Spider         = false,
	SpiderSpeed    = 20,
	NoRecoil       = false,
	NoRecoilMethod = 1,
	LowPC          = false,
	HighJump       = false,
	HighJumpHeight = 100,

	AutoFire       = false,
	AutoFireDelay  = 0.05,
	TargetHUD      = false,
	HitLogsEnabled = false,
	HitLogsDuration = 5,
	HitLogsPosition = "Center",
	HitmarkerEnabled = false,
	HitmarkerSize  = 12,
	HitmarkerThickness = 2,
	HitmarkerDuration = 2.5,
	DamageFXEnabled = false,
	DamageFXStyle  = "Foam",
	DamageFXCount  = 12,
	DamageFXSpeed  = 20,
	DamageFXSize   = 0.25,
	DamageFXLifetime = 0.8,
	DamageFXRainbow = false,
	KillNotify     = false,
	XRay           = false,
	XRayTransparency = 0.5,
	ToolOutline    = false,
	CustomWater    = false,
	WaterReflectance = 0.3,
	SwimSpeed      = false,
	SwimSpeedValue = 50,
	CopterSpeed    = false,
	CopterSpeedValue = 50,
	NoFallDamage   = false,
	AntiAim        = false,
	AntiAimMode    = "Under Ground",
	AntiAimDepth   = 3,
	AntiAimSpin    = 180,
	NoJumpDelay    = false,
	CopterFly      = false,
	CopterFlySpeed = 100,
}
local SA_CurrentTarget = nil
S.Calamari = {}

local AC      = Color3.fromRGB(255, 255, 255)
local AC_ESP  = Color3.fromRGB(255, 255, 255)
local AC_FOV  = Color3.fromRGB(255, 255, 255)
local AC_FOV_TARGET = Color3.fromRGB(255, 0, 0)
local AC_FOV_FILL = Color3.fromRGB(255, 255, 255)
local AC_TR   = Color3.fromRGB(255, 255, 255)

local AC_NAME = Color3.fromRGB(255, 255, 255)
local AC_DIST = Color3.fromRGB(255, 255, 255)
local AC_FILL = Color3.fromRGB(255, 255, 255)
local AC_HP   = Color3.fromRGB(255, 255, 255)
local AC_WEAPON = Color3.fromRGB(255, 255, 255)
local AC_CHAMS = Color3.fromRGB(255, 255, 255)
local AC_CHAMS_OUTLINE = Color3.fromRGB(255, 255, 255)
Runtime.ExtraColors = {
	Hitmarker = Color3.fromRGB(255, 255, 255),
	HitmarkerKill = Color3.fromRGB(220, 80, 80),
	HitLogs = Color3.fromRGB(176, 176, 209),
	DamageFX = Color3.fromRGB(255, 255, 255),
	ToolOutline = Color3.fromRGB(255, 255, 255),
	Water = Color3.fromRGB(128, 128, 128),
}
local BK      = Color3.fromRGB(0, 0, 0)

local _visParams = RaycastParams.new()
_visParams.FilterType = Enum.RaycastFilterType.Exclude
_visParams.IgnoreWater = true
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
	local currentCamera = workspace.CurrentCamera or Camera
	if _visFilterList[1] ~= char or _visFilterList[2] ~= myChar or _visFilterList[3] ~= currentCamera then
		_visFilterList[1] = char
		_visFilterList[2] = myChar
		_visFilterList[3] = currentCamera
		_visParams.FilterDescendantsInstances = _visFilterList
	end
	local origin = currentCamera.CFrame.Position
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
	crosshairDot       = false,
	crosshairPulse     = false,
	crosshairPulseSpeed = 3,
	crosshairFollowAim = false,
	crosshairFollowTarget = false,
	crosshairFollowSmooth = 8,
}

local Crosshair = {
	ScreenGui    = nil,
	MainFrame    = nil,
	Segments     = {},
	Enabled      = false,
	CurrentType  = nil,
	Rotation     = 0,
	RainbowHue   = 0,
	PulseClock   = 0,
	CurrentGap   = 4,
	SmoothX      = nil,
	SmoothY      = nil,
	DotSegment   = nil,
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
	if Crosshair.DotSegment then
		Crosshair.DotSegment:Destroy()
		Crosshair.DotSegment = nil
	end
	Crosshair.Segments = {}
	Crosshair.SmoothX, Crosshair.SmoothY = nil, nil
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
		if Runtime.CraftingMenuOpen then
			UIS.MouseIconEnabled = true
			return
		end
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
		local pos, followUsed = nil, false
		local followPosition = nil
		if crosshairSettings.crosshairFollowAim and SA_CurrentTarget then
			followPosition = ProjectileSilent and ProjectileSilent.TargetPosition or SA_CurrentTarget.Position
		elseif crosshairSettings.crosshairFollowTarget and SA_CurrentTarget then
			followPosition = SA_CurrentTarget.Position
		end
		if followPosition then
			local activeCamera = workspace.CurrentCamera or Camera
			local projected, visible = activeCamera:WorldToViewportPoint(followPosition)
			if visible and projected.Z > 0 then
				pos = Vector2.new(projected.X, projected.Y)
				followUsed = true
				UIS.MouseIconEnabled = false
			end
		end
		if not pos and crosshairSettings.crosshairCenter then
			UIS.MouseIconEnabled = true
			local ss2 = Camera.ViewportSize
			pos = Vector2.new(ss2.X / 2, ss2.Y / 2)
		elseif not pos then
			UIS.MouseIconEnabled = false
			pos = UIS:GetMouseLocation()
		end
		if followUsed then
			if not Crosshair.SmoothX then Crosshair.SmoothX, Crosshair.SmoothY = pos.X, pos.Y end
			local alpha = 1 - math.exp(-math.max(0, dt or 0) * math.clamp(crosshairSettings.crosshairFollowSmooth, 1, 20))
			Crosshair.SmoothX += (pos.X - Crosshair.SmoothX) * alpha
			Crosshair.SmoothY += (pos.Y - Crosshair.SmoothY) * alpha
			pos = Vector2.new(Crosshair.SmoothX, Crosshair.SmoothY)
		else
			Crosshair.SmoothX, Crosshair.SmoothY = nil, nil
		end
		if Crosshair.MainFrame.Position ~= UDim2.new(0, pos.X, 0, pos.Y) then
			Crosshair.MainFrame.Position = UDim2.new(0, pos.X, 0, pos.Y)
		end
		Crosshair.PulseClock += dt or 0
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
		local gap = crosshairSettings.crosshairGap
		if crosshairSettings.crosshairPulse then
			gap += math.sin(Crosshair.PulseClock * crosshairSettings.crosshairPulseSpeed) * math.max(gap * 0.4, 2)
		end
		Crosshair.CurrentGap = gap
		if crosshairSettings.crosshairDot then
			if not Crosshair.DotSegment then
				local dot = Instance.new("Frame")
				dot.Name = "CenterDot"
				dot.AnchorPoint = Vector2.new(0.5, 0.5)
				dot.Size = UDim2.new(0, 2, 0, 2)
				dot.BorderSizePixel = 0
				dot.Parent = Crosshair.ScreenGui
				Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5, 0)
				Crosshair.DotSegment = dot
			end
			Crosshair.DotSegment.Visible = true
			Crosshair.DotSegment.Position = UDim2.new(0, pos.X, 0, pos.Y)
			Crosshair.DotSegment.BackgroundColor3 = col
		elseif Crosshair.DotSegment then
			Crosshair.DotSegment:Destroy()
			Crosshair.DotSegment = nil
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
advGui.Name = "BurmaldaHookStats"
advGui.IgnoreGuiInset = true
advGui.ResetOnSpawn = false
advGui.DisplayOrder = 999999
advGui.Parent = pGui
local _isLargeScreen = Camera.ViewportSize.X >= 1024



local statsHud = createBurmaldaStatsHud({
	Parent = advGui,
	Workspace = workspace,
	LocalPlayer = LocalPlayer,
	Stats = Stats,
	Visible = S.HUDEnabled == true,
	IsActive = function() return not Runtime.Unloaded end,
})
local function updateHUD() statsHud.SetVisible(S.HUDEnabled == true) end
onCleanup(function() statsHud.Destroy() end)


local function hudMakeDrag(gui)
	local drag, dragInput, dragStart, startPosition
	local connections = {}
	local changedConnection = nil
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
		if changedConnection then pcall(function() changedConnection:Disconnect() end); changedConnection = nil end
		for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
	end)
end

local openBtn = Instance.new("TextButton")
openBtn.Name = "MenuBtn"
openBtn.Text = ""
openBtn.AutoButtonColor = false
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
Runtime.StartClosed = true








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

local gunFeatures = {
	["No Recoil"] = true, ["Auto Fire"] = true, ["Rapid Fire"] = true,
	["Full Auto"] = true, ["Melee Mods"] = true, ["Hitbox Expander"] = true,
	["No Spread"] = true, ["Always Shoot"] = true, ["No Slowdown"] = true,
	["Force Headshots"] = true,
}
local worldFeatures = {
	["Custom FOV"] = true, ["Night Mode"] = true, ["Night Vision"] = true, ["Low PC"] = true,
	["Third Person"] = true, ["Stretch Resolution"] = true, ["Jump Circles"] = true,
	["Fullbright"] = true, ["No Decoration"] = true, ["Sky Color"] = true,
	["Skybox"] = true, ["Delete Spikes"] = true, ["Delete Leaves"] = true,
	["Custom Models"] = true, ["Custom Fog"] = true, ["Custom Water"] = true,
	["Custom Hand Position"] = true, ["X-Ray"] = true, ["Remove Fog"] = true,
	["Remove Grass"] = true, ["Remove Shadows"] = true,
}
local resourceFeatures = {
	["Resource ESP"] = true, ["Resource Boxes"] = true, ["Resource Names"] = true,
	["Resource Distance"] = true, ["Cloth"] = true, ["Iron"] = true,
	["Sulfur"] = true, ["Stone"] = true, ["Body Bag"] = true,
}
local projectileFeatures = {
	["Aim All Projectiles"] = true, ["Extend Throws"] = true,
}
local aimVisualFeatures = {
	["Target HUD"] = true, ["Hit Logs"] = true, ["Hitmarker"] = true,
	["Damage FX"] = true, ["Reload Indicator"] = true, ["Bullet Tracers"] = true,
	["FOV Circle"] = true, ["Dynamic FOV"] = true, ["Snapline"] = true,
	["Target Indicator"] = true, ["Hitscan Indicator"] = true,
}
local cameraFeatures = {
	["Custom FOV"] = true, ["Third Person"] = true, ["Stretch Resolution"] = true,
	["Custom Hand Position"] = true, ["FOV Changer"] = true, ["Zoom"] = true,
}
local performanceFeatures = { ["Low PC"] = true, ["Performance Overlay"] = true }
local effectFeatures = { ["Jump Circles"] = true, ["Tool Outline"] = true }
local localFeatures = { ["Instant Loot"] = true, ["No Fall"] = true, ["Silent Walk"] = true }
local diagnosticFeatures = { ["Print debug"] = true, ["Reset aim stats"] = true }
local soundFeatures = { ["Hit Sound"] = true, ["Kill Sound"] = true, ["Kill Notify"] = true }
local hudFeatures = {
	["HUD"] = true, ["Hotbar Overlay"] = true, ["Crosshair"] = true,
	["Pickup Notifications"] = true, ["Keybind List"] = true, ["Detection Notifier"] = true,
}
local interfaceFeatures = {
	["Menu Accent"] = true, ["UI Animations"] = true,
}



local featureTabOverrides = {
	["Target HUD"] = "VISUALS", ["Hit Logs"] = "VISUALS",
	["Hitmarker"] = "VISUALS", ["Damage FX"] = "VISUALS",
	["Reload Indicator"] = "VISUALS", ["Bullet Tracers"] = "VISUALS",
	["FOV Circle"] = "VISUALS", ["Dynamic FOV"] = "VISUALS",
	["Snapline"] = "VISUALS", ["Target Indicator"] = "VISUALS",
	["Hitscan Indicator"] = "VISUALS", ["FOV Changer"] = "VISUALS", ["Zoom"] = "VISUALS",
	["Aim All Projectiles"] = "COMBAT", ["Extend Throws"] = "COMBAT",
	["Night Mode"] = "MISC", ["Night Vision"] = "MISC", ["Low PC"] = "MISC",
	["Fullbright"] = "MISC", ["No Decoration"] = "MISC", ["Sky Color"] = "MISC",
	["Skybox"] = "MISC", ["Delete Spikes"] = "MISC", ["Delete Leaves"] = "MISC",
	["Custom Models"] = "MISC", ["Custom Fog"] = "MISC", ["Custom Water"] = "MISC",
	["X-Ray"] = "MISC", ["Remove Fog"] = "MISC", ["Remove Grass"] = "MISC",
	["Remove Shadows"] = "MISC",
}

local function organizeFeatureParent(parent, featureName)
	local currentTab = columnTabs[parent]
	local targetTab = currentTab and featureTabOverrides[featureName]
	if not targetTab then return parent end
	if targetTab == "MISC" and not tabColumns.MISC and tabColumns.WORLD then targetTab = "WORLD" end
	local targetColumns = tabColumns[targetTab]
	if not targetColumns then return parent end
	local currentColumns = tabColumns[currentTab]
	if currentColumns and parent == currentColumns[2] then return targetColumns[2] end
	return targetColumns[1]
end

function defaultSectionName(parent, featureName)
	local existing = sectionContents[parent]
	if existing then return existing.Name end
	local tabName = columnTabs[parent] or "MISC"
	if tabName == "COMBAT" then
		if projectileFeatures[featureName] then return "Projectiles" end
		return gunFeatures[featureName] and "Gun Mods" or "Aimbot"
	elseif tabName == "VISUALS" then
		if resourceFeatures[featureName] then return "Resources" end
		if aimVisualFeatures[featureName] then return "Aim Visuals" end
		if cameraFeatures[featureName] then return "Camera" end
		if effectFeatures[featureName] then return "Effects" end
		return worldFeatures[featureName] and "World" or "Players"
	elseif tabName == "MOVEMENT" then
		return projectileFeatures[featureName] and "Projectiles" or "Movement"
	elseif tabName == "MISC" then
		if performanceFeatures[featureName] then return "Performance" end
		if localFeatures[featureName] then return "Local" end
		if diagnosticFeatures[featureName] or string.find(featureName, "Insert / RightShift", 1, true) then return "Diagnostics" end
		if soundFeatures[featureName] then return "Sounds" end
		if hudFeatures[featureName] then return "HUD" end
		return worldFeatures[featureName] and "World" or "Misc"
	elseif tabName == "WORLD" then
		return cameraFeatures[featureName] and "Camera" or "World"
	elseif tabName == "CONFIG" then
		return interfaceFeatures[featureName] and "Interface" or "Configs"
	end
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
	parent = organizeFeatureParent(parent, name)
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
main.Visible = true
openBtn.Visible = false

function toggleMenu(viaSHIFT)
	menuOpen = not menuOpen
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



local craftingOpen, craftingChecking, craftRestoreMenu = false, false, false
local craftGuiStates = {}
local function craftingIsOpen()
	local mainGui = pGui and pGui:FindFirstChild("Main")
	local crafting = mainGui and mainGui:FindFirstChild("Crafting")
	return crafting ~= nil and crafting.Visible == true
end
local function updateCrafting()
	if Runtime.Unloaded then return end
	local open = craftingIsOpen()
	local changed = open ~= craftingOpen
	if changed then
		craftingOpen = open
		Runtime.CraftingMenuOpen = open
		if open then
			craftRestoreMenu = menuOpen
			if menuOpen then toggleMenu() end
		else
			for gui, enabled in pairs(craftGuiStates) do
				pcall(function() gui.Enabled = enabled end)
			end
			table.clear(craftGuiStates)
			if craftRestoreMenu and not menuOpen then toggleMenu() end
			craftRestoreMenu = false
		end
	end
	if open then
		for gui in pairs(Runtime.Guis) do
			if craftGuiStates[gui] == nil then craftGuiStates[gui] = gui.Enabled ~= false end
			pcall(function() gui.Enabled = false end)
		end
	end
end
Runtime.UpdateCraftingMenu = updateCrafting
local function checkCrafting()
	if craftingChecking then return end
	craftingChecking = true
	task.defer(function()
		craftingChecking = false
		updateCrafting()
	end)
end
do
	
	
	
	
	
	local mainChildConnection, craftingConnection
	local function disconnectOwned(connection)
		if connection then pcall(function() connection:Disconnect() end) end
	end
	local function bindCrafting(crafting)
		disconnectOwned(craftingConnection)
		craftingConnection = nil
		if crafting then
			craftingConnection = connectUI(crafting:GetPropertyChangedSignal("Visible"), checkCrafting)
		end
		checkCrafting()
	end
	local function bindMain(mainGui)
		disconnectOwned(mainChildConnection)
		mainChildConnection = nil
		if mainGui then
			mainChildConnection = connectUI(mainGui.ChildAdded, function(child)
				if child.Name == "Crafting" then bindCrafting(child) end
			end)
			bindCrafting(mainGui:FindFirstChild("Crafting"))
		else
			bindCrafting(nil)
		end
	end
	connectUI(pGui.ChildAdded, function(child)
		if child.Name == "Main" then bindMain(child) end
	end)
	bindMain(pGui and pGui:FindFirstChild("Main"))
	onCleanup(function()
		disconnectOwned(mainChildConnection)
		disconnectOwned(craftingConnection)
		mainChildConnection, craftingConnection = nil, nil
	end)
	updateCrafting()
end


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

if Runtime.StartClosed and menuOpen then toggleMenu() end
end


local recoilMod = nil

local function setupNoRecoil(enabled)
	if enabled then
		if not recoilMod then
			local gun = ReplicatedStorage:WaitForChild("Gun", 10)
			local scripts = gun and gun:WaitForChild("Scripts", 10)
			local module = scripts and scripts:WaitForChild("RecoilHandler", 10) or nil
			local loaded, err = Runtime.RequireGameModule(module)
			if type(loaded) == "table" then
				recoilMod = loaded
			else
				Runtime.NoRecoilError = err or "RecoilHandler did not return a table"
			end
		end

		if recoilMod and type(recoilMod.nextStep) == "function" and type(recoilMod.setRecoilMultiplier) == "function" then
			if not recoilMod._o_nS then
				recoilMod._o_nS = recoilMod.nextStep
			end
			if not recoilMod._o_sRM then
				recoilMod._o_sRM = recoilMod.setRecoilMultiplier
			end

			recoilMod.nextStep = function() end
			recoilMod.setRecoilMultiplier = function() end
			Runtime.NoRecoilError = nil
			S.NoRecoil = true
			return true
		end
		Runtime.NoRecoilError = Runtime.NoRecoilError or "RecoilHandler methods are unavailable"
		S.NoRecoil = false
		return false
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
		S.NoRecoil = false
		return true
	end
end
onCleanup(function() setupNoRecoil(false) end)

local JumpStunSettings = { Enabled = false, Height = 100 }

local jumpRequestConnection = UIS.JumpRequest:Connect(function()
	if Runtime.Unloaded or not JumpStunSettings.Enabled then return end
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.new(
			root.AssemblyLinearVelocity.X,
			JumpStunSettings.Height,
			root.AssemblyLinearVelocity.Z
		)
	end
end)
onCleanup(function()
	JumpStunSettings.Enabled = false
	if jumpRequestConnection then jumpRequestConnection:Disconnect(); jumpRequestConnection = nil end
end)

S.MBTargetLine = false
S.MBTargetLineColor = Color3.fromRGB(255, 255, 255)

do
	local lc, rc = getTab("COMBAT")

	local mbSet = createFeature(lc, "Silent Aim", false, function(v)
		S.SilentAim = v
		if v and ProjectileSilent and not ProjectileSilent.Installed.GunBase and type(ProjectileSilent.Refresh) == "function" then
			local ok, err = pcall(ProjectileSilent.Refresh)
			if ok then Runtime.SilentError = nil else Runtime.SilentError = tostring(err) end
		end
		
		
	end)
	addSlider(mbSet, "FOV", 10, 500, 120, function(v) S.FOV = v end)
	addSlider(mbSet, "Hit Chance", 0, 100, 100, function(v) S.MBHitChance = v end)
	addSlider(mbSet, "Max Dist", 50, 3000, 500, function(v) S.MBMaxDist = v end)
	addDropdown(mbSet, "Target Part", {"HeadHitbox", "Head", "HumanoidRootPart", "Random"}, 1, function(v)
		if v == "HeadHitbox" then S.MBTargetPart = 1
		elseif v == "Head" then S.MBTargetPart = 2
		elseif v == "HumanoidRootPart" then S.MBTargetPart = 3
		else S.MBTargetPart = 4 end
	end)
	addDropdown(mbSet, "Use FOV Filter", {"Off", "On"}, 2, function(v) S.MBUseFOV = v == "On" end)
	addDropdown(mbSet, "Visible Check", {"Off", "On"}, 2, function(v) S.MBVisibleOnly = v == "On" end)
	addDropdown(mbSet, "Manipulation", {"Off", "On"}, 1, function(v) S.Manipulation = v == "On" end)
	addDropdown(mbSet, "Target Priority", {"Distance", "HP"}, 1, function(v)
		S.MBPriority = v == "HP" and "hp" or "distance"
	end)
	addDropdown(mbSet, "FOV Mode", {"mobile", "pc"}, 1, function(v) S.MBFovMode = v end)
	addDropdown(mbSet, "FOV Circle", {"Off", "On"}, 1, function(v) S.FOVCircle = v == "On" end)
	addColor(mbSet, "FOV Color", function(c) AC_FOV = c end)
	addColor(mbSet, "Target Color", function(c) AC_FOV_TARGET = c end)
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
	addBind(mbSet, "Toggle Bind", "None", function()
		if _fFS["Silent Aim"] then _fFS["Silent Aim"](not S.SilentAim) end
	end)

	local noRecoilSet = createFeature(rc, "No Recoil", false, function(v)
		S.NoRecoil = v
		local applied = setupNoRecoil(v)
		if v and not applied and _fFS["No Recoil"] then
			_fFS["No Recoil"](false)
		end
	end, false)
	addBind(noRecoilSet, "Toggle Bind", "None", function()
		_fFS["No Recoil"](not S.NoRecoil)
	end)

end

do
	local lc, rc = getTab("ESP")

	local espSet = createFeature(lc, "ESP", false, function(v) S.ESPEnabled = v end)
	addSlider(espSet, "Radius", 50, 1000, 500, function(v) S.ESPRadius = v end)
	addDropdown(espSet, "Box Type", {"Normal", "Corner"}, 1, function(v) S.ESPBoxType = v end)
	addColor(espSet, "Box Color", function(c) AC_ESP = c end)
	addDropdown(espSet, "Box Fill", {"Off", "On"}, 1, function(v) S.BoxFill = v == "On" end)
	addSlider(espSet, "Fill Alpha", 1, 9, 7, function(v) S.BoxFillTransparency = v / 10 end)
	addColor(espSet, "Fill Color", function(c) AC_FILL = c end)

	local tracerSet = createFeature(lc, "Tracers", false, function(v)
		S.Tracers = v
		if v and S.MBTargetLine then
			S.MBTargetLine = false
			
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
	addDropdown(hpSet, "Health Number", {"Off", "On"}, 1, function(v) S.HPHealthNumber = v == "On" end)
	addDropdown(hpSet, "Dynamic Color", {"Off", "On"}, 1, function(v) S.HPDynamicColor = v == "On" end)
	addColor(hpSet, "Color", function(c) AC_HP = c end)

	local namesSet = createFeature(rc, "Names", false, function(v) S.Names = v end)
	addColor(namesSet, "Color", function(c) AC_NAME = c end)

	local distSet = createFeature(lc, "Distance", false, function(v) S.ESPDist = v end)
	addColor(distSet, "Color", function(c) AC_DIST = c end)

	local weaponSet = createFeature(lc, "Weapon", false, function(v) S.ESPWeapon = v end)
	addColor(weaponSet, "Color", function(c) AC_WEAPON = c end)

	local chamsSet = createFeature(rc, "Chams", false, function(v) S.ESPChams = v end)
	addColor(chamsSet, "Fill Color", function(c) AC_CHAMS = c end)
	addColor(chamsSet, "Outline Color", function(c) AC_CHAMS_OUTLINE = c end)
	addSlider(chamsSet, "Fill Alpha", 0, 9, 5, function(v) S.ChamsFillTransparency = v / 10 end)
	addSlider(chamsSet, "Outline Alpha", 0, 9, 2, function(v) S.ChamsOutlineTransparency = v / 10 end)
end

do
	local lc, rc = getTab("MOVEMENT")

	local speedSet = createFeature(lc, "Speed", false, function(v)
		S.SpeedRostAlpha = v
	end)
	addSlider(speedSet, "Value", 0, 60, 30, function(v) S.SpeedRostValue = v end)
	addBind(speedSet, "Toggle Bind", "None", function()
		if _fFS["Speed"] then _fFS["Speed"](not S.SpeedRostAlpha) end
	end)

	local hjSet = createFeature(lc, "High Jump", false, function(v)
		S.HighJump = v
		JumpStunSettings.Enabled = v
	end)
	addSlider(hjSet, "Height", 1, 200, 100, function(v)
		S.HighJumpHeight = v
		JumpStunSettings.Height = v
	end)
	addBind(hjSet, "Toggle Bind", "None", function()
		if _fFS["High Jump"] then _fFS["High Jump"](not S.HighJump) end
	end)

	local spiderSet = createFeature(rc, "Spider", false, function(v) S.Spider = v end)
	addSlider(spiderSet, "Speed", 5, 60, 20, function(v) S.SpiderSpeed = v end)
	addBind(spiderSet, "Toggle Bind", "None", function()
		if _fFS["Spider"] then _fFS["Spider"](not S.Spider) end
	end)

end

local HitSoundSettings = {
	Enabled = false,
	SoundId = "rbxassetid://8935436941",
	Volume  = 2,
	OriginalSounds = setmetatable({}, {__mode = "k"}),
	PlayedConnections = setmetatable({}, {__mode = "k"}),
}
local HitSoundIDs

do
	local lc, rc = getTab("MISC")

	HitSoundIDs = {
		["None"] = "",
		["Pop"] = "rbxassetid://8935436941",
		["Neverlose"] = "rbxassetid://6607598351",
		["Bat"] = "rbxassetid://99362374452374",
		["Tink"] = "rbxassetid://134428986251283",
		["Blum"] = "rbxassetid://79105299046226",
		["Skeet"] = "rbxassetid://83717596220569",
		["Sonic checkpoint"] = "rbxassetid://6817150445",
		["Sonic.exe laugh"] = "rbxassetid://18379039436",
		["Windows XP Error"] = "rbxassetid://9066167010",
		["Minecraft Hit"] = "rbxassetid://8766809464",
		["one sit nn dog"] = "rbxassetid://7380502345",
		["Door Bell"] = "rbxassetid://131845870598154",
		["Duck"] = "rbxassetid://1139819274",
		["Mgs"] = "rbxassetid://81845122657643",
		["Money"] = "rbxassetid://3020841054",
		["Fart"] = "rbxassetid://4809574295",
		["Meow"] = "rbxassetid://7148585764",
		["byebye"] = "rbxassetid://70888261086432",
	}

	local _hsLastPlayTime = setmetatable({}, {__mode = "k"})
	local _HS_COOLDOWN = 0.5

	local function applyHitSound(snd)
		if not snd or not snd.Parent then return end
		if not HitSoundSettings.OriginalSounds[snd] then
			HitSoundSettings.OriginalSounds[snd] = {SoundId = snd.SoundId, Volume = snd.Volume}
		end
		if HitSoundSettings.SoundId ~= "" then
			snd.SoundId = HitSoundSettings.SoundId
		else
			snd.SoundId = HitSoundSettings.OriginalSounds[snd].SoundId
		end
		snd.Volume  = HitSoundSettings.Volume

		
		
		local playedConnection = HitSoundSettings.PlayedConnections[snd]
		if not playedConnection or not playedConnection.Connected then
			snd:SetAttribute("_burmalda_hs_hooked", true)
			HitSoundSettings.PlayedConnections[snd] = snd.Played:Connect(function()
				if Runtime.Unloaded or not HitSoundSettings.Enabled then return end
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
						if s and s:IsA("Sound") then
							if HitSoundSettings.Enabled then applyHitSound(s) else restoreHitSound(s) end
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
			refreshSounds()
			hookHSContainers()
		end
	end)

	addDropdown(hsSet, "Sound", {"Pop", "Neverlose", "Bat", "Tink", "Blum", "None", "Skeet", "Sonic checkpoint", "Sonic.exe laugh", "Windows XP Error", "Minecraft Hit", "one sit nn dog", "Door Bell", "Duck", "Mgs", "Money", "Fart", "Meow", "byebye"}, 1, function(v)
		HitSoundSettings.SoundId = HitSoundIDs[v] or ""
		if HitSoundSettings.Enabled then debouncedRefresh() end
	end)

	addSlider(hsSet, "Volume", 1, 10, 2, function(v)
		HitSoundSettings.Volume = v
		if HitSoundSettings.Enabled then debouncedRefresh() end
	end)

	local _hsLifecycleConns = {}
	table.insert(_hsLifecycleConns, LocalPlayer.CharacterAdded:Connect(function()
		task.delay(0.3, function() if not Runtime.Unloaded then hookHSContainers() end end)
	end))

	table.insert(_hsLifecycleConns, LocalPlayer.CharacterRemoving:Connect(function()
		for _, c in ipairs(_hsConns) do pcall(function() c:Disconnect() end) end
		_hsConns = {}
	end))

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
		for snd in pairs(HitSoundSettings.OriginalSounds) do
			pcall(restoreHitSound, snd)
		end
		for snd, conn in pairs(HitSoundSettings.PlayedConnections) do
			pcall(function() conn:Disconnect() end)
			pcall(function()
				if snd:GetAttribute("_burmalda_hs_hooked") ~= nil then
					snd:SetAttribute("_burmalda_hs_hooked", nil)
				end
			end)
			_hsLastPlayTime[snd] = nil
		end
		table.clear(HitSoundSettings.PlayedConnections)
		table.clear(HitSoundSettings.OriginalSounds)
		for _, conn in ipairs(_hsConns) do pcall(function() conn:Disconnect() end) end
		for _, conn in ipairs(_hsLifecycleConns) do pcall(function() conn:Disconnect() end) end
		_hsConns = {}
		_hsLifecycleConns = {}
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
	addSlider(chSet, "Spin Speed", -360, 360, 2, function(v) crosshairSettings.crosshairSpinSpeed = v end)
	addDropdown(chSet, "Rainbow", {"Off", "On"}, 1, function(v) crosshairSettings.crosshairRainbow = v == "On" end)
	addDropdown(chSet, "Dot", {"Off", "On"}, 1, function(v) crosshairSettings.crosshairDot = v == "On" end)
	addDropdown(chSet, "Pulse", {"Off", "On"}, 1, function(v) crosshairSettings.crosshairPulse = v == "On" end)
	addSlider(chSet, "Pulse Speed", 5, 100, 30, function(v) crosshairSettings.crosshairPulseSpeed = v / 10 end)
	addDropdown(chSet, "Follow Aim Point", {"Off", "On"}, 1, function(v) crosshairSettings.crosshairFollowAim = v == "On" end)
	addDropdown(chSet, "Follow Target", {"Off", "On"}, 1, function(v) crosshairSettings.crosshairFollowTarget = v == "On" end)
	addSlider(chSet, "Follow Smoothness", 1, 20, 8, function(v) crosshairSettings.crosshairFollowSmooth = v end)

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
local fovControlled, fovBaseline = false, nil
local nvEnabled = false
local handPosEnabled = false
local ViewmodelConfig = { X = 0, Y = 0, Z = 0 }

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
	if fogAtm and fogAtm.Parent then
		applyFogSettings()
		return
	end
	if fogAtm then fogAtm:Destroy(); fogAtm = nil end
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
	_origFogColor, _origFogEnd, _origFogStart = nil, nil, nil
	_origClockTime, _origBrightness, _origOutdoorAmbient = nil, nil, nil
end
onCleanup(function() fogEnabled = false; disableFog() end)

do
	local lc, rc = getTab("CONFIG")
	createFeature(lc, "Unload Burmalda.hook", false, function(v)
		if v and Runtime.Unload then task.defer(Runtime.Unload) end
	end, false)
	local accentSet = createFeature(lc, "Menu Accent", true, function() end)
	addColor(accentSet, "Accent Color", function(c) setMenuAccent(c) end, Theme.Accent)
	addDropdown(accentSet, "Preset", {"White", "Silver", "Graphite", "Blue"}, 1, function(v)
		if v == "White" then setMenuAccent(Color3.fromRGB(255, 255, 255))
		elseif v == "Silver" then setMenuAccent(Color3.fromRGB(190, 190, 190))
		elseif v == "Graphite" then setMenuAccent(Color3.fromRGB(105, 105, 105))
		else setMenuAccent(Color3.fromRGB(0, 82, 255)) end
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

		local cols = {AC_ESP=AC_ESP,AC_FOV=AC_FOV,AC_FOV_TARGET=AC_FOV_TARGET,AC_FOV_FILL=AC_FOV_FILL,
			AC_TR=AC_TR,AC_NAME=AC_NAME,AC_DIST=AC_DIST,
			AC_FILL=AC_FILL,AC_HP=AC_HP,AC_WEAPON=AC_WEAPON,
			AC_CHAMS=AC_CHAMS,AC_CHAMS_OUTLINE=AC_CHAMS_OUTLINE}
		for k,v in pairs(cols) do cfg[k] = c2t(v) end
		for name, color in pairs(Runtime.ExtraColors) do cfg["AC_EXTRA_"..name] = c2t(color) end

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
		cfg["CH_dot"]       = crosshairSettings.crosshairDot
		cfg["CH_pulse"]     = crosshairSettings.crosshairPulse
		cfg["CH_pulseSpeed"] = crosshairSettings.crosshairPulseSpeed
		cfg["CH_followAim"] = crosshairSettings.crosshairFollowAim
		cfg["CH_followTarget"] = crosshairSettings.crosshairFollowTarget
		cfg["CH_followSmooth"] = crosshairSettings.crosshairFollowSmooth
		cfg["CH_color"]     = c2t(crosshairSettings.crosshairColor)

		cfg["HS_enabled"] = HitSoundSettings.Enabled
		cfg["HS_soundId"] = HitSoundSettings.SoundId
		cfg["HS_volume"]  = HitSoundSettings.Volume

		cfg["FG_enabled"] = fogEnabled
		cfg["FG_color"]   = c2t(fogColor)
		cfg["FG_density"] = fogDensity

		cfg["CFOV_enabled"] = fovLockEnabled
		cfg["CFOV_value"]   = targetFOV
		cfg["NV_enabled"]   = nvEnabled
		cfg["HP_enabled"]   = handPosEnabled
		cfg["HP_x"]         = ViewmodelConfig.X
		cfg["HP_y"]         = ViewmodelConfig.Y
		cfg["HP_z"]         = ViewmodelConfig.Z
		cfg["Binds"]        = {}
		for featureName, api in pairs(Runtime.BindApis or {}) do
			if api and api.Get then cfg.Binds[featureName] = api.Get() end
		end

		cfg["CM_enabled"]      = customModelsEnabled
		cfg["CM_color"]        = c2t(glassColor)
		cfg["CM_transparency"] = glassTransparency
		cfg["CM_material"]     = glassMaterial.Name or tostring(glassMaterial)

		cfg["HB_enabled"] = HotbarSettings.enabled

		cfg["PN_enabled"] = PickupNotifEnabled
		cfg["UI_accent"] = c2t(Theme.Accent)
		cfg["UI_animations"] = UIAnimations
		return HS:JSONEncode(cfg)
	end

	local function applyConfig(str)
		local ok, cfg = pcall(HS.JSONDecode, HS, str)
		if not ok or type(cfg) ~= "table" then return false end
		local requestedNV, requestedHand = nvEnabled, handPosEnabled

		for k in pairs(S) do
			if cfg["S_"..k] ~= nil then S[k] = cfg["S_"..k] end
		end
		if cfg.S_Calamari and Runtime.CalamariVisuals then
			local destination = Runtime.CalamariVisuals.State
			for key, value in pairs(cfg.S_Calamari) do destination[key] = value end
			S.Calamari = destination
			Runtime.CalamariVisuals.SyncUI()
		end

		if cfg.AC_ESP      then AC_ESP      = t2c(cfg.AC_ESP)      end
		if cfg.AC_FOV      then AC_FOV      = t2c(cfg.AC_FOV)      end
		if cfg.AC_FOV_TARGET then AC_FOV_TARGET = t2c(cfg.AC_FOV_TARGET) end
		if cfg.AC_FOV_FILL then AC_FOV_FILL = t2c(cfg.AC_FOV_FILL) end
		if cfg.AC_TR       then AC_TR       = t2c(cfg.AC_TR)       end
		if cfg.AC_NAME     then AC_NAME     = t2c(cfg.AC_NAME)     end
		if cfg.AC_DIST     then AC_DIST     = t2c(cfg.AC_DIST)     end
		if cfg.AC_FILL     then AC_FILL     = t2c(cfg.AC_FILL)     end
		if cfg.AC_HP       then AC_HP       = t2c(cfg.AC_HP)       end
		if cfg.AC_WEAPON   then AC_WEAPON   = t2c(cfg.AC_WEAPON)   end
		if cfg.AC_CHAMS    then AC_CHAMS    = t2c(cfg.AC_CHAMS)    end
		if cfg.AC_CHAMS_OUTLINE then AC_CHAMS_OUTLINE = t2c(cfg.AC_CHAMS_OUTLINE) end
		for name in pairs(Runtime.ExtraColors) do
			local key = "AC_EXTRA_"..name
			if cfg[key] then Runtime.ExtraColors[name] = t2c(cfg[key]) end
		end

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
		if cfg.CH_dot       ~= nil then crosshairSettings.crosshairDot       = cfg.CH_dot       end
		if cfg.CH_pulse     ~= nil then crosshairSettings.crosshairPulse     = cfg.CH_pulse     end
		if cfg.CH_pulseSpeed ~= nil then crosshairSettings.crosshairPulseSpeed = cfg.CH_pulseSpeed end
		if cfg.CH_followAim ~= nil then crosshairSettings.crosshairFollowAim = cfg.CH_followAim end
		if cfg.CH_followTarget ~= nil then crosshairSettings.crosshairFollowTarget = cfg.CH_followTarget end
		if cfg.CH_followSmooth ~= nil then crosshairSettings.crosshairFollowSmooth = cfg.CH_followSmooth end
		if cfg.CH_color     ~= nil then crosshairSettings.crosshairColor     = t2c(cfg.CH_color) end

		if cfg.HS_enabled ~= nil then HitSoundSettings.Enabled = cfg.HS_enabled end
		if cfg.HS_soundId ~= nil then HitSoundSettings.SoundId = cfg.HS_soundId end
		if cfg.HS_volume  ~= nil then HitSoundSettings.Volume  = cfg.HS_volume  end

		if cfg.FG_enabled ~= nil then fogEnabled = cfg.FG_enabled end
		if cfg.FG_color   ~= nil then fogColor   = t2c(cfg.FG_color) end
		if cfg.FG_density ~= nil then fogDensity = cfg.FG_density end

		if cfg.CFOV_enabled ~= nil then fovLockEnabled = cfg.CFOV_enabled end
		if cfg.CFOV_value   ~= nil then targetFOV      = cfg.CFOV_value   end
		if cfg.NV_enabled   ~= nil then requestedNV    = cfg.NV_enabled    end
		if cfg.HP_enabled   ~= nil then requestedHand  = cfg.HP_enabled    end
		if type(cfg.HP_x) == "number" then ViewmodelConfig.X = cfg.HP_x end
		if type(cfg.HP_y) == "number" then ViewmodelConfig.Y = cfg.HP_y end
		if type(cfg.HP_z) == "number" then ViewmodelConfig.Z = cfg.HP_z end

		if cfg.CM_enabled      ~= nil then customModelsEnabled = cfg.CM_enabled      end
		if cfg.CM_color        ~= nil then glassColor          = t2c(cfg.CM_color)   end
		if cfg.CM_transparency ~= nil then glassTransparency   = cfg.CM_transparency end
		if cfg.CM_material     ~= nil then
			local mats = {Glass=Enum.Material.Glass, Neon=Enum.Material.Neon,
				ForceField=Enum.Material.ForceField, SmoothPlastic=Enum.Material.SmoothPlastic}
			
			
			local materialName = tostring(cfg.CM_material):match("([^.]+)$")
			glassMaterial = mats[materialName] or Enum.Material.Glass
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
		applyToggle("Weapon",                S.ESPWeapon)
		applyToggle("Chams",                 S.ESPChams)

		applyToggle("Speed",                 S.SpeedRostAlpha)
		applyToggle("High Jump",             S.HighJump)
		applyToggle("Spider",                S.Spider)
		applyToggle("Auto Fire",             S.AutoFire)
		applyToggle("Target HUD",            S.TargetHUD)
		applyToggle("Hit Logs",              S.HitLogsEnabled)
		applyToggle("Hitmarker",             S.HitmarkerEnabled)
		applyToggle("Damage FX",             S.DamageFXEnabled)
		applyToggle("Kill Notify",           S.KillNotify)
		applyToggle("X-Ray",                 S.XRay)
		applyToggle("Tool Outline",          S.ToolOutline)
		applyToggle("Custom Water",          S.CustomWater)
		applyToggle("Swim Speed",            S.SwimSpeed)
		applyToggle("Copter Speed",          S.CopterSpeed)
		applyToggle("No Fall Damage",        S.NoFallDamage)
		applyToggle("No Jump Delay",         S.NoJumpDelay)
		applyToggle("Copter Fly",            S.CopterFly)
		applyToggle("Rapid Fire",            S.RapidFire)
		applyToggle("Full Auto",             S.FullAuto)
		applyToggle("Melee Mods",            S.MeleeMods)
		applyToggle("Hitbox Expander",       S.HitboxExpander)
		applyToggle("Reload Indicator",      S.ReloadIndicator)
		applyToggle("Bullet Tracers",        S.BulletTracers)
		applyToggle("Third Person",          S.ThirdPerson)
		applyToggle("Stretch Resolution",    S.Stretch)
		applyToggle("Jump Circles",          S.JumpCircles)
		applyToggle("Fullbright",            S.Fullbright)
		applyToggle("No Decoration",         S.NoDecoration)
		applyToggle("Sky Color",             S.SkyColorEnabled)
		applyToggle("Skybox",                S.SkyboxEnabled)
		applyToggle("Delete Spikes",         S.DeleteSpikes)
		applyToggle("Delete Leaves",         S.DeleteLeaves)
		applyToggle("Kill Sound",            S.KillSound)

		applyToggle("Hit Sound",             HitSoundSettings.Enabled)

		applyToggle("HUD",                   S.HUDEnabled)
		applyToggle("Hotbar Overlay",        HotbarSettings.enabled)
		applyToggle("Crosshair",             crosshairSettings.crosshairEnabled)
		applyToggle("Pickup Notifications",  PickupNotifEnabled)

		applyToggle("Custom Models",         customModelsEnabled)
		applyToggle("Custom Fog",            fogEnabled)
		applyToggle("Custom FOV",            fovLockEnabled)
		applyToggle("Night Vision",          requestedNV)
		applyToggle("Custom Hand Position",  requestedHand)
		applyToggle("Low PC",                S.LowPC)
		applyToggle("UI Animations",         UIAnimations)

		if fovLockEnabled and targetFOV then Camera.FieldOfView = targetFOV end
		if type(cfg.Binds) == "table" then
			for featureName, value in pairs(cfg.Binds) do
				local api = Runtime.BindApis and Runtime.BindApis[featureName]
				if api and api.Set and type(value) == "string" then api.Set(value) end
			end
		end

		
		
		
		local function syncDropdown(feature, name, value)
			local setter = _fDD[feature .. "_Settings_" .. name]
			if setter and value ~= nil then setter(value, true) end
		end
		local function onOff(value) return value and "On" or "Off" end
		syncDropdown("Silent Aim", "Target Part", ({"HeadHitbox", "Head", "HumanoidRootPart", "Random"})[S.MBTargetPart] or "HeadHitbox")
		syncDropdown("Silent Aim", "Use FOV Filter", onOff(S.MBUseFOV))
		syncDropdown("Silent Aim", "Visible Check", onOff(S.MBVisibleOnly))
		syncDropdown("Silent Aim", "Manipulation", onOff(S.Manipulation))
		syncDropdown("Silent Aim", "Target Priority", S.MBPriority == "hp" and "HP" or "Distance")
		syncDropdown("Silent Aim", "FOV Mode", S.MBFovMode or "mobile")
		syncDropdown("Silent Aim", "FOV Circle", onOff(S.FOVCircle))
		syncDropdown("Silent Aim", "FOV Fill", onOff(S.FOVFill))
		syncDropdown("Silent Aim", "Target Line", onOff(S.MBTargetLine))
		syncDropdown("ESP", "Box Type", S.ESPBoxType or "Normal")
		syncDropdown("ESP", "Box Fill", onOff(S.BoxFill))
		syncDropdown("Tracers", "Origin", ({"Top", "Bottom", "Center"})[S.TracerOrigin] or "Bottom")
		syncDropdown("HP Bar", "Position", S.HPBarSide == 2 and "Top" or "Side")
		syncDropdown("HP Bar", "Health Number", onOff(S.HPHealthNumber))
		syncDropdown("HP Bar", "Dynamic Color", onOff(S.HPDynamicColor))
		local hitSoundName
		for name, id in pairs(HitSoundIDs) do
			if id == HitSoundSettings.SoundId then hitSoundName = name break end
		end
		syncDropdown("Hit Sound", "Sound", hitSoundName)
		syncDropdown("Crosshair", "Type", crosshairSettings.crosshairType or "Default")
		syncDropdown("Crosshair", "Mode", crosshairSettings.crosshairCenter and "mobile" or "pc")
		syncDropdown("Crosshair", "Spin", onOff(crosshairSettings.crosshairSpin))
		syncDropdown("Crosshair", "Rainbow", onOff(crosshairSettings.crosshairRainbow))
		syncDropdown("Crosshair", "Dot", onOff(crosshairSettings.crosshairDot))
		syncDropdown("Crosshair", "Pulse", onOff(crosshairSettings.crosshairPulse))
		syncDropdown("Crosshair", "Follow Aim Point", onOff(crosshairSettings.crosshairFollowAim))
		syncDropdown("Crosshair", "Follow Target", onOff(crosshairSettings.crosshairFollowTarget))
		syncDropdown("Hit Logs", "Position", S.HitLogsPosition)
		syncDropdown("Damage FX", "Style", S.DamageFXStyle)
		syncDropdown("Damage FX", "Rainbow", onOff(S.DamageFXRainbow))
		syncDropdown("Custom Models", "Material", glassMaterial and glassMaterial.Name)
		syncDropdown("Bullet Tracers", "Texture", S.BulletTracerStyle)
		syncDropdown("Skybox", "Preset", S.SkyboxChoice)
		syncDropdown("Kill Sound", "Sound", S.KillSoundChoice)
		applyToggle("Anti Aim", S.AntiAim)
		syncDropdown("Anti Aim", "Mode", S.AntiAimMode)
		if Runtime.AntiAimControls then
			Runtime.AntiAimControls.Depth(S.AntiAimDepth, true)
			Runtime.AntiAimControls.Spin(S.AntiAimSpin, true)
		end
		local accentPreset
		local accentColors = {
			Blue = Color3.fromRGB(0, 82, 255), White = Color3.fromRGB(255, 255, 255),
			Silver = Color3.fromRGB(190, 190, 190), Graphite = Color3.fromRGB(105, 105, 105),
		}
		for name, color in pairs(accentColors) do
			if Theme.Accent == color then accentPreset = name break end
		end
		syncDropdown("Menu Accent", "Preset", accentPreset)

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

	local HUD_BG = Theme.Element
	local HUD_BT = 0
	local HUD_ST = 0
	local HUD_R  = 0

	local function mkCorner(p)
		if not p:FindFirstChildOfClass("UICorner") then
			local corner = Instance.new("UICorner", p)
			corner.CornerRadius = UDim.new(0, 5)
		end
	end
	local function mkStroke(p)
		sourceStroke(p)
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
		b.TextSize = 12
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

	
	lc, rc = getTab("CONFIG")
	lc = getSection(lc, "Configs").Content
	rc = getSection(rc, "Saved Configs").Content
	local inputF = Instance.new("Frame", lc)
	inputF.Size = UDim2.new(1, 0, 0, 45)
	inputF.BackgroundColor3 = HUD_BG
	inputF.BackgroundTransparency = HUD_BT
	inputF.BorderSizePixel = 0
	mkCorner(inputF); mkStroke(inputF)
	local inputLabel = sourceText(inputF, "Config Name", UDim2.new(1, 0, 0, 15), Theme.SubText)
	inputLabel.Position = UDim2.new(0, 8, 0, 4)
	local iPad = Instance.new("UIPadding", inputF)
	iPad.PaddingLeft = UDim.new(0, 8); iPad.PaddingRight = UDim.new(0, 8)
	local tb = Instance.new("TextBox", inputF)
	tb.Position = UDim2.new(0, 0, 0, 25)
	tb.Size = UDim2.new(1, 0, 0, 20)
	tb.BackgroundTransparency = 1
	tb.Text = ""; tb.PlaceholderText = "config name..."
	tb.Font = Enum.Font.Gotham; tb.TextSize = 12
	tb.TextColor3 = Color3.new(1,1,1)
	tb.PlaceholderColor3 = Color3.fromRGB(70,70,70)
	tb.ClearTextOnFocus = false
	tb.TextXAlignment = Enum.TextXAlignment.Center

	local rowF = Instance.new("Frame", lc)
	rowF.Size = UDim2.new(1, 0, 0, 20)
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
	emptyLbl.Font = Enum.Font.Gotham; emptyLbl.TextSize = 12
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
			nLbl.Font = Enum.Font.Gotham; nLbl.TextSize = 14
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
	local _cmChildConnection = nil
	local function connectCMChar(char)
		if Runtime.Unloaded or not char then return end
		if _cmLastChar == char and _cmChildConnection then return end
		if _cmChildConnection then _cmChildConnection:Disconnect(); _cmChildConnection = nil end
		_cmLastChar = char
		pcall(scanForWeapons)
		_cmChildConnection = char.ChildAdded:Connect(function(child)
			if not Runtime.Unloaded and customModelsEnabled and (child:IsA("Tool") or child:IsA("Model")) then
				task.delay(0.05, function() if not Runtime.Unloaded then pcall(scanForWeapons) end end)
			end
		end)
	end
	local _cmAddedConnection = LocalPlayer.CharacterAdded:Connect(connectCMChar)
	if LocalPlayer.Character then connectCMChar(LocalPlayer.Character) end
	onCleanup(function()
		customModelsEnabled = false
		if _cmChildConnection then _cmChildConnection:Disconnect(); _cmChildConnection = nil end
		if _cmAddedConnection then _cmAddedConnection:Disconnect(); _cmAddedConnection = nil end
		_cmLastChar = nil
	end)

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
		if _fFS["Custom Models"] then _fFS["Custom Models"](not customModelsEnabled) end
	end)

	local fogSet = createFeature(lc, "Custom Fog", false, function(v)
		if v and S.Fullbright and _fFS["Fullbright"] then _fFS["Fullbright"](false) end
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

	local function restoreFOV()
		if fovControlled and fovBaseline ~= nil then Camera.FieldOfView = fovBaseline end
		fovControlled, fovBaseline = false, nil
	end
	local function setFOVLock(enabled)
		if enabled then
			if not fovControlled then fovBaseline = Camera.FieldOfView end
			fovControlled = true
			fovLockEnabled = true
			Camera.FieldOfView = targetFOV
		else
			fovLockEnabled = false
			restoreFOV()
		end
	end

	
	RunService:BindToRenderStep("BurmaldaHookFOV", Enum.RenderPriority.First.Value, function()
		if Runtime.Unloaded or not fovLockEnabled or not fovControlled then return end
		Camera.FieldOfView = targetFOV
	end)
	onCleanup(function()
		fovLockEnabled = false
		RunService:UnbindFromRenderStep("BurmaldaHookFOV")
		restoreFOV()
	end)

	
	local fovChangedConnection = Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
		if not Runtime.Unloaded and fovLockEnabled and fovControlled and Camera.FieldOfView ~= targetFOV then
			Camera.FieldOfView = targetFOV
		end
	end)
	onCleanup(function()
		fovLockEnabled = false
		if fovChangedConnection then fovChangedConnection:Disconnect(); fovChangedConnection = nil end
	end)

	local fovLockSet = createFeature(rc, "Custom FOV", false, function(v)
		setFOVLock(v)
	end)
	addSlider(fovLockSet, "FOV Value", 30, 120, 90, function(v)
		targetFOV = v
	end)
	addBind(fovLockSet, "Toggle Bind", "None", function()
		if _fFS["Custom FOV"] then _fFS["Custom FOV"](not fovLockEnabled) end
	end)

	nvEnabled = false
	local _nvOrig = {}

	local function enableNV()
		if _nvOrig.ClockTime == nil then
			_nvOrig.Brightness     = _Lighting.Brightness
			_nvOrig.Ambient        = _Lighting.Ambient
			_nvOrig.OutdoorAmbient = _Lighting.OutdoorAmbient
			_nvOrig.ClockTime      = _Lighting.ClockTime
		end
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
		if v and S.Fullbright and _fFS["Fullbright"] then _fFS["Fullbright"](false) end
		nvEnabled = v
		if v then
			if fogEnabled then disableFog() end
			enableNV()
		else
			disableNV()
			if fogEnabled then enableFog() end
		end
	end, false)

	
	do
		local state = { Backups = {}, Connections = {} }
		Runtime.LowPCState = state

		local function setProperty(object, key, value)
			if not object then return end
			local saved = state.Backups[object]
			if not saved then
				saved = {}
				state.Backups[object] = saved
			end
			if saved[key] == nil then
				local ok, original = pcall(function() return object[key] end)
				if not ok or original == nil then return end
				saved[key] = original
			end
			pcall(function() object[key] = value end)
		end

		local function isDecorative(object)
			local current = object
			for _ = 1, 6 do
				if not current then break end
				if current.ClassName == "Tool" then return false end
				local name = string.lower(tostring(current.Name))
				if string.find(name, "grass", 1, true)
					or string.find(name, "leav", 1, true)
					or string.find(name, "foliage", 1, true)
					or string.find(name, "bush", 1, true)
					or string.find(name, "shrub", 1, true)
					or string.find(name, "fern", 1, true)
					or string.find(name, "flower", 1, true)
					or string.find(name, "reed", 1, true)
					or string.find(name, "cloud", 1, true) then
					return true
				end
				current = current.Parent
			end
			return false
		end

		local function applyObject(object)
			local className = object.ClassName
			if className == "ParticleEmitter" or className == "Trail" or className == "Beam"
				or className == "Smoke" or className == "Fire" or className == "Sparkles"
				or className == "Clouds"
				or className == "BloomEffect" or className == "BlurEffect"
				or className == "SunRaysEffect" or className == "DepthOfFieldEffect"
				or className == "ColorCorrectionEffect" then
				setProperty(object, "Enabled", false)
			end
			if className == "Atmosphere" then
				setProperty(object, "Density", 0)
				setProperty(object, "Haze", 0)
				setProperty(object, "Glare", 0)
			end
			if isDecorative(object) then
				if object:IsA("BasePart") then
					setProperty(object, "LocalTransparencyModifier", 1)
					setProperty(object, "Transparency", 1)
					setProperty(object, "CastShadow", false)
				elseif className == "Decal" or className == "Texture" then
					setProperty(object, "Transparency", 1)
				elseif className == "SpecialMesh" then
					setProperty(object, "TextureId", "")
				end
			end
		end

		local scanId = 0
		local function applyLowPC()
			setProperty(_Lighting, "GlobalShadows", false)
			local terrain = workspace:FindFirstChildOfClass("Terrain")
			if terrain then
				setProperty(terrain, "WaterWaveSize", 0)
				setProperty(terrain, "WaterWaveSpeed", 0)
				setProperty(terrain, "Decoration", false)
			end
			local ok, rendering = pcall(function() return settings().Rendering end)
			if ok and rendering then setProperty(rendering, "QualityLevel", Enum.QualityLevel.Level01) end
			scanId += 1
			local currentScan = scanId
			local stack = {}
			local function push(root)
				local children = root:GetChildren()
				if #children > 0 then stack[#stack + 1] = {children = children, index = 1} end
			end
			push(workspace)
			push(_Lighting)
			local function step()
				if currentScan ~= scanId or not S.LowPC or Runtime.Unloaded then return end
				local processed = 0
				while #stack > 0 and processed < 250 do
					local frame = stack[#stack]
					local object = frame.children[frame.index]
					frame.index += 1
					if object then
						applyObject(object)
						processed += 1
						local children = object:GetChildren()
						if #children > 0 then stack[#stack + 1] = {children = children, index = 1} end
					else
						table.remove(stack)
					end
				end
				if #stack > 0 then task.delay(0.01, step) end
			end
			step()
		end

		local function disconnectLowPC()
			scanId += 1
			for _, connection in ipairs(state.Connections) do pcall(function() connection:Disconnect() end) end
			table.clear(state.Connections)
		end

		local function restoreLowPC()
			disconnectLowPC()
			for object, saved in pairs(state.Backups) do
				for key, value in pairs(saved) do
					pcall(function() object[key] = value end)
				end
			end
			table.clear(state.Backups)
		end

		createFeature(rc, "Low PC", false, function(v)
			if v and S.Fullbright and _fFS["Fullbright"] then _fFS["Fullbright"](false) end
			S.LowPC = v
			if v then
				if #state.Connections == 0 then
					table.insert(state.Connections, workspace.DescendantAdded:Connect(function(object)
						if S.LowPC then applyObject(object) end
					end))
					table.insert(state.Connections, _Lighting.DescendantAdded:Connect(function(object)
						if S.LowPC then applyObject(object) end
					end))
				end
				applyLowPC()
			else
				restoreLowPC()
			end
		end, false)
		onCleanup(function()
			S.LowPC = false
			restoreLowPC()
		end)
	end

	
	ViewmodelConfig = { X = 0, Y = 0, Z = 0 }
	handPosEnabled = false
	local handPosConn = nil
	local handPosLastVM = nil
	local handPosLastWritten = nil
	local handPosBase = nil
	local handPosHasApplied = false

	local function restoreHandPosition()
		if handPosHasApplied and handPosLastVM and handPosLastVM.Parent then
			pcall(function()
				local current = handPosLastVM:GetPivot()
				
				
				
				if handPosLastWritten and handPosBase and current == handPosLastWritten then
					handPosLastVM:PivotTo(handPosBase)
				end
			end)
		end
		handPosHasApplied = false
		handPosLastWritten = nil
		handPosBase = nil
	end

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
	Runtime.GetCalamariViewmodel = getViewmodel

	local function startHandPos()
		if handPosConn then handPosConn:Disconnect(); handPosConn = nil end
		handPosConn = RunService.RenderStepped:Connect(function()
			if Runtime.Unloaded then return end
			local vm = getViewmodel()
			if vm ~= handPosLastVM then
				restoreHandPosition()
				handPosLastVM = vm
			end
			if handPosEnabled and vm then
				local desired = CFrame.new(ViewmodelConfig.X, ViewmodelConfig.Y, ViewmodelConfig.Z)
				local current = vm:GetPivot()
				local base = current
				
				
				if handPosHasApplied and handPosLastWritten and handPosBase and current == handPosLastWritten then
					base = handPosBase
				end
				local written = base * desired
				vm:PivotTo(written)
				handPosLastWritten = written
				handPosBase = base
				handPosHasApplied = true
			elseif handPosHasApplied then
				restoreHandPosition()
			end
		end)
	end
	startHandPos()
	onCleanup(function()
		handPosEnabled = false
		restoreHandPosition()
		if handPosConn then handPosConn:Disconnect(); handPosConn = nil end
		handPosLastVM = nil
	end)

	local handSet = createFeature(lc, "Custom Hand Position", false, function(v)
		handPosEnabled = v
		if not v then
			restoreHandPosition()
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
	Runtime.PickupSeen = {}

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
						if ch:IsA("TextLabel") and ch.Name=="Example" then
							local text = ch.Text
							if text == "" then
								Runtime.PickupSeen[ch] = nil
							elseif Runtime.PickupSeen[ch] ~= text then
								Runtime.PickupSeen[ch] = text
								notify(text)
							end
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)
end

local circleFill = newDrawing("Circle")
circleFill.Radius = S.FOV
circleFill.Thickness = 0
circleFill.NumSides = 64
circleFill.Color = AC_FOV_FILL
circleFill.Transparency = S.FOVFillTransparency
circleFill.Filled = true
circleFill.Visible = false
circleFill.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
pcall(function() circleFill.ZIndex = 1 end)

local circle = newDrawing("Circle")
circle.Radius = S.FOV
circle.Thickness = 1
circle.NumSides = 64
circle.Color = AC_FOV
circle.Transparency = 1
circle.Filled = false
circle.Visible = S.FOVCircle
circle.Position = circleFill.Position
pcall(function() circle.ZIndex = 2 end)

local TargetLine = newDrawing("Line")
TargetLine.Visible = false
TargetLine.Color = S.MBTargetLineColor
TargetLine.Thickness = 1
TargetLine.Transparency = 1
pcall(function() TargetLine.ZIndex = 3 end)




local ESPBoxes, TracerObjs, NameObjs, DistObjs = {}, {}, {}, {}
local ESPCorners, ESPFills, HPBars = {}, {}, {}
local WeaponObjs, HPTextObjs, ChamsObjs = {}, {}, {}

local _espLastUpdate = 0
local espConnection

do
local function initializeESP()
local ESPCoreGui = game:GetService("CoreGui")

local function removeDrawing(object)
	Runtime.RemoveDrawing(object)
end

local function hideCorners(player)
	for _, line in ipairs(ESPCorners[player] or {}) do line.Visible = false end
end

local function hideESP2D(player)
	if ESPBoxes[player] then ESPBoxes[player].Visible = false end
	if ESPFills[player] then ESPFills[player].Visible = false end
	hideCorners(player)
	if TracerObjs[player] then
		TracerObjs[player][1].Visible = false
		TracerObjs[player][2].Visible = false
	end
	if NameObjs[player] then NameObjs[player].Visible = false end
	if DistObjs[player] then DistObjs[player].Visible = false end
	if WeaponObjs[player] then WeaponObjs[player].Visible = false end
	if HPBars[player] then
		HPBars[player].bg.Visible = false
		HPBars[player].fg.Visible = false
	end
	if HPTextObjs[player] then HPTextObjs[player].Visible = false end
end

local function destroyChams(player)
	local highlight = ChamsObjs[player]
	ChamsObjs[player] = nil
	if highlight then pcall(function() highlight:Destroy() end) end
end

local function destroyAllChams()
	for player in pairs(ChamsObjs) do destroyChams(player) end
end

local function removeESP(player)
	hideESP2D(player)
	destroyChams(player)
	removeDrawing(ESPBoxes[player])
	removeDrawing(ESPFills[player])
	removeDrawing(NameObjs[player])
	removeDrawing(DistObjs[player])
	removeDrawing(WeaponObjs[player])
	removeDrawing(HPTextObjs[player])
	if TracerObjs[player] then
		for _, line in ipairs(TracerObjs[player]) do removeDrawing(line) end
	end
	if HPBars[player] then
		removeDrawing(HPBars[player].bg)
		removeDrawing(HPBars[player].fg)
	end
	for _, line in ipairs(ESPCorners[player] or {}) do removeDrawing(line) end
	ESPBoxes[player] = nil
	ESPFills[player] = nil
	ESPCorners[player] = nil
	TracerObjs[player] = nil
	NameObjs[player] = nil
	DistObjs[player] = nil
	WeaponObjs[player] = nil
	HPTextObjs[player] = nil
	HPBars[player] = nil
end

local function createESP(player)
	if Runtime.Unloaded or player == LocalPlayer or ESPBoxes[player] then return end
	local box = newDrawing("Square")
	box.Color = AC_ESP
	box.Thickness = 1
	box.Filled = false
	box.Transparency = 1
	box.Visible = false

	local fill = newDrawing("Square")
	fill.Color = AC_FILL
	fill.Thickness = 0
	fill.Filled = true
	fill.Transparency = S.BoxFillTransparency
	fill.Visible = false

	local corners = {}
	for index = 1, 8 do
		local line = newDrawing("Line")
		line.Color = AC_ESP
		line.Thickness = 1
		line.Transparency = 1
		line.Visible = false
		corners[index] = line
	end

	local tracer = newDrawing("Line")
	tracer.Color = AC_TR
	tracer.Thickness = 1
	tracer.Transparency = 1
	tracer.Visible = false
	local tracerOutline = newDrawing("Line")
	tracerOutline.Color = Color3.fromRGB(0, 0, 0)
	tracerOutline.Thickness = 3
	tracerOutline.Transparency = 1
	tracerOutline.Visible = false

	local name = newDrawing("Text")
	name.Size = 12
	name.Center = true
	name.Outline = true
	name.Color = AC_NAME
	name.Transparency = 1
	name.Visible = false

	local distance = newDrawing("Text")
	distance.Size = 11
	distance.Center = true
	distance.Outline = true
	distance.Color = AC_DIST
	distance.Transparency = 1
	distance.Visible = false

	local weapon = newDrawing("Text")
	weapon.Size = 11
	weapon.Center = true
	weapon.Outline = true
	weapon.Color = AC_WEAPON
	weapon.Transparency = 1
	weapon.Visible = false

	local hpBg = newDrawing("Square")
	hpBg.Filled = true
	hpBg.Color = Color3.fromRGB(0, 0, 0)
	hpBg.Transparency = 0.5
	hpBg.Visible = false
	local hpFg = newDrawing("Square")
	hpFg.Filled = true
	hpFg.Color = AC_HP
	hpFg.Transparency = 1
	hpFg.Visible = false

	local hpText = newDrawing("Text")
	hpText.Size = 10
	hpText.Center = true
	hpText.Outline = true
	hpText.Color = AC_HP
	hpText.Transparency = 1
	hpText.Visible = false

	ESPBoxes[player] = box
	ESPFills[player] = fill
	ESPCorners[player] = corners
	TracerObjs[player] = {tracer, tracerOutline}
	NameObjs[player] = name
	DistObjs[player] = distance
	WeaponObjs[player] = weapon
	HPBars[player] = {bg = hpBg, fg = hpFg}
	HPTextObjs[player] = hpText
end

local function updateChams(player, character)
	if not S.ESPChams then
		destroyChams(player)
		return
	end
	local highlight = ChamsObjs[player]
	if not highlight then
		local ok, object = pcall(Instance.new, "Highlight")
		if not ok or not object then return end
		highlight = object
		ChamsObjs[player] = highlight
	end
	pcall(function()
		highlight.Name = "BurmaldaHookESP"
		highlight.Adornee = character
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = AC_CHAMS
		highlight.OutlineColor = AC_CHAMS_OUTLINE
		highlight.FillTransparency = S.ChamsFillTransparency
		highlight.OutlineTransparency = S.ChamsOutlineTransparency
		if highlight.Parent ~= ESPCoreGui then highlight.Parent = ESPCoreGui end
		highlight.Enabled = true
	end)
end

local function setCornerLine(player, index, ax, ay, bx, by, color)
	local line = ESPCorners[player][index]
	line.From = Vector2.new(ax, ay)
	line.To = Vector2.new(bx, by)
	line.Color = color
	line.Visible = true
end

local function drawCornerBox(player, x, y, sx, sy, color)
	local armX = math.max(3, math.min(12, sx * 0.35))
	local armY = math.max(3, math.min(12, sy * 0.35))
	setCornerLine(player, 1, x, y, x + armX, y, color)
	setCornerLine(player, 2, x, y, x, y + armY, color)
	setCornerLine(player, 3, x + sx - armX, y, x + sx, y, color)
	setCornerLine(player, 4, x + sx, y, x + sx, y + armY, color)
	setCornerLine(player, 5, x, y + sy, x + armX, y + sy, color)
	setCornerLine(player, 6, x, y + sy - armY, x, y + sy, color)
	setCornerLine(player, 7, x + sx - armX, y + sy, x + sx, y + sy, color)
	setCornerLine(player, 8, x + sx, y + sy - armY, x + sx, y + sy, color)
end

local HP_LOW = Color3.fromRGB(255, 60, 60)
local HP_MEDIUM = Color3.fromRGB(255, 193, 0)
local HP_HIGH = Color3.fromRGB(80, 220, 100)
local function getHealthColor(ratio)
	if not S.HPDynamicColor then return AC_HP end
	if ratio < 0.5 then return HP_LOW:Lerp(HP_MEDIUM, ratio * 2) end
	return HP_MEDIUM:Lerp(HP_HIGH, (ratio - 0.5) * 2)
end

for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
	if not Runtime.Unloaded then createESP(player) end
end)
local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
	if Runtime.Unloaded then return end
	removeESP(player)
	if player.Character then
		local head = player.Character:FindFirstChild("Head")
		if head then
			_visCache[head] = nil
			_visCacheTime[head] = nil
		end
	end
end)
onCleanup(function()
	if playerAddedConnection then playerAddedConnection:Disconnect(); playerAddedConnection = nil end
	if playerRemovingConnection then playerRemovingConnection:Disconnect(); playerRemovingConnection = nil end
	destroyAllChams()
	table.clear(_visCache)
	table.clear(_visCacheTime)
end)

local function updateESPPlayer(player, box, context)
	local screenSize = context.screenSize
	local center = context.center
	local cameraPosition = context.cameraPosition
	local espEnabled = context.espEnabled
	local tracersOn = context.tracersOn
	local namesOn = context.namesOn
	local hpBarOn = context.hpBarOn
	local espRadius = context.espRadius
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then
			hideESP2D(player)
			destroyChams(player)
			return
		end

		local rootPosition = root.Position
		local distance3D = (cameraPosition - rootPosition).Magnitude
		if distance3D > espRadius then
			hideESP2D(player)
			destroyChams(player)
			return
		end

		updateChams(player, character)
		local projected, onScreen = Camera:WorldToViewportPoint(rootPosition)
		if not onScreen then
			hideESP2D(player)
			return
		end
		local screenPosition = Vector2.new(projected.X, projected.Y)
		local top = Camera:WorldToViewportPoint(rootPosition + Vector3.new(0, 3, 0))
		local bottom = Camera:WorldToViewportPoint(rootPosition - Vector3.new(0, 3, 0))
		local sx = 8
		local sy = 12
		local x = screenPosition.X - sx * 0.5
		local y = screenPosition.Y - sy * 0.5
		if top and bottom then
			sy = math.max(math.abs(top.Y - bottom.Y), 12)
			sx = math.max(sy * 0.6, 8)
			x = (top.X + bottom.X) * 0.5 - sx * 0.5
			y = math.min(top.Y, bottom.Y)
		end

		if espEnabled then
			local cornerStyle = S.ESPBoxType == "Corner"
			box.Visible = not cornerStyle
			box.Size = Vector2.new(sx, sy)
			box.Position = Vector2.new(x, y)
			box.Color = AC_ESP
			if cornerStyle then
				drawCornerBox(player, x, y, sx, sy, AC_ESP)
			else
				hideCorners(player)
			end
			local fill = ESPFills[player]
			fill.Visible = S.BoxFill
			if S.BoxFill then
				fill.Size = Vector2.new(sx, sy)
				fill.Position = Vector2.new(x, y)
				fill.Color = AC_FILL
				fill.Transparency = S.BoxFillTransparency
			end
		else
			box.Visible = false
			ESPFills[player].Visible = false
			hideCorners(player)
		end

		if tracersOn then
			local tracer = TracerObjs[player][1]
			local fromY = S.TracerOrigin == 1 and 0 or S.TracerOrigin == 2 and screenSize.Y or center.Y
			tracer.From = Vector2.new(center.X, fromY)
			tracer.To = screenPosition
			tracer.Color = AC_TR
			tracer.Visible = true
			TracerObjs[player][2].Visible = false
		else
			TracerObjs[player][1].Visible = false
			TracerObjs[player][2].Visible = false
		end

		if namesOn then
			NameObjs[player].Text = player.Name
			NameObjs[player].Position = Vector2.new(x + sx * 0.5, y - 12)
			NameObjs[player].Color = AC_NAME
			NameObjs[player].Visible = true
		else
			NameObjs[player].Visible = false
		end

		if S.ESPDist then
			DistObjs[player].Text = math.floor(distance3D + 0.5) .. " m"
			DistObjs[player].Position = Vector2.new(x + sx * 0.5, y + sy + 4)
			DistObjs[player].Color = AC_DIST
			DistObjs[player].Visible = true
		else
			DistObjs[player].Visible = false
		end

		if S.ESPWeapon then
			local tool = character:FindFirstChildOfClass("Tool")
			WeaponObjs[player].Text = tool and tool.Name or "Unarmed"
			WeaponObjs[player].Position = Vector2.new(x + sx * 0.5, y + sy + (S.ESPDist and 18 or 4))
			WeaponObjs[player].Color = AC_WEAPON
			WeaponObjs[player].Visible = true
		else
			WeaponObjs[player].Visible = false
		end

		if hpBarOn then
			local ratio = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
			local healthColor = getHealthColor(ratio)
			local hpBg = HPBars[player].bg
			local hpFg = HPBars[player].fg
			local barWidth = 3
			if S.HPBarSide == 1 then
				local bx = x - barWidth - 3
				hpBg.Size = Vector2.new(barWidth, sy)
				hpBg.Position = Vector2.new(bx, y)
				hpFg.Size = Vector2.new(barWidth, sy * ratio)
				hpFg.Position = Vector2.new(bx, y + sy * (1 - ratio))
				if S.HPHealthNumber then
					HPTextObjs[player].Position = Vector2.new(bx - 10, y + sy * (1 - ratio))
				end
			else
				local by = y - barWidth - 3
				hpBg.Size = Vector2.new(sx, barWidth)
				hpBg.Position = Vector2.new(x, by)
				hpFg.Size = Vector2.new(sx * ratio, barWidth)
				hpFg.Position = Vector2.new(x, by)
				if S.HPHealthNumber then
					HPTextObjs[player].Position = Vector2.new(x + sx * ratio, by - 7)
				end
			end
			hpBg.Visible = true
			hpFg.Color = healthColor
			hpFg.Visible = true
			HPTextObjs[player].Text = tostring(math.floor(humanoid.Health + 0.5))
			HPTextObjs[player].Color = healthColor
			HPTextObjs[player].Visible = S.HPHealthNumber
		else
			HPBars[player].bg.Visible = false
			HPBars[player].fg.Visible = false
			HPTextObjs[player].Visible = false
		end
	end

local _ESP_INTERVAL = 1 / 30
espConnection = RunService.RenderStepped:Connect(function()
	if Runtime.Unloaded then return end
	local now = tick()
	local interval = S.LowPC and 0.1 or _ESP_INTERVAL
	if now - _espLastUpdate < interval then return end
	_espLastUpdate = now

	local currentCamera = workspace.CurrentCamera
	if currentCamera then Camera = currentCamera end
	if not Camera then
		circle.Visible = false
		circleFill.Visible = false
		TargetLine.Visible = false
		for player in pairs(ESPBoxes) do hideESP2D(player) end
		destroyAllChams()
		return
	end
	local screenSize = Camera.ViewportSize
	local center = Vector2.new(screenSize.X * 0.5, screenSize.Y * 0.5)
	local cameraPosition = Camera.CFrame.Position
	local fovPosition = S.MBFovMode == "pc" and UIS:GetMouseLocation() or center

	if S.FOVCircle then
		circle.Visible = true
		circle.Transparency = 1
		circle.Filled = false
		circle.Position = fovPosition
		circle.Radius = S.FOV
		circle.Color = S.SilentAim and SA_CurrentTarget and AC_FOV_TARGET or AC_FOV
		circleFill.Visible = S.FOVFill
		circleFill.Position = fovPosition
		circleFill.Radius = S.FOV
		circleFill.Color = AC_FOV_FILL
		circleFill.Transparency = S.FOVFillTransparency
	else
		circle.Visible = false
		circleFill.Visible = false
	end

	if S.MBTargetLine and SA_CurrentTarget and SA_CurrentTarget.Parent then
		local worldPosition = SA_CurrentTarget.Position
		if S.SilentAim and ProjectileSilent and ProjectileSilent.TargetPart == SA_CurrentTarget
			and typeof(ProjectileSilent.TargetPosition) == "Vector3" then
			worldPosition = ProjectileSilent.TargetPosition
		end
		local targetPosition = Camera:WorldToViewportPoint(worldPosition)
		TargetLine.From = fovPosition
		TargetLine.To = Vector2.new(targetPosition.X, targetPosition.Y)
		TargetLine.Color = S.MBTargetLineColor
		TargetLine.Visible = true
	else
		TargetLine.Visible = false
	end

	local espEnabled = S.ESPEnabled
	local tracersOn = S.Tracers
	local namesOn = S.Names
	local hpBarOn = S.HPBar
	local espRadius = S.ESPRadius
	local anyESP = espEnabled or tracersOn or namesOn or hpBarOn
		or S.ESPDist or S.ESPWeapon or S.ESPChams
	if not anyESP then
		for player in pairs(ESPBoxes) do hideESP2D(player) end
		destroyAllChams()
		return
	end

	local context = {
		screenSize = screenSize,
		center = center,
		cameraPosition = cameraPosition,
		espEnabled = espEnabled,
		tracersOn = tracersOn,
		namesOn = namesOn,
		hpBarOn = hpBarOn,
		espRadius = espRadius,
	}
	Runtime.ESPLastError = nil
	for player, box in pairs(ESPBoxes) do
		local ok, err = pcall(updateESPPlayer, player, box, context)
		if not ok then
			hideESP2D(player)
			destroyChams(player)
			Runtime.ESPLastError = tostring(err)
		end
	end
end)
end
initializeESP()
end 
onCleanup(function()
	if espConnection then espConnection:Disconnect() end
end)






local projectileInitOK, projectileInitError = pcall(function()
	ProjectileCore = {
		Running = true,
		GunBaseRedirecting = false,
		Status = {
			gunbase = false,
			raycast = true,
			calls = 0,
			normalCalls = 0,
			redirects = 0,
			remoteCalls = 0,
			remoteRedirects = 0,
			fallbackSkips = 0,
			nonCombatSkips = 0,
			actionSkips = 0,
			explosiveSkips = 0,
			bufferWrites = 0,
			target = "inactive",
			visiblePointChecks = 0,
			lastShotReason = "not-fired",
		},
	}
	ProjectileSilent = {
		TargetPart = nil,
		TargetPosition = nil,
		
		
		TargetOffset = nil,
		TargetPlayer = nil,
		TargetCharacter = nil,
		TargetHumanoid = nil,
		TargetVisible = false,
		LastShotPart = nil,
		LastShotAt = nil,
		HeldTool = nil,
		HeldToolName = "",
		ExplosiveTool = false,
		Installed = { GunBase = false },
	}

	
	
	local function hasExplosiveName(name)
		if type(name) ~= "string" then return false end
		local lower = string.lower(name)
		for _, pattern in ipairs({
			"c4", "c%-4", "rocket", "rpg", "launcher", "grenade", "bomb",
			"dynamite", "satchel", "explosive", "molotov", "landmine", "tnt",
			"detonator", "detonate", "^ied", "^mine",
		}) do
			if string.find(lower, pattern) then return true end
		end
		return false
	end
	local function refreshHeldTool()
		local character = LocalPlayer.Character
		local tool = character and character:FindFirstChildOfClass("Tool")
		local name = tool and tostring(tool.Name or "") or ""
		ProjectileSilent.HeldTool = tool
		ProjectileSilent.HeldToolName = name
		ProjectileSilent.ExplosiveTool = hasExplosiveName(name)
	end
	ProjectileSilent.RefreshHeldTool = refreshHeldTool
	ProjectileSilent.IsExplosiveContext = function(remote)
		return ProjectileSilent.ExplosiveTool == true or hasExplosiveName(remote and remote.Name)
	end

	
	
	
	local weaponActionAt, weaponActionTool, weaponActionProven = nil, nil, false
	local weaponMouseHeld = false
	local shotConnections, watchedTools = {}, setmetatable({}, {__mode = "k"})
	local function trackShotConnection(connection)
		if connection then table.insert(shotConnections, connection) end
		return connection
	end
	local function noteWeaponAction(tool, proven)
		refreshHeldTool()
		tool = tool or ProjectileSilent.HeldTool
		if tool and ProjectileSilent.ExplosiveTool then return end
		weaponActionAt = os.clock()
		weaponActionTool = tool
		weaponActionProven = proven == true
	end
	ProjectileSilent.NoteWeaponAction = noteWeaponAction
	local function hasWeaponAction()
		if not ProjectileCore.Running or not S.SilentAim or Runtime.CraftingMenuOpen then return false end
		
		if ProjectileSilent.ExplosiveTool then return false end
		local now = os.clock()
		local recent = weaponActionAt ~= nil and now - weaponActionAt >= 0 and now - weaponActionAt <= 0.35
		local currentTool = ProjectileSilent.HeldTool
		if recent and (weaponActionProven or weaponActionTool ~= nil) then return true end
		
		return currentTool ~= nil and weaponMouseHeld
	end
	ProjectileSilent.HasWeaponAction = hasWeaponAction
	local function noteShot(target)
		ProjectileSilent.LastShotPart = target
		ProjectileSilent.LastShotAt = os.clock()
	end
	ProjectileSilent.NoteShot = noteShot
	local function watchTool(tool)
		if not tool or watchedTools[tool] or not tool:IsA("Tool") then return end
		watchedTools[tool] = true
		local ok, connection = pcall(function()
			return tool.Activated:Connect(function() noteWeaponAction(tool, false) end)
		end)
		if ok then trackShotConnection(connection) end
	end
	local function watchCharacter(character)
		if not character then return end
		for _, child in ipairs(character:GetChildren()) do watchTool(child) end
		trackShotConnection(character.ChildAdded:Connect(watchTool))
	end
	watchCharacter(LocalPlayer.Character)
	trackShotConnection(LocalPlayer.CharacterAdded:Connect(watchCharacter))
	trackShotConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
			weaponMouseHeld = true
		end
	end))
	trackShotConnection(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then weaponMouseHeld = false end
	end))

	local function clearTarget()
		ProjectileSilent.TargetPart = nil
		ProjectileSilent.TargetPosition = nil
		ProjectileSilent.TargetOffset = nil
		ProjectileSilent.TargetPlayer = nil
		ProjectileSilent.TargetCharacter = nil
		ProjectileSilent.TargetHumanoid = nil
		ProjectileSilent.TargetVisible = false
	end

	local function setTarget(part, player, humanoid, position)
		ProjectileSilent.TargetPart = part
		ProjectileSilent.TargetPosition = position
		ProjectileSilent.TargetOffset = part and position and (position - part.Position) or nil
		ProjectileSilent.TargetPlayer = player
		ProjectileSilent.TargetCharacter = player and player.Character or nil
		ProjectileSilent.TargetHumanoid = humanoid
		ProjectileSilent.TargetVisible = part ~= nil and position ~= nil
	end

	
	
	local randomPartCache = setmetatable({}, {__mode = "k"})
	local function targetPartFor(character)
		local function getPart(name)
			local object = character:FindFirstChild(name)
			if object and object:IsA("BasePart") then return object end
			return nil
		end
		if S.MBTargetPart == 2 then
			return getPart("Head") or getPart("HeadHitbox") or getPart("HumanoidRootPart")
		end
		if S.MBTargetPart == 3 then
			return getPart("HumanoidRootPart") or getPart("HeadHitbox") or getPart("Head")
		end
		if S.MBTargetPart == 4 then
			local cached = randomPartCache[character]
			if cached and cached.Parent == character and cached:IsA("BasePart") then return cached end
			local candidates = {}
			for _, name in ipairs({"HeadHitbox", "Head", "HumanoidRootPart"}) do
				local part = getPart(name)
				if part then table.insert(candidates, part) end
			end
			if #candidates > 0 then
				local selected = candidates[math.random(1, #candidates)]
				randomPartCache[character] = selected
				return selected
			end
			randomPartCache[character] = nil
			return nil
		end
		return getPart("HeadHitbox") or getPart("Head") or getPart("HumanoidRootPart")
	end
	ProjectileSilent.ResolveTargetPart = targetPartFor

	
	
	
	local visibleParams = RaycastParams.new()
	visibleParams.FilterType = Enum.RaycastFilterType.Exclude
	visibleParams.IgnoreWater = true
	local ignoreCache, lastIgnoreRefresh = {}, -1000
	local ignoredCamera, ignoredLocalCharacter = nil, nil
	local testOffsets = {Vector3.new(0, 0, 0)}
	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do table.insert(testOffsets, Vector3.new(x * 0.5, y * 0.5, z * 0.5)) end
		end
	end
	for _, offset in ipairs({
		Vector3.new(0.5, 0, 0), Vector3.new(-0.5, 0, 0),
		Vector3.new(0, 0.5, 0), Vector3.new(0, -0.5, 0),
		Vector3.new(0, 0, 0.5), Vector3.new(0, 0, -0.5),
	}) do table.insert(testOffsets, offset) end
	local function isIgnoredDecoration(instance)
		if instance.CanQuery == false then return true end
		if not instance:IsA("BasePart") or instance.CanCollide ~= false then return false end
		local current = instance
		for _ = 1, 6 do
			if not current then break end
			if current.ClassName == "Tool" then return false end
			local name = string.lower(tostring(current.Name))
			if string.find(name, "grass", 1, true)
				or string.find(name, "leav", 1, true)
				or string.find(name, "foliage", 1, true)
				or string.find(name, "bush", 1, true)
				or string.find(name, "shrub", 1, true)
				or string.find(name, "fern", 1, true)
				or string.find(name, "flower", 1, true)
				or string.find(name, "reed", 1, true)
				or string.find(name, "cloud", 1, true) then
				return true
			end
			current = current.Parent
		end
		return false
	end
	local function pointVisible(character, worldPoint, camera)
		local now = os.clock()
		local localCharacter = LocalPlayer.Character
		if now - lastIgnoreRefresh >= 0.5 or ignoredCamera ~= camera or ignoredLocalCharacter ~= localCharacter then
			lastIgnoreRefresh = now
			ignoredCamera, ignoredLocalCharacter = camera, localCharacter
			ignoreCache = {localCharacter, camera}
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character then table.insert(ignoreCache, player.Character) end
			end
		end
		local origin = camera.CFrame.Position
		local direction = worldPoint - origin
		local added = 0
		for _ = 1, 16 do
			visibleParams.FilterDescendantsInstances = ignoreCache
			local result = workspace:Raycast(origin, direction, visibleParams)
			if not result then
				for _ = 1, added do table.remove(ignoreCache) end
				return true
			end
			local instance = result.Instance
			if not instance then
				for _ = 1, added do table.remove(ignoreCache) end
				return false
			end
			if instance:IsDescendantOf(character) then
				for _ = 1, added do table.remove(ignoreCache) end
				return true
			end
			if not isIgnoredDecoration(instance) then
				for _ = 1, added do table.remove(ignoreCache) end
				return false
			end
			ignoreCache[#ignoreCache + 1] = instance
			added += 1
		end
		for _ = 1, added do table.remove(ignoreCache) end
		return false
	end
	local visibleOffsetCache = setmetatable({}, {__mode = "k"})
	local function getVisiblePoint(part, character, camera)
		if not part or not part:IsA("BasePart") then return nil end
		ProjectileCore.Status.visiblePointChecks += 1
		local centerOffset = testOffsets[1]
		local centerPoint = part.CFrame:PointToWorldSpace(centerOffset * part.Size)
		if pointVisible(character, centerPoint, camera) then
			visibleOffsetCache[part] = centerOffset
			return part.Position
		end

		local previousOffset = visibleOffsetCache[part]
		if previousOffset and previousOffset ~= centerOffset then
			local previousPoint = part.CFrame:PointToWorldSpace(previousOffset * part.Size)
			if pointVisible(character, previousPoint, camera) then return previousPoint end
		end
		for index = 2, #testOffsets do
			local offset = testOffsets[index]
			if offset ~= previousOffset then
				local worldPoint = part.CFrame:PointToWorldSpace(offset * part.Size)
				if pointVisible(character, worldPoint, camera) then
					visibleOffsetCache[part] = offset
					return worldPoint
				end
			end
		end
		visibleOffsetCache[part] = nil
		return nil
	end

	local function updateTarget()
		refreshHeldTool()
		if not ProjectileCore.Running or not S.SilentAim then
			clearTarget()
			ProjectileCore.Status.target = S.SilentAim and "starting" or "inactive"
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then
			clearTarget()
			ProjectileCore.Status.target = "no-camera"
			return
		end
		local viewport = camera.ViewportSize
		local center = S.MBFovMode == "pc" and UIS:GetMouseLocation()
			or Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
		local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local worldOrigin = localRoot and localRoot.Position or camera.CFrame.Position
		local bestPart, bestPlayer, bestPosition, bestHumanoid = nil, nil, nil, nil
		local bestDistance, bestHP = math.huge, math.huge

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if character and humanoid and humanoid.Health > 0 then
					local part = targetPartFor(character)
					if part then
						if (part.Position - worldOrigin).Magnitude > S.MBMaxDist then continue end
						local targetPosition = part.Position
						if S.MBVisibleOnly then
							targetPosition = getVisiblePoint(part, character, camera)
						end
						if targetPosition then
							local distance3D = (part.Position - worldOrigin).Magnitude
							if distance3D <= S.MBMaxDist then
								local projected, onScreen = camera:WorldToViewportPoint(targetPosition)
								if onScreen and projected.Z > 0 then
									local screenDistance = (Vector2.new(projected.X, projected.Y) - center).Magnitude
									if not S.MBUseFOV or screenDistance <= S.FOV then
										local hp = humanoid.Health
										if S.MBPriority == "hp" then
											if hp < bestHP or (hp == bestHP and screenDistance < bestDistance) then
												bestPart, bestPlayer, bestPosition, bestHumanoid = part, player, targetPosition, humanoid
												bestDistance, bestHP = screenDistance, hp
											end
										elseif screenDistance < bestDistance then
											bestPart, bestPlayer, bestPosition, bestHumanoid = part, player, targetPosition, humanoid
											bestDistance, bestHP = screenDistance, hp
										end
									end
								end
							end
						end
					end
				end
			end
		end

		if bestPart then
			setTarget(bestPart, bestPlayer, bestHumanoid, bestPosition)
			ProjectileCore.Status.target = "ok"
		else
			clearTarget()
			ProjectileCore.Status.target = "no-target"
		end
	end
	ProjectileSilent.Update = updateTarget

	
	
	local function getLiveTarget()
		local target = ProjectileSilent.TargetPart
		local character = ProjectileSilent.TargetCharacter
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not target or not target.Parent or not character or not humanoid or humanoid.Health <= 0
			or not target:IsA("BasePart") or not target:IsDescendantOf(character) then
			clearTarget()
			ProjectileCore.Status.target = "stale"
			return nil
		end
		local camera = workspace.CurrentCamera
		if not camera then
			clearTarget()
			ProjectileCore.Status.target = "no-camera"
			return nil
		end
		local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local worldOrigin = localRoot and localRoot.Position or camera.CFrame.Position
		if (target.Position - worldOrigin).Magnitude > S.MBMaxDist then
			clearTarget()
			ProjectileCore.Status.target = "stale-distance"
			return nil
		end
		local targetPosition = target.Position
		if S.MBVisibleOnly then
			
			
			targetPosition = getVisiblePoint(target, character, camera)
			if not targetPosition then
				clearTarget()
				ProjectileCore.Status.target = "stale-not-visible"
				return nil
			end
		end
		local projected, onScreen = camera:WorldToViewportPoint(targetPosition)
		local viewport = camera.ViewportSize
		local center = S.MBFovMode == "pc" and UIS:GetMouseLocation()
			or Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
		if not onScreen or projected.Z <= 0 or (S.MBUseFOV
			and (Vector2.new(projected.X, projected.Y) - center).Magnitude > S.FOV) then
			clearTarget()
			ProjectileCore.Status.target = "stale-fov"
			return nil
		end
		setTarget(target, ProjectileSilent.TargetPlayer, humanoid, targetPosition)
		ProjectileCore.Status.target = "ok"
		return target, targetPosition
	end
	ProjectileSilent.GetTarget = getLiveTarget

	
	
	local GunBase, originalFire, replacementFire = nil, nil, nil
	local gunBaseWaitRunning = false
	local function installGunBase(module)
		if ProjectileSilent.Installed.GunBase then return true end
		if not ProjectileCore.Running then return false end
		
		
		if not S.SilentAim then
			ProjectileCore.Status.lastShotReason = "gunbase-standby"
			return false
		end
		if not module then
			local gun = ReplicatedStorage:FindFirstChild("Gun")
			local scripts = gun and gun:FindFirstChild("Scripts")
			module = scripts and scripts:FindFirstChild("GunBase")
			module = module or ReplicatedStorage:FindFirstChild("GunBase", true)
		end
		if not module then
			ProjectileCore.Status.lastShotReason = "gunbase-waiting"
			if not gunBaseWaitRunning then
				gunBaseWaitRunning = true
				task.spawn(function()
					local ok, waitedModule = pcall(function()
						local gun = ReplicatedStorage:WaitForChild("Gun", 20)
						local scripts = gun and gun:WaitForChild("Scripts", 20)
						return scripts and scripts:WaitForChild("GunBase", 20) or nil
					end)
					gunBaseWaitRunning = false
					if ok and waitedModule and ProjectileCore.Running and S.SilentAim then
						installGunBase(waitedModule)
					end
				end)
			end
			return false
		end
		local loaded, requireError = Runtime.RequireGameModule(module)
		if type(loaded) ~= "table" or type(loaded.fire) ~= "function" then
			ProjectileCore.Status.lastShotReason = requireError or "gunbase-fire-missing"
			return false
		end
		GunBase = loaded
		originalFire = GunBase.fire

		replacementFire = function(self, ...)
			if not ProjectileCore.Running then
				return originalFire(self, ...)
			end
			ProjectileCore.Status.calls += 1
			noteWeaponAction(nil, true)
			if not S.SilentAim or Runtime.CraftingMenuOpen then
				ProjectileCore.Status.normalCalls += 1
				ProjectileCore.Status.lastShotReason = Runtime.CraftingMenuOpen and "crafting-menu-original" or "silent-inactive-original"
				return originalFire(self, ...)
			end
			refreshHeldTool()
			if ProjectileSilent.ExplosiveTool then
				ProjectileCore.Status.explosiveSkips += 1
				ProjectileCore.Status.lastShotReason = "explosive-original"
				return originalFire(self, ...)
			end
			local target, livePosition = getLiveTarget()
			if not target then
				ProjectileCore.Status.lastShotReason = ProjectileCore.Status.target == "stale-not-visible"
					and "wall-original" or "no-target-original"
				return originalFire(self, ...)
			end
			if math.random(1, 100) > S.MBHitChance then
				ProjectileCore.Status.lastShotReason = "gunbase-hit-chance-original"
				return originalFire(self, ...)
			end

			local args = table.pack(...)
			local targetPosition = livePosition or target.Position
			local patched = false
			for index = 1, args.n do
				local value = args[index]
				if typeof(value) == "Vector3" and not patched then
					args[index] = targetPosition
					patched = true
				elseif typeof(value) == "buffer" and not patched and type(buffer) == "table" and type(buffer.writef32) == "function" then
					local writeOK = pcall(function()
						buffer.writef32(value, 4, targetPosition.X)
						buffer.writef32(value, 8, targetPosition.Y)
						buffer.writef32(value, 12, targetPosition.Z)
					end)
					if writeOK then
						patched = true
						ProjectileCore.Status.bufferWrites += 1
					end
				end
			end
			if not patched then
				ProjectileCore.Status.lastShotReason = "args-unmatched-original"
				return originalFire(self, unpack(args, 1, args.n))
			end

			ProjectileCore.Status.redirects += 1
			ProjectileCore.Status.lastShotReason = "gunbase-redirected"
			noteShot(target)
			
			
			local previousGunBaseShot = ProjectileCore.GunBaseRedirecting
			ProjectileCore.GunBaseRedirecting = true
			local results = table.pack(pcall(originalFire, self, unpack(args, 1, args.n)))
			ProjectileCore.GunBaseRedirecting = previousGunBaseShot
			if not results[1] then error(results[2], 0) end
			return unpack(results, 2, results.n)
		end

		local assigned = pcall(function() GunBase.fire = replacementFire end)
		if not assigned or GunBase.fire ~= replacementFire then
			ProjectileCore.Status.lastShotReason = "gunbase-assign-failed"
			GunBase, originalFire, replacementFire = nil, nil, nil
			return false
		end
		ProjectileSilent.Installed.GunBase = true
		ProjectileCore.Status.gunbase = true
		ProjectileCore.Status.lastShotReason = "gunbase-ready"
		return true
	end
	ProjectileSilent.Refresh = installGunBase
	refreshHeldTool()

	onCleanup(function()
		clearTarget()
		ProjectileSilent.LastShotPart = nil
		ProjectileSilent.LastShotAt = nil
		weaponActionAt, weaponActionTool = nil, nil
		weaponMouseHeld = false
		for index = #shotConnections, 1, -1 do
			pcall(function() shotConnections[index]:Disconnect() end)
		end
		table.clear(shotConnections)
		ProjectileCore.GunBaseRedirecting = false
		if GunBase and originalFire and GunBase.fire == replacementFire then
			pcall(function() GunBase.fire = originalFire end)
		end
		ProjectileSilent.Installed.GunBase = false
		ProjectileCore.Status.gunbase = false
	end)

	Runtime.Projectile = ProjectileSilent
	Runtime.ProjectileStatus = ProjectileCore.Status
	Runtime.ProjectilePath = "GunBase.fire + FireServer + Workspace Raycast"
	Runtime.SilentPath = Runtime.ProjectilePath
	Runtime.GetSilentStatus = function()
		local status = ProjectileCore.Status
		local hasNamecall = Runtime.NamecallPath ~= nil and Runtime.NamecallPath ~= "unavailable"
		return {
			path = Runtime.ProjectilePath,
			executor = Runtime.ExecutorName,
			moduleRequireMode = Runtime.ModuleRequireMode,
			moduleRequireError = Runtime.LastModuleRequireError,
			namecall = Runtime.NamecallPath or "pending",
			namecallError = Runtime.NamecallError,
			silentError = Runtime.SilentError,
			enabled = S.SilentAim,
			available = status.gunbase or hasNamecall,
			gunbase = status.gunbase,
			fireserver = hasNamecall,
			raycast = hasNamecall,
			calls = status.calls,
			normalCalls = status.normalCalls,
			redirects = status.redirects,
			remoteCalls = status.remoteCalls,
			remoteRedirects = status.remoteRedirects,
			fallbackSkips = status.fallbackSkips,
			nonCombatSkips = status.nonCombatSkips,
			actionSkips = status.actionSkips,
			explosiveSkips = status.explosiveSkips,
			heldTool = ProjectileSilent.HeldToolName,
			gunbaseOwnsShot = ProjectileCore.GunBaseRedirecting == true,
			bufferWrites = status.bufferWrites,
			target = status.target,
			targetPart = ProjectileSilent.TargetPart and ProjectileSilent.TargetPart.Name or nil,
			targetVisible = ProjectileSilent.TargetVisible == true,
			targetPosition = ProjectileSilent.TargetPosition,
			targetOffset = ProjectileSilent.TargetOffset,
			visualTargetMatches = SA_CurrentTarget == ProjectileSilent.TargetPart,
			targetError = Runtime.LastTargetError,
			visiblePointChecks = status.visiblePointChecks,
			lastShotReason = status.lastShotReason,
		}
	end
end)

if not projectileInitOK then
	Runtime.ProjectileError = tostring(projectileInitError)
	ProjectileCore = nil
	ProjectileSilent = nil
end


if not Runtime.GetSilentStatus then
	Runtime.GetSilentStatus = function()
		return {
			path = Runtime.SilentPath,
			executor = Runtime.ExecutorName,
			moduleRequireMode = Runtime.ModuleRequireMode,
			moduleRequireError = Runtime.LastModuleRequireError,
			namecall = Runtime.NamecallPath or "pending",
			namecallError = Runtime.NamecallError,
			gunbase = false,
			fireserver = Runtime.NamecallPath ~= "unavailable",
			raycast = Runtime.NamecallPath ~= "unavailable",
			error = Runtime.ProjectileError,
		}
	end
end




Runtime.ExtraFeatures = {
	Status = { autoFireCalls = 0, damageEvents = 0 },
}

do
local function initializeExtraFeatures()
local ExtraFeatures = Runtime.ExtraFeatures
local extraConnections = {}
local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(extraConnections, connection)
	return connection
end
local function destroyObject(object)
	if object then pcall(function() object:Destroy() end) end
end


local extraGui = newScreenGui()
extraGui.Name = "BurmaldaHookExtra"
extraGui.ResetOnSpawn = false
extraGui.IgnoreGuiInset = true
extraGui.DisplayOrder = 999997
extraGui.Parent = pGui

local targetFrame = Instance.new("Frame")
targetFrame.Name = "TargetHUD"
targetFrame.AnchorPoint = Vector2.new(0.5, 0.5)
targetFrame.Position = UDim2.new(0.5, 0, 0.84, 0)
targetFrame.Size = UDim2.new(0, 300, 0, 92)
targetFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
targetFrame.BackgroundTransparency = 0.08
targetFrame.BorderSizePixel = 0
targetFrame.Visible = false
targetFrame.Parent = extraGui
Instance.new("UICorner", targetFrame).CornerRadius = UDim.new(0, 4)
local targetStroke = Instance.new("UIStroke")
targetStroke.Color = Color3.fromRGB(52, 52, 52)
targetStroke.Parent = targetFrame

local function makeText(parent, text, position, size, textSize, color)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = position
	label.Size = size
	label.Text = text or ""
	label.TextColor3 = color or Color3.fromRGB(242, 242, 242)
	label.Font = Enum.Font.Gotham
	label.TextSize = textSize or 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local targetName = makeText(targetFrame, "", UDim2.new(0, 14, 0, 8), UDim2.new(1, -28, 0, 22), 16)
targetName.Font = Enum.Font.GothamBold
local targetDistance = makeText(targetFrame, "", UDim2.new(0, 14, 0, 32), UDim2.new(1, -28, 0, 17), 11, Color3.fromRGB(190, 190, 190))
local targetWeapon = makeText(targetFrame, "", UDim2.new(0, 14, 0, 51), UDim2.new(1, -28, 0, 16), 10, Color3.fromRGB(135, 135, 135))
local targetHealthBack = Instance.new("Frame")
targetHealthBack.Position = UDim2.new(0, 14, 1, -15)
targetHealthBack.Size = UDim2.new(1, -28, 0, 5)
targetHealthBack.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
targetHealthBack.BorderSizePixel = 0
targetHealthBack.Parent = targetFrame
local targetHealthFill = Instance.new("Frame")
targetHealthFill.Size = UDim2.new(1, 0, 1, 0)
targetHealthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
targetHealthFill.BorderSizePixel = 0
targetHealthFill.Parent = targetHealthBack

local logHolder = Instance.new("Frame")
logHolder.Name = "HitLogs"
logHolder.AnchorPoint = Vector2.new(0.5, 0)
logHolder.Position = UDim2.new(0.5, 0, 0.61, 0)
logHolder.Size = UDim2.new(0, 560, 0, 120)
logHolder.BackgroundTransparency = 1
logHolder.Parent = extraGui
local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 3)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logHolder
local function updateLogPosition()
	local position = S.HitLogsPosition
	if position == "Left" then
		logHolder.AnchorPoint = Vector2.new(0, 0.5)
		logHolder.Position = UDim2.new(0, 18, 0.5, 0)
		logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	elseif position == "Top" then
		logHolder.AnchorPoint = Vector2.new(0.5, 0)
		logHolder.Position = UDim2.new(0.5, 0, 0, 78)
		logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	elseif position == "LeftTop" then
		logHolder.AnchorPoint = Vector2.new(0, 0)
		logHolder.Position = UDim2.new(0, 18, 0, 78)
		logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	else
		logHolder.AnchorPoint = Vector2.new(0.5, 0)
		logHolder.Position = UDim2.new(0.5, 0, 0.62, 0)
		logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end
end
updateLogPosition()
ExtraFeatures.ApplyHitLogPosition = updateLogPosition
ExtraFeatures.GetLogHolder = function() return logHolder end

local logEntries, logOrder = {}, 0
local function removeLog(label)
	for index, entry in ipairs(logEntries) do
		if entry == label then table.remove(logEntries, index) break end
	end
	destroyObject(label)
end
local function pushLog(text)
	if Runtime.Unloaded then return end
	logOrder += 1
	local label = makeText(logHolder, tostring(text), UDim2.new(), UDim2.new(1, 0, 0, 18), 12)
	label.Font = Enum.Font.Code
	label.TextColor3 = Runtime.ExtraColors.HitLogs
	label.LayoutOrder = -logOrder
	label.TextStrokeTransparency = 0.5
	table.insert(logEntries, label)
	while #logEntries > 5 do removeLog(logEntries[1]) end
	task.delay(math.max(1, S.HitLogsDuration), function()
		if label.Parent then removeLog(label) end
	end)
end
local function clearLogs()
	for _, label in ipairs(logEntries) do destroyObject(label) end
	table.clear(logEntries)
end
ExtraFeatures.PushLog = pushLog
ExtraFeatures.ClearLogs = clearLogs
ExtraFeatures.GetLogCount = function() return #logEntries end
ExtraFeatures.ShowHitLog = function(playerName, partName, damage, health)
	if not S.HitLogsEnabled then return end
	pushLog("[ Burmalda.hook ] Hit " .. tostring(playerName) .. " / " .. tostring(partName)
		.. " / " .. tostring(damage) .. " damage / " .. tostring(health) .. " HP")
end


local hitmarkers = {}
local markerDirections = {{1, 1}, {-1, 1}, {1, -1}, {-1, -1}}
local function clearHitmarkers()
	for _, marker in ipairs(hitmarkers) do
		for _, line in ipairs(marker.lines) do Runtime.RemoveDrawing(line) end
	end
	table.clear(hitmarkers)
end
local function spawnHitmarker(worldPosition, isKill)
	if Runtime.Unloaded or not S.HitmarkerEnabled or not worldPosition then return end
	local lines = {}
	for index = 1, 4 do
		local line = newDrawing("Line")
		line.Visible = false
		line.Thickness = S.HitmarkerThickness
		line.ZIndex = 5
		lines[index] = line
	end
	table.insert(hitmarkers, {position = worldPosition, born = os.clock(), kill = isKill == true, lines = lines})
end
local function updateHitmarkers()
	local now = os.clock()
	for index = #hitmarkers, 1, -1 do
		local marker = hitmarkers[index]
		local age = now - marker.born
		if age > S.HitmarkerDuration then
			for _, line in ipairs(marker.lines) do Runtime.RemoveDrawing(line) end
			table.remove(hitmarkers, index)
		else
			local projected, visible = Camera:WorldToViewportPoint(marker.position)
			for lineIndex, line in ipairs(marker.lines) do
				local direction = markerDirections[lineIndex]
				line.Visible = S.HitmarkerEnabled and visible == true
				line.Transparency = math.clamp(1 - age / math.max(0.01, S.HitmarkerDuration), 0, 1)
				line.Color = marker.kill and Runtime.ExtraColors.HitmarkerKill or Runtime.ExtraColors.Hitmarker
				line.Thickness = S.HitmarkerThickness
				line.From = Vector2.new(projected.X + direction[1] * S.HitmarkerSize * 0.3, projected.Y + direction[2] * S.HitmarkerSize * 0.3)
				line.To = Vector2.new(projected.X + direction[1] * S.HitmarkerSize, projected.Y + direction[2] * S.HitmarkerSize)
			end
		end
	end
end
ExtraFeatures.SpawnHitmarker = spawnHitmarker
ExtraFeatures.ClearHitmarkers = clearHitmarkers
ExtraFeatures.GetHitmarkerCount = function() return #hitmarkers end


local Debris = game:GetService("Debris")
local damageParts = {}
local damageTextures = {
	Foam = "rbxassetid://8297030850",
	Crescents = "rbxassetid://12509373457",
	Residue = "rbxassetid://4509687978",
	Electric = "rbxassetid://10547286472",
}
local function spawnDamageFX(worldPosition)
	if Runtime.Unloaded or not S.DamageFXEnabled or not worldPosition then return end
	local part = Instance.new("Part")
	part.Name = "BurmaldaHookDamageFX"
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Position = worldPosition + Vector3.new(0, 1, 0)
	part.Parent = workspace
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Rate = 0
	emitter.Texture = damageTextures[S.DamageFXStyle] or damageTextures.Foam
	local particleColor = Runtime.ExtraColors.DamageFX
	if S.DamageFXRainbow then particleColor = Color3.fromHSV((os.clock() * 0.5) % 1, 1, 1) end
	emitter.Color = ColorSequence.new(particleColor)
	emitter.Lifetime = NumberRange.new(S.DamageFXLifetime)
	emitter.Speed = NumberRange.new(S.DamageFXSpeed)
	emitter.Size = NumberSequence.new(S.DamageFXSize)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.LightEmission = 0.5
	emitter.Parent = attachment
	pcall(function() emitter:Emit(math.max(1, math.floor(S.DamageFXCount))) end)
	table.insert(damageParts, part)
	while #damageParts > 24 do destroyObject(table.remove(damageParts, 1)) end
	if Debris and Debris.AddItem then
		pcall(function() Debris:AddItem(part, math.max(1, S.DamageFXLifetime + 0.5)) end)
	else
		task.delay(math.max(1, S.DamageFXLifetime + 0.5), function() destroyObject(part) end)
	end
	return part
end
local function clearDamageFX()
	for _, part in ipairs(damageParts) do destroyObject(part) end
	table.clear(damageParts)
end
ExtraFeatures.SpawnDamageFX = spawnDamageFX
ExtraFeatures.ClearDamageFX = clearDamageFX
ExtraFeatures.GetDamageFXCount = function()
	local count = 0
	for _, part in ipairs(damageParts) do if part.Parent then count += 1 end end
	return count
end


local xrayCache = {}
local xrayNames = {"TwigWall", "SoloTwigFrame", "TrigTwigRoof", "TwigFrame", "TwigWindow", "TwigRoof"}
local function isXRayPart(object)
	if not object:IsA("BasePart") then return false end
	for _, keyword in ipairs(xrayNames) do
		if string.find(object.Name, keyword, 1, true) then return true end
	end
	return false
end
local function registerXRay(object)
	if not isXRayPart(object) or xrayCache[object] then return end
	xrayCache[object] = object.Transparency
	object.Transparency = S.XRayTransparency
end
local function scanXRay()
	if not S.XRay then return end
	for _, object in ipairs(workspace:GetDescendants()) do registerXRay(object) end
end
local function restoreXRay()
	for object, transparency in pairs(xrayCache) do
		if object and object.Parent then pcall(function() object.Transparency = transparency end) end
	end
	table.clear(xrayCache)
end
local function setXRay(enabled)
	S.XRay = enabled
	if enabled then scanXRay() else restoreXRay() end
end
ExtraFeatures.ScanXRay = scanXRay
ExtraFeatures.SetXRay = setXRay
connect(workspace.DescendantAdded, function(object)
	if S.XRay and not Runtime.Unloaded then pcall(registerXRay, object) end
end)


local terrain = workspace.Terrain or workspace:FindFirstChildOfClass("Terrain")
local waterOriginal = nil
local function applyWater()
	if not terrain then return end
	terrain.WaterColor = Runtime.ExtraColors.Water
	terrain.WaterReflectance = S.WaterReflectance
end
local function restoreWater()
	if terrain and waterOriginal then
		pcall(function()
			terrain.WaterColor = waterOriginal.Color
			terrain.WaterReflectance = waterOriginal.Reflectance
		end)
	end
	waterOriginal = nil
end
local function setWater(enabled)
	S.CustomWater = enabled
	if enabled then
		if terrain and not waterOriginal then
			waterOriginal = {Color = terrain.WaterColor, Reflectance = terrain.WaterReflectance}
		end
		applyWater()
	else
		restoreWater()
	end
end
ExtraFeatures.SetWater = setWater
ExtraFeatures.ApplyWater = applyWater


local toolHighlights = {}
local function clearToolOutline()
	for _, highlight in pairs(toolHighlights) do destroyObject(highlight) end
	table.clear(toolHighlights)
end
local function updateToolOutline()
	if not S.ToolOutline or Runtime.Unloaded then clearToolOutline() return end
	local seen = {}
	local character = LocalPlayer.Character
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local containers = {}
	if character then table.insert(containers, character) end
	if backpack then table.insert(containers, backpack) end
	for _, container in ipairs(containers) do
		if container then
			for _, tool in ipairs(container:GetChildren()) do
				if tool:IsA("Tool") then
					seen[tool] = true
					local highlight = toolHighlights[tool]
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "BurmaldaHookToolOutline"
						highlight.Parent = tool
						toolHighlights[tool] = highlight
					end
					highlight.Adornee = tool
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 0
					highlight.OutlineColor = Runtime.ExtraColors.ToolOutline
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Enabled = true
				end
			end
		end
	end
	for tool, highlight in pairs(toolHighlights) do
		if not seen[tool] then
			destroyObject(highlight)
			toolHighlights[tool] = nil
		end
	end
end
ExtraFeatures.UpdateToolOutline = updateToolOutline
ExtraFeatures.GetToolOutline = function(tool) return toolHighlights[tool] end


local VirtualInputManager = game:GetService("VirtualInputManager")
local lastAutoFire = -1000
local function fireAutoClick()
	if type(mouse1click) == "function" then
		local ok = pcall(mouse1click)
		if ok then ExtraFeatures.Status.autoFireCalls += 1 end
		return
	end
	if not VirtualInputManager then return end
	local viewport = Camera.ViewportSize
	local x, y = viewport.X * 0.5, viewport.Y * 0.5
	local ok = pcall(function()
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	end)
	if ok then
		ExtraFeatures.Status.autoFireCalls += 1
		task.defer(function()
			pcall(function() VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0) end)
		end)
	end
end
local function updateAutoFire()
	if not S.AutoFire or not S.SilentAim or menuOpen or Runtime.CraftingMenuOpen then return end
	local target = SA_CurrentTarget
	local character = LocalPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	if not target or not target.Parent or not tool then return end
	local now = os.clock()
	if now - lastAutoFire < math.max(0.01, S.AutoFireDelay) then return end
	lastAutoFire = now
	fireAutoClick()
end


local noFallParams = RaycastParams.new()
noFallParams.FilterType = Enum.RaycastFilterType.Exclude
local swimVelocity = nil
local flyVelocity, flyGyro, flySeat, flyHumanoid, flyOldAutoRotate = nil, nil, nil, nil, nil
local function destroySwim()
	destroyObject(swimVelocity)
	swimVelocity = nil
end
local function destroyFly()
	destroyObject(flyVelocity)
	destroyObject(flyGyro)
	flyVelocity, flyGyro, flySeat = nil, nil, nil
	if flyHumanoid and flyOldAutoRotate ~= nil then
		pcall(function() flyHumanoid.AutoRotate = flyOldAutoRotate end)
	end
	flyHumanoid, flyOldAutoRotate = nil, nil
end
local function ensureFly(humanoid, seat)
	if flyVelocity and flySeat == seat and flyVelocity.Parent == seat then return end
	destroyFly()
	flySeat, flyHumanoid = seat, humanoid
	flyOldAutoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false
	flyVelocity = Instance.new("BodyVelocity")
	flyVelocity.Name = "BurmaldaHookCopterFly"
	flyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyVelocity.Velocity = Vector3.new()
	flyVelocity.Parent = seat
	flyGyro = Instance.new("BodyGyro")
	flyGyro.Name = "BurmaldaHookCopterGyro"
	flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyGyro.P = 9000
	flyGyro.CFrame = seat.CFrame
	flyGyro.Parent = seat
end
local function updateFly(humanoid)
	local seat = humanoid.SeatPart
	if not seat then destroyFly() return end
	ensureFly(humanoid, seat)
	humanoid.Sit = true
	local cameraCF = (workspace.CurrentCamera or Camera).CFrame
	local look = cameraCF.LookVector
	local right = cameraCF.RightVector or Vector3.new(-look.Z, 0, look.X)
	local movement = Vector3.new()
	if UIS:IsKeyDown(Enum.KeyCode.W) then movement += look end
	if UIS:IsKeyDown(Enum.KeyCode.S) then movement -= look end
	if UIS:IsKeyDown(Enum.KeyCode.D) then movement += right end
	if UIS:IsKeyDown(Enum.KeyCode.A) then movement -= right end
	local vertical = 0
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift) then vertical = 1 end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then vertical = -1 end
	if movement.Magnitude > 0 or vertical ~= 0 then
		flyVelocity.Velocity = (movement + Vector3.new(0, vertical, 0)).Unit * S.CopterFlySpeed
	else
		flyVelocity.Velocity = Vector3.new()
	end
	flyGyro.CFrame = cameraCF
end
ExtraFeatures.GetFlyObjects = function() return flyVelocity, flyGyro end

local toolScanElapsed = 0
local function physicsStep(dt)
	if Runtime.Unloaded then return end
	updateAutoFire()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		destroySwim()
		destroyFly()
		return
	end

	if S.CopterSpeed and not S.CopterFly and humanoid.Sit and humanoid.MoveDirection.Magnitude > 0 then
		local direction = humanoid.MoveDirection
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(direction.X * S.CopterSpeedValue, velocity.Y, direction.Z * S.CopterSpeedValue)
	end

	local state = humanoid.GetState and humanoid:GetState() or nil
	if S.SwimSpeed and state == Enum.HumanoidStateType.Swimming then
		if not swimVelocity or swimVelocity.Parent ~= root then
			destroySwim()
			swimVelocity = Instance.new("BodyVelocity")
			swimVelocity.Name = "BurmaldaHookSwim"
			swimVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			swimVelocity.Parent = root
		end
		swimVelocity.Velocity = humanoid.MoveDirection * S.SwimSpeedValue
	else
		destroySwim()
	end

	if S.NoFallDamage and root.AssemblyLinearVelocity.Y < -55 then
		noFallParams.FilterDescendantsInstances = {character}
		local result = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), noFallParams)
		if result then
			local velocity = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, -2, velocity.Z)
		end
	end

	if S.CopterFly then updateFly(humanoid) else destroyFly() end
	toolScanElapsed += dt or 0
	if toolScanElapsed >= 0.5 then
		toolScanElapsed = 0
		updateToolOutline()
	end
end
ExtraFeatures.Physics = physicsStep

local lastJumpRequest = -1000
connect(UIS.JumpRequest, function()
	if Runtime.Unloaded or not S.NoJumpDelay then return end
	local now = os.clock()
	if now - lastJumpRequest < 0.1 then return end
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	local state = humanoid.GetState and humanoid:GetState() or nil
	if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Flying then return end
	lastJumpRequest = now
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)


local trackedCharacters, humanoidStates = {}, {}
local recentTargets, lastHits = {}, {}
local characterConnections, playerConnections, playerCharacters = {}, {}, {}

local function disconnectOwned(connection)
	pcall(function() connection:Disconnect() end)
	for index = #extraConnections, 1, -1 do
		if extraConnections[index] == connection then
			table.remove(extraConnections, index)
			break
		end
	end
end

local function releaseConnections(connections)
	if not connections then return end
	for index = #connections, 1, -1 do
		disconnectOwned(connections[index])
		connections[index] = nil
	end
end

local function connectOwned(signal, callback, connections)
	local connection = connect(signal, callback)
	table.insert(connections, connection)
	return connection
end

local function releaseCharacter(character)
	local connections = characterConnections[character]
	if not connections then return end
	characterConnections[character] = nil
	trackedCharacters[character] = nil
	releaseConnections(connections)
	for humanoid, state in pairs(humanoidStates) do
		if state.Character == character then humanoidStates[humanoid] = nil end
	end
end

local function releasePlayer(player)
	local character = playerCharacters[player]
	if character then releaseCharacter(character) end
	playerCharacters[player] = nil
	releaseConnections(playerConnections[player])
	playerConnections[player] = nil
	recentTargets[player] = nil
	lastHits[player] = nil
end

local function isOurDamage(player, _character)
	local seen = recentTargets[player]
	return seen ~= nil and os.clock() - seen >= 0 and os.clock() - seen <= 2
end
local function onDamaged(player, character, damage, newHealth)
	if damage <= 0.05 or not isOurDamage(player, character) then return end
	local shotPart = ProjectileSilent and ProjectileSilent.LastShotPart
	local part = shotPart and shotPart.Parent == character and shotPart
		or character:FindFirstChild("HeadHitbox") or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	if not part then return end
	lastHits[player] = os.clock()
	ExtraFeatures.Status.damageEvents += 1
	ExtraFeatures.ShowHitLog(player.DisplayName or player.Name, part.Name, math.floor(damage + 0.5), math.floor(newHealth + 0.5))
	spawnHitmarker(part.Position, false)
	spawnDamageFX(part.Position)
end
local function attachHumanoid(player, character, humanoid)
	local connections = characterConnections[character]
	if not connections or humanoidStates[humanoid] then return end
	humanoidStates[humanoid] = {health = humanoid.Health, Character = character}
	connectOwned(humanoid.HealthChanged, function(newHealth)
		local state = humanoidStates[humanoid]
		local previous = state and state.health or newHealth
		if state then state.health = newHealth end
		if newHealth < previous then onDamaged(player, character, previous - newHealth, newHealth) end
	end, connections)
	connectOwned(humanoid.Died, function()
		if S.KillNotify and not Runtime.Unloaded then
			pushLog("[ Burmalda.hook ] " .. tostring(player.DisplayName or player.Name) .. " died")
		end
		local hitTime = lastHits[player]
		if hitTime and os.clock() - hitTime <= 5 then
			if Runtime.VomaglaFeatures and Runtime.VomaglaFeatures.PlayKillSound then Runtime.VomaglaFeatures.PlayKillSound() end
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then spawnHitmarker(root.Position, true) end
		end
		lastHits[player] = nil
	end, connections)
end
local function trackCharacter(player, character)
	if not character or trackedCharacters[character] then return end
	local previous = playerCharacters[player]
	if previous and previous ~= character then releaseCharacter(previous) end
	trackedCharacters[character] = true
	playerCharacters[player] = character
	local connections = {}
	characterConnections[character] = connections
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then attachHumanoid(player, character, humanoid) end
	connectOwned(character.ChildAdded, function(child)
		if child:IsA("Humanoid") then attachHumanoid(player, character, child) end
	end, connections)
end
local function trackPlayer(player)
	if player == LocalPlayer or playerConnections[player] then return end
	local connections = {}
	playerConnections[player] = connections
	if player.Character then trackCharacter(player, player.Character) end
	connectOwned(player.CharacterAdded, function(character) trackCharacter(player, character) end, connections)
	connectOwned(player.CharacterRemoving, function(character)
		releaseCharacter(character)
		if playerCharacters[player] == character then playerCharacters[player] = nil end
	end, connections)
end
for _, player in ipairs(Players:GetPlayers()) do trackPlayer(player) end
connect(Players.PlayerAdded, trackPlayer)
connect(Players.PlayerRemoving, releasePlayer)

local function clearDamageTracking()
	for player in pairs(playerConnections) do releasePlayer(player) end
	for character in pairs(characterConnections) do releaseCharacter(character) end
	table.clear(trackedCharacters)
	table.clear(humanoidStates)
	table.clear(characterConnections)
	table.clear(playerConnections)
	table.clear(playerCharacters)
	table.clear(recentTargets)
	table.clear(lastHits)
end

local function updateRecentTarget()
	local target = ProjectileSilent and ProjectileSilent.LastShotPart
	local shotAt = ProjectileSilent and ProjectileSilent.LastShotAt
	local character = target and target.Parent
	if not character or type(shotAt) ~= "number" then return end
	local age = os.clock() - shotAt
	if age < 0 or age > 2 then return end
	local ok, player = pcall(Players.GetPlayerFromCharacter, Players, character)
	if ok and player then recentTargets[player] = shotAt end
end
local function updateTargetHUD()
	local target = SA_CurrentTarget
	local character = target and target.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not S.TargetHUD or not character or not humanoid or not root or humanoid.Health <= 0 then
		targetFrame.Visible = false
		return
	end
	local ok, player = pcall(Players.GetPlayerFromCharacter, Players, character)
	targetName.Text = ok and player and (player.DisplayName or player.Name) or character.Name
	local localCharacter = LocalPlayer.Character
	local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
	targetDistance.Text = localRoot and string.format("Distance: %.1f m", (localRoot.Position - root.Position).Magnitude) or "Distance: —"
	local tool = character:FindFirstChildOfClass("Tool")
	targetWeapon.Text = tool and ("Holding: " .. tool.Name) or "Unarmed"
	local ratio = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
	targetHealthFill.Size = UDim2.new(ratio, 0, 1, 0)
	targetFrame.Visible = true
end
local function visualUpdate(_)
	if Runtime.Unloaded then return end
	updateRecentTarget()
	updateTargetHUD()
	updateHitmarkers()
	for index = #damageParts, 1, -1 do
		if not damageParts[index].Parent then table.remove(damageParts, index) end
	end
end
ExtraFeatures.Update = visualUpdate
ExtraFeatures.GetTargetHUD = function()
	return targetFrame, targetName, targetDistance, targetWeapon, targetHealthFill
end


do
	local autoSet = createFeature(smartCol("COMBAT"), "Auto Fire", false, function(v) S.AutoFire = v end)
	addSlider(autoSet, "Fire Delay", 1, 50, 5, function(v) S.AutoFireDelay = v / 100 end)
end
do
	local hudSet = createFeature(smartCol("COMBAT"), "Target HUD", false, function(v) S.TargetHUD = v end)
	local logsSet = createFeature(smartCol("COMBAT"), "Hit Logs", false, function(v) S.HitLogsEnabled = v end)
	addDropdown(logsSet, "Position", {"Center", "Left", "Top", "LeftTop"}, 1, function(v) S.HitLogsPosition = v; updateLogPosition() end)
	addSlider(logsSet, "Duration", 1, 15, 5, function(v) S.HitLogsDuration = v end)
	addColor(logsSet, "Log Color", function(c) Runtime.ExtraColors.HitLogs = c end)
	local markerSet = createFeature(smartCol("COMBAT"), "Hitmarker", false, function(v) S.HitmarkerEnabled = v end)
	addSlider(markerSet, "Size", 5, 40, 12, function(v) S.HitmarkerSize = v end)
	addSlider(markerSet, "Thickness", 1, 5, 2, function(v) S.HitmarkerThickness = v end)
	addSlider(markerSet, "Duration", 5, 60, 25, function(v) S.HitmarkerDuration = v / 10 end)
	addColor(markerSet, "Color", function(c) Runtime.ExtraColors.Hitmarker = c end)
	addColor(markerSet, "Kill Color", function(c) Runtime.ExtraColors.HitmarkerKill = c end)
	local damageSet = createFeature(smartCol("COMBAT"), "Damage FX", false, function(v) S.DamageFXEnabled = v end)
	addDropdown(damageSet, "Style", {"Foam", "Crescents", "Residue", "Electric"}, 1, function(v) S.DamageFXStyle = v end)
	addSlider(damageSet, "Count", 1, 60, 12, function(v) S.DamageFXCount = v end)
	addSlider(damageSet, "Speed", 5, 60, 20, function(v) S.DamageFXSpeed = v end)
	addSlider(damageSet, "Size", 5, 100, 25, function(v) S.DamageFXSize = v / 100 end)
	addSlider(damageSet, "Lifetime", 2, 40, 8, function(v) S.DamageFXLifetime = v / 10 end)
	addDropdown(damageSet, "Rainbow", {"Off", "On"}, 1, function(v) S.DamageFXRainbow = v == "On" end)
	addColor(damageSet, "Color", function(c) Runtime.ExtraColors.DamageFX = c end)
	local toolSet = createFeature(smartCol("VISUALS"), "Tool Outline", false, function(v) S.ToolOutline = v end)
	addColor(toolSet, "Outline Color", function(c) Runtime.ExtraColors.ToolOutline = c; if S.ToolOutline then updateToolOutline() end end)
	local outlineSet = createFeature(smartCol("VISUALS"), "X-Ray", false, function(v) setXRay(v) end)
	addSlider(outlineSet, "Transparency", 0, 9, 5, function(v)
		S.XRayTransparency = v / 10
		if S.XRay then for object in pairs(xrayCache) do if object.Parent then object.Transparency = S.XRayTransparency end end end
	end)
	local waterSet = createFeature(smartCol("VISUALS"), "Custom Water", false, function(v) setWater(v) end)
	addColor(waterSet, "Water Color", function(c) Runtime.ExtraColors.Water = c; if S.CustomWater then applyWater() end end)
	addSlider(waterSet, "Reflectance", 0, 10, 3, function(v) S.WaterReflectance = v / 10; if S.CustomWater then applyWater() end end)
end
do
	createFeature(smartCol("MISC"), "Kill Notify", false, function(v) S.KillNotify = v end)
end
do
	local swimSet = createFeature(smartCol("MOVEMENT"), "Swim Speed", false, function(v) S.SwimSpeed = v end)
	addSlider(swimSet, "Value", 20, 200, 50, function(v) S.SwimSpeedValue = v end)
	local copterSet = createFeature(smartCol("MOVEMENT"), "Copter Speed", false, function(v) S.CopterSpeed = v end)
	addSlider(copterSet, "Value", 20, 100, 50, function(v) S.CopterSpeedValue = v end)
	createFeature(smartCol("MOVEMENT"), "No Fall Damage", false, function(v) S.NoFallDamage = v end, false)
	createFeature(smartCol("MOVEMENT"), "No Jump Delay", false, function(v) S.NoJumpDelay = v end, false)
	local flySet = createFeature(smartCol("MOVEMENT"), "Copter Fly", false, function(v)
		S.CopterFly = v
		if not v then destroyFly() end
	end)
	addSlider(flySet, "Fly Speed", 50, 450, 100, function(v) S.CopterFlySpeed = v end)
end

Runtime.ExtraHeartbeat = RunService.Heartbeat:Connect(physicsStep)
Runtime.ExtraRender = RunService.RenderStepped:Connect(visualUpdate)
local function cleanup()
	clearDamageTracking()
	for _, connection in ipairs(extraConnections) do pcall(function() connection:Disconnect() end) end
	table.clear(extraConnections)
	if Runtime.ExtraHeartbeat then Runtime.ExtraHeartbeat:Disconnect() end
	if Runtime.ExtraRender then Runtime.ExtraRender:Disconnect() end
	clearLogs()
	clearHitmarkers()
	clearDamageFX()
	restoreXRay()
	restoreWater()
	clearToolOutline()
	destroySwim()
	destroyFly()
	targetFrame.Visible = false
end
ExtraFeatures.Cleanup = cleanup
onCleanup(cleanup)
end
initializeExtraFeatures()
end 





do
local function initializeVomaglaFeatures()
local M = {
	Status = {
		weaponCacheAvailable = false,
		weaponScans = 0,
		reloadHooked = false,
		bulletTracers = 0,
		killSoundCalls = 0,
		lastKillSound = "",
		lastStretch = nil,
		gunTables = 0,
		meleeTables = 0,
		weaponCacheError = nil,
		lastWeaponCacheAt = 0,
	},
	KillSoundState = { Times = {}, LastDouble = -1000 },
	ReloadState = { Start = 0, Duration = 0, Active = false },
}
Runtime.VomaglaFeatures = M

local defaults = {
	RapidFire = false, RapidFireDelay = 0.02,
	FullAuto = false,
	MeleeMods = false, MeleeSpeed = 0.05, MeleeRange = 5,
	ReloadIndicator = false,
	BulletTracers = false, BulletTracerStyle = "Beam", BulletTracerWidth = 1.5,
	BulletTracerTransparency = 0, BulletTracerLifetime = 0.5,
	HitboxExpander = false, HitboxSize = 5, HitboxTransparency = 0.2,
	ThirdPerson = false, ThirdPersonDistance = 10,
	Stretch = false, StretchValue = 0.65,
	Fullbright = false, NoDecoration = false,
	SkyColorEnabled = false, SkyboxEnabled = false, SkyboxChoice = "Default",
	JumpCircles = false, DeleteSpikes = false, DeleteLeaves = false,
	KillSound = false, KillSoundVolume = 1, KillSoundChoice = "Random",
}
for key, value in pairs(defaults) do
	if S[key] == nil then S[key] = value end
end
Runtime.ExtraColors.BulletTracer = Runtime.ExtraColors.BulletTracer or Color3.fromRGB(255, 255, 255)
Runtime.ExtraColors.Hitbox = Runtime.ExtraColors.Hitbox or Color3.fromRGB(255, 0, 0)
Runtime.ExtraColors.JumpCircle = Runtime.ExtraColors.JumpCircle or Color3.fromRGB(0, 170, 255)
Runtime.ExtraColors.Sky = Runtime.ExtraColors.Sky or Color3.fromRGB(135, 200, 255)

local moduleConnections = {}
local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(moduleConnections, connection)
	return connection
end
local function destroyObject(object)
	if object then pcall(function() object:Destroy() end) end
end


do
	local gunCache, meleeCache = {}, {}
	local gunOriginals, meleeOriginals = {}, {}
	local cachesBuilt = false
	local nextCacheRefresh = 0
	local CACHE_REFRESH_SECONDS = 5

	local function updateCacheStatus()
		M.Status.gunTables = #gunCache
		M.Status.meleeTables = #meleeCache
		M.Status.lastWeaponCacheAt = os.clock()
	end

	local function saveOriginal(originals, object, key)
		local properties = originals[object]
		if not properties then
			properties = {}
			originals[object] = properties
		end
		if properties[key] == nil then properties[key] = { value = rawget(object, key) } end
	end
	local function restoreKeys(originals, keys)
		for object, properties in pairs(originals) do
			for _, key in ipairs(keys) do
				local saved = properties[key]
				if saved then
					pcall(function() rawset(object, key, saved.value) end)
					properties[key] = nil
				end
			end
			if next(properties) == nil then originals[object] = nil end
		end
	end
	local rapidKeys = {"FireDelay", "FireRate", "FiringOnCooldown"}
	local autoKeys = {"FiringType", "FireMode", "Auto"}
	local meleeKeys = {"UseDelay", "UseTime", "Range", "CharacterRange", "UsingOnCooldown"}

	local function restoreAll()
		restoreKeys(gunOriginals, rapidKeys)
		restoreKeys(gunOriginals, autoKeys)
		restoreKeys(meleeOriginals, meleeKeys)
	end
	local function rebuildCaches()
		restoreAll()
		table.clear(gunCache)
		table.clear(meleeCache)
		cachesBuilt = true
		nextCacheRefresh = os.clock() + CACHE_REFRESH_SECONDS
		M.Status.weaponScans += 1
		M.Status.weaponCacheError = nil
		M.Status.weaponCacheAvailable = type(getgc) == "function"
		if not M.Status.weaponCacheAvailable then
			M.Status.weaponCacheError = "getgc unavailable"
			updateCacheStatus()
			return
		end
		local ok, objects = pcall(getgc, true)
		if not ok or type(objects) ~= "table" then
			M.Status.weaponCacheError = "getgc failed: " .. tostring(objects)
			updateCacheStatus()
			return
		end
		for _, object in pairs(objects) do
			if type(object) == "table" then
				if rawget(object, "FireDelay") ~= nil and rawget(object, "FiringOnCooldown") ~= nil and rawget(object, "OwnerPlayer") ~= nil then
					table.insert(gunCache, object)
				end
				if rawget(object, "UseDelay") ~= nil and rawget(object, "Range") ~= nil
					and rawget(object, "UsingOnCooldown") ~= nil and rawget(object, "Destroyed") ~= true then
					table.insert(meleeCache, object)
				end
			end
		end
		updateCacheStatus()
	end
	local function applyWeaponMods(forceRefresh)
		local enabled = S.RapidFire or S.FullAuto or S.MeleeMods
		if forceRefresh or (enabled and (not cachesBuilt or os.clock() >= nextCacheRefresh)) then
			
			
			
			
			rebuildCaches()
		end
		if S.RapidFire or S.FullAuto then
			for _, object in ipairs(gunCache) do
				pcall(function()
					if S.RapidFire then
						local speed = math.clamp(tonumber(S.RapidFireDelay) or 0.02, 0.01, 0.5)
						for _, key in ipairs(rapidKeys) do saveOriginal(gunOriginals, object, key) end
						rawset(object, "FireDelay", speed)
						if rawget(object, "FireRate") ~= nil then rawset(object, "FireRate", math.floor(1 / speed)) end
						rawset(object, "FiringOnCooldown", false)
					end
					if S.FullAuto then
						for _, key in ipairs(autoKeys) do saveOriginal(gunOriginals, object, key) end
						if rawget(object, "FiringType") ~= nil then rawset(object, "FiringType", 2) end
						if rawget(object, "FireMode") ~= nil then rawset(object, "FireMode", "Auto") end
						if rawget(object, "Auto") ~= nil then rawset(object, "Auto", true) end
					end
				end)
			end
		end
		if S.MeleeMods then
			local speed = math.clamp(tonumber(S.MeleeSpeed) or 0.05, 0.01, 0.5)
			local range = math.clamp(tonumber(S.MeleeRange) or 5, 1, 20)
			for _, object in ipairs(meleeCache) do
				pcall(function()
					if rawget(object, "Destroyed") == true then return end
					for _, key in ipairs(meleeKeys) do saveOriginal(meleeOriginals, object, key) end
					rawset(object, "UseDelay", speed)
					rawset(object, "UseTime", speed)
					rawset(object, "Range", range)
					rawset(object, "CharacterRange", range)
					rawset(object, "UsingOnCooldown", false)
				end)
			end
		end
	end
	M.RebuildWeaponCaches = rebuildCaches
	M.ApplyWeaponMods = applyWeaponMods
	M.SetRapidFire = function(enabled)
		S.RapidFire = enabled
		if enabled then applyWeaponMods(true) else restoreKeys(gunOriginals, rapidKeys) end
	end
	M.SetFullAuto = function(enabled)
		S.FullAuto = enabled
		if enabled then applyWeaponMods(true) else restoreKeys(gunOriginals, autoKeys) end
	end
	M.SetMeleeMods = function(enabled)
		S.MeleeMods = enabled
		if enabled then applyWeaponMods(true) else restoreKeys(meleeOriginals, meleeKeys) end
	end
	M.GetWeaponCaches = function() return gunCache, meleeCache end
	M.RestoreWeaponMods = restoreAll
	local function watchCharacter(character)
		cachesBuilt = false
		if character then
			connect(character.ChildAdded, function(child)
				if child:IsA("Tool") then cachesBuilt = false end
			end)
		end
	end
	if LocalPlayer.Character then watchCharacter(LocalPlayer.Character) end
	connect(LocalPlayer.CharacterAdded, function(character)
		watchCharacter(character)
		task.delay(0.15, function() if not Runtime.Unloaded then rebuildCaches() end end)
	end)
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if backpack then
		connect(backpack.ChildAdded, function(child)
			if child:IsA("Tool") then cachesBuilt = false end
		end)
	end
	
	
	
end


do
	local reloadGui = newScreenGui()
	reloadGui.Name = "BurmaldaHookReload"
	reloadGui.ResetOnSpawn = false
	reloadGui.IgnoreGuiInset = true
	reloadGui.DisplayOrder = 999996
	reloadGui.Parent = pGui
	local holder = Instance.new("Frame", reloadGui)
	holder.AnchorPoint = Vector2.new(0.5, 1)
	holder.Position = UDim2.new(0.5, 0, 1, -80)
	holder.Size = UDim2.new(0, 160, 0, 16)
	holder.BackgroundTransparency = 1
	holder.Visible = false
	local background = Instance.new("Frame", holder)
	background.Size = UDim2.new(1, 0, 0, 6)
	background.Position = UDim2.new(0, 0, 0.5, -3)
	background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	background.BorderSizePixel = 0
	Instance.new("UICorner", background).CornerRadius = UDim.new(1, 0)
	local fill = Instance.new("Frame", background)
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local gunBase, originalReload, replacementReload, reloadName = nil, nil, nil, nil
	local lastInstallAttempt = -1000
	local function installReloadHook()
		if M.Status.reloadHooked then return true end
		lastInstallAttempt = os.clock()
		local gun = ReplicatedStorage:FindFirstChild("Gun")
		local scripts = gun and gun:FindFirstChild("Scripts")
		local module = scripts and scripts:FindFirstChild("GunBase")
		if not module then return false end
		local loaded = Runtime.RequireGameModule(module)
		if type(loaded) ~= "table" then return false end
		for _, name in ipairs({"reload", "Reload", "startReload", "beginReload"}) do
			if type(loaded[name]) == "function" then
				gunBase, originalReload, reloadName = loaded, loaded[name], name
				replacementReload = function(self, ...)
					local duration = rawget(self, "ReloadTime") or rawget(self, "ReloadDuration")
						or rawget(self, "reload_time") or rawget(self, "reloadTime") or 2
					M.ReloadState.Start = os.clock()
					M.ReloadState.Duration = tonumber(duration) or 2
					M.ReloadState.Active = true
					return originalReload(self, ...)
				end
				local assigned = pcall(function() gunBase[reloadName] = replacementReload end)
				if assigned and gunBase[reloadName] == replacementReload then
					M.Status.reloadHooked = true
					return true
				end
				gunBase, originalReload, replacementReload, reloadName = nil, nil, nil, nil
			end
		end
		return false
	end
	M.InstallReloadHook = installReloadHook
	M.UpdateReload = function()
		local state = M.ReloadState
		if S.ReloadIndicator and not M.Status.reloadHooked and os.clock() - lastInstallAttempt > 2 then installReloadHook() end
		if Runtime.Unloaded or not S.ReloadIndicator or not state.Active then
			holder.Visible = false
			return
		end
		local progress = (os.clock() - state.Start) / math.max(state.Duration, 0.01)
		if progress >= 1 then
			state.Active = false
			holder.Visible = false
			return
		end
		progress = math.clamp(progress, 0, 1)
		holder.Visible = true
		fill.Size = UDim2.new(progress, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - progress) + 0.5), math.floor(180 + 75 * progress + 0.5), 50)
	end
	M.GetReloadObjects = function() return holder, fill end
	M.CleanupReload = function()
		M.ReloadState.Active = false
		holder.Visible = false
		if gunBase and originalReload and reloadName and gunBase[reloadName] == replacementReload then
			pcall(function() gunBase[reloadName] = originalReload end)
		end
		M.Status.reloadHooked = false
		destroyObject(reloadGui)
	end
	
end


do
	local active = {}
	local textures = {
		Beam = "rbxassetid://12781852245", Lightning = "rbxassetid://446111271",
		Heartrate = "rbxassetid://5830549480", Chain = "rbxassetid://9632168658",
		Glitch = "rbxassetid://8089467613", Swirl = "rbxassetid://5638168605",
	}
	local function clearTracers()
		for _, tracer in ipairs(active) do destroyObject(tracer.part) end
		table.clear(active)
		M.Status.bulletTracers = 0
	end
	local function createTracer(startPosition, endPosition)
		if Runtime.Unloaded or not S.BulletTracers or typeof(startPosition) ~= "Vector3" or typeof(endPosition) ~= "Vector3" then return end
		local camera = workspace.CurrentCamera
		if camera and (startPosition - camera.CFrame.Position).Magnitude < 4 then
			startPosition = camera.CFrame.Position + camera.CFrame.LookVector * 2.5
		end
		local part = Instance.new("Part")
		part.Name = "BurmaldaHookBulletTracer"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.Parent = workspace
		local attachment0 = Instance.new("Attachment", part)
		attachment0.Name = "A0"
		attachment0.WorldPosition = startPosition
		local attachment1 = Instance.new("Attachment", part)
		attachment1.Name = "A1"
		attachment1.WorldPosition = endPosition
		local beam = Instance.new("Beam", part)
		beam.Name = "B"
		beam.Attachment0 = attachment0
		beam.Attachment1 = attachment1
		beam.FaceCamera = true
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.TextureLength = 2
		beam.TextureSpeed = 2
		beam.Color = ColorSequence.new(Runtime.ExtraColors.BulletTracer)
		beam.Transparency = NumberSequence.new(S.BulletTracerTransparency)
		beam.Texture = textures[S.BulletTracerStyle] or textures.Beam
		beam.Width0 = S.BulletTracerWidth
		beam.Width1 = S.BulletTracerWidth
		beam.Enabled = true
		table.insert(active, {part = part, beam = beam, born = os.clock()})
		while #active > 25 do destroyObject(table.remove(active, 1).part) end
		M.Status.bulletTracers = #active
		return part
	end
	M.RecordRaycast = function(origin, hitPosition)
		if S.BulletTracers then return createTracer(origin, hitPosition) end
	end
	M.CreateBulletTracer = createTracer
	M.UpdateBulletTracers = function()
		for index = #active, 1, -1 do
			local tracer = active[index]
			local alpha = 1 - (os.clock() - tracer.born) / math.max(0.05, S.BulletTracerLifetime)
			if not tracer.part.Parent or alpha <= 0 then
				destroyObject(tracer.part)
				table.remove(active, index)
			else
				tracer.beam.Transparency = NumberSequence.new(math.clamp(alpha * (1 - S.BulletTracerTransparency), 0, 1))
			end
		end
		M.Status.bulletTracers = #active
	end
	M.GetBulletTracerCount = function() return #active end
	M.ClearBulletTracers = clearTracers
	M.SetBulletTracers = function(enabled)
		S.BulletTracers = enabled
		if not enabled then clearTracers() end
	end
end


do
	local enlarged = {}
	local elapsed = 0
	local function restore(part)
		local original = enlarged[part]
		if not original then return end
		if part and part.Parent then
			pcall(function()
				part.Size = original.Size
				part.Color = original.Color
				part.Transparency = original.Transparency
				part.Material = original.Material
			end)
		end
		enlarged[part] = nil
	end
	local function restoreAll()
		for part in pairs(enlarged) do restore(part) end
	end
	local function updateHitboxes(dt)
		if not S.HitboxExpander then
			elapsed = 0
			if next(enlarged) ~= nil then restoreAll() end
			return
		end
		elapsed += dt or 0
		if elapsed < 0.08 then return end
		elapsed = 0
		local seen = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local part = character and character:FindFirstChild("HeadHitbox")
				if part and humanoid and humanoid.Health > 0 and S.HitboxExpander then
					seen[part] = true
					if not enlarged[part] then
						enlarged[part] = {Size = part.Size, Color = part.Color, Transparency = part.Transparency, Material = part.Material}
					end
					local original = enlarged[part]
					part.Size = original.Size * S.HitboxSize
					part.Color = Runtime.ExtraColors.Hitbox
					part.Transparency = S.HitboxTransparency
					part.Material = Enum.Material.Neon
				end
			end
		end
		for part in pairs(enlarged) do
			if not seen[part] then restore(part) end
		end
	end
	M.UpdateHitboxes = updateHitboxes
	M.ApplyHitboxVisuals = function()
		for part, original in pairs(enlarged) do
			if part.Parent then
				part.Size = original.Size * S.HitboxSize
				part.Color = Runtime.ExtraColors.Hitbox
				part.Transparency = S.HitboxTransparency
			end
		end
	end
	M.RestoreHitboxes = restoreAll
	M.SetHitboxExpander = function(enabled)
		S.HitboxExpander = enabled
		if enabled then updateHitboxes(1) else restoreAll() end
	end
	M.GetHitboxCount = function()
		local count = 0
		for _ in pairs(enlarged) do count += 1 end
		return count
	end
end


do
	local thirdOriginal, stretchOriginal = nil, nil
	local function disableThirdPerson()
		local camera = workspace.CurrentCamera
		if camera and thirdOriginal then pcall(function() camera.CFrame = thirdOriginal end) end
		thirdOriginal = nil
	end
	local function disableStretch()
		local camera = workspace.CurrentCamera
		if camera and stretchOriginal then pcall(function() camera.CFrame = stretchOriginal end) end
		stretchOriginal = nil
		M.Status.lastStretch = nil
	end
	M.SetThirdPerson = function(enabled)
		S.ThirdPerson = enabled
		if not enabled then disableThirdPerson() end
	end
	M.SetStretch = function(enabled)
		S.Stretch = enabled
		if not enabled then disableStretch() end
	end
	M.UpdateCamera = function()
		local camera = workspace.CurrentCamera
		if not camera then return end
		if S.ThirdPerson then
			local character = LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				local original = camera.CFrame
				thirdOriginal = original
				camera.CFrame = CFrame.new(root.Position - original.LookVector * S.ThirdPersonDistance, root.Position)
			end
		else
			thirdOriginal = nil
		end
		if S.Stretch then
			local original = camera.CFrame
			stretchOriginal = original
			camera.CFrame = original * CFrame.new(0, 0, 0, 1, 0, 0, 0, S.StretchValue, 0, 0, 0, 1)
			M.Status.lastStretch = S.StretchValue
		else
			stretchOriginal = nil
			M.Status.lastStretch = nil
		end
	end
	M.CleanupCamera = function()
		disableStretch()
		disableThirdPerson()
	end
end


do
	local fullbrightOriginal = nil
	local function applyFullbright()
		_Lighting.Brightness = 2
		_Lighting.ClockTime = 14
		_Lighting.FogEnd = 100000
		_Lighting.GlobalShadows = false
		_Lighting.Ambient = Color3.fromRGB(178, 178, 178)
	end
	M.SetFullbright = function(enabled)
		S.Fullbright = enabled
		if enabled then
			if not fullbrightOriginal then
				fullbrightOriginal = {Brightness = _Lighting.Brightness, ClockTime = _Lighting.ClockTime, FogEnd = _Lighting.FogEnd,
					GlobalShadows = _Lighting.GlobalShadows, Ambient = _Lighting.Ambient}
			end
			applyFullbright()
		elseif fullbrightOriginal then
			for key, value in pairs(fullbrightOriginal) do pcall(function() _Lighting[key] = value end) end
			fullbrightOriginal = nil
		end
	end
	M.ApplyFullbright = function() if S.Fullbright then applyFullbright() end end

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	local decorationOriginal = nil
	M.SetNoDecoration = function(enabled)
		S.NoDecoration = enabled
		if not terrain then return end
		if enabled then
			if decorationOriginal == nil then decorationOriginal = terrain.Decoration end
			if type(sethiddenproperty) == "function" then
				pcall(sethiddenproperty, terrain, "Decoration", false)
			else
				pcall(function() terrain.Decoration = false end)
			end
		elseif decorationOriginal ~= nil then
			pcall(function() terrain.Decoration = decorationOriginal end)
			decorationOriginal = nil
		end
	end

	local skyFx = nil
	M.SetSkyColorEnabled = function(enabled)
		S.SkyColorEnabled = enabled
		if enabled then
			if not skyFx then
				skyFx = Instance.new("ColorCorrectionEffect")
				skyFx.Name = "BurmaldaHookSky"
				skyFx.Parent = _Lighting
			end
			skyFx.TintColor = Runtime.ExtraColors.Sky
		else
			destroyObject(skyFx)
			skyFx = nil
		end
	end
	M.ApplySkyColor = function() if skyFx then skyFx.TintColor = Runtime.ExtraColors.Sky end end
	M.GetSkyEffect = function() return skyFx end

	local skyData = {
		["Blue Sky"] = {591058823, 591059876, 591058104, 591057861, 591057625, 591059642},
		["Vaporwave"] = {1417494030, 1417494146, 1417494253, 1417494402, 1417494499, 1417494643},
		["Redshift"] = {401664839, 401664862, 401664960, 401664881, 401664901, 401664936},
		["Blaze"] = {150939022, 150939038, 150939047, 150939056, 150939063, 150939082},
		["Among Us"] = {5752463190, 5752463190, 5752463190, 5752463190, 5752463190, 5752463190},
		["Dark Night"] = {6285719338, 6285721078, 6285722964, 6285724682, 6285726335, 6285730635},
		["Bright Pink"] = {271042516, 271077243, 271042556, 271042310, 271042467, 271077958},
		["Purple Sky"] = {570557514, 570557775, 570557559, 570557620, 570557672, 570557727},
		["Galaxy"] = {15125283003, 15125281008, 15125277539, 15125279325, 15125274388, 15125275800},
		["Pinky Sky"] = {11427769401, 11427770685, 11427769401, 11427769401, 11427769401, 11427771954},
		["Sky 2"] = {17279854976, 17279856318, 17279858447, 17279860360, 17279862234, 17279864507},
		["Sky 3"] = {12064107, 12064152, 12064121, 12063984, 12064115, 12064131},
	}
	local skyNames = {"Default", "Blue Sky", "Vaporwave", "Redshift", "Blaze", "Among Us", "Dark Night", "Bright Pink", "Purple Sky", "Galaxy", "Pinky Sky", "Sky 2", "Sky 3"}
	M.SkyboxNames = skyNames
	local ownedSky, skyOriginal = nil, nil
	local skyProperties = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}
	local function restoreSkybox()
		if ownedSky then
			destroyObject(ownedSky)
			ownedSky = nil
		elseif skyOriginal and skyOriginal.Object and skyOriginal.Object.Parent then
			for _, key in ipairs(skyProperties) do pcall(function() skyOriginal.Object[key] = skyOriginal[key] end) end
		end
		skyOriginal = nil
	end
	local function applySkybox()
		restoreSkybox()
		if not S.SkyboxEnabled or S.SkyboxChoice == "Default" or not skyData[S.SkyboxChoice] then return end
		local sky = _Lighting:FindFirstChildOfClass("Sky")
		if sky then
			skyOriginal = {Object = sky}
			for _, key in ipairs(skyProperties) do skyOriginal[key] = sky[key] end
		else
			sky = Instance.new("Sky")
			sky.Name = "BurmaldaHookSkybox"
			sky.Parent = _Lighting
			ownedSky = sky
		end
		local data = skyData[S.SkyboxChoice]
		for index, key in ipairs(skyProperties) do sky[key] = "rbxassetid://" .. tostring(data[index]) end
	end
	M.ApplySkybox = applySkybox
	M.SetSkyboxEnabled = function(enabled)
		S.SkyboxEnabled = enabled
		applySkybox()
	end
	M.RestoreWorldVisuals = function()
		M.SetFullbright(false)
		M.SetNoDecoration(false)
		M.SetSkyColorEnabled(false)
		S.SkyboxEnabled = false
		restoreSkybox()
	end
end


do
	local function matches(object)
		return (S.DeleteSpikes and object.Name == "Spikes")
			or (S.DeleteLeaves and (object.Name == "LeavesTop" or object.Name == "Leafs"))
	end
	local function scan()
		if not S.DeleteSpikes and not S.DeleteLeaves then return end
		for _, object in ipairs(workspace:GetDescendants()) do
			if matches(object) then pcall(function() object:Destroy() end) end
		end
	end
	connect(workspace.DescendantAdded, function(object)
		if not Runtime.Unloaded and matches(object) then task.defer(function() pcall(function() object:Destroy() end) end) end
	end)
	M.ScanWorldRemovals = scan
	M.SetDeleteSpikes = function(enabled) S.DeleteSpikes = enabled; if enabled then scan() end end
	M.SetDeleteLeaves = function(enabled) S.DeleteLeaves = enabled; if enabled then scan() end end
end


do
	local jumpParts = {}
	local function clearJumpParts()
		for _, part in ipairs(jumpParts) do destroyObject(part) end
		table.clear(jumpParts)
	end
	local function onJump(_, newState)
		if newState ~= Enum.HumanoidStateType.Jumping or not S.JumpCircles or Runtime.Unloaded then return end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local part = Instance.new("Part")
		part.Name = "BurmaldaHookJumpCircle"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Material = Enum.Material.Neon
		part.Color = Runtime.ExtraColors.JumpCircle
		part.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.9, 0)) * CFrame.Angles(math.rad(90), 0, 0)
		part.Parent = workspace
		local mesh = Instance.new("SpecialMesh", part)
		mesh.MeshId = "rbxassetid://3270017"
		mesh.MeshType = Enum.MeshType.FileMesh
		local tweenService = game:GetService("TweenService")
		if tweenService and tweenService.Create then
			pcall(function()
				tweenService:Create(part, TweenInfo.new(0.4), {Transparency = 1}):Play()
				tweenService:Create(mesh, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = Vector3.new(8, 8, 0.2)}):Play()
			end)
		end
		table.insert(jumpParts, part)
		while #jumpParts > 12 do destroyObject(table.remove(jumpParts, 1)) end
		task.delay(0.45, function() destroyObject(part) end)
	end
	local function attachCharacter(character)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then connect(humanoid.StateChanged, onJump) end
	end
	if LocalPlayer.Character then attachCharacter(LocalPlayer.Character) end
	connect(LocalPlayer.CharacterAdded, attachCharacter)
	M.TriggerJumpCircle = onJump
	M.GetJumpCircleCount = function()
		local count = 0
		for _, part in ipairs(jumpParts) do if part.Parent then count += 1 end end
		return count
	end
	M.ClearJumpCircles = clearJumpParts
	M.SetJumpCircles = function(enabled) S.JumpCircles = enabled; if not enabled then clearJumpParts() end end

	local soundService = game:GetService("SoundService")
	local sounds = {}
	local killIds = {"6350854289", "132050044560917", "125662494668382", "130940311850179"}
	local killNames = {"Random", "Sound 1", "Sound 2", "Sound 3", "Sound 4"}
	M.KillSoundIds = killIds
	M.KillSoundNames = killNames
	local doubleId = "116907610084760"
	local function clearSounds()
		for _, sound in ipairs(sounds) do destroyObject(sound) end
		table.clear(sounds)
	end
	M.PlayKillSound = function()
		if not S.KillSound or Runtime.Unloaded then return end
		local state = M.KillSoundState
		local now = os.clock()
		table.insert(state.Times, now)
		for index = #state.Times, 1, -1 do if now - state.Times[index] > 10 then table.remove(state.Times, index) end end
		local id
		if #state.Times >= 2 and now - state.LastDouble > 1 then
			id = doubleId
			state.LastDouble = now
		else
			local choice = table.find(killNames, S.KillSoundChoice)
			id = choice and choice > 1 and killIds[choice - 1] or killIds[math.random(1, #killIds)]
		end
		local sound = Instance.new("Sound")
		sound.Name = "BurmaldaHookKillSound"
		sound.Volume = S.KillSoundVolume
		sound.SoundId = "rbxassetid://" .. id
		sound.Parent = soundService or pGui
		sound:Play()
		table.insert(sounds, sound)
		while #sounds > 12 do destroyObject(table.remove(sounds, 1)) end
		M.Status.killSoundCalls += 1
		M.Status.lastKillSound = sound.SoundId
		task.delay(6, function() destroyObject(sound) end)
		return sound
	end
	M.ClearKillSounds = clearSounds
	M.SetKillSound = function(enabled) S.KillSound = enabled; if not enabled then clearSounds() end end
end


local function column(tabName, right)
	local left, rightColumn = getTab(tabName)
	return right and rightColumn or left
end
local rapidSet = createFeature(column("COMBAT", true), "Rapid Fire", false, function(v) M.SetRapidFire(v) end)
addSlider(rapidSet, "Fire Delay", 1, 50, 2, function(v) S.RapidFireDelay = v / 100 end)
createFeature(column("COMBAT", true), "Full Auto", false, function(v) M.SetFullAuto(v) end, false)
local meleeSet = createFeature(column("COMBAT", true), "Melee Mods", false, function(v) M.SetMeleeMods(v) end)
addSlider(meleeSet, "Melee Speed", 1, 50, 5, function(v) S.MeleeSpeed = v / 100 end)
addSlider(meleeSet, "Melee Range", 1, 20, 5, function(v) S.MeleeRange = v end)
local hitboxSet = createFeature(column("COMBAT", true), "Hitbox Expander", false, function(v) M.SetHitboxExpander(v) end)
addSlider(hitboxSet, "Size Multiplier", 50, 205, 50, function(v) S.HitboxSize = v / 10; M.ApplyHitboxVisuals() end)
addSlider(hitboxSet, "Transparency", 0, 10, 2, function(v) S.HitboxTransparency = v / 10; M.ApplyHitboxVisuals() end)
addColor(hitboxSet, "Color", function(color) Runtime.ExtraColors.Hitbox = color; M.ApplyHitboxVisuals() end)

createFeature(column("COMBAT", true), "Reload Indicator", false, function(v)
	S.ReloadIndicator = v
	if v then M.InstallReloadHook() end
	M.UpdateReload()
end, false)
local bulletSet = createFeature(column("COMBAT", true), "Bullet Tracers", false, function(v) M.SetBulletTracers(v) end)
addDropdown(bulletSet, "Texture", {"Beam", "Lightning", "Heartrate", "Chain", "Glitch", "Swirl"}, 1, function(v) S.BulletTracerStyle = v end)
addSlider(bulletSet, "Width", 1, 50, 15, function(v) S.BulletTracerWidth = v / 10 end)
addSlider(bulletSet, "Transparency", 0, 10, 0, function(v) S.BulletTracerTransparency = v / 10 end)
addSlider(bulletSet, "Life Time", 1, 30, 5, function(v) S.BulletTracerLifetime = v / 10 end)
addColor(bulletSet, "Color", function(color) Runtime.ExtraColors.BulletTracer = color end)
local thirdSet = createFeature(column("VISUALS", true), "Third Person", false, function(v) M.SetThirdPerson(v) end)
addSlider(thirdSet, "Camera Distance", 5, 50, 10, function(v) S.ThirdPersonDistance = v end)
local stretchSet = createFeature(column("VISUALS", true), "Stretch Resolution", false, function(v) M.SetStretch(v) end)
addSlider(stretchSet, "Stretch Amount", 30, 100, 65, function(v) S.StretchValue = v / 100 end)
local jumpSet = createFeature(column("VISUALS", true), "Jump Circles", false, function(v) M.SetJumpCircles(v) end)
addColor(jumpSet, "Circle Color", function(color) Runtime.ExtraColors.JumpCircle = color end)

createFeature(column("VISUALS", false), "Fullbright", false, function(v)
	if v then
		if _fFS["Night Vision"] then _fFS["Night Vision"](false) end
		if fogEnabled and _fFS["Custom Fog"] then _fFS["Custom Fog"](false) end
		if S.LowPC and _fFS["Low PC"] then _fFS["Low PC"](false) end
	end
	M.SetFullbright(v)
end, false)
createFeature(column("VISUALS", false), "No Decoration", false, function(v) M.SetNoDecoration(v) end, false)
local skyColorSet = createFeature(column("VISUALS", false), "Sky Color", false, function(v) M.SetSkyColorEnabled(v) end)
addColor(skyColorSet, "Tint", function(color) Runtime.ExtraColors.Sky = color; M.ApplySkyColor() end)
local skyboxSet = createFeature(column("VISUALS", false), "Skybox", false, function(v) M.SetSkyboxEnabled(v) end)
addDropdown(skyboxSet, "Preset", M.SkyboxNames, 1, function(v) S.SkyboxChoice = v; M.ApplySkybox() end)
createFeature(column("VISUALS", false), "Delete Spikes", false, function(v) M.SetDeleteSpikes(v) end, false)
createFeature(column("VISUALS", false), "Delete Leaves", false, function(v) M.SetDeleteLeaves(v) end, false)
local killSoundSet = createFeature(column("MISC", true), "Kill Sound", false, function(v) M.SetKillSound(v) end)
addDropdown(killSoundSet, "Sound", M.KillSoundNames, 1, function(v) S.KillSoundChoice = v end)
addSlider(killSoundSet, "Kill Volume", 0, 50, 10, function(v) S.KillSoundVolume = v / 10 end)

M.Heartbeat = function(dt)
	if Runtime.Unloaded then return end
	M.ApplyWeaponMods()
	M.UpdateReload()
	M.UpdateBulletTracers()
	M.UpdateHitboxes(dt)
	M.ApplyFullbright()
end
M.Render = function()
	if not Runtime.Unloaded then M.UpdateCamera() end
end
M.HeartbeatConnection = RunService.Heartbeat:Connect(M.Heartbeat)
M.RenderConnection = RunService.RenderStepped:Connect(M.Render)

local function cleanup()
	if M.HeartbeatConnection then pcall(function() M.HeartbeatConnection:Disconnect() end) end
	if M.RenderConnection then pcall(function() M.RenderConnection:Disconnect() end) end
	for _, connection in ipairs(moduleConnections) do pcall(function() connection:Disconnect() end) end
	table.clear(moduleConnections)
	M.RestoreWeaponMods()
	M.CleanupReload()
	M.ClearBulletTracers()
	M.RestoreHitboxes()
	M.CleanupCamera()
	M.RestoreWorldVisuals()
	M.ClearJumpCircles()
	M.ClearKillSounds()
end
M.Cleanup = cleanup
onCleanup(cleanup)
end
initializeVomaglaFeatures()
end 


do
	local lc, rc = getTab("MISC")
	local editor = createFeature(rc, "Anti Aim", false, function(value)
		S.AntiAim = value
		if not value and Runtime.AntiAimState then Runtime.AntiAimState.Restore() end
	end)
	addDropdown(editor, "Mode", {"Under Ground", "Spin"}, 1, function(value)
		S.AntiAimMode = value
	end)
	local depthSetter = addSlider(editor, "Depth", 1, 12, 3, function(value)
		S.AntiAimDepth = value
	end)
	local spinSetter = addSlider(editor, "Spin Speed", 30, 720, 180, function(value)
		S.AntiAimSpin = value
	end)
	addBind(editor, "Toggle Bind", "None", function()
		if _fFS["Anti Aim"] then _fFS["Anti Aim"](not S.AntiAim) end
	end)
	Runtime.AntiAimControls = {Depth = depthSetter, Spin = spinSetter}

	local AntiAimState = {Saved = nil, Angle = 0}
	Runtime.AntiAimState = AntiAimState
	local function rootPart()
		local character = LocalPlayer and LocalPlayer.Character
		if not character then return nil end
		return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character.PrimaryPart
	end
	function AntiAimState.Restore()
		local saved = AntiAimState.Saved
		AntiAimState.Saved = nil
		if not saved or not saved.Root or not saved.Root.Parent then return end
		pcall(function() saved.Root.CFrame = saved.CFrame end)
	end
	AntiAimState.Connection = RunService.Heartbeat:Connect(function(dt)
		if Runtime.Unloaded or not S.AntiAim then
			AntiAimState.Restore()
			return
		end
		AntiAimState.Restore()
		local root = rootPart()
		if not root then return end
		local current = root.CFrame
		local position = current.Position
		local spoof
		if S.AntiAimMode == "Spin" then
			AntiAimState.Angle = (AntiAimState.Angle + S.AntiAimSpin * (dt or 0)) % 360
			spoof = CFrame.new(position) * CFrame.Angles(0, math.rad(AntiAimState.Angle), 0)
		else
			spoof = CFrame.new(position - Vector3.new(0, S.AntiAimDepth, 0))
		end
		AntiAimState.Saved = {Root = root, CFrame = current}
		pcall(function() root.CFrame = spoof end)
	end)
	table.insert(Runtime.Cleanup, function()
		AntiAimState.Restore()
		if AntiAimState.Connection then AntiAimState.Connection:Disconnect() end
	end)
end


do
	local calamariFactory = (function()



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
local fallbackBodyParts = {"UpperTorso", "Torso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftArm", "RightArm"}
local function onViewport(camera, point)
	return point and point.Z > 0 and point.X >= 0 and point.X <= camera.ViewportSize.X
		and point.Y >= 0 and point.Y <= camera.ViewportSize.Y
end
local function visiblePartPoint(camera, part)
	if not part or not part.Parent then return nil end
	local ok, point = pcall(camera.WorldToViewportPoint, camera, part.Position)
	if ok and onViewport(camera, point) then return point end
	return nil
end
local function playerFallbackPoint(camera, target, model, distance)
	local point = visiblePartPoint(camera, target.Head or target.head)
	if point or distance > 80 then return point end
	for _, name in ipairs(fallbackBodyParts) do
		local part = model:FindFirstChild(name)
		point = visiblePartPoint(camera, part)
		if point then return point end
	end
	return nil
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
				if Adapter.PlayerViewportFallback then
					onScreen = onViewport(camera, point)
					if not onScreen then
						local fallback = playerFallbackPoint(camera, target, model, distance)
						if fallback then
							point = fallback
							onScreen = true
						end
					end
				end
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
					local centerX, centerY = point.X, point.Y
					if Adapter.PlayerViewportFallback then
						local viewport = camera.ViewportSize
						local topReserve = State.Player.Names and 24 or 6
						local bottomReserve = State.Player.Weapon and 40 or (State.Player.Distance and 22 or 6)
						width = math.floor(math.min(width, math.max(4, viewport.X - 16)))
						height = math.floor(math.min(height, math.max(4, viewport.Y - topReserve - bottomReserve - 8)))
						centerX = math.clamp(centerX, width * 0.5 + 4, viewport.X - width * 0.5 - 4)
						centerY = math.clamp(centerY, height * 0.5 + topReserve, viewport.Y - height * 0.5 - bottomReserve)
					end
					setProperty(entry.Main, "Position", UDim2.fromOffset(centerX, centerY))
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
	if options.Lighting == true then
		lightingClock += step
		if lightingClock >= 0.2 or API.Diagnostics.LightingDirty then
			lightingClock = 0
			API.Diagnostics.LightingDirty = nil
			ok, err = pcall(updateLighting); if not ok then API.Diagnostics.LightingError = tostring(err) end
		end
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
	S.Calamari = type(S.Calamari) == "table" and S.Calamari or {}
	local calamari = calamariFactory({
		Game = "rost alpha",
		State = S.Calamari,
		Camera = "None",
		Lighting = false,
		IsActive = function() return not Runtime.Unloaded end,
		IsLowPC = function() return S.LowPC == true end,
		Adapter = {
			GetViewmodels = function()
				if type(Runtime.GetCalamariViewmodel) ~= "function" then return {} end
				local ok, model = pcall(Runtime.GetCalamariViewmodel)
				return ok and model and {model} or {}
			end,
		},
	})
	Runtime.CalamariVisuals = calamari
	onCleanup(function()
		calamari.Unload()
		if Runtime.CalamariVisuals == calamari then Runtime.CalamariVisuals = nil end
	end)
	local mountCalamari = (function()


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
	mountCalamari(calamari, {Camera = "None", Lighting = false})
end





local function updateSharedTarget()
	if ProjectileSilent then
		local ok, err = pcall(ProjectileSilent.Update)
		Runtime.LastTargetError = ok and nil or tostring(err)
		if not ok then
			SA_CurrentTarget = nil
			return
		end
	end
	if S.SilentAim and ProjectileSilent then
		SA_CurrentTarget = ProjectileSilent.TargetVisible and ProjectileSilent.TargetPart or nil
		return
	end
	if not S.MBTargetLine then
		SA_CurrentTarget = nil
		return
	end

	local target = nil
	local shortestDistance = S.MBUseFOV and S.FOV or math.huge
	local lowestHP = math.huge
	local currentCamera = workspace.CurrentCamera or Camera
	local camPos2 = currentCamera.CFrame.Position
	local vp = currentCamera.ViewportSize
	local center = S.MBFovMode == "pc"
		and UIS:GetMouseLocation()
		or Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local priority = S.MBPriority
	local candidates = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not character then continue end
		local root
		if ProjectileSilent and ProjectileSilent.ResolveTargetPart then
			root = ProjectileSilent.ResolveTargetPart(character)
		elseif S.MBTargetPart == 2 then
			root = character:FindFirstChild("Head") or character:FindFirstChild("HeadHitbox") or character:FindFirstChild("HumanoidRootPart")
		elseif S.MBTargetPart == 3 then
			root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("HeadHitbox") or character:FindFirstChild("Head")
		elseif S.MBTargetPart == 4 then
			local randomParts = {}
			for _, name in ipairs({"HeadHitbox", "Head", "HumanoidRootPart"}) do
				local part = character:FindFirstChild(name)
				if part then table.insert(randomParts, part) end
			end
			root = #randomParts > 0 and randomParts[math.random(1, #randomParts)] or nil
		else
			root = character:FindFirstChild("HeadHitbox") or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 then continue end
		if (root.Position - camPos2).Magnitude > S.MBMaxDist then continue end
		if S.MBVisibleOnly and not isVisible(root, character) then continue end
		local projected, onScreen = currentCamera:WorldToViewportPoint(root.Position)
		if onScreen and projected.Z > 0 then
			local distance = (Vector2.new(projected.X, projected.Y) - center).Magnitude
			if not S.MBUseFOV or distance <= S.FOV then
				table.insert(candidates, {root = root, hum = humanoid, dist = distance})
			end
		end
	end

	if priority == "hp" then
		for _, candidate in ipairs(candidates) do
			local hp = candidate.hum.Health
			if hp < lowestHP or (hp == lowestHP and candidate.dist < shortestDistance) then
				lowestHP = hp
				shortestDistance = candidate.dist
				target = candidate.root
			end
		end
	else
		for _, candidate in ipairs(candidates) do
			if candidate.dist < shortestDistance then
				shortestDistance = candidate.dist
				target = candidate.root
			end
		end
	end
	SA_CurrentTarget = target
end
Runtime.UpdateSharedTarget = updateSharedTarget
onCleanup(function()
	Runtime.UpdateSharedTarget = nil
	SA_CurrentTarget = nil
end)

task.spawn(function()
	while task.wait(S.LowPC and 0.1 or 0.05) do
		if Runtime.Unloaded then break end
		updateSharedTarget()
	end
end)

local speedRostConn = nil
local function startSpeedRost()
	if speedRostConn then speedRostConn:Disconnect(); speedRostConn = nil end
	speedRostConn = RunService.Heartbeat:Connect(function()
		if Runtime.Unloaded or not S.SpeedRostAlpha then return end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not root or hum.Health <= 0 then return end
		local direction = hum.MoveDirection
		if direction.Magnitude <= 0 then return end
		
		
		local velocity = root.AssemblyLinearVelocity
		local speed = math.clamp(tonumber(S.SpeedRostValue) or 30, 0, 60)
		root.AssemblyLinearVelocity = Vector3.new(direction.X * speed, velocity.Y, direction.Z * speed)
	end)
	onCleanup(function()
		if speedRostConn then speedRostConn:Disconnect(); speedRostConn = nil end
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

do
	local function installSilentNamecall()
	local oldNamecall = nil
	local restoreNamecall = nil
	Runtime.NamecallPath = "pending"
	Runtime.CallWorldRay = function(self, beamOrigin, ...)
		local results = table.pack(oldNamecall(self, ...))
		local calamari = Runtime.CalamariVisuals
		local calamariShots = calamari and (calamari.State.Bullet.Enabled
			or calamari.State.HitEffects.Enabled or calamari.State.HitNotifications.Enabled)
		local firstArg, secondArg = ...
		local rayDirection = typeof(firstArg) == "Ray" and firstArg.Direction
			or (typeof(secondArg) == "Vector3" and secondArg or nil)
		local calamariAllowed = calamariShots and (not rayDirection or rayDirection.Magnitude > 50)
		if (S.BulletTracers and Runtime.VomaglaFeatures) or calamariAllowed then
			local hitPosition, hitInstance = nil, nil
			if typeof(results[1]) == "RaycastResult" then
				hitPosition = results[1].Position
				hitInstance = results[1].Instance
			elseif typeof(results[2]) == "Vector3" then
				hitPosition = results[2]
			end
			if hitPosition then
				if S.BulletTracers and Runtime.VomaglaFeatures then
					Runtime.VomaglaFeatures.RecordRaycast(beamOrigin, hitPosition)
				end
				if calamariAllowed then
					calamari.Impact(beamOrigin, hitPosition, hitInstance, hitInstance and hitInstance.Name or nil)
				end
			end
		end
		return unpack(results, 1, results.n)
	end
	
	
	
	local function getCachedTarget()
		if not ProjectileSilent then
			local target = SA_CurrentTarget
			if not target or not target.Parent then return nil end
			return target, target.Position
		end
		local target = ProjectileSilent.TargetPart
		local humanoid = ProjectileSilent.TargetHumanoid
		if ProjectileSilent.TargetVisible ~= true then return nil end
		if not target or not target.Parent or (humanoid and humanoid.Health <= 0) then
			return nil
		end
		
		
		local targetPosition = target.Position
		local targetOffset = ProjectileSilent.TargetOffset
		if typeof(targetOffset) == "Vector3" then
			if targetOffset.X ~= 0 or targetOffset.Y ~= 0 or targetOffset.Z ~= 0 then
				targetPosition = targetPosition + targetOffset
			end
		elseif typeof(ProjectileSilent.TargetPosition) == "Vector3" then
			targetPosition = ProjectileSilent.TargetPosition
		end
		return target, targetPosition
	end

	local function silentNamecall(self, ...)
		local method = type(getnamecallmethod) == "function" and getnamecallmethod() or nil
		local executorCall = checkcaller and checkcaller() or false
		local worldRay = self == workspace and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList")
		local calamari = Runtime.CalamariVisuals
		local visualShots = calamari and (calamari.State.Bullet.Enabled
			or calamari.State.HitEffects.Enabled or calamari.State.HitNotifications.Enabled) or false
		if Runtime.Unloaded then return oldNamecall(self, ...) end
		if Runtime.CraftingMenuOpen then return oldNamecall(self, ...) end

		if not S.SilentAim then
			if worldRay and not executorCall and (S.BulletTracers or visualShots) then
				local args = {...}
				local origin = method == "Raycast" and args[1] or (typeof(args[1]) == "Ray" and args[1].Origin or nil)
				if typeof(origin) == "Vector3" then return Runtime.CallWorldRay(self, origin, ...) end
			end
			return oldNamecall(self, ...)
		end

		local gunbaseOwnsShot = ProjectileCore and ProjectileCore.GunBaseRedirecting == true
		
		if method == "FireServer" then
			if gunbaseOwnsShot then
				if ProjectileCore then ProjectileCore.Status.fallbackSkips += 1 end
				return oldNamecall(self, ...)
			end
			
			
			if ProjectileSilent and ProjectileSilent.IsExplosiveContext(self) then
				if ProjectileCore then
					ProjectileCore.Status.explosiveSkips += 1
					ProjectileCore.Status.lastShotReason = "explosive-remote-original"
				end
				return oldNamecall(self, ...)
			end
			if not ProjectileSilent or not ProjectileSilent.HasWeaponAction() then
				if ProjectileCore then
					ProjectileCore.Status.actionSkips += 1
					ProjectileCore.Status.lastShotReason = "no-weapon-action-remote-original"
				end
				return oldNamecall(self, ...)
			end
			local target, targetPosition = getCachedTarget()
			if not target then return oldNamecall(self, ...) end
			if ProjectileCore then ProjectileCore.Status.remoteCalls += 1 end
			if math.random(1, 100) > S.MBHitChance then
				if ProjectileCore then ProjectileCore.Status.lastShotReason = "fireserver-hit-chance-original" end
				return oldNamecall(self, ...)
			end
			local args = table.pack(...)
			local patched = false
			for index = 1, args.n do
				local value = args[index]
				if typeof(value) == "Vector3" then
					args[index] = targetPosition
					patched = true
				elseif typeof(value) == "CFrame" then
					args[index] = CFrame.new(targetPosition)
					patched = true
				end
			end
			if patched and ProjectileCore then
				ProjectileCore.Status.remoteRedirects += 1
				ProjectileCore.Status.lastShotReason = "fireserver-redirected"
				ProjectileSilent.NoteShot(target)
			end
			return oldNamecall(self, unpack(args, 1, args.n))
		end

		if executorCall or not worldRay then return oldNamecall(self, ...) end
		local args = {...}
		local originalOrigin = nil
		if method == "Raycast" then
			if typeof(args[1]) ~= "Vector3" or typeof(args[2]) ~= "Vector3" then return oldNamecall(self, ...) end
			originalOrigin = args[1]
		else
			if typeof(args[1]) ~= "Ray" then return oldNamecall(self, ...) end
			originalOrigin = args[1].Origin
		end
		local castDistance = method == "Raycast" and args[2].Magnitude or args[1].Direction.Magnitude
		if gunbaseOwnsShot then
			if castDistance > 50 then
				local target, targetPosition = getCachedTarget()
				if target then
					local origin = method == "Raycast" and args[1] or args[1].Origin
					local direction = method == "Raycast" and args[2] or args[1].Direction
					local delta = targetPosition - origin
					local distance = delta.Magnitude
					if distance > castDistance then
						local alignment = (direction.X * delta.X + direction.Y * delta.Y + direction.Z * delta.Z) / (castDistance * distance)
						if alignment >= 0.98 then
							local extended = direction.Unit * distance
							if method == "Raycast" then
								args[2] = extended
							else
								args[1] = Ray.new(origin, extended)
							end
							return Runtime.CallWorldRay(self, originalOrigin, unpack(args))
						end
					end
				end
			end
			if ProjectileCore then ProjectileCore.Status.fallbackSkips += 1 end
			if S.BulletTracers or visualShots then return Runtime.CallWorldRay(self, originalOrigin, ...) end
			return oldNamecall(self, ...)
		end
		if ProjectileSilent and ProjectileSilent.IsExplosiveContext(self) then
			if ProjectileCore then
				ProjectileCore.Status.explosiveSkips += 1
				ProjectileCore.Status.lastShotReason = "explosive-ray-original"
			end
			return oldNamecall(self, ...)
		end

		
		
		
		if castDistance <= 50 then
			if ProjectileCore then
				ProjectileCore.Status.nonCombatSkips += 1
				ProjectileCore.Status.lastShotReason = "short-melee-resource-ray-original"
			end
			return oldNamecall(self, ...)
		end
		if not ProjectileSilent or not ProjectileSilent.HasWeaponAction() then
			if ProjectileCore then
				ProjectileCore.Status.actionSkips += 1
				ProjectileCore.Status.lastShotReason = "no-weapon-action-ray-original"
			end
			return oldNamecall(self, ...)
		end

		local target, targetPosition = getCachedTarget()
		if not target or math.random(1, 100) > S.MBHitChance then
			if S.BulletTracers or visualShots then return Runtime.CallWorldRay(self, originalOrigin, ...) end
			return oldNamecall(self, ...)
		end

		if method == "Raycast" then
			local origin, direction = args[1], args[2]
			local newOrigin = origin
			if S.Manipulation and workspace.CurrentCamera then newOrigin = workspace.CurrentCamera.CFrame.Position end
			local delta = targetPosition - newOrigin
			if delta.Magnitude == 0 or castDistance == 0 then
				if S.BulletTracers or visualShots then return Runtime.CallWorldRay(self, originalOrigin, ...) end
				return oldNamecall(self, ...)
			end
			args[1] = newOrigin
			args[2] = delta.Unit * math.max(castDistance, delta.Magnitude)
			ProjectileSilent.NoteShot(target)
			return Runtime.CallWorldRay(self, newOrigin, unpack(args))
		end

		local ray = args[1]
		local delta = targetPosition - ray.Origin
		if delta.Magnitude == 0 or castDistance == 0 then
			if S.BulletTracers or visualShots then return Runtime.CallWorldRay(self, originalOrigin, ...) end
			return oldNamecall(self, ...)
		end
		args[1] = Ray.new(ray.Origin, delta.Unit * math.max(castDistance, delta.Magnitude))
		ProjectileSilent.NoteShot(target)
		return Runtime.CallWorldRay(self, ray.Origin, unpack(args))
	end

	local function makeNamecallClosure(callback)
		if type(newcclosure) == "function" then
			local ok, wrapped = pcall(newcclosure, callback)
			if ok and type(wrapped) == "function" then return wrapped end
		end
		return callback
	end
	local wrappedNamecall = makeNamecallClosure(silentNamecall)

	Runtime._InstallStandardNamecall = function()
		if oldNamecall or type(hookmetamethod) ~= "function" then return end
		local ok, original = pcall(hookmetamethod, game, "__namecall", wrappedNamecall)
		if ok and type(original) == "function" then
			oldNamecall = original
			Runtime.NamecallPath = "hookmetamethod"
			restoreNamecall = function()
				pcall(hookmetamethod, game, "__namecall", original)
			end
		end
	end
	Runtime._InstallStandardNamecall()

	
	if not oldNamecall and type(getrawmetatable) == "function" then
		local ok, mt = pcall(getrawmetatable, game)
		if ok and type(mt) == "table" and type(mt.__namecall) == "function" then
			local original = mt.__namecall
			local wasReadonly = true
			if type(isreadonly) == "function" then
				pcall(function() wasReadonly = isreadonly(mt) end)
			end
			local function setMetaReadonly(value)
				if type(setreadonly) == "function" then
					pcall(setreadonly, mt, value)
				elseif value and type(makereadonly) == "function" then
					pcall(makereadonly, mt)
				elseif not value and type(makewriteable) == "function" then
					pcall(makewriteable, mt)
				end
			end
			setMetaReadonly(false)
			if pcall(function() mt.__namecall = wrappedNamecall end) and mt.__namecall == wrappedNamecall then
				oldNamecall = original
				Runtime.NamecallPath = "raw-metatable"
				setMetaReadonly(wasReadonly)
				restoreNamecall = function()
					setMetaReadonly(false)
					pcall(function() mt.__namecall = original end)
					setMetaReadonly(wasReadonly)
				end
			else
				pcall(function() mt.__namecall = original end)
				setMetaReadonly(wasReadonly)
			end
		end
	end
	if not oldNamecall then
		Runtime.NamecallPath = "unavailable"
		Runtime.NamecallError = "No compatible __namecall hook; GunBase path remains active"
	end
	onCleanup(function()
		if restoreNamecall then pcall(restoreNamecall) end
		oldNamecall = nil
		restoreNamecall = nil
		Runtime._InstallStandardNamecall = nil
		Runtime.CallWorldRay = nil
	end)
	end
	installSilentNamecall()
end

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
