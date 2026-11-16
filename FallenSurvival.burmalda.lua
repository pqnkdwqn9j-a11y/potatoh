local _fsEnv = getgenv and getgenv() or _G
if _fsEnv.BurmaldaFS and _fsEnv.BurmaldaFS.UnloadAll then
	pcall(_fsEnv.BurmaldaFS.UnloadAll)
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

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
	SilentManipulation = false,
	SilentManipDistance = 10,
	SilentManipIndicator = true,
	SilentManipIndicatorColor = Color3.fromRGB(255, 0, 0),
	SilentManipTargetColor = Color3.fromRGB(255, 0, 0),
	SilentAutoshoot = false,
	SilentVisibleCheck = false,
	SilentDownCheck = true,
	SilentTargetTeammates = false,
	SilentFOVCircle = false,
	SilentFOVCircleSize = 20,
	SilentFOVThickness = 2,
	SilentFOVFill = false,
	SilentFOVFillTransparency = 0.8,
	SilentFOVColor = Color3.fromRGB(50, 220, 110),
	SilentFOVColor2 = Color3.fromRGB(255, 255, 255),
	SilentFOVRainbow = false,
	SilentFOVRainbowSpeed = 1,
	SilentFOVGradientRotation = 0,
	SilentFOVRotate = false,
	SilentFOVRotateSpeed = 1.2,

	NoRecoil = false,
	NoSway = false,
	RPMEnabled = false,
	RPMMultiplier = 1,
	NoBob = false,
	InstantBullet = false,
	RangeMult = false,
	RangeAmount = 5,

	HitsoundEnabled = false,
	HitsoundSound = "Minecraft",
	HitsoundVolume = 1.0,
	HitNotify = true,
	ShootSoundEnabled = false,
	ShootSoundVolume = 1.0,
	TracerEnabled = false,
	TracerStyle = "Default",
	TracerColor = Color3.fromRGB(100, 255, 150),
	TracerDuration = 1,
	TracerThickness = 0.15,

	InstantEoka = false,
	InstantEquip = false,
	MeleeSpeedEnabled = false,
	MeleeSpeedAmount = 1.3,
	MeleeRangeEnabled = false,
	MeleeRangeAmount = 2.0,
	NoFallDamage = false,
	InstantLoot = false,
	ReloadBar = false,
	PerfectFarm = false,

	Speed = false,
	SpeedValue = 50,
	Fly = false,
	FlySpeed = 50,
	FlyHeight = 0,
	RocketNoclip = false,

	PlayerESP = false,
	ESPBox = true,
	ESPBoxType = "Corner",
	ESPBoxColor = Color3.fromRGB(50, 220, 110),
	ESPHealthBar = false,
	ESPName = false,
	ESPDistance = false,
	ESPWeapon = false,
	ESPChams = false,
	ESPChamsColor = Color3.fromRGB(50, 220, 110),
	ESPSkeleton = false,
	ESPSkeletonColor = Color3.fromRGB(255, 255, 255),
	ESPMaxDist = 500,
	ESPTeamCheck = false,

	BossESP = false,
	BossBox = false,
	BossBoxColor = Color3.fromRGB(255, 68, 68),
	BossHealthBar = false,
	BossName = false,
	BossDistance = false,

	AIESP = false,
	AIBox = false,
	AIBoxColor = Color3.fromRGB(255, 170, 0),
	AIName = false,
	AIDistance = false,
	AIFilter = "All",

	LootESP = false,
	DeployablesESP = false,
	VehiclesESP = false,
	ResourcesESP = false,
	AirdropsESP = false,
	MiscESPMaxDist = 500,

	FullBright = false,
	NoFog = false,
	NoShadows = false,

	AmbienceEnabled = false,
	AmbienceBrightness = 0.12,
	AmbienceIndoor = 0.04,
	AmbienceColor = Color3.fromRGB(80, 255, 140),
	ArmorViewer = false,
	ArmorShowLocal = false,
	ArmorMaxDist = 1500,
	FreecamEnabled = false,
	FreecamSpeed = 9,
	FOVChanger = false,
	FOVAmount = 100,
	ZoomEnabled = false,
	ZoomAmount = 30,
	ZoomAnimSpeed = 8,
	GunSkinEnabled = false,
	GunSkinPreset = "Aurora",
	GunSkinScrollSpeed = 0.1,
	GunChams = false,
	GunChamsColor = Color3.fromRGB(166, 147, 243),
	GunChamsMaterial = "ForceField",
	GunChamsTexture = "None",
	ArmsChams = false,
	ArmsChamsColor = Color3.fromRGB(255, 255, 255),
	ArmsChamsMaterial = "ForceField",
	ArmsChamsTexture = "None",
	ModDetector = false,
	ModNotify = true,
	CrosshairEnabled = false,
	CrosshairPreset = "Custom",
	CrosshairColor = Color3.fromRGB(255, 255, 255),
	CrosshairPosition = "Center",
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
	HideGrass = false,
	LowPC = false,
	UIAnimations = true,
}

local Colors = {
	Accent = Color3.fromRGB(50, 220, 110),
}

local Runtime = {
	State = S,
	Colors = Colors,
	Diagnostics = {Errors = {}, SilentRedirects = 0},
	Unloaded = false,
	MenuOpen = false,
	RaycastBypass = 0,
	Boxes = {},
	Tracers = {},
	HealthBars = {},
	NameTags = {},
	DistanceTags = {},
	WeaponTags = {},
	Visuals = {Rigs = {}, Clear = function() end},
	FeatureHandlers = {},
	SettingHandlers = {},
	ConfigControls = {},
	BindApis = {},
	_cleanup = {},
	Guis = {},
	LastFeatureName = nil,
	LastFeatureState = nil,
	TabNames = {"COMBAT", "VISUALS", "MOVEMENT", "MISC", "CONFIG"},
}

Runtime.Guis = {}
local _instanceNew = Instance.new
local function newScreenGui()
	local gui = _instanceNew("ScreenGui")
	Runtime.Guis[gui] = true
	return gui
end

local uiParent
if type(gethui) == "function" then pcall(function() uiParent = gethui() end) end
if not uiParent then uiParent = LocalPlayer:WaitForChild("PlayerGui") end
for _, name in ipairs({"BurmaldaHookFS", "BurmaldaHookFSStats"}) do
	local old = uiParent:FindFirstChild(name)
	if old then old:Destroy() end
end

local sg = newScreenGui()
sg.Name = "BurmaldaHookFS"
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
	onCleanup = function(fn) table.insert(Runtime._cleanup, fn) end,
}
setmetatable(env, {__index = function(_, key)
	if key == "Camera" then return Workspace.CurrentCamera end
	return _G[key]
end})
setfenv(0, env)

local function guardedStep(name, fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		table.insert(Runtime.Diagnostics.Errors, {name, err, os.clock()})
		Runtime.Diagnostics.LastError = string.format("[%s] %s", name, tostring(err))
	end
end

local renderConnection = RunService.RenderStepped:Connect(function(dt)
	if Runtime.Unloaded then return end
	guardedStep("Shared", Runtime.Shared and Runtime.Shared.ClearCache)
	guardedStep("Visuals", Runtime.Visuals and Runtime.Visuals.Update)
	guardedStep("Movement", Runtime.Movement and Runtime.Movement.Update, dt)
	guardedStep("Misc", Runtime.Misc and Runtime.Misc.Update, dt)
	guardedStep("Aim", Runtime.Aim and Runtime.Aim.Update, dt)
end)

function Runtime.UnloadAll()
	if Runtime.Unloaded then return end
	Runtime.Unloaded = true
	if renderConnection then renderConnection:Disconnect() end
	for _, fn in ipairs(Runtime._cleanup) do pcall(fn) end
	Runtime._cleanup = {}
	if Runtime.Environment and Runtime.Environment.Restore then pcall(Runtime.Environment.Restore) end
	if _fsEnv.BurmaldaFS == Runtime then _fsEnv.BurmaldaFS = nil end
	for gui in pairs(Runtime.Guis) do pcall(function() gui:Destroy() end) end
	Runtime.Guis = {}
end

Runtime.Environment = env
_fsEnv.BurmaldaFS = Runtime

local Config = {Folder = "BurmaldaFS", Session = {}}
Runtime.Config = Config
_fsEnv.BurmaldaFSConfigs = type(_fsEnv.BurmaldaFSConfigs) == "table" and _fsEnv.BurmaldaFSConfigs or {}
Config.Session = _fsEnv.BurmaldaFSConfigs

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

do
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	local Shared = {
		WallClearCache = {},
		CacheTTL = 0.1,
	}
	Runtime.Shared = Shared

	function Shared.Humanoid(character)
		if not character then return nil end
		return character:FindFirstChildOfClass("Humanoid")
	end

	function Shared.Root(character)
		if not character then return nil end
		return character:FindFirstChild("HumanoidRootPart")
	end

	function Shared.Project(position)
		local viewport, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(position)
		if not onScreen then return nil end
		return viewport.X, viewport.Y, viewport.Z
	end

	function Shared.IsTeammate(player)
		if not player or player.Neutral or LocalPlayer.Neutral then return false end
		return player.Team == LocalPlayer.Team
	end

	function Shared.KeyDown(keyCode)
		if type(keyCode) ~= "EnumItem" then return false end
		local service = game:GetService("UserInputService")
		return service:IsKeyDown(keyCode)
	end

	function Shared.WallClear(targetPosition, targetCharacter)
		if not targetPosition or not targetCharacter then return false end
		local origin = Workspace.CurrentCamera.CFrame.Position
		local direction = targetPosition - origin
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
		params.IgnoreWater = true
		local result = Workspace:Raycast(origin, direction, params)
		if result then
			local dist = (result.Position - origin).Magnitude
			local total = direction.Magnitude
			return dist >= total - 2
		end
		return true
	end

	function Shared.IsCharacterPart(part)
		if not part or not part.Parent then return false end
		local model = part.Parent
		if model and model:IsA("Model") then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			return humanoid ~= nil
		end
		return false
	end

	local lastFlush = 0
	function Shared.ClearCache(now)
		if not now then now = os.clock() end
		if now - lastFlush > Shared.CacheTTL then
			Shared.WallClearCache = {}
			lastFlush = now
		end
	end

	function Shared.WallClearCached(targetPosition, targetCharacter)
		Shared.ClearCache()
		if not targetPosition or not targetCharacter then return false end
		local key = string.format("%.2f,%.2f,%.2f", targetPosition.X, targetPosition.Y, targetPosition.Z)
		local cached = Shared.WallClearCache[key]
		if cached ~= nil then return cached end
		local result = Shared.WallClear(targetPosition, targetCharacter)
		Shared.WallClearCache[key] = result
		return result
	end

	function Shared.RestoreNamecall()
		if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
			pcall(hookmetamethod, workspace, "__namecall", function() end)
		end
	end

	function Shared.OnCleanup(fn)
		Runtime._cleanup = Runtime._cleanup or {}
		table.insert(Runtime._cleanup, fn)
	end

	function Shared.RunCleanup()
		if Runtime._cleanup then
			for _, fn in ipairs(Runtime._cleanup) do
				pcall(fn)
			end
			Runtime._cleanup = nil
		end
	end
end

do
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local PhysicsService = game:GetService("PhysicsService")
	local UIS = game:GetService("UserInputService")
	local LocalPlayer = Players.LocalPlayer

	local Movement = {
		SpeedEnabled = false,
		OriginalWalkSpeed = 16,
		FlyEnabled = false,
		FlyCFrame = nil,
		NoclipEnabled = false,
		NoclipPartsCache = {},
		NoclipLastChar = nil,
		Keys = {},
	}
	Runtime.Movement = Movement

	local noclipGroupReady = false
	local function ensureNoclipGroup()
		if noclipGroupReady then return true end
		local ok = pcall(function() PhysicsService:CreateCollisionGroup("BurmaldaNC") end)
		if ok or true then
			pcall(function() PhysicsService:CollisionGroupSetCollidable("BurmaldaNC", "Default", false) end)
			noclipGroupReady = true
			return true
		end
		return false
	end

	local function applyNoclipToCharacter(character)
		if not character then return end
		if Movement.NoclipLastChar == character then return end
		Movement.NoclipLastChar = character
		for _, obj in ipairs(Movement.NoclipPartsCache) do
			if typeof(obj) == "RBXScriptConnection" then pcall(function() obj:Disconnect() end) end
		end
		Movement.NoclipPartsCache = {}
		if not ensureNoclipGroup() then return end
		local flying = Movement.FlyEnabled
		for _, desc in ipairs(character:GetDescendants()) do
			if desc:IsA("BasePart") then
				if flying then
					pcall(function() PhysicsService:SetPartCollisionGroup(desc, "BurmaldaNC") end)
				else
					local name = desc.Name
					if name ~= "HumanoidRootPart" and name ~= "LeftHand" and name ~= "RightHand"
					   and name ~= "LeftFoot" and name ~= "RightFoot" then
						pcall(function() PhysicsService:SetPartCollisionGroup(desc, "BurmaldaNC") end)
					end
				end
			end
		end
		local conn = character.DescendantAdded:Connect(function(desc)
			if Movement.NoclipEnabled and desc:IsA("BasePart") then
				if Movement.FlyEnabled then
					pcall(function() PhysicsService:SetPartCollisionGroup(desc, "BurmaldaNC") end)
				else
					local name = desc.Name
					if name ~= "HumanoidRootPart" and name ~= "LeftHand" and name ~= "RightHand"
					   and name ~= "LeftFoot" and name ~= "RightFoot" then
						pcall(function() PhysicsService:SetPartCollisionGroup(desc, "BurmaldaNC") end)
					end
				end
			end
		end)
		table.insert(Movement.NoclipPartsCache, conn)
	end

	local function removeNoclipFromCharacter(character)
		if not character then return end
		for _, obj in ipairs(Movement.NoclipPartsCache) do
			if typeof(obj) == "Instance" and obj:IsA("BasePart") then
				pcall(function() PhysicsService:SetPartCollisionGroup(obj, "Default") end)
			elseif typeof(obj) == "RBXScriptConnection" then
				pcall(function() obj:Disconnect() end)
			end
		end
		Movement.NoclipPartsCache = {}
		Movement.NoclipLastChar = nil
	end

	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			Movement.Keys[input.KeyCode] = true
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			Movement.Keys[input.KeyCode] = nil
		end
	end)

	local function updateFly(dt)
		local character = LocalPlayer.Character
		if not character then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return end

		humanoid.AutoRotate = false
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero

		local camCF = Workspace.CurrentCamera.CFrame
		local moveDir = Vector3.zero
		if Movement.Keys[Enum.KeyCode.W] then moveDir = moveDir + camCF.LookVector end
		if Movement.Keys[Enum.KeyCode.S] then moveDir = moveDir - camCF.LookVector end
		if Movement.Keys[Enum.KeyCode.A] then moveDir = moveDir - camCF.RightVector end
		if Movement.Keys[Enum.KeyCode.D] then moveDir = moveDir + camCF.RightVector end
		if Movement.Keys[Enum.KeyCode.E] or Movement.Keys[Enum.KeyCode.Space] then
			moveDir = moveDir + Vector3.new(0, 1, 0)
		end
		if Movement.Keys[Enum.KeyCode.Q] or Movement.Keys[Enum.KeyCode.LeftControl] then
			moveDir = moveDir - Vector3.new(0, 1, 0)
		end

		local speed = S.FlySpeed or 50
		if moveDir.Magnitude > 0 then
			Movement.FlyCFrame = Movement.FlyCFrame + moveDir.Unit * speed * dt
		end
		root.CFrame = Movement.FlyCFrame
	end

	Runtime.FeatureHandlers.Fly = function(value)
		if value then
			local character = LocalPlayer.Character
			if not character then return end
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			Movement.FlyEnabled = true
			Movement.FlyCFrame = root.CFrame
			Movement.NoclipLastChar = nil
			if Movement.NoclipEnabled then applyNoclipToCharacter(character) end
		else
			Movement.FlyEnabled = false
			local character = LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid.AutoRotate = true end
				Movement.NoclipLastChar = nil
				if Movement.NoclipEnabled then applyNoclipToCharacter(character) end
			end
		end
	end

	Runtime.FeatureHandlers.Speed = function(value)
		local character = LocalPlayer.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		if value then
			Movement.SpeedEnabled = true
			Movement.OriginalWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = S.SpeedValue or 24
		else
			Movement.SpeedEnabled = false
			humanoid.WalkSpeed = Movement.OriginalWalkSpeed
		end
	end

	Runtime.FeatureHandlers.SpeedValue = function()
		if Movement.SpeedEnabled then
			local character = LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid.WalkSpeed = S.SpeedValue end
			end
		end
	end

	Runtime.FeatureHandlers.Noclip = function(value)
		if value then
			Movement.NoclipEnabled = true
			applyNoclipToCharacter(LocalPlayer.Character)
		else
			Movement.NoclipEnabled = false
			removeNoclipFromCharacter(LocalPlayer.Character)
		end
	end

	function Movement.Update(dt)
		if Movement.FlyEnabled then updateFly(dt) end
	end

	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart")
		task.wait(0.5)
		if Movement.NoclipEnabled then applyNoclipToCharacter(character) end
	end)

	function Movement.Restore()
		if Movement.FlyEnabled then
			local character = LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid.AutoRotate = true end
			end
			Movement.FlyEnabled = false
			Movement.FlyCFrame = nil
		end
		if Movement.SpeedEnabled then
			local character = LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid.WalkSpeed = Movement.OriginalWalkSpeed end
			end
			Movement.SpeedEnabled = false
		end
		if Movement.NoclipEnabled then
			removeNoclipFromCharacter(LocalPlayer.Character)
			Movement.NoclipEnabled = false
		end
	end
	Runtime._cleanup = Runtime._cleanup or {}
	table.insert(Runtime._cleanup, Movement.Restore)
end

do
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	local Visuals = {
		Tracers = {},
		ESPObjects = {},
	}
	Runtime.Visuals = Visuals

	local function getBoxColor(player)
		if S.TeamCheck and Runtime.Shared.IsTeammate(player) then return Colors.ESP_Team or Color3.new(0, 0, 1) end
		local humanoid = Runtime.Shared.Humanoid(player.Character)
		if humanoid and humanoid.Health <= 0 then return Colors.ESP_Dead or Color3.new(0.5, 0.5, 0.5) end
		return Colors.ESP_Enemy or Color3.new(1, 0, 0)
	end

	local function boxForPlayer(player)
		if not Runtime.Boxes[player] then
			Runtime.Boxes[player] = {
				TopLeft = newDrawing("Line"),
				TopRight = newDrawing("Line"),
				BottomLeft = newDrawing("Line"),
				BottomRight = newDrawing("Line"),
				Top = newDrawing("Line"),
				Bottom = newDrawing("Line"),
				Left = newDrawing("Line"),
				Right = newDrawing("Line"),
			}
		end
		return Runtime.Boxes[player]
	end

	local function tracerForPlayer(player)
		if not Runtime.Tracers[player] then
			Runtime.Tracers[player] = newDrawing("Line")
			if Runtime.Tracers[player] then
				Runtime.Tracers[player].Thickness = 1
				Runtime.Tracers[player].Transparency = 1
			end
		end
		return Runtime.Tracers[player]
	end

	local function healthBarForPlayer(player)
		if not Runtime.HealthBars[player] then
			Runtime.HealthBars[player] = {
				Background = newDrawing("Square"),
				Fill = newDrawing("Square"),
			}
		end
		return Runtime.HealthBars[player]
	end

	local function nameTagForPlayer(player)
		if not Runtime.NameTags[player] then
			Runtime.NameTags[player] = newDrawing("Text")
			if Runtime.NameTags[player] then
				Runtime.NameTags[player].Size = 13
				Runtime.NameTags[player].Center = true
				Runtime.NameTags[player].Outline = true
			end
		end
		return Runtime.NameTags[player]
	end

	local function distanceTagForPlayer(player)
		if not Runtime.DistanceTags[player] then
			Runtime.DistanceTags[player] = newDrawing("Text")
			if Runtime.DistanceTags[player] then
				Runtime.DistanceTags[player].Size = 12
				Runtime.DistanceTags[player].Center = true
				Runtime.DistanceTags[player].Outline = true
			end
		end
		return Runtime.DistanceTags[player]
	end

	local function weaponTagForPlayer(player)
		if not Runtime.WeaponTags[player] then
			Runtime.WeaponTags[player] = newDrawing("Text")
			if Runtime.WeaponTags[player] then
				Runtime.WeaponTags[player].Size = 11
				Runtime.WeaponTags[player].Center = true
				Runtime.WeaponTags[player].Outline = true
			end
		end
		return Runtime.WeaponTags[player]
	end

	local chamsCache = {}

	local function chamsForPlayer(player)
		if not chamsCache[player] then
			chamsCache[player] = {
				Visible = newHighlight(),
				Occluded = newHighlight(),
			}
		end
		return chamsCache[player]
	end

	local worldOverrides = {
		ClockTime = 12,
		FogEnd = 900,
		GlobalShadows = true,
		Brightness = 2,
	}
	local originalWorld = {}

	local function saveWorld()
		local lighting = game:GetService("Lighting")
		originalWorld.ClockTime = lighting.ClockTime
		originalWorld.FogEnd = lighting.FogEnd
		originalWorld.GlobalShadows = lighting.GlobalShadows
		originalWorld.Brightness = lighting.Brightness
		originalWorld.FogStart = lighting.FogStart
		if lighting:FindFirstChildOfClass("Atmosphere") then
			originalWorld.AtmosphereDensity = lighting:FindFirstChildOfClass("Atmosphere").Density
		end
		originalWorld.TimeOfDay = lighting.TimeOfDay
	end

	local function applyWorld()
		local lighting = game:GetService("Lighting")
		if S.FullBright then
			lighting.ClockTime = 14
			lighting.FogEnd = 1000000
			lighting.GlobalShadows = false
			lighting.Brightness = 0
		else
			lighting.ClockTime = originalWorld.ClockTime or 12
			lighting.FogEnd = originalWorld.FogEnd or 900
			lighting.GlobalShadows = originalWorld.GlobalShadows or true
			lighting.Brightness = originalWorld.Brightness or 2
		end
		if S.RemoveFog then
			lighting.FogEnd = 1000000
			lighting.FogStart = 0
		end
		local atm = lighting:FindFirstChildOfClass("Atmosphere")
		if S.HideGrass then
			local terrain = Workspace:FindFirstChildOfClass("Terrain")
			if terrain then terrain.Decoration = false end
		else
			local terrain = Workspace:FindFirstChildOfClass("Terrain")
			if terrain then terrain.Decoration = true end
		end
		if S.LowPC then
			for _, effect in ipairs(lighting:GetChildren()) do
				if effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
					effect.Enabled = false
				end
			end
		else
			for _, effect in ipairs(lighting:GetChildren()) do
				if effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
					effect.Enabled = true
				end
			end
		end
	end

	Runtime.FeatureHandlers.FullBright = function() applyWorld() end
	Runtime.FeatureHandlers.RemoveFog = function() applyWorld() end
	Runtime.FeatureHandlers.HideGrass = function() applyWorld() end
	Runtime.FeatureHandlers.LowPC = function() applyWorld() end

	function Visuals.Update()
		local camera = Workspace.CurrentCamera
		if not camera then return end
		local camPos = camera.CFrame.Position

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local character = player.Character
				local humanoid = Runtime.Shared.Humanoid(character)
				local root = Runtime.Shared.Root(character)
				if character and humanoid and root and humanoid.Health > 0 then
					local rootPos = root.Position
					local dist = (rootPos - camPos).Magnitude
					if dist <= (S.ESPMaxDist or 500) then
						local sx, sy, sz = Runtime.Shared.Project(rootPos)
						if sx and sz > 0 then
							if S.PlayerESP then
								local box = boxForPlayer(player)
								if box.TopLeft then
									local color = getBoxColor(player)
									for _, line in pairs(box) do
										line.Visible = true
										line.Color = color
										line.Thickness = 1
									end
									local w, h = 40, 80
									local top = sy - h/2
									local bot = sy + h/2
									local left = sx - w/2
									local right = sx + w/2
									box.TopLeft.From = Vector2.new(left, top); box.TopLeft.To = Vector2.new(left + 8, top)
									box.TopLeft.To = Vector2.new(left + 8, top)
									box.TopRight.From = Vector2.new(right - 8, top); box.TopRight.To = Vector2.new(right, top)
									box.BottomLeft.From = Vector2.new(left, bot); box.BottomLeft.To = Vector2.new(left + 8, bot)
									box.BottomRight.From = Vector2.new(right - 8, bot); box.BottomRight.To = Vector2.new(right, bot)
									box.Top.From = Vector2.new(left, top); box.Top.To = Vector2.new(left, top + 12)
									box.Bottom.From = Vector2.new(left, bot - 12); box.Bottom.To = Vector2.new(left, bot)
									box.Left.From = Vector2.new(left, top); box.Left.To = Vector2.new(left, top + 12)
									box.Right.From = Vector2.new(right, top); box.Right.To = Vector2.new(right, top + 12)
								end
							end
							if S.PlayerChams then
								local chams = chamsForPlayer(player)
								if chams.Visible then
									chams.Visible.Adornee = character
									chams.Visible.FillColor = Colors.ChamsFill or Color3.new(1, 0, 0)
									chams.Visible.OutlineColor = Colors.ChamsOutline or Color3.new(1, 1, 1)
									chams.Visible.FillTransparency = 0.5
									chams.Visible.OutlineTransparency = 0
									chams.Visible.Enabled = true
								end
								if chams.Occluded then
									chams.Occluded.Adornee = character
									chams.Occluded.FillColor = Colors.ChamsFill or Color3.new(1, 0, 0)
									chams.Occluded.OutlineColor = Colors.ChamsOutline or Color3.new(1, 1, 1)
									chams.Occluded.FillTransparency = 0.7
									chams.Occluded.OutlineTransparency = 0.3
									chams.Occluded.Enabled = true
								end
							end
							if S.PlayerTracers then
								local tracer = tracerForPlayer(player)
								if tracer then
									tracer.Visible = true
									tracer.Color = getBoxColor(player)
									tracer.From = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y)
									tracer.To = Vector2.new(sx, sy)
								end
							end
							if S.HealthBar then
								local hb = healthBarForPlayer(player)
								if hb.Background then
									local barW, barH = 4, 80
									local x, y = sx - 25, sy - 40
									hb.Background.Visible = true
									hb.Background.Size = Vector2.new(barW, barH)
									hb.Background.Position = Vector2.new(x, y)
									hb.Background.Color = Color3.new(0.2, 0.2, 0.2)
									hb.Background.Filled = true
									hb.Fill.Visible = true
									hb.Fill.Size = Vector2.new(barW, barH * (humanoid.Health / humanoid.MaxHealth))
									hb.Fill.Position = Vector2.new(x, y + barH - barH * (humanoid.Health / humanoid.MaxHealth))
									hb.Fill.Color = Color3.new(0, 1, 0)
									hb.Fill.Filled = true
								end
							end
							if S.PlayerName then
								local tag = nameTagForPlayer(player)
								if tag then
									tag.Visible = true
									tag.Text = player.DisplayName or player.Name
									tag.Position = Vector2.new(sx, sy - 55)
									tag.Color = getBoxColor(player)
								end
							end
							if S.PlayerDistance then
								local tag = distanceTagForPlayer(player)
								if tag then
									tag.Visible = true
									tag.Text = string.format("%.0f studs", dist)
									tag.Position = Vector2.new(sx, sy + 50)
									tag.Color = Color3.new(1, 1, 1)
								end
							end
						else
							Visuals.HidePlayer(player)
						end
					else
						Visuals.HidePlayer(player)
					end
				else
					Visuals.HidePlayer(player)
				end
			end
		end
	end

	function Visuals.HidePlayer(player)
		local box = Runtime.Boxes[player]
		if box then for _, line in pairs(box) do if line then line.Visible = false end end end
		local tracer = Runtime.Tracers[player]
		if tracer then tracer.Visible = false end
		local hb = Runtime.HealthBars[player]
		if hb then
			if hb.Background then hb.Background.Visible = false end
			if hb.Fill then hb.Fill.Visible = false end
		end
		local nameTag = Runtime.NameTags[player]
		if nameTag then nameTag.Visible = false end
		local distTag = Runtime.DistanceTags[player]
		if distTag then distTag.Visible = false end
		local weaponTag = Runtime.WeaponTags[player]
		if weaponTag then weaponTag.Visible = false end
		local chams = chamsCache[player]
		if chams then
			if chams.Visible then chams.Visible.Enabled = false end
			if chams.Occluded then chams.Occluded.Enabled = false end
		end
	end

	function Visuals.Clear()
		for _, player in ipairs(Players:GetPlayers()) do
			Visuals.HidePlayer(player)
		end
		for key, box in pairs(Runtime.Boxes) do
			for _, line in pairs(box) do if line then line:Remove() end end
		end
		for player, tracer in pairs(Runtime.Tracers) do
			if tracer then tracer:Remove() end
		end
		for player, hb in pairs(Runtime.HealthBars) do
			if hb.Background then hb.Background:Remove() end
			if hb.Fill then hb.Fill:Remove() end
		end
		for player, tag in pairs(Runtime.NameTags) do
			if tag then tag:Remove() end
		end
		for player, tag in pairs(Runtime.DistanceTags) do
			if tag then tag:Remove() end
		end
		for player, tag in pairs(Runtime.WeaponTags) do
			if tag then tag:Remove() end
		end
		Runtime.Boxes = {}
		Runtime.Tracers = {}
		Runtime.HealthBars = {}
		Runtime.NameTags = {}
		Runtime.DistanceTags = {}
		Runtime.WeaponTags = {}
		for player, chams in pairs(chamsCache) do
			if chams.Visible then chams.Visible:Destroy() end
			if chams.Occluded then chams.Occluded:Destroy() end
		end
		chamsCache = {}
	end

	function Visuals.Restore()
		Visuals.Clear()
		local lighting = game:GetService("Lighting")
		lighting.ClockTime = originalWorld.ClockTime or 12
		lighting.FogEnd = originalWorld.FogEnd or 900
		lighting.GlobalShadows = originalWorld.GlobalShadows or true
		lighting.Brightness = originalWorld.Brightness or 2
		if originalWorld.FogStart then lighting.FogStart = originalWorld.FogStart end
		if originalWorld.TimeOfDay then lighting.TimeOfDay = originalWorld.TimeOfDay end
		local atm = lighting:FindFirstChildOfClass("Atmosphere")
		if atm and originalWorld.AtmosphereDensity ~= nil then
			atm.Density = originalWorld.AtmosphereDensity
		end
		local terrain = Workspace:FindFirstChildOfClass("Terrain")
		if terrain then terrain.Decoration = true end
		for _, effect in ipairs(lighting:GetChildren()) do
			if effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
				effect.Enabled = true
			end
		end
	end
	Runtime._cleanup = Runtime._cleanup or {}
	table.insert(Runtime._cleanup, Visuals.Restore)
end

do
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	local Aim = {
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
	local silentOptions = {}
	local silentBest = {Score = math.huge}
	local fovCircle = newDrawing("Circle")
	if fovCircle then
		fovCircle.NumSides = 40
		fovCircle.Thickness = 1
		fovCircle.Filled = false
		fovCircle.Transparency = 1
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
		local humanoid = Runtime.Shared.Humanoid(character)
		local root = Runtime.Shared.Root(character)
		if not character or not humanoid or not root or humanoid.Health <= 0 then return end
		if options.TeamCheck and Runtime.Shared.IsTeammate(player) then return end
		local origin = Workspace.CurrentCamera.CFrame.Position
		local parts = boneSets[options.PartMode] or boneSets.Head
		for _, name in ipairs(parts) do
			local part = character:FindFirstChild(name)
			if part and part:IsA("BasePart") then
				local position = part.Position
				local distance = (position - origin).Magnitude
				if distance <= options.Range then
					local x, y, z = Runtime.Shared.Project(position)
					if x and z > 0 then
						local dx = x - Workspace.CurrentCamera.ViewportSize.X * 0.5
						local dy = y - Workspace.CurrentCamera.ViewportSize.Y * 0.5
						local screenDistance = math.sqrt(dx * dx + dy * dy)
						if screenDistance <= options.FOV then
							local score = screenDistance
							if options.Priority == "Distance" then
								score = distance + screenDistance * 0.0001
							elseif options.Priority == "Low HP" then
								score = humanoid.Health + screenDistance * 0.0001
							end
							if score < best.Score then
								if not options.WallCheck or Runtime.Shared.WallClearCached(position, character) then
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
		if not enabled or not Workspace.CurrentCamera then return position end
		local speed = math.max(1, tonumber(S.BulletSpeed) or 1000)
		local travel = math.clamp((position - Workspace.CurrentCamera.CFrame.Position).Magnitude / speed, 0, 0.5)
		local velocity = best.Target.Root.AssemblyLinearVelocity or Vector3.zero
		return position + velocity * travel
	end

	local originalRaycast, wrappedRaycast
	local hookInstalled = false
	local function raycastReplacement(self, origin, direction, params, ...)
		if not originalRaycast then return nil end
		if Runtime.Unloaded or not S.SilentAim or Runtime.MenuOpen or self ~= Workspace then
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
		if type(hookfunction) ~= "function" or type(Workspace.Raycast) ~= "function" then
			Aim.HookStatus = "unavailable"
			return false
		end
		originalRaycast = Workspace.Raycast
		wrappedRaycast = raycastReplacement
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
		if type(hookfunction) == "function" and originalRaycast then
			pcall(hookfunction, Workspace.Raycast, originalRaycast)
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
			if service and Workspace.CurrentCamera then
				pcall(service.SendMouseButtonEvent, service, Workspace.CurrentCamera.ViewportSize.X * 0.5, Workspace.CurrentCamera.ViewportSize.Y * 0.5, 0, false, game, 0)
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
		if not service or not Workspace.CurrentCamera then return false end
		local ok = pcall(service.SendMouseButtonEvent, service, Workspace.CurrentCamera.ViewportSize.X * 0.5, Workspace.CurrentCamera.ViewportSize.Y * 0.5, 0, true, game, 0)
		if not ok then return false end
		inputDown = true
		task.delay(0.025, release)
		return true
	end

	function Aim.Update(dt)
		Aim.SilentTarget = nil
		Aim.SilentPosition = nil
		local camera = Workspace.CurrentCamera
		if not camera then return end
		local center = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
		if fovCircle then
			fovCircle.Position = center
			fovCircle.Radius = S.SilentFOV or 100
			fovCircle.Color = Colors.FOV or Color3.new(1, 1, 1)
			fovCircle.Visible = S.SilentAim and S.FOVCircle and not Runtime.MenuOpen
		end
		if Runtime.MenuOpen then
			release()
			return
		end
		if S.SilentAim and hookInstalled then
			silentOptions.FOV = S.SilentFOV or 100
			silentOptions.Range = S.SilentRange or 1000
			silentOptions.PartMode = S.SilentPart or "Head"
			silentOptions.Priority = S.SilentPriority or "Distance"
			silentOptions.TeamCheck = S.SilentTeamCheck or false
			silentOptions.WallCheck = S.SilentWallCheck or false
			local best = selectTarget(silentOptions, silentBest)
			if best then
				Aim.SilentTarget = best.Target
				Aim.SilentPosition = predictedPosition(best, S.SilentPrediction)
			end
		end
		if S.AutoFire and Aim.SilentPosition and not inputDown then
			local now = os.clock()
			if now >= Aim.NextAutoFire and click() then
				Aim.NextAutoFire = now + math.max(20, S.AutoFireDelay) / 1000
			end
		end
	end

	function Aim.Restore()
		release()
		Aim.RestoreRaycast()
		Aim.SilentTarget = nil
		Aim.SilentPosition = nil
		if fovCircle then fovCircle.Visible = false end
	end
	Runtime._cleanup = Runtime._cleanup or {}
	table.insert(Runtime._cleanup, Aim.Restore)

	Runtime.FeatureHandlers.SilentAim = function(value)
		if value then
			Aim.InstallRaycast()
		else
			Aim.RestoreRaycast()
		end
	end
end

do
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local RunService = game:GetService("RunService")
	local Lighting = game:GetService("Lighting")
	local SoundService = game:GetService("SoundService")
	local LocalPlayer = Players.LocalPlayer

	local Misc = {}
	Runtime.Misc = Misc

	local originalFOV = 70
	local originalAmbience = {}
	local armorOverlays = {}
	local crosshairLines = {}
	local modDetectorCache = {}
	local lastModCheck = 0

	local function saveAmbience()
		originalAmbience.Brightness = Lighting.Brightness
		originalAmbience.OutdoorAmbient = Lighting.OutdoorAmbient
		originalAmbience.Ambient = Lighting.Ambient
	end

	local function applyAmbience()
		if S.AmbienceEnabled then
			Lighting.Brightness = S.AmbienceBrightness or 0
			local color = S.AmbienceColor or Color3.new(0.2, 0.5, 0.3)
			Lighting.OutdoorAmbient = color
			Lighting.Ambient = color
		else
			Lighting.Brightness = originalAmbience.Brightness or 2
			Lighting.OutdoorAmbient = originalAmbience.OutdoorAmbient or Color3.new(0.5, 0.5, 0.5)
			Lighting.Ambient = originalAmbience.Ambient or Color3.new(0, 0, 0)
		end
	end

	Runtime.FeatureHandlers.AmbienceEnabled = function() applyAmbience() end
	Runtime.FeatureHandlers.AmbienceBrightness = function() applyAmbience() end
	Runtime.FeatureHandlers.AmbienceColor = function() applyAmbience() end

	local function updateFOV()
		local camera = Workspace.CurrentCamera
		if not camera then return end
		if S.FOVChanger then
			camera.FieldOfView = S.FOVAmount or 100
		else
			camera.FieldOfView = originalFOV
		end
	end

	Runtime.FeatureHandlers.FOVChanger = function() updateFOV() end
	Runtime.FeatureHandlers.FOVAmount = function() updateFOV() end

	local freecamCFrame = nil
	local freecamSpeed = 30

	local function updateFreecam(dt)
		if not S.FreecamEnabled then return end
		local camera = Workspace.CurrentCamera
		if not camera then return end
		if not freecamCFrame then freecamCFrame = camera.CFrame end
		local moveDir = Vector3.zero
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
		if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
		if moveDir.Magnitude > 0 then
			freecamCFrame = freecamCFrame + moveDir.Unit * freecamSpeed * dt
			camera.CFrame = freecamCFrame
		end
	end

	Runtime.FeatureHandlers.FreecamEnabled = function(value)
		if value then
			freecamCFrame = Workspace.CurrentCamera.CFrame
		else
			freecamCFrame = nil
		end
	end

	local function updateCrosshair()
		for _, line in ipairs(crosshairLines) do
			if line then line:Remove() end
		end
		crosshairLines = {}
		if not S.CrosshairEnabled then return end
		local camera = Workspace.CurrentCamera
		if not camera then return end
		local cx, cy = camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5
		local color = S.CrosshairColor or Color3.new(1, 1, 1)
		local length = S.CrosshairLength or 10
		local gap = S.CrosshairGap or 4
		local thickness = S.CrosshairThickness or 2

		local function makeLine(fromX, fromY, toX, toY)
			local line = newDrawing("Line")
			if line then
				line.From = Vector2.new(fromX, fromY)
				line.To = Vector2.new(toX, toY)
				line.Color = color
				line.Thickness = thickness
				line.Visible = true
				table.insert(crosshairLines, line)
			end
		end

		makeLine(cx - gap - length, cy, cx - gap, cy)
		makeLine(cx + gap, cy, cx + gap + length, cy)
		makeLine(cx, cy - gap - length, cx, cy - gap)
		makeLine(cx, cy + gap, cx, cy + gap + length)
	end

	Runtime.FeatureHandlers.CrosshairEnabled = function() updateCrosshair() end
	Runtime.FeatureHandlers.CrosshairColor = function() updateCrosshair() end
	Runtime.FeatureHandlers.CrosshairLength = function() updateCrosshair() end
	Runtime.FeatureHandlers.CrosshairGap = function() updateCrosshair() end
	Runtime.FeatureHandlers.CrosshairThickness = function() updateCrosshair() end

	local function checkMods()
		local now = os.clock()
		if now - lastModCheck < 1 then return end
		lastModCheck = now
		local detected = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local char = player.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart")
					if root then
						local vel = root.AssemblyLinearVelocity
						if vel and vel.Magnitude > 100 then
							table.insert(detected, player.Name .. " (speed: " .. math.floor(vel.Magnitude) .. ")")
						end
					end
				end
			end
		end
		modDetectorCache = detected
	end

	function Misc.Update(dt)
		if S.AmbienceEnabled then applyAmbience() end
		if S.FOVChanger then updateFOV() end
		if S.FreecamEnabled then updateFreecam(dt) end
		if S.ModDetector then checkMods() end
	end

	function Misc.Restore()
		Lighting.Brightness = originalAmbience.Brightness or 2
		Lighting.OutdoorAmbient = originalAmbience.OutdoorAmbient or Color3.new(0.5, 0.5, 0.5)
		Lighting.Ambient = originalAmbience.Ambient or Color3.new(0, 0, 0)
		local camera = Workspace.CurrentCamera
		if camera then camera.FieldOfView = originalFOV end
		for _, line in ipairs(crosshairLines) do
			if line then line:Remove() end
		end
		crosshairLines = {}
	end
	Runtime._cleanup = Runtime._cleanup or {}
	table.insert(Runtime._cleanup, Misc.Restore)
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
	table.insert(Runtime._cleanup, Environment.Restore)
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
	table.insert(Runtime._cleanup, function() pcall(function() connection:Disconnect() end) end)
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

table.insert(Runtime._cleanup, function()
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
	Runtime.FeatureHandlers.FreecamEnabled = function(value)
		if not value and Runtime.Freecam and Runtime.Freecam.Restore then Runtime.Freecam.Restore() end
	end
	Runtime.FeatureHandlers.UIAnimations = function(value) UIAnimations = value end
	for _, key in ipairs({"FullBright", "NoFog", "NoShadows", "HideGrass", "LowPC"}) do
		Runtime.FeatureHandlers[key] = function() Runtime.Environment.Apply() end
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

	do
		local lc, rc = getTab("COMBAT")

		local editor = feature(section(lc, "Silent Aim"), "Silent Aim", "SilentAim")
		slider(editor, "FOV", 0, 100, "SilentFOV")
		slider(editor, "Hit Chance", 0, 100, "SilentHitChance")
		dropdown(editor, "Target Parts", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "SilentPart")
		onOff(editor, "Manipulation", "SilentManipulation")
		addBind(editor, "Manip Key", "None", function() end)
		slider(editor, "Manip Distance", 1, 15, "SilentManipDistance")
		onOff(editor, "Manip Indicator", "SilentManipIndicator")
		color(editor, "Manip Indicator Color", "SilentManipIndicatorColor")
		color(editor, "Manip Target Color", "SilentManipTargetColor")
		onOff(editor, "Autoshoot", "SilentAutoshoot")
		addBind(editor, "Autoshoot Key", "T", function() end)
		onOff(editor, "Visible Check", "SilentVisibleCheck")
		onOff(editor, "Ignore Downed", "SilentDownCheck")
		onOff(editor, "Target Teammates", "SilentTargetTeammates")
		onOff(editor, "Draw FOV Circle", "SilentFOVCircle")
		slider(editor, "Circle FOV Size", 0, 100, "SilentFOVCircleSize")
		slider(editor, "Circle Thickness", 1, 10, "SilentFOVThickness")
		onOff(editor, "Fill Circle", "SilentFOVFill")
		slider(editor, "Fill Transparency", 0, 100, "SilentFOVFillTransparency")
		color(editor, "Circle Color 1", "SilentFOVColor")
		color(editor, "Circle Color 2", "SilentFOVColor2")
		onOff(editor, "Rainbow", "SilentFOVRainbow")
		slider(editor, "Rainbow Speed", 0, 5, "SilentFOVRainbowSpeed")
		slider(editor, "Gradient Rotation", 0, 360, "SilentFOVGradientRotation")
		onOff(editor, "Rotate Gradient", "SilentFOVRotate")
		slider(editor, "Rotate Speed", 0, 5, "SilentFOVRotateSpeed")
		toggleBind(editor, "Silent Aim", "SilentAim")

		editor = feature(section(rc, "Gun Mods"), "No Recoil", "NoRecoil")
		onOff(editor, "No Recoil", "NoRecoil")
		onOff(editor, "No Sway", "NoSway")
		onOff(editor, "RPM", "RPMEnabled")
		slider(editor, "RPM Multiplier", 1, 15, "RPMMultiplier")
		onOff(editor, "No Bob", "NoBob")
		onOff(editor, "Instant Bullet", "InstantBullet")
		onOff(editor, "Range Multiplier", "RangeMult")
		slider(editor, "Range Amount", 1, 20, "RangeAmount")

		editor = feature(section(rc, "Hitsound & Tracers"), "Hitsound", "HitsoundEnabled")
		onOff(editor, "Hitsound", "HitsoundEnabled")
		dropdown(editor, "Hitsound Select", {"Minecraft", "Telegram", "Rust Headshot", "CSGO Kill", "Minecraft Bow", "CSGO Headshot", "Minecraft XP", "Minecraft Drop", "Fortnite Headshot", "Gamesense", "Primordial"}, "HitsoundSound")
		slider(editor, "Hitsound Volume", 0, 1000, "HitsoundVolume")
		onOff(editor, "Hit Notifications", "HitNotify")
		onOff(editor, "Shoot Sound", "ShootSoundEnabled")
		slider(editor, "Shoot Volume", 0, 1000, "ShootSoundVolume")
		onOff(editor, "Tracer", "TracerEnabled")
		dropdown(editor, "Tracer Style", {"Default", "Obelus", "Lightning", "DNA", "Minecraft", "Beam", "Galaxy"}, "TracerStyle")
		color(editor, "Tracer Color", "TracerColor")
		slider(editor, "Tracer Duration", 0, 15, "TracerDuration")
		slider(editor, "Tracer Thickness", 0, 100, "TracerThickness")

		editor = feature(section(rc, "Exploits"), "Instant Eoka", "InstantEoka")
		onOff(editor, "Instant Eoka", "InstantEoka")
		onOff(editor, "Instant Equip", "InstantEquip")
		onOff(editor, "Fast Melee", "MeleeSpeedEnabled")
		slider(editor, "Melee Speed", 1, 20, "MeleeSpeedAmount")
		onOff(editor, "Melee Range", "MeleeRangeEnabled")
		slider(editor, "Melee Range Amount", 1, 35, "MeleeRangeAmount")
		onOff(editor, "No Fall Damage", "NoFallDamage")
		onOff(editor, "Instant Loot", "InstantLoot")
		onOff(editor, "Reload Bar", "ReloadBar")
		onOff(editor, "Perfect Farm", "PerfectFarm")
	end

	do
		local lc, rc = getTab("VISUALS")

		local editor = feature(section(lc, "Players"), "Player ESP", "PlayerESP")
		onOff(editor, "Box", "ESPBox")
		dropdown(editor, "Box Type", {"Corner", "2D", "3D"}, "ESPBoxType")
		color(editor, "Box Color", "ESPBoxColor")
		onOff(editor, "Health Bar", "ESPHealthBar")
		onOff(editor, "Name", "ESPName")
		onOff(editor, "Distance", "ESPDistance")
		onOff(editor, "Weapon", "ESPWeapon")
		onOff(editor, "Chams", "ESPChams")
		color(editor, "Chams Color", "ESPChamsColor")
		onOff(editor, "Skeleton", "ESPSkeleton")
		color(editor, "Skeleton Color", "ESPSkeletonColor")
		slider(editor, "Max Distance", 50, 2000, "ESPMaxDist")
		toggleBind(editor, "Player ESP", "PlayerESP")

		editor = feature(section(lc, "Boss"), "Boss ESP", "BossESP")
		onOff(editor, "Box", "BossBox")
		color(editor, "Box Color", "BossBoxColor")
		onOff(editor, "Health Bar", "BossHealthBar")
		onOff(editor, "Name", "BossName")
		onOff(editor, "Distance", "BossDistance")

		editor = feature(section(rc, "AI"), "AI ESP", "AIESP")
		onOff(editor, "Box", "AIBox")
		color(editor, "Box Color", "AIBoxColor")
		onOff(editor, "Name", "AIName")
		onOff(editor, "Distance", "AIDistance")
		dropdown(editor, "Filter", {"All", "Hostile", "Neutral"}, "AIFilter")

		editor = feature(section(rc, "Misc ESP"), "Loot ESP", "LootESP")
		onOff(editor, "Loot ESP", "LootESP")
		onOff(editor, "Deployables ESP", "DeployablesESP")
		onOff(editor, "Vehicles ESP", "VehiclesESP")
		onOff(editor, "Resources ESP", "ResourcesESP")
		onOff(editor, "Airdrops ESP", "AirdropsESP")
		slider(editor, "Max Distance", 50, 2000, "MiscESPMaxDist")

		editor = feature(section(rc, "Gun Chams & Skin"), "Weapon Skin", "GunSkinEnabled")
		onOff(editor, "Weapon Skin", "GunSkinEnabled")
		dropdown(editor, "Shader Preset", {"Galaxy", "Universe", "Grooves", "Liquid", "Galaxy2", "Tunnel", "Aurora"}, "GunSkinPreset")
		slider(editor, "Scroll Speed", 1, 100, "GunSkinScrollSpeed")
		onOff(editor, "Gun Chams", "GunChams")
		color(editor, "Gun Color", "GunChamsColor")
		dropdown(editor, "Gun Material", {"ForceField", "Neon", "Glass", "Ice", "Wood", "Plastic", "Metal"}, "GunChamsMaterial")
		dropdown(editor, "Gun Texture", {"Web", "Swirl", "Checkers", "CandyCane", "Dots", "Scanning", "Bubbles", "Water", "America", "Rainbow", "Akatsuki", "None"}, "GunChamsTexture")
		onOff(editor, "Arms Chams", "ArmsChams")
		color(editor, "Arms Color", "ArmsChamsColor")
		dropdown(editor, "Arms Material", {"ForceField", "Neon", "Glass", "Ice", "Wood", "Plastic", "Metal"}, "ArmsChamsMaterial")
		dropdown(editor, "Arms Texture", {"Web", "Swirl", "Checkers", "CandyCane", "Dots", "Scanning", "Bubbles", "Water", "America", "Rainbow", "Akatsuki", "None"}, "ArmsChamsTexture")
	end

	do
		local lc, rc = getTab("MOVEMENT")

		local editor = feature(section(lc, "Speed"), "Speed", "Speed")
		slider(editor, "Value", 16, 200, "SpeedValue")
		toggleBind(editor, "Speed", "Speed")

		editor = feature(section(lc, "Fly"), "Fly", "Fly")
		slider(editor, "Speed", 16, 250, "FlySpeed")
		slider(editor, "Height", -50, 50, "FlyHeight")
		addBind(editor, "Fly Key", "F", function() end)
		toggleBind(editor, "Fly", "Fly")

		editor = feature(section(rc, "Collision"), "Noclip", "RocketNoclip")
		toggleBind(editor, "Noclip", "RocketNoclip")

		editor = feature(section(rc, "Camera"), "Freecam", "FreecamEnabled")
		slider(editor, "Speed", 0, 100, "FreecamSpeed")
		addBind(editor, "Toggle Key", "U", function() end)
		toggleBind(editor, "Freecam", "FreecamEnabled")
	end

	do
		local lc, rc = getTab("MISC")

		local editor = feature(section(lc, "Lighting"), "FullBright", "FullBright")
		onOff(editor, "No Shadows", "NoShadows")

		editor = feature(section(lc, "Fog"), "Remove Fog", "NoFog")

		editor = feature(section(lc, "Ambience"), "Ambience", "AmbienceEnabled")
		slider(editor, "Brightness", 0, 100, "AmbienceBrightness")
		slider(editor, "Indoor Brightness", 0, 100, "AmbienceIndoor")
		color(editor, "Color", "AmbienceColor")

		editor = feature(section(lc, "Crosshair"), "Crosshair", "CrosshairEnabled")
		dropdown(editor, "Preset", {"Custom", "Dot", "Cross", "Star of David", "Hexagram", "Circle"}, "CrosshairPreset")
		color(editor, "Color", "CrosshairColor")
		dropdown(editor, "Position", {"Center", "Mouse", "Target"}, "CrosshairPosition")
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

		editor = feature(section(rc, "Terrain"), "Hide Grass", "HideGrass")
		toggleBind(editor, "Hide Grass", "HideGrass")

		editor = feature(section(rc, "Performance"), "Low PC", "LowPC")
		toggleBind(editor, "Low PC", "LowPC")

		editor = feature(section(rc, "FOV Changer"), "FOV Changer", "FOVChanger")
		slider(editor, "Amount", 70, 120, "FOVAmount")
		onOff(editor, "Zoom", "ZoomEnabled")
		addBind(editor, "Zoom Key", "Z", function() end)
		slider(editor, "Zoom Amount", 1, 80, "ZoomAmount")
		slider(editor, "Animation Speed", 1, 30, "ZoomAnimSpeed")

		editor = feature(section(rc, "Mod Detector"), "Mod Detector", "ModDetector")
		onOff(editor, "Notify", "ModNotify")

		editor = feature(section(rc, "Armor Viewer"), "Armor Viewer", "ArmorViewer")
		onOff(editor, "Show Local", "ArmorShowLocal")
		slider(editor, "Max Distance", 0, 100, "ArmorMaxDist")
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
