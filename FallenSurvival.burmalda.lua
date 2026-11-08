local __burmaldaFallenEnv = getgenv and getgenv() or _G
local __burmaldaFallenGame = tostring(__burmaldaFallenEnv.BURMALDA_GAME or ""):match("^%s*(.-)%s*$")
local __burmaldaFallenKey = tostring(__burmaldaFallenEnv.SCRIPT_KEY or ""):match("^%s*(.-)%s*$")
if game.PlaceId ~= 10228136016
    or __burmaldaFallenGame ~= "fallen survival"
    or tostring(__burmaldaFallenEnv.PHOOKGATE or "") ~= "1347571535"
    or __burmaldaFallenKey == ""
    or __burmaldaFallenKey:upper() == "BETA"
then
    __burmaldaFallenEnv.PHOOKGATE = nil
    __burmaldaFallenEnv.SCRIPT_KEY = nil
    __burmaldaFallenEnv.BURMALDA_GAME = nil
    return
end
__burmaldaFallenEnv.PHOOKGATE = nil
__burmaldaFallenEnv.SCRIPT_KEY = nil
__burmaldaFallenEnv.BURMALDA_GAME = nil

local Env = getgenv and getgenv() or _G
if Env.BurmaldaFallenSurvival and Env.BurmaldaFallenSurvival.Unload then
	pcall(Env.BurmaldaFallenSurvival.Unload)
end

local executorName = 'unknown'
if type(identifyexecutor) == 'function' then
	local ok, name = pcall(identifyexecutor)
	if ok and name ~= nil then executorName = tostring(name) end
elseif type(getexecutorname) == 'function' then
	local ok, name = pcall(getexecutorname)
	if ok and name ~= nil then executorName = tostring(name) end
end

if string.find(string.lower(executorName), 'xeno', 1, true) then return end
local supported = false
for _, name in ipairs({ 'Real', 'Opiumware', 'Madium', 'Potassium', 'Synapse Z', 'Volt', 'Volcano' }) do
	if string.find(string.lower(executorName), string.lower(name), 1, true) then supported = true break end
end
if not supported then return end
if game.PlaceId ~= 10228136016 then return end

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local Lighting = game:GetService('Lighting')
local HttpService = game:GetService('HttpService')
local StatsService = game:GetService('Stats')
local TweenService = game:GetService('TweenService')
local Workspace = game:GetService('Workspace')
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local NL = string.char(10)

local Runtime = {
	Unloaded = false,
	Ready = false,
	Connections = {},
	Drawings = {},
	Guis = {},
	Owned = {},
	AnimationConnections = {},
	MenuOpen = true,
	GuardActive = false,
	TabNames = { 'COMBAT', 'VISUALS', 'ENTITY', 'LOCAL', 'WORLD', 'MISC', 'CONFIG' },
	PlaceId = 10228136016,
	SupportedExecutors = { 'Real', 'Opiumware', 'Madium', 'Potassium', 'Synapse Z', 'Volt', 'Volcano', 'Solara' },
}
Env.BurmaldaFallenSurvival = Runtime

local State = {
	ConfigSlot = 'Slot 1',
	SilentAim = false,
	AimFOV = 300,
	AimRange = 1300,
	AimSmoothing = 8,
	AimHitchance = 100,
	AimHitPart = 'Head',
	AimBulletSpeed = 1000,
	AimFOVSize = 300,
	AimFOVColour = 'White',
	AimSnaplineColour = 'Default',
	AimManipulationIndicator = false,
	AimManipulationIndicatorColour = 'Red',
	AimHitscanIndicator = false,
	AimHitscanIndicatorColour = 'Yellow',
	AimTargetNPCs = false,
	AimTeamCheck = false,
	AimVisibleCheck = false,
	AimWallCheck = false,
	AimPrediction = false,
	AimForceHit = false,
	AimManipulation = false,
	AimHitscan = false,
	AimSnapline = false,
	AimDrawFOV = false,
	AimDynamicFOV = false,
	ForceHitDistance = 8,
	ManipulationDistance = 8,
	HitscanDistance = 8.5,
	RecoilControl = false,
	SpreadControl = false,
	FirerateControl = false,
	RecoilPercentage = 100,
	SpreadPercentage = 100,
	FirerateMultiplier = 1,
	AlwaysAutomatic = false,
	NoMeleeShake = false,
	MeleeSpeedBoost = false,
	MeleeRangeBoost = false,
	MeleeSpeedAmount = 1,
	MeleeRangeAmount = 1,
	InstantEoka = false,
	AlwaysShoot = false,
	AutoReload = false,
	BulletTP = false,
	TPToWaypoint = false,
	CombatMode = false,
	PlayerESP = false,
	PlayerNames = false,
	PlayerBoxes = false,
	PlayerHealth = false,
	PlayerDistance = false,
	PlayerWeapon = false,
	PlayerNameColour = 'Default',
	PlayerBoxColour = 'Default',
	PlayerDistanceColour = 'Default',
	PlayerWeaponColour = 'Default',
	PlayerTracers = false,
	PlayerTeamCheck = false,
	TeamColors = false,
	ESPRange = 1000,
	ESPUpdateRate = 20,
	NPCESP = false,
	NPCNames = false,
	NPCBoxes = false,
	NPCHealth = false,
	NPCDistance = false,
	NPCMaxDistance = 1000,
	NPCScav = false,
	NPCBruno = false,
	NPCBoris = false,
	NPCBrutus = false,
	NPCBradley = false,
	NPCWolf = false,
	NPCDeer = false,
	NPCBoar = false,
	NPCScavColour = 'Default',
	NPCBrunoColour = 'Default',
	NPCBorisColour = 'Default',
	NPCBrutusColour = 'Default',
	NPCBradleyColour = 'Default',
	NPCWolfColour = 'Default',
	NPCDeerColour = 'Default',
	NPCBoarColour = 'Default',
	NPCZombie = false,
	NPCAttackHeli = false,
	EntityESP = false,
	EntityNames = false,
	EntityBoxes = false,
	EntityDistance = false,
	EntityTracers = false,
	EntityMaxDistance = 1000,
	EntityMinicopter = false,
	EntityBodyBag = false,
	EntityAirdrop = false,
	EntityTimedCrate = false,
	EntityHemp = false,
	EntityStone = false,
	EntityPhosphate = false,
	EntityMetal = false,
	EntitySmallGift = false,
	EntityMediumGift = false,
	EntityLargeGift = false,
	EntityMinicopterColour = 'Default',
	EntityBodyBagColour = 'Default',
	EntityAirdropColour = 'Default',
	EntityTimedCrateColour = 'Default',
	EntityHempColour = 'Default',
	EntityStoneColour = 'Default',
	EntityPhosphateColour = 'Default',
	EntityMetalColour = 'Default',
	EntitySmallGiftColour = 'Default',
	EntityMediumGiftColour = 'Default',
	EntityLargeGiftColour = 'Default',
	SilentMinicopter = false,
	DisableMinicopterDamage = false,
	ShootWhilePiloted = false,
	XRay = false,
	XRayTransparency = 70,
	DisableTraps = false,
	DisableSpikes = false,
	Speed = false,
	SpeedValue = 30,
	Fly = false,
	FlySpeed = 40,
	Noclip = false,
	InfiniteJump = false,
	Freecam = false,
	FreecamSpeed = 60,
	UndergroundAntiAim = false,
	AntiAimDepth = 2,
	NoFallDamage = false,
	InstantEquip = false,
	SilentWalk = false,
	InstantLoot = false,
	AlwaysCriticals = false,
	Chams = false,
	ChamsColour = 'White',
	ChamsMaterial = 'Forcefield',
	ChamsTransparency = 50,
	CustomFOV = false,
	FOVValue = 90,
	Zoom = false,
	ZoomFOV = 40,
	Ambient = false,
	AmbientColour = 'White',
	RemoveGrass = false,
	LowPC = false,
	FullBright = false,
	RemoveFog = false,
	StaffDetector = false,
	ResolveAntiAim = false,
	TeleportMouse = false,
	Respawn = false,
	Suicide = false,
	StatsHUD = false,
	TargetHUD = false,
	KeybindList = false,
	MenuAccent = false,
	UIAnimations = false,
	ScorpionGunMods = false,
	ScorpionNoRecoil = false,
	ScorpionNoSway = false,
	ScorpionNoBob = false,
	ScorpionRPM = false,
	ScorpionRPMValue = 1,
	ScorpionInstantBullet = false,
	ScorpionRangeMult = false,
	ScorpionRangeAmount = 5,
	ScorpionAutoshoot = false,
	ScorpionDownCheck = false,
	ScorpionTargetTeammates = false,
	ScorpionInstantEoka = false,
	ScorpionInstantLoot = false,
	ScorpionPerfectFarm = false,
	ScorpionRemoveGrass = false,
	ScorpionHitSound = false,
	ScorpionHitSoundName = 'Minecraft',
	ScorpionHitSoundVolume = 100,
	ScorpionShootSound = false,
	ScorpionShootVolume = 100,
	ScorpionTracer = false,
	ScorpionTracerStyle = 'Default',
	ScorpionTracerDuration = 1,
	ScorpionTracerThickness = 15,
	ScorpionFovRainbow = false,
	ScorpionFovRainbowSpeed = 1,
	ScorpionFovRotate = false,
	ScorpionFovRotateSpeed = 1.2,
	ScorpionFovFill = false,
	ScorpionFovFillTransparency = 80,
	ScorpionFovThickness = 2,
	ScorpionAmbience = false,
	ScorpionAmbBrightness = 12,
	ScorpionAmbIndoor = 4,
	ScorpionAmbColour = 'White',
	ScorpionGunChams = false,
	ScorpionArmsChams = false,
	ScorpionGunMaterial = 'ForceField',
	ScorpionGunColour = 'White',
	ScorpionWatermark = false,
	ScorpionFlyRestrictions = false,
}
Runtime.State = State

local Binds = {
	SilentAim = 'None',
	AimForceHit = 'None',
	AimManipulation = 'None',
	AimHitscan = 'None',
	PlayerESP = 'None',
	Speed = 'None',
	Fly = 'None',
	Noclip = 'None',
	Freecam = 'None',
	Zoom = 'None',
	XRay = 'None',
	BulletTP = 'None',
	TPToWaypoint = 'None',
	CombatMode = 'None',
	UndergroundAntiAim = 'None',
	NoFallDamage = 'None',
	TeleportMouse = 'None',
	Respawn = 'None',
	Suicide = 'None',
}
Runtime.Binds = Binds

local function configPath()
	local slot = string.match(State.ConfigSlot, '%d+') or '1'
	return 'burmalda/fallen_survival_config_' .. slot .. '.json'
end

local ConfigControls = {}
local FeatureHandlers = {}
local SettingHandlers = {}
local EspObjects = {}
local OriginalLighting = {}
local OriginalEffects = {}
local OriginalGrass = {}
local OriginalXRay = {}
local OriginalTraps = {}
local OriginalSpikes = {}
local OriginalChams = {}
local OriginalTerrainDecoration = Workspace.Terrain and Workspace.Terrain.Decoration or nil
local OriginalFOV = Camera and Camera.FieldOfView or 70
local OriginalGravity = Workspace.Gravity
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local OriginalJumpHeight = 7.2
local OriginalCameraType = Camera and Camera.CameraType or nil
local OriginalCameraCFrame = Camera and Camera.CFrame or nil
local OriginalCameraSubject = Camera and Camera.CameraSubject or nil
local noclipParts = {}
local freecam = { active = false, position = Vector3.new(), yaw = 0, pitch = 0 }
local antiAimOriginal = nil
local espAccumulator = 0

local function fromRGB(r, g, b)
	if Color3.fromRGB then return Color3.fromRGB(r, g, b) end
	return Color3.new(r / 255, g / 255, b / 255)
end

local NpcSettings = {
	Soldier = { Flag = 'NPCScav', Colour = 'NPCScavColour', Label = 'Scav', Color = fromRGB(62, 87, 55) },
	Bruno = { Flag = 'NPCBruno', Colour = 'NPCBrunoColour', Label = 'Bruno', Color = fromRGB(81, 99, 40) },
	Boris = { Flag = 'NPCBoris', Colour = 'NPCBorisColour', Label = 'Boris', Color = fromRGB(21, 26, 10) },
	Brutus = { Flag = 'NPCBrutus', Colour = 'NPCBrutusColour', Label = 'Brutus', Color = fromRGB(38, 41, 33) },
	BTR = { Flag = 'NPCBradley', Colour = 'NPCBradleyColour', Label = 'Bradley', Color = fromRGB(39, 49, 16) },
	PREFAB_ANIMAL_WOLF = { Flag = 'NPCWolf', Colour = 'NPCWolfColour', Label = 'Wolf', Color = fromRGB(105, 95, 68) },
	PREFAB_ANIMAL_DEER = { Flag = 'NPCDeer', Colour = 'NPCDeerColour', Label = 'Deer', Color = fromRGB(63, 57, 41) },
	PREFAB_ANIMAL_WILDBOAR = { Flag = 'NPCBoar', Colour = 'NPCBoarColour', Label = 'Boar', Color = fromRGB(43, 35, 13) },
	Zombie = { Flag = 'NPCZombie', Label = 'Zombie', Color = fromRGB(82, 110, 60) },
	['Attack Heli'] = { Flag = 'NPCAttackHeli', Label = 'Attack Heli', Color = fromRGB(120, 40, 40) },
}

local EntitySettings = {
	['Wool Plant'] = { Flag = 'EntityHemp', Colour = 'EntityHempColour', Label = 'Hemp', Color = fromRGB(168, 168, 168) },
	Stone_Node = { Flag = 'EntityStone', Colour = 'EntityStoneColour', Label = 'Stone', Color = fromRGB(87, 87, 87) },
	Phosphate_Node = { Flag = 'EntityPhosphate', Colour = 'EntityPhosphateColour', Label = 'Phosphate', Color = fromRGB(235, 229, 158) },
	Metal_Node = { Flag = 'EntityMetal', Colour = 'EntityMetalColour', Label = 'Metal', Color = fromRGB(145, 85, 62) },
	['Body Bag'] = { Flag = 'EntityBodyBag', Colour = 'EntityBodyBagColour', Label = 'Body Bag', Color = fromRGB(255, 101, 40) },
	['Care Package'] = { Flag = 'EntityAirdrop', Colour = 'EntityAirdropColour', Label = 'Airdrop', Color = fromRGB(80, 49, 20) },
	['Timed Crate'] = { Flag = 'EntityTimedCrate', Colour = 'EntityTimedCrateColour', Label = 'Timed Crate', Color = fromRGB(41, 41, 41) },
	['Salvaged Flycopter'] = { Flag = 'EntityMinicopter', Colour = 'EntityMinicopterColour', Label = 'Minicopter', Color = fromRGB(44, 236, 19) },
	['Small Gift'] = { Flag = 'EntitySmallGift', Colour = 'EntitySmallGiftColour', Label = 'Small Gift', Color = fromRGB(255, 7, 11) },
	['Medium Gift'] = { Flag = 'EntityMediumGift', Colour = 'EntityMediumGiftColour', Label = 'Medium Gift', Color = fromRGB(255, 215, 15) },
	['Large Gift'] = { Flag = 'EntityLargeGift', Colour = 'EntityLargeGiftColour', Label = 'Large Gift', Color = fromRGB(60, 255, 16) },
}

local BuildingLookup = {
	Doorway = true, Floor = true, FloorFrame = true, Foundation = true,
	['Foundation Steps'] = true, ['Half Wall'] = true, ['L-Shaped Stairs'] = true,
	['Low Wall'] = true, ['Triangle Floor'] = true, ['Triangle Floor Frame'] = true,
	['Triangle Foundation'] = true, ['U-Shaped Stairs'] = true, Wall = true,
	['Wall Block'] = true, ['Wall Frame'] = true, Window = true,
}
local TrapLookup = { ['Bear Trap'] = true, ['Shotgun Turret'] = true, ['Auto Turret'] = true }
local SpikeLookup = { ['Metal Spikes'] = true, ['Wooden Spikes'] = true, ['External Stone Wall'] = true, ['External Wooden Wall'] = true }
local GrassLookup = { Grass = true, Leaves = true, Bush = true, LeafPart = true, CactusPart = true, Vegetation = true, Trees = true }
local AmbientColours = { White = fromRGB(255, 255, 255), Blue = fromRGB(120, 180, 255), Warm = fromRGB(255, 180, 120) }
local ChamsColours = { White = fromRGB(255, 255, 255), Red = fromRGB(255, 70, 70), Green = fromRGB(70, 255, 120) }
local ChamsMaterials = { Forcefield = Enum.Material.ForceField, Neon = Enum.Material.Neon, SmoothPlastic = Enum.Material.SmoothPlastic }
local AimColours = { White = fromRGB(255, 255, 255), Green = fromRGB(105, 237, 150), Red = fromRGB(237, 105, 105) }
local EspColours = {
	White = fromRGB(255, 255, 255), Red = fromRGB(255, 0, 0), Yellow = fromRGB(255, 196, 0),
	Green = fromRGB(60, 255, 16), Orange = fromRGB(255, 101, 40), Blue = fromRGB(120, 180, 255),
	Purple = fromRGB(150, 80, 220), Cyan = fromRGB(80, 220, 255), Pink = fromRGB(255, 7, 11),
}
local ColourNames = { 'Default', 'White', 'Red', 'Yellow', 'Green', 'Orange', 'Blue', 'Purple', 'Cyan', 'Pink' }
local function espColour(key, fallback)
	return EspColours[State[key]] or fallback
end
local ConfigSlots = { 'Slot 1', 'Slot 2', 'Slot 3' }
local HitParts = { 'Head', 'Torso', 'Root', 'Closest', 'Random' }

local function runCompatibility()
	local ok, result = pcall(function()
		if type(getgc) ~= 'function' or type(debug) ~= 'table' then return false end
		local info = debug.info
		local getupvalues = debug.getupvalues
		local getconstants = debug.getconstants
		local clone = table.clone
		local isfrozen = table.isfrozen
		local clear = table.clear
		if type(info) ~= 'function' or type(getupvalues) ~= 'function' or type(getconstants) ~= 'function' or type(clone) ~= 'function' or type(isfrozen) ~= 'function' or type(clear) ~= 'function' then return false end
		if type(rawlen) ~= 'function' or type(rawget) ~= 'function' or type(rawset) ~= 'function' or type(getmetatable) ~= 'function' or type(setmetatable) ~= 'function' then return false end
		local objects = getgc()
		if type(objects) ~= 'table' then return false end
		local sourceName = 'ReplicatedStorage.Modules.AssetContainer'
		local found = nil
		for _, value in ipairs(objects) do
			if type(value) == 'function' and info(value, 's') == sourceName then
				for _, constant in pairs(getconstants(value)) do
					if constant == 'WalkSpeed' then found = value break end
				end
				if found then break end
			end
		end
		if not found then return false end
		local banTable = getupvalues(found)[2]
		if type(banTable) ~= 'table' then return false end
		local selfKey, indexKey, indexValue = nil, nil, nil
		for key, value in pairs(banTable) do
			if type(key) == 'number' then
				if value == banTable then selfKey = key
				elseif type(value) == 'number' then indexKey, indexValue = key, value end
			end
		end
		if not selfKey or not indexKey or not indexValue then return false end
		local function suspicious(value)
			if type(value) ~= 'table' then return false end
			local length = rawlen(value)
			local first, second, third, fourth = rawget(value, 1), rawget(value, 2), rawget(value, 3), rawget(value, 4)
			if length == 4 and first == 2 and second == 'BillboardGui' and third == 'BillboardGui' and fourth == false then return true end
			if length == 4 and type(first) == 'table' and rawget(first, 1) == 73 and second == false and type(third) == 'number' and type(fourth) == 'number' then return true end
			if length == 4 and type(first) == 'table' and rawget(first, 1) == 7 and rawget(first, 'n') == 1 and type(second) == 'number' and second % 1 == 0 then return true end
			if length == 2 and type(first) == 'number' and first >= 0 and first <= 10 and type(second) == 'number' and second % 1 == 0 then return true end
			return false
		end
		local patched = 0
		local function patchTable(tbl)
			if type(tbl) ~= 'table' or isfrozen(tbl) or getmetatable(tbl) ~= nil then return end
			if rawget(tbl, selfKey) ~= tbl or rawget(tbl, indexKey) ~= indexValue then return end
			local copy = clone(tbl)
			setmetatable(tbl, {
				__newindex = function(_, key, value)
					if not suspicious(value) then rawset(copy, key, value) end
				end,
				__index = function(_, key)
					return rawget(copy, key)
				end,
			})
			clear(tbl)
			patched += 1
		end
		for _, value in ipairs(objects) do
			if type(value) == 'function' and info(value, 's') == sourceName then
				for _, upvalue in pairs(getupvalues(value)) do patchTable(upvalue) end
			end
		end
		return patched > 0
	end)
	return ok and result == true
end
Runtime.GuardActive = runCompatibility()

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
	if type(callback) == 'function' then Runtime.Owned[#Runtime.Owned + 1] = callback end
end

local function newScreenGui(name)
	local parent
	if type(gethui) == 'function' then pcall(function() parent = gethui() end) end
	if not parent then parent = LocalPlayer:WaitForChild('PlayerGui') end
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local gui = Instance.new('ScreenGui')
	gui.Name = name
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999990
	gui.Parent = parent
	return trackGui(gui)
end

local sg = newScreenGui('BurmaldaHookFallenSurvival')
local hudGui = newScreenGui('BurmaldaHookFallenSurvivalStats')

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

local main = Instance.new('Frame', sg)
main.Name = 'Main'
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 621, 0, 542)
main.Visible = true
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 2
main.ClipsDescendants = true
local mainStroke = Instance.new('UIStroke', main)
mainStroke.Name = 'BurmaldaAccent'
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local header = Instance.new('Frame', main)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Theme.Inline
header.BorderSizePixel = 0
local title = Instance.new('TextLabel', header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = 'Burmalda.hook | Fallen Survival'
title.TextColor3 = Theme.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
local closeBtn = Instance.new('TextButton', header)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -30, 0, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = 'X'
closeBtn.TextColor3 = Theme.SubText
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16

local tabBar = Instance.new('Frame', main)
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 30)
tabBar.BackgroundColor3 = Theme.Inline
tabBar.BorderSizePixel = 0
local tabLayout = Instance.new('UIListLayout', tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 1)

local content = Instance.new('Frame', main)
content.Size = UDim2.new(1, 0, 1, -60)
content.Position = UDim2.new(0, 0, 0, 60)
content.BackgroundTransparency = 1

local tabButtons = {}
local tabFrames = {}
local Columns = {}
local tabWidth = math.floor((621 - (#Runtime.TabNames - 1)) / #Runtime.TabNames)
for i, name in ipairs(Runtime.TabNames) do
	local button = Instance.new('TextButton', tabBar)
	button.Name = name
	button.Size = UDim2.new(0, tabWidth, 1, 0)
	button.BackgroundColor3 = Theme.Element
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = Theme.SubText
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 12
	button.LayoutOrder = i
	tabButtons[name] = button
	local frame = Instance.new('ScrollingFrame', content)
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ScrollBarThickness = 4
	frame.ScrollingEnabled = true
	frame.Visible = i == 1
	tabFrames[name] = frame
	local columns = Instance.new('Frame', frame)
	columns.Size = UDim2.new(1, 0, 1, 0)
	columns.BackgroundTransparency = 1
	local left = Instance.new('Frame', columns)
	left.Size = UDim2.new(0.5, -6, 1, 0)
	left.Position = UDim2.new(0, 6, 0, 0)
	left.BackgroundTransparency = 1
	local right = Instance.new('Frame', columns)
	right.Size = UDim2.new(0.5, -6, 1, 0)
	right.Position = UDim2.new(0.5, 0, 0, 0)
	right.BackgroundTransparency = 1
	Columns[frame] = { Left = left, Right = right }
	button.MouseButton1Click:Connect(function()
		for _, tab in pairs(tabFrames) do tab.Visible = false end
		for _, btn in pairs(tabButtons) do btn.TextColor3 = Theme.SubText end
		frame.Visible = true
		button.TextColor3 = Theme.Accent
		if State.UIAnimations then
			frame.Position = UDim2.new(0, 14, 0, 0)
			pcall(function()
				local tween = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
				tween:Play()
			end)
		else
			frame.Position = UDim2.new(0, 0, 0, 0)
		end
	end)
end
tabButtons.COMBAT.TextColor3 = Theme.Accent

local function setUIAnimations(enabled)
	Runtime.UIAnimations = enabled == true
	for _, connection in ipairs(Runtime.AnimationConnections) do
		if connection and connection.Disconnect then pcall(connection.Disconnect, connection) end
	end
	table.clear(Runtime.AnimationConnections)
	if not Runtime.UIAnimations then
		main.Position = UDim2.new(0.5, 0, 0.5, 0)
		return
	end
	main.Position = UDim2.new(0.5, 0, 0.5, 18)
	pcall(function()
		local tween = TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0.5, 0) })
		tween:Play()
	end)
	for _, object in ipairs(sg:GetDescendants()) do
		if object:IsA('TextButton') then
			local base = object.BackgroundColor3 or Theme.Element
			Runtime.AnimationConnections[#Runtime.AnimationConnections + 1] = object.MouseEnter:Connect(function()
				pcall(function()
					local tween = TweenService:Create(object, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Theme.Border })
					tween:Play()
				end)
			end)
			Runtime.AnimationConnections[#Runtime.AnimationConnections + 1] = object.MouseLeave:Connect(function()
				pcall(function()
					local tween = TweenService:Create(object, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = base })
					tween:Play()
				end)
			end)
		end
	end
end

local activeSection = nil
local function section(parent, name)
	local holder = Instance.new('Frame', parent)
	holder.Size = UDim2.new(1, 0, 0, 25)
	holder.BackgroundColor3 = Theme.Inline
	holder.BorderSizePixel = 0
	local label = Instance.new('TextLabel', holder)
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
		if child:IsA('Frame') or child:IsA('TextButton') then count += 1 end
	end
	return UDim2.new(0, 0, 0, count * 30)
end

local function feature(tabName, column, label, key, callback)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new('Frame', parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new('TextLabel', row)
	text.Size = UDim2.new(1, -92, 1, 0)
	text.Position = UDim2.new(0, 8, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 12
	local button = Instance.new('TextButton', row)
	button.Size = UDim2.new(0, 76, 0, 20)
	button.Position = UDim2.new(1, -80, 0.5, -10)
	button.BackgroundColor3 = Theme.Inline
	button.BorderSizePixel = 0
	button.Text = State[key] == true and 'On' or 'Off'
	button.TextColor3 = State[key] == true and Theme.Green or Theme.SubText
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 11
	local handler = {
		Key = key,
		Set = function(_, value)
			State[key] = value == true
			button.Text = State[key] and 'On' or 'Off'
			local targetColor = State[key] and Theme.Green or Theme.SubText
			if State.UIAnimations then
				local ok = pcall(function()
					local tween = TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = targetColor })
					tween:Play()
				end)
				if not ok then button.TextColor3 = targetColor end
			else
				button.TextColor3 = targetColor
			end
			if type(callback) == 'function' then callback(State[key]) end
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
	local row = Instance.new('Frame', parent)
	row.Size = UDim2.new(1, 0, 0, 34)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new('TextLabel', row)
	text.Size = UDim2.new(1, -10, 0, 14)
	text.Position = UDim2.new(0, 8, 0, 2)
	text.BackgroundTransparency = 1
	text.Text = label .. ': ' .. tostring(State[key])
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 11
	local fill = Instance.new('Frame', row)
	fill.Size = UDim2.new(0, 0, 0, 6)
	fill.Position = UDim2.new(0, 8, 0, 22)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	local function apply(value)
		local number = math.clamp(tonumber(value) or State[key], minimum, maximum)
		State[key] = number
		text.Text = label .. ': ' .. tostring(math.floor(number * 100) / 100)
		fill.Size = UDim2.new((number - minimum) / (maximum - minimum), 0, 0, 6)
		if type(callback) == 'function' then callback(number) end
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
	local row = Instance.new('Frame', parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new('TextLabel', row)
	text.Size = UDim2.new(1, -100, 1, 0)
	text.Position = UDim2.new(0, 8, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 12
	local button = Instance.new('TextButton', row)
	button.Size = UDim2.new(0, 88, 0, 20)
	button.Position = UDim2.new(1, -92, 0.5, -10)
	button.BackgroundColor3 = Theme.Inline
	button.BorderSizePixel = 0
	button.Text = tostring(State[key])
	button.TextColor3 = Theme.SubText
	button.Font = Enum.Font.SourceSans
	button.TextSize = 11
	local index = 1
	for i, option in ipairs(options) do if option == State[key] then index = i end end
	local function apply(value)
		State[key] = value
		button.Text = tostring(value)
		if type(callback) == 'function' then callback(value) end
	end
	ConfigControls[key] = apply
	button.MouseButton1Click:Connect(function()
		index = index % #options + 1
		apply(options[index])
	end)
	return row
end

local function bind(tabName, column, label, key)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new('Frame', parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	local text = Instance.new('TextLabel', row)
	text.Size = UDim2.new(1, -100, 1, 0)
	text.Position = UDim2.new(0, 8, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Theme.Text
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Font = Enum.Font.SourceSans
	text.TextSize = 12
	local button = Instance.new('TextButton', row)
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
	ConfigControls[key .. 'Bind'] = apply
	button.MouseButton1Click:Connect(function()
		picking = true
		button.Text = '...'
		button.TextColor3 = Theme.Accent
	end)
	trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
		if not picking or processed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			apply(input.KeyCode.Name)
			picking = false
			button.TextColor3 = Theme.SubText
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			apply('RMB')
			picking = false
			button.TextColor3 = Theme.SubText
		end
	end))
	return row
end

local function button(tabName, column, label, callback)
	local parent = Columns[tabFrames[tabName]][column]
	local row = Instance.new('TextButton', parent)
	row.Size = UDim2.new(1, 0, 0, 28)
	row.Position = nextPosition(parent)
	row.BackgroundColor3 = Theme.Element
	row.BorderSizePixel = 0
	row.Text = label
	row.TextColor3 = Theme.Text
	row.Font = Enum.Font.SourceSansBold
	row.TextSize = 12
	row.MouseButton1Click:Connect(function()
		if type(callback) == 'function' then pcall(callback) end
	end)
	return row
end

local function newDrawing(kind, properties)
	local object
	if Drawing and type(Drawing.new) == 'function' then
		object = Drawing.new(kind)
		for key, value in pairs(properties) do object[key] = value end
		trackDrawing(object)
	end
	return object
end

local fovCircle = newDrawing('Circle', { Visible = false, Filled = false, Thickness = 1, NumSides = 64, Radius = State.AimFOVSize, Color = AimColours.White, ZIndex = 30 })
local targetLine = newDrawing('Line', { Visible = false, Thickness = 1, Color = Theme.Accent, ZIndex = 30 })
local manipulationMarker = newDrawing('Square', { Visible = false, Filled = false, Thickness = 2, Size = Vector2.new(14, 14), Color = EspColours.Red, ZIndex = 31 })
local hitscanMarker = newDrawing('Square', { Visible = false, Filled = false, Thickness = 2, Size = Vector2.new(10, 10), Color = EspColours.Yellow, ZIndex = 31 })

local function applyFOVCircle()
	if not fovCircle then return end
	local radius = State.AimFOVSize
	if State.AimDynamicFOV and Camera then radius = radius / math.max(Camera.FieldOfView / 70, 0.1) end
	fovCircle.Radius = radius
	fovCircle.Color = AimColours[State.AimFOVColour] or AimColours.White
	fovCircle.Visible = State.AimDrawFOV and not Runtime.Unloaded
end

local function newEspObject()
	local wrapper = {}
	local textDrawing, lineDrawing, boxDrawing, healthDrawing
	local textLabel, lineFrame, boxFrame, healthFrame
	local extraDrawings = {}
	local extraLabels = {}
	if Drawing and type(Drawing.new) == 'function' then
		textDrawing = newDrawing('Text', { Visible = false, Center = true, Outline = true, Font = 2, Size = 13, Color = Theme.Text, ZIndex = 20 })
		lineDrawing = newDrawing('Line', { Visible = false, Thickness = 1, Color = Theme.Text, ZIndex = 19 })
		boxDrawing = newDrawing('Square', { Visible = false, Filled = false, Thickness = 1, Color = Theme.Text, ZIndex = 18 })
		healthDrawing = newDrawing('Square', { Visible = false, Filled = true, Thickness = 1, Color = Theme.Green, ZIndex = 18 })
		for index = 1, 2 do
			extraDrawings[index] = newDrawing('Text', { Visible = false, Center = true, Outline = true, Font = 2, Size = 12, Color = Theme.Text, ZIndex = 20 })
		end
	else
		textLabel = Instance.new('TextLabel', sg)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Theme.Text
		textLabel.TextStrokeTransparency = 0
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextSize = 12
		textLabel.Visible = false
		lineFrame = Instance.new('Frame', sg)
		lineFrame.BackgroundColor3 = Theme.Text
		lineFrame.BorderSizePixel = 0
		lineFrame.Visible = false
		boxFrame = Instance.new('Frame', sg)
		boxFrame.BackgroundTransparency = 1
		boxFrame.BorderSizePixel = 0
		boxFrame.Visible = false
		healthFrame = Instance.new('Frame', sg)
		healthFrame.BackgroundColor3 = Theme.Green
		healthFrame.BorderSizePixel = 0
		healthFrame.Visible = false
		for index = 1, 2 do
			local label = Instance.new('TextLabel', sg)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.TextStrokeTransparency = 0
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 12
			label.Visible = false
			extraLabels[index] = label
		end
	end
	function wrapper.textShow(value, position, color)
		if Runtime.Unloaded then return end
		if textDrawing then
			textDrawing.Text = value
			textDrawing.Position = position
			textDrawing.Color = color or Theme.Text
			textDrawing.Visible = true
		elseif textLabel then
			textLabel.Text = value
			textLabel.Position = UDim2.new(0, position.X, 0, position.Y)
			textLabel.TextColor3 = color or Theme.Text
			textLabel.Visible = true
		end
	end
	function wrapper.lineShow(from, to, color)
		if Runtime.Unloaded then return end
		if lineDrawing then
			lineDrawing.From = from
			lineDrawing.To = to
			lineDrawing.Color = color or Theme.Text
			lineDrawing.Visible = true
		elseif lineFrame then
			local delta = to - from
			lineFrame.Size = UDim2.new(0, math.max(1, delta.Magnitude), 0, 1)
			lineFrame.Position = UDim2.new(0, from.X, 0, from.Y)
			lineFrame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			lineFrame.BackgroundColor3 = color or Theme.Text
			lineFrame.Visible = true
		end
	end
	function wrapper.boxShow(position, size, color)
		if Runtime.Unloaded then return end
		if boxDrawing then
			boxDrawing.Position = position - size / 2
			boxDrawing.Size = size
			boxDrawing.Color = color or Theme.Text
			boxDrawing.Visible = true
		elseif boxFrame then
			boxFrame.Size = UDim2.new(0, size.X, 0, size.Y)
			boxFrame.Position = UDim2.new(0, position.X - size.X / 2, 0, position.Y - size.Y / 2)
			boxFrame.BackgroundColor3 = color or Theme.Text
			boxFrame.Visible = true
		end
	end
	function wrapper.healthShow(position, size, color)
		if Runtime.Unloaded then return end
		if healthDrawing then
			healthDrawing.Position = position
			healthDrawing.Size = size
			healthDrawing.Color = color or Theme.Green
			healthDrawing.Visible = true
		elseif healthFrame then
			healthFrame.Size = UDim2.new(0, size.X, 0, size.Y)
			healthFrame.Position = UDim2.new(0, position.X, 0, position.Y)
			healthFrame.BackgroundColor3 = color or Theme.Green
			healthFrame.Visible = true
		end
	end
	function wrapper.extraShow(index, value, position, color)
		if Runtime.Unloaded then return end
		local drawing = extraDrawings[index]
		local label = extraLabels[index]
		if drawing then
			drawing.Text = value
			drawing.Position = position
			drawing.Color = color or Theme.Text
			drawing.Visible = true
		elseif label then
			label.Text = value
			label.Position = UDim2.new(0, position.X, 0, position.Y)
			label.TextColor3 = color or Theme.Text
			label.Visible = true
		end
	end
	function wrapper:Hide()
		if textDrawing then textDrawing.Visible = false end
		if lineDrawing then lineDrawing.Visible = false end
		if boxDrawing then boxDrawing.Visible = false end
		if healthDrawing then healthDrawing.Visible = false end
		if textLabel then textLabel.Visible = false end
		if lineFrame then lineFrame.Visible = false end
		if boxFrame then boxFrame.Visible = false end
		if healthFrame then healthFrame.Visible = false end
		for _, drawing in ipairs(extraDrawings) do if drawing then drawing.Visible = false end end
		for _, label in ipairs(extraLabels) do if label then label.Visible = false end end
	end
	function wrapper:Remove()
		for _, drawing in ipairs({ textDrawing, lineDrawing, boxDrawing, healthDrawing, extraDrawings[1], extraDrawings[2] }) do
			if drawing and drawing.Remove then pcall(drawing.Remove, drawing) end
			if drawing then Runtime.Drawings[drawing] = nil end
		end
		for _, gui in ipairs({ textLabel, lineFrame, boxFrame, healthFrame, extraLabels[1], extraLabels[2] }) do
			if gui and gui.Destroy then pcall(gui.Destroy, gui) end
		end
	end
	return wrapper
end

local function getRoot(model)
	if not model then return nil end
	return model:FindFirstChild('HumanoidRootPart') or model:FindFirstChild('Torso') or model.PrimaryPart
end

local function getHumanoid(model)
	if not model then return nil end
	return model:FindFirstChildOfClass('Humanoid')
end

local function getModelPosition(model)
	if not model then return nil end
	if model.PrimaryPart and model.PrimaryPart.Position then return model.PrimaryPart.Position end
	if model.GetPivot then
		local ok, pivot = pcall(model.GetPivot, model)
		if ok and pivot and pivot.Position then return pivot.Position end
	end
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA('BasePart') then return child.Position end
	end
	return nil
end

local function isDowned(humanoid)
	if not humanoid then return true end
	local ok, attribute = pcall(function() return humanoid:GetAttribute('Downed') end)
	if ok and attribute then return true end
	return humanoid.Health <= 0
end

local function isTeammate(player, check)
	if not check then return false end
	local character = player.Character
	local nameTag = character and character:FindFirstChild('NameTag')
	if nameTag and nameTag.AlwaysOnTop then return true end
	if LocalPlayer.Team and player.Team then return player.Team == LocalPlayer.Team end
	return false
end

local function isVisible(point, model)
	if not Camera then return true end
	local origin = Camera.CFrame.Position
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { LocalPlayer.Character, model }
	local result = Workspace:Raycast(origin, point - origin, params)
	return result == nil
end

local function predictedPosition(root)
	if not State.AimPrediction or not root or not Camera then return root and root.Position or nil end
	local velocity = root.AssemblyLinearVelocity or Vector3.new()
	local distance = (root.Position - Camera.CFrame.Position).Magnitude
	local time = distance / math.max(State.AimBulletSpeed, 1)
	return root.Position + velocity * time
end

local function getTargetPart(character)
	local partName = State.AimHitPart
	if partName == 'Head' then return character:FindFirstChild('Head')
	elseif partName == 'Torso' then return character:FindFirstChild('UpperTorso') or character:FindFirstChild('Torso')
	elseif partName == 'Root' then return getRoot(character)
	elseif partName == 'Random' then
		local parts = { character:FindFirstChild('Head'), character:FindFirstChild('UpperTorso'), getRoot(character) }
		return parts[math.random(1, #parts)]
	end
	return getRoot(character)
end

local function getTargets()
	local list = {}
	local function addPlayer(player)
		if player == LocalPlayer then return end
		if not State.ScorpionTargetTeammates and isTeammate(player, State.AimTeamCheck) then return end
		local character = player.Character
		if not character or not getRoot(character) then return end
		local humanoid = getHumanoid(character)
		if isDowned(humanoid) and State.ScorpionDownCheck then return end
		list[#list + 1] = { Player = player, Character = character, Model = character }
	end
	if Players.GetPlayers then
		for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end
	else
		for _, player in ipairs(Players:GetChildren()) do addPlayer(player) end
	end
	if State.AimTargetNPCs then
		local military = Workspace:FindFirstChild('Military')
		local events = Workspace:FindFirstChild('Events')
		local animals = Workspace:FindFirstChild('Animals')
		for _, folder in ipairs({ military, events, animals }) do
			if folder then
				for _, model in ipairs(folder:GetDescendants()) do
					if model:IsA('Model') and NpcSettings[model.Name] and getRoot(model) then
						local humanoid = getHumanoid(model)
						if not isDowned(humanoid) then list[#list + 1] = { Player = model, Character = model, Model = model, NPC = true } end
					end
				end
			end
		end
	end
	return list
end

local function getAimTarget()
	if not Camera or not Mouse then return nil end
	local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
	local best, bestScore = nil, math.huge
	for _, entry in ipairs(getTargets()) do
		local part = getTargetPart(entry.Character)
		if part then
			local position = predictedPosition(part)
			if position then
				local screen, visible = Camera:WorldToViewportPoint(position)
				if visible then
					local distance2 = (Vector2.new(screen.X, screen.Y) - mousePosition).Magnitude
					local worldDistance = (position - Camera.CFrame.Position).Magnitude
					if distance2 <= State.AimFOV and worldDistance <= State.AimRange then
						if not State.AimVisibleCheck or not State.AimWallCheck or isVisible(position, entry.Model) then
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

local function updateAim()
	if Runtime.Unloaded or not Camera then return end
	applyFOVCircle()
	if not State.SilentAim or Runtime.MenuOpen then
		if targetLine then targetLine.Visible = false end
		if manipulationMarker then manipulationMarker.Visible = false end
		if hitscanMarker then hitscanMarker.Visible = false end
		return
	end
	local target = getAimTarget()
	if not target or math.random(0, 99) >= State.AimHitchance then
		if targetLine then targetLine.Visible = false end
		if manipulationMarker then manipulationMarker.Visible = false end
		if hitscanMarker then hitscanMarker.Visible = false end
		return
	end
	if manipulationMarker then
		manipulationMarker.Visible = State.AimManipulationIndicator and State.AimManipulation
		if manipulationMarker.Visible then
			manipulationMarker.Position = target.Screen
			manipulationMarker.Color = espColour('AimManipulationIndicatorColour', EspColours.Red)
		end
	end
	if hitscanMarker then
		hitscanMarker.Visible = State.AimHitscanIndicator and State.AimHitscan
		if hitscanMarker.Visible then
			hitscanMarker.Position = target.Screen
			hitscanMarker.Color = espColour('AimHitscanIndicatorColour', EspColours.Yellow)
		end
	end
	local smoothing = State.AimSmoothing
	if State.AimForceHit or State.AimHitscan then smoothing = 1 end
	if State.AimManipulation then smoothing = math.max(smoothing, 2) end
	local current = Camera.CFrame
	local direction = (target.Position - current.Position).Unit
	local blended = current.LookVector + (direction - current.LookVector) * math.clamp(1 / math.max(smoothing, 1), 0.01, 1)
	Camera.CFrame = CFrame.new(current.Position, current.Position + blended)
	if targetLine and State.AimSnapline then
		targetLine.From = Vector2.new(Mouse.X, Mouse.Y)
		targetLine.To = target.Screen
		targetLine.Color = espColour('AimSnaplineColour', AimColours.White)
		targetLine.Visible = true
	elseif targetLine then
		targetLine.Visible = false
	end
end

local function drawEntry(model, label, color, position, settings, maxDistance)
	if not position or not Camera then return end
	local screen, visible = Camera:WorldToViewportPoint(position)
	if not visible then return end
	local distance = (position - Camera.CFrame.Position).Magnitude
	if distance > maxDistance then return end
	local object = EspObjects[model]
	if not object then
		object = newEspObject()
		EspObjects[model] = object
	end
	local text = ''
	if settings.Names then text = label end
	if settings.Health then
		local humanoid = getHumanoid(model)
		if humanoid then text = text .. NL .. 'HP ' .. tostring(math.floor(humanoid.Health)) end
	end
	local screenPoint = Vector2.new(screen.X, screen.Y)
	object.textShow(text, screenPoint, settings.NameColour or color)
	if settings.Boxes then
		local size = Vector2.new(40, 60 * math.clamp(300 / math.max(distance, 1), 0.4, 2))
		object.boxShow(screenPoint, size, settings.BoxColour or color)
	end
	if settings.Health then
		local humanoid = getHumanoid(model)
		if humanoid and humanoid.MaxHealth > 0 then
			local ratio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			object.healthShow(screenPoint + Vector2.new(-24, 30), Vector2.new(3, 60 * ratio), Theme.Green)
		end
	end
	if settings.Distance then
		object.extraShow(1, tostring(math.floor(distance)) .. 'm', screenPoint + Vector2.new(0, 14), settings.DistanceColour or color)
	end
	if settings.Weapon then
		local tool = model:FindFirstChildOfClass('Tool') or model:FindFirstChild('Tool')
		if tool then object.extraShow(2, tool.Name, screenPoint + Vector2.new(0, 28), settings.WeaponColour or color) end
	end
	if settings.Tracers then
		object.lineShow(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), screenPoint, settings.TracerColour or color)
	end
end

local function updateESP()
	if Runtime.Unloaded or not Camera then return end
	for _, object in pairs(EspObjects) do object:Hide() end
	local playerSettings = {
		Names = State.PlayerNames, Boxes = State.PlayerBoxes, Health = State.PlayerHealth,
		Distance = State.PlayerDistance, Weapon = State.PlayerWeapon, Tracers = State.PlayerTracers,
		NameColour = espColour('PlayerNameColour', Theme.Text),
		BoxColour = espColour('PlayerBoxColour', Theme.Text),
		DistanceColour = espColour('PlayerDistanceColour', Theme.Text),
		WeaponColour = espColour('PlayerWeaponColour', Theme.Text),
		TracerColour = espColour('PlayerBoxColour', Theme.Text),
	}
	if State.PlayerESP then
		local players = Players.GetPlayers and Players:GetPlayers() or Players:GetChildren()
		for _, player in ipairs(players) do
			if player ~= LocalPlayer and player.Character and not isTeammate(player, State.PlayerTeamCheck) then
				local root = getRoot(player.Character)
				if root then
					local color = Theme.Text
					if State.TeamColors and player.Team and LocalPlayer.Team then color = player.Team == LocalPlayer.Team and Theme.Green or Theme.Red end
					drawEntry(player.Character, player.Name, color, root.Position, playerSettings, State.ESPRange)
				end
			end
		end
	end
	local npcSettings = { Names = State.NPCNames, Boxes = State.NPCBoxes, Health = State.NPCHealth, Distance = State.NPCDistance, Tracers = false }
	if State.NPCESP then
		local folders = { Workspace:FindFirstChild('Military'), Workspace:FindFirstChild('Events'), Workspace:FindFirstChild('Animals') }
		for _, folder in ipairs(folders) do
			if folder then
				for _, model in ipairs(folder:GetDescendants()) do
					local setting = NpcSettings[model.Name]
					if setting and State[setting.Flag] and model:IsA('Model') then
						drawEntry(model, setting.Label, espColour(setting.Colour, setting.Color), getModelPosition(model), npcSettings, State.NPCMaxDistance)
					end
				end
			end
		end
	end
	local entitySettings = { Names = State.EntityNames, Boxes = State.EntityBoxes, Distance = State.EntityDistance, Tracers = State.EntityTracers, Health = false, Weapon = false }
	if State.EntityESP then
		local folders = { Workspace:FindFirstChild('Nodes'), Workspace:FindFirstChild('Plants'), Workspace:FindFirstChild('Drops') }
		local bases = Workspace:FindFirstChild('Bases')
		if bases then
			local loners = bases:FindFirstChild('Loners')
			if loners then table.insert(folders, loners) end
		end
		for _, folder in ipairs(folders) do
			if folder then
				for _, model in ipairs(folder:GetDescendants()) do
					local setting = EntitySettings[model.Name]
					if setting and State[setting.Flag] then
						drawEntry(model, setting.Label, espColour(setting.Colour, setting.Color), getModelPosition(model), entitySettings, State.EntityMaxDistance)
					end
				end
			end
		end
	end
end

local function updateESPThrottled(dt)
	local rate = State.LowPC and 8 or State.ESPUpdateRate
	espAccumulator += dt or 0
	if espAccumulator < 1 / math.max(rate, 1) then return end
	espAccumulator = 0
	updateESP()
end

local function setFullBright(enabled)
	if enabled then
		if OriginalLighting.Brightness == nil then OriginalLighting.Brightness = Lighting.Brightness end
		if OriginalLighting.Ambient == nil then OriginalLighting.Ambient = Lighting.Ambient end
		if OriginalLighting.OutdoorAmbient == nil then OriginalLighting.OutdoorAmbient = Lighting.OutdoorAmbient end
		if OriginalLighting.ClockTime == nil then OriginalLighting.ClockTime = Lighting.ClockTime end
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
		if OriginalLighting.FogEnd == nil then OriginalLighting.FogEnd = Lighting.FogEnd end
		if OriginalLighting.FogStart == nil then OriginalLighting.FogStart = Lighting.FogStart end
		if OriginalLighting.FogColor == nil then OriginalLighting.FogColor = Lighting.FogColor end
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
	else
		if OriginalLighting.FogEnd ~= nil then Lighting.FogEnd = OriginalLighting.FogEnd end
		if OriginalLighting.FogStart ~= nil then Lighting.FogStart = OriginalLighting.FogStart end
		if OriginalLighting.FogColor ~= nil then Lighting.FogColor = OriginalLighting.FogColor end
	end
end

local function applyAmbient()
	if State.Ambient then
		if OriginalLighting.Ambient == nil then OriginalLighting.Ambient = Lighting.Ambient end
		Lighting.Ambient = AmbientColours[State.AmbientColour] or AmbientColours.White
	elseif OriginalLighting.Ambient ~= nil then
		Lighting.Ambient = OriginalLighting.Ambient
	end
end

local function applyTerrainDecoration()
	if not Workspace.Terrain or OriginalTerrainDecoration == nil then return end
	if State.RemoveGrass or State.LowPC then
		Workspace.Terrain.Decoration = false
	else
		Workspace.Terrain.Decoration = OriginalTerrainDecoration
	end
end

local function setGrass(enabled)
	if not Workspace.Terrain then return end
	applyTerrainDecoration()
	if enabled then
		for _, object in ipairs(Workspace:GetDescendants()) do
			if GrassLookup[object.Name] and object:IsA('BasePart') then
				if OriginalGrass[object] == nil then OriginalGrass[object] = object.LocalTransparencyModifier end
				object.LocalTransparencyModifier = 1
			end
		end
		if type(setfflag) == 'function' then
			pcall(setfflag, 'FRMMinGrassDistance', '-1')
			pcall(setfflag, 'FRMMaxGrassDistance', '-1')
		end
	elseif next(OriginalGrass) ~= nil then
		for object, value in pairs(OriginalGrass) do
			if object.Parent then object.LocalTransparencyModifier = value end
		end
		table.clear(OriginalGrass)
		if type(setfflag) == 'function' then
			pcall(setfflag, 'FRMMinGrassDistance', '100')
			pcall(setfflag, 'FRMMaxGrassDistance', '290')
		end
	end
end

local function setLowPC(enabled)
	if enabled then
		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA('PostEffect') or effect:IsA('BloomEffect') or effect:IsA('SunRaysEffect') or effect:IsA('DepthOfFieldEffect') then
				if OriginalEffects[effect] == nil then OriginalEffects[effect] = effect.Enabled end
				effect.Enabled = false
			end
		end
		applyTerrainDecoration()
	elseif next(OriginalEffects) ~= nil then
		for effect, value in pairs(OriginalEffects) do
			pcall(function() effect.Enabled = value end)
		end
		table.clear(OriginalEffects)
		applyTerrainDecoration()
	end
end

local function applyXRay()
	local bases = Workspace:FindFirstChild('Bases')
	if State.XRay and bases then
		for _, part in ipairs(bases:GetDescendants()) do
			if part:IsA('BasePart') and BuildingLookup[part.Parent and part.Parent.Name or ''] then
				if OriginalXRay[part] == nil then OriginalXRay[part] = part.LocalTransparencyModifier end
				part.LocalTransparencyModifier = State.XRayTransparency / 100
			end
		end
	elseif next(OriginalXRay) ~= nil then
		for part, value in pairs(OriginalXRay) do
			if part.Parent then part.LocalTransparencyModifier = value end
		end
		table.clear(OriginalXRay)
	end
end

local function applyTraps()
	local bases = Workspace:FindFirstChild('Bases')
	if State.DisableTraps and bases then
		for _, part in ipairs(bases:GetDescendants()) do
			if part:IsA('BasePart') and (TrapLookup[part.Name] or TrapLookup[part.Parent and part.Parent.Name or '']) then
				if OriginalTraps[part] == nil then OriginalTraps[part] = part.CanTouch end
				part.CanTouch = false
			end
		end
	elseif next(OriginalTraps) ~= nil then
		for part, value in pairs(OriginalTraps) do
			if part.Parent then part.CanTouch = value end
		end
		table.clear(OriginalTraps)
	end
end

local function applySpikes()
	local bases = Workspace:FindFirstChild('Bases')
	if State.DisableSpikes and bases then
		for _, part in ipairs(bases:GetDescendants()) do
			if part:IsA('BasePart') and (SpikeLookup[part.Name] or SpikeLookup[part.Parent and part.Parent.Name or '']) then
				if OriginalSpikes[part] == nil then OriginalSpikes[part] = part.CanTouch end
				part.CanTouch = false
			end
		end
	elseif next(OriginalSpikes) ~= nil then
		for part, value in pairs(OriginalSpikes) do
			if part.Parent then part.CanTouch = value end
		end
		table.clear(OriginalSpikes)
	end
end

local function applyChams()
	local character = LocalPlayer.Character
	if State.Chams and character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA('BasePart') then
				if OriginalChams[part] == nil then OriginalChams[part] = { Color = part.Color, Transparency = part.Transparency, Material = part.Material } end
				part.Color = ChamsColours[State.ChamsColour] or ChamsColours.White
				part.Transparency = State.ChamsTransparency / 100
				part.Material = ChamsMaterials[State.ChamsMaterial] or Enum.Material.ForceField
			end
		end
	elseif next(OriginalChams) ~= nil then
		for part, value in pairs(OriginalChams) do
			if part.Parent then
				part.Color = value.Color
				part.Transparency = value.Transparency
				part.Material = value.Material
			end
		end
		table.clear(OriginalChams)
	end
end

local function applyFOV()
	if not Camera then return end
	if State.Zoom then
		Camera.FieldOfView = State.ZoomFOV
	elseif State.CustomFOV then
		Camera.FieldOfView = State.FOVValue
	else
		Camera.FieldOfView = OriginalFOV
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
	if not State.TeleportMouse or not Mouse then return end
	local root = getRoot(LocalPlayer.Character)
	if not root then return end
	local target = Mouse.Hit and Mouse.Hit.Position or nil
	if target then root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0)) end
end

local function respawn()
	local humanoid = getHumanoid(LocalPlayer.Character)
	if humanoid then humanoid.Health = 0 end
end

local function updateMovement(dt)
	if Runtime.Unloaded then return end
	local character = LocalPlayer.Character
	local root = getRoot(character)
	local humanoid = getHumanoid(character)
	if not root or not humanoid or not Camera then return end
	humanoid.WalkSpeed = State.Speed and State.SpeedValue or OriginalWalkSpeed
	if State.Fly and not State.Freecam then
		local direction = Vector3.new()
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
		if direction.Magnitude > 0 then root.AssemblyLinearVelocity = direction.Unit * State.FlySpeed else root.AssemblyLinearVelocity = Vector3.new() end
	end
	if State.Noclip then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA('BasePart') then
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
	if State.UndergroundAntiAim then
		if not antiAimOriginal then antiAimOriginal = root.CFrame end
		root.CFrame = antiAimOriginal + Vector3.new(0, -State.AntiAimDepth, 0)
	elseif antiAimOriginal then
		root.CFrame = antiAimOriginal
		antiAimOriginal = nil
	end
	if State.NoFallDamage and root.AssemblyLinearVelocity.Y < -60 then
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)
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

local function restoreMovement()
	local character = LocalPlayer.Character
	if character then
		local root = getRoot(character)
		local humanoid = getHumanoid(character)
		if humanoid then
			humanoid.WalkSpeed = OriginalWalkSpeed
			if humanoid.UseJumpPower then humanoid.JumpPower = OriginalJumpPower else humanoid.JumpHeight = OriginalJumpHeight end
		end
		for part, value in pairs(noclipParts) do
			if part.Parent then part.CanCollide = value end
		end
		table.clear(noclipParts)
		if antiAimOriginal and root then root.CFrame = antiAimOriginal end
	end
	antiAimOriginal = nil
	Workspace.Gravity = OriginalGravity
	if Camera then
		Camera.CameraType = OriginalCameraType or Enum.CameraType.Custom
		Camera.CameraSubject = OriginalCameraSubject
		if OriginalCameraCFrame then Camera.CFrame = OriginalCameraCFrame end
		Camera.FieldOfView = OriginalFOV
	end
end

local hudLabel = Instance.new('TextLabel', hudGui)
hudLabel.Name = 'StatsHUD'
hudLabel.Size = UDim2.new(0, 240, 0, 58)
hudLabel.Position = UDim2.new(0, 8, 0, 8)
hudLabel.BackgroundTransparency = 1
hudLabel.TextColor3 = Theme.Text
hudLabel.TextStrokeTransparency = 0
hudLabel.TextXAlignment = Enum.TextXAlignment.Left
hudLabel.TextYAlignment = Enum.TextYAlignment.Top
hudLabel.Font = Enum.Font.SourceSansBold
hudLabel.TextSize = 12
hudLabel.Visible = State.StatsHUD

local function updateHUD()
	if Runtime.Unloaded then return end
	hudLabel.Visible = (State.StatsHUD or State.TargetHUD) and true or false
	if not hudLabel.Visible then return end
	local fps = 0
	if Workspace.GetRealPhysicsFPS then
		local ok, value = pcall(Workspace.GetRealPhysicsFPS, Workspace)
		if ok and type(value) == 'number' then fps = math.floor(value) end
	end
	local ping = 0
	if StatsService and StatsService.Network and StatsService.Network.ServerStatsItem and StatsService.Network.ServerStatsItem['Data Ping'] then
		local ok, value = pcall(function() return StatsService.Network.ServerStatsItem['Data Ping']:GetValue() end)
		if ok then ping = math.floor(tonumber(value) or 0) end
	end
	local speed = math.floor(State.Speed and State.SpeedValue or OriginalWalkSpeed)
	hudLabel.Text = string.format('Burmalda.hook | Fallen Survival%sFPS %d | Ping %d | Speed %d | %s', NL, fps, ping, speed, executorName)
end

local function guardedStep(name, callback, dt)
	if Runtime.Unloaded or type(callback) ~= 'function' then return end
	local ok, err = pcall(callback, dt)
	if not ok then Runtime.LastError = name .. ': ' .. tostring(err) end
end

local renderConnection
renderConnection = trackConnection(RunService.RenderStepped:Connect(function(dt)
	if Runtime.Unloaded or not Runtime.Ready then return end
	Camera = Workspace.CurrentCamera or Camera
	if not Camera then return end
	guardedStep('Aim', updateAim, dt)
	guardedStep('ESP', updateESPThrottled, dt)
	guardedStep('Movement', updateMovement, dt)
	guardedStep('HUD', updateHUD, dt)
end))

local function toggleMenu()
	Runtime.MenuOpen = not Runtime.MenuOpen
	main.Visible = Runtime.MenuOpen
end

local function saveConfig()
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, { State = State, Binds = Binds })
	if not ok or type(writefile) ~= 'function' then return false end
	if type(makefolder) == 'function' then pcall(makefolder, 'burmalda') end
	return pcall(writefile, configPath(), encoded)
end

local function loadConfig()
	if type(isfile) ~= 'function' or type(readfile) ~= 'function' then return false end
	if not isfile(configPath()) then return false end
	local readOk, raw = pcall(readfile, configPath())
	if not readOk then return false end
	local decodedOk, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
	if not decodedOk or type(decoded) ~= 'table' then return false end
	local loadedState = type(decoded.State) == 'table' and decoded.State or decoded
	local loadedBinds = type(decoded.Binds) == 'table' and decoded.Binds or decoded
	for key, value in pairs(loadedState) do
		if State[key] ~= nil and type(State[key]) == type(value) then State[key] = value end
	end
	for key, value in pairs(Binds) do
		if loadedBinds[key] ~= nil then Binds[key] = loadedBinds[key]
		elseif loadedBinds[key .. 'Bind'] ~= nil then Binds[key] = loadedBinds[key .. 'Bind'] end
	end
	return true
end

local function deleteConfig()
	if type(isfile) == 'function' and isfile(configPath()) and type(delfile) == 'function' then pcall(delfile, configPath()) end
end

local function syncUI()
	for _, handler in pairs(FeatureHandlers) do
		if handler.Key then handler:Set(State[handler.Key]) end
	end
	for key, apply in pairs(ConfigControls) do
		if State[key] ~= nil then apply(State[key]) end
	end
	for key, value in pairs(Binds) do
		local apply = ConfigControls[key .. 'Bind']
		if apply then apply(value) end
	end
	applyFOVCircle()
	applyFOV()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Scorpion = {}
Runtime.Scorpion = Scorpion

local dbg = {}
do
	local d = debug
	if type(d) == "table" then
		dbg.traceback = d.traceback
		dbg.info = d.info
		dbg.getupvalues = d.getupvalues
		dbg.getconstants = d.getconstants
		dbg.setconstant = d.setconstant
		dbg.getstack = d.getstack
		dbg.setstack = d.setstack
	end
end
Scorpion.dbg = dbg

local hookFunction = type(hookfunction) == "function" and hookfunction or nil
local getConnections = type(getconnections) == "function" and getconnections or nil
local getSenv = type(getsenv) == "function" and getsenv or nil
local setHidden = type(sethiddenproperty) == "function" and sethiddenproperty or nil
local setFFlag = type(setfflag) == "function" and setfflag or nil
local setReadonly = type(setreadonly) == "function" and setreadonly or nil
local isValidLevel = type(isvalidlevel) == "function" and isvalidlevel or nil
local getStack = type(getstack) == "function" and getstack or nil
local setStack = type(setstack) == "function" and setstack or nil
local cloneRef = type(cloneref) == "function" and cloneref or nil
local getHui = type(gethui) == "function" and gethui or nil

local coreGui = cloneRef and cloneRef(game:GetService("CoreGui")) or game:GetService("CoreGui")
local uiParent = nil
if getHui then pcall(function() uiParent = getHui() end) end
if not uiParent then uiParent = coreGui end

Scorpion.UndetectedGui = function(gui)
	if not gui then return end
	pcall(function()
		gui.Name = "\0"
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 999999
		gui.Parent = uiParent
	end)
end

for _, gui in pairs(Runtime.Guis or {}) do Scorpion.UndetectedGui(gui) end

local function trace()
	if not dbg.traceback then return "" end
	local ok, value = pcall(dbg.traceback)
	return ok and type(value) == "string" and value or ""
end
Scorpion.Trace = trace

local originals = {}
Scorpion.Originals = originals

local function hook(target, replacement)
	if not hookFunction or type(target) ~= "function" then return nil end
	local ok, original = pcall(hookFunction, target, replacement)
	if ok and type(original) == "function" then return original end
	return nil
end

local Modules = ReplicatedStorage:FindFirstChild("Modules")
if Modules then
	local ItemClass = Modules:FindFirstChild("ItemClass")
	if ItemClass then
		local ok, class = pcall(require, ItemClass)
		if ok and type(class) == "table" and type(class.AttachmentStats) == "function" then
			local original = class.AttachmentStats
			class.AttachmentStats = function(...)
				local result = original(...)
				if State.ScorpionGunMods and result and trace():find("ViewmodelController", 1, true) then
					if State.ScorpionNoRecoil then result.RecoilMult = -1 end
					if State.ScorpionNoSway then result.SwayMult = -1 end
					if State.ScorpionRPM then result.FireRateMult = State.ScorpionRPMValue - 1 end
					if State.ScorpionInstantBullet then result.SpeedMult = 100 end
					if State.ScorpionRangeMult then result.RangeMult = State.ScorpionRangeAmount end
				end
				return result
			end
			originals.ItemClass = { class, "AttachmentStats", original }
		end
	end
	local RaycastModule = Modules:FindFirstChild("RaycastUtil")
	if RaycastModule then
		local ok, util = pcall(require, RaycastModule)
		if ok and type(util) == "table" and type(util.Raycast) == "function" then
			local original = hook(util.Raycast, function(...)
				local output = { original(...) }
				if State.ScorpionPerfectFarm and trace():find("ViewmodelController", 1, true) then
					local hit, position = output[1], output[2]
					if typeof(hit) == "Instance" and typeof(position) == "Vector3" then
						local model = hit.Parent
						if model and model:IsA("Model") then
							local folder = model.Parent
							if folder and folder:IsA("Folder") and (folder.Name == "Trees" or folder.Name == "Nodes") then
								local critical = model:FindFirstChild("NodeSpark") or model:FindFirstChild("TreeX")
								if critical and critical:IsA("Model") and critical.PrimaryPart then output[1] = critical.PrimaryPart end
							end
						end
					end
				end
				return unpack(output)
			end)
			if original then originals.RaycastUtil = { util, "Raycast", original } end
		end
	end
end

local quickStack = {}
Scorpion.QuickStack = quickStack

local function attachCharacter(character)
	if not character then return end
	task.spawn(function()
		task.wait(1)
		if Runtime.Unloaded then return end
		local vmc = character:FindFirstChild("ViewmodelController")
		if vmc and getSenv then
			local ok, environment = pcall(getSenv, vmc)
			if ok and type(environment) == "table" and type(environment.ChooseRandom) == "function" then
				local original = environment.ChooseRandom
				environment.ChooseRandom = function(...)
					if State.ScorpionInstantEoka then return 0 end
					return original(...)
				end
				originals.ChooseRandom = { environment, "ChooseRandom", original }
			end
		end
		local inventory = character:FindFirstChild("InventoryController")
		local equip = inventory and inventory:FindFirstChild("EquipArmor")
		if equip and getConnections and dbg.getupvalues and dbg.getconstants and dbg.setconstant then
			local ok, connections = pcall(getConnections, equip.Event)
			if ok and type(connections) == "table" then
				for _, connection in ipairs(connections) do
					local fn = connection.Function
					if type(fn) ~= "function" then continue end
					local okUp, upvalues = pcall(dbg.getupvalues, fn)
					if not okUp or type(upvalues) ~= "table" then continue end
					for _, candidate in ipairs(upvalues) do
						if type(candidate) ~= "function" then continue end
						local okConst, constants = pcall(dbg.getconstants, candidate)
						if not okConst or type(constants) ~= "table" then continue end
						if constants[1] == "ArmorEquip" and constants[5] == "GetAttribute" then
							quickStack[#quickStack + 1] = candidate
						end
					end
				end
			end
		end
		Scorpion.ApplyQuickStack()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and getConnections and hookFunction and dbg.info then
			local ok, connections = pcall(getConnections, humanoid.StateChanged)
			if ok and type(connections) == "table" then
				for _, connection in ipairs(connections) do
					local fn = connection.Function
					if type(fn) ~= "function" then continue end
					local okInfo, source = pcall(dbg.info, fn, "s")
					if okInfo and type(source) == "string" and source:find("ViewmodelController", 1, true) then
						local original = hook(fn, function(...)
							if State.ScorpionFlyRestrictions then return end
							if original then return original(...) end
						end)
						if not original then continue end
					end
				end
			end
		end
	end)
end
Scorpion.AttachCharacter = attachCharacter

Scorpion.ApplyQuickStack = function()
	if not dbg.setconstant then return end
	for _, fn in ipairs(quickStack) do
		pcall(function()
			dbg.setconstant(fn, 19, State.ScorpionInstantLoot and 0 or 0.9)
			dbg.setconstant(fn, 20, State.ScorpionInstantLoot and 0 or 0.3)
			dbg.setconstant(fn, 21, State.ScorpionInstantLoot and 0 or 0.1)
		end)
	end
end

if setReadonly and dbg.traceback then
	pcall(function()
		local originalAbs = math.abs
		setReadonly(math, false)
		math.abs = function(value)
			if State.ScorpionNoBob and trace():find("ViewmodelController", 1, true) then
				for level = 2, 4 do
					if isValidLevel and isValidLevel(level) then
						local stack = getStack and getStack(level)
						local candidate = stack and stack[2]
						if type(candidate) == "boolean" and setStack then setStack(level, 2, true) end
					end
				end
			end
			return originalAbs(value)
		end
		setReadonly(math, true)
		originals.MathAbs = originalAbs
	end)
end

local SoundService = game:GetService("SoundService")
local hitSounds = {
	Minecraft = "73369656122118", Telegram = "6696469190", ["Rust Headshot"] = "127036469955037",
	["CSGO Kill"] = "7269900245", ["Minecraft Bow"] = "72656167409567", ["CSGO Headshot"] = "93671116663771",
	["Minecraft XP"] = "101023147710668", ["Minecraft Drop"] = "90752223133261",
	["Fortnite Headshot"] = "136947670419465", Gamesense = "4817809188", Primordial = "97511223764004",
}
Scorpion.HitSounds = hitSounds
local soundPool = {}
for name, id in pairs(hitSounds) do
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Parent = SoundService
	soundPool[name] = sound
end
local shootSound = Instance.new("Sound")
shootSound.SoundId = "rbxassetid://116617548245274"
shootSound.Parent = SoundService

Scorpion.PlayHit = function()
	if not State.ScorpionHitSound then return end
	local sound = soundPool[State.ScorpionHitSoundName]
	if sound then
		sound.Volume = State.ScorpionHitSoundVolume / 100
		sound:Play()
	end
end
Scorpion.PlayShoot = function()
	if not State.ScorpionShootSound then return end
	shootSound.Volume = State.ScorpionShootVolume / 100
	shootSound:Play()
end

local tracerStyles = { "Default", "Obelus", "Lightning", "DNA", "Minecraft", "Beam", "Galaxy" }
Scorpion.TracerStyles = tracerStyles
local tracerTextures = {
	Default = "115789305736770", Obelus = "2382169232", Lightning = "7151778302",
	DNA = "7071778278", Minecraft = "301464986", Beam = "4494641460", Galaxy = "1120738433",
}
Scorpion.CreateTracer = function(origin, direction)
	if not State.ScorpionTracer then return end
	local attachmentA = Instance.new("Attachment")
	local attachmentB = Instance.new("Attachment")
	attachmentA.Position = origin
	attachmentB.Position = origin + direction * 300
	local beam = Instance.new("Beam")
	beam.Texture = "rbxassetid://" .. (tracerTextures[State.ScorpionTracerStyle] or tracerTextures.Default)
	beam.FaceCamera = true
	beam.Width0 = State.ScorpionTracerThickness / 100
	beam.Width1 = State.ScorpionTracerThickness / 100
	beam.LightEmission = 1
	beam.Attachment0 = attachmentA
	beam.Attachment1 = attachmentB
	local parent = Workspace.Terrain or Workspace
	beam.Parent = parent
	attachmentA.Parent = parent
	attachmentB.Parent = parent
	game:GetService("Debris"):AddItem(beam, State.ScorpionTracerDuration)
	game:GetService("Debris"):AddItem(attachmentA, State.ScorpionTracerDuration)
	game:GetService("Debris"):AddItem(attachmentB, State.ScorpionTracerDuration)
end

local VFX = Workspace:FindFirstChild("VFX")
if VFX then
	local okCreate, originalCreate = pcall(function() return VFX.CreateProjectile end)
	if okCreate and type(originalCreate) == "function" then
		VFX.CreateProjectile = function(self, ...)
			local args = { ... }
			if trace():find("ViewmodelController", 1, true) and type(args[1]) == "table" then
				local origin = args[1].Position or args[1].PositionFirst
				local direction = args[1].Direction or args[1].DirectionFirst
				if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
					Scorpion.PlayShoot()
					task.spawn(function() pcall(Scorpion.CreateTracer, origin, direction.Unit) end)
				end
			end
			return originalCreate(self, ...)
		end
		originals.CreateProjectile = { VFX, "CreateProjectile", originalCreate }
	end
	for _, name in ipairs({ "CreateBlood", "CreateHole" }) do
		local original = VFX[name]
		if type(original) == "function" then
			VFX[name] = function(self, hit, position, ...)
				if not trace():find("HitVFX", 1, true) then Scorpion.PlayHit() end
				return original(self, hit, position, ...)
			end
			originals[name] = { VFX, name, original }
		end
	end
end

Scorpion.ApplyAmbience = function()
	if not State.ScorpionAmbience then
		Lighting.Ambient = OriginalLighting.Ambient or Lighting.Ambient
		Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient or Lighting.OutdoorAmbient
		return
	end
	local color = EspColours[State.ScorpionAmbColour] or EspColours.White
	Lighting.Ambient = Color3.new(color.R * State.ScorpionAmbBrightness / 100, color.G * State.ScorpionAmbBrightness / 100, color.B * State.ScorpionAmbBrightness / 100)
	Lighting.OutdoorAmbient = Color3.new(color.R * State.ScorpionAmbIndoor / 100, color.G * State.ScorpionAmbIndoor / 100, color.B * State.ScorpionAmbIndoor / 100)
end

Scorpion.ApplyGrass = function()
	if not setFFlag then return end
	if State.RemoveGrass or State.ScorpionRemoveGrass then
		pcall(setFFlag, "FRMMinGrassDistance", "-1")
		pcall(setFFlag, "FRMMaxGrassDistance", "-1")
	else
		pcall(setFFlag, "FRMMinGrassDistance", "100")
		pcall(setFFlag, "FRMMaxGrassDistance", "290")
	end
end

Scorpion.ApplyGunChams = function()
	local enabled = State.ScorpionGunChams or State.ScorpionArmsChams
	local character = LocalPlayer.Character
	if not enabled then
		for part, saved in pairs(OriginalChams) do
			if part and part.Parent and saved and type(saved) == "table" and saved.Material then
				pcall(function() part.Material = saved.Material; part.Color = saved.Color end)
			end
		end
		return
	end
	if not character then return end
	local parts = {}
	if State.ScorpionGunChams then
		local tool = character:FindFirstChildOfClass("Tool")
		if tool then for _, part in ipairs(tool:GetDescendants()) do if part:IsA("BasePart") then parts[#parts + 1] = part end end end
	end
	if State.ScorpionArmsChams then
		for _, name in ipairs({ "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand" }) do
			local part = character:FindFirstChild(name)
			if part and part:IsA("BasePart") then parts[#parts + 1] = part end
		end
	end
	local material = Enum.Material[State.ScorpionGunMaterial] or Enum.Material.ForceField
	local color = EspColours[State.ScorpionGunColour] or EspColours.White
	for _, part in ipairs(parts) do
		if OriginalChams[part] == nil then OriginalChams[part] = { Color = part.Color, Material = part.Material } end
		part.Material = material
		part.Color = color
	end
end

Scorpion.ApplyFOV = function(dt)
	if not fovCircle then return end
	if State.ScorpionFovRainbow then
		local hue = (os.clock() * State.ScorpionFovRainbowSpeed / 5) % 1
		fovCircle.Color = Color3.fromHSV(hue, 0.7, 1)
	end
	if State.ScorpionFovRotate and not State.ScorpionFovRainbow then
		local hue = (os.clock() * State.ScorpionFovRotateSpeed / 5) % 1
		fovCircle.Color = Color3.fromHSV(hue, 0.35, 1)
	end
	if State.ScorpionFovFill then
		fovCircle.Filled = true
		fovCircle.Transparency = 1 - State.ScorpionFovFillTransparency / 100
	else
		fovCircle.Filled = false
		fovCircle.Transparency = 1
	end
	fovCircle.Thickness = State.ScorpionFovThickness
end

Scorpion.ApplyNetworkSleeping = function(root, active)
	if not setHidden or not root then return end
	pcall(setHidden, root, "NetworkIsSleeping", active == true)
end

Scorpion.Restore = function()
	for _, entry in pairs(originals) do
		if type(entry) == "table" and entry[1] and entry[2] and entry[3] then
			pcall(function() entry[1][entry[2]] = entry[3] end)
		end
	end
	if originals.MathAbs and setReadonly then
		pcall(function()
			setReadonly(math, false)
			math.abs = originals.MathAbs
			setReadonly(math, true)
		end)
	end
	if setFFlag then
		pcall(setFFlag, "FRMMinGrassDistance", "100")
		pcall(setFFlag, "FRMMaxGrassDistance", "290")
	end
	pcall(Scorpion.ApplyAmbience)
end

if LocalPlayer.Character then attachCharacter(LocalPlayer.Character) end
trackConnection(LocalPlayer.CharacterAdded:Connect(attachCharacter))
trackConnection(RunService.Heartbeat:Connect(function(dt)
	if Runtime.Unloaded then return end
	Scorpion.ApplyFOV(dt)
	if State.ScorpionAutoshoot and State.SilentAim and not Runtime.MenuOpen and type(mouse1click) == "function" then
		local ok, target = pcall(getAimTarget)
		if ok and target then pcall(mouse1click) end
	end
	if Scorpion.Watermark then
		pcall(function() Scorpion.Watermark.Visible = State.ScorpionWatermark == true end)
	end
end))

pcall(function()
	local label = Instance.new("TextLabel", sg)
	label.Name = "ScorpionWatermark"
	label.Size = UDim2.new(0, 180, 0, 20)
	label.Position = UDim2.new(1, -190, 0, 8)
	label.BackgroundTransparency = 1
	label.Text = "Burmalda.hook | Fallen Survival"
	label.TextColor3 = EspColours.White
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.Visible = false
	trackGui(label)
	Scorpion.Watermark = label
end)
onCleanup(function() Scorpion.Restore() end)


section(Columns[tabFrames.COMBAT].Left, 'Silent Aim')
feature('COMBAT', 'Left', 'Silent Aim', 'SilentAim')
slider('COMBAT', 'Left', 'FOV', 'AimFOV', 10, 1500)
slider('COMBAT', 'Left', 'Range', 'AimRange', 100, 3000)
slider('COMBAT', 'Left', 'Smoothing', 'AimSmoothing', 1, 30)
slider('COMBAT', 'Left', 'Hitchance', 'AimHitchance', 1, 100)
dropdown('COMBAT', 'Left', 'Hit Part', 'AimHitPart', HitParts)
slider('COMBAT', 'Left', 'Bullet Speed', 'AimBulletSpeed', 100, 3000)
feature('COMBAT', 'Left', 'Target NPCs', 'AimTargetNPCs')
feature('COMBAT', 'Left', 'Team Check', 'AimTeamCheck')
feature('COMBAT', 'Left', 'Visible Check', 'AimVisibleCheck')
feature('COMBAT', 'Left', 'Wall Check', 'AimWallCheck')
feature('COMBAT', 'Left', 'Prediction', 'AimPrediction')
bind('COMBAT', 'Left', 'Silent Aim Bind', 'SilentAim')

section(Columns[tabFrames.COMBAT].Right, 'Aim Extras')
feature('COMBAT', 'Right', 'Force Hit', 'AimForceHit')
slider('COMBAT', 'Right', 'Force Hit Dist', 'ForceHitDistance', 1, 20)
feature('COMBAT', 'Right', 'Manipulation', 'AimManipulation')
slider('COMBAT', 'Right', 'Manipulation Dist', 'ManipulationDistance', 1, 20)
feature('COMBAT', 'Right', 'Hitscan', 'AimHitscan')
slider('COMBAT', 'Right', 'Hitscan Dist', 'HitscanDistance', 1, 20)
feature('COMBAT', 'Right', 'Snapline', 'AimSnapline')
feature('COMBAT', 'Right', 'Draw FOV', 'AimDrawFOV', applyFOVCircle)
feature('COMBAT', 'Right', 'Dynamic FOV', 'AimDynamicFOV', applyFOVCircle)
slider('COMBAT', 'Right', 'FOV Size', 'AimFOVSize', 10, 1500, applyFOVCircle)
dropdown('COMBAT', 'Right', 'FOV Colour', 'AimFOVColour', { 'White', 'Green', 'Red' }, applyFOVCircle)
dropdown('COMBAT', 'Right', 'Snapline Colour', 'AimSnaplineColour', ColourNames)
feature('COMBAT', 'Right', 'Manipulation Indicator', 'AimManipulationIndicator')
dropdown('COMBAT', 'Right', 'Manipulation Ind Colour', 'AimManipulationIndicatorColour', ColourNames)
feature('COMBAT', 'Right', 'Hitscan Indicator', 'AimHitscanIndicator')
dropdown('COMBAT', 'Right', 'Hitscan Ind Colour', 'AimHitscanIndicatorColour', ColourNames)
feature('COMBAT', 'Right', 'Gun Mods', 'ScorpionGunMods')
feature('COMBAT', 'Right', 'No Recoil', 'ScorpionNoRecoil')
feature('COMBAT', 'Right', 'No Sway', 'ScorpionNoSway')
feature('COMBAT', 'Right', 'No Bob', 'ScorpionNoBob')
feature('COMBAT', 'Right', 'RPM', 'ScorpionRPM')
slider('COMBAT', 'Right', 'RPM Multiplier', 'ScorpionRPMValue', 1, 15)
feature('COMBAT', 'Right', 'Instant Bullet', 'ScorpionInstantBullet')
feature('COMBAT', 'Right', 'Range Multiplier', 'ScorpionRangeMult')
slider('COMBAT', 'Right', 'Range Amount', 'ScorpionRangeAmount', 1, 20)
feature('COMBAT', 'Right', 'Autoshoot', 'ScorpionAutoshoot')
feature('COMBAT', 'Right', 'Ignore Downed', 'ScorpionDownCheck')
feature('COMBAT', 'Right', 'Target Teammates', 'ScorpionTargetTeammates')
bind('COMBAT', 'Right', 'Force Hit Bind', 'AimForceHit')
bind('COMBAT', 'Right', 'Manipulation Bind', 'AimManipulation')
bind('COMBAT', 'Right', 'Hitscan Bind', 'AimHitscan')

section(Columns[tabFrames.VISUALS].Left, 'Player ESP')
feature('VISUALS', 'Left', 'Player ESP', 'PlayerESP')
feature('VISUALS', 'Left', 'Player Names', 'PlayerNames')
feature('VISUALS', 'Left', 'Player Boxes', 'PlayerBoxes')
feature('VISUALS', 'Left', 'Player Health', 'PlayerHealth')
feature('VISUALS', 'Left', 'Player Distance', 'PlayerDistance')
feature('VISUALS', 'Left', 'Player Weapon', 'PlayerWeapon')
dropdown('VISUALS', 'Left', 'Player Name Colour', 'PlayerNameColour', ColourNames)
dropdown('VISUALS', 'Left', 'Player Box Colour', 'PlayerBoxColour', ColourNames)
dropdown('VISUALS', 'Left', 'Player Distance Colour', 'PlayerDistanceColour', ColourNames)
dropdown('VISUALS', 'Left', 'Player Weapon Colour', 'PlayerWeaponColour', ColourNames)
feature('VISUALS', 'Left', 'Player Tracers', 'PlayerTracers')
feature('VISUALS', 'Left', 'Player Team Check', 'PlayerTeamCheck')
feature('VISUALS', 'Left', 'Team Colours', 'TeamColors')
slider('VISUALS', 'Left', 'ESP Range', 'ESPRange', 100, 3000)
slider('VISUALS', 'Left', 'ESP Update Rate', 'ESPUpdateRate', 5, 60)
bind('VISUALS', 'Left', 'Player ESP Bind', 'PlayerESP')

section(Columns[tabFrames.VISUALS].Right, 'NPC ESP')
feature('VISUALS', 'Right', 'NPC ESP', 'NPCESP')
feature('VISUALS', 'Right', 'NPC Names', 'NPCNames')
feature('VISUALS', 'Right', 'NPC Boxes', 'NPCBoxes')
feature('VISUALS', 'Right', 'NPC Health', 'NPCHealth')
feature('VISUALS', 'Right', 'NPC Distance', 'NPCDistance')
feature('VISUALS', 'Right', 'Scav ESP', 'NPCScav')
feature('VISUALS', 'Right', 'Bruno ESP', 'NPCBruno')
feature('VISUALS', 'Right', 'Boris ESP', 'NPCBoris')
feature('VISUALS', 'Right', 'Brutus ESP', 'NPCBrutus')
feature('VISUALS', 'Right', 'Bradley ESP', 'NPCBradley')
feature('VISUALS', 'Right', 'Wolf ESP', 'NPCWolf')
feature('VISUALS', 'Right', 'Deer ESP', 'NPCDeer')
feature('VISUALS', 'Right', 'Boar ESP', 'NPCBoar')
feature('VISUALS', 'Right', 'Zombie ESP', 'NPCZombie')
feature('VISUALS', 'Right', 'Attack Heli ESP', 'NPCAttackHeli')
dropdown('VISUALS', 'Right', 'Scav Colour', 'NPCScavColour', ColourNames)
dropdown('VISUALS', 'Right', 'Bruno Colour', 'NPCBrunoColour', ColourNames)
dropdown('VISUALS', 'Right', 'Boris Colour', 'NPCBorisColour', ColourNames)
dropdown('VISUALS', 'Right', 'Brutus Colour', 'NPCBrutusColour', ColourNames)
dropdown('VISUALS', 'Right', 'Bradley Colour', 'NPCBradleyColour', ColourNames)
dropdown('VISUALS', 'Right', 'Wolf Colour', 'NPCWolfColour', ColourNames)
dropdown('VISUALS', 'Right', 'Deer Colour', 'NPCDeerColour', ColourNames)
dropdown('VISUALS', 'Right', 'Boar Colour', 'NPCBoarColour', ColourNames)
slider('VISUALS', 'Right', 'NPC Max Dist', 'NPCMaxDistance', 100, 7500)

section(Columns[tabFrames.ENTITY].Left, 'Entity ESP')
feature('ENTITY', 'Left', 'Entity ESP', 'EntityESP')
feature('ENTITY', 'Left', 'Entity Names', 'EntityNames')
feature('ENTITY', 'Left', 'Entity Boxes', 'EntityBoxes')
feature('ENTITY', 'Left', 'Entity Distance', 'EntityDistance')
feature('ENTITY', 'Left', 'Entity Tracers', 'EntityTracers')
feature('ENTITY', 'Left', 'Minicopter ESP', 'EntityMinicopter')
feature('ENTITY', 'Left', 'Body Bag ESP', 'EntityBodyBag')
feature('ENTITY', 'Left', 'Airdrop ESP', 'EntityAirdrop')
feature('ENTITY', 'Left', 'Timed Crate ESP', 'EntityTimedCrate')
feature('ENTITY', 'Left', 'Hemp ESP', 'EntityHemp')
feature('ENTITY', 'Left', 'Stone ESP', 'EntityStone')
feature('ENTITY', 'Left', 'Phosphate ESP', 'EntityPhosphate')
feature('ENTITY', 'Left', 'Metal ESP', 'EntityMetal')
feature('ENTITY', 'Left', 'Small Gift ESP', 'EntitySmallGift')
feature('ENTITY', 'Left', 'Medium Gift ESP', 'EntityMediumGift')
feature('ENTITY', 'Left', 'Large Gift ESP', 'EntityLargeGift')
dropdown('ENTITY', 'Left', 'Minicopter Colour', 'EntityMinicopterColour', ColourNames)
dropdown('ENTITY', 'Left', 'Body Bag Colour', 'EntityBodyBagColour', ColourNames)
dropdown('ENTITY', 'Left', 'Airdrop Colour', 'EntityAirdropColour', ColourNames)
dropdown('ENTITY', 'Left', 'Timed Crate Colour', 'EntityTimedCrateColour', ColourNames)
dropdown('ENTITY', 'Left', 'Hemp Colour', 'EntityHempColour', ColourNames)
dropdown('ENTITY', 'Left', 'Stone Colour', 'EntityStoneColour', ColourNames)
dropdown('ENTITY', 'Left', 'Phosphate Colour', 'EntityPhosphateColour', ColourNames)
dropdown('ENTITY', 'Left', 'Metal Colour', 'EntityMetalColour', ColourNames)
dropdown('ENTITY', 'Left', 'Small Gift Colour', 'EntitySmallGiftColour', ColourNames)
dropdown('ENTITY', 'Left', 'Medium Gift Colour', 'EntityMediumGiftColour', ColourNames)
dropdown('ENTITY', 'Left', 'Large Gift Colour', 'EntityLargeGiftColour', ColourNames)
slider('ENTITY', 'Left', 'Entity Max Dist', 'EntityMaxDistance', 100, 7500)

section(Columns[tabFrames.ENTITY].Right, 'World ESP')
feature('ENTITY', 'Right', 'Silent Minicopter', 'SilentMinicopter')
feature('ENTITY', 'Right', 'Disable Heli Damage', 'DisableMinicopterDamage')
feature('ENTITY', 'Right', 'Shoot While Piloted', 'ShootWhilePiloted')
feature('ENTITY', 'Right', 'X-Ray Buildings', 'XRay', applyXRay)
slider('ENTITY', 'Right', 'X-Ray Transparency', 'XRayTransparency', 1, 100, applyXRay)
feature('ENTITY', 'Right', 'Disable Traps', 'DisableTraps', applyTraps)
feature('ENTITY', 'Right', 'Disable Spikes', 'DisableSpikes', applySpikes)
bind('ENTITY', 'Right', 'X-Ray Bind', 'XRay')

section(Columns[tabFrames.LOCAL].Left, 'Movement')
feature('LOCAL', 'Left', 'Speed', 'Speed')
slider('LOCAL', 'Left', 'Speed Value', 'SpeedValue', 16, 60)
feature('LOCAL', 'Left', 'Fly', 'Fly')
slider('LOCAL', 'Left', 'Fly Speed', 'FlySpeed', 16, 120)
feature('LOCAL', 'Left', 'Noclip', 'Noclip')
feature('LOCAL', 'Left', 'Infinite Jump', 'InfiniteJump')
feature('LOCAL', 'Left', 'Freecam', 'Freecam', setFreecam)
slider('LOCAL', 'Left', 'Freecam Speed', 'FreecamSpeed', 30, 200)
feature('LOCAL', 'Left', 'Underground Anti-Aim', 'UndergroundAntiAim')
slider('LOCAL', 'Left', 'Anti-Aim Depth', 'AntiAimDepth', 1, 3)
feature('LOCAL', 'Left', 'No Fall Damage', 'NoFallDamage')
feature('LOCAL', 'Left', 'Teleport Mouse', 'TeleportMouse')
feature('LOCAL', 'Left', 'Suicide', 'Suicide', function(value)
	if not value then return end
	local humanoid = getHumanoid(LocalPlayer.Character)
	if humanoid then pcall(function() humanoid.Health = 0 end) end
	if SettingHandlers.Suicide then SettingHandlers.Suicide(false) end
end)
feature('LOCAL', 'Left', 'Instant Respawn', 'Respawn', function(value)
	if value then
		respawn()
		if SettingHandlers.Respawn then SettingHandlers.Respawn(false) end
	end
end)

section(Columns[tabFrames.LOCAL].Right, 'Local Visuals')
feature('LOCAL', 'Right', 'Local Chams', 'Chams', applyChams)
dropdown('LOCAL', 'Right', 'Chams Colour', 'ChamsColour', { 'White', 'Red', 'Green' }, applyChams)
dropdown('LOCAL', 'Right', 'Chams Material', 'ChamsMaterial', { 'Forcefield', 'Neon', 'SmoothPlastic' }, applyChams)
slider('LOCAL', 'Right', 'Chams Transparency', 'ChamsTransparency', 0, 100, applyChams)
feature('LOCAL', 'Right', 'Custom FOV', 'CustomFOV', applyFOV)
slider('LOCAL', 'Right', 'FOV Value', 'FOVValue', 30, 120, applyFOV)
feature('LOCAL', 'Right', 'Zoom', 'Zoom', applyFOV)
slider('LOCAL', 'Right', 'Zoom FOV', 'ZoomFOV', 5, 120, applyFOV)
feature('LOCAL', 'Right', 'Instant Equip', 'InstantEquip')
feature('LOCAL', 'Right', 'Silent Walk', 'SilentWalk')
feature('LOCAL', 'Right', 'Instant Loot', 'InstantLoot')
feature('LOCAL', 'Right', 'Always Criticals', 'AlwaysCriticals')
feature('LOCAL', 'Right', 'Resolve Anti-Aim', 'ResolveAntiAim')

section(Columns[tabFrames.WORLD].Left, 'Lighting')
feature('WORLD', 'Left', 'FullBright', 'FullBright', setFullBright)
feature('WORLD', 'Left', 'Remove Fog', 'RemoveFog', setFog)
feature('WORLD', 'Left', 'Ambient', 'Ambient', applyAmbient)
dropdown('WORLD', 'Left', 'Ambient Colour', 'AmbientColour', { 'White', 'Blue', 'Warm' }, applyAmbient)
feature('WORLD', 'Left', 'Remove Grass', 'RemoveGrass', setGrass)
feature('WORLD', 'Left', 'Low PC', 'LowPC', setLowPC)

section(Columns[tabFrames.WORLD].Right, 'Combat Extras')
feature('WORLD', 'Right', 'Recoil Control', 'RecoilControl')
slider('WORLD', 'Right', 'Recoil', 'RecoilPercentage', 0, 100)
feature('WORLD', 'Right', 'Spread Control', 'SpreadControl')
slider('WORLD', 'Right', 'Spread', 'SpreadPercentage', 0, 100)
feature('WORLD', 'Right', 'Firerate Control', 'FirerateControl')
slider('WORLD', 'Right', 'Firerate', 'FirerateMultiplier', 1, 2.5)
feature('WORLD', 'Right', 'Always Automatic', 'AlwaysAutomatic')
feature('WORLD', 'Right', 'No Melee Shake', 'NoMeleeShake')
feature('WORLD', 'Right', 'Melee Speed', 'MeleeSpeedBoost')
slider('WORLD', 'Right', 'Melee Speed Amt', 'MeleeSpeedAmount', 1, 1.3)
feature('WORLD', 'Right', 'Melee Range', 'MeleeRangeBoost')
slider('WORLD', 'Right', 'Melee Range Amt', 'MeleeRangeAmount', 1, 2.5)
feature('WORLD', 'Right', 'Instant Eoka', 'InstantEoka')
feature('WORLD', 'Right', 'Always Shoot', 'AlwaysShoot')
feature('WORLD', 'Right', 'Auto Reload', 'AutoReload')
feature('WORLD', 'Right', 'Bullet TP', 'BulletTP')
feature('WORLD', 'Right', 'TP To Waypoint', 'TPToWaypoint')
feature('WORLD', 'Right', 'Combat Mode', 'CombatMode')
feature('WORLD', 'Right', 'Staff Detector', 'StaffDetector')
feature('WORLD', 'Right', 'Instant Eoka', 'ScorpionInstantEoka')
feature('WORLD', 'Right', 'Instant Loot', 'ScorpionInstantLoot', function() if Runtime.Scorpion then Runtime.Scorpion.ApplyQuickStack() end end)
feature('WORLD', 'Right', 'Perfect Farm', 'ScorpionPerfectFarm')
feature('WORLD', 'Right', 'Remove Grass', 'ScorpionRemoveGrass', function() if Runtime.Scorpion then Runtime.Scorpion.ApplyGrass() end end)
feature('WORLD', 'Right', 'Ambience', 'ScorpionAmbience', function() if Runtime.Scorpion then Runtime.Scorpion.ApplyAmbience() end end)
slider('WORLD', 'Right', 'Amb Brightness', 'ScorpionAmbBrightness', 0, 100)
slider('WORLD', 'Right', 'Amb Indoor', 'ScorpionAmbIndoor', 0, 100)

section(Columns[tabFrames.MISC].Left, 'Interface')
feature('MISC', 'Left', 'Stats HUD', 'StatsHUD')
feature('MISC', 'Left', 'Target HUD', 'TargetHUD')
feature('MISC', 'Left', 'Keybind List', 'KeybindList')
feature('MISC', 'Left', 'Menu Accent', 'MenuAccent', function(value)
	mainStroke.Color = value and Theme.Green or Theme.Accent
end)
feature('MISC', 'Left', 'UI Animations', 'UIAnimations', setUIAnimations)
feature('MISC', 'Left', 'Hit Sound', 'ScorpionHitSound')
dropdown('MISC', 'Left', 'Hit Sound Preset', 'ScorpionHitSoundName', { 'Minecraft', 'Telegram', 'Rust Headshot', 'CSGO Kill', 'Minecraft Bow', 'CSGO Headshot', 'Minecraft XP', 'Minecraft Drop', 'Fortnite Headshot', 'Gamesense', 'Primordial' })
slider('MISC', 'Left', 'Hit Volume', 'ScorpionHitSoundVolume', 0, 1000)
feature('MISC', 'Left', 'Shoot Sound', 'ScorpionShootSound')
slider('MISC', 'Left', 'Shoot Volume', 'ScorpionShootVolume', 0, 1000)
feature('MISC', 'Left', 'Bullet Tracer', 'ScorpionTracer')
dropdown('MISC', 'Left', 'Tracer Style', 'ScorpionTracerStyle', { 'Default', 'Obelus', 'Lightning', 'DNA', 'Minecraft', 'Beam', 'Galaxy' })
slider('MISC', 'Left', 'Tracer Duration', 'ScorpionTracerDuration', 0, 15)
slider('MISC', 'Left', 'Tracer Thickness', 'ScorpionTracerThickness', 0, 100)
feature('MISC', 'Left', 'FOV Rainbow', 'ScorpionFovRainbow')
slider('MISC', 'Left', 'Rainbow Speed', 'ScorpionFovRainbowSpeed', 0, 5)
feature('MISC', 'Left', 'FOV Rotate', 'ScorpionFovRotate')
slider('MISC', 'Left', 'Rotate Speed', 'ScorpionFovRotateSpeed', 0, 5)
feature('MISC', 'Left', 'FOV Fill', 'ScorpionFovFill')
slider('MISC', 'Left', 'FOV Fill Alpha', 'ScorpionFovFillTransparency', 0, 100)
slider('MISC', 'Left', 'FOV Thickness', 'ScorpionFovThickness', 1, 10)
feature('MISC', 'Left', 'Watermark', 'ScorpionWatermark')

section(Columns[tabFrames.MISC].Right, 'Binds')
bind('MISC', 'Right', 'Speed Bind', 'Speed')
bind('MISC', 'Right', 'Fly Bind', 'Fly')
bind('MISC', 'Right', 'Noclip Bind', 'Noclip')
bind('MISC', 'Right', 'Freecam Bind', 'Freecam')
bind('MISC', 'Right', 'Zoom Bind', 'Zoom')
bind('MISC', 'Right', 'Bullet TP Bind', 'BulletTP')
bind('MISC', 'Right', 'Waypoint Bind', 'TPToWaypoint')
bind('MISC', 'Right', 'Combat Mode Bind', 'CombatMode')
bind('MISC', 'Right', 'Anti-Aim Bind', 'UndergroundAntiAim')
bind('MISC', 'Right', 'No Fall Bind', 'NoFallDamage')
bind('MISC', 'Right', 'Teleport Bind', 'TeleportMouse')
bind('MISC', 'Right', 'Respawn Bind', 'Respawn')
bind('MISC', 'Right', 'Suicide Bind', 'Suicide')
feature('MISC', 'Right', 'Gun Chams', 'ScorpionGunChams', function() if Runtime.Scorpion then Runtime.Scorpion.ApplyGunChams() end end)
feature('MISC', 'Right', 'Arms Chams', 'ScorpionArmsChams', function() if Runtime.Scorpion then Runtime.Scorpion.ApplyGunChams() end end)
dropdown('MISC', 'Right', 'Gun Material', 'ScorpionGunMaterial', { 'ForceField', 'Neon', 'Glass', 'Ice', 'Wood', 'Plastic', 'Metal' })
dropdown('MISC', 'Right', 'Gun Colour', 'ScorpionGunColour', ColourNames)
feature('MISC', 'Right', 'Fly Restrictions', 'ScorpionFlyRestrictions')
button('MISC', 'Right', 'Unload Burmalda.hook', function()
	local defer = task.defer or task.spawn or function(callback) callback() end
	defer(Runtime.Unload)
end)

section(Columns[tabFrames.CONFIG].Left, 'Config')
dropdown('CONFIG', 'Left', 'Config Slot', 'ConfigSlot', ConfigSlots)
button('CONFIG', 'Left', 'Save Config', saveConfig)
button('CONFIG', 'Left', 'Load Config', function()
	if loadConfig() then syncUI() end
end)
button('CONFIG', 'Left', 'Delete Config', deleteConfig)

section(Columns[tabFrames.CONFIG].Right, 'Info')
local info = Instance.new('TextLabel', Columns[tabFrames.CONFIG].Right)
info.Size = UDim2.new(1, -12, 0, 120)
info.Position = UDim2.new(0, 6, 0, 0)
info.BackgroundTransparency = 1
info.Text = 'Fallen Survival' .. NL .. 'PlaceId 10228136016' .. NL .. 'Executor ' .. executorName .. NL .. 'All features Off at startup'
info.TextColor3 = Theme.SubText
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Font = Enum.Font.SourceSans
info.TextSize = 12
info.TextWrapped = true

for _, frame in pairs(tabFrames) do
	local left = Columns[frame].Left
	local right = Columns[frame].Right
	local rows = math.max(#left:GetChildren(), #right:GetChildren())
	frame.CanvasSize = UDim2.new(0, 0, 0, rows * 34 + 20)
end

closeBtn.MouseButton1Click:Connect(toggleMenu)

trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
	if processed or Runtime.Unloaded then return end
	if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
	for key, value in pairs(Binds) do
		local match = false
		if value ~= 'None' then
			if value == 'RMB' and input.UserInputType == Enum.UserInputType.MouseButton2 then match = true end
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == value then match = true end
		end
		if match then
			if key == 'TeleportMouse' or key == 'BulletTP' then
				teleportMouse()
			elseif key == 'Respawn' then
				respawn()
			elseif SettingHandlers[key] then
				SettingHandlers[key](not State[key])
			end
		end
	end
end))

trackConnection(UserInputService.InputChanged:Connect(function(input)
	if not State.Freecam or not freecam.active or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	local delta = input.Delta
	if delta then
		freecam.yaw -= delta.X / 200
		freecam.pitch = math.clamp(freecam.pitch - delta.Y / 200, -1.5, 1.5)
	end
end))

trackConnection(UserInputService.JumpRequest:Connect(function()
	if not State.InfiniteJump or Runtime.Unloaded then return end
	local humanoid = getHumanoid(LocalPlayer.Character)
	if humanoid then pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Jumping) end
end))

function Runtime.Unload()
	if Runtime.Unloaded then return end
	Runtime.Unloaded = true
	Runtime.Ready = false
	for key in pairs(State) do
		if type(State[key]) == 'boolean' then State[key] = false end
	end
	hudLabel.Visible = false
	for _, connection in ipairs(Runtime.AnimationConnections) do
		if connection and connection.Disconnect then pcall(connection.Disconnect, connection) end
	end
	table.clear(Runtime.AnimationConnections)
	if fovCircle then fovCircle.Visible = false end
	if targetLine then targetLine.Visible = false end
	if manipulationMarker then manipulationMarker.Visible = false end
	if hitscanMarker then hitscanMarker.Visible = false end
	for _, connection in ipairs(Runtime.Connections) do
		if connection and connection.Disconnect then pcall(connection.Disconnect, connection) end
	end
	table.clear(Runtime.Connections)
	for _, object in pairs(EspObjects) do object:Remove() end
	table.clear(EspObjects)
	for drawing in pairs(Runtime.Drawings) do
		if drawing and drawing.Remove then pcall(drawing.Remove, drawing) end
	end
	table.clear(Runtime.Drawings)
	setFullBright(false)
	setFog(false)
	applyAmbient()
	setGrass(false)
	setLowPC(false)
	applyXRay()
	applyTraps()
	applySpikes()
	applyChams()
	setFreecam(false)
	restoreMovement()
	applyFOV()
	for index = #Runtime.Owned, 1, -1 do pcall(Runtime.Owned[index]) end
	for gui in pairs(Runtime.Guis) do
		if gui and gui.Destroy then pcall(gui.Destroy, gui) end
	end
	table.clear(Runtime.Guis)
	if Env.BurmaldaFallenSurvival == Runtime then Env.BurmaldaFallenSurvival = nil end
end

loadConfig()
syncUI()
Runtime.Ready = true
return Runtime
