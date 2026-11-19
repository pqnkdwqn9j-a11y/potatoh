local _pdEnv = getgenv and getgenv() or _G
if _pdEnv.BurmaldaProjectDelta and _pdEnv.BurmaldaProjectDelta.UnloadAll then
	pcall(_pdEnv.BurmaldaProjectDelta.UnloadAll)
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
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local S = {
	SilentAim = false,
	SilentFOV = 20,
	SilentRange = 1000,
	SilentPart = "Head",
	SilentPriority = "Distance",
	SilentTeamCheck = false,
	SilentWallCheck = false,
	SilentPrediction = false,
	SilentHitChance = 100,
	SilentSticky = false,
	SilentRandomPart = false,
	SilentAutoShoot = false,
	SilentMagicBullet = false,
	SilentInstantHit = false,
	SilentWallbang = false,
	SilentHoldKey = "None",
	SilentHoldMode = false,
	SilentKeybindOnly = false,
	SilentTargetNPC = true,
	SilentTargetHeli = false,
	SilentFOVCircle = false,
	SilentFOVColor = Color3.fromRGB(129, 210, 255),
	SilentFOVThickness = 2,
	SilentTracer = false,
	SilentTracerThickness = 0.25,
	SilentTracerLifetime = 0.5,
	SilentTracerTextureSpeed = 0,
	SilentPitchResolver = false,
	SilentCurve = false,
	SilentCurveAmount = 6,
	SilentCurveSegments = 12,
	SilentCurveRandom = true,
	SilentHSR = false,
	SilentSticky = false,

	Aimbot = false,
	AimbotFOV = 120,
	AimbotSmooth = 40,
	AimbotPrediction = false,
	AimbotWallCheck = false,
	AimbotTeamCheck = false,
	AimbotNearestCursor = false,
	AimbotKey = "MouseButton2",
	AimbotPart = "Head",

	TriggerBot = false,
	TriggerKey = "MouseButton1",
	TriggerDelay = 50,
	TriggerPart = "Head",

	NoSpread = false,
	NoRecoil = false,
	InstantADS = false,
	MultiBullet = false,
	DoubleTap = false,
	RemoveSandboxing = false,
	RemoveRechamber = false,
	MeleeReach = false,
	MeleeReachAmount = 2.0,
	InstantLean = false,
	NoBob = false,
	InstantBullet = false,
	RangeMult = false,
	RangeAmount = 5,
	RPMEnabled = false,
	RPMMultiplier = 1,
	HeadshotSound = false,
	BodySound = false,

	HitsoundEnabled = false,
	HitsoundSound = "Minecraft",
	HitsoundVolume = 100,
	HitNotify = true,
	HeadshotSound = false,
	BodySound = false,
	ShootSoundEnabled = false,
	ShootSoundVolume = 100,
	TracerEnabled = false,
	TracerStyle = "Default",
	TracerColor = Color3.fromRGB(100, 255, 150),
	TracerDuration = 0.5,
	TracerThickness = 0.15,

	Speed = false,
	SpeedValue = 50,
	Fly = false,
	FlySpeed = 10,
	FlyVSpeed = 10,
	Noclip = false,
	NoclipSpeed = 2,
	NoclipLayers = 1,
	BunnyHop = false,
	LongJump = false,
	LongJumpPower = 50,
	Spiderman = false,
	SpidermanSpeed = 30,
	TeleportDown = false,
	CarSpeed = false,
	CarSpeedAmount = 2,

	FakeLag = false,
	FakeLagAmount = 5,
	FloorClip = false,
	FloorClipOffset = 5,
	AnimSpoof = false,
	AnimSpoofSpeed = 0,
	Spinbot = false,
	SpinbotSpeed = 6,
	Underworld = false,
	PeekBlink = false,
	TPKill = false,
	SkyPeek = false,
	LongJumpPower = 50,
	CarSpeedAmount = 2,
	FakeLagAmount = 5,

	PlayerESP = false,
	ESPBox = true,
	ESPBoxType = "Corner",
	ESPBoxColor = Color3.fromRGB(255, 255, 255),
	ESPSkeleton = false,
	ESPSkeletonColor = Color3.fromRGB(255, 255, 255),
	ESPHealthBar = true,
	ESPName = true,
	ESPDistance = false,
	ESPWeapon = false,
	ESPInvisible = false,
	ESPInvisibleColor = Color3.fromRGB(255, 120, 255),
	ESPChams = false,
	ESPChamsColor = Color3.fromRGB(255, 255, 255),
	ESPBodyChams = false,
	ESPBodyChamsColor = Color3.fromRGB(255, 255, 255),
	ESPMaxDist = 500,
	ESPTeamCheck = false,

	AIESP = false,
	AIBox = false,
	AIBoxColor = Color3.fromRGB(255, 255, 0),
	AIName = true,
	AIDistance = false,
	AIChams = false,
	AIChamsColor = Color3.fromRGB(255, 0, 0),
	AIRange = 300,

	DroppedESP = false,
	DroppedColor = Color3.fromRGB(255, 100, 0),
	ContainerESP = false,
	ContainerColor = Color3.fromRGB(0, 255, 255),
	VehicleESP = false,
	VehicleColor = Color3.fromRGB(150, 60, 40),
	QuestESP = false,
	QuestColor = Color3.fromRGB(45, 150, 99),
	AirdropNotify = false,
	ObjectESPMaxDist = 500,

	GrenadeESP = false,
	GrenadeAutoThrow = false,

	Snaplines = false,
	SnaplineColor = Color3.fromRGB(255, 255, 255),
	SnapMaxDist = 500,

	Radar = false,
	RadarColor = Color3.fromRGB(255, 60, 60),

	HitChams = false,
	HitChamsColor = Color3.fromRGB(255, 60, 60),
	HitChamsTime = 0.6,
	TargetChams = false,
	TargetChamsColor = Color3.fromRGB(255, 60, 60),

	FullBright = false,
	NoFog = false,
	NoShadows = false,
	CustomSky = false,

	AmbienceEnabled = false,
	AmbienceBrightness = 12,
	AmbienceIndoor = 4,
	AmbienceColor = Color3.fromRGB(80, 255, 140),
	ThirdPerson = false,
	ThirdPersonDist = 10,
	ThirdPersonFadeSpeed = 14,
	ForceRender = false,
	FreeCam = false,
	FreeCamSpeed = 9,
	FOVChanger = false,
	FOVAmount = 100,
	ZoomEnabled = false,
	ZoomAmount = 30,
	ZoomAnimSpeed = 8,
	CrosshairEnabled = false,
	CrosshairPreset = "Custom",
	CrosshairColor = Color3.fromRGB(255, 255, 255),
	CrosshairSides = 4,
	CrosshairLength = 10,
	CrosshairWidth = 2,
	CrosshairGap = 6,
	CrosshairTransparency = 0,
	CrosshairOutline = true,
	CrosshairOutlineColor = Color3.fromRGB(0, 0, 0),
	CrosshairSpin = false,
	CrosshairSpinSpeed = 1,
	CrosshairTargetColor = Color3.fromRGB(255, 80, 80),
	TargetPanel = false,
	TargetPanelFOV = 350,
	TargetPanelCrossDrop = 60,
	TargetPanelLabels = false,
	TargetPanelHPAnim = false,
	TargetPanelStatus = false,
	TargetPanelVis = false,
	StatsHUD = false,
	ESPInvisible = false,
	ESPInvisibleColor = Color3.fromRGB(255, 120, 255),
	ESPBodyChams = false,
	ESPBodyChamsColor = Color3.fromRGB(255, 255, 255),
	AIESP = false,
	AIBox = false,
	AIBoxColor = Color3.fromRGB(255, 255, 0),
	AIName = true,
	AIDistance = false,
	AIChams = false,
	AIChamsColor = Color3.fromRGB(255, 0, 0),
	AIRange = 300,
	DroppedESP = false,
	DroppedColor = Color3.fromRGB(255, 100, 0),
	ContainerESP = false,
	ContainerColor = Color3.fromRGB(0, 255, 255),
	VehicleESP = false,
	VehicleColor = Color3.fromRGB(150, 60, 40),
	QuestESP = false,
	QuestColor = Color3.fromRGB(45, 150, 99),
	AirdropNotify = false,
	GrenadeESP = false,
	GrenadeAutoThrow = false,
	SnaplineColor = Color3.fromRGB(255, 255, 255),
	SnapMaxDist = 500,
	ObjectESPMaxDist = 500,
	CustomSky = false,
	ThirdPersonDist = 10,
	ThirdPersonFadeSpeed = 14,
	TargetPanelFOV = 350,
	TargetPanelCrossDrop = 60,
	TargetPanelLabels = false,
	TargetPanelHPAnim = false,
	TargetPanelStatus = false,
	TargetPanelVis = false,
	VisFlag = false,
	HideUI = false,
	TrashTalk = false,
	ModDetector = false,
	HideGrass = false,
	LowPC = false,
	UIAnimations = true,
	GunChams = false,
	GunChamsColor = Color3.fromRGB(255, 255, 255),
	ArmChams = false,
	ArmChamsColor = Color3.fromRGB(255, 255, 255),
}

local Colors = {
	Accent = Color3.fromRGB(50, 220, 110),
}

local Runtime = {
	State = S,
	Colors = Colors,
	Diagnostics = {Errors = {}, LastError = nil},
	Unloaded = false,
	MenuOpen = false,
	Ready = false,
	PlaceId = 3765739,
	Cleanup = {},
	Drawings = {},
	Guis = {},
	BindApis = {},
	ConfigControls = {},
	FeatureHandlers = {},
	SettingHandlers = {},
	TabNames = {"COMBAT", "VISUALS", "MOVEMENT", "MISC", "CONFIG"},
	ExecutorName = executorName,
	SupportedExecutors = {"Real", "Opiumware", "Madium", "Potassium", "Synapse Z", "Volt", "Volcano", "Solara"},
	Boxes = {},
	Tracers = {},
	HealthBars = {},
	NameTags = {},
	Visuals = {Rigs = {}, Clear = function() end},
}
_projectDeltaEnv.BurmaldaProjectDelta = Runtime

local _instanceNew = Instance.new
local function newScreenGui()
	local gui = _instanceNew("ScreenGui")
	Runtime.Guis[gui] = true
	return gui
end

local uiParent
if type(gethui) == "function" then pcall(function() uiParent = gethui() end) end
if not uiParent then uiParent = LocalPlayer:WaitForChild("PlayerGui") end
for _, name in ipairs({"BurmaldaHookPD", "BurmaldaHookPDStats"}) do
	local old = uiParent:FindFirstChild(name)
	if old then old:Destroy() end
end

local sg = newScreenGui()
sg.Name = "BurmaldaHookPD"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.DisplayOrder = 999998
sg.Parent = uiParent

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.new(0, 80, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "Menu"
openBtn.Visible = true
openBtn.Parent = sg

local env = {
	S = S,
	Colors = Colors,
	Runtime = Runtime,
	Players = Players,
	Workspace = Workspace,
	Lighting = Lighting,
	UIS = UIS,
	TS = TS,
	HttpService = HttpService,
	LocalPlayer = LocalPlayer,
	newDrawing = function(t) return Drawing and Drawing.new(t) or nil end,
	newHighlight = function() return Instance.new("Highlight") end,
}

local function onCleanup(fn)
	table.insert(Runtime.Cleanup, fn)
end
env.onCleanup = onCleanup

setmetatable(env, {__index = function(_, key)
	if key == "Camera" then return Workspace.CurrentCamera end
	return _G[key]
end})

local function guardedStep(name, fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		table.insert(Runtime.Diagnostics.Errors, {name, err, os.clock()})
		Runtime.Diagnostics.LastError = string.format("[%s] %s", name, tostring(err))
	end
end

local Config = {Folder = "BurmaldaPD", Session = {}}
Runtime.Config = Config
_projectDeltaEnv.BurmaldaPDConfigs = type(_projectDeltaEnv.BurmaldaPDConfigs) == "table" and _projectDeltaEnv.BurmaldaPDConfigs or {}
Config.Session = _projectDeltaEnv.BurmaldaPDConfigs

function Config.BuildTable()
	local state = {}
	for key, value in pairs(S) do
		local kind = type(value)
		if kind == "boolean" or kind == "number" or kind == "string" then state[key] = value end
	end
	local colors = {}
	for key, value in pairs(Colors) do
		if type(value) == "table" and value.R then
			colors[key] = {math.floor(value.R * 255 + 0.5), math.floor(value.G * 255 + 0.5), math.floor(value.B * 255 + 0.5)}
		end
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
			if colorKey == "Accent" and setMenuAccent then setMenuAccent(Colors.Accent) end
		elseif control.Kind ~= "feature" and accepted[key] then
			control.Set(S[key], false)
		end
	end
	for key in pairs(accepted) do
		local control = Runtime.ConfigControls[key]
		if control and control.Kind == "feature" then
			local handler = Runtime.FeatureHandlers[key]
			if handler then pcall(handler, S[key]) end
			if _fFS and _fFS[control.Feature] then
				_fFS[control.Feature](S[key])
			end
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

local renderConnection = RunService.RenderStepped:Connect(function(dt)
	if Runtime.Unloaded or not Runtime.Ready then return end
	Camera = Workspace.CurrentCamera or Camera
	if not Camera then return end
	guardedStep("Aim", Runtime.Aim and Runtime.Aim.Update, dt)
	guardedStep("Movement", Runtime.Movement and Runtime.Movement.Update, dt)
	guardedStep("Visuals", Runtime.Visuals and Runtime.Visuals.Update, dt)
	guardedStep("Misc", Runtime.Misc and Runtime.Misc.Update, dt)
	guardedStep("Environment", Runtime.Environment and Runtime.Environment.Update, dt)
end)

onCleanup(function()
	if renderConnection then pcall(function() renderConnection:Disconnect() end); renderConnection = nil end
end)

function Runtime.UnloadAll()
	if Runtime.Unloaded then return end
	Runtime.Unloaded = true
	if renderConnection then renderConnection:Disconnect() end
	for _, fn in ipairs(Runtime.Cleanup) do pcall(fn) end
	Runtime.Cleanup = {}
	for gui in pairs(Runtime.Guis) do pcall(function() gui:Destroy() end) end
	Runtime.Guis = {}
	if _projectDeltaEnv.BurmaldaProjectDelta == Runtime then _projectDeltaEnv.BurmaldaProjectDelta = nil end
end

Runtime.Environment = env
Runtime.Ready = true

do
	local Aim = {
		HookStatus = "not installed",
		CurrentTarget = nil,
		StickyTarget = nil,
		LastFireTime = 0,
		HSRUsingTorso = false,
		CurveBend = nil,
	}
	Runtime.Aim = Aim

	local originalRaycast = nil
	local wrappedRaycast = nil
	local hookInstalled = false
	local fovCircle = newDrawing("Circle")
	local tracerLine = newDrawing("Line")
	local curveLine = newDrawing("Line")
	local hitChamsActive = false
	local hitChamsTimer = 0
	local hitChamsPlayer = nil

	if fovCircle then
		fovCircle.NumSides = 64
		fovCircle.Thickness = 2
		fovCircle.Filled = false
		fovCircle.Transparency = 0.3
		fovCircle.ZIndex = 999
	end
	if tracerLine then
		tracerLine.Thickness = 2
		tracerLine.Transparency = 0.3
		tracerLine.ZIndex = 999
		tracerLine.Visible = false
	end
	if curveLine then
		curveLine.Thickness = 2
		curveLine.Transparency = 0.3
		curveLine.ZIndex = 999
		curveLine.Visible = false
	end

	local function findPart(char, partName)
		if not char then return nil end
		local part = char:FindFirstChild(partName)
		if part then return part end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then return root end
		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		if torso then return torso end
		return nil
	end

	local function getTargetRoot(player)
		local char = player and player.Character
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	end

	local function getTargetPos(player)
		if not player or not player.Character then return nil end
		local partName = S.SilentPart or "Head"

		if S.SilentHSR and partName == "Head" then
			if Aim.HSRUsingTorso then
				if math.random() < 0.6 then
					Aim.HSRUsingTorso = false
				end
			else
				if math.random() < 0.3 then
					Aim.HSRUsingTorso = true
				end
			end
			if Aim.HSRUsingTorso then
				partName = "UpperTorso"
			end
		end

		if S.SilentRandomPart then
			local parts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
			partName = parts[math.random(1, #parts)]
		end

		local root = getTargetRoot(player)
		if not root then return nil end

		local part = findPart(player.Character, partName)
		if not part then return root.Position end

		if S.SilentPrediction then
			local vel = root.AssemblyLinearVelocity or root.Velocity or Vector3.new()
			local camPos = Camera and Camera.CFrame.Position or Vector3.new()
			local dist = (root.Position - camPos).Magnitude
			local bulletSpeed = 500
			local travelTime = dist / bulletSpeed
			return part.Position + vel * travelTime
		end

		return part.Position
	end

	local function canSeeTarget(origin, targetPos, ignoreList)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignoreList or {}
		local direction = (targetPos - origin).Unit * 5000
		local result = Workspace:Raycast(origin, direction, params)
		if not result then return true end
		local hitChar = result.Instance
		local hitPlayer = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and (hitChar == p.Character or hitChar:IsDescendantOf(p.Character)) then
				hitPlayer = p
				break
			end
		end
		return hitPlayer == nil
	end

	local function canWallbang(origin, targetPos, ignoreList)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignoreList or {}
		local direction = (targetPos - origin).Unit * 5000
		local result = Workspace:Raycast(origin, direction, params)
		if not result then return true end
		local material = result.Material
		if material == Enum.Material.Glass or material == Enum.Material.Wood or
		   material == Enum.Material.WoodPlanks or material == Enum.Material.Metal or
		   material == Enum.Material.Plastic or material == Enum.Material.Concrete then
			return true
		end
		return false
	end

	local function getBestTarget()
		local best, bestDist = nil, S.SilentRange or 2000
		local camPos = Camera and Camera.CFrame.Position or Vector3.new()
		local localChar = LocalPlayer.Character
		local ignoreList = {localChar}

		for _, player in ipairs(Players:GetPlayers()) do
			if player == LocalPlayer then continue end

			if S.SilentTeamCheck then
				local localTeam = LocalPlayer.Team
				if localTeam and player.Team == localTeam then continue end
			end

			local char = player.Character
			if not char then continue end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then continue end

			local root = getTargetRoot(player)
			if not root then continue end

			local dist = (root.Position - camPos).Magnitude
			if dist > (S.SilentRange or 2000) then continue end

			local partName = S.SilentPart or "Head"
			local targetPart = findPart(char, partName)
			if not targetPart then continue end

			if S.SilentWallCheck and not S.SilentWallbang then
				if not canSeeTarget(camPos, targetPart.Position, ignoreList) then continue end
			end

			if S.SilentWallbang then
				if not canWallbang(camPos, targetPart.Position, ignoreList) then continue end
			end

			if S.SilentPriority == "Distance" then
				if dist < bestDist then
					best = player
					bestDist = dist
				end
			elseif S.SilentPriority == "Health" then
				if not best or humanoid.Health < (best.Character and best.Character:FindFirstChildOfClass("Humanoid") or {}).Health then
					best = player
					bestDist = dist
				end
			else
				best = player
				bestDist = dist
			end
		end
		return best
	end

	local function drawFOV()
		if not fovCircle then return end
		local center = Camera and Camera.ViewportSize / 2 or Vector2.new(960, 540)
		fovCircle.Position = center
		fovCircle.Radius = S.SilentFOV or 20
		fovCircle.Color = S.SilentFOVColor or Color3.fromRGB(129, 210, 255)
		fovCircle.Thickness = S.SilentFOVThickness or 2
		fovCircle.Visible = S.SilentFOVCircle and S.SilentAim and not Runtime.MenuOpen
	end

	local function drawCurveTracer(originPos, targetPos)
		if not curveLine or not S.SilentCurve then
			if curveLine then curveLine.Visible = false end
			return
		end
		local cam = Camera
		if not cam then return end

		local originScreen, onScreen1 = cam:WorldToViewportPoint(originPos)
		local targetScreen, onScreen2 = cam:WorldToViewportPoint(targetPos)
		if not onScreen1 or not onScreen2 then
			curveLine.Visible = false
			return
		end

		local segments = S.SilentCurveSegments or 12
		local curveAmount = S.SilentCurveAmount or 6
		local bend = Aim.CurveBend
		if not bend or S.SilentCurveRandom then
			bend = Vector2.new(
				math.random(-curveAmount * 50, curveAmount * 50),
				math.random(-curveAmount * 50, curveAmount * 50)
			)
			Aim.CurveBend = bend
		end

		local mid = (originScreen + targetScreen) / 2 + bend
		curveLine.From = originScreen
		curveLine.To = targetScreen
		curveLine.Color = S.TracerColor or Color3.fromRGB(100, 255, 150)
		curveLine.Thickness = (S.SilentTracerThickness or 25) / 100
		curveLine.Visible = true
	end

	local function drawTracer(targetPos)
		if not tracerLine or not S.SilentTracer or S.SilentCurve then
			if tracerLine then tracerLine.Visible = false end
			return
		end
		local center = Camera and Camera.ViewportSize / 2 or Vector2.new(960, 540)
		local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
		if not onScreen then
			tracerLine.Visible = false
			return
		end
		tracerLine.From = center
		tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
		tracerLine.Color = S.TracerColor or Color3.fromRGB(100, 255, 150)
		tracerLine.Thickness = (S.SilentTracerThickness or 25) / 100
		tracerLine.Visible = true
	end

	function Aim.InstallRaycast()
		if hookInstalled then return true end
		if type(hookfunction) ~= "function" or type(Workspace.Raycast) ~= "function" then
			Aim.HookStatus = "unavailable"
			return false
		end
		originalRaycast = Workspace.Raycast
		wrappedRaycast = function(self, origin, direction, params)
			if S.SilentAim then
				local hitChance = S.SilentHitChance or 100
				if math.random(1, 100) > hitChance then
					return originalRaycast(self, origin, direction, params)
				end

				if S.SilentHoldMode then
					local holdKey = S.SilentHoldKey or "None"
					if holdKey == "None" or not UIS:IsKeyDown(Enum.KeyCode[holdKey]) then
						return originalRaycast(self, origin, direction, params)
					end
				end

				if S.SilentKeybindOnly then
					return originalRaycast(self, origin, direction, params)
				end

				local target = Aim.CurrentTarget or Aim.StickyTarget
				if target and target.Character then
					local targetPos = getTargetPos(target)
					if targetPos then
						local char = target.Character
						local root = getTargetRoot(target)

						if S.SilentPitchResolver then
							local head = char:FindFirstChild("Head")
							if head and root then
								local headOffset = head.Position - root.Position
								if headOffset.Y > 3 or headOffset.Y < -1 then
									return originalRaycast(self, origin, direction, params)
								end
							end
						end

						if S.SilentWallbang then
							if S.SilentMagicBullet then
								drawTracer(targetPos)
								if S.SilentCurve then drawCurveTracer(origin, targetPos) end
								return {
									Instance = root,
									Position = targetPos,
									Normal = Vector3.new(0, 1, 0),
									Material = Enum.Material.Plastic,
									Distance = (targetPos - origin).Magnitude,
								}
							end
						end

						local newDirection = (targetPos - origin).Unit * direction.Magnitude

						if S.SilentCurve then
							drawCurveTracer(origin, targetPos)
						else
							drawTracer(targetPos)
						end

						return {
							Instance = root,
							Position = targetPos,
							Normal = Vector3.new(0, 1, 0),
							Material = Enum.Material.Plastic,
							Distance = (targetPos - origin).Magnitude,
						}
					end
				end
			end
			return originalRaycast(self, origin, direction, params)
		end

		local ok, previous = pcall(hookfunction, Workspace.Raycast, wrappedRaycast)
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
		hookInstalled = false
		Aim.HookStatus = "restored"
		Aim.CurrentTarget = nil
		if not S.SilentSticky then Aim.StickyTarget = nil end
		if fovCircle then fovCircle.Visible = false end
		if tracerLine then tracerLine.Visible = false end
		if curveLine then curveLine.Visible = false end
	end

	function Aim.EnableAimbot()
		aimbotRunning = true
	end

	function Aim.Update(dt)
		if S.SilentAim then
			local target = getBestTarget()

			if S.SilentSticky then
				if not Aim.StickyTarget then
					Aim.StickyTarget = target
				end
				if Aim.StickyTarget and Aim.StickyTarget.Character then
					local hum = Aim.StickyTarget.Character:FindFirstChildOfClass("Humanoid")
					if not hum or hum.Health <= 0 then
						Aim.StickyTarget = nil
						target = getBestTarget()
					end
				else
					Aim.StickyTarget = nil
					target = getBestTarget()
				end
			else
				Aim.StickyTarget = nil
			end

			Aim.CurrentTarget = target
			drawFOV()

			if S.SilentAutoShoot and target then
				local now = os.clock()
				if now - Aim.LastFireTime > 0.1 then
					pcall(function() UIS:MouseClick(1) end)
					Aim.LastFireTime = now
				end
			end
		else
			Aim.CurrentTarget = nil
			if not S.SilentSticky then Aim.StickyTarget = nil end
			if fovCircle then fovCircle.Visible = false end
			if tracerLine then tracerLine.Visible = false end
			if curveLine then curveLine.Visible = false end
		end
	end

	onCleanup(function()
		Aim.RestoreRaycast()
	end)
end


do
	local Movement = {
		FlyEnabled = false,
		FlyCFrame = nil,
		NoclipActive = false,
		FakeLagActive = false,
		FakeLagCounter = 0,
		SpidermanCooldown = 0,
		SavedHumanoidState = nil,
		UnderworldActive = false,
		PeekBlinkPos = nil,
		TPKillActive = false,
		SkyPeekActive = false,
		SkyPeekTimer = 0,
	}
	Runtime.Movement = Movement

	local flyConnection = nil
	local noclipConnection = nil
	local bhopConnection = nil
	local fakeLagConnection = nil
	local spidermanConnection = nil
	local underworldConnection = nil
	local animSpoofConnection = nil
	local spinbotConnection = nil

	local function getRoot()
		local char = LocalPlayer.Character
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	end

	local function getHumanoid()
		local char = LocalPlayer.Character
		if not char then return nil end
		return char:FindFirstChildOfClass("Humanoid")
	end

	local function startFly()
		if flyConnection then return end
		Movement.FlyEnabled = true
		local root = getRoot()
		if root then Movement.FlyCFrame = root.CFrame end

		flyConnection = RunService.RenderStepped:Connect(function(dt)
			if not S.Fly or Runtime.Unloaded then Movement.RestoreFly(); return end
			local root = getRoot()
			if not root then return end
			local cam = Camera
			if not cam then return end

			local speed = S.FlySpeed or 10
			local vSpeed = S.FlyVSpeed or 10
			local moveDir = Vector3.new()

			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.C) then moveDir = moveDir - Vector3.new(0, 1, 0) end

			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit
				local newPos = root.Position + moveDir * speed * (dt or 0.016) * 60
				root.CFrame = CFrame.new(newPos) * cam.CFrame.Rotation
			end
		end)
	end

	function Movement.RestoreFly()
		Movement.FlyEnabled = false
		Movement.FlyCFrame = nil
		if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	end

	local function startNoclip()
		if noclipConnection then return end
		Movement.NoclipActive = true
		local layers = S.NoclipLayers or 1
		local speed = S.NoclipSpeed or 2

		noclipConnection = RunService.Stepped:Connect(function()
			if not S.Noclip or Runtime.Unloaded then Movement.RestoreNoclip(); return end
			local char = LocalPlayer.Character
			if not char then return end

			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end

			local root = getRoot()
			if root and UIS:IsKeyDown(Enum.KeyCode.W) then
				local cam = Camera
				if cam then
					local dir = cam.CFrame.LookVector * speed
					root.CFrame = root.CFrame + dir * 0.1
				end
			end
		end)
	end

	function Movement.RestoreNoclip()
		Movement.NoclipActive = false
		if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					pcall(function() part.CanCollide = true end)
				end
			end
		end
	end

	local function startFakeLag()
		if fakeLagConnection then return end
		Movement.FakeLagActive = true
		Movement.FakeLagCounter = 0

		fakeLagConnection = RunService.Heartbeat:Connect(function()
			if not S.FakeLag or Runtime.Unloaded then Movement.RestoreFakeLag(); return end
			local amount = S.FakeLagAmount or 5
			Movement.FakeLagCounter = Movement.FakeLagCounter + 1
			if Movement.FakeLagCounter >= amount then
				Movement.FakeLagCounter = 0
				local root = getRoot()
				if root then
					pcall(function() root.CFrame = root.CFrame end)
				end
			end
		end)
	end

	function Movement.RestoreFakeLag()
		Movement.FakeLagActive = false
		Movement.FakeLagCounter = 0
		if fakeLagConnection then fakeLagConnection:Disconnect() fakeLagConnection = nil end
	end

	function Movement.ApplyFloorClip()
		local root = getRoot()
		if not root then return end
		local offset = S.FloorClipOffset or 5
		local cam = Camera
		if cam then
			local spoofedCFrame = CFrame.new(root.Position - Vector3.new(0, offset, 0)) * cam.CFrame.Rotation
			pcall(function() root.CFrame = spoofedCFrame end)
		end
	end

	function Movement.ApplyAnimSpoof()
		local char = LocalPlayer.Character
		if not char then return end
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.AutoRotate = false
		end
	end

	function Movement.RestoreAnimSpoof()
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.AutoRotate = true
		end
	end

	function Movement.ApplySpinbot()
		local root = getRoot()
		if not root then return end
		local speed = S.SpinbotSpeed or 6
		local angle = (os.clock() * speed * 60) % 360
		local cam = Camera
		if cam then
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(angle), 0)
		end
	end

	local function startUnderworld()
		if underworldConnection then return end
		Movement.UnderworldActive = true

		underworldConnection = RunService.Stepped:Connect(function()
			if not S.Underworld or Runtime.Unloaded then
				Movement.UnderworldActive = false
				if underworldConnection then underworldConnection:Disconnect() underworldConnection = nil end
				return
			end
			local root = getRoot()
			if not root then return end
			local cam = Camera
			if cam then
				local dir = Vector3.new()
				if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
				if dir.Magnitude > 0 then
					dir = dir.Unit * 0.5
					root.CFrame = CFrame.new(root.Position + dir)
				end
			end
		end)
	end

	function Movement.RestoreUnderworld()
		Movement.UnderworldActive = false
		if underworldConnection then underworldConnection:Disconnect() underworldConnection = nil end
	end

	local function doBunnyHop()
		local humanoid = getHumanoid()
		if not humanoid then return end
		if humanoid.FloorMaterial ~= Enum.FloorMaterial.Air then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	local function doLongJump()
		local root = getRoot()
		local humanoid = getHumanoid()
		if not root or not humanoid then return end
		local power = S.LongJumpPower or 50
		local cam = Camera
		if cam then
			local dir = cam.CFrame.LookVector
			root.AssemblyLinearVelocity = dir * power + Vector3.new(0, power * 0.5, 0)
		end
	end

	local function doSpiderman(dt)
		if Movement.SpidermanCooldown > 0 then
			Movement.SpidermanCooldown = Movement.SpidermanCooldown - dt
			return
		end

		local root = getRoot()
		local cam = Camera
		if not root or not cam then return end

		local speed = S.SpidermanSpeed or 30
		local dir = cam.CFrame.LookVector
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {LocalPlayer.Character}
		local result = Workspace:Raycast(root.Position, dir * 5, params)

		if result then
			root.CFrame = root.CFrame + Vector3.new(0, speed * (dt or 0.016), 0)
			Movement.SpidermanCooldown = 0
		else
			Movement.SpidermanCooldown = 3
		end
	end

	local function doTeleportDown()
		local root = getRoot()
		if not root then return end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {LocalPlayer.Character}
		local result = Workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), params)
		if result then
			root.CFrame = CFrame.new(result.Position + Vector3.new(0, 2, 0))
		end
	end

	local function doPeekBlink()
		local root = getRoot()
		if not root then return end
		if not Movement.PeekBlinkPos then
			Movement.PeekBlinkPos = root.Position
		end
		local cam = Camera
		if cam then
			local dir = cam.CFrame.LookVector * 10
			root.CFrame = CFrame.new(root.Position + dir)
		end
	end

	function Movement.RestorePeekBlink()
		local root = getRoot()
		if root and Movement.PeekBlinkPos then
			root.CFrame = CFrame.new(Movement.PeekBlinkPos)
		end
		Movement.PeekBlinkPos = nil
	end

	local function doTPKill(target)
		local root = getRoot()
		if not root or not target or not target.Character then return end
		local targetRoot = getTargetRoot(target)
		if not targetRoot then return end
		local pos = targetRoot.Position + Vector3.new(0, 50, 0)
		root.CFrame = CFrame.new(pos)
	end

	function Movement.RestoreTPKill()
	end

	local function doSkyPeek()
		local root = getRoot()
		if not root then return end
		Movement.SkyPeekActive = true
		Movement.SkyPeekTimer = 2
		root.CFrame = CFrame.new(root.Position + Vector3.new(0, 100, 0))
	end

	function Movement.UpdateSkyPeek(dt)
		if Movement.SkyPeekActive then
			Movement.SkyPeekTimer = Movement.SkyPeekTimer - dt
			if Movement.SkyPeekTimer <= 0 then
				Movement.SkyPeekActive = false
				local root = getRoot()
				if root then
					root.CFrame = CFrame.new(root.Position - Vector3.new(0, 100, 0))
				end
			end
		end
	end

	function Movement.Update(dt)
		dt = dt or 0.016

		if S.Speed then
			local humanoid = getHumanoid()
			if humanoid and humanoid.WalkSpeed ~= S.SpeedValue then
				humanoid.WalkSpeed = S.SpeedValue
			end
		else
			local humanoid = getHumanoid()
			if humanoid and humanoid.WalkSpeed ~= 16 then
				humanoid.WalkSpeed = 16
			end
		end

		if S.Fly and not Movement.FlyEnabled then
			startFly()
		elseif not S.Fly and Movement.FlyEnabled then
			Movement.RestoreFly()
		end

		if S.Noclip and not Movement.NoclipActive then
			startNoclip()
		elseif not S.Noclip and Movement.NoclipActive then
			Movement.RestoreNoclip()
		end

		if S.FakeLag and not Movement.FakeLagActive then
			startFakeLag()
		elseif not S.FakeLag and Movement.FakeLagActive then
			Movement.RestoreFakeLag()
		end

		if S.FloorClip then
			Movement.ApplyFloorClip()
		end

		if S.AnimSpoof then
			Movement.ApplyAnimSpoof()
		else
			Movement.RestoreAnimSpoof()
		end

		if S.Spinbot then
			Movement.ApplySpinbot()
		end

		if S.Underworld and not Movement.UnderworldActive then
			startUnderworld()
		elseif not S.Underworld and Movement.UnderworldActive then
			Movement.RestoreUnderworld()
		end

		if S.BunnyHop and UIS:IsKeyDown(Enum.KeyCode.Space) then
			doBunnyHop()
		end

		if S.LongJump then
		end

		if S.Spiderman then
			doSpiderman(dt)
		end

		if S.CarSpeed then
			local char = LocalPlayer.Character
			if char then
				local vehicle = char:FindFirstChildOfClass("VehicleSeat")
				if vehicle then
					vehicle.MaxSpeed = S.CarSpeedAmount * 50
				end
			end
		end

		Movement.UpdateSkyPeek(dt)
	end

	onCleanup(function()
		Movement.RestoreFly()
		Movement.RestoreNoclip()
		Movement.RestoreFakeLag()
		Movement.RestoreUnderworld()
		Movement.RestorePeekBlink()
		Movement.RestoreAnimSpoof()
	end)
end


do
	local Visuals = {
		Rigs = {},
		ObjectLabels = {},
		Snaplines = {},
		RadarDots = {},
		HitChamsList = {},
		TargetChamsRigs = {},
		WorldLabels = {},
		Clear = function() end,
	}
	Runtime.Visuals = Visuals

	local function getRoot(char)
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	end

	local function getOrCreateRig(player)
		if not Visuals.Rigs[player] then
			Visuals.Rigs[player] = {
				Box = nil,
				NameTag = nil,
				Distance = nil,
				HealthBar = nil,
				WeaponTag = nil,
				SkeletonParts = {},
				Highlight = nil,
				BodyHighlight = nil,
				LastSeen = 0,
				Visible = false,
			}
		end
		return Visuals.Rigs[player]
	end

	local function drawBox(rig, pos, size, color)
		if not rig.Box then
			rig.Box = newDrawing("Square")
			if rig.Box then
				rig.Box.Thickness = 1
				rig.Box.Filled = false
			end
		end
		if rig.Box then
			rig.Box.Position = pos - size / 2
			rig.Box.Size = size
			rig.Box.Color = color or S.ESPBoxColor or Color3.fromRGB(255, 255, 255)
			rig.Box.Visible = S.ESPBox and rig.Visible
		end
	end

	local function drawCornerBox(rig, pos, size, color)
		if not rig.CornerBox then
			rig.CornerBox = {}
			for i = 1, 4 do
				local line = newDrawing("Line")
				if line then
					line.Thickness = 1
					line.Transparency = 0
				end
				rig.CornerBox[i] = line
			end
		end
		local x, y = pos.X, pos.Y
		local w, h = size.X, size.Y
		local cornerLen = math.min(w, h) * 0.3
		local corners = {
			{Vector2.new(x, y), Vector2.new(x + cornerLen, y)},
			{Vector2.new(x, y), Vector2.new(x, y + cornerLen)},
			{Vector2.new(x + w, y), Vector2.new(x + w - cornerLen, y)},
			{Vector2.new(x + w, y), Vector2.new(x + w, y + cornerLen)},
			{Vector2.new(x, y + h), Vector2.new(x + cornerLen, y + h)},
			{Vector2.new(x, y + h), Vector2.new(x, y + h - cornerLen)},
			{Vector2.new(x + w, y + h), Vector2.new(x + w - cornerLen, y + h)},
			{Vector2.new(x + w, y + h), Vector2.new(x + w, y + h - cornerLen)},
		}
		for i, line in ipairs(rig.CornerBox) do
			if line and corners[i] then
				line.From = corners[i][1]
				line.To = corners[i][2]
				line.Color = color or S.ESPBoxColor or Color3.fromRGB(255, 255, 255)
				line.Visible = S.ESPBox and rig.Visible and S.ESPBoxType == "Corner"
			end
		end
	end

	local function drawNameTag(rig, name, pos)
		if not rig.NameTag then
			rig.NameTag = newDrawing("Text")
			if rig.NameTag then
				rig.NameTag.Size = 13
				rig.NameTag.Center = true
				rig.NameTag.Outline = true
			end
		end
		if rig.NameTag then
			rig.NameTag.Text = name
			rig.NameTag.Position = pos
			rig.NameTag.Color = S.ESPBoxColor or Color3.fromRGB(255, 255, 255)
			rig.NameTag.Visible = S.ESPName and rig.Visible
		end
	end

	local function drawDistance(rig, dist, pos)
		if not rig.Distance then
			rig.Distance = newDrawing("Text")
			if rig.Distance then
				rig.Distance.Size = 11
				rig.Distance.Center = true
				rig.Distance.Outline = true
			end
		end
		if rig.Distance then
			rig.Distance.Text = string.format("%dm", math.floor(dist))
			rig.Distance.Position = pos
			rig.Distance.Color = Color3.fromRGB(200, 200, 200)
			rig.Distance.Visible = S.ESPDistance and rig.Visible
		end
	end

	local function drawWeapon(rig, weaponName, pos)
		if not rig.WeaponTag then
			rig.WeaponTag = newDrawing("Text")
			if rig.WeaponTag then
				rig.WeaponTag.Size = 11
				rig.WeaponTag.Center = true
				rig.WeaponTag.Outline = true
			end
		end
		if rig.WeaponTag then
			rig.WeaponTag.Text = weaponName or ""
			rig.WeaponTag.Position = pos
			rig.WeaponTag.Color = Color3.fromRGB(255, 200, 100)
			rig.WeaponTag.Visible = S.ESPWeapon and rig.Visible and weaponName ~= ""
		end
	end

	local function drawHealthBar(rig, health, maxHealth, startPos)
		if not rig.HealthBar then
			rig.HealthBar = newDrawing("Square")
			if rig.HealthBar then
				rig.HealthBar.Thickness = 1
				rig.HealthBar.Filled = true
			end
		end
		if rig.HealthBar then
			local h = (health / maxHealth) * 40
			rig.HealthBar.Position = Vector2.new(startPos.X - 5, startPos.Y + 40 - h)
			rig.HealthBar.Size = Vector2.new(3, h)
			local ratio = health / maxHealth
			if ratio > 0.5 then
				rig.HealthBar.Color = Color3.fromRGB(0, 255, 0)
			elseif ratio > 0.25 then
				rig.HealthBar.Color = Color3.fromRGB(255, 255, 0)
			else
				rig.HealthBar.Color = Color3.fromRGB(255, 0, 0)
			end
			rig.HealthBar.Visible = S.ESPHealthBar and rig.Visible
		end
	end

	local function drawSnapline(rig, rootPos)
		local cam = Camera
		if not cam then return end
		if not rig.Snapline then
			rig.Snapline = newDrawing("Line")
			if rig.Snapline then
				rig.Snapline.Thickness = 1
				rig.Snapline.Transparency = 0
			end
		end
		if rig.Snapline then
			local center = cam.ViewportSize / 2
			local screenPos, onScreen = cam:WorldToViewportPoint(rootPos)
			if onScreen then
				rig.Snapline.From = center
				rig.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
				rig.Snapline.Color = S.SnaplineColor or Color3.fromRGB(255, 255, 255)
				rig.Snapline.Visible = S.Snaplines and rig.Visible
			else
				rig.Snapline.Visible = false
			end
		end
	end

	local function applyHighlight(rig, char, color)
		if S.ESPChams then
			if not rig.Highlight then
				rig.Highlight = newHighlight()
				if rig.Highlight then
					rig.Highlight.Parent = char
					rig.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				end
			end
			if rig.Highlight then
				rig.Highlight.Enabled = true
				rig.Highlight.FillColor = S.ESPChamsColor or Color3.fromRGB(255, 255, 255)
				rig.Highlight.OutlineColor = S.ESPChamsColor or Color3.fromRGB(255, 255, 255)
				rig.Highlight.FillTransparency = 0.4
				rig.Highlight.OutlineTransparency = 0
			end
		else
			if rig.Highlight then rig.Highlight.Enabled = false end
		end

		if S.ESPBodyChams then
			if not rig.BodyHighlight then
				rig.BodyHighlight = newHighlight()
				if rig.BodyHighlight then
					rig.BodyHighlight.Parent = char
					rig.BodyHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				end
			end
			if rig.BodyHighlight then
				rig.BodyHighlight.Enabled = true
				rig.BodyHighlight.FillColor = S.ESPBodyChamsColor or Color3.fromRGB(255, 255, 255)
				rig.BodyHighlight.OutlineColor = S.ESPBodyChamsColor or Color3.fromRGB(255, 255, 255)
				rig.BodyHighlight.FillTransparency = 0.4
				rig.BodyHighlight.OutlineTransparency = 0
			end
		else
			if rig.BodyHighlight then rig.BodyHighlight.Enabled = false end
		end
	end

	local function getWeaponName(char)
		if not char then return "" end
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") then return child.Name end
		end
		return ""
	end

	function Visuals.ForceRenderAll()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						pcall(function() part.LocalTransparencyModifier = 0 end)
					end
				end
			end
		end
	end

	function Visuals.Clear()
		for player, rig in pairs(Visuals.Rigs) do
			if rig.Box then rig.Box:Remove() rig.Box = nil end
			if rig.CornerBox then
				for _, line in ipairs(rig.CornerBox) do if line then line:Remove() end end
				rig.CornerBox = nil
			end
			if rig.NameTag then rig.NameTag:Remove() rig.NameTag = nil end
			if rig.Distance then rig.Distance:Remove() rig.Distance = nil end
			if rig.HealthBar then rig.HealthBar:Remove() rig.HealthBar = nil end
			if rig.WeaponTag then rig.WeaponTag:Remove() rig.WeaponTag = nil end
			if rig.Snapline then rig.Snapline:Remove() rig.Snapline = nil end
			if rig.Highlight then pcall(function() rig.Highlight:Destroy() end) rig.Highlight = nil end
			if rig.BodyHighlight then pcall(function() rig.BodyHighlight:Destroy() end) rig.BodyHighlight = nil end
		end
		Visuals.Rigs = {}
	end

	local function drawObjectESP()
		local camPos = Camera and Camera.CFrame.Position or Vector3.new()
		local maxDist = S.ObjectESPMaxDist or 500

		for _, obj in ipairs(Workspace:GetDescendants()) do
			if not obj:IsA("BasePart") then continue end
			local name = obj.Name:lower()
			local pos = obj.Position
			local dist = (pos - camPos).Magnitude
			if dist > maxDist then continue end

			local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
			if not onScreen then continue end

			if S.DroppedESP then
				if name:find("drop") or name:find("loot") or name:find("item") then
					if not Visuals.WorldLabels[obj] then
						Visuals.WorldLabels[obj] = newDrawing("Text")
						if Visuals.WorldLabels[obj] then
							Visuals.WorldLabels[obj].Size = 11
							Visuals.WorldLabels[obj].Center = true
							Visuals.WorldLabels[obj].Outline = true
						end
					end
					local label = Visuals.WorldLabels[obj]
					if label then
						label.Text = obj.Name
						label.Position = Vector2.new(screenPos.X, screenPos.Y)
						label.Color = S.DroppedColor or Color3.fromRGB(255, 100, 0)
						label.Visible = true
					end
				end
			end

			if S.ContainerESP then
				if name:find("container") or name:find("crate") or name:find("box") or name:find("barrel") then
					if not Visuals.WorldLabels[obj .. "_cont"] then
						Visuals.WorldLabels[obj .. "_cont"] = newDrawing("Text")
					end
					local label = Visuals.WorldLabels[obj .. "_cont"]
					if label then
						label.Text = "Container"
						label.Position = Vector2.new(screenPos.X, screenPos.Y)
						label.Color = S.ContainerColor or Color3.fromRGB(0, 255, 255)
						label.Visible = true
					end
				end
			end

			if S.VehicleESP then
				if name:find("vehicle") or name:find("car") or name:find("truck") or name:find("jeep") then
					if not Visuals.WorldLabels[obj .. "_veh"] then
						Visuals.WorldLabels[obj .. "_veh"] = newDrawing("Text")
					end
					local label = Visuals.WorldLabels[obj .. "_veh"]
					if label then
						label.Text = "Vehicle"
						label.Position = Vector2.new(screenPos.X, screenPos.Y)
						label.Color = S.VehicleColor or Color3.fromRGB(150, 60, 40)
						label.Visible = true
					end
				end
			end

			if S.QuestESP then
				if name:find("quest") or name:find("objective") or name:find("target") then
					if not Visuals.WorldLabels[obj .. "_quest"] then
						Visuals.WorldLabels[obj .. "_quest"] = newDrawing("Text")
					end
					local label = Visuals.WorldLabels[obj .. "_quest"]
					if label then
						label.Text = "Quest"
						label.Position = Vector2.new(screenPos.X, screenPos.Y)
						label.Color = S.QuestColor or Color3.fromRGB(45, 150, 99)
						label.Visible = true
					end
				end
			end
		end
	end

	local function drawRadar()
		if not S.Radar then return end
	end

	function Visuals.Update(dt)
		Camera = Workspace.CurrentCamera or Camera
		if not Camera then return end

		local camPos = Camera.CFrame.Position
		local maxDist = S.ESPMaxDist or 500

		if S.PlayerESP or S.ESPChams or S.ESPBodyChams or S.Snaplines then
			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer then continue end

				if S.ESPTeamCheck then
					local localTeam = LocalPlayer.Team
					if localTeam and player.Team == localTeam then continue end
				end

				local char = player.Character
				if not char then continue end
				local root = getRoot(char)
				if not root then continue end
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then continue end

				local dist = (root.Position - camPos).Magnitude
				if dist > maxDist then continue end

				local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
				if not onScreen then continue end

				local rig = getOrCreateRig(player)
				rig.LastSeen = os.clock()
				rig.Visible = true

				local height = 50
				local width = 30
				local boxPos = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
				local boxSize = Vector2.new(width, height)

				local isInvisible = false
				local head = char:FindFirstChild("Head")
				if head and head.Transparency > 0.9 then isInvisible = true end

				if isInvisible and S.ESPInvisible then
					drawBox(rig, boxPos, boxSize, S.ESPInvisibleColor or Color3.fromRGB(255, 120, 255))
				else
					if S.ESPBoxType == "Corner" then
						drawCornerBox(rig, boxPos, boxSize, S.ESPBoxColor)
					else
						drawBox(rig, boxPos, boxSize, S.ESPBoxColor)
					end
				end

				drawNameTag(rig, player.Name, Vector2.new(screenPos.X, screenPos.Y - height / 2 - 15))
				drawDistance(rig, dist, Vector2.new(screenPos.X, screenPos.Y + height / 2 + 15))
				drawHealthBar(rig, humanoid.Health, humanoid.MaxHealth, boxPos)
				drawWeapon(rig, getWeaponName(char), Vector2.new(screenPos.X, screenPos.Y + height / 2 + 30))
				drawSnapline(rig, root.Position)
				applyHighlight(rig, char, S.ESPChamsColor)
			end
		end

		if S.DroppedESP or S.ContainerESP or S.VehicleESP or S.QuestESP then
			drawObjectESP()
		end

		local now = os.clock()
		for player, rig in pairs(Visuals.Rigs) do
			if now - rig.LastSeen > 3 then
				rig.Visible = false
				if rig.Box then rig.Box.Visible = false end
				if rig.NameTag then rig.NameTag.Visible = false end
				if rig.Distance then rig.Distance.Visible = false end
				if rig.HealthBar then rig.HealthBar.Visible = false end
				if rig.WeaponTag then rig.WeaponTag.Visible = false end
				if rig.Snapline then rig.Snapline.Visible = false end
				if rig.Highlight then rig.Highlight.Enabled = false end
				if rig.BodyHighlight then rig.BodyHighlight.Enabled = false end
			end
		end
	end

	onCleanup(function()
		Visuals.Clear()
		for obj, label in pairs(Visuals.WorldLabels) do
			if label then label:Remove() end
		end
		Visuals.WorldLabels = {}
	end)
end


do
	local Misc = {}
	Runtime.Misc = Misc

	local savedLighting = {}
	local lightingCaptured = false
	local savedCameraFOV = nil
	local thirdPersonConnection = nil
	local forceRenderConnection = nil
	local trashTalkConnection = nil
	local trashTalkIndex = 1
	local trashTalkMessages = {
		"Nice shot!", "gg", "lol", "ez", "wow", "how?", "lag", "hacker",
		"nice try", "bruh", "really?", "come on", "seriously?", "wowow",
		"gg ez", "noob", "skill issue", "get rekt", "too easy", "lolol"
	}
	local freeCamActive = false
	local freeCamCFrame = nil
	local freeCamInputState = {
		Forward = false, Backward = false, Left = false, Right = false,
		Up = false, Down = false,
	}

	local lightingProps = {
		"Brightness", "ClockTime", "TimeOfDay", "Ambient", "OutdoorAmbient",
		"ExposureCompensation", "FogEnd", "FogStart", "FogColor", "GlobalShadows",
		"EnvironmentDiffuseScale", "EnvironmentSpecularScale",
	}

	local function captureLighting()
		if lightingCaptured then return end
		lightingCaptured = true
		for _, prop in ipairs(lightingProps) do
			local ok, val = pcall(function() return Lighting[prop] end)
			if ok then savedLighting[prop] = val end
		end
	end

	local function restoreLighting()
		for prop, val in pairs(savedLighting) do
			pcall(function() Lighting[prop] = val end)
		end
		lightingCaptured = false
		savedLighting = {}
	end

	local function applyCustomSky()
		if not S.CustomSky then return end
		local sky = Lighting:FindFirstChild("CustomSky")
		if not sky then
			sky = Instance.new("Sky")
			sky.Name = "CustomSky"
			sky.Parent = Lighting
		end
		sky.SkyboxBk = "rbxassetid://159452228"
		sky.SkyboxDn = "rbxassetid://159452223"
		sky.SkyboxFt = "rbxassetid://159452226"
		sky.SkyboxLf = "rbxassetid://159452224"
		sky.SkyboxRt = "rbxassetid://159452227"
		sky.SkyboxUp = "rbxassetid://159452225"
		sky.StarCount = 3000
	end

	local function startThirdPerson()
		if thirdPersonConnection then return end
		thirdPersonConnection = RunService.RenderStepped:Connect(function()
			if not S.ThirdPerson or Runtime.Unloaded then
				Misc.RestoreThirdPerson()
				return
			end
			local cam = Camera
			if not cam then return end
			local dist = S.ThirdPersonDist or 10
			local fadeSpeed = S.ThirdPersonFadeSpeed or 14
			local char = LocalPlayer.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					local offset = cam.CFrame.LookVector * -dist
					cam.CFrame = CFrame.new(root.Position + offset + Vector3.new(0, 3, 0), root.Position)
				end
			end
		end)
	end

	function Misc.RestoreThirdPerson()
		if thirdPersonConnection then thirdPersonConnection:Disconnect() thirdPersonConnection = nil end
	end

	local function startForceRender()
		if forceRenderConnection then return end
		forceRenderConnection = RunService.RenderStepped:Connect(function()
			if not S.ForceRender or Runtime.Unloaded then
				if forceRenderConnection then forceRenderConnection:Disconnect() forceRenderConnection = nil end
				return
			end
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							pcall(function() part.LocalTransparencyModifier = 0 end)
						end
					end
				end
			end
		end)
	end

	function Misc.RestoreForceRender()
		if forceRenderConnection then forceRenderConnection:Disconnect() forceRenderConnection = nil end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						pcall(function() part.LocalTransparencyModifier = 1 end)
					end
				end
			end
		end
	end

	local function startFreeCam()
		if freeCamActive then return end
		freeCamActive = true
		local cam = Camera
		if not cam then return end
		freeCamCFrame = cam.CFrame
		cam.CameraType = Enum.CameraType.Scriptable

		local inputBeganConn = UIS.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == Enum.KeyCode.W then freeCamInputState.Forward = true
			elseif input.KeyCode == Enum.KeyCode.S then freeCamInputState.Backward = true
			elseif input.KeyCode == Enum.KeyCode.A then freeCamInputState.Left = true
			elseif input.KeyCode == Enum.KeyCode.D then freeCamInputState.Right = true
			elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then freeCamInputState.Up = true
			elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftShift then freeCamInputState.Down = true
			end
		end)

		local inputEndedConn = UIS.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.W then freeCamInputState.Forward = false
			elseif input.KeyCode == Enum.KeyCode.S then freeCamInputState.Backward = false
			elseif input.KeyCode == Enum.KeyCode.A then freeCamInputState.Left = false
			elseif input.KeyCode == Enum.KeyCode.D then freeCamInputState.Right = false
			elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then freeCamInputState.Up = false
			elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.LeftShift then freeCamInputState.Down = false
			end
		end)

		local renderConn = RunService.RenderStepped:Connect(function(dt)
			if not S.FreeCam or not freeCamCFrame then
				Misc.RestoreFreeCam()
				return
			end
			local speed = S.FreeCamSpeed or 9
			local moveDir = Vector3.new()
			if freeCamInputState.Forward then moveDir = moveDir + freeCamCFrame.LookVector end
			if freeCamInputState.Backward then moveDir = moveDir - freeCamCFrame.LookVector end
			if freeCamInputState.Left then moveDir = moveDir - freeCamCFrame.RightVector end
			if freeCamInputState.Right then moveDir = moveDir + freeCamCFrame.RightVector end
			if freeCamInputState.Up then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if freeCamInputState.Down then moveDir = moveDir - Vector3.new(0, 1, 0) end

			if moveDir.Magnitude > 0 then
				freeCamCFrame = freeCamCFrame + moveDir.Unit * speed * (dt or 0.016) * 60
				cam.CFrame = freeCamCFrame
			end

			local mouseDelta = UIS:GetMouseDelta()
			if mouseDelta.Magnitude > 0 then
				local yaw = -mouseDelta.X * 0.1
				local pitch = -mouseDelta.Y * 0.1
				freeCamCFrame = freeCamCFrame * CFrame.Angles(math.rad(pitch), math.rad(yaw), 0)
				cam.CFrame = freeCamCFrame
			end
		end)

		table.insert(Runtime.Cleanup, function()
			if inputBeganConn then inputBeganConn:Disconnect() end
			if inputEndedConn then inputEndedConn:Disconnect() end
			if renderConn then renderConn:Disconnect() end
		end)
	end

	function Misc.RestoreFreeCam()
		freeCamActive = false
		freeCamCFrame = nil
		freeCamInputState = {
			Forward = false, Backward = false, Left = false, Right = false,
			Up = false, Down = false,
		}
		local cam = Camera
		if cam then
			cam.CameraType = Enum.CameraType.Custom
		end
	end

	local function startTrashTalk()
		if trashTalkConnection then return end
		trashTalkConnection = RunService.Heartbeat:Connect(function()
			if not S.TrashTalk or Runtime.Unloaded then
				if trashTalkConnection then trashTalkConnection:Disconnect() trashTalkConnection = nil end
				return
			end
		end)
	end

	function Misc.RestoreTrashTalk()
		if trashTalkConnection then trashTalkConnection:Disconnect() trashTalkConnection = nil end
	end

	function Misc.TeleportAllTraders()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if root and localRoot then
					pcall(function()
						root.CFrame = localRoot.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
					end)
				end
			end
		end
	end

	local function isUnderwater()
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not root then return false end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {LocalPlayer.Character}
		local result = Workspace:Raycast(root.Position + Vector3.new(0, 2, 0), Vector3.new(0, -200, 0), params)
		return result and result.Material == Enum.Material.Water
	end

	function Misc.Update(dt)
		if S.FullBright or S.NoFog or S.NoShadows or S.HideGrass or S.LowPC or S.AmbienceEnabled or S.CustomSky then
			captureLighting()

			if S.FullBright then
				Lighting.Brightness = 2
				Lighting.ClockTime = 14
				Lighting.TimeOfDay = "14:00:00"
				Lighting.Ambient = Color3.fromRGB(200, 200, 200)
				Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
				Lighting.ExposureCompensation = 0
				Lighting.FogEnd = 1000000
				Lighting.GlobalShadows = false
			else
				restoreLighting()
			end

			if S.NoFog then
				Lighting.FogStart = 100000
				Lighting.FogEnd = 1000000
			end

			if S.NoShadows then
				Lighting.GlobalShadows = false
			end

			if S.AmbienceEnabled then
				Lighting.Brightness = (S.AmbienceBrightness or 12) / 100
				Lighting.Ambient = S.AmbienceColor or Color3.fromRGB(80, 255, 140)
			end

			if S.CustomSky then
				applyCustomSky()
			end
		else
			if lightingCaptured then restoreLighting() end
		end

		if S.FOVChanger then
			local cam = Camera
			if cam then
				local targetFOV = S.FOVAmount or 100
				cam.FieldOfView = targetFOV
			end
		elseif savedCameraFOV then
			local cam = Camera
			if cam then
				cam.FieldOfView = savedCameraFOV
			end
			savedCameraFOV = nil
		end

		if S.ZoomEnabled then
			local cam = Camera
			if cam then
				local targetFOV = 90 - (S.ZoomAmount or 30)
				cam.FieldOfView = math.max(cam.FieldOfView - 1, targetFOV)
			end
		end

		if S.ThirdPerson then
			startThirdPerson()
		else
			Misc.RestoreThirdPerson()
		end

		if S.ForceRender then
			startForceRender()
		else
			Misc.RestoreForceRender()
		end

		if S.FreeCam and not freeCamActive then
			startFreeCam()
		elseif not S.FreeCam and freeCamActive then
			Misc.RestoreFreeCam()
		end

		if S.TrashTalk then
			startTrashTalk()
		else
			Misc.RestoreTrashTalk()
		end

		if S.HideGrass then
			local terrain = Workspace:FindFirstChild("Terrain")
			if terrain then
				terrain.Decoration = false
			end
		end

		if S.LowPC then
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 1000000
		end
	end

	function Misc.Restore()
		if lightingCaptured then restoreLighting() end
		Misc.RestoreThirdPerson()
		Misc.RestoreForceRender()
		Misc.RestoreFreeCam()
		Misc.RestoreTrashTalk()

		if savedCameraFOV then
			local cam = Camera
			if cam then cam.FieldOfView = savedCameraFOV end
			savedCameraFOV = nil
		end

		local terrain = Workspace:FindFirstChild("Terrain")
		if terrain then
			terrain.Decoration = true
		end
	end

	onCleanup(function()
		Misc.Restore()
	end)
end


do
	local Environment = {Captured = false, NextApply = 0}
	Runtime.Environment = Environment

	function Environment.Apply()
		if Runtime.Misc and Runtime.Misc.Update then
			Runtime.Misc.Update(0)
		end
	end

	function Environment.Restore()
		if Runtime.Misc and Runtime.Misc.Restore then
			Runtime.Misc.Restore()
		end
	end

	function Environment.Update()
		if (S.FullBright or S.NoFog or S.NoShadows or S.HideGrass or S.LowPC or S.AmbienceEnabled) and os.clock() >= Environment.NextApply then
			Environment.Apply()
			Environment.NextApply = os.clock() + 0.5
		end
	end

	onCleanup(Environment.Restore)
end


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
local SOURCE_WINDOW_WIDTH, SOURCE_WINDOW_HEIGHT = 480, 420
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
title.Size = UDim2.new(1, -40, 0, 15)
title.Font = Enum.Font.Gotham
title.Text = "BurmaldaPD"
title.TextSize = 14
title.TextColor3 = Theme.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center

local closeButton = Instance.new("TextButton", header)
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -4, 0, 8)
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeButton.BackgroundTransparency = 0.2
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = true
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.MouseButton1Click:Connect(function()
	Runtime.MenuOpen = not Runtime.MenuOpen
	main.Visible = Runtime.MenuOpen
end)

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
			if picking or input == ignoreInput then return end
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

	Runtime.FeatureHandlers.PlayerESP = function(value)
		if not value and not S.ESPChams then Runtime.Visuals.Clear() end
	end
	Runtime.FeatureHandlers.ESPChams = function(value)
		if not value then
			for _, entry in pairs(Runtime.Visuals.Rigs) do
				if entry.Highlight then entry.Highlight.Enabled = false end
			end
		end
	end
	Runtime.FeatureHandlers.ForceRender = function(value)
		if value and Runtime.Visuals and Runtime.Visuals.ForceRenderAll then Runtime.Visuals.ForceRenderAll() end
	end
	Runtime.FeatureHandlers.UIAnimations = function(value) UIAnimations = value end
	for _, key in ipairs({"FullBright", "NoFog", "NoShadows", "HideGrass", "LowPC"}) do
		Runtime.FeatureHandlers[key] = function() if Runtime.Environment and Runtime.Environment.Apply then Runtime.Environment.Apply() end end
	end
	Runtime.FeatureHandlers.SilentAim = function(value)
		if value and Runtime.Aim and Runtime.Aim.InstallRaycast then
			if not Runtime.Aim.InstallRaycast() then
				S.SilentAim = false
				if _fFS["Silent Aim"] then _fFS["Silent Aim"](false) end
			end
		elseif not value and Runtime.Aim and Runtime.Aim.RestoreRaycast then
			Runtime.Aim.RestoreRaycast()
		end
	end
	Runtime.FeatureHandlers.Aimbot = function(value)
		if value and Runtime.Aim and Runtime.Aim.EnableAimbot then Runtime.Aim.EnableAimbot() end
	end
	Runtime.FeatureHandlers.TriggerBot = function(value)
		if value and Runtime.Aim and Runtime.Aim.EnableTrigger then Runtime.Aim.EnableTrigger() end
	end
	Runtime.FeatureHandlers.Fly = function(value)
		if not value and Runtime.Movement and Runtime.Movement.RestoreFly then Runtime.Movement.RestoreFly() end
	end
	Runtime.FeatureHandlers.Noclip = function(value)
		if not value and Runtime.Movement and Runtime.Movement.RestoreNoclip then Runtime.Movement.RestoreNoclip() end
	end
	Runtime.FeatureHandlers.FakeLag = function(value)
		if not value and Runtime.Movement and Runtime.Movement.RestoreFakeLag then Runtime.Movement.RestoreFakeLag() end
	end

	do
		local lc, rc = getTab("COMBAT")

		local editor = feature(section(lc, "Silent Aim"), "Silent Aim", "SilentAim")
		slider(editor, "FOV", 0, 100, "SilentFOV")
		slider(editor, "Hit Chance", 1, 100, "SilentHitChance")
		dropdown(editor, "Target Parts", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "SilentPart")
		dropdown(editor, "Priority", {"Distance", "FOV", "Health"}, "SilentPriority")
		onOff(editor, "Sticky Target", "SilentSticky")
		onOff(editor, "Randomize Hit Part", "SilentRandomPart")
		onOff(editor, "Auto Shoot", "SilentAutoShoot")
		addBind(editor, "Auto Shoot Key", "T", function() end)
		onOff(editor, "Magic Bullet", "SilentMagicBullet")
		onOff(editor, "Instant Hit", "SilentInstantHit")
		addBind(editor, "Instant Hit Key", "None", function() end)
		onOff(editor, "Wallbang", "SilentWallbang")
		addBind(editor, "Wallbang Key", "None", function() end)
		onOff(editor, "Pitch Resolver", "SilentPitchResolver")
		onOff(editor, "Hold to Aim", "SilentHoldMode")
		addBind(editor, "Hold Key", "None", function() end)
		onOff(editor, "Keybind Only", "SilentKeybindOnly")
		onOff(editor, "Wall Check", "SilentWallCheck")
		onOff(editor, "Target NPC", "SilentTargetNPC")
		onOff(editor, "Target Heli/BTR", "SilentTargetHeli")
		onOff(editor, "Tracer", "SilentTracer")
		slider(editor, "Tracer Thickness", 5, 100, "SilentTracerThickness")
		slider(editor, "Tracer Lifetime", 10, 200, "SilentTracerLifetime")
		slider(editor, "Texture Scroll Speed", 0, 80, "SilentTracerTextureSpeed")
		onOff(editor, "Curve Tracer", "SilentCurve")
		slider(editor, "Curve Amount", 1, 40, "SilentCurveAmount")
		slider(editor, "Curve Segments", 4, 32, "SilentCurveSegments")
		onOff(editor, "Randomize Curve", "SilentCurveRandom")
		toggleBind(editor, "Silent Aim", "SilentAim")

		editor = feature(section(rc, "FOV"), "Show FOV Circle", "SilentFOVCircle")
		slider(editor, "FOV Radius", 10, 720, "SilentFOV")
		slider(editor, "Circle Thickness", 1, 8, "SilentFOVThickness")
		color(editor, "FOV Color", "SilentFOVColor")

		editor = feature(section(rc, "Targets"), "Max Distance", "SilentRange")
		slider(editor, "Max Distance (m)", 25, 2000, "SilentRange")

		editor = feature(section(lc, "Aimbot"), "Enable Aimbot", "Aimbot")
		slider(editor, "Smoothness", 1, 100, "AimbotSmooth")
		slider(editor, "FOV Radius", 1, 720, "AimbotFOV")
		dropdown(editor, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "AimbotPart")
		addBind(editor, "Aim Key", "MouseButton2", function() end)

		editor = feature(section(rc, "Aimbot Options"), "Prediction", "AimbotPrediction")
		onOff(editor, "Wall Check", "AimbotWallCheck")
		onOff(editor, "Team Check", "AimbotTeamCheck")
		onOff(editor, "Nearest Part To Cursor", "AimbotNearestCursor")

		editor = feature(section(lc, "Trigger Bot"), "Enable Trigger Bot", "TriggerBot")
		slider(editor, "Trigger Delay (ms)", 0, 500, "TriggerDelay")
		addBind(editor, "Trigger Key", "MouseButton1", function() end)

		editor = feature(section(rc, "Gun Mods"), "No Spread", "NoSpread")
		onOff(editor, "No Recoil", "NoRecoil")
		onOff(editor, "Instant ADS", "InstantADS")
		onOff(editor, "Multibullet", "MultiBullet")
		onOff(editor, "Double Tap", "DoubleTap")
		onOff(editor, "Remove Sandboxing", "RemoveSandboxing")
		onOff(editor, "Remove Rechamber Delay", "RemoveRechamber")
		onOff(editor, "Melee Reach", "MeleeReach")
		slider(editor, "Melee Reach Amount", 1, 10, "MeleeReachAmount")
		onOff(editor, "Instant Lean", "InstantLean")
		onOff(editor, "No Bob", "NoBob")
		onOff(editor, "Instant Bullet", "InstantBullet")
		onOff(editor, "Range Multiplier", "RangeMult")
		slider(editor, "Range Amount", 1, 20, "RangeAmount")
		onOff(editor, "RPM", "RPMEnabled")
		slider(editor, "RPM Multiplier", 1, 15, "RPMMultiplier")

		editor = feature(section(rc, "Hitsound & Tracers"), "Hitsound", "HitsoundEnabled")
		onOff(editor, "Hitsound", "HitsoundEnabled")
		dropdown(editor, "Hitsound Select", {"Minecraft", "Telegram", "Rust Headshot", "CSGO Kill", "Minecraft Bow", "CSGO Headshot", "Minecraft XP", "Minecraft Drop", "Fortnite Headshot", "Gamesense", "Primordial"}, "HitsoundSound")
		slider(editor, "Hitsound Volume", 0, 1000, "HitsoundVolume")
		onOff(editor, "Hit Notifications", "HitNotify")
		onOff(editor, "Headshot Sound Override", "HeadshotSound")
		onOff(editor, "Body Sound Override", "BodySound")
		onOff(editor, "Shoot Sound", "ShootSoundEnabled")
		slider(editor, "Shoot Volume", 0, 1000, "ShootSoundVolume")
		onOff(editor, "Tracer", "TracerEnabled")
		dropdown(editor, "Tracer Style", {"Default", "Obelus", "Lightning", "DNA", "Minecraft", "Beam", "Galaxy"}, "TracerStyle")
		color(editor, "Tracer Color", "TracerColor")
		slider(editor, "Tracer Duration", 0, 15, "TracerDuration")
		slider(editor, "Tracer Thickness", 0, 100, "TracerThickness")

		editor = feature(section(rc, "Hit Effects"), "Hit Chams", "HitChams")
		color(editor, "Hit Chams Color", "HitChamsColor")
		slider(editor, "Hit Chams Lifetime", 1, 30, "HitChamsTime")
		onOff(editor, "Target Chams", "TargetChams")
		color(editor, "Target Chams Color", "TargetChamsColor")
	end

	do
		local lc, rc = getTab("VISUALS")

		local editor = feature(section(lc, "Players"), "Player ESP", "PlayerESP")
		onOff(editor, "Box", "ESPBox")
		dropdown(editor, "Box Type", {"Corner", "2D", "3D"}, "ESPBoxType")
		color(editor, "Box Color", "ESPBoxColor")
		onOff(editor, "Skeleton", "ESPSkeleton")
		color(editor, "Skeleton Color", "ESPSkeletonColor")
		onOff(editor, "Health Bar", "ESPHealthBar")
		onOff(editor, "Name", "ESPName")
		onOff(editor, "Distance", "ESPDistance")
		onOff(editor, "Weapon", "ESPWeapon")
		onOff(editor, "Invisible Players", "ESPInvisible")
		color(editor, "Invisible Color", "ESPInvisibleColor")
		onOff(editor, "Chams", "ESPChams")
		color(editor, "Chams Color", "ESPChamsColor")
		onOff(editor, "Body Chams", "ESPBodyChams")
		color(editor, "Body Chams Color", "ESPBodyChamsColor")
		slider(editor, "Max Distance", 50, 2000, "ESPMaxDist")
		onOff(editor, "Team Check", "ESPTeamCheck")
		toggleBind(editor, "Player ESP", "PlayerESP")

		editor = feature(section(lc, "AI / NPC"), "AI ESP", "AIESP")
		onOff(editor, "Box", "AIBox")
		color(editor, "Box Color", "AIBoxColor")
		onOff(editor, "Name", "AIName")
		onOff(editor, "Distance", "AIDistance")
		onOff(editor, "Chams", "AIChams")
		color(editor, "Chams Color", "AIChamsColor")
		slider(editor, "Range", 50, 1000, "AIRange")

		editor = feature(section(rc, "Object ESP"), "Dropped Items", "DroppedESP")
		color(editor, "Dropped Color", "DroppedColor")
		onOff(editor, "Containers", "ContainerESP")
		color(editor, "Container Color", "ContainerColor")
		onOff(editor, "Vehicles", "VehicleESP")
		color(editor, "Vehicle Color", "VehicleColor")
		onOff(editor, "Quest Items", "QuestESP")
		color(editor, "Quest Color", "QuestColor")
		onOff(editor, "Airdrop Notifications", "AirdropNotify")
		slider(editor, "Max Distance", 50, 2000, "ObjectESPMaxDist")

		editor = feature(section(rc, "Grenades"), "Grenade ESP", "GrenadeESP")
		onOff(editor, "Auto Throw", "GrenadeAutoThrow")

		editor = feature(section(rc, "Snaplines"), "Snaplines", "Snaplines")
		color(editor, "Snapline Color", "SnaplineColor")
		slider(editor, "Max Distance", 25, 1000, "SnapMaxDist")

		editor = feature(section(rc, "Radar"), "Radar", "Radar")
		color(editor, "Player Color", "RadarColor")

		editor = feature(section(rc, "ViewModel"), "Gun Chams", "GunChams")
		color(editor, "Gun Color", "GunChamsColor")
		onOff(editor, "Arm Chams", "ArmChams")
		color(editor, "Arm Color", "ArmChamsColor")
	end

	do
		local lc, rc = getTab("MOVEMENT")

		editor = feature(section(lc, "Speed"), "Speed", "Speed")
		slider(editor, "Speed Value", 16, 200, "SpeedValue")
		toggleBind(editor, "Speed", "Speed")

		editor = feature(section(lc, "Fly"), "Fly", "Fly")
		slider(editor, "Fly Speed", 1, 50, "FlySpeed")
		slider(editor, "Vertical Speed", 1, 50, "FlyVSpeed")
		addBind(editor, "Fly Key", "F", function() end)
		toggleBind(editor, "Fly", "Fly")

		editor = feature(section(rc, "Noclip"), "Noclip", "Noclip")
		slider(editor, "Noclip Speed", 1, 8, "NoclipSpeed")
		slider(editor, "Max Layers", 1, 4, "NoclipLayers")
		addBind(editor, "Noclip Key", "None", function() end)
		toggleBind(editor, "Noclip", "Noclip")

		editor = feature(section(lc, "Jump"), "Bunny Hop", "BunnyHop")
		addBind(editor, "Bhop Key", "None", function() end)
		toggleBind(editor, "Bunny Hop", "BunnyHop")

		editor = feature(section(lc, "Long Jump"), "Long Jump", "LongJump")
		slider(editor, "Long Jump Power", 10, 100, "LongJumpPower")
		addBind(editor, "Long Jump Key", "None", function() end)
		toggleBind(editor, "Long Jump", "LongJump")

		editor = feature(section(rc, "Spiderman"), "Spiderman", "Spiderman")
		slider(editor, "Climb Speed", 10, 30, "SpidermanSpeed")
		addBind(editor, "Spiderman Key", "None", function() end)
		toggleBind(editor, "Spiderman", "Spiderman")

		editor = feature(section(rc, "Teleport Down"), "Teleport Down", "TeleportDown")
		addBind(editor, "TP Down Key", "None", function() end)

		editor = feature(section(rc, "Car Speed"), "Car Speedhack", "CarSpeed")
		slider(editor, "Car Speed Amount", 1, 10, "CarSpeedAmount")

		editor = feature(section(rc, "Fake Lag"), "Fake Lag", "FakeLag")
		slider(editor, "Fake Lag Amount", 1, 20, "FakeLagAmount")
		addBind(editor, "Fake Lag Key", "None", function() end)
		toggleBind(editor, "Fake Lag", "FakeLag")

		editor = feature(section(rc, "Anti Aim"), "Floor Clip", "FloorClip")
		slider(editor, "Floor Clip Offset", 1, 20, "FloorClipOffset")
		addBind(editor, "Floor Clip Key", "None", function() end)
		toggleBind(editor, "Floor Clip", "FloorClip")

		editor = feature(section(rc, "Animation Spoofer"), "Animation Spoofer", "AnimSpoof")
		slider(editor, "Playback Speed", 0, 2, "AnimSpoofSpeed")
		addBind(editor, "Anim Spoof Key", "None", function() end)
		toggleBind(editor, "Animation Spoofer", "AnimSpoof")

		editor = feature(section(rc, "Spinbot"), "Spinbot", "Spinbot")
		slider(editor, "Spin Speed", 1, 30, "SpinbotSpeed")
		addBind(editor, "Spin Key", "None", function() end)
		toggleBind(editor, "Spinbot", "Spinbot")

		editor = feature(section(rc, "Underworld Walk"), "Underworld Walk", "Underworld")
		addBind(editor, "Underworld Key", "None", function() end)
		toggleBind(editor, "Underworld Walk", "Underworld")

		editor = feature(section(rc, "Peek Blink"), "Peek Blink", "PeekBlink")
		addBind(editor, "Peek Blink Key", "None", function() end)

		editor = feature(section(rc, "TP Kill"), "TP Kill", "TPKill")
		addBind(editor, "TP Kill Key", "None", function() end)

		editor = feature(section(rc, "Sky Peek"), "Sky Peek", "SkyPeek")
		addBind(editor, "Sky Peek Key", "None", function() end)
	end

	do
		local lc, rc = getTab("MISC")

		editor = feature(section(lc, "Lighting"), "FullBright", "FullBright")
		onOff(editor, "No Shadows", "NoShadows")
		onOff(editor, "No Fog", "NoFog")
		onOff(editor, "Custom Skybox", "CustomSky")

		editor = feature(section(lc, "Ambience"), "Ambience", "AmbienceEnabled")
		slider(editor, "Brightness", 0, 100, "AmbienceBrightness")
		slider(editor, "Indoor Brightness", 0, 100, "AmbienceIndoor")
		color(editor, "Color", "AmbienceColor")

		editor = feature(section(lc, "Third Person"), "Third Person", "ThirdPerson")
		slider(editor, "Distance", 1, 50, "ThirdPersonDist")
		slider(editor, "Fade Speed", 2, 30, "ThirdPersonFadeSpeed")
		addBind(editor, "Third Person Key", "None", function() end)
		toggleBind(editor, "Third Person", "ThirdPerson")

		editor = feature(section(rc, "Force Render"), "Force Render", "ForceRender")
		toggleBind(editor, "Force Render", "ForceRender")

		editor = feature(section(rc, "FreeCam"), "FreeCam", "FreeCam")
		slider(editor, "Speed", 0, 100, "FreeCamSpeed")
		addBind(editor, "Toggle Key", "U", function() end)
		toggleBind(editor, "FreeCam", "FreeCam")

		editor = feature(section(rc, "FOV Changer"), "FOV Changer", "FOVChanger")
		slider(editor, "FOV Amount", 70, 120, "FOVAmount")
		onOff(editor, "Zoom", "ZoomEnabled")
		addBind(editor, "Zoom Key", "Z", function() end)
		slider(editor, "Zoom Amount", 1, 80, "ZoomAmount")
		slider(editor, "Animation Speed", 1, 30, "ZoomAnimSpeed")

		editor = feature(section(rc, "Crosshair"), "Crosshair", "CrosshairEnabled")
		dropdown(editor, "Preset", {"Custom", "Dot", "Cross", "Star of David", "Hexagram", "Circle"}, "CrosshairPreset")
		color(editor, "Color", "CrosshairColor")
		slider(editor, "Sides", 2, 8, "CrosshairSides")
		slider(editor, "Length", 1, 30, "CrosshairLength")
		slider(editor, "Width", 1, 6, "CrosshairWidth")
		slider(editor, "Gap", 0, 20, "CrosshairGap")
		slider(editor, "Transparency", 0, 100, "CrosshairTransparency")
		onOff(editor, "Outline", "CrosshairOutline")
		color(editor, "Outline Color", "CrosshairOutlineColor")
		onOff(editor, "Spin", "CrosshairSpin")
		slider(editor, "Spin Speed", 0, 10, "CrosshairSpinSpeed")
		color(editor, "Target Color", "CrosshairTargetColor")

		editor = feature(section(rc, "Target Panel"), "Target Stats", "TargetPanel")
		slider(editor, "Stats FOV (px)", 50, 1000, "TargetPanelFOV")
		slider(editor, "Crosshair Drop", -400, 400, "TargetPanelCrossDrop")
		onOff(editor, "Crosshair Labels", "TargetPanelLabels")
		onOff(editor, "Animate Healthbar", "TargetPanelHPAnim")
		onOff(editor, "Status Bar", "TargetPanelStatus")
		onOff(editor, "Target Status (Vis/Manip/Hidden)", "TargetPanelVis")

		editor = feature(section(rc, "Terrain"), "Hide Grass", "HideGrass")
		toggleBind(editor, "Hide Grass", "HideGrass")

		editor = feature(section(rc, "Performance"), "Low PC", "LowPC")
		toggleBind(editor, "Low PC", "LowPC")

		editor = feature(section(rc, "Hide UI"), "Hide UI", "HideUI")

		editor = feature(section(rc, "Mod Detector"), "Mod Detector", "ModDetector")

		editor = feature(section(rc, "Stats HUD"), "Stats HUD", "StatsHUD")
	end

	do
		local lc, rc = getTab("CONFIG")

		local interfaceSection = section(lc, "Interface")
		for index, value in pairs(Colors) do
			if type(value) == "table" and value.R then
				color(interfaceSection, tostring(index), index)
			end
		end
		feature(interfaceSection, "UI Animations", "UIAnimations")

		local configsSection = section(lc, "Configs")
		local inputFrame = Instance.new("Frame", configsSection)
		inputFrame.Size = UDim2.new(1, 0, 0, 45)
		inputFrame.BackgroundColor3 = Theme.Element
		inputFrame.BorderSizePixel = 0
		local inputLabel = sourceText(inputFrame, "Config Name", UDim2.new(1, -16, 0, 15), Theme.SubText)
		inputLabel.Position = UDim2.new(0, 8, 0, 4)
		local textbox = Instance.new("TextBox", inputFrame)
		textbox.Position = UDim2.new(0, 8, 0, 25)
		textbox.Size = UDim2.new(1, -16, 0, 20)
		textbox.BackgroundColor3 = Theme.Background
		textbox.BorderSizePixel = 0
		textbox.PlaceholderText = "enter config name..."
		textbox.PlaceholderColor3 = Theme.SubText
		textbox.Text = ""
		textbox.TextColor3 = Theme.Text
		textbox.Font = Enum.Font.Gotham
		textbox.TextSize = 12
		textbox.ClearTextOnFocus = false

		local saveBtn = Instance.new("TextButton", configsSection)
		saveBtn.Size = UDim2.new(0.5, -2, 0, 22)
		saveBtn.BackgroundColor3 = Theme.Element
		saveBtn.BorderSizePixel = 0
		saveBtn.Text = "Save"
		saveBtn.TextColor3 = Color3.new(1, 1, 1)
		saveBtn.Font = Enum.Font.GothamMedium
		saveBtn.TextSize = 12
		saveBtn.AutoButtonColor = false
		saveBtn.MouseButton1Click:Connect(function()
			local name = textbox.Text
			if name == "" then return end
			Runtime.Config.Save(name)
		end)

		local loadBtn = Instance.new("TextButton", configsSection)
		loadBtn.Size = UDim2.new(0.5, -2, 0, 22)
		loadBtn.Position = UDim2.new(0.5, 2, 0, 0)
		loadBtn.BackgroundColor3 = Theme.Element
		loadBtn.BorderSizePixel = 0
		loadBtn.Text = "Load"
		loadBtn.TextColor3 = Color3.new(1, 1, 1)
		loadBtn.Font = Enum.Font.GothamMedium
		loadBtn.TextSize = 12
		loadBtn.AutoButtonColor = false
		loadBtn.MouseButton1Click:Connect(function()
			local name = textbox.Text
			if name == "" then return end
			Runtime.Config.Load(name)
		end)

		local savedSection = section(rc, "Saved Configs")
		local function refreshSaved()
			for _, child in ipairs(savedSection:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			for _, name in ipairs(Runtime.Config.List()) do
				local button = Instance.new("TextButton", savedSection)
				button.Size = UDim2.new(1, 0, 0, 24)
				button.BackgroundColor3 = Theme.Element
				button.BorderSizePixel = 0
				button.Text = name
				button.TextColor3 = Theme.Text
				button.Font = Enum.Font.GothamMedium
				button.TextSize = 12
				button.AutoButtonColor = false
				button.MouseButton1Click:Connect(function()
					Runtime.Config.Load(name)
				end)
				local deleteBtn = Instance.new("TextButton", button)
				deleteBtn.Size = UDim2.new(0, 50, 1, 0)
				deleteBtn.Position = UDim2.new(1, -50, 0, 0)
				deleteBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
				deleteBtn.BorderSizePixel = 0
				deleteBtn.Text = "X"
				deleteBtn.TextColor3 = Color3.new(1, 1, 1)
				deleteBtn.Font = Enum.Font.GothamBold
				deleteBtn.TextSize = 12
				deleteBtn.AutoButtonColor = false
				deleteBtn.MouseButton1Click:Connect(function()
					Runtime.Config.Delete(name)
					refreshSaved()
				end)
			end
		end
		refreshSaved()
		Runtime.SettingHandlers.ConfigRefresh = refreshSaved

		local unloadBtn = Instance.new("TextButton", savedSection)
		unloadBtn.Size = UDim2.new(1, 0, 0, 28)
		unloadBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
		unloadBtn.BorderSizePixel = 0
		unloadBtn.Text = "UNLOAD"
		unloadBtn.TextColor3 = Color3.new(1, 1, 1)
		unloadBtn.Font = Enum.Font.GothamBold
		unloadBtn.TextSize = 12
		unloadBtn.AutoButtonColor = false
		unloadBtn.MouseButton1Click:Connect(function()
			task.defer(Runtime.UnloadAll)
		end)
	end

	Runtime.DefaultState = {}
	for key, value in pairs(S) do Runtime.DefaultState[key] = value end
end
