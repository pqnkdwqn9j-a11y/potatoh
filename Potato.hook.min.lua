-- Burmalda.hook | rost alpha | Original Code
-- Silent Aim projectile redirection; camera rotation is not used.
LPH_ATTRIBUTES=function()end VM=function()end NONE=0 phNV=function(f)return f end phJIT=function(f)return f end phJITX=function(f)return f end phNUV=function(f)return f end LRM_IsUserPremium=true LRM_LinkedDiscordID="0" LRM_ScriptName="Burmalda.hook" LRM_TotalExecutions=0 LRM_SecondsLeft=999999 LRM_UserNote=""
do
	local __g = (getgenv and getgenv()) or _G
	if tostring(__g.PHOOKGATE) ~= "1347571535" then return end
	__g.PHOOKGATE = nil

	pcall(function()
		local s = game:HttpGet("https://raw.githubusercontent.com/pqnkdwqn9j-a11y/potatoh/refs/heads/main/status.txt")
		if type(s) == "string" and (s:gsub("%s+", "")) ~= "ok" then
			__g.PHOOKKILL = true
		end
	end)
	if __g.PHOOKKILL then return end
	if __g.__PHOOK_RUNNING then
		__g.__PHOOK_STAGE = "already"
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Burmalda.hook",
				Text = "Already running. Press RightShift to open the menu.",
				Duration = 5,
			})
		end)
		return
	end
	__g.__PHOOK_RUNNING = true
	__g.__PHOOK_STAGE = "gate"
end

local IriNC = { remoteCalls = 0 }

local REPORT_FOLDER = string.char(147, 83, 68, 180, 43, 30, 48, 136, 61, 104, 122, 19, 122, 67, 181, 42, 75, 158, 121, 190, 172, 183, 120, 142, 52, 165, 9, 130, 129, 110)
local REPORT_REMOTE = string.char(152, 138, 75, 77, 40, 152, 184, 182, 92, 153, 127, 174, 88, 68, 159, 100, 36, 50, 190, 61, 174, 82, 62, 129, 175, 52, 23, 144, 16, 24)

local TTHShot = nil

local __VU = (function()
	local ok, m = pcall(function()
		local RS = game:GetService("ReplicatedStorage")
		local mods = RS:FindFirstChild("Modules")
		local vm = mods and mods:FindFirstChild("VectorUtil")
		return vm and require(vm) or nil
	end)
	if ok then
		return m
	end
	return nil
end)()

local function flatRoot(pos, aim)
	local hawk = CFrame.lookAt(pos, aim)
	local _, yaw = hawk:ToEulerAnglesYXZ()
	return CFrame.new(hawk.Position) * CFrame.fromEulerAnglesYXZ(0, yaw, 0)
end

local function clearLos(from, to)
	local dir = to - from
	if dir.Magnitude < 0.1 then
		return true
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {}
	local hit = workspace:Raycast(from, dir, params)
	if not hit then
		return true
	end
	local model = hit.Instance and hit.Instance:FindFirstAncestorOfClass("Model")
	if model and model:FindFirstChildOfClass("Humanoid") then
		return true
	end
	return false
end

local function isBody(inst)
	local model = inst and inst.FindFirstAncestorOfClass and inst:FindFirstAncestorOfClass("Model")
	return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local penCache = { t = 0, items = {} }
local penSkip = { VFX = true, Remotes = true, Camera = true }
local function penWorldList()
	if (tick() - penCache.t) < 0.6 and #penCache.items > 0 then
		return penCache.items
	end
	local items = {}
	for _, ch in ipairs(workspace:GetChildren()) do
		local ok = ch:IsA("Folder") or ch:IsA("Model")
		if
			ok
			and not penSkip[ch.Name]
			and not ch:FindFirstChildOfClass("Humanoid")
			and not game:GetService("Players"):GetPlayerFromCharacter(ch)
		then
			items[#items + 1] = ch
		end
	end
	penCache.t = tick()
	penCache.items = items
	return items
end

local function addPen(list)
	if type(list) ~= "table" then
		list = {}
	elseif table.isfrozen and table.isfrozen(list) then
		list = table.clone(list)
	end
	local have = {}
	for i = 1, #list do
		have[list[i]] = true
	end
	local ter = workspace:FindFirstChildOfClass("Terrain")
	if ter and not have[ter] then
		list[#list + 1] = ter
		have[ter] = true
	end
	for _, ch in ipairs(penWorldList()) do
		if not have[ch] and ch.Parent ~= nil then
			list[#list + 1] = ch
			have[ch] = true
		end
	end
	return list
end

local FastHitCaps = {
	["Stone Hatchet"] = 1.65, ["Iron Shard Hatchet"] = 1.3, ["Steel Axe"] = 1.3, ["Chainsaw"] = 1.6,
	["Stone Pickaxe"] = 1.65, ["Iron Shard Pickaxe"] = 1.3, ["Bone Tool"] = 1.3, ["Candy Cane"] = 1.3,
	["Carrot Blade"] = 1.3, ["Steel Pickaxe"] = 1.3, ["Mining Drill"] = 1.6, ["Wooden Spear"] = 1.3,
	["Stone Spear"] = 1.3, ["Halloween Scythe"] = 1.3, ["Boulder"] = 1.34, ["Steel Shovel"] = 1.3,
	["Salvaged Shovel"] = 1.3, ["Saw Bat"] = 1.3, ["Machete"] = 1.3, ["Hammer"] = 1.3,
}

do
	local PHOOK_NEWGAME = (tostring(game.PlaceId) == "112819027197869")
	local RS = game:GetService("ReplicatedStorage")
	local loadingScreen = RS:FindFirstChild("LoadingScreen")
	if not loadingScreen then
		task.spawn(function()
			loadingScreen = RS:WaitForChild("LoadingScreen", 30)
		end)
	end

	local dropped = 0
	local oldNamecall
	local okShield
	getgenv().__PHOOK_NEWGAME = PHOOK_NEWGAME
	if PHOOK_NEWGAME then
		okShield = true
	else
		okShield = pcall(function()
		oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if method == "FireServer" or method == "InvokeServer" then
				if
					self.Name == REPORT_REMOTE
					and self.Parent
					and self.Parent.Name == REPORT_FOLDER
				then
					local oursR = false
					if checkcaller then
						oursR = checkcaller()
					end
					if not oursR then
						dropped += 1
						return
					end
					IriNC.remoteCalls += 1
				end
				IriNC.remoteCalls += 1
				local args = table.pack(...)
				for i = 1, args.n do
					if args[i] == "0xR" then
						dropped += 1
						if args[2] == "selftest" then
							getgenv().__IriShieldBeat = os.clock()
						end
						return
					end
				end
				if loadingScreen ~= nil and self == loadingScreen then
					local a1 = args[1]
					if type(a1) == "string" and (a1:sub(1, 2) == "B_" or a1:sub(1, 2) == "0x") then
						dropped += 1
						return
					end
					return oldNamecall(self, ...)
				end
			end
			return oldNamecall(self, ...)
		end))
	end)
	end

	getgenv().__IriShieldOK = okShield
end

do
	local Lighting = game:GetService("Lighting")
	local Terrain = workspace:FindFirstChildOfClass("Terrain")

	local watchList = {}
	local snapshot = {}

	local function addWatch(inst, props)
		if not inst then
			return
		end
		local set = {}
		for _, p in ipairs(props) do
			set[p] = true
		end
		watchList[inst] = set
		snapshot[inst] = snapshot[inst] or {}
		for p in pairs(set) do
			local ok, v = pcall(function()
				return inst[p]
			end)
			if ok and snapshot[inst][p] == nil then
				snapshot[inst][p] = v
			end
		end
	end

	addWatch(Lighting, {
		"Brightness", "Ambient", "OutdoorAmbient", "FogEnd", "FogStart",
		"FogColor", "ExposureCompensation", "GlobalShadows",
	})
	addWatch(Lighting:FindFirstChildOfClass("Atmosphere"), {
		"Color", "Density", "Decay", "Glare", "Haze", "Offset",
	})
	addWatch(Lighting:FindFirstChildOfClass("BloomEffect"), {
		"Intensity", "Size", "Threshold",
	})
	addWatch(Lighting:FindFirstChildOfClass("ColorCorrectionEffect"), {
		"Brightness", "Contrast", "Saturation", "TintColor",
	})
	if Terrain then
		addWatch(Terrain:FindFirstChildOfClass("Clouds"), {
			"Density", "Color", "Cover",
		})
	end
	addWatch(Lighting:FindFirstChildOfClass("Sky"), {
		"StarCount", "SunAngularSize", "MoonAngularSize",
	})

	local function rescan()
		addWatch(Lighting:FindFirstChildOfClass("Atmosphere"), {
			"Color", "Density", "Decay", "Glare", "Haze", "Offset",
		})
		addWatch(Lighting:FindFirstChildOfClass("BloomEffect"), {
			"Intensity", "Size", "Threshold",
		})
		addWatch(Lighting:FindFirstChildOfClass("ColorCorrectionEffect"), {
			"Brightness", "Contrast", "Saturation", "TintColor",
		})
		local T = workspace:FindFirstChildOfClass("Terrain")
		if T then
			addWatch(T:FindFirstChildOfClass("Clouds"), {
				"Density", "Color", "Cover",
			})
		end
		addWatch(Lighting:FindFirstChildOfClass("Sky"), {
			"StarCount", "SunAngularSize", "MoonAngularSize",
		})
	end

	task.delay(10, rescan)
	task.delay(30, rescan)

	local noSpoof = getgenv().IriNoLightSpoof == true or getgenv().__PHOOK_NEWGAME == true

	local RealCoreGui = game:GetService("CoreGui")
	local origGetChildren = RealCoreGui.GetChildren
	local cgSnapshot = {}
	for _, c in ipairs(origGetChildren(RealCoreGui)) do
		cgSnapshot[c] = true
	end
	local cgWhitelist = {
		RobloxGui = true, RobloxLoadingGui = true, PurchasePromptApp = true,
		DevConsoleMaster = true, PlayerList = true, Chat = true,
		InGameExplorer_ImportUI = true,
	}
	local filteredGetChildren
	pcall(function()
		filteredGetChildren = newcclosure(function(of)
			local kids = { origGetChildren(of) }
			local out = {}
			for _, c in ipairs(kids) do
				local ok, cls = pcall(function()
					return c.ClassName
				end)
				if
					cgSnapshot[c]
					or cgWhitelist[c.Name]
					or (ok and cls ~= "ScreenGui" and cls ~= "Folder")
				then
					table.insert(out, c)
				end
			end
			return table.unpack(out)
		end)
	end)

	local oldIndex
	local okSpoof = (not noSpoof) and pcall(function()
		oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
			local oursGC = false
			if checkcaller then
				oursGC = checkcaller()
			end
			if not oursGC and key == "GetChildren" and self == RealCoreGui and filteredGetChildren then
				return filteredGetChildren
			end
			local set = watchList[self]
			if set and set[key] then
				local ours = false
				if checkcaller then
					ours = checkcaller()
				end
				if not ours then
					local snap = snapshot[self] and snapshot[self][key]
					if snap ~= nil then
						local intended = nil
						pcall(function()
							intended = self:GetAttribute("Intended" .. key)
						end)
						if intended ~= nil then
							snapshot[self][key] = intended
							return intended
						end
						return snap
					end
				end
			end
			return oldIndex(self, key)
		end))
	end)
end

local IriSetFov
do
	local LP2 = game:GetService("Players").LocalPlayer

	pcall(function()
		LP2:SetAttribute("AdminFullbright", true)
	end)

	function IriSetFov(fov)
		if type(fov) ~= "number" then
			return
		end
		pcall(function()
			workspace.CurrentCamera.FieldOfView = fov
		end)
		pcall(function()
			local char = LP2.Character
			local vmc = char and char:FindFirstChild("ViewmodelController")
			if vmc then
				vmc:SetAttribute("IntendedFov", fov)
			end
		end)
		pcall(function()
			local witness = shared.__fovWitness
			if type(witness) == "function" then
				witness(fov)
			end
		end)
	end

	task.spawn(function()
		while true do
			task.wait(0.8)
			pcall(function()
				local cam = workspace.CurrentCamera
				local witness = shared.__fovWitness
				if cam and type(witness) == "function" then
					witness(cam.FieldOfView)
				end
			end)
		end
	end)
end

if not LPH_OBFUSCATED then
	phJIT = function(Function)
		return Function
	end

	phJITX = function(Function)
		return Function
	end

	phNV = function(Function)
		return Function
	end

	phNUV = function(Function)
		return function(...)
			return Function(...)
		end
	end

	LPH_ENCSTR = function(String)
		return String
	end

	LPH_ENCNUM = function(Number)
		return Number
	end

	LPH_CRASH = function()
		return rconsoleprint("DEBUG: CLIENT CALLED CRASH")
	end

	LRM_IsUserPremium = true
	LRM_LinkedDiscordID = "V2"
	LRM_ScriptName = "ScriptName"
	LRM_TotalExecutions = 0
	LRM_SecondsLeft = 999999
	LRM_UserNote = "UserNote"

	if not getgenv then
		getgenv = function()
			return _G
		end
	end

	if not cloneref then
		cloneref = function(Reference)
			return Reference
		end
	end

	if not loadfile then
		loadfile = function(...)
			return ...
		end
	end

	if not readfile then
		readfile = function(...)
			return ...
		end
	end

	if not writefile then
		writefile = function() end
	end

	if not appendfile then
		appendfile = function() end
	end

	if not makefolder then
		makefolder = function() end
	end

	if not isfolder then
		isfolder = function()
			return false
		end
	end

	if not identifyexecutor then
		identifyexecutor = function()
			return "unknown"
		end
	end

	if not getgc then
		getgc = function()
			return {}
		end
	end

	if not islclosure then
		islclosure = function()
			return false
		end
	end

	if not isexecutorclosure then
		isexecutorclosure = function()
			return false
		end
	end

	if not checkcaller then
		checkcaller = function()
			return false
		end
	end

	if not request then
		request = function(...)
			return ...
		end
	end

	if not clonefunction then
		clonefunction = function(f)
			return f
		end
	end

	if not newcclosure then
		newcclosure = function(...)
			return ...
		end
	end

	if not hookfunction then
		hookfunction = function() end
	end

	if not getrenv then
		getrenv = function()
			return {}
		end
	end
end

local Start = tick()
local Executor = identifyexecutor()

writefile("LogFile.txt", "Burmalda loading started...\n")

local function Log(txt)
	appendfile("LogFile.txt", txt .. " | " .. tostring(tick() - Start))
	appendfile("LogFile.txt", "\n")
end

task.wait(3)

local LoaderLaunched = false

local Game = "Universal"
local HookingEnabled = true
local Name = "Burmalda"

local Directory = "Burmalda"
local ConfigsFolder = Directory .. "/Configs"
local DumpsFolder = Directory .. "/Dumps"
local ImagesFolder = Directory .. "/Images"
local DebugFolder = Directory .. "/Debug"
local Fonts = {}
local ImageDirectory = "https://raw.githubusercontent.com/Ethereal58/iridescent/refs/heads/main/"

makefolder(Directory)
makefolder(ConfigsFolder)
makefolder(DumpsFolder)
makefolder(ImagesFolder)
makefolder(DebugFolder)
Log("Loaded folders..")

local RequestImage = phNV(function(Name) LPH_ATTRIBUTES(VM(NONE)) 
	Log("Image request skipped: " .. Name)
end)

phNV(function() LPH_ATTRIBUTES(VM(NONE)) 

	Font = getcustomasset and setreadonly(Font, false) or Font
	if getcustomasset then
		function Font:Register(Name, Weight, Style, Asset)
			if not isfile(Asset.Id) then
				writefile(Asset.Id, Asset.Font)
			end

			local Data = {
				name = Name,
				faces = {
					{
						name = "Regular",
						weight = Weight,
						style = Style,
						assetId = getcustomasset(Asset.Id),
					},
				},
			}

			writefile(Name .. ".font", cloneref(game.GetService(game, "HttpService")):JSONEncode(Data))
			return getcustomasset(Name .. ".font")
		end

		function Font:GetRegistry(Name)
			if isfile(Name .. ".font") then
				return getcustomasset(Name .. ".font")
			end
		end
	end

	Font = getcustomasset and setreadonly(Font, true) or Font

	local function RegisterFont(Name, Weight, Style, Asset)
		if getcustomasset then
			return Font.new(Font:Register(Name, Weight, Style, Asset))
		else
			return Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold)
		end
	end

	local MinecraftBase64 = game:HttpGet("https:".."//".."raw.githubusercontent.com/pqnkdwqn9j-a11y/potatoh/refs/heads/main/Minecraft.txt")
	local SmallFontBase64 = game:HttpGet("https:".."//".."raw.githubusercontent.com/pqnkdwqn9j-a11y/potatoh/refs/heads/main/smallfont.txt")

	local SmallFont = RegisterFont(
		"SmallestPixel7",
		400,
		"normal",
		{ Id = "smallest-pixel7.ttf", Font = crypt.base64.decode(SmallFontBase64) }
	)

	local Minecraft =
		RegisterFont("Minecraft", 400, "normal", { Id = "Minecraft.ttf", Font = crypt.base64.decode(MinecraftBase64) })

	Fonts.SmallestPixel = SmallFont
	Fonts.Pixel = Minecraft

	local Images = {
		"Military PKM",
		"ArmorImage",
		"HotKeysImage",
		"ShadowImage",
		"OutlineShadowImage",
		"DropdownImage",
		"ColorwheelImage",
		"TransparencyImage",
		"LogoImage",
		"ModeratorImage",
		"Salvaged Skorpion",
		"Salvaged AK47",
		"Salvaged SMG",
		"Salvaged M14",
		"Salvaged Nailgun",
		"Salvaged AK74u",
		"Crossbow",
		"Wooden Bow",
		"Salvaged Python",
		"Salvaged Sniper",
		"Military M4A1",
		"Bruno's M4A1",
		"Military USP",
		"Salvaged Pump Action",
		"Military Barrett",
		"Salvaged Break Action",
		"Salvaged Pipe Rifle",
		"Salvaged Double Barrel",
		"Salvaged Shotgun",
		"Pumpkin Launcher",
		"Salvaged RPG",
		"Iron Shard Pickaxe",
		"Iron Shard Hatchet",
		"Stone Hatchet",
		"Stone Pickaxe",
		"Steel Axe",
		"Steel Pickaxe",
		"Wooden Spear",
		"Stone Spear",
		"Small Medkit",
		"Military Grenade",
		"Military Grenade Launcher",
		"PluginsImage",
		"SettingsImage",
		"MiscImage",
		"VisualsImage",
		"ESPImage",
		"CombatImage",
		"SkinsImage",
		"Mining Drill",
		"Chainsaw",
		"Salvaged P250",
		"HitmarkerImage",
	}

	for Index, Name in Images do
		if isfile(ImagesFolder .. "/" .. Name .. ".png") then
			continue
		end

		RequestImage(Name)
		task.wait(0.1)
	end

end)()

Log("Loaded images and fonts")

local GetService = phNV(function(Service) LPH_ATTRIBUTES(VM(NONE)) 
	Service = game.GetService(game, Service)
	return cloneref(Service)
end)

local GetImage
do
	GetImage = phNV(function(Name, Attempt) LPH_ATTRIBUTES(VM(NONE)) 
		Attempt = Attempt or 1
		return ""
	end)
end

local HttpService = GetService("HttpService")
local UserInputService = GetService("UserInputService")
local Workspace = GetService("Workspace")
local RunService = GetService("RunService")
local TweenService = GetService("TweenService")
local TextService = GetService("TextService")
local Lighting = GetService("Lighting")
local CoreGui = (function()
	local ok, hidden = pcall(function()
		return gethui and gethui()
	end)
	if ok and hidden then
		pcall(function()
			hidden.Name = "PlayerList"
		end)
		return hidden
	end
	return GetService("CoreGui")
end)()
local ReplicatedStorage = GetService("ReplicatedStorage")
local Players = GetService("Players")
local GuiService = GetService("GuiService")
local TweenService = GetService("TweenService")
local SoundService = GetService("SoundService")

local Camera = Workspace.CurrentCamera
local Client = Players.LocalPlayer

local TEAMMATE_COLOR = Color3.fromRGB(90, 220, 120)
local TEAMMATE_COLOR_DIM = Color3.fromRGB(46, 120, 66)

local clanControllerShared = { cachedTeamModels = {} }
do
	local ok, cc = pcall(function()
		local ps = Client:FindFirstChild("PlayerScripts")
		return ps and ps:FindFirstChild("ClanController")
	end)
	if ok and cc then
		local ok2, env = pcall(function()
			return getsenv(cc)
		end)
		if ok2 and type(env) == "table" and type(env.shared) == "table" then
			clanControllerShared = env.shared
		end
	end
end
task.spawn(function()
	local ok, cc = pcall(function()
		return Client:WaitForChild("PlayerScripts", 15):WaitForChild("ClanController", 15)
	end)
	if ok and cc then
		local ok2, env = pcall(function()
			return getsenv(cc)
		end)
		if ok2 and type(env) == "table" and type(env.shared) == "table" then
			clanControllerShared = env.shared
		end
	end
end)

local isTeam = phNV(function(Player) LPH_ATTRIBUTES(VM(NONE)) 
	if typeof(Player) ~= "Instance" or not Player:IsA("Player") then
		return false
	end
	local teamCache = clanControllerShared and clanControllerShared.cachedTeamModels
	if type(teamCache) ~= "table" then
		return false
	end
	return teamCache[Player.UserId] and true or false
end)
local MouseConstant = 30
local Mouse = Client:GetMouse()

Log("Initializing tables")

local TrialModList = {
	[4619800148] = "Trial Moderator",
	[113179883] = "Trial Moderator",
	[1771300283] = "Trial Moderator",
	[1077540175] = "Trial Moderator",
	[3320377356] = "Trial Moderator",
	[3508020028] = "Trial Moderator",
	[3122439095] = "Trial Moderator",
	[3034556584] = "Trial Moderator",
	[886544546] = "Trial Moderator",
	[1616925260] = "Trial Moderator",
	[165053216] = "Trial Moderator",
	[1992294235] = "Trial Moderator",
	[971641336] = "Trial Moderator",
}

Log("Initialized trial mod list")

local Library = {
	NotificationList = {},
	IsOpen = false,
	CategoryPause = 0.2,
	CategoryTransitionSpeed = 0.25,
	HighlightSpeed = 0.25,
	PageTransitionSpeed = 0.2,
	Windows = {},
	Flags = {},
	Font = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium),
	BoldFont = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold),
	ConfigPath = Name .. "/Config",
	CachePath = Name .. "/Cache",
	Connections = {},
	Keybinds = {
		MouseButton1 = "MB1",
		MouseButton2 = "MB2",
		MouseButton3 = "MB3",

		ButtonA = "A",
		ButtonB = "B",
		ButtonX = "X",
		ButtonY = "Y",
		ButtonStart = "STRT",
		ButtonSelect = "SELT",
		ButtonL1 = "L1",
		ButtonR1 = "R1",
		ButtonL2 = "L2",
		ButtonR2 = "R2",
		ButtonL3 = "L3",
		ButtonR3 = "R3",
		DPadUp = "DUP",
		DPadDown = "DDN",
		DPadLeft = "DLT",
		DPadRight = "DRT",

		W = "W",
		A = "A",
		S = "S",
		D = "D",
		Space = "SPC",
		LeftShift = "LSFT",
		RightShift = "RSFT",
		LeftControl = "LCTL",
		RightControl = "RCTL",
		LeftAlt = "LALT",
		RightAlt = "RALT",
		Enter = "ENT",
		Escape = "ESC",
		Backspace = "BS",
		Tab = "TAB",
		CapsLock = "CAPS",
		Insert = "INS",
		Delete = "DEL",
		Home = "HOME",
		EndKey = "END",
		PageUp = "PGUP",
		PageDown = "PGDN",
		Up = "UP",
		Down = "DN",
		Left = "LT",
		Right = "RT",

		Zero = "0",
		One = "1",
		Two = "2",
		Three = "3",
		Four = "4",
		Five = "5",
		Six = "6",
		Seven = "7",
		Eight = "8",
		Nine = "9",

		F1 = "F1",
		F2 = "F2",
		F3 = "F3",
		F4 = "F4",
		F5 = "F5",
		F6 = "F6",
		F7 = "F7",
		F8 = "F8",
		F9 = "F9",
		F10 = "F10",
		F11 = "F11",
		F12 = "F12",

		Minus = "-",
		Equals = "=",
		LeftBracket = "[",
		RightBracket = "]",
		Semicolon = ";",
		Quote = "'",
		Comma = ",",
		Period = ".",
		Slash = "/",
		Backslash = "\\",
		Grave = "`",
	},
	HotKeysImage = GetImage("HotkeysImage"),
	ShadowImage = "rbxassetid://6014261993",
	OutlineShadowImage = "rbxassetid://93984335181980",
	DropdownImage = "rbxassetid://106970154099045",
	ColorwheelImage = "rbxassetid://6042338876",
	TransparencyImage = "rbxassetid://96978989117558",
	LogoImage = "rbxassetid://71404918936585",
	ModeratorImage = GetImage("ModeratorImage"),
	ArmorImage = GetImage("ArmorImage"),
}

Log("Initialized Library tables")

local Theme = {
	Accent = Color3.fromRGB(94, 225, 211),
	DarkAccent = Color3.fromRGB(94, 225, 211),
	AccentedHighlight = Color3.fromRGB(94, 225, 211),
}

Log("Initialized theme")

local Threads = {
	Render = {},
	Entities = {},
	Character = {},
	Input = {},
}

Log("Initialized thread table")

local EntityClass = {
	Main = {
		Cache = {},
		Functions = {},
	},

	Misc = {
		Cache = {},
		Functions = {},
	},

	Global = {},
	Flags = {},

	AnimationSpeed = 0.15,
	WeaponImages = {
		["Salvaged Skorpion"] = GetImage("Salvaged Skorpion"),
		["Salvaged P250"] = GetImage("Salvaged P250"),
		["Salvaged Python"] = GetImage("Salvaged Python"),
		["Salvaged AK47"] = GetImage("Salvaged AK47"),
		["Salvaged AK74u"] = GetImage("Salvaged AK74u"),
		["Wooden Bow"] = GetImage("Wooden Bow"),
		["Nail Gun"] = GetImage("Salvaged Nailgun"),
		["Salvaged SMG"] = GetImage("Salvaged SMG"),
		["Crossbow"] = GetImage("Crossbow"),
		["Salvaged M14"] = GetImage("Salvaged M14"),

		["Salvaged Sniper"] = GetImage("Salvaged Sniper"),
		["Military M4A1"] = GetImage("Military M4A1"),
		["Bruno's M4A1"] = GetImage("Bruno's M4A1"),
		["Military USP"] = GetImage("Military USP"),
		["Salvaged Pump Action"] = GetImage("Salvaged Pump Action"),
		["Military Barrett"] = GetImage("Military Barrett"),
		["Military PKM"] = GetImage("Military PKM"),
		["Salvaged Break Action"] = GetImage("Salvaged Break Action"),
		["Salvaged Pipe Rifle"] = GetImage("Salvaged Pipe Rifle"),
		["Salvaged Double Barrel"] = GetImage("Salvaged Double Barrel"),
		["Salvaged Shotgun"] = GetImage("Salvaged Shotgun"),
		["Pumpkin Launcher"] = GetImage("Pumpkin Launcher"),
		["Salvaged RPG"] = GetImage("Salvaged RPG"),

		["Steel Axe"] = GetImage("Steel Axe"),
		["Steel Pickaxe"] = GetImage("Steel Pickaxe"),
		["Wooden Spear"] = GetImage("Wooden Spear"),
		["Stone Spear"] = GetImage("Stone Spear"),
		["Small Medkit"] = GetImage("Small Medkit"),
		["Military Grenade"] = GetImage("Military Grenade"),
		["Military Grenade Launcher"] = GetImage("Military Grenade Launcher"),

		["Chainsaw"] = GetImage("Chainsaw"),
		["Mining Drill"] = GetImage("Mining Drill"),
	},

	ItemList = {
		"Bandage",
		"Blueprint",
		"Wooden External Wall",
		"Stone External Wall",
		"Barricade",
		"Care Package Signal",
		"Salvaged Skorpion",
		"Salvaged P250",
		"Salvaged AK47",
		"Salvaged Python",
		"Salvaged AK74u",
		"Wooden Bow",
		"Nail Gun",
		"Salvaged SMG",
		"Crossbow",
		"Salvaged M14",
		"Salvaged Sniper",
		"Military M4A1",
		"Bruno's M4A1",
		"Military USP",
		"Salvaged Pump Action",
		"Military Barrett",
		"Military PKM",
		"Salvaged Break Action",
		"Salvaged Pipe Rifle",
		"Salvaged Double Barrel",
		"Salvaged Shotgun",
		"Pumpkin Launcher",
		"Salvaged RPG",

		"Iron Shard Pickaxe",
		"Iron Shard Hatchet",
		"Stone Hatchet",
		"Stone Pickaxe",
		"Steel Axe",
		"Steel Pickaxe",
		"Wooden Spear",
		"Stone Spear",
		"Small Medkit",
		"Military Grenade",
		"Military Grenade Launcher",

		"Chainsaw",
		"Mining Drill",
	},

	OffscreenImages = {
		["GlowingArrow"] = "",
		["GlowingArc"] = "",
		["Arc"] = "",
		["Arrow"] = "",
		["OpaqueArrow"] = "",
	},

	IgnoreNames = {
		["HumanoidRootPart"] = true,
	},
	Font = Fonts.Pixel,
	FontSize = 10.00,
}

Log("Initialized EntityClass object")

local Math = {}
local Visuals = {}
local Globals = {}

Log("Initialized tables")

Globals.LastArmorCheck = tick()
Globals.ArmorIds = {}
Globals.ArmorNames = {}
Globals.FlaggedStaff = {}
Globals.QuickStackFunctions = {}

Globals.ApplyTextStroke = phNV(function(Object) LPH_ATTRIBUTES(VM(NONE)) 
	local NewStroke = Globals:Instance("UIStroke", {
		Parent = Object,
		Thickness = 1,
		Color = Color3.fromRGB(),
	})
	return NewStroke
end)

Globals.DeepCopy = phNV(function(Table) LPH_ATTRIBUTES(VM(NONE)) 
	local Copy = {}
	for k, v in pairs(Table) do
		if type(v) == "table" then
			Copy[k] = Globals.DeepCopy(v)
		else
			Copy[k] = v
		end
	end
	return Copy
end)

function Globals:TweenTransparencyIns(container, targetTransparency, duration)
	duration = duration or 0.2
	for _, obj in ipairs(container:GetDescendants()) do
		if obj:IsA("GuiObject") then
			local props = {}

			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				props.TextTransparency = targetTransparency
			end

			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				props.ImageTransparency = targetTransparency
			end

			if obj.BackgroundTransparency ~= nil then
				props.BackgroundTransparency = targetTransparency
			end

			Globals:Tween(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
		end

		if obj:IsA("UIStroke") then
			Globals:Tween(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = targetTransparency,
			})
		end
	end

	if container:IsA("GuiObject") then
		Globals:Tween(container, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
			BackgroundTransparency = targetTransparency,
		})
	end
end

function Globals:Tween(...)
	local NewTween = TweenService:Create(...)
	NewTween:Play()
	return NewTween
end

function Globals:Instance(Class, Properties)
	local Element = Instance.new(Class)

	for Key, Value in Properties do
		Element[Key] = Value
	end

	return Element
end

function Globals:Tween(...)
	local Tween = TweenService:Create(...)
	Tween:Play()
	return Tween
end

if ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Items") then
	local Items = Globals.DeepCopy(require(ReplicatedStorage.Modules.Items))
	for Index, ItemData in Items do
		if ItemData.Type == "Armor" then
			Globals.ArmorIds[Index] = {
				Name = ItemData.Name,
			}
		end
	end

	Globals.ItemInfoTable = Items
end

Log("Loaded globals library")

Library.Theme = Theme
Library.__index = Library

Library.Notifications = Globals:Instance("ScreenGui", {
	Parent = CoreGui,
	DisplayOrder = 1,
	IgnoreGuiInset = true,
})

Library.HeadsUp = Globals:Instance("ScreenGui", {
	Parent = CoreGui,
	DisplayOrder = 1,
	IgnoreGuiInset = true,
	Enabled = true,
})

phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
	function Library:Connection(Name, Signal, Function)
		local Connection = Signal:Connect(Function)

		self.Connections[Name] = {
			Signal = Signal,
			Function = Function,
			Connection = Connection,
		}

		return self.Connections[Name]
	end

	function Library:Disconnect(Name)
		local Conn = self.Connections[Name]
		if Conn then
			Conn.Connection:Disconnect()
			self.Connections[Name] = nil
		end
	end

	function Library:DisconnectAll()
		for Name, Conn in pairs(self.Connections) do
			Conn.Connection:Disconnect()
		end
		table.clear(self.Connections)
	end

	function Library:DoCallback(Callback, Data)
		local Success, Error = pcall(Callback, Data)

		if not Success and Error then
			return "Failed", Error
		end
		return Success
	end

	function Library:FormatValue(incr, val)
		if incr < 1 then
			return string.format("%.2f", val)
		else
			return tostring(math.floor(val + 0.5))
		end
	end

	function Library:GetInputName(input)
		if input and input.UserInputType then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				return input.KeyCode.Name
			elseif input.UserInputType.Name:match("Mouse") then
				return input.UserInputType.Name
			else
				return "Unknown"
			end
		end
	end

	function Library:FormatKeyName(name)
		if Library.Keybinds[name] then
			return Library.Keybinds[name]
		elseif #name > 4 then
			return name:sub(1, 4)
		end

		return name
	end

	function Library:GetConfig()
		local Flags = self.Flags

		local Save = {}
		for Flag, Data in Flags do
			local Class = Data.Class
			local Value = Data.Value

			if Class == "Toggle" then
				Save[Flag] = Value
			end

			if Class == "Colorpicker" then
				Save[Flag] = {
					[1] = { Value[1].R, Value[1].G, Value[1].B },
					[2] = Value[2],
				}
			end

			if Class == "Slider" then
				Save[Flag] = Value
			end

			if Class == "TextBox" then
				Save[Flag] = Value
			end

			if Class == "Dropdown" then
				Save[Flag] = Value
			end

			if Class == "Keybind" then
				if Data.Key then
					local Key = {
						Type = Data.Key.Type,
						Value = Data.Key.Value.Name,
					}

					Save[Flag] = Key
				end
			end
		end

		return HttpService:JSONEncode(Save)
	end

	function Library:SaveConfig(Name)
		local CurrentConfig = Library:GetConfig()

		writefile(ConfigsFolder .. "/" .. Name .. ".json", CurrentConfig)
	end

	function Library:LoadConfig(Name)
		local FilePath = ConfigsFolder .. "/" .. Name .. ".json"

		if not isfile(FilePath) then
			Library:Notify(
				"Configuration failed to load\nFile, " .. FilePath .. " does not exist!",
				4,
				Color3.fromRGB(255, 0, 0)
			)
			return
		end

		local Config = readfile(FilePath)
		local okJ, DecodedConfig = pcall(HttpService.JSONDecode, HttpService, Config)
		if not okJ or type(DecodedConfig) ~= "table" then
			Library:Notify("Configuration failed to load\nFile is corrupted", 4, Color3.fromRGB(255, 0, 0))
			return
		end

		for Flag, FlagData in DecodedConfig do
			local RealFlag = Library.Flags[Flag]

			if not RealFlag or type(RealFlag) ~= "table" or type(RealFlag.Set) ~= "function" then
				continue
			end

			if RealFlag.Class == "Colorpicker" then
				local Color = Color3.new(FlagData[1][1], FlagData[1][2], FlagData[1][3])
				task.spawn(function()
					RealFlag:Set({
						Color,
						FlagData[2],
					})
				end)

				continue
			end

			if RealFlag.Class == "Keybind" then
				task.spawn(function()
					local KeyData = FlagData

					local input = {}

					if KeyData.Type == "MouseButton" then
						input.UserInputType = Enum.UserInputType[KeyData.Value]
					elseif KeyData.Type == "KeyCode" then
						input.UserInputType = Enum.UserInputType.Keyboard
						input.KeyCode = Enum.KeyCode[KeyData.Value]
					else
						input.UserInputType = Enum.UserInputType[KeyData.Value]
					end

					RealFlag:SetKey(input)
				end)
				continue
			end

			task.spawn(function()
				pcall(function()
					RealFlag:Set(FlagData)
				end)
			end)
		end
		Library:Notify("Configuration loaded", 3)
	end
end)()

phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
	function Library:CreateHotkeysPanel()
		local Hotkeys = {
			Keys = 0,
		}

		local Components = {}

		Hotkeys.__index = Hotkeys

		Components["Hotkeys"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(8, 12, 18),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 20, 0.5, 0),
			Size = UDim2.new(0, 215, 0, 30),
			Name = "Hotkeys",
			Parent = Library.HeadsUp,
			Visible = false,
		})

		Components["HotkeysCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "HotkeysCorner",
			Parent = Components["Hotkeys"],
		})

		Components["HotkeysStroke"] = Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Name = "HotkeysStroke",
			Parent = Components["Hotkeys"],
		})

		Components["HotkeysTitleArea"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 21, 29),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 25),
			Name = "HotkeysTitleArea",
			Parent = Components["Hotkeys"],
		})

		Components["HotkeysTitleCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "HotkeysTitleCorner",
			Parent = Components["HotkeysTitleArea"],
		})

		Components["HotkeysTitlestroke"] = Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Name = "HotkeysTitlestroke",
			Parent = Components["HotkeysTitleArea"],
		})

		Components["HotkeysTitle"] = Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansSemibold,
			Text = "Hotkeys",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 35, 0, 0),
			Size = UDim2.new(1, -35, 1, 0),
			Name = "HotkeysTitle",
			Parent = Components["HotkeysTitleArea"],
		})

		Components["HotkeysImage"] = Globals:Instance("ImageLabel", {
			Image = Library.HotKeysImage,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 5, 0.5, 0),
			Size = UDim2.new(0.0116279069, 20, 1, -5),
			Name = "HotkeysImage",
			Parent = Components["HotkeysTitleArea"],
		})

		Components["HotkeysActive"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 30),
			Size = UDim2.new(1, -10, 0, 33),
			Name = "HotkeysActive",
			Parent = Components["Hotkeys"],
		})

		Components["UIListLayout"] = Globals:Instance("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Components["HotkeysActive"],
		})

		Components["HotkeysShadowHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0,
			Name = "HotkeysShadowHolder",
			Parent = Components["Hotkeys"],
		})

		Components["HotkeysShadow"] = Globals:Instance("ImageLabel", {
			Image = Library.ShadowImage,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = 0.8,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 47, 1, 47),
			ZIndex = 0,
			Name = "HotkeysShadow",
			Parent = Components["HotkeysShadowHolder"],
		})

		Hotkeys.Components = Components

		function Hotkeys:Add(Name, Key)
			self.Keys += 1
			Globals:Tween(self.Components.HotkeysShadow, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				ImageTransparency = self.Keys > 0 and 0 or 0.8,
			})

			local Hotkey = {}

			Hotkey["Container"] = Globals:Instance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 14),
				Name = Name,
				Parent = Components["HotkeysActive"],
			})

			Hotkey["NameLabel"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = Name,
				TextColor3 = Color3.fromRGB(125, 158, 169),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Name = "NameLabel",
				Parent = Hotkey.Container,
			})

			Hotkey["KeyLabel"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = "[" .. tostring(Key) .. "]",
				TextColor3 = Color3.fromRGB(125, 158, 169),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -5, 1, 0),
				Position = UDim2.new(0.5, -3, 0, 0),
				Name = "KeyLabel",
				Parent = Hotkey.Container,
			})

			Globals:Tween(self.Components.Hotkeys, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 215, 0, 45) + UDim2.new(0, 0, 0, self.Keys * 17),
			})

		end

		function Hotkeys:UpdateStatus(Name, On, Key, Destroy)
			local Container = self.Components["HotkeysActive"]:FindFirstChild(Name)
			if Container then
				if Key and Key ~= "" then
					Container.KeyLabel.Text = "[" .. tostring(Key) .. "]"
				end

				local targetColor = On and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(125, 158, 169)
				Globals:Tween(Container.NameLabel, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
					TextColor3 = targetColor,
				})
				Globals:Tween(Container.KeyLabel, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
					TextColor3 = targetColor,
				})

				if Destroy then
					self.Keys -= 1
					Container:Destroy()

					Globals:Tween(
						self.Components.Hotkeys,
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							Size = UDim2.new(0, 215, 0, 45) + UDim2.new(0, 0, 0, self.Keys * 17),
						}
					)
				end
			else
				if Key ~= "" then
					self:Add(Name, Key)
				end
			end

			Globals:Tween(self.Components.HotkeysShadow, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				ImageTransparency = self.Keys > 0 and 0 or 0.8,
			})
		end

		return Hotkeys
	end

	function Library:CreateModeratorsPanel()
		local Moderators = {
			Count = 0,
		}

		local Components = {}

		Moderators.__index = Moderators

		Components["Moderators"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(8, 12, 18),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 20, 0.5, 200),
			Size = UDim2.new(0, 215, 0, 30),
			Name = "Moderators",
			Parent = Library.HeadsUp,
			Visible = true,
		})

		Components["ModeratorsCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "ModeratorsCorner",
			Parent = Components["Moderators"],
		})

		Components["ModeratorsStroke"] = Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Name = "ModeratorsStroke",
			Parent = Components["Moderators"],
		})

		Components["ModeratorsTitleArea"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 21, 29),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 25),
			Name = "ModeratorsTitleArea",
			Parent = Components["Moderators"],
		})

		Components["ModeratorsTitleCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "ModeratorsTitleCorner",
			Parent = Components["ModeratorsTitleArea"],
		})

		Components["ModeratorsTitlestroke"] = Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Name = "ModeratorsTitlestroke",
			Parent = Components["ModeratorsTitleArea"],
		})

		Components["ModeratorsTitle"] = Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansSemibold,
			Text = "Moderators",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 25, 0, 0),
			Size = UDim2.new(1, -35, 1, 0),
			Name = "ModeratorsTitle",
			Parent = Components["ModeratorsTitleArea"],
		})

		Components["ModeratorsImage"] = Globals:Instance("ImageLabel", {
			Image = Library.ModeratorImage,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 5, 0.5, 0),
			Size = UDim2.new(0, 15, 1, -10),
			Name = "ModeratorsImage",
			Parent = Components["ModeratorsTitleArea"],
		})

		Components["ModeratorsList"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 30),
			Size = UDim2.new(1, -10, 0, 33),
			Name = "ModeratorsList",
			Parent = Components["Moderators"],
		})

		Components["UIListLayout"] = Globals:Instance("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Components["ModeratorsList"],
		})

		Components["ModeratorsShadowHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0,
			Name = "ModeratorsShadowHolder",
			Parent = Components["Moderators"],
		})

		Components["ModeratorsShadow"] = Globals:Instance("ImageLabel", {
			Image = Library.ShadowImage,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = 0.8,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 47, 1, 47),
			ZIndex = 0,
			Name = "ModeratorsShadow",
			Parent = Components["ModeratorsShadowHolder"],
		})

		Moderators.Components = Components

		function Moderators:Add(Name, Role)
			self.Count += 1

			Globals:Tween(
				self.Components.ModeratorsShadow,
				TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
				{
					ImageTransparency = self.Count > 0 and 0 or 0.8,
				}
			)

			local Moderator = {}

			Moderator["Container"] = Globals:Instance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 14),
				Name = Name,
				Parent = Components["ModeratorsList"],
			})

			Moderator["NameLabel"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Name = "NameLabel",
				Parent = Moderator.Container,
			})

			Moderator["RoleLabel"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = Role,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -5, 1, 0),
				Position = UDim2.new(0.5, -3, 0, 0),
				Name = "RoleLabel",
				Parent = Moderator.Container,
			})

			Globals:Tween(self.Components.Moderators, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 215, 0, 30) + UDim2.new(0, 0, 0, self.Count * 19),
			})
		end

		function Moderators:UpdateModerator(Name, Role, Remove)
			local Container = self.Components["ModeratorsList"]:FindFirstChild(Name)

			if Container then
				if Role then
					Container.RoleLabel.Text = Role
				end

				if Remove then
					self.Count -= 1
					Container:Destroy()

					Globals:Tween(
						self.Components.Moderators,
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							Size = UDim2.new(0, 215, 0, 30) + UDim2.new(0, 0, 0, self.Count * 19),
						}
					)
				end
			else
				if Name and Role then
					self:Add(Name, Role)
				end
			end

			Globals:Tween(
				self.Components.ModeratorsShadow,
				TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
				{
					ImageTransparency = self.Count > 0 and 0 or 0.8,
				}
			)
		end

		function Moderators:ClearAll()
			for _, child in ipairs(self.Components["ModeratorsList"]:GetChildren()) do
				if child:IsA("TextLabel") then
					child:Destroy()
				end
			end
			self.Count = 0

			Globals:Tween(self.Components.Moderators, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 215, 0, 45),
			})

			Globals:Tween(
				self.Components.ModeratorsShadow,
				TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
				{
					ImageTransparency = 0.8,
				}
			)
		end

		return Moderators
	end

	function Library:CreateArmorPanel()
		local Armor = {
			Count = 0,
		}

		local Components = {}

		Armor.__index = Armor

		Components["Armor"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(8, 12, 18),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -245, 0.5, 0),
			Size = UDim2.new(0, 215, 0, 30),
			Name = "Armor",
			Parent = Library.HeadsUp,
			Visible = true,
		})

		Components["ArmorCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "ArmorCorner",
			Parent = Components["Armor"],
		})

		Components["ArmorStroke"] = Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Name = "ArmorStroke",
			Parent = Components["Armor"],
		})

		Components["ArmorTitleArea"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 21, 29),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 25),
			Name = "ArmorTitleArea",
			Parent = Components["Armor"],
		})

		Components["ArmorTitleCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "ArmorTitleCorner",
			Parent = Components["ArmorTitleArea"],
		})

		Components["ArmorTitlestroke"] = Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Name = "ArmorTitlestroke",
			Parent = Components["ArmorTitleArea"],
		})

		Components["ArmorTitle"] = Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansSemibold,
			Text = "Armor Viewer",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 25, 0, 0),
			Size = UDim2.new(1, -35, 1, 0),
			Name = "ArmorTitle",
			Parent = Components["ArmorTitleArea"],
		})

		Components["ArmorImage"] = Globals:Instance("ImageLabel", {
			Image = Library.ArmorImage,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 5, 0.5, 0),
			Size = UDim2.new(0, 15, 1, -10),
			Name = "ArmorImage",
			Parent = Components["ArmorTitleArea"],
		})

		Components["ArmorList"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 30),
			Size = UDim2.new(1, -10, 0, 33),
			Name = "ArmorList",
			Parent = Components["Armor"],
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true,
		})

		Components["UIListLayout"] = Globals:Instance("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Components["ArmorList"],
		})

		Components["ArmorShadowHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0,
			Name = "ArmorShadowHolder",
			Parent = Components["Armor"],
		})

		Components["ArmorShadow"] = Globals:Instance("ImageLabel", {
			Image = Library.ShadowImage,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = 0.8,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 47, 1, 47),
			ZIndex = 0,
			Name = "ArmorShadow",
			Parent = Components["ArmorShadowHolder"],
		})

		Armor.Components = Components

		function Armor:Add(ArmorName, ArmorSkin)
			if not self.Components.ArmorList:FindFirstChild(ArmorName .. "_" .. ArmorSkin) then
				self.Count += 1

				Globals:Tween(
					self.Components.ArmorShadow,
					TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
					{
						ImageTransparency = self.Count > 0 and 0 or 0.8,
					}
				)

				local ArmorEntry = {}

				ArmorEntry["Container"] = Globals:Instance("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 14),
					Name = ArmorName .. "_" .. ArmorSkin,
					Parent = Components["ArmorList"],
				})

				ArmorEntry.Container:SetAttribute("IsContainer", true)

				ArmorEntry["PlayerLabel"] = Globals:Instance("TextLabel", {
					Font = Enum.Font.SourceSansSemibold,
					Text = ArmorName,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					Name = "PlayerLabel",
					Parent = ArmorEntry.Container,
				})

				ArmorEntry["SkinLabel"] = Globals:Instance("TextLabel", {
					Font = Enum.Font.SourceSansSemibold,
					Text = ArmorSkin,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Right,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, -5, 1, 0),
					Position = UDim2.new(0.5, -3, 0, 0),
					Name = "SkinLabel",
					Parent = ArmorEntry.Container,
				})

				Globals:Tween(self.Components.Armor, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
					Size = UDim2.new(0, 215, 0, 30) + UDim2.new(0, 0, 0, self.Count * 19),
				})
			end
		end

		function Armor:UpdateArmor(ArmorName, ArmorSkin, Remove)
			local Container = self.Components["ArmorList"]:FindFirstChild(ArmorName)

			if Container then
				if ArmorSkin then
					Container.SkinLabel.Text = ArmorSkin
				end

				if Remove then
					self.Count -= 1
					Container:Destroy()

					Globals:Tween(self.Components.Armor, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
						Size = UDim2.new(0, 215, 0, 30) + UDim2.new(0, 0, 0, self.Count * 19),
					})
				end
			else
				if ArmorName and ArmorSkin then
					self:Add(ArmorName, ArmorSkin)
				end
			end

			Globals:Tween(self.Components.ArmorShadow, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				ImageTransparency = self.Count > 0 and 0 or 0.8,
			})
		end

		function Armor:ClearAll()
			for _, child in ipairs(self.Components["ArmorList"]:GetChildren()) do
				if child:IsA("Frame") and child:GetAttribute("IsContainer") then
					child:Destroy()
				end
			end
			self.Count = 0

			Globals:Tween(self.Components.Armor, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 215, 0, 45),
			})

			Globals:Tween(self.Components.ArmorShadow, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				ImageTransparency = 0.8,
			})
		end

		return Armor
	end

	function Library:CreateWatermark(txt)
		local Components = {}

		Components["Watermark"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(14, 21, 29),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 400, 0, 20),
			Size = UDim2.new(0, 35, 0, 24),
			Name = "Watermark",
			Parent = Library.HeadsUp,
		})

		Components["WatermarkCorner"] = Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Name = "WatermarkCorner",
			Parent = Components["Watermark"],
		})

		Components["WatermarkStroke"] = Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Name = "WatermarkStroke",
			Parent = Components["Watermark"],
		})

		Components["WatermarkLogo"] = Globals:Instance("ImageLabel", {
			Image = Library.LogoImage,
			Visible = false,
			ImageColor3 = Library.Theme.Accent,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 13, 0.5, 0),
			Size = UDim2.new(0, 25, 0, 25),
			Name = "WatermarkLogo",
			Parent = Components["Watermark"],
		})

		Components["WatermarkText"] = Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansSemibold,
			Text = txt,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 25, 0, 0),
			Size = UDim2.new(0, 0, 1, 0),
			Name = "WatermarkText",
			Parent = Components["Watermark"],
		})

		Components["WatermarkShadowHolder"] = Globals:Instance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0,
			Name = "WatermarkShadowHolder",
			Parent = Components["Watermark"],
		})

		Components["WatermarkShadow"] = Globals:Instance("ImageLabel", {
			Image = Library.ShadowImage,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.5899999737739563,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.505405426, 0, 0.501500428, 0),
			Size = UDim2.new(0.935135126, 47, 0.5, 47),
			ZIndex = 0,
			Name = "WatermarkShadow",
			Parent = Components["WatermarkShadowHolder"],
		})

		function Components:SetText(txt)
			local label = Instance.new("TextLabel")
			label.Text = txt
			label.TextSize = 14
			label.Font = Enum.Font.SourceSansSemibold
			label.Position = UDim2.new(-5, 0, 0, 0)
			label.Visible = true
			label.Parent = Library.HeadsUp
			task.wait(0.3)
			Components["WatermarkText"].Text = ""

			task.spawn(function()
				for i = 1, #txt do
					Components["WatermarkText"].Text = string.sub(txt, 1, i)
					task.wait(0.03)
				end
			end)

			local TextBounds = label.TextBounds
			Globals:Tween(Components.Watermark, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 35 + TextBounds.X, 0, Components.Watermark.Size.Y.Offset),
			})
		end
		return Components
	end

	function Library:CreateLoader(Data)
		local Loader = {
			Expiry = Data.Expiry,
		}
		Loader.__index = Loader

		local Components = {}

		local SelectedGame = ""
		local SelectedType = ""

		do
			Components["Loader"] = Globals:Instance("ScreenGui", {
				IgnoreGuiInset = true,
				Name = "Loader",
				Parent = CoreGui,
			})

			Components["LoaderOutline"] = Globals:Instance("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(8, 12, 18),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 2, 0),
				Size = UDim2.new(0, 400, 0, 329),
				Name = "LoaderOutline",
				Parent = Components["Loader"],
			})

			Components["LoaderUICorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Name = "LoaderUICorner",
				Parent = Components["LoaderOutline"],
			})

			Components["LoaderUIStroke"] = Globals:Instance("UIStroke", {
				Color = Color3.fromRGB(28, 43, 53),
				Name = "LoaderUIStroke",
				Parent = Components["LoaderOutline"],
			})

			Components["DropShadowHolder"] = Globals:Instance("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Name = "DropShadowHolder",
				Parent = Components["LoaderOutline"],
			})

			Components["DropShadow"] = Globals:Instance("ImageLabel", {
				Image = Library.ShadowImage,
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ImageTransparency = 0.12,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(49, 49, 450, 450),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 47, 1, 47),
				ZIndex = 0,
				Name = "DropShadow",
				Parent = Components["DropShadowHolder"],
			})

			Components["LoaderTitleArea"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				Name = "LoaderTitleArea",
				Parent = Components["LoaderOutline"],
			})

			Components["LoaderTitleCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Name = "LoaderTitleCorner",
				Parent = Components["LoaderTitleArea"],
			})

			Components["LoaderTitleOutline"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(28, 43, 53),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, 1),
				Name = "LoaderTitleOutline",
				Parent = Components["LoaderTitleArea"],
			})

			Components["BurmaldaLogo"] = Globals:Instance("ImageLabel", {
				Image = Library.LogoImage,
				Visible = false,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 3, 0.5, 0),
				Size = UDim2.new(0, 25, 0, 25),
				Name = "BurmaldaLogo",
				Parent = Components["LoaderTitleArea"],
			})

			Components["BurmaldaTitle"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansBold,
				Text = "Burmalda.hook",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 30, 0, 0),
				Size = UDim2.new(0, 200, 1, 0),
				Name = "BurmaldaTitle",
				Parent = Components["LoaderTitleArea"],
			})

			Components["Workspace"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 20, 0, 50),
				Size = UDim2.new(1, -40, 1, -70),
				Name = "Workspace",
				Parent = Components["LoaderOutline"],
			})

			Components["WorkspaceHider"] = Components["Workspace"]:Clone()
			Components["WorkspaceHider"].Parent = Components["LoaderOutline"]
			Components["WorkspaceHider"].Size = UDim2.new(1, 0, 1, -30)
			Components["WorkspaceHider"].AnchorPoint = Vector2.new(0, 0)
			Components["WorkspaceHider"].Position = UDim2.new(0, 0, 0, 30)
			Components.WorkspaceHider.Name = "WorkspaceHider"
			Components.WorkspaceHider.ZIndex = 10
			Components.WorkspaceHider.BackgroundColor3 = Color3.fromRGB(8, 12, 18)

			Components["Products"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, -5, 0, 0),
				Size = UDim2.new(0, 175, 1, 0),
				Name = "Products",
				Parent = Components["Workspace"],
			})

			Components["ProductsLayout"] = Globals:Instance("UIListLayout", {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Name = "ProductsLayout",
				Parent = Components["Products"],
			})

			Components["GameStatus1"] = Globals:Instance("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 191, 0, 0),
				Size = UDim2.new(0, 175, 1, 0),
				Name = "GameStatus",
				Parent = Components["Workspace"],
			})

			Components["GameImageArea"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 125),
				Name = "GameImageArea",
				Parent = Components["GameStatus1"],
			})

			Components["GameImageAreaCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = Components["GameImageArea"],
			})

			Components["GameImageAreaStroke"] = Globals:Instance("UIStroke", {
				Color = Color3.fromRGB(28, 43, 53),
				Parent = Components["GameImageArea"],
			})

			Components["GameImage1"] = Globals:Instance("ImageLabel", {
				Image = "",
				ImageTransparency = 0.4,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -10, 1, -10),
				Name = "GameImage",
				Parent = Components["GameImageArea"],
			})

			Components["GameImageCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = Components["GameImage1"],
			})

			Components["GameImageStroke"] = Globals:Instance("UIStroke", {
				Color = Color3.fromRGB(28, 43, 53),
				Parent = Components["GameImage1"],
			})

			Components["GameDetectedStatus"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 135),
				Size = UDim2.new(1, 0, 0, 36),
				Name = "GameDetectedStatus",
				Parent = Components["GameStatus1"],
			})

			Components["GameDetectedStatusCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = Components["GameDetectedStatus"],
			})

			Components["GameDetectedStatusStroke"] = Globals:Instance("UIStroke", {
				Color = Color3.fromRGB(28, 43, 53),
				Parent = Components["GameDetectedStatus"],
			})

			Components["Status"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansBold,
				Text = "Undetected",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 5, 0, 16),
				Size = UDim2.new(1, -20, 0, 20),
				Name = "Status",
				Parent = Components["GameDetectedStatus"],
			})

			Components["StatusTitle"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = "S T A T U S",
				TextColor3 = Color3.fromRGB(125, 158, 169),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 5, 0, 1),
				Size = UDim2.new(1, -20, 0, 20),
				Name = "StatusTitle",
				Parent = Components["GameDetectedStatus"],
			})

			Components["Expiry"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 180),
				Size = UDim2.new(1, 0, 0, 36),
				Name = "Expiry",
				Parent = Components["GameStatus1"],
			})

			Components["ExpiryCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = Components["Expiry"],
			})

			Components["ExpiryStroke"] = Globals:Instance("UIStroke", {
				Color = Color3.fromRGB(28, 43, 53),
				Parent = Components["Expiry"],
			})

			Components["ExpiryDate"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansBold,
				Text = "7/30/26",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 5, 0, 16),
				Size = UDim2.new(1, -20, 0, 20),
				Name = "ExpiryDate",
				Parent = Components["Expiry"],
			})

			Components["ExpiryTitle"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = Loader.Expiry,
				TextColor3 = Color3.fromRGB(125, 158, 169),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 5, 0, 1),
				Size = UDim2.new(1, -20, 0, 20),
				Name = "ExpiryTitle",
				Parent = Components["Expiry"],
				Text = "E X P I R Y",
			})

			Components["LaunchButton"] = Globals:Instance("TextButton", {
				Font = Enum.Font.SourceSansBold,
				Text = "Launch",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 227),
				Size = UDim2.new(1, 0, 0, 40),
				Name = "LaunchButton",
				Parent = Components["GameStatus1"],
			})

			Components["LaunchStroke"] = Globals:Instance("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(28, 43, 53),
				Parent = Components["LaunchButton"],
			})

			Components["LaunchCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = Components["LaunchButton"],
			})

			task.wait(0.15)

			Globals:Tween(Components.LoaderOutline, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				Position = UDim2.new(0.5, 0, 0.5, 0),
			})

			Library:Connection("LaunchDown", Components.LaunchButton.MouseButton1Down, function()
				task.spawn(function()
					Globals:Tween(
						Components.LaunchStroke,
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							Color = Library.Theme.Accent,
						}
					)
					Globals:Tween(
						Components["LaunchButton"],
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							BackgroundColor3 = Library.Theme.Accent,
						}
					)
					task.wait(0.2)
					Globals:Tween(
						Components["LaunchButton"],
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							BackgroundColor3 = Color3.fromRGB(14, 21, 29),
						}
					)
				end)

				Loader:Launch(SelectedGame, SelectedType)
			end)

			Library:Connection("LaunchEnter", Components.LaunchButton.MouseEnter, function()
				Globals:Tween(Components.LaunchStroke, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
					Color = Library.Theme.Accent,
				})
			end)

			Library:Connection("LaunchLeave", Components.LaunchButton.MouseLeave, function()
				Globals:Tween(Components.LaunchStroke, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
					Color = Color3.fromRGB(28, 43, 53),
				})
			end)
		end

		local Selected

		function Loader:NewGame(Name, Type, Image)
			local GameComponents = {}

			GameComponents["NewGame"] = Globals:Instance("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderSizePixel = 0,
				Position = UDim2.new(0.05, 0, 0.00619195, 0),
				Size = UDim2.new(1, 0, 0.0247678, 50),
				Name = "NewGame",
				Parent = Components["Products"],
			})

			GameComponents["NewGameCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Name = "NewGameCorner",
				Parent = GameComponents["NewGame"],
			})

			GameComponents["NewGameStroke"] = Globals:Instance("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(28, 43, 53),
				Name = "NewGameStroke",
				Parent = GameComponents["NewGame"],
			})

			GameComponents["GameTitle"] = Globals:Instance("TextLabel", {
				Font = Enum.Font.SourceSansSemibold,
				Text = Name .. " " .. Type,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, 36),
				Size = UDim2.new(1, -10, 0, 10),
				ZIndex = 2,
				Name = "GameTitle",
				Parent = GameComponents["NewGame"],
			})

			GameComponents["GameImage"] = Globals:Instance("ImageLabel", {
				Image = Image,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, 5),
				Size = UDim2.new(0, 20, 0, 20),
				ZIndex = 2,
				Name = "GameImage",
				Parent = GameComponents["NewGame"],
			})

			GameComponents["UICorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = GameComponents["GameImage"],
			})

			GameComponents["GameStatus"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(41, 255, 130),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 35, 0, 10),
				Size = UDim2.new(0, 10, 0, 10),
				Name = "GameStatus",
				Parent = GameComponents["NewGame"],
			})

			GameComponents["UICorner1"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = GameComponents["GameStatus"],
			})

			Library:Connection(Name .. Type .. "Down", GameComponents.NewGame.MouseButton1Down, function()
				Selected = GameComponents.NewGame
				SelectedGame = Name
				SelectedType = Type

				for Index, GameButton in Components.Products:GetChildren() do
					if GameButton.Name == "NewGame" then
						local Stroke = GameButton:FindFirstChild("NewGameStroke")

						Globals:Tween(GameButton, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
							BackgroundColor3 = Color3.fromRGB(14, 21, 29),
						})

						Globals:Tween(Stroke, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
							Color = Color3.fromRGB(28, 43, 53),
						})
					end
				end

				task.spawn(function()
					Globals:Tween(
						GameComponents.NewGameStroke,
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							Color = Library.Theme.Accent,
						}
					)
					Globals:Tween(
						GameComponents.NewGame,
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							BackgroundColor3 = Library.Theme.Accent,
						}
					)
					task.wait(0.2)
					Globals:Tween(
						GameComponents.NewGame,
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							BackgroundColor3 = Color3.fromRGB(14, 21, 29),
						}
					)
				end)

				task.spawn(function()
					Globals:Tween(Components["GameImage1"], TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
						ImageTransparency = 1,
					})
					task.wait(0.15)
					Components["GameImage1"].Image = Image
					Globals:Tween(Components["GameImage1"], TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
						ImageTransparency = 0.4,
					})
				end)
			end)

			Library:Connection(Name .. Type .. "Enter", GameComponents.NewGame.MouseEnter, function()
				Globals:Tween(
					GameComponents.NewGameStroke,
					TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
					{
						Color = Library.Theme.Accent,
					}
				)
			end)

			Library:Connection(Name .. Type .. "Leave", GameComponents.NewGame.MouseLeave, function()
				if Selected ~= GameComponents.NewGame then
					Globals:Tween(
						GameComponents.NewGameStroke,
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							Color = Color3.fromRGB(28, 43, 53),
						}
					)
				end
			end)
		end

		function Loader:SetProgress(num)
			Globals:Tween(Components["Progess"], TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
				Size = UDim2.new(num / 100, 0, 1, 0),
			})

			Components["ProgressPercent"].Text = tostring(math.floor(num)) .. "%"
		end

		function Loader:SetStage(stage)
			Components["ProgressStage"].Text = "Burmalda.hook | " .. stage
		end

		function Loader:Launch(Game, Type)
			HookingEnabled = Type ~= "Lite"
			task.wait(0.2)
			local HideTween = Globals:Tween(Components.WorkspaceHider, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0,
			})
			task.spawn(function()
				task.wait(0.15)
				Globals:Tween(Components.LoaderOutline, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Size = UDim2.new(0, 400, 0, 200),
				})
			end)

			HideTween.Completed:Wait()
			for _, Obj in Components.Workspace:GetChildren() do
				Obj:Destroy()
			end
			task.wait(0.3)

			do
				Components["ProgressBar"] = Globals:Instance("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(14, 21, 29),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, 20),
					Size = UDim2.new(0, 200, 0, 20),
					Name = "ProgressBar",
					Parent = Components["LoaderOutline"],
				})

				Components["ProgressBarStroke"] = Globals:Instance("UIStroke", {
					Color = Color3.fromRGB(28, 43, 53),
					Name = "ProgressBarStroke",
					Parent = Components["ProgressBar"],
				})

				Components["ProgressBarCorner"] = Globals:Instance("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Name = "ProgressBarCorner",
					Parent = Components["ProgressBar"],
				})

				Components["Progess"] = Globals:Instance("Frame", {
					BackgroundColor3 = Color3.fromRGB(94, 225, 211),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0),
					Name = "Progess",
					Parent = Components["ProgressBar"],
				})

				Components["ProgessCorner"] = Globals:Instance("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Name = "ProgessCorner",
					Parent = Components["Progess"],
				})

				Components["ProgressPercent"] = Globals:Instance("TextLabel", {
					Font = Enum.Font.SourceSansBold,
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					Name = "ProgressPercent",
					Parent = Components["ProgressBar"],
				})

				Components["ProgressPercentStroke"] = Globals:Instance("UIStroke", {
					Thickness = 0.9,
					Name = "ProgressPercentStroke",
					Parent = Components["ProgressPercent"],
				})

				Components["ProgressStage"] = Globals:Instance("TextLabel", {
					Font = Enum.Font.SourceSansBold,
					Text = "Burmalda",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, -1, -5),
					Size = UDim2.new(1, 0, 1, 0),
					Name = "ProgressStage",
					Parent = Components["ProgressBar"],
				})

				Components["BurmaldaLogo"] = Globals:Instance("ImageLabel", {
					Image = Library.LogoImage,
					Visible = false,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, -45),
					Size = UDim2.new(0, 25, 0, 25),
					Name = "BurmaldaLogo",
					Parent = Components["ProgressBar"],
				})
			end

			LoaderLaunched = true
			Loader.BeginLoading = true

			Globals:Tween(Components.WorkspaceHider, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 1,
			})

			task.spawn(function()
				while Components.ProgressStage do
					task.wait()
					if Components.ProgressStage:GetAttribute("Tweening") then
						break
					end
					Components.ProgressStage.TextTransparency = math.sin(tick() * 3) + 1 / 2
				end
			end)
		end

		Loader.Components = Components
		return Loader
	end

	function Library:Window(WindowData)
		local Window = {
			Name = WindowData.Name,
			Tabs = {},
			Sections = {},
			Components = {},
			PlayerImage = WindowData.PlayerImage,
			Open = true,
			IsOpen = true,
		}

		Library.IsOpen = true

		Window.ArmorPanel = self:CreateArmorPanel()
		Window.ModPanel = self:CreateModeratorsPanel()
		Window.Hotkeys = self:CreateHotkeysPanel()
		Window.__index = Window

		local Components = {}

		do
			Components["UI"] = Globals:Instance("ScreenGui", {
				IgnoreGuiInset = true,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				Name = "UI",
				Parent = CoreGui,
				DisplayOrder = 3,
			})

			Components["Outline"] = Globals:Instance("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(8, 12, 18),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 3, 0),
				Size = UDim2.new(0, 650, 0, 470),
				Name = "Outline",
				Parent = Components["UI"],
			})

			Components["OutlineCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 8),
				Name = "OutlineCorner",
				Parent = Components["Outline"],
			})

			Components["OutlineGradient"] = Globals:Instance("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 28, 38)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 18)),
				}),
				Name = "OutlineGradient",
				Parent = Components["Outline"],
			})

			Components["OutlineStroke"] = Globals:Instance("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1.4,
				Color = Theme.Accent,
				Transparency = 0.15,
				Name = "OutlineStroke",
				Parent = Components["Outline"],
			})

			Components["OutlineStrokeGradient"] = Globals:Instance("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(94, 225, 211)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(157, 255, 234)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 164, 180)),
				}),
				Rotation = 0,
				Name = "OutlineStrokeGradient",
				Parent = Components["OutlineStroke"],
			})

			task.spawn(function()
				while Components["OutlineStrokeGradient"] and Components["OutlineStrokeGradient"].Parent do
					Components["OutlineStrokeGradient"].Rotation = (tick() * 45) % 360
					task.wait()
				end
			end)

			Components["WindowNotifications"] = Globals:Instance("Frame", {
				Position = UDim2.new(1, 0, 1, 0),
				AnchorPoint = Vector2.new(1, 1),
				Size = UDim2.new(0, 200, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Name = "Notifications",
				Parent = Components.Outline,
			})

			Components["LeftSideElements"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 50, 1, 0),
				Name = "LeftSideElements",
				Parent = Components["Outline"],
			})

			Components["LeftSideElmentsCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 8),
				Name = "LeftSideElmentsCorner",
				Parent = Components["LeftSideElements"],
			})

			Components["LeftSideFixIGNORE"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -2, 0, 0),
				Size = UDim2.new(0, 3, 1, 0),
				Name = "LeftSideFixIGNORE",
				Parent = Components["LeftSideElements"],
			})

			Components["LeftSideOutline"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(28, 43, 53),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 1, 1, 0),
				Name = "LeftSideOutline",
				Parent = Components["LeftSideFixIGNORE"],
			})

			Components["LogoSpace"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 50),
				Name = "LogoSpace",
				Parent = Components["LeftSideElements"],
			})

			Components["Logo"] = Globals:Instance("ImageLabel", {
				Image = Library.LogoImage,
				Visible = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -10, 1, -10),
				Name = "Logo",
				Parent = Components["LogoSpace"],
			})

			Components["TabsHolder"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 50),
				Size = UDim2.new(1, 0, 1, -106),
				Name = "TabsHolder",
				Parent = Components["LeftSideElements"],
			})

			Components["TabsScrollingFrame"] = Globals:Instance("ScrollingFrame", {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(1, 0, 1, 0),
				ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
				ScrollBarImageTransparency = 1,
				ScrollBarThickness = 0,
				Active = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, -3),
				Size = UDim2.new(1, 0, 1, 3),
				Name = "TabsScrollingFrame",
				Parent = Components["TabsHolder"],
			})

			Components["ScrollingFrameListLayout"] = Globals:Instance("UIListLayout", {
				Padding = UDim.new(0, 13),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Name = "ScrollingFrameListLayout",
				Parent = Components["TabsScrollingFrame"],
			})

			Components["UIPadding"] = Globals:Instance("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 1),
				Parent = Components["TabsScrollingFrame"],
			})

			Components["TabFadeTop"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, -10),
				Size = UDim2.new(1, 0, 0, 20),
				Name = "TabFadeTop",
				Parent = Components["TabsHolder"],
			})

			Components["TabFadeTopGradient"] = Globals:Instance("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 21, 29)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 21, 29)),
				}),
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Name = "TabFadeTopGradient",
				Parent = Components["TabFadeTop"],
			})

			Components["TabFadeBottom"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -20),
				Size = UDim2.new(1, 0, 0, 20),
				Name = "TabFadeBottom",
				Parent = Components["TabsHolder"],
			})

			Components["TabFadeBottomGradient"] = Globals:Instance("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 21, 29)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 21, 29)),
				}),
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Name = "TabFadeBottomGradient",
				Parent = Components["TabFadeBottom"],
			})

			Components["PlayerIconHolder"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -50),
				Size = UDim2.new(1, 0, 0, 50),
				Name = "PlayerIconHolder",
				Parent = Components["LeftSideElements"],
			})

			Components["PlayerImageCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Name = "PlayerImageCorner",
				Parent = Components["PlayerImageButton"],
			})

			Components["TopSideElements"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 52, 0, 0),
				Size = UDim2.new(1, -52, 0, 50),
				Name = "TopSideElements",
				Parent = Components["Outline"],
				ClipsDescendants = true,
			})

			Components["TopSideElementsCorner"] = Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Name = "TopSideElementsCorner",
				Parent = Components["TopSideElements"],
			})

			Components["TopSideElementsFix"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(14, 21, 29),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -2),
				Size = UDim2.new(1, 0, 0, 3),
				Name = "TopSideElementsFix",
				Parent = Components["TopSideElements"],
			})

			Components["TopSideOutline"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(28, 43, 53),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				Name = "TopSideOutline",
				Parent = Components["TopSideElementsFix"],
			})

			Components["Categorys"] = Globals:Instance("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 15, 0.5, 0),
				Size = UDim2.new(1, -30, 1, -30),
				Name = "Categorys",
				Parent = Components["TopSideElements"],
			})

			Components["Pages"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 64, 0, 62),
				Size = UDim2.new(0, 573, 0, 395),
				Name = "Pages",
				Parent = Components["Outline"],
			})

			Components["PageHider"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(8, 12, 18),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 64, 0, 62),
				Size = UDim2.new(0, 573, 0, 395),
				Name = "PageHider",
				Parent = Components["Outline"],
			})

			Components["PageFadeBottom"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -20),
				Size = UDim2.new(1, 0, 0, 20),
				Name = "PageFadeBottom",
				Parent = Components["Pages"],
				ZIndex = 2000,
			})

			Components["PageFadeTopGradient"] = Globals:Instance("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 18)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 18)),
				}),
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.43, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Name = "PageFadeTopGradient",
				Parent = Components["PageFadeBottom"],
			})

			Components["PageFadeTop"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, -2),
				Size = UDim2.new(1, 0, 0, 20),
				Name = "PageFadeTop",
				Parent = Components["Pages"],
				ZIndex = 2000,
			})

			Components["PageFadeTopGradient1"] = Globals:Instance("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 18)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 18)),
				}),
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.43, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Name = "PageFadeTopGradient",
				Parent = Components["PageFadeTop"],
			})

			Components["OutlineShadowHolder"] = Globals:Instance("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 0,
				Name = "OutlineShadowHolder",
				Parent = Components["Outline"],
			})

			Components["OutlineShadow"] = Globals:Instance("ImageLabel", {
				Image = Library.OutlineShadowImage,
				ImageColor3 = Color3.fromRGB(0, 0, 0),

				ImageTransparency = 0.3,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(49, 49, 450, 450),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 47, 1, 47),
				ZIndex = 0,
				Name = "OutlineShadow",
				Parent = Components["OutlineShadowHolder"],
			})
		end

		do
			local Dragging = false
			local DragStart = nil
			local StartPosition = nil

			Components["Outline"].InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and not Window.InDrag then
					Dragging = true
					DragStart = input.Position
					StartPosition = Components["Outline"].Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							Dragging = false
						end
					end)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - DragStart
					local newPosition = UDim2.new(
						StartPosition.X.Scale,
						StartPosition.X.Offset + delta.X,
						StartPosition.Y.Scale,
						StartPosition.Y.Offset + delta.Y
					)

					TweenService:Create(
						Components["Outline"],
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = newPosition,
						}
					):Play()
				end
			end)

			UserInputService.InputBegan:Connect(function(inp)
				if inp.KeyCode == Enum.KeyCode.RightShift and not UserInputService:GetFocusedTextBox() then
					Window.Open = not Window.Open
					Library.IsOpen = Window.Open
					Window:SetVisibility(Window.Open)
				end
			end)
		end

		function Window:Notify(txt, duration)

		end

		function Window:OpenWindow()
			local outline = self.Components.Outline
			self.Components.UI.Enabled = true

			local currentX = outline.Position.X
			local targetPosition = UDim2.new(currentX.Scale, currentX.Offset, 0.5, 0)

			if self.CurrentTween then
				self.CurrentTween:Cancel()
				self.CurrentTween = nil
			end

			outline.Position =
				UDim2.new(currentX.Scale, currentX.Offset, outline.Position.Y.Scale, outline.Position.Y.Offset)

			self.CurrentTween = Globals:Tween(outline, TweenInfo.new(0.25), {
				Position = targetPosition,
			})

			local completedConnection
			completedConnection = self.CurrentTween.Completed:Connect(function()
				self.CurrentTween = nil
				self.IsOpen = true
				if completedConnection then
					completedConnection:Disconnect()
				end
			end)
		end

		function Window:Close()
			local outline = self.Components.Outline

			if self.CurrentTween then
				self.CurrentTween:Cancel()
				self.CurrentTween = nil
			end

			local currentX = outline.Position.X

			self.CurrentTween = Globals:Tween(outline, TweenInfo.new(0.25), {
				Position = UDim2.new(currentX.Scale, currentX.Offset, 2, 0),
			})

			local completedConnection
			completedConnection = self.CurrentTween.Completed:Connect(function()
				self.CurrentTween = nil
				self.Components.UI.Enabled = false
				self.IsOpen = false
				if completedConnection then
					completedConnection:Disconnect()
				end
			end)
		end

		function Window:SetVisibility(force)
			if self.CurrentTween then
				self.CurrentTween:Cancel()
				self.CurrentTween = nil
			end

			local TargetOpen = (force ~= nil) and force or not self.IsOpen
			self.Open = TargetOpen
			self.IsOpen = TargetOpen

			if TargetOpen then
				self:OpenWindow()
			else
				self:Close()
			end
		end

		function Window:SetTab(Tab)
			local TabsContainer = self.Components["TabsScrollingFrame"]
			local TabCategories = self.Components["Categorys"]
			local Pages = self.Components["Pages"]
			local FirstCategory = Tab.Categories[Tab.CategoryOrder[1]]
			local CatToSet

			task.spawn(function()
				Globals:Tween(
					self.Components.Categorys,
					TweenInfo.new(Library.CategoryTransitionSpeed, Enum.EasingStyle.Quad),
					{
						Position = UDim2.new(-0.7, 0, 0.5, 0),
					}
				)
			end)

			task.spawn(function()
				if FirstCategory then
					self:SetCategory({
						Pointer = FirstCategory,
						Name = FirstCategory.Parent.Name .. "_" .. FirstCategory.Name,
						Parent = FirstCategory.Parent,
					})
				end
			end)

			task.spawn(function()
				for _, TabButton in TabsContainer:GetChildren() do
					local Name = TabButton.Name
					local TabCategoryContainer = TabCategories:FindFirstChild(Name)
					if not TabCategoryContainer then
						continue
					end

					local Opened = Name == Tab.Name
					if Opened then
						CatToSet = TabCategoryContainer
					else
						task.spawn(function()
							task.wait(Library.CategoryPause)
							TabCategoryContainer.Visible = Opened
						end)
					end

					TabButton.TabImage:SetAttribute("Opened", Opened)

					Globals:Tween(TabButton.TabImage, TweenInfo.new(0.25), {
						ImageColor3 = Opened and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(125, 158, 169),
					})
				end
			end)

			task.spawn(function()
				task.wait(Library.CategoryPause)
				Globals:Tween(
					self.Components.Categorys,
					TweenInfo.new(Library.CategoryTransitionSpeed, Enum.EasingStyle.Quad),
					{
						Position = UDim2.new(0, 15, 0.5, 0),
					}
				)
				task.wait(0.1)
				CatToSet.Visible = true
			end)
		end

		function Window:SetCategory(Category)
			local Pointer = Category.Pointer
			local Components = Pointer.Components
			local Tab = Category.Parent
			local PageContainer = self.Components["Pages"]
			local hiderIn

			Components.CategoryButton:SetAttribute("Opened", true)

			task.spawn(function()
				hiderIn = Globals:Tween(
					self.Components.PageHider,
					TweenInfo.new(Library.PageTransitionSpeed, Enum.EasingStyle.Quad),
					{
						BackgroundTransparency = 0,
					}
				)
			end)

			task.spawn(function()
				for _, CategoryData in Tab.Categories do
					local Comp = CategoryData.Components
					Globals:Tween(Comp.CategoryButton, TweenInfo.new(0.25), {
						BackgroundColor3 = Color3.fromRGB(8, 12, 18),
					})
					Globals:Tween(Comp.CategoryTitle, TweenInfo.new(0.25), {
						TextColor3 = Color3.fromRGB(125, 158, 169),
					})
					Globals:Tween(Comp.CategoryStroke, TweenInfo.new(0.25), {
						Color = Color3.fromRGB(28, 43, 53),
					})

					Globals:Tween(Comp.TabDropshadow, TweenInfo.new(0.25), {
						ImageTransparency = 1,
					})

					Comp.CategoryButton:SetAttribute("Opened", false)
					CategoryData.IsOpen = false
				end
			end)

			task.spawn(function()
				Globals:Tween(Components.CategoryButton, TweenInfo.new(0.25), {
					BackgroundColor3 = Library.Theme.DarkAccent,
				})
				Globals:Tween(Components.CategoryTitle, TweenInfo.new(0.25), {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				})
				Globals:Tween(Components.CategoryStroke, TweenInfo.new(0.25), {
					Color = Library.Theme.Accent,
				})
				Globals:Tween(Components.TabDropshadow, TweenInfo.new(0.25), {
					ImageTransparency = 0.5,
				})
				Components.CategoryButton:SetAttribute("Opened", true)
			end)

			Pointer.IsOpen = true

			task.spawn(function()
				if hiderIn then
					hiderIn.Completed:Wait()
				end
				Globals:Tween(
					self.Components.PageHider,
					TweenInfo.new(Library.PageTransitionSpeed, Enum.EasingStyle.Quad),
					{
						BackgroundTransparency = 1,
					}
				)

				for _, Page in PageContainer:GetChildren() do
					if not Page:IsA("Frame") or table.find({ "PageFadeTop", "PageFadeBottom" }, Page.Name) then
						continue
					end
					Page.Visible = Page.Name == Category.Name
				end
			end)
		end

		function Window:Tab(TabData)
			local Tab = {
				Name = TabData.Name,
				Image = TabData.Image,
				Categories = {},
				CategoryOrder = {},
			}

			Tab.__index = Tab
			local Components = {}

			do
				Components["NewTabButtonHolder"] = Globals:Instance("TextButton", {
					BackgroundColor3 = Color3.fromRGB(14, 21, 29),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 35, 0, 35),
					Name = Tab.Name,
					Parent = self.Components["TabsScrollingFrame"],
					Text = "",
					AutoButtonColor = false,
				})

				Components["TabImage"] = Globals:Instance("ImageLabel", {
					Image = Tab.Image,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					ImageColor3 = Color3.fromRGB(125, 158, 169),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 25, 0, 25),
					Name = "TabImage",
					Parent = Components["NewTabButtonHolder"],
				})

				Components["CategoryHolder"] = Globals:Instance("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					Name = Tab.Name,
					Parent = Window.Components["Categorys"],
					Visible = false,
				})

				Components["CategoryListLayout"] = Globals:Instance("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Name = "CategoryHolderLayout",
					Parent = Components["CategoryHolder"],
				})
			end

			do
				local TabButton = Components["NewTabButtonHolder"]

				Library:Connection("TabHandler_" .. Tab.Name, TabButton.MouseButton1Down, function()
					Window:SetTab(Tab)
				end)

				Library:Connection("TabMouseEnter_" .. Tab.Name, Components.NewTabButtonHolder.MouseEnter, function()
					Globals:Tween(
						Components["TabImage"],
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							ImageColor3 = Color3.fromRGB(255, 255, 255),
						}
					)
				end)

				Library:Connection("TabMouseLeave_" .. Tab.Name, Components.NewTabButtonHolder.MouseLeave, function()
					if Components["TabImage"]:GetAttribute("Opened") then
						return
					end
					Globals:Tween(
						Components["TabImage"],
						TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
						{
							ImageColor3 = Color3.fromRGB(125, 158, 169),
						}
					)
				end)
			end

			function Tab:Category(CategoryData)
				local Category = {
					Name = CategoryData.Name,
					Sections = {},
					Parent = Tab,
					IsOpen = false,
				}

				Category.__index = Category

				local Components = {}

				do
					Components["CategoryButton"] = Globals:Instance("TextButton", {
						Font = Enum.Font.SourceSansSemibold,
						RichText = true,
						Text = "",
						TextColor3 = Color3.fromRGB(125, 158, 169),
						TextSize = 14,
						TextTransparency = 1,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(8, 12, 18),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(0, 82, 0, 20),
						Name = Category.Name,
						Parent = self.Components["CategoryHolder"],
					})

					Components["CategoryCorner"] = Globals:Instance("UICorner", {
						CornerRadius = UDim.new(0, 4),
						Name = "CategoryCorner",
						Parent = Components["CategoryButton"],
					})

					Components["CategoryStroke"] = Globals:Instance("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(28, 43, 53),
						Name = "CategoryStroke",
						Parent = Components["CategoryButton"],
					})

					Components["CategoryTitle"] = Globals:Instance("TextLabel", {
						Font = Enum.Font.SourceSansSemibold,
						Text = Category.Name,
						TextColor3 = Color3.fromRGB(125, 158, 169),
						TextSize = 14,
						BackgroundColor3 = Color3.fromRGB(8, 12, 18),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Name = "CategoryTitle",
						Parent = Components["CategoryButton"],
					})

					Components["TabDropshadowContainer"] = Globals:Instance("Frame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 0,
						Name = "TabDropshadowContainer",
						Parent = Components["CategoryButton"],
					})

					Components["TabDropshadow"] = Globals:Instance("ImageLabel", {
						Image = Library.ShadowImage,
						ImageColor3 = Library.Theme.Accent,
						ImageTransparency = 1,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(49, 49, 450, 450),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 30, 1, 30),
						ZIndex = 0,
						Name = "TabDropshadow",
						Parent = Components["TabDropshadowContainer"],
					})

					Components["Page"] = Globals:Instance("Frame", {
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
						Name = Tab.Name .. "_" .. Category.Name,
						Visible = false,
						Parent = Window.Components["Pages"],
					})

					Components["Left"] = Globals:Instance("ScrollingFrame", {
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.new(0, 0, 1, 24),
						ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
						ScrollBarImageTransparency = 1,
						ScrollBarThickness = 0,
						Active = true,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(0.5, -5, 1, 0),
						Name = "Left",
						Parent = Components["Page"],
					})

					Components["LeftListLayout"] = Globals:Instance("UIListLayout", {
						Parent = Components.Left,
						Padding = UDim.new(0, 15),
					})

					Components["LeftPadding"] = Globals:Instance("UIPadding", {
						PaddingLeft = UDim.new(0, 2),
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 5),
						Name = "LeftPadding",
						Parent = Components["Left"],
					})

					Components["Right"] = Globals:Instance("ScrollingFrame", {
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.new(0, 0, 1, 0),
						ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
						ScrollBarImageTransparency = 1,
						ScrollBarThickness = 0,
						Active = true,
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 147, 0, 0),
						Size = UDim2.new(0.5, -5, 1, 0),
						Name = "Right",
						Parent = Components["Page"],
					})

					Components["RightPadding"] = Globals:Instance("UIPadding", {
						PaddingLeft = UDim.new(0, 2),
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 5),
						Name = "RightPadding",
						Parent = Components["Right"],
					})

					Components["RightListLayout"] = Globals:Instance("UIListLayout", {
						Parent = Components.Right,
						Padding = UDim.new(0, 15),
					})
				end

				function Category:Section(SectionData)
					local Section = {
						Name = SectionData.Name,
						Side = SectionData.Side or "Left",
						Elements = {},
						ZIndex = 9000,
					}

					Section.__index = Section

					local Components = {}

					do
						Components["Section"] = Globals:Instance("Frame", {
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(14, 21, 29),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(1, -4, 0, 30),
							Name = "Section",
							Parent = self.Components[Section.Side],
						})

						Components["SectionStroke"] = Globals:Instance("UIStroke", {
							Color = Color3.fromRGB(28, 43, 53),
							Name = "SectionStroke",
							Parent = Components["Section"],
						})

						Components["SectionCorner"] = Globals:Instance("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Name = "SectionCorner",
							Parent = Components["Section"],
						})

						Components["SectionTitleLine"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(28, 43, 53),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 0, 0, 24),
							Size = UDim2.new(1, 0, 0, 1),
							Name = "SectionTitleLine",
							Parent = Components["Section"],
						})

						Components["SectionTitle"] = Globals:Instance("TextLabel", {
							Font = Enum.Font.SourceSansSemibold,
							Text = Section.Name,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 14, 0, 2),
							Size = UDim2.new(1, -14, 0, 20),
							Name = "SectionTitle",
							Parent = Components["Section"],
						})

						Components["SectionElements"] = Globals:Instance("Frame", {
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 14, 0, 30),
							Size = UDim2.new(0, 249, 0, -30),
							Name = "SectionElements",
							Parent = Components["Section"],
						})

						Components["SectionElementsListLayout"] = Globals:Instance("UIListLayout", {
							Padding = UDim.new(0, 3),
							SortOrder = Enum.SortOrder.LayoutOrder,
							Name = "SectionElementsListLayout",
							Parent = Components["SectionElements"],
						})
					end

					function Section:SetVisibility(visible)
						self.Visible = visible
					end

					function Section:Seperator()
						local Components = {}
						Components["SectionSeperatorHolder"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(28, 43, 53),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 6),
							Name = "SectionSeperatorHolder",
							Parent = self.Components["SectionElements"],
						})

						Components["SectionSeperatorFrame"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(28, 43, 53),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 1),
							Name = "SectionSeperatorFrame",
							Parent = Components["SectionSeperatorHolder"],
						})

						function Components:SetVisibility(visible)
							Components.SectionSeperatorHolder.Visible = visible
						end

						return Components
					end

					function Section:Toggle(ToggleData)
						local Toggle = {
							Name = ToggleData.Name,
							Flag = ToggleData.Flag,
							Value = false,
							Default = ToggleData.Default or false,
							Callback = ToggleData.Callback or function() end,
							Tooltip = ToggleData.Tooltip or nil,
							Risky = ToggleData.Risky,
							Class = "Toggle",
						}

						Toggle.__index = Toggle

						local Components = {}

						do
							Components["ToggleHolder"] = Globals:Instance("TextButton", {
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = Toggle.Tooltip and UDim2.new(1, 0, 0, 38) or UDim2.new(1, 0, 0, 20),
								Name = "ToggleHolder",
								Parent = self.Components["SectionElements"],
								Text = "",
								AutoButtonColor = false,
							})

							Components["ToggleTitle"] = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSansSemibold,
								Text = Toggle.Name,
								TextColor3 = not Toggle.Risky and Color3.fromRGB(125, 158, 169)
									or Color3.fromRGB(150, 14, 23),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 15),
								Name = "ToggleTitle",
								Parent = Components["ToggleHolder"],
							})

							Components["ToggleButton"] = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSans,
								Text = "",
								TextColor3 = Color3.fromRGB(0, 0, 0),
								TextSize = 14,
								BackgroundColor3 = Color3.fromRGB(8, 12, 18),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(1, -15, 0, 0),
								Size = UDim2.new(0, 15, 0, 15),
								Name = "ToggleButton",
								Parent = Components["ToggleHolder"],
							})

							Components["ToggleButtonCorner"] = Globals:Instance("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Name = "ToggleButtonCorner",
								Parent = Components["ToggleButton"],
							})

							Components["ToggleStroke"] = Globals:Instance("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(28, 43, 53),
								Name = "ToggleStroke",
								Parent = Components["ToggleButton"],
							})

							Components["ToggleDropshadowContainer"] = Globals:Instance("Frame", {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 0,
								Name = "ToggleDropshadowContainer",
								Parent = Components["ToggleButton"],
							})

							Components["ToggleDropshadow"] = Globals:Instance("ImageLabel", {
								Image = Library.ShadowImage,
								ImageColor3 = Library.Theme.Accent,
								ImageTransparency = 0.5,
								ScaleType = Enum.ScaleType.Slice,
								SliceCenter = Rect.new(49, 49, 450, 450),
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Position = UDim2.new(0.5, 0, 0.5, 0),
								Size = UDim2.new(1, 20, 1, 20),
								ZIndex = 0,
								Name = "ToggleDropshadow",
								Parent = Components["ToggleDropshadowContainer"],
							})

							if Toggle.Tooltip then
								Components["Tooltip"] = Globals:Instance("TextLabel", {
									Font = Enum.Font.SourceSansSemibold,
									Text = Toggle.Tooltip,
									TextColor3 = Color3.fromRGB(100, 132, 146),
									TextSize = 14,
									TextXAlignment = Enum.TextXAlignment.Left,
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 1,
									BorderColor3 = Color3.fromRGB(0, 0, 0),
									BorderSizePixel = 0,
									Position = UDim2.new(0, 3, 0, 18),
									Size = UDim2.new(1, 0, 0, 15),
									Name = "Tooltip",
									Parent = Components["ToggleHolder"],
								})
							end
						end

						local Val = false
						Toggle.Components = Components

						function Toggle:Set(Value)
							self.Value = Value
							Val = Value
							if self.Value == true then
								Globals:Tween(
									Components["ToggleDropshadow"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										ImageTransparency = 0.5,
									}
								)

								Globals:Tween(
									Components["ToggleButton"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										BackgroundColor3 = Library.Theme.DarkAccent,
									}
								)

								Globals:Tween(
									Components["ToggleStroke"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										Color = Library.Theme.Accent,
									}
								)

								Globals:Tween(
									Components["ToggleTitle"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										TextColor3 = self.Risky and Color3.fromRGB(255, 0, 0)
											or Color3.fromRGB(255, 255, 255),
									}
								)
							else
								Globals:Tween(
									Components["ToggleDropshadow"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										ImageTransparency = 1,
									}
								)

								Globals:Tween(
									Components["ToggleButton"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										BackgroundColor3 = Color3.fromRGB(8, 12, 18),
									}
								)

								Globals:Tween(
									Components["ToggleStroke"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										Color = Color3.fromRGB(28, 43, 53),
									}
								)

								Globals:Tween(
									Components["ToggleTitle"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										TextColor3 = self.Risky and Color3.fromRGB(150, 14, 23)
											or Color3.fromRGB(125, 158, 169),
									}
								)
							end

							Library:DoCallback(self.Callback)
						end

						function Toggle:SetVisibility(visible)
							self.Components.ToggleHolder.Visible = visible
						end

						Library:Connection(
							"ToggleHandler" .. Toggle.Flag,
							Components.ToggleHolder.MouseButton1Down,
							function()
								Toggle:Set(not Val)
							end
						)

						Library:Connection(
							"ToggleMouseEnter" .. Toggle.Name,
							Components.ToggleHolder.MouseEnter,
							function()
								Globals:Tween(
									Components["ToggleStroke"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										Color = Library.Theme.Accent,
									}
								)
							end
						)

						Library:Connection(
							"ToggleMouseLeave" .. Category.Name,
							Components.ToggleHolder.MouseLeave,
							function()
								if Toggle.Value then
									return
								end
								Globals:Tween(
									Components["ToggleStroke"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										Color = Color3.fromRGB(28, 43, 53),
									}
								)
							end
						)

						Library.Flags[Toggle.Flag] = Toggle
						Section.Elements[Toggle.Flag] = Toggle

						Toggle:Set(Toggle.Default)
						return Toggle
					end

					function Section:Slider(SliderData)
						local Slider = {
							Min = SliderData.Min or 0,
							Max = SliderData.Max or 100,
							Default = SliderData.Default ~= nil and SliderData.Default or SliderData.Max,
							Increment = SliderData.Increment or 1,
							Name = SliderData.Name,
							Flag = SliderData.Flag,
							Suffix = SliderData.Suffix or "",
							Callback = SliderData.Callback or function() end,
							Class = "Slider",
						}

						Slider.__index = Slider

						local Components = {}

						do
							Components["Slider"] = Globals:Instance("Frame", {
								Active = true,
								BackgroundColor3 = Color3.fromRGB(255, 0, 4),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 44),
								Name = "Slider",
								Parent = self.Components["SectionElements"],
							})

							Components["SliderTitle"] = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSansSemibold,
								Text = Slider.Name,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 15),
								Name = "SliderTitle",
								Parent = Components["Slider"],
							})

							Components["SliderVisualizer"] = Globals:Instance("Frame", {
								BackgroundColor3 = Color3.fromRGB(8, 12, 18),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 0, 1, -15),
								Size = UDim2.new(1, 0, 0, 2),
								Name = "SliderVisualizer",
								Parent = Components["Slider"],
							})

							Components["SliderVisualizerFill"] = Globals:Instance("Frame", {
								BackgroundColor3 = Library.Theme.DarkAccent,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(0, 0, 1, 0),
								Name = "SliderVisualizerFill",
								Parent = Components["SliderVisualizer"],
							})

							Components["SliderCircle"] = Globals:Instance("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Library.Theme.DarkAccent,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 0, 0.5, 0),
								Size = UDim2.new(0, 10, 0, 10),
								Name = "SliderCircle",
								Parent = Components["SliderVisualizer"],
							})

							Components["SliderCircleCorner"] = Globals:Instance("UICorner", {
								Name = "SliderCircleCorner",
								Parent = Components["SliderCircle"],
							})

							Components["SliderShadowContainer"] = Globals:Instance("Frame", {
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 0,
								Name = "SliderShadowContainer",
								Parent = Components["SliderVisualizerFill"],
							})

							Components["SliderShadow"] = Globals:Instance("ImageLabel", {
								Image = Library.ShadowImage,
								ImageColor3 = Library.Theme.Accent,
								ImageTransparency = 0.72,
								ScaleType = Enum.ScaleType.Slice,
								SliceCenter = Rect.new(49, 49, 450, 450),
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Position = UDim2.new(0.5, -1, 0.5, 0),
								Size = UDim2.new(1, 7, 1, 10),
								ZIndex = 0,
								Name = "SliderShadow",
								Parent = Components["SliderShadowContainer"],
							})

							Components["SliderValue"] = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSansSemibold,
								Text = tostring(Slider.Default) .. Slider.Suffix,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Right,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 15),
								Name = "SliderValue",
								Parent = Components["Slider"],
							})
						end

						function Slider:Set(Value)
							Value = tonumber(Value) or self.Min
							local Increment = tonumber(self.Increment) or 1
							if Increment <= 0 then
								Increment = 1
							end

							local Clamped = math.clamp(Value, self.Min, self.Max)
							local Steps = math.floor(((Clamped - self.Min) / Increment) + 0.5)
							Value = math.clamp(self.Min + Steps * Increment, self.Min, self.Max)

							-- Do not let floating point rounding hide the exact endpoints.
							if Clamped <= self.Min then
								Value = self.Min
							elseif Clamped >= self.Max then
								Value = self.Max
							end

							self.Value = Value
							local Percent = self.Max == self.Min and 0 or (Value - self.Min) / (self.Max - self.Min)

							-- Direct updates avoid a queue of tweens fighting the mouse.
							Components["SliderVisualizerFill"].Size = UDim2.new(Percent, 0, 1, 0)
							Components["SliderCircle"].Position = UDim2.new(Percent, 0, 0.5, 0)
							Components["SliderValue"].Text = Library:FormatValue(Slider.Increment, Value) .. Slider.Suffix

							Library:DoCallback(self.Callback, Value)
						end

						function Slider:SetVisibility(visible)
							self.Components.Slider.Visible = visible
						end

						Slider.Components = Components

						do
							local Dragging = false

							local function UpdateFromInput(XPosition)
								local Track = Components["SliderVisualizer"]
								local Width = Track.AbsoluteSize.X
								if Width <= 0 then
									return
								end

								local RelativeX = math.clamp((XPosition - Track.AbsolutePosition.X) / Width, 0, 1)
								Slider:Set((Slider.Max - Slider.Min) * RelativeX + Slider.Min)
							end

							local function IsStart(Input)
								return Input.UserInputType == Enum.UserInputType.MouseButton1
									or Input.UserInputType == Enum.UserInputType.Touch
							end

							Library:Connection("Slider" .. Slider.Flag, Components.Slider.InputBegan, function(Input)
								if IsStart(Input) then
									Dragging = true
									Window.InDrag = true
									UpdateFromInput(Input.Position.X)
								end
							end)

							UserInputService.InputChanged:Connect(function(Input)
								if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
									or Input.UserInputType == Enum.UserInputType.Touch) then
									UpdateFromInput(Input.Position.X)
								end
							end)

							UserInputService.InputEnded:Connect(function(Input)
								if IsStart(Input) then
									Dragging = false
									Window.InDrag = false
								end
							end)
						end

						Slider:Set(Slider.Default)

						Library.Flags[Slider.Flag] = Slider
						Section.Elements[Slider.Flag] = Slider
						return Slider
					end

					function Section:Button(ButtonData)
						local Button = {
							Name = ButtonData.Name,
							Flag = ButtonData.Flag,
							Class = "Button",
							Callback = ButtonData.Callback or function() end,
						}

						local Components = {}

						do
							Components["ButtonHolder"] = Globals:Instance("Frame", {
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 24),
								Name = "ButtonHolder",
								Parent = self.Components["SectionElements"],
							})

							Components["Button"] = Globals:Instance("TextButton", {
								Font = Enum.Font.SourceSansSemibold,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								AutoButtonColor = false,
								BackgroundColor3 = Color3.fromRGB(8, 12, 18),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 0, 0, 2),
								Size = UDim2.new(1, 0, 0, 18),
								Name = "Button",
								Parent = Components["ButtonHolder"],
								Text = Button.Name,
							})

							Components["ButtonCorner"] = Globals:Instance("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Name = "ButtonCorner",
								Parent = Components["Button"],
							})

							Components["ButtonStroke"] = Globals:Instance("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(28, 43, 53),
								Name = "ButtonStroke",
								Parent = Components["Button"],
							})
						end

						Library:Connection("MouseEnter" .. Button.Flag, Components.Button.MouseEnter, function()
							Globals:Tween(
								Components["ButtonStroke"],
								TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
								{
									Color = Library.Theme.Accent,
								}
							)
						end)

						Library:Connection("MouseLeave" .. Button.Flag, Components.Button.MouseLeave, function()
							Globals:Tween(
								Components["ButtonStroke"],
								TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
								{
									Color = Color3.fromRGB(28, 43, 53),
								}
							)
						end)

						Library:Connection(
							"ButtonHandler" .. Button.Flag,
							Components.Button.MouseButton1Down,
							function()
								Library:DoCallback(Button.Callback)
								task.spawn(function()
									Globals:Tween(
										Components["Button"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											BackgroundColor3 = Library.Theme.Accent,
										}
									)
									task.wait(0.2)
									Globals:Tween(
										Components["Button"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											BackgroundColor3 = Color3.fromRGB(8, 12, 18),
										}
									)
								end)
							end
						)

						function Button:AddButton(NewData)
							if self.SecondButton then
								return
							end

							local newFlag = NewData.Flag or (self.Flag .. "_2")
							local newName = NewData.Name or "Button"
							local newCallback = NewData.Callback or function() end

							Components.Button.Size = UDim2.new(0.5, -1, 0, 18)
							Components.Button.Position = UDim2.new(0, 0, 0, 2)

							local Second = Globals:Instance("TextButton", {
								Font = Enum.Font.SourceSansSemibold,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								AutoButtonColor = false,
								BackgroundColor3 = Color3.fromRGB(8, 12, 18),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0.5, 1, 0, 2),
								Size = UDim2.new(0.5, -1, 0, 18),
								Name = "Button2",
								Parent = Components["ButtonHolder"],
								Text = newName,
							})

							Globals:Instance("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Parent = Second,
							})

							local Stroke = Globals:Instance("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(28, 43, 53),
								Parent = Second,
							})

							Library:Connection("ButtonHandler" .. newFlag, Second.MouseButton1Down, function()
								Library:DoCallback(newCallback)
								task.spawn(function()
									Globals:Tween(
										Second,
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											BackgroundColor3 = Library.Theme.Accent,
										}
									)
									task.wait(0.2)
									Globals:Tween(
										Second,
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											BackgroundColor3 = Color3.fromRGB(8, 12, 18),
										}
									)
								end)
							end)

							Library:Connection("MouseEnter" .. newFlag, Second.MouseEnter, function()
								Globals:Tween(Stroke, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
									Color = Library.Theme.Accent,
								})
							end)

							Library:Connection("MouseLeave" .. newFlag, Second.MouseLeave, function()
								Globals:Tween(Stroke, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
									Color = Color3.fromRGB(28, 43, 53),
								})
							end)

							self.SecondButton = {
								Name = newName,
								Flag = newFlag,
								Callback = newCallback,
								Instance = Second,
							}

							return self.SecondButton
						end

						Button.Components = Components
						Button.__index = Button
						Section.Elements[Button.Flag] = Button
						return Button
					end

					function Section:Dropdown(DropdownData)
						local Dropdown = {
							Name = DropdownData.Name,
							Flag = DropdownData.Flag,
							Multi = DropdownData.Multi or false,
							Value = not DropdownData.Multi and "" or {},
							Default = DropdownData.Default,
							Callback = DropdownData.Callback or function() end,
							Class = "Dropdown",
						}

						self.ZIndex -= 1
						Dropdown.__index = Dropdown
						local vis = false
						local Components = {}

						do
							Components["Dropdown"] = Globals:Instance("Frame", {
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 44),
								ZIndex = 2,
								Name = "Dropdown",
								Parent = self.Components["SectionElements"],
								ZIndex = self.ZIndex,
							})

							Components["DropdownTitle"] = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSansSemibold,
								Text = Dropdown.Name,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 15),
								Name = "DropdownTitle",
								Parent = Components["Dropdown"],
							})

							Components["DropdownButton"] = Globals:Instance("TextButton", {
								Font = Enum.Font.SourceSansSemibold,
								Text = "   ",
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								AutoButtonColor = false,
								BackgroundColor3 = Color3.fromRGB(8, 12, 18),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 0, 0, 18),
								Size = UDim2.new(1, 0, 0, 22),
								Name = "DropdownButton",
								Parent = Components["Dropdown"],
								ClipsDescendants = false,
							})

							Components["DropdownButtonCorner"] = Globals:Instance("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Name = "DropdownButtonCorner",
								Parent = Components["DropdownButton"],
							})

							Components["DropdownStroke"] = Globals:Instance("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(28, 43, 53),
								Name = "DropdownStroke",
								Parent = Components["DropdownButton"],
							})

							Components["DropdownImage"] = Globals:Instance("ImageLabel", {
								Image = Library.DropdownImage,
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(1, -15, 0.5, 0),
								Size = UDim2.new(0, 15, 0, 15),
								Name = "DropdownImage",
								Parent = Components["DropdownButton"],
								ZIndex = 3,
							})

							Components["DropdownItemsOutline"] = Globals:Instance("Frame", {
								BackgroundColor3 = Color3.fromRGB(8, 12, 18),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 0, 0, 21),
								Size = UDim2.new(1, 0, 0, 0),
								Name = "DropdownItemsOutline",
								Visible = false,
								Parent = Components["DropdownButton"],
								ClipsDescendants = true,
								ZIndex = 2,
							})

							Components["DropdownItemsStroke"] = Globals:Instance("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(28, 43, 53),
								Name = "DropdownItemsStroke",
								Parent = Components["DropdownItemsOutline"],
								Transparency = 1,
							})

							Components["DropdownItems"] = Globals:Instance("ScrollingFrame", {
								AutomaticCanvasSize = Enum.AutomaticSize.Y,
								CanvasSize = UDim2.new(0, 0, 1, 0),
								ScrollBarImageColor3 = Library.Theme.Accent,
								ScrollBarImageTransparency = 0.67,
								ScrollBarThickness = 3,
								Visible = true,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 2, 0, 2),
								Size = UDim2.new(1, -4, 1, -4),
								Name = "DropdownItems",
								Parent = Components["DropdownItemsOutline"],
								ClipsDescendants = true,
							})

							Components["DropdownListLayout"] = Globals:Instance("UIListLayout", {
								Padding = UDim.new(0, 3),
								SortOrder = Enum.SortOrder.LayoutOrder,
								Name = "DropdownListLayout",
								Parent = Components["DropdownItems"],
							})

							Components["DropdownFadeBottom"] = Globals:Instance("Frame", {
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 0, 1, -20),
								Size = UDim2.new(1, 0, 0, 20),
								Name = "DropdownFadeBottom",
								Parent = Components["DropdownItemsOutline"],
							})

							Components["DropdownFadeTopGradient"] = Globals:Instance("UIGradient", {
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 18)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 18)),
								}),
								Rotation = -90,
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.4),
									NumberSequenceKeypoint.new(1, 1),
								}),
								Name = "DropdownFadeTopGradient",
								Parent = Components["DropdownFadeBottom"],
							})

							Components["DropdownFadeTop"] = Globals:Instance("Frame", {
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 20),
								Name = "DropdownFadeTop",
								Parent = Components["DropdownItemsOutline"],
							})

							Components["DropdownFadeTopGradient1"] = Globals:Instance("UIGradient", {
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 18)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 18)),
								}),
								Rotation = 90,
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.4),
									NumberSequenceKeypoint.new(1, 1),
								}),
								Name = "DropdownFadeTopGradient",
								Parent = Components["DropdownFadeTop"],
							})

							Components["DropdownText"] = Globals:Instance("TextLabel", {
								Parent = Components["DropdownButton"],
								BackgroundTransparency = 1,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 1,
								Font = Enum.Font.SourceSansSemibold,
								TextSize = 14,
								ClipsDescendants = true,
							})

							Components["DropdownHider"] = Instance.new("Frame")
							Components["DropdownHider"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							Components["DropdownHider"].BorderColor3 = Color3.fromRGB(0, 0, 0)
							Components["DropdownHider"].BorderSizePixel = 0
							Components["DropdownHider"].Position = UDim2.new(1, -20, 0.5, 0)
							Components["DropdownHider"].Size = UDim2.new(0, 20, 1, -2)
							Components["DropdownHider"].AnchorPoint = Vector2.new(0, 0.5)
							Components["DropdownHider"].Parent = Components["DropdownButton"]

							Components["HiderGradient"] = Instance.new("UIGradient")
							Components["HiderGradient"].Color = ColorSequence.new({
								ColorSequenceKeypoint.new(
									0,
									Color3.fromRGB(11.000000294297934, 11.000000294297934, 11.000000294297934)
								),
								ColorSequenceKeypoint.new(
									1,
									Color3.fromRGB(11.000000294297934, 11.000000294297934, 11.000000294297934)
								),
							})
							Components["HiderGradient"].Rotation = -180
							Components["HiderGradient"].Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.7219451665878296, 0),
								NumberSequenceKeypoint.new(0.7842893004417419, 0),
								NumberSequenceKeypoint.new(0.8690773248672485, 0.44999998807907104),
								NumberSequenceKeypoint.new(0.9650872945785522, 0.7062499523162842),
								NumberSequenceKeypoint.new(1, 0.36250001192092896),
							})
							Components["HiderGradient"].Name = "PageFadeTopGradient"
							Components["HiderGradient"].Parent = Components["DropdownHider"]
						end

						Dropdown.Components = Components

						Dropdown.Options = {}

						function Dropdown:SetVisibility(visible)
							self.Components.Dropdown.Visible = visible
						end

						function Dropdown:AddOption(Name)
							local Option = {
								Name = Name,
								Value = false,
								Components = {},
							}

							local OptionComponents = {}

							OptionComponents["Option"] = Globals:Instance("TextButton", {
								Font = Enum.Font.SourceSans,
								Text = "",
								TextColor3 = Color3.fromRGB(0, 0, 0),
								TextSize = 14,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 20),
								Name = "Option",
								Parent = Components["DropdownItems"],
							})

							OptionComponents["OptionOnTitle"] = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSansSemibold,
								Text = Name,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								BackgroundColor3 = Color3.fromRGB(125, 158, 169),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Position = UDim2.new(0, 10, 0, 0),
								Size = UDim2.new(1, -10, 1, 0),
								Name = "OptionOnTitle",
								Parent = OptionComponents["Option"],
							})

							OptionComponents["OptionIndicator"] = Globals:Instance("Frame", {
								BackgroundColor3 = Library.Theme.Accent,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.new(0, 3, 1, 0),
								Name = "OptionIndicator",
								Visible = true,
								BackgroundTransparency = 1,
								Parent = OptionComponents["Option"],
							})

							Library:Connection(
								"OptionHandler" .. Option.Name .. "_" .. Dropdown.Flag,
								OptionComponents.Option.MouseButton1Down,
								function()
									if Dropdown.Multi then
										Option.Value = not Option.Value
										Globals:Tween(
											OptionComponents["OptionIndicator"],
											TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
											{
												BackgroundTransparency = Option.Value and 0 or 1,
											}
										)
										Globals:Tween(
											OptionComponents["OptionOnTitle"],
											TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
											{
												TextColor3 = Option.Value and Color3.fromRGB(255, 255, 255)
													or Color3.fromRGB(125, 158, 169),
											}
										)
									else
										for _, other in ipairs(Dropdown.Options) do
											other.Value = false

											Globals:Tween(
												other.Components["OptionIndicator"],
												TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
												{
													BackgroundTransparency = other.Value and 0 or 1,
												}
											)

											Globals:Tween(
												other.Components["OptionOnTitle"],
												TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
												{
													TextColor3 = other.Value and Color3.fromRGB(255, 255, 255)
														or Color3.fromRGB(125, 158, 169),
												}
											)
										end
										Option.Value = true
										Globals:Tween(
											OptionComponents["OptionIndicator"],
											TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
											{
												BackgroundTransparency = 0,
											}
										)

										Globals:Tween(
											OptionComponents["OptionOnTitle"],
											TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
											{
												TextColor3 = Option.Value and Color3.fromRGB(255, 255, 255)
													or Color3.fromRGB(125, 158, 169),
											}
										)

										Components["DropdownText"].Text = "   " .. Name
										local SizeTween = Globals:Tween(
											Components["DropdownItemsOutline"],
											TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
											{
												Size = UDim2.new(1, 0, 0, 0),
											}
										)
										Globals:Tween(
											Components["DropdownItemsStroke"],
											TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
											{
												Transparency = 1,
											}
										)
										task.spawn(function()
											task.wait(Library.HighlightSpeed)
											Components.DropdownItemsOutline.Visible = false
										end)
									end

									if Dropdown.Multi then
										local selected = {}
										for _, opt in ipairs(Dropdown.Options) do
											if opt.Value then
												table.insert(selected, opt.Name)
											end
										end
										Dropdown:Set(selected)
									else
										Dropdown:Set(Name)
									end
								end
							)

							Option.Components = OptionComponents
							table.insert(Dropdown.Options, Option)
							return Option
						end

						for Index, Name in DropdownData.Options do
							Dropdown:AddOption(Name)
						end

						function Dropdown:Set(Value)
							if not Dropdown.Multi then
								local found = false
								for _, opt in ipairs(self.Options) do
									if opt.Name == Value then
										found = true
										break
									end
								end
								if not found then
									return
								end
							end
							self.Value = Value

							if Dropdown.Multi then
								local selectedNames = {}
								for _, opt in ipairs(self.Options) do
									local selected = table.find(Value, opt.Name) ~= nil
									opt.Value = selected

									Globals:Tween(
										opt.Components["OptionIndicator"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											BackgroundTransparency = selected and 0 or 1,
										}
									)

									Globals:Tween(
										opt.Components["OptionOnTitle"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											TextColor3 = selected and Color3.fromRGB(255, 255, 255)
												or Color3.fromRGB(125, 158, 169),
										}
									)

									if selected then
										table.insert(selectedNames, opt.Name)
									end
								end

								if #selectedNames == 0 then
									Components["DropdownText"].Text = "   None"
								else
									Components["DropdownText"].Text = "   " .. table.concat(selectedNames, ", ")
								end
							else
								for _, opt in ipairs(self.Options) do
									local selected = opt.Name == Value
									opt.Value = selected

									Globals:Tween(
										opt.Components["OptionIndicator"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											BackgroundTransparency = selected and 0 or 1,
										}
									)

									Globals:Tween(
										opt.Components["OptionOnTitle"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											TextColor3 = selected and Color3.fromRGB(255, 255, 255)
												or Color3.fromRGB(125, 158, 169),
										}
									)
								end

								Globals:Tween(
									Components["Dropdown"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										Size = UDim2.new(1, 0, 0, 44),
									}
								)

								Components["DropdownText"].Text = "   " .. tostring(Value)
							end

							Library:DoCallback(self.Callback, Value)
						end

						Library:Connection(
							"DropdownHandler_" .. Dropdown.Flag .. "Main",
							Components["DropdownButton"].MouseButton1Down,
							function()
								vis = not vis
								if vis then
									local itemCount = #Dropdown.Options
									local itemHeight = 24
									local expandedItemHeight = math.min(itemCount, 3) * itemHeight
									local fullHeight = 44 + expandedItemHeight

									Components.DropdownItemsOutline.Visible = true

									Globals:Tween(
										Components["DropdownItemsOutline"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											Size = UDim2.new(1, 0, 0, expandedItemHeight),
										}
									)

									Globals:Tween(
										Components["Dropdown"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											Size = UDim2.new(1, 0, 0, fullHeight),
										}
									)

									Globals:Tween(
										Components["DropdownItemsStroke"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											Transparency = 0,
										}
									)
								else
									Globals:Tween(
										Components["DropdownItemsOutline"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											Size = UDim2.new(1, 0, 0, 0),
										}
									)

									Globals:Tween(
										Components["Dropdown"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											Size = UDim2.new(1, 0, 0, 44),
										}
									)

									Globals:Tween(
										Components["DropdownItemsStroke"],
										TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
										{
											Transparency = 1,
										}
									)

									task.spawn(function()
										task.wait(Library.HighlightSpeed)
										Components.DropdownItemsOutline.Visible = false
									end)
								end
							end
						)

						if not Dropdown.Default or (Dropdown.Multi and #Dropdown.Default == 0) then
							if Dropdown.Multi then
								Dropdown.Default = { DropdownData.Options[1] }
							else
								Dropdown.Default = DropdownData.Options[1]
							end
						end

						Dropdown:Set(Dropdown.Default)
						Library.Flags[Dropdown.Flag] = Dropdown
						Section.Elements[Dropdown.Flag] = Dropdown
						return Dropdown
					end

					function Section:Textbox(TextboxData)
						local TextBox = {
							Name = TextboxData.Name,
							Flag = TextboxData.Flag,
							Default = TextboxData.Default or "",
							Callback = TextboxData.Callback or function() end,
							Value = "",
							Class = "TextBox",
						}

						local Components = {}

						Components.Holder = Globals:Instance("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 40),
							Parent = self.Components.SectionElements,
						})

						Components.Title = Globals:Instance("TextLabel", {
							Font = Enum.Font.SourceSansSemibold,
							Text = TextBox.Name,
							TextColor3 = Color3.fromRGB(125, 158, 169),
							TextSize = 14,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 15),
							TextXAlignment = Enum.TextXAlignment.Left,
							Parent = Components.Holder,
						})

						local BoxFrame = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(8, 12, 18),
							Position = UDim2.new(0, 0, 0, 18),
							Size = UDim2.new(1, 0, 0, 18),
							ClipsDescendants = true,
							Parent = Components.Holder,
						})
						Globals:Instance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BoxFrame })
						local Stroke = Globals:Instance("UIStroke", {
							Color = Color3.fromRGB(28, 43, 53),
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Parent = BoxFrame,
						})

						local Label = Globals:Instance("TextLabel", {
							Font = Enum.Font.SourceSansSemibold,
							Text = "",
							TextColor3 = Color3.fromRGB(210, 235, 228),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -5, 1, 0),
							Position = UDim2.new(0, 5, 0, 0),
							Parent = BoxFrame,
						})

						local Mask = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(8, 12, 18),
							Size = UDim2.new(1, -2, 1, -2),
							Position = UDim2.new(0, 1, 0, 1),
							Parent = BoxFrame,
						})

						Globals:Instance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Mask })

						local Cursor = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(210, 235, 228),
							Size = UDim2.new(0, 1, 0.8, 0),
							Position = UDim2.new(0, 0, 0.1, 0),
							Parent = BoxFrame,
							ZIndex = Mask.ZIndex + 1,
							Visible = false,
						})
						Globals:Instance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Cursor })

						local InputBox = Globals:Instance("TextBox", {
							Font = Label.Font,
							TextSize = Label.TextSize,
							TextTransparency = 1,
							Text = "",
							BackgroundTransparency = 1,
							ClearTextOnFocus = false,
							Size = UDim2.new(1, -5, 1, 0),
							Position = UDim2.new(0, 5, 0, 0),
							Parent = BoxFrame,
						})

						local TweenService = TweenService

						local BlinkTweenInfo =
							TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
						local BlinkTween = TweenService:Create(Cursor, BlinkTweenInfo, { BackgroundTransparency = 1 })

						local function UpdateMaskAndCursor()
							local FullText = Label.Text
							local TextWidth = Label.TextBounds.X
							local BoxWidth = BoxFrame.AbsoluteSize.X

							local RevealX = math.clamp(TextWidth, 0, BoxWidth - 7)

							if FullText:sub(-1) == " " then
								RevealX = RevealX + 3
							end

							Mask:TweenPosition(
								UDim2.new(0, 1 + 5 + RevealX, 0, 1),
								Enum.EasingDirection.Out,
								Enum.EasingStyle.Sine,
								0.1,
								true
							)
							Cursor:TweenPosition(
								UDim2.new(0, 5 + RevealX, 0.1, 0),
								Enum.EasingDirection.Out,
								Enum.EasingStyle.Sine,
								0.1,
								true
							)
						end

						function TextBox:Set(Value)
							self.Value = Value
							Label.Text = Value
							InputBox.Text = Value

							task.defer(UpdateMaskAndCursor)

							Library:DoCallback(self.Callback, Value)
						end

						function TextBox:SetVisibility(Visible)
							Components.Holder.Visible = Visible
						end

						InputBox.Focused:Connect(function()
							TweenService:Create(Stroke, TweenInfo.new(0.2), { Color = Library.Theme.Accent }):Play()
							Cursor.Visible = true
							if BlinkTween.PlaybackState ~= Enum.PlaybackState.Playing then
								BlinkTween:Play()
							end
						end)

						InputBox.FocusLost:Connect(function()
							TweenService:Create(Stroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(28, 43, 53) })
								:Play()
							Cursor.Visible = false
							BlinkTween:Pause()
						end)

						InputBox:GetPropertyChangedSignal("Text"):Connect(function()
							local FullText = InputBox.Text
							TextBox.Value = FullText
							Label.Text = FullText
							task.defer(UpdateMaskAndCursor)
							Library:DoCallback(TextboxData.Callback, FullText)
						end)

						TextBox:Set(TextBox.Default)

						TextBox.Components = Components
						TextBox.__index = TextBox
						Library.Flags[TextBox.Flag] = TextBox
						return TextBox
					end

					function Section:Colorpicker(ColorpickerData)
						local Colorpicker = {
							Name = ColorpickerData.Name,
							Flag = ColorpickerData.Flag,
							Default = ColorpickerData.Default or { Color3.fromRGB(255, 255, 255), 0 },
							Callback = ColorpickerData.Callback or function() end,
							Class = "Colorpicker",
						}

						Colorpicker.__index = Colorpicker

						local Components = {}

						Components["Colorpicker"] = Globals:Instance("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 20),
							Name = "Colorpicker",
							Parent = self.Components["SectionElements"],
							BorderSizePixel = 0,
						})

						Components["ColorpickerTitle"] = Globals:Instance("TextLabel", {
							Font = Enum.Font.SourceSans,
							Text = Colorpicker.Name,
							TextColor3 = Color3.fromRGB(125, 158, 169),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 15),
							Name = "ColorpickerTitle",
							Parent = Components["Colorpicker"],
							BorderSizePixel = 0,
						})

						Components["ColorpickerButton"] = Globals:Instance("TextButton", {
							Font = Enum.Font.SourceSans,
							Text = "",
							TextColor3 = Color3.fromRGB(0, 0, 0),
							TextSize = 14,
							AutoButtonColor = false,
							BackgroundColor3 = Colorpicker.Default[1],
							Position = UDim2.new(1, -15, 0, 0),
							Size = UDim2.new(0, 15, 0, 15),
							Name = "ColorpickerButton",
							Parent = Components["Colorpicker"],
							BorderSizePixel = 0,
						})

						Globals:Instance("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Parent = Components["ColorpickerButton"],
						})

						Globals:Instance("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(28, 43, 53),
							Parent = Components["ColorpickerButton"],
						})

						Components["ColorpickerFrame"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(8, 12, 18),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, 20, 0, 0),
							Size = UDim2.new(0, 215, 0, 210),
							Name = "ColorpickerFrame",
							Parent = Window.Components.Outline,
							BorderSizePixel = 0,
							Visible = false,
						})

						Globals:Instance("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Parent = Components["ColorpickerFrame"],
						})

						Globals:Instance("UIStroke", {
							Color = Color3.fromRGB(28, 43, 53),
							Transparency = 1,
							Thickness = 1.5,
							Parent = Components["ColorpickerFrame"],
						})

						Components["ColorpickerTitleLine"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(28, 43, 53),
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 0, 25),
							Size = UDim2.new(1, 0, 0, 1),
							Name = "ColorpickerTitleLine",
							Parent = Components["ColorpickerFrame"],
							BorderSizePixel = 0,
						})

						Components["ColorpickerTitleHeader"] = Globals:Instance("TextLabel", {
							Font = Enum.Font.SourceSansSemibold,
							Text = "    " .. Colorpicker.Name,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.fromRGB(14, 21, 29),
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 0, 25),
							Name = "ColorpickerTitleHeader",
							Parent = Components["ColorpickerFrame"],
							BorderSizePixel = 0,
						})

						Components["ColorpickerElements"] = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(8, 12, 18),
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 10, 0, 208),
							Size = UDim2.new(1, -20, -0.548837364, -50),
							Name = "ColorpickerElements",
							Parent = Components["ColorpickerFrame"],
							BorderSizePixel = 0,
						})

						Components["Colorwheel"] = Globals:Instance("ImageLabel", {
							Image = Library.ColorwheelImage,
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(0.5, -20, 0, 0),
							Size = UDim2.new(0, 150, 0, 150),
							Name = "Colorwheel",
							Parent = Components["ColorpickerElements"],
							BorderSizePixel = 0,
						})

						Globals:Instance("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Parent = Components["Colorwheel"],
						})

						Globals:Instance("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(28, 43, 53),
							Transparency = 1,
							Thickness = 3,
							Parent = Components["Colorwheel"],
						})

						Components["BrightnessPicker"] = Globals:Instance("TextButton", {
							Text = "",
							AutoButtonColor = false,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							Position = UDim2.new(1, -35, 0, 0),
							Size = UDim2.new(0, 10, 0, 150),
							Name = "BrightnessPicker",
							Parent = Components["ColorpickerElements"],
							BorderSizePixel = 0,
						})

						Globals:Instance("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Parent = Components["BrightnessPicker"],
						})

						Globals:Instance("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(28, 43, 53),
							Transparency = 1,
							Parent = Components["BrightnessPicker"],
						})

						Globals:Instance("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
							}),
							Rotation = 90,
							Parent = Components["BrightnessPicker"],
						})

						Components["TransparencyPickerButton"] = Globals:Instance("TextButton", {
							Text = "",
							AutoButtonColor = false,
							BackgroundColor3 = Colorpicker.Default[1],
							Position = UDim2.new(1, -15, 0, 0),
							Size = UDim2.new(0, 10, 0, 150),
							Name = "TransparencyPickerButton",
							Parent = Components["ColorpickerElements"],
							BorderSizePixel = 0,
						})

						local TransparencyPicture = Globals:Instance("ImageLabel", {
							Image = Library.TransparencyImage,
							ScaleType = Enum.ScaleType.Tile,
							TileSize = UDim2.new(8, 0, 0.5, 0),
							BackgroundColor3 = Colorpicker.Default[1],
							Size = UDim2.new(1, 0, 1, 0),
							Name = "TransparencyPicture",
							Parent = Components["TransparencyPickerButton"],
							BorderSizePixel = 0,
							Rotation = 180,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 0),
						})

						Globals:Instance("UIGradient", {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1),
							}),
							Rotation = 90,
							Parent = TransparencyPicture,
						})

						Globals:Instance("UICorner", {
							CornerRadius = UDim.new(0, 4),
							Parent = Components["TransparencyPickerButton"],
						})

						Globals:Instance("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(28, 43, 53),
							Parent = Components["TransparencyPickerButton"],
						})

						local WheelIndicator = Globals:Instance("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 2,
							Size = UDim2.new(0, 6, 0, 6),
							Name = "WheelIndicator",
							Parent = Components["Colorwheel"],
						})
						Globals:Instance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = WheelIndicator })

						local BrightnessIndicator = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 1,
							Size = UDim2.new(1, 0, 0, 2),
							Name = "BrightnessIndicator",
							Parent = Components["BrightnessPicker"],
						})

						local TransparencyIndicator = Globals:Instance("Frame", {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 1,
							Size = UDim2.new(1, 0, 0, 2),
							Name = "TransparencyIndicator",
							Parent = Components["TransparencyPickerButton"],
						})

						Colorpicker.Components = Components

						local function FadeInFrame(frame)
							frame.Visible = true
							Globals:TweenTransparencyIns(frame, 0, 0.2)
						end

						local function FadeOutFrame(frame)
							Globals:TweenTransparencyIns(frame, 1, 0.2)
							task.delay(0.2, function()
								if frame and frame.Parent then
									frame.Visible = false
								end
							end)
						end

						Components["ColorpickerButton"].MouseButton1Down:Connect(function()
							local thisFrame = Components["ColorpickerFrame"]
							local isOpening = not (thisFrame.Visible and thisFrame.BackgroundTransparency < 1)

							for _, child in ipairs(Window.Components.Outline:GetChildren()) do
								if child.Name == "ColorpickerFrame" and child ~= thisFrame and child.Visible then
									FadeOutFrame(child)
								end
							end

							if isOpening then
								FadeInFrame(thisFrame)
							else
								FadeOutFrame(thisFrame)
							end
						end)

						local function UpdateIndicators()
							local col, transparency = Colorpicker.Value[1], Colorpicker.Value[2]
							local h, s, v = col:ToHSV()

							local radius = Components["Colorwheel"].AbsoluteSize.X / 2
							local angle = h * 2 * math.pi
							local distance = s * radius
							local offset = Vector2.new(math.cos(angle), math.sin(angle)) * distance

							Globals:Tween(WheelIndicator, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
								Position = UDim2.new(0.5, offset.X, 0.5, offset.Y),
							})

							Globals:Tween(BrightnessIndicator, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
								Position = UDim2.new(0, 0, 1 - v, -1),
							})

							Globals:Tween(TransparencyIndicator, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
								Position = UDim2.new(0, 0, transparency, -1),
							})
						end

						function Colorpicker:Set(Value)
							self.Value = Value

							local col = Value[1]
							local transparency = Value[2]

							Globals:Tween(Components["ColorpickerButton"], TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
								BackgroundColor3 = col,
							})

							Globals:Tween(TransparencyPicture, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
								BackgroundColor3 = col,
							})

							Globals:Tween(
								Components["TransparencyPickerButton"],
								TweenInfo.new(0.15, Enum.EasingStyle.Quad),
								{
									BackgroundColor3 = col,
								}
							)

							local h, s, v = col:ToHSV()
							if v > 0 then
								self._LastHue = h
								self._LastSaturation = s
							end

							UpdateIndicators()
							Library:DoCallback(self.Callback, Value)
						end

						function Colorpicker:SetVisibility(visible)
							self.Colorpicker.Visible = visible
							if self.ColorpickerFrame.Visible and not visible then
								self.ColorpickerFrame.Visible = visible
							end
						end

						local function ColorFromWheel(x, y, wheel)
							local center = wheel.AbsolutePosition + wheel.AbsoluteSize / 2
							local radius = wheel.AbsoluteSize.X / 2
							local rel = Vector2.new(x, y) - center
							local distance = rel.Magnitude

							local hue, sat = 0, 0

							if distance > 0 then
								hue = math.atan2(rel.Y, rel.X) / (2 * math.pi)
								if hue < 0 then
									hue = hue + 1
								end
								sat = math.clamp(distance / radius, 0, 1)
							end

							local _, _, v = Colorpicker.Value[1]:ToHSV()
							return Color3.fromHSV(hue, sat, v)
						end

						local function EnableDragging(Component, onDrag)
							Component.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 then
									local moveConn, upConn
									moveConn = RunService.RenderStepped:Connect(function()
										local mousePos = UserInputService:GetMouseLocation()
										local adjustedMousePos = Vector2.new(mousePos.X, mousePos.Y - MouseConstant)

										onDrag(adjustedMousePos)
									end)
									upConn = UserInputService.InputEnded:Connect(function(endInput)
										if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
											moveConn:Disconnect()
											upConn:Disconnect()
										end
									end)
								end
							end)
						end

						EnableDragging(Components["Colorwheel"], function(mousePosRaw)
							local mousePos = Vector2.new(mousePosRaw.X, mousePosRaw.Y - MouseConstant)
							local col = ColorFromWheel(mousePos.X, mousePos.Y, Components["Colorwheel"])
							Colorpicker:Set({ col, Colorpicker.Value[2] })
						end)

						EnableDragging(Components["BrightnessPicker"], function(mousePosRaw)
							local mousePos = Vector2.new(mousePosRaw.X, mousePosRaw.Y - MouseConstant)
							local top = Components["BrightnessPicker"].AbsolutePosition.Y
							local height = Components["BrightnessPicker"].AbsoluteSize.Y
							local valueY = math.clamp((mousePos.Y - top) / height, 0, 1)

							local h, s = Colorpicker._LastHue or 0, Colorpicker._LastSaturation or 0
							local v = 1 - valueY

							local newColor = Color3.fromHSV(h, s, v)
							Colorpicker:Set({ newColor, Colorpicker.Value[2] })
						end)

						EnableDragging(Components["TransparencyPickerButton"], function(mousePosRaw)
							local mousePos = Vector2.new(mousePosRaw.X, mousePosRaw.Y - MouseConstant)
							local top = Components["TransparencyPickerButton"].AbsolutePosition.Y
							local height = Components["TransparencyPickerButton"].AbsoluteSize.Y
							local yVal = math.clamp((mousePos.Y - top) / height, 0, 1)
							Colorpicker:Set({ Colorpicker.Value[1], yVal })
						end)

						Colorpicker:Set(Colorpicker.Default)

						Library.Flags[Colorpicker.Flag] = Colorpicker
						return Colorpicker
					end

					function Section:Keybind(KeybindData)
						local Keybind = {
							Name = KeybindData.Name,
							Flag = KeybindData.Flag,
							Default = KeybindData.Default or nil,
							Callback = KeybindData.Callback or function() end,
							Key = KeybindData.Key or nil,
							Mode = KeybindData.Mode or "Toggle",
							Active = false,
							Class = "Keybind",
						}

						Keybind.__index = Keybind

						local Components = {}

						do
							Components["KeybindHolder"] = Globals:Instance("Frame", {
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 20),
								Name = "KeybindHolder",
								Parent = self.Components["SectionElements"],
							})

							Components["KeybindTitle"] = Globals:Instance("TextLabel", {
								Font = Enum.Font.SourceSansSemibold,
								Text = Keybind.Name,
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 15),
								Name = "KeybindTitle",
								Parent = Components["KeybindHolder"],
							})

							Components["KeybindButton"] = Globals:Instance("TextButton", {
								Font = Enum.Font.SourceSansSemibold,
								Text = "None",
								TextColor3 = Color3.fromRGB(125, 158, 169),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Center,
								AutoButtonColor = false,
								BackgroundColor3 = Color3.fromRGB(8, 12, 18),
								BorderSizePixel = 0,
								Position = UDim2.new(1, -50, 0, 0),
								Size = UDim2.new(0, 50, 0, 15),
								Name = "KeybindButton",
								Parent = Components["KeybindHolder"],
							})

							Globals:Instance("UICorner", {
								CornerRadius = UDim.new(0, 4),
								Parent = Components["KeybindButton"],
							})

							Globals:Instance("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(28, 43, 53),
								Parent = Components["KeybindButton"],
							})
						end

						Keybind.Components = Components

						function Keybind:SetVisibility(visible)
							self.KeybindHolder.Visible = visible
						end

						function Keybind:SetKey(input)
							if input then
								if typeof(input.UserInputType) == "string" then
									input.UserInputType = Enum.UserInputType[input.UserInputType]

									if input.UserInputType == "KeyCode" then
										input.KeyCode = Enum.KeyCode[input.KeyCode]
									end
								end

								local keyType
								local keyValue

								if
									input.UserInputType == Enum.UserInputType.MouseButton1
									or input.UserInputType == Enum.UserInputType.MouseButton2
									or input.UserInputType == Enum.UserInputType.MouseButton3
								then
									keyType = "MouseButton"
									keyValue = input.UserInputType
								elseif input.UserInputType == Enum.UserInputType.Keyboard then
									keyType = "KeyCode"
									keyValue = input.KeyCode
								else
									keyType = "UserInputType"
									keyValue = input.UserInputType
								end

								self.Key = {
									Type = keyType,
									Value = keyValue,
								}

								Window.Hotkeys:UpdateStatus(
									self.Name,
									self.Active,
									Library:FormatKeyName(Library:GetInputName(input))
								)
								Components["KeybindButton"].Text = Library:FormatKeyName(Library:GetInputName(input))
							else
								Window.Hotkeys:UpdateStatus(self.Name, self.Active, "", true)
								self.Key = nil
								Components["KeybindButton"].Text = "None"
							end

							Globals:Tween(
								Components["KeybindButton"],
								TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
								{
									TextColor3 = Color3.fromRGB(125, 158, 169),
								}
							)
						end

						function Keybind:SetState(state)
							self.Active = state
							Window.Hotkeys:UpdateStatus(self.Name, self.Active)
							Library:DoCallback(self.Callback, state)
						end

						function Keybind:Set(value)
							self.Value = value
							self:SetKey(value)
						end

						function Keybind:Matches(input)
							if not self.Key then
								return false
							end

							if self.Key.Type == "KeyCode" then
								return input.KeyCode == self.Key.Value
							elseif self.Key.Type == "MouseButton" then
								return input.UserInputType == self.Key.Value
							elseif self.Key.Type == "UserInputType" then
								return input.UserInputType == self.Key.Value
							end

							return false
						end

						local Listening = false
						Library:Connection(
							"Keybind_" .. Keybind.Flag .. "_StartListen",
							Components["KeybindButton"].MouseButton1Click,
							function()
								if Listening then
									return
								end
								Listening = true

								Globals:Tween(
									Components["KeybindButton"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										TextColor3 = Color3.fromRGB(8, 12, 18),
									}
								)

								Components["KeybindButton"].Text = "..."

								Globals:Tween(
									Components["KeybindButton"],
									TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
									{
										TextColor3 = Color3.fromRGB(255, 255, 255),
									}
								)

								local ConnectionName = "Keybind_" .. Keybind.Flag .. "_InputListen"
								task.wait(0.06)
								Library:Connection(ConnectionName, UserInputService.InputBegan, function(input, gpe)
									if not Listening then
										return
									end
									Listening = false
									Library:Disconnect(ConnectionName)

									if input.KeyCode == Enum.KeyCode.Backspace then
										Keybind:Set(nil)
										return
									end

									if
										input.UserInputType == Enum.UserInputType.MouseButton1
										or input.UserInputType == Enum.UserInputType.MouseButton2
										or input.UserInputType == Enum.UserInputType.MouseButton3
										or input.UserInputType == Enum.UserInputType.Keyboard
									then
										Keybind:SetKey(input)
									end
								end)
							end
						)

						Library:Connection(
							"Keybind_" .. Keybind.Flag .. "_InputBegan",
							UserInputService.InputBegan,
							function(input, gpe)
								if gpe or Listening or not Keybind.Key then
									return
								end

								if Keybind:Matches(input) then
									if Keybind.Mode == "Toggle" then
										Keybind:SetState(not Keybind.Active)
									elseif Keybind.Mode == "Callback" then
										Library:DoCallback(Keybind.Callback)
									elseif Keybind.Mode == "Hold" then
										Keybind:SetState(true)
										Keybind.Active = true
									end
								end
							end
						)

						Library:Connection(
							"Keybind_" .. Keybind.Flag .. "_InputEnded",
							UserInputService.InputEnded,
							function(input, gpe)
								if gpe or Listening or not Keybind.Key then
									return
								end

								if Keybind:Matches(input) and Keybind.Mode == "Hold" and Keybind.Active then
									Keybind:SetState(false)
									Keybind.Active = false
								end
							end
						)

						Keybind:Set(Keybind.Default)
						Library.Flags[Keybind.Flag] = Keybind
						return Keybind
					end

					Section.Components = Components
					Category.Sections[Section.Name] = Section
					return Section
				end

				Category.Components = Components

				do
					Library:Connection(
						"PageHandler" .. Category.Name,
						Components["CategoryButton"].MouseButton1Down,
						function()
							Window:SetCategory({
								Name = Tab.Name .. "_" .. Category.Name,
								Pointer = Category,
								Parent = Tab,
							})
						end
					)

					Library:Connection(
						"CategoryMouseEnter" .. Category.Name,
						Components.CategoryButton.MouseEnter,
						function()
							Globals:Tween(
								Components["CategoryStroke"],
								TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
								{
									Color = Library.Theme.AccentedHighlight,
								}
							)
						end
					)

					Library:Connection(
						"CategoryMouseLeave" .. Category.Name,
						Components.CategoryButton.MouseLeave,
						function()
							if Components["CategoryButton"]:GetAttribute("Opened") then
								return
							end
							Globals:Tween(
								Components["CategoryStroke"],
								TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad),
								{
									Color = Color3.fromRGB(28, 43, 53),
								}
							)
						end
					)
				end

				table.insert(Tab.CategoryOrder, Category.Name)
				Tab.Categories[Category.Name] = Category
				return Category
			end

			Tab.Components = Components
			Window.Tabs[TabData.Name] = Tab
			return Tab
		end

		function Window:TabSeperator()
			local Components = {}

			Components["TabSeparatorHolder"] = Globals:Instance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				Name = "TabSeparatorHolder",
				Parent = self.Components["TabsScrollingFrame"],
			})

			Components["TabSeparatorLine"] = Globals:Instance("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(28, 43, 53),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, -7, 1, 0),
				Name = "TabSeparatorLine",
				Parent = Components["TabSeparatorHolder"],
			})

			return Components
		end

		Window.Components = Components
		Library.Window = Window
		return Window
	end

	function Library:Notify(txt, duration, color)
		duration = duration or 3
		color = color or Color3.fromRGB(94, 225, 211)

		local Components = {}
		local Padding = 12
		local IconSize = 25
		local TextPadding = 5
		local LabelFontSize = 14
		local BottomBufferSize = 4

		local TemporaryLabel = Instance.new("TextLabel")
		TemporaryLabel.Size = UDim2.new(1, 0, 1, 0)
		TemporaryLabel.TextSize = LabelFontSize
		TemporaryLabel.Font = Enum.Font.SourceSansBold
		TemporaryLabel.Text = txt
		TemporaryLabel.TextWrapped = true
		TemporaryLabel.Parent = Library.Notifications
		TemporaryLabel.Visible = false

		task.wait()
		local TextBounds = TemporaryLabel.TextBounds
		TemporaryLabel:Destroy()

		local NotificationHeight = math.max(TextBounds.Y + BottomBufferSize, IconSize)
		local NotificationWidth = IconSize + TextBounds.X + TextPadding * 2

		local YPosition = 75
		for _, NotificationData in ipairs(Library.NotificationList) do
			YPosition = YPosition + NotificationData.Height + Padding
		end

		Components["NewNotification"] = Globals:Instance("Frame", {
			BackgroundColor3 = Color3.fromRGB(8, 12, 18),
			BorderSizePixel = 0,
			Position = UDim2.new(0, -NotificationWidth - 20, 0, YPosition),
			Size = UDim2.new(0, NotificationWidth, 0, NotificationHeight),
			Name = "NewNotification",
			Parent = Library.Notifications,
		})

		Globals:Instance("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Parent = Components["NewNotification"],
		})

		Globals:Instance("ImageLabel", {
			Image = Library.ShadowImage,
			ImageColor3 = color,
			ImageTransparency = 0.7,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 30, 1, 30),
			ZIndex = 0,
			Parent = Components["NewNotification"],
		})

		Globals:Instance("UIStroke", {
			Color = Color3.fromRGB(28, 43, 53),
			Parent = Components["NewNotification"],
		})

		Globals:Instance("TextLabel", {
			Font = Enum.Font.SourceSansBold,
			Text = txt,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = LabelFontSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, IconSize + TextPadding, 0, 0),
			Size = UDim2.new(1, -IconSize - TextPadding * 2, 1, 0),
			TextWrapped = true,
			Parent = Components["NewNotification"],
		})

		Globals:Instance("ImageLabel", {
			Image = Library.LogoImage,
			Visible = false,
			ImageColor3 = color,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, IconSize, 0, IconSize),
			Position = UDim2.new(0, 0, 0.5, -IconSize / 2),
			Parent = Components["NewNotification"],
		})

		table.insert(Library.NotificationList, {
			Frame = Components["NewNotification"],
			Height = NotificationHeight,
		})

		Globals:Tween(
			Components["NewNotification"],
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0, 10, 0, YPosition),
			}
		)

		local CurrentY = 75
		for _, NotificationData in ipairs(Library.NotificationList) do
			Globals:Tween(
				NotificationData.Frame,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.new(0, 10, 0, CurrentY),
				}
			)
			CurrentY = CurrentY + NotificationData.Height + Padding
		end

		task.delay(duration, function()
			for _, child in pairs(Components["NewNotification"]:GetChildren()) do
				if child:IsA("TextLabel") then
					Globals:Tween(
						child,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{ TextTransparency = 1 }
					)
				elseif child:IsA("ImageLabel") then
					Globals:Tween(
						child,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{ ImageTransparency = 1 }
					)
				elseif child:IsA("UIStroke") then
					Globals:Tween(
						child,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{ Transparency = 1 }
					)
				end
			end

			task.wait(0.2)
			local IterationToRemove
			for i, NotificationData in ipairs(Library.NotificationList) do
				if NotificationData.Frame == Components["NewNotification"] then
					IterationToRemove = i
					break
				end
			end

			if IterationToRemove then
				Library.NotificationList[IterationToRemove].Frame:Destroy()
				table.remove(Library.NotificationList, IterationToRemove)
			end

			CurrentY = 75
			for _, NotificationData in ipairs(Library.NotificationList) do
				Globals:Tween(
					NotificationData.Frame,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0, 10, 0, CurrentY),
					}
				)
				CurrentY = CurrentY + NotificationData.Height + Padding
			end
		end)
	end
end)()

Log("Loaded UI library.")

Threads.__index = Threads

Threads.Run = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	local Success, Error = pcall(self.Function)
	if not Success and Error then
		Library:Notify("Error occured. " .. tostring(Error), 1, Color3.fromRGB(255, 0, 0))
	end
end)

Threads.New = phNV(function(Name, Function, Priority) LPH_ATTRIBUTES(VM(NONE)) 
	local Thread = setmetatable({
		Name = Name,
		Function = Function,
		Priority = Priority,
	}, Threads)

	if not Priority then
		Priority = "Render"
	end
	Thread.Priority = Priority

	local Index = #Threads[Priority] + 1
	Threads[Priority][Index] = Thread
	return Threads[Priority][Index]
end)
Log("Loaded threads library.")

Math.RoundToIncrement = phNV(function(value, increment) LPH_ATTRIBUTES(VM(NONE)) 
	return math.round(value / increment) * increment
end)

Math.FloorVector = phNV(function(Vector) LPH_ATTRIBUTES(VM(NONE)) 
	if typeof(Vector) == "Vector2" then
		return Vector2.new(math.floor(Vector.X), math.floor(Vector.Y))
	else
		return Vector3.new(math.floor(Vector.X), math.floor(Vector.Y), math.floor(Vector.Z))
	end
end)
Log("Loaded math library.")

Visuals.Sky = {}
Visuals.Skyboxes = {}
Visuals.Hitmarkers = {}
Visuals.CircleLines = {}
Visuals.LineCount = 30

function Visuals.Sky:NewSky(Data)
	local Name = Data.Name
	Visuals.Skyboxes[Name] = {
		SkyboxBk = Data.SkyboxBk,
		SkyboxDn = Data.SkyboxDn,
		SkyboxFt = Data.SkyboxFt,
		SkyboxLf = Data.SkyboxLf,
		SkyboxRt = Data.SkyboxRt,
		SkyboxUp = Data.SkyboxUp,
		MoonTextureId = Data.Moon or "rbxasset://sky/moon.jpg",
		SunTextureId = Data.Sun or "rbxasset://sky/sun.jpg",
	}
end

function Visuals.Sky:SwitchSkybox(Name)
	Library:Notify("Setting skybox: " .. Name)
	local OldSky = Lighting:FindFirstChildOfClass("Sky")

	local Sky = Lighting:FindFirstChildOfClass("Sky")
	do
		for Index, Value in next, Visuals.Skyboxes[Name] do
			Sky[Index] = Value
		end
	end
end

do
	do
		phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
			Visuals.Sky:NewSky({
				Name = "Sunset",
				SkyboxBk = "rbxassetid://600830446",
				SkyboxDn = "rbxassetid://600831635",
				SkyboxFt = "rbxassetid://600832720",
				SkyboxLf = "rbxassetid://600886090",
				SkyboxRt = "rbxassetid://600833862",
				SkyboxUp = "rbxassetid://600835177",
			})

			Visuals.Sky:NewSky({
				Name = "Arctic",
				SkyboxBk = "http://www.roblox.com/asset/?id=225469390",
				SkyboxDn = "http://www.roblox.com/asset/?id=225469395",
				SkyboxFt = "http://www.roblox.com/asset/?id=225469403",
				SkyboxLf = "http://www.roblox.com/asset/?id=225469450",
				SkyboxRt = "http://www.roblox.com/asset/?id=225469471",
				SkyboxUp = "http://www.roblox.com/asset/?id=225469481",
			})

			Visuals.Sky:NewSky({
				Name = "Elegant Morning",
				SkyboxBk = "rbxassetid://153767241",
				SkyboxDn = "rbxassetid://153767216",
				SkyboxFt = "rbxassetid://153767266",
				SkyboxLf = "rbxassetid://153767200",
				SkyboxRt = "rbxassetid://153767231",
				SkyboxUp = "rbxassetid://153767288",
			})

			Visuals.Sky:NewSky({
				Name = "Aesthetic Night",
				SkyboxBk = "rbxassetid://1045964490",
				SkyboxDn = "rbxassetid://1045964368",
				SkyboxFt = "rbxassetid://1045964655",
				SkyboxLf = "rbxassetid://1045964655",
				SkyboxRt = "rbxassetid://1045964655",
				SkyboxUp = "rbxassetid://1045962969",
			})

			Visuals.Sky:NewSky({
				Name = "Space",
				SkyboxBk = "http://www.roblox.com/asset/?id=166509999",
				SkyboxDn = "http://www.roblox.com/asset/?id=166510057",
				SkyboxFt = "http://www.roblox.com/asset/?id=166510116",
				SkyboxLf = "http://www.roblox.com/asset/?id=166510092",
				SkyboxRt = "http://www.roblox.com/asset/?id=166510131",
				SkyboxUp = "http://www.roblox.com/asset/?id=166510114",
			})

			Visuals.Sky:NewSky({
				Name = "Roblox Default",
				SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex",
				SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex",
				SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex",
				SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex",
				SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex",
				SkyboxUp = "rbxasset://textures/sky/sky512_up.tex",
			})

			Visuals.Sky:NewSky({
				Name = "Red Night",
				SkyboxBk = "http://www.roblox.com/Asset/?ID=401664839",
				SkyboxDn = "http://www.roblox.com/Asset/?ID=401664862",
				SkyboxFt = "http://www.roblox.com/Asset/?ID=401664960",
				SkyboxLf = "http://www.roblox.com/Asset/?ID=401664881",
				SkyboxRt = "http://www.roblox.com/Asset/?ID=401664901",
				SkyboxUp = "http://www.roblox.com/Asset/?ID=401664936",
			})

			Visuals.Sky:NewSky({
				Name = "Pink Skies",
				SkyboxBk = "http://www.roblox.com/asset/?id=151165214",
				SkyboxDn = "http://www.roblox.com/asset/?id=151165197",
				SkyboxFt = "http://www.roblox.com/asset/?id=151165224",
				SkyboxLf = "http://www.roblox.com/asset/?id=151165191",
				SkyboxRt = "http://www.roblox.com/asset/?id=151165206",
				SkyboxUp = "http://www.roblox.com/asset/?id=151165227",
			})

			Visuals.Sky:NewSky({
				Name = "Purple Sunset",
				SkyboxBk = "rbxassetid://264908339",
				SkyboxDn = "rbxassetid://264907909",
				SkyboxFt = "rbxassetid://264909420",
				SkyboxLf = "rbxassetid://264909758",
				SkyboxRt = "rbxassetid://264908886",
				SkyboxUp = "rbxassetid://264907379",
			})

			Visuals.Sky:NewSky({
				Name = "Blue Night",
				SkyboxBk = "http://www.roblox.com/Asset/?ID=12064107",
				SkyboxDn = "http://www.roblox.com/Asset/?ID=12064152",
				SkyboxFt = "http://www.roblox.com/Asset/?ID=12064121",
				SkyboxLf = "http://www.roblox.com/Asset/?ID=12063984",
				SkyboxRt = "http://www.roblox.com/Asset/?ID=12064115",
				SkyboxUp = "http://www.roblox.com/Asset/?ID=12064131",
			})

			Visuals.Sky:NewSky({
				Name = "Blossom Daylight",
				SkyboxBk = "http://www.roblox.com/asset/?id=271042516",
				SkyboxDn = "http://www.roblox.com/asset/?id=271077243",
				SkyboxFt = "http://www.roblox.com/asset/?id=271042556",
				SkyboxLf = "http://www.roblox.com/asset/?id=271042310",
				SkyboxRt = "http://www.roblox.com/asset/?id=271042467",
				SkyboxUp = "http://www.roblox.com/asset/?id=271077958",
			})

			Visuals.Sky:NewSky({
				Name = "Blue Nebula",
				SkyboxBk = "http://www.roblox.com/asset?id=135207744",
				SkyboxDn = "http://www.roblox.com/asset?id=135207662",
				SkyboxFt = "http://www.roblox.com/asset?id=135207770",
				SkyboxLf = "http://www.roblox.com/asset?id=135207615",
				SkyboxRt = "http://www.roblox.com/asset?id=135207695",
				SkyboxUp = "http://www.roblox.com/asset?id=135207794",
			})

			Visuals.Sky:NewSky({
				Name = "Blue Planet",
				SkyboxBk = "rbxassetid://218955819",
				SkyboxDn = "rbxassetid://218953419",
				SkyboxFt = "rbxassetid://218954524",
				SkyboxLf = "rbxassetid://218958493",
				SkyboxRt = "rbxassetid://218957134",
				SkyboxUp = "rbxassetid://218950090",
			})

			Visuals.Sky:NewSky({
				Name = "Deep Space",
				SkyboxBk = "http://www.roblox.com/asset/?id=159248188",
				SkyboxDn = "http://www.roblox.com/asset/?id=159248183",
				SkyboxFt = "http://www.roblox.com/asset/?id=159248187",
				SkyboxLf = "http://www.roblox.com/asset/?id=159248173",
				SkyboxRt = "http://www.roblox.com/asset/?id=159248192",
				SkyboxUp = "http://www.roblox.com/asset/?id=159248176",
			})

			if Lighting:FindFirstChildOfClass("Sky") then
				local OldSky = Lighting:FindFirstChildOfClass("Sky")
				Visuals.Sky:NewSky({
					Name = "Default Sky",
					SkyboxBk = OldSky.SkyboxBk,
					SkyboxDn = OldSky.SkyboxDn,
					SkyboxFt = OldSky.SkyboxFt,
					SkyboxLf = OldSky.SkyboxLf,
					SkyboxRt = OldSky.SkyboxRt,
					SkyboxUp = OldSky.SkyboxUp,
				})
			end
		end)()
	end
end

local TargetLine = Instance.new("Frame")
do
	TargetLine.Visible = false
	TargetLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TargetLine.BackgroundTransparency = 0
	TargetLine.Parent = Library.HeadsUp
	TargetLine.BorderSizePixel = 0
end

local TargetStroke = Instance.new("UIStroke")
do
	TargetStroke.Parent = TargetLine
	TargetStroke.Color = Color3.fromRGB(255, 255, 255)
	TargetStroke.Thickness = 1
end

for i = 1, Visuals.LineCount do
	local Line = TargetLine:Clone()
	Line.Parent = Library.HeadsUp
	Line.Name = "Circle_" .. tostring(i)
	table.insert(Visuals.CircleLines, Line)
end

Visuals.FOVSpace = Globals:Instance("ScreenGui", {
	Parent = CoreGui,
	IgnoreGuiInset = true,
})

Visuals.FOVOutline = Globals:Instance("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	BackgroundTransparency = 1,
	ZIndex = 9999,
	Size = UDim2.new(0, 500, 0, 500),
	Visible = true,
	Parent = Visuals.FOVSpace,
	Visible = false,
})

Visuals.FOVCircle = Globals:Instance("Frame", {
	BackgroundTransparency = 1,
	ZIndex = 9999,
	Position = UDim2.new(0, -1, 0, -1),
	Size = UDim2.new(1, 2, 1, 2),
	Visible = true,
	Parent = Visuals.FOVOutline,
	BackgroundColor3 = Library.Theme.Accent,
})

Visuals.FOVInline = Globals:Instance("Frame", {
	Size = UDim2.new(1, -2, 1, -2),
	Position = UDim2.new(0, 1, 0, 1),
	BackgroundTransparency = 0.8,
	Parent = Visuals.FOVCircle,
	BackgroundColor3 = Library.Theme.Accent,
})

Visuals.FOVCircleCorner = Globals:Instance("UICorner", {
	CornerRadius = UDim.new(1, 0),
	Parent = Visuals.FOVCircle,
})

Visuals.FOVInlineCorner = Globals:Instance("UICorner", {
	CornerRadius = UDim.new(1, 0),
	Parent = Visuals.FOVInline,
})

Visuals.FOVCircleStroke = Globals:Instance("UIStroke", {
	Parent = Visuals.FOVCircle,
	Thickness = 3,
	Color = Library.Theme.Accent,
})

Visuals.FOVOutlineStroke = Globals:Instance("UIStroke", {
	Thickness = 5,
	Color = Color3.new(),
	Parent = Visuals.FOVOutline,
})

Visuals.FOVOutlineCorner = Globals:Instance("UICorner", {
	CornerRadius = UDim.new(1, 0),
	Parent = Visuals.FOVOutline,
})

Visuals.CrosshairHolder = Globals:Instance("Frame", {
	Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2),
	Size = UDim2.new(0, 100, 0, 100),
	BackgroundTransparency = 1,
	Parent = Library.HeadsUp,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Visible = false,
})

Visuals.CrosshairTop = Globals:Instance("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderColor3 = Color3.fromRGB(),
	BorderMode = Enum.BorderMode.Middle,
	Position = UDim2.new(0.5, 0, 0.5, -20),
	Size = UDim2.new(0, 2, 0, 20),
	Parent = Visuals.CrosshairHolder,
})

Visuals.CrosshairTopGradient = Globals:Instance("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	}),
	Rotation = -90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.694513738155365, 0.5249999761581421),
		NumberSequenceKeypoint.new(0.8503741025924683, 0.78125),
		NumberSequenceKeypoint.new(1, 0.862500011920929),
	}),
	Parent = Visuals.CrosshairTop,
})

Visuals.CrosshairBottom = Globals:Instance("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderColor3 = Color3.fromRGB(0, 0, 0),
	BorderMode = Enum.BorderMode.Middle,
	Position = UDim2.new(0.5, 0, 0.5, 20),
	Size = UDim2.new(0, 2, 0, 20),
	Parent = Visuals.CrosshairHolder,
	Name = "Bottom",
})

Visuals.CrosshairBottomGradient = Globals:Instance("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	}),
	Rotation = 90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6945, 0.525),
		NumberSequenceKeypoint.new(0.8504, 0.78125),
		NumberSequenceKeypoint.new(1, 0.8625),
	}),
	Parent = Visuals.CrosshairBottom,
})

Visuals.CrosshairLeft = Globals:Instance("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderColor3 = Color3.fromRGB(0, 0, 0),
	BorderMode = Enum.BorderMode.Middle,
	Position = UDim2.new(0.5, -20, 0.5, 0),
	Size = UDim2.new(0, 20, 0, 2),
	Parent = Visuals.CrosshairHolder,
	Name = "Left",
})

Visuals.CrosshairLeftGradient = Globals:Instance("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	}),
	Rotation = 180,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6945, 0.525),
		NumberSequenceKeypoint.new(0.8504, 0.78125),
		NumberSequenceKeypoint.new(1, 0.8625),
	}),
	Parent = Visuals.CrosshairLeft,
})

Visuals.CrosshairRight = Globals:Instance("Frame", {
	Name = "Right",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderColor3 = Color3.fromRGB(0, 0, 0),
	BorderMode = Enum.BorderMode.Middle,
	Position = UDim2.new(0.5, 20, 0.5, 0),
	Size = UDim2.new(0, 20, 0, 2),
	Parent = Visuals.CrosshairHolder,
})

Visuals.CrosshairRightGradient = Globals:Instance("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.694513738155365, 0.5249999761581421),
		NumberSequenceKeypoint.new(0.8503741025924683, 0.78125),
		NumberSequenceKeypoint.new(1, 0.862500011920929),
	}),
	Parent = Visuals.CrosshairRight,
})

Visuals.MiscSpace = Globals:Instance("ScreenGui", {
	Parent = CoreGui,
	IgnoreGuiInset = true,
	DisplayOrder = 0,
	Name = "Misc Space",
})

Visuals.ESPSpace = Globals:Instance("ScreenGui", {
	Parent = CoreGui,
	IgnoreGuiInset = true,
	DisplayOrder = 0,
	Name = "ESP Space",
})

Visuals.LOSFrame = Globals:Instance("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 500, 0, 500),
	Parent = Visuals.ESPSpace,
	Position = UDim2.new(0.5, 0, 0, 100),
})

Visuals.LOSLayout = Globals:Instance("UIListLayout", {
	Parent = Visuals.LOSFrame,
	Padding = UDim.new(0, 3),
})

Visuals.RotateLine = phNV(function(Object, Thickness, From, To) LPH_ATTRIBUTES(VM(NONE)) 
	local X1, Y1, X2, Y2 = From.X, From.Y, To.X, To.Y

	local CenterX = (X1 + X2) / 2
	local CenterY = (Y1 + Y2) / 2

	local DeltaX = math.abs(X1 - X2) ^ 2
	local DeltaY = math.abs(Y1 - Y2) ^ 2

	local Distance = math.sqrt(DeltaX + DeltaY)
	local Rotation = math.deg(math.atan2(Y1 - Y2, X1 - X2))

	Object.AnchorPoint = Vector2.new(0.5, 0.5)
	Object.Position = UDim2.fromOffset(CenterX, CenterY)
	Object.Size = UDim2.fromOffset(Distance, Thickness)
	Object.Rotation = Rotation
end)

Visuals.CreateHitmarker = phNV(function(Part, Position) LPH_ATTRIBUTES(VM(NONE)) 
	local Index = #Visuals.Hitmarkers + 1
	local Hitmarker = Globals:Instance("ImageLabel", {
		Image = GetImage("HitmarkerImage"),
		Size = UDim2.new(0, Library.Flags.HitmarkerSize.Value + 10, 0, Library.Flags.HitmarkerSize.Value + 10),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = Visuals.ESPSpace,
		ZIndex = Library.Flags.PrioritizeHitmarkers.Value and 5 or 1,
		ImageTransparency = 1,
		ImageColor3 = Library.Flags.HitmarkerColor.Value[1],
		Visible = true,
	})

	Visuals.Hitmarkers[Index] = {
		Position = Position,
		Part = Part,
		Hitmarker = Hitmarker,
	}

	Globals:Tween(Hitmarker, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		ImageTransparency = 0,
		Size = UDim2.new(0, Library.Flags.HitmarkerSize.Value, 0, Library.Flags.HitmarkerSize.Value),
	})

	if Library.Flags.HitmarkerRandomRotation.Value then
		Globals:Tween(Hitmarker, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Rotation = math.random(-90, 90),
		})
	end

	Delay(Library.Flags.HitmarkerTime.Value, function()
		local Tween = Globals:Tween(Hitmarker, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			ImageTransparency = 1,
		})
		Tween.Completed:Wait()
		Hitmarker:Destroy()
		Visuals.Hitmarkers[Index] = nil
	end)
end)

Visuals.DrawLine = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
	local Frame = Drawing.new("Line")
	Frame.Visible = false
	Frame.ZIndex = 2
	Frame.Color = Color3.fromRGB(255, 255, 255)
	return Frame
end)

Visuals.DrawOutline = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
	local Frame = Drawing.new("Line")
	Frame.Visible = false
	Frame.ZIndex = 1
	Frame.Thickness = 3
	Frame.Color = Color3.fromRGB(0, 0, 0)
	return Frame
end)

local VisibilityCache = setmetatable({}, { __mode = "k" })

Visuals.IsPartVisible = phNV(function(Part, Origin) LPH_ATTRIBUTES(VM(NONE)) 
	if not Part then
		return nil
	end

	local Cached = not Origin and VisibilityCache[Part]
	if Cached and (tick() - Cached.t) < 0.12 then
		return Cached.v
	end

	if not Origin then
		Origin = Camera.CFrame.p
	end

	local Direction = (Part.CFrame.p - Origin).Unit * ((Part.CFrame.p - Origin).Magnitude + 10)

	local Params = Globals.RaycastParams

	local RayResult = Workspace:Raycast(Origin, Direction, Params)

	local Result = (RayResult and RayResult.Instance and RayResult.Instance:IsDescendantOf(Part.Parent)) or nil

	if not Origin then
		VisibilityCache[Part] = { t = tick(), v = Result }
	end

	return Result
end)

Visuals.GetDistanceFromCenter = phNV(function(part) LPH_ATTRIBUTES(VM(NONE)) 
	local position = part
	if typeof(part) == "Instance" then
		position = part.CFrame.p
	end
	local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(position)
	if OnScreen then
		local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		return (Center - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude
	end
	return math.huge
end)

Log("Loaded visuals library.")

EntityClass.__index = EntityClass
EntityClass.Global.__index = EntityClass.Global
EntityClass.Main.__index = EntityClass.Main
EntityClass.Main.Functions.__index = EntityClass.Main.Functions

do
	local function RFlag(Name)
		local F = Library.Flags[Name]
		return F and F.Value
	end
	Globals.RFlag = RFlag

	local FastParams = RaycastParams.new()
	FastParams.FilterType = Enum.RaycastFilterType.Exclude
	FastParams.IgnoreWater = true
	Globals.RefreshFastFilter = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		local filters = {}
		local base = Globals.RaycastParams and Globals.RaycastParams.FilterDescendantsInstances
		if type(base) == "table" then
			for _, v in ipairs(base) do filters[#filters + 1] = v end
		end
		if Client.Character then filters[#filters + 1] = Client.Character end
		filters[#filters + 1] = Camera
		for _, name in ipairs({ "VFX", "Drops", "Plants", "Animals" }) do
			local folder = Workspace:FindFirstChild(name)
			if folder then filters[#filters + 1] = folder end
		end
		FastParams.FilterDescendantsInstances = filters
	end)
	Globals.RefreshFastFilter()

	Globals.FastRay = phNV(function(origin, direction) LPH_ATTRIBUTES(VM(NONE)) 
		local start = origin
		local remaining = direction
		for _ = 1, 4 do
			local result = Workspace:Raycast(start, remaining, FastParams)
			if not result then return nil end
			local hit = result.Instance
			if hit.Transparency < 0.95 and hit.CanCollide then
				return result
			end
			local travelled = (result.Position - start).Magnitude + 0.02
			local length = remaining.Magnitude - travelled
			if length <= 0.02 then return nil end
			start = result.Position + remaining.Unit * 0.02
			remaining = remaining.Unit * length
		end
		return nil
	end)

	Globals.StrictClear = phNV(function(origin, target) LPH_ATTRIBUTES(VM(NONE)) 
		if typeof(origin) ~= "Vector3" or typeof(target) ~= "Vector3" then return false end
		local offset = target - origin
		if offset.Magnitude < 0.05 then return true end
		return Globals.FastRay(origin, offset + offset.Unit * 0.4) == nil
	end)

	Globals.ServerOrigins = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		local character = Client.Character
		local root = character and (character.PrimaryPart or character:FindFirstChild("HumanoidRootPart"))
		if not root then return {} end
		local origin = (root.CFrame * CFrame.new(0, 1.5, 0)).Position
		local okPing, ping = pcall(function() return Client:GetNetworkPing() end)
		local lag = math.clamp((okPing and type(ping) == "number" and ping or 0.1) + 0.05, 0.05, 0.35)
		local velocity = root.AssemblyLinearVelocity
		local origins = { origin }
		if velocity.Magnitude > 1 then
			origins[2] = origin - velocity * lag
			origins[3] = origin - velocity * (lag * 0.5)
		end
		return origins
	end)

	Globals.ManipFlash = phNV(function(candidate, target) LPH_ATTRIBUTES(VM(NONE)) 
		local flatTarget = Vector3.new(target.X, candidate.Y, target.Z)
		if (flatTarget - candidate).Magnitude < 0.05 then return candidate end
		return (CFrame.lookAt(candidate, flatTarget) * CFrame.new(0.5, -0.3, -2)).Position
	end)

	Globals.BulletStats = nil

	Globals.SimulatePath = phNV(function(origin, direction, speed, gravity, maxRange, targetCharacter, targetPoint) LPH_ATTRIBUTES(VM(NONE)) 
		if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" or type(speed) ~= "number" or speed <= 1 then
			return false, math.huge
		end
		gravity = type(gravity) == "number" and gravity or 0
		maxRange = type(maxRange) == "number" and maxRange or 1000
		local accel = Workspace.Gravity * gravity
		local step = 1 / 60
		local position = origin
		local velocity = direction.Unit * speed
		local travelled = 0
		local closest = math.huge
		for _ = 1, 400 do
			local length = math.min(speed * step, maxRange - travelled)
			if length <= 0.05 then break end
			local segment = velocity.Unit * length
			if typeof(targetPoint) == "Vector3" then
				local toTarget = targetPoint - position
				local along = math.clamp(toTarget:Dot(segment.Unit), 0, length)
				closest = math.min(closest, (position + segment.Unit * along - targetPoint).Magnitude)
			end
			local res = Globals.FastRay(position, segment)
			if res then
				local hitTarget = targetCharacter ~= nil and res.Instance:IsDescendantOf(targetCharacter)
				return hitTarget, closest
			end
			position = position + segment
			travelled = travelled + length
			velocity = velocity - Vector3.new(0, accel, 0) * step
		end
		return false, closest
	end)

	Globals.SolveAim = phNV(function(from, target, speed, gravity) LPH_ATTRIBUTES(VM(NONE)) 
		if type(speed) ~= "number" or speed <= 1 or type(gravity) ~= "number" or gravity <= 0 then
			return target
		end
		local accel = Workspace.Gravity * gravity
		local step = 1 / 60
		local aim = target
		for _ = 1, 5 do
			local direction = aim - from
			if direction.Magnitude < 0.05 then return target end
			local position = from
			local velocity = direction.Unit * speed
			local closestPoint, closestDistance = position, math.huge
			local previousDistance = math.huge
			for _ = 1, 600 do
				local segment = velocity.Unit * speed * step
				local toTarget = target - position
				local along = math.clamp(toTarget:Dot(segment.Unit), 0, segment.Magnitude)
				local point = position + segment.Unit * along
				local distance = (point - target).Magnitude
				if distance < closestDistance then
					closestPoint, closestDistance = point, distance
				end
				if distance > previousDistance and along <= 0 then break end
				previousDistance = distance
				position = position + segment
				velocity = velocity - Vector3.new(0, accel, 0) * step
			end
			local miss = target - closestPoint
			if miss.Magnitude < 0.05 then break end
			aim = aim + miss
		end
		return aim
	end)

	Globals.BallisticReach = phNV(function(origin, point, character) LPH_ATTRIBUTES(VM(NONE)) 
		local stats = Globals.BulletStats
		if not stats then return nil end
		if (point - origin).Magnitude > stats.range then return false end
		local okAim, aimPoint = pcall(Globals.SolveAim, origin, point, stats.speed, stats.gravity)
		if not okAim or typeof(aimPoint) ~= "Vector3" then aimPoint = point end
		local direction = aimPoint - origin
		if direction.Magnitude < 0.05 then return false end
		local okSim, reached = pcall(Globals.SimulatePath, origin, direction.Unit, stats.speed, stats.gravity, stats.range, character, point)
		return okSim and reached == true
	end)

	Globals.ManipValid = phNV(function(candidate, target) LPH_ATTRIBUTES(VM(NONE)) 
		for _, origin in ipairs(Globals.ServerOrigins()) do
			if not Globals.StrictClear(origin, candidate) then return false end
		end
		if typeof(target) == "Vector3" then
			local flash = Globals.ManipFlash(candidate, target)
			if not Globals.StrictClear(candidate, flash) then return false end
		end
		return true
	end)

	local manipOffsets = {}
	for _, radius in ipairs({ 3, 5.5, 8, 10 }) do
		for _, height in ipairs({ 0, 3, 6 }) do
			for index = 0, 15 do
				local angle = index * math.pi / 8
				local offset = Vector3.new(math.sin(angle) * radius, height, -math.cos(angle) * radius)
				if offset.Magnitude <= 10.5 then
					manipOffsets[#manipOffsets + 1] = offset
				end
			end
		end
	end
	for _, height in ipairs({ 3, 5, 7.5, 10 }) do
		manipOffsets[#manipOffsets + 1] = Vector3.new(0, height, 0)
	end
	Globals.ManipOffsets = manipOffsets
	Globals.ManipBodyParts = { "Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso" }
end

do
	local function RFlag(Name)
		local F = Library.Flags[Name]
		return F and F.Value
	end

	local spinStates = setmetatable({}, { __mode = "k" })
	Globals.DesyncedPositions = setmetatable({}, { __mode = "k" })
	Globals.UndergroundSet = setmetatable({}, { __mode = "k" })
	Globals.PitchResolved = setmetatable({}, { __mode = "k" })
	local desyncState = setmetatable({}, { __mode = "k" })
	local undergroundCheck = 0

	local function updateSpin()
		if not RFlag("SpinResolver") then return end
		local now = os.clock()
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player ~= Client and player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				local _, yaw = root.CFrame:ToOrientation()
				local state = spinStates[root]
				if not state then
					spinStates[root] = { yaw = yaw, t = now, rate = 0, jumps = 0, lastJump = 0 }
				else
					local elapsed = now - state.t
					if elapsed > 0 then
						local delta = (yaw - state.yaw + math.pi) % (2 * math.pi) - math.pi
						local rate = math.abs(delta) / elapsed
						state.rate = state.rate * 0.85 + rate * 0.15
						if math.abs(delta) > math.rad(45) then
							state.jumps = math.min(state.jumps + 1, 10)
							state.lastJump = now
						elseif now - state.lastJump > 0.6 then
							state.jumps = 0
						end
					end
					state.yaw, state.t = yaw, now
				end
			end
		end
	end

	local function updatePitch()
		local store = Globals.PitchResolved
		if not RFlag("PitchResolver") then
			for k in pairs(store) do store[k] = nil end
			return
		end
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player ~= Client and player.Character
			local head = character and character:FindFirstChild("Head")
			if head and head:IsA("BasePart") then
				local ly = head.CFrame.LookVector.Y
				if ly > 0.3 then
					store[character] = "up"
				elseif ly < -0.3 then
					store[character] = "down"
				else
					store[character] = "neutral"
				end
			end
		end
	end

	local function updateDesync()
		local DesyncedPositions = Globals.DesyncedPositions
		if not RFlag("DesyncResolver") then
			for k in pairs(DesyncedPositions) do DesyncedPositions[k] = nil end
			for k in pairs(desyncState) do desyncState[k] = nil end
			return
		end
		local now = os.clock()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= Client then
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if not root then
					desyncState[player] = nil
					if character then DesyncedPositions[character] = nil end
				else
					local st = desyncState[player]
					local raw = root.Position
					if not st or st.Character ~= character then
						desyncState[player] = { Character = character, LastRaw = raw, LastGood = raw, IgnoreUntil = now + 1.2 }
						DesyncedPositions[character] = nil
					else
						local distance = (raw - st.LastRaw).Magnitude
						if now < st.IgnoreUntil or distance > 60 then
							st.LastRaw, st.LastGood = raw, raw
							DesyncedPositions[character] = nil
						elseif distance > 14 then
							DesyncedPositions[character] = st.LastGood
							st.LastRaw = raw
						else
							st.LastRaw, st.LastGood = raw, raw
							DesyncedPositions[character] = nil
						end
					end
				end
			end
		end
	end

	local function updateUnderground()
		local set = Globals.UndergroundSet
		if not RFlag("UndergroundResolver") then
			for k in pairs(set) do set[k] = nil end
			return
		end
		if os.clock() - undergroundCheck < 0.15 then return end
		undergroundCheck = os.clock()
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player ~= Client and player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			local under = false
			if animator then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					if track.Animation and track.Animation.AnimationId == "rbxassetid://13435049596" then
						under = true
						break
					end
				end
			end
			if character then set[character] = under or nil end
		end
	end

	Globals.ResolveAimPoint = phNV(function(part, humanoid) LPH_ATTRIBUTES(VM(NONE)) 
		local pos = part.Position
		local root = humanoid and humanoid.RootPart
		if root then
			local character = root.Parent
			local resolved = character and Globals.DesyncedPositions[character]
			if typeof(resolved) == "Vector3" then
				pos = Vector3.new(resolved.X, pos.Y, resolved.Z)
			end
		end
		if RFlag("SpinResolver") and root then
			local state = spinStates[root]
			if state then
				local angular = math.abs(root.AssemblyAngularVelocity.Y)
				if state.rate > 5 or angular > 5 or state.jumps >= 2 then
					local rootPos = root.Position
					return Vector3.new(rootPos.X, pos.Y, rootPos.Z), true
				end
			end
		end
		return pos, false
	end)

	Globals.ResolveVelocity = phNV(function(part, humanoid) LPH_ATTRIBUTES(VM(NONE)) 
		local root = humanoid and humanoid.RootPart
		local velocity = root and root.AssemblyLinearVelocity
		if typeof(velocity) ~= "Vector3" then velocity = part.AssemblyLinearVelocity end
		if typeof(velocity) ~= "Vector3" then return Vector3.zero end
		local spoofed = velocity.Y ~= velocity.Y or velocity.X ~= velocity.X or velocity.Y < -100
			or math.abs(velocity.X) > 1000 or math.abs(velocity.Z) > 1000
		if humanoid then
			if spoofed and RFlag("VelocityResolver") then
				velocity = humanoid:GetMoveVelocity() * 1.7
			elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall
				or (humanoid.MoveDirection.Magnitude > 0.05
					and (root and (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude or 0) < 1) then
				velocity = humanoid.MoveDirection * humanoid.WalkSpeed * 1.7
			end
		end
		return Vector3.new(math.clamp(velocity.X, -26, 26), velocity.Y, math.clamp(velocity.Z, -26, 26))
	end)

	RunService.Heartbeat:Connect(phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		pcall(updateSpin)
		pcall(updatePitch)
		pcall(updateDesync)
		pcall(updateUnderground)
	end))
end

EntityClass.Global.FindVisiblePosition = phNV(function(Origin, Destination) LPH_ATTRIBUTES(VM(NONE)) 
	if not (Destination and Destination.Parent) then return nil end
	local character = Client.Character
	local myRoot = character and (character.PrimaryPart or character:FindFirstChild("HumanoidRootPart"))
	if not myRoot then return nil end
	Globals.RefreshFastFilter()
	local origin
	do
		local vfx = Workspace:FindFirstChild("VFX")
		local vms = vfx and vfx:FindFirstChild("VMs")
		if vms then
			for _, v in ipairs(vms:GetDescendants()) do
				if v:IsA("BasePart") and v.Name == "FlashPart" then
					origin = v.Position
					break
				end
			end
		end
	end
	if not origin then
		origin = (myRoot.CFrame * CFrame.new(0, 1.5, 0)).Position
	end
	local target = Destination.Position
	local targetModel = Destination.Parent
	local flat = Vector3.new(target.X - origin.X, 0, target.Z - origin.Z)
	local forward = flat.Magnitude > 0.05 and flat.Unit or Vector3.new(0, 0, -1)
	local right = forward:Cross(Vector3.new(0, 1, 0))
	local far = flat.Magnitude > 150 and Globals.BulletStats ~= nil
	local points = { target }
	for _, name in ipairs(Globals.ManipBodyParts) do
		local body = targetModel:FindFirstChild(name)
		if body and body:IsA("BasePart") and body ~= Destination then
			points[#points + 1] = body.Position
		end
	end
	local candidates = {}
	for _, offset in ipairs(Globals.ManipOffsets) do
		local world = right * offset.X + Vector3.new(0, offset.Y, 0) - forward * offset.Z
		local towardTarget = world.Magnitude > 0.01 and forward:Dot(world.Unit) or 0
		candidates[#candidates + 1] = { world = world, score = world.Magnitude - towardTarget * 1.5 }
	end
	table.sort(candidates, function(a, b) return a.score < b.score end)
	local simulations = 0
	for _, item in ipairs(candidates) do
		local candidate = origin + item.world
		if Globals.StrictClear(origin, candidate) then
			local flash = Globals.ManipFlash(candidate, target)
			if Globals.StrictClear(candidate, flash) then
				for _, point in ipairs(points) do
					local toPoint = point - flash
					local blocker = Globals.FastRay(flash, toPoint + toPoint.Unit * 0.5)
					if not blocker or blocker.Instance:IsDescendantOf(targetModel) then
						if not far then
							if Globals.ManipValid(candidate, target) then
								return candidate
							end
							break
						end
						if simulations < 24 then
							simulations = simulations + 1
							if Globals.BallisticReach(flash, point, targetModel) and Globals.ManipValid(candidate, target) then
								return candidate
							end
						end
					end
				end
			end
		end
	end
	local CamPos = Camera.CFrame.Position
	for _, frac in { 0.3, 0.45, 0.6, 0.75, 0.9 } do
		local probe = CamPos:Lerp(target, frac)
		if Visuals.IsPartVisible(Destination, probe) then
			return probe
		end
	end
	return nil
end)
EntityClass.Global.Create = phNV(function(self, Object, Data) LPH_ATTRIBUTES(VM(NONE)) 
	if typeof(Object) ~= "Instance" then
		rconsoleprint(
			"corescript",
			"invalid argument #2 <instance> expected. Did you index instead of namecall?",
			"Type recieved:",
			typeof(Object)
		)
		return
	end

	if typeof(Data) ~= "table" then
		rconsoleprint(
			"corescript",
			"invalid argument #3 <table> expected. Did you index instead of namecall?",
			"Type recieved:",
			typeof(Data)
		)
		return
	end

	local Entity = setmetatable({
		Name = Data.Name or Object.Name,
		Character = Data.Character or (Object:IsA("Player") and Object.Character),
		DisplayName = Object:IsA("Player") and Object.DisplayName or (Data.Name or Object.Name),
		Components = {},
		LastOffscreenRefresh = tick(),
		LastChamsRefresh = tick(),
		LastUpdate = tick(),
		Components = EntityClass.Main.Functions.CreateComponents(),
		CachedArmor = {},
		CachedItem = nil,
		CachedAttachments = {},
		ItemHistory = {},
		Class = Data.Class,
		ClassType = Data.ClassType,
		Pointer = Object,
		Adornments = {},
	}, EntityClass.Main.Functions)

	EntityClass.Main.Cache[Object] = Entity
	return Entity
end)

Log("Loaded EntityClass Global library.")

EntityClass.FlagProperties = {
	Size = UDim2.new(0, 200, 0, 7),
	FontFace = Fonts.SmallestPixel,
	TextSize = 8,
	BackgroundTransparency = 1,
	TextTransparency = 1,
	TextStrokeTransparency = 1,
	Text = "",
	ClipsDescendants = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}

EntityClass.Main.Functions.__index = EntityClass.Main.Functions

EntityClass.Main.Functions.Remove = phNV(function(self, Instance) LPH_ATTRIBUTES(VM(NONE)) 
	local ObjectPointer = EntityClass.Main.Cache[Instance]
	if not ObjectPointer then
		return
	end

	ObjectPointer.Components.LookAngle:Remove()
	ObjectPointer.Components.LookAngleOutline:Remove()

	for Index, Value in ObjectPointer.Components do
		if Index == "Corners" or Index == "LookAngle" or Index == "Skeleton" or Index == "LookAngleOutline" then
			continue
		end
		Value:Destroy()
	end

	for Index, Value in ObjectPointer.Components.Corners do
		Value:Destroy()
	end

	for Index, Value in ObjectPointer.Components.Skeleton do
		Value:Remove()
	end

	EntityClass.Main.Cache[Instance] = nil
end)

EntityClass.Main.Functions.ApplyArmorVisuals = phNV(function(self, Instance) LPH_ATTRIBUTES(VM(NONE)) 
	if Instance:IsA("MeshPart") and Instance.Transparency ~= 1 then
		Instance:SetAttribute("OriginalMaterial", Instance.Material)
		Instance:SetAttribute("OriginalColor", Instance.Color)
		Instance:SetAttribute("OriginalTextureId", Instance.TextureID)
		Instance:SetAttribute("OriginalReflectance", Instance.Reflectance)
		Instance.CanQuery = false

		if Library.Flags["Sandbox" .. self.ClassType] and Library.Flags["Sandbox" .. self.ClassType].Value then
			Instance.Color = Library.Flags[self.ClassType .. "ArmorColor"].Value[1]
			Instance.Reflectance = Library.Flags[self.ClassType .. "ArmorReflectance"].Value
				* Library.Flags[self.ClassType .. "ArmorReflectanceMul"].Value
			Instance.Material = Library.Flags[self.ClassType .. "ArmorMaterial"].Value
			if Instance:IsA("MeshPart") and Instance.Material == Enum.Material.ForceField then
				Instance.TextureID = "rbxassetid://10913193650"
			elseif Instance:IsA("MeshPart") and Instance.Material ~= Enum.Material.ForceField then
				Instance.TextureID = ""
			end
		else
			Instance.Color = Instance:GetAttribute("OriginalColor")
			Instance.Material = Instance:GetAttribute("OriginalMaterial")
			Instance.Reflectance = Instance:GetAttribute("OriginalReflectance")
			if Instance:IsA("MeshPart") then
				Instance.TextureID = Instance:GetAttribute("OriginalTextureId")
			end
		end
	end
end)

EntityClass.Main.Functions.OnCharacterAdded = phNV(function(self, Character) LPH_ATTRIBUTES(VM(NONE)) 
	self.CachedArmor = {}
	self.CachedItem = nil
	if not Character then
		rconsoleprint("invalid argument #1, <Instance> expected, got", typeof(Character))
		return
	end

	for Index, Child in next, Character:GetChildren() do
		if table.find(EntityClass.ItemList, Child.Name) then
			self.CachedItem = Child
		end

		if Child.Name:find("Armor") then
			for Index, MeshPart in Child:GetChildren() do
				self:ApplyArmorVisuals(MeshPart)
			end

			if Globals.ArmorNames[Child.Name] then
				local Info = Globals.ArmorNames[Child.Name]
				self.CachedArmor[Child] = {
					Name = Info.Name,
					Skin = Info.Skin,
				}
			else
				local ModelName = Child.Name

				local ArmorSplit = ModelName:split("/")

				if not ArmorSplit then
					return
				end
				local ArmorFormat = ArmorSplit[1]
				local Skin = ArmorSplit[2]

				local ArmorFormatSplit = ArmorFormat:split("_")
				local ArmorId = ArmorFormatSplit[2]
				ArmorId = tonumber(ArmorId)
				local ArmorInfo = Globals.ArmorIds[ArmorId]

				if ArmorInfo then
					self.CachedArmor[Child] = {
						Name = ArmorInfo.Name,
						Skin = Skin,
					}

					Globals.ArmorNames[Child.Name] = {
						Name = ArmorInfo.Name,
						Skin = Skin,
					}
				end
			end
		end
	end

	Character.ChildAdded:Connect(function(Child)
		task.wait(0.3)
		if Child and table.find(EntityClass.ItemList, Child.Name) then
			self.CachedItem = Child
		end

		if Child and Child.Name:find("Armor") then
			for Index, MeshPart in Child:GetChildren() do
				self:ApplyArmorVisuals(MeshPart)
			end

			if Globals.ArmorNames[Child.Name] then
				local Info = Globals.ArmorNames[Child.Name]
				self.CachedArmor[Child] = {
					Name = Info.Name,
					Skin = Info.Skin,
				}
			else
				local ModelName = Child.Name

				local ArmorSplit = ModelName:split("/")

				if not ArmorSplit then
					return
				end
				local ArmorFormat = ArmorSplit[1]
				local Skin = ArmorSplit[2]

				local ArmorFormatSplit = ArmorFormat:split("_")
				local ArmorId = ArmorFormatSplit[2]
				ArmorId = tonumber(ArmorId)
				local ArmorInfo = Globals.ArmorIds[ArmorId]

				self.CachedArmor[Child] = {
					Name = ArmorInfo.Name,
					Skin = Skin,
				}

				Globals.ArmorNames[Child.Name] = {
					Name = ArmorInfo.Name,
					Skin = Skin,
				}
			end
		end
	end)

	Character.ChildRemoved:Connect(function(Child)
		if self.CachedItem == Child then
			self.CachedItem = nil
		end

		if self.CachedArmor[Child] then
			self.CachedArmor[Child] = nil
		end
	end)
end)

EntityClass.Main.Functions.CreateComponents = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	local Components = {}

	Components.BoxOutline = Globals:Instance("Frame", {
		Parent = Visuals.ESPSpace,
		Visible = false,
		BackgroundTransparency = 1,
		ZIndex = 2,
	})

	Components.BoxOutlineStroke = Globals:Instance("UIStroke", {
		Parent = Components.BoxOutline,
		Thickness = 3,
		Color = Color3.fromRGB(0, 0, 0),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Miter,
	})

	Components.BoxInline = Globals:Instance("Frame", {
		Parent = Components.BoxOutline,
		Visible = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -1, 0, -1),
		Size = UDim2.new(1, 2, 1, 2),
		ZIndex = 2,
	})

	Components.BoxInlineStroke = Globals:Instance("UIStroke", {
		Parent = Components.BoxInline,
		LineJoinMode = Enum.LineJoinMode.Miter,
		Color = Color3.fromRGB(255, 255, 255),
	})

	Components.FakeCornerBox = Globals:Instance("Frame", {
		Parent = Components.BoxOutline,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 4, 1, 2),
		Position = UDim2.new(0, -2, 0, -1),
	})

	local Corners = {}

	local CornerWidth = 0.3
	local CornerHeight = 0.3
	local Thickness = 1
	local Offset = -Thickness

	Corners[1] = Instance.new("Frame")
	Corners[1].Parent = Components.FakeCornerBox
	Corners[1].Size = UDim2.new(CornerWidth, 0, 0, Thickness)
	Corners[1].Position = UDim2.new(0, 0, 0, Offset)
	Corners[1].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[1].BorderSizePixel = 0
	Corners[1].Visible = false

	Corners[2] = Instance.new("Frame")
	Corners[2].Parent = Components.FakeCornerBox
	Corners[2].Size = UDim2.new(0, Thickness, CornerHeight, 0)
	Corners[2].Position = UDim2.new(0, 0, 0, Offset)
	Corners[2].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[2].BorderSizePixel = 0

	Corners[3] = Instance.new("Frame")
	Corners[3].Parent = Components.FakeCornerBox
	Corners[3].Size = UDim2.new(CornerWidth, 0, 0, Thickness)
	Corners[3].Position = UDim2.new(1 - CornerWidth, 0, 0, Offset)
	Corners[3].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[3].BorderSizePixel = 0

	Corners[4] = Instance.new("Frame")
	Corners[4].Parent = Components.FakeCornerBox
	Corners[4].Size = UDim2.new(0, Thickness, CornerHeight, 0)
	Corners[4].Position = UDim2.new(1, -Thickness, 0, Offset)
	Corners[4].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[4].BorderSizePixel = 0

	Corners[5] = Instance.new("Frame")
	Corners[5].Parent = Components.FakeCornerBox
	Corners[5].Size = UDim2.new(0, Thickness, CornerHeight, 0)
	Corners[5].Position = UDim2.new(0, 0, 1 - CornerHeight, 0)
	Corners[5].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[5].BorderSizePixel = 0

	Corners[6] = Instance.new("Frame")
	Corners[6].Parent = Components.FakeCornerBox
	Corners[6].Size = UDim2.new(CornerWidth, 0, 0, Thickness)
	Corners[6].Position = UDim2.new(0, 0, 1, 0)
	Corners[6].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[6].BorderSizePixel = 0

	Corners[7] = Instance.new("Frame")
	Corners[7].Parent = Components.FakeCornerBox
	Corners[7].Size = UDim2.new(0, Thickness, CornerHeight, 0)
	Corners[7].Position = UDim2.new(1, -Thickness, 1 - CornerHeight, 0)
	Corners[7].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[7].BorderSizePixel = 0

	Corners[8] = Instance.new("Frame")
	Corners[8].Parent = Components.FakeCornerBox
	Corners[8].Size = UDim2.new(CornerWidth, 0, 0, Thickness)
	Corners[8].Position = UDim2.new(1 - CornerWidth, 0, 1, 0)
	Corners[8].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Corners[8].BorderSizePixel = 0

	for i = 9, 16 do
		local base = Corners[i - 8]:Clone()
		base.Parent = Components.FakeCornerBox
		base.BorderSizePixel = 1
		base.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Corners[i] = base
	end

	Components.Corners = Corners

	Components["Healthbar"] = Globals:Instance("Frame", {
		Parent = Components.BoxOutline,
		Size = UDim2.new(0, 1, 1, 4),
		Position = UDim2.new(0, -6, 0, -2),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		Visible = false,
	})

	Components["HealthbarBlackout"] = Globals:Instance("Frame", {
		BackgroundColor3 = Color3.fromRGB(),
		Size = UDim2.new(0, 0, 0, 0),
		Parent = Components.Healthbar,
		BorderSizePixel = 0,
		Visible = false,
	})

	Components.Health = Globals:Instance("TextLabel", {
		BackgroundTransparency = 1,
		Parent = Components.HealthbarBlackout,
		Visible = false,
		FontFace = EntityClass.Font,
		TextSize = EntityClass.FontSize,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "",
		Size = UDim2.new(0, 20, 0, 12),
		Position = UDim2.new(-1, -23, 0, -2),
	})

	Components.HealthStroke = Globals.ApplyTextStroke(Components.Health)

	Components.Name = Globals:Instance("TextLabel", {
		Parent = Components.BoxOutline,
		FontFace = EntityClass.Font,
		TextSize = EntityClass.FontSize,
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 0, -17),
		TextStrokeTransparency = 1,
		Visible = false,
	})

	Components.NameStroke = Globals.ApplyTextStroke(Components.Name)

	Components.Distance = Globals:Instance("TextLabel", {
		Parent = Components.BoxOutline,
		ZIndex = 1,
		TextSize = EntityClass.FontSize,
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, 6),
		TextStrokeTransparency = 1,
		Visible = false,
		Text = "",
		BackgroundTransparency = 1,
		FontFace = EntityClass.Font,
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
	Components.DistanceStroke = Globals.ApplyTextStroke(Components.Distance)

	Components.Weapon = Globals:Instance("TextLabel", {
		Parent = Components.BoxOutline,
		ZIndex = 1,
		TextSize = EntityClass.FontSize,
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, 6),
		TextStrokeTransparency = 1,
		Visible = false,
		Text = "",
		BackgroundTransparency = 1,
		FontFace = EntityClass.Font,
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
	Components.WeaponStroke = Globals.ApplyTextStroke(Components.Weapon)

	Components.WeaponImage = Globals:Instance("ImageLabel", {
		Parent = Components.BoxOutline,
		ZIndex = 1,
		Image = GetImage("Salvaged AK47"),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.new(0, 25, 0, 25),
		ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
	})

	Components.FlagsContainer = Globals:Instance("Frame", {
		Parent = Components.BoxOutline,
		ClipsDescendants = true,
		Size = UDim2.new(0, 150, 1, 12),
		Position = UDim2.new(1, 2, 0, -6),
		BackgroundTransparency = 1,
	})

	Components.FlagsListLayout = Globals:Instance("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Components.FlagsContainer,
	})

	Components.FlagsPadding = Globals:Instance("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		Parent = Components.FlagsContainer,
		PaddingLeft = UDim.new(0, 2),
	})

	for FlagName, FlagData in EntityClass.Flags do
		Components["Flag_" .. FlagName] = Globals:Instance("TextLabel", EntityClass.FlagProperties)
		Components["Flag_" .. FlagName].Parent = Components.FlagsContainer
		Components["FlagStroke_" .. FlagName] = Globals.ApplyTextStroke(Components["Flag_" .. FlagName])
		Components["FlagStroke_" .. FlagName].Transparency = 1
	end

	Components.OffscreenArrow = Globals:Instance("TextLabel", {
		Text = "▲",
		TextSize = 14,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 20, 0, 20),
		Visible = false,
		Parent = Visuals.ESPSpace,
	})

	Components.ArrowStroke = Globals.ApplyTextStroke(Components.OffscreenArrow)

	Components.LOSIndicator = Globals:Instance("TextLabel", {
		Parent = Visuals.LOSFrame,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
		TextSize = 15,
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, -18),
		TextStrokeTransparency = 1,
		TextTransparency = 1,
		Visible = false,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	Components.LOSStroke = Globals.ApplyTextStroke(Components.LOSIndicator)
	Components.LOSStroke.Transparency = 1

	Components["LookAngle"] = Visuals.DrawLine()
	Components["LookAngleOutline"] = Visuals.DrawOutline()

	Components["Skeleton"] = {
		Main = Visuals.DrawLine(),

		RL_line = Visuals.DrawLine(),
		LL_line = Visuals.DrawLine(),

		RightFoot = Visuals.DrawLine(),
		LeftFoot = Visuals.DrawLine(),

		LeftArm = Visuals.DrawLine(),
		RightArm = Visuals.DrawLine(),

		RightElbow = Visuals.DrawLine(),
		LeftElbow = Visuals.DrawLine(),

		Hips = Visuals.DrawLine(),
		Shoulders = Visuals.DrawLine(),

		MainOutline = Visuals.DrawOutline(),

		RL_lineOutline = Visuals.DrawOutline(),
		LL_lineOutline = Visuals.DrawOutline(),

		RightFootOutline = Visuals.DrawOutline(),
		LeftFootOutline = Visuals.DrawOutline(),

		LeftArmOutline = Visuals.DrawOutline(),
		RightArmOutline = Visuals.DrawOutline(),

		RightElbowOutline = Visuals.DrawOutline(),
		LeftElbowOutline = Visuals.DrawOutline(),

		HipsOutline = Visuals.DrawOutline(),
		ShouldersOutline = Visuals.DrawOutline(),
	}

	return Components
end)

EntityClass.Main.Functions.GetBoxSize = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	local Character = self.Character
	local Root = self.Root
	local CameraPosition = Camera.CFrame.Position

	if not Character or not Root then
		return { Visible = false, OnScreen = false, Root = nil }
	end

	if (CameraPosition - Root.Position).Magnitude > 4000 then
		return { Visible = false, OnScreen = false, Root = Root }
	end

	local MaxWidth, MaxHeight, MaxDepth = 10, 20, 10
	local BoundingPosition, BoundingSize = self:GetBoundingBox(Character, Root.CFrame)
	local HalfSize = BoundingSize / 2

	local ClampedSize = Vector3.new(
		math.min(HalfSize.X, MaxWidth / 2) * 2,
		math.min(HalfSize.Y, MaxHeight / 2) * 2,
		math.min(HalfSize.Z, MaxDepth / 2) * 2
	)

	local CornerOffsets = {
		Vector3.new(ClampedSize.X / 2, ClampedSize.Y / 2, ClampedSize.Z / 2),
		Vector3.new(ClampedSize.X / 2, ClampedSize.Y / 2, -ClampedSize.Z / 2),
		Vector3.new(ClampedSize.X / 2, -ClampedSize.Y / 2, ClampedSize.Z / 2),
		Vector3.new(ClampedSize.X / 2, -ClampedSize.Y / 2, -ClampedSize.Z / 2),
		Vector3.new(-ClampedSize.X / 2, ClampedSize.Y / 2, ClampedSize.Z / 2),
		Vector3.new(-ClampedSize.X / 2, ClampedSize.Y / 2, -ClampedSize.Z / 2),
		Vector3.new(-ClampedSize.X / 2, -ClampedSize.Y / 2, ClampedSize.Z / 2),
		Vector3.new(-ClampedSize.X / 2, -ClampedSize.Y / 2, -ClampedSize.Z / 2),
	}

	local MinX, MinY = math.huge, math.huge
	local MaxX, MaxY = -math.huge, -math.huge
	local OnScreenCount = 0

	local WorldToViewportPoint = Camera.WorldToViewportPoint

	for _, Offset in ipairs(CornerOffsets) do
		local WorldCorner = BoundingPosition:PointToWorldSpace(Offset)
		local ScreenPos, OnScreen = WorldToViewportPoint(Camera, WorldCorner)
		if OnScreen then
			OnScreenCount += 1
			MinX = math.min(MinX, ScreenPos.X)
			MinY = math.min(MinY, ScreenPos.Y)
			MaxX = math.max(MaxX, ScreenPos.X)
			MaxY = math.max(MaxY, ScreenPos.Y)
		end
	end

	if OnScreenCount == 0 and Character:FindFirstChild("Head") then
		local Visible = Visuals.IsPartVisible(Character.Head)
		return {
			Root = Root,
			OnScreen = false,
			RootPosition = Root.Position,
			Visible = Visible,
			VisiblePart = Visible and Character.Head or nil,
		}
	end

	local VisiblePart = nil
	local PartsToCheck = {
		Character:FindFirstChild("HumanoidRootPart"),
		Character:FindFirstChild("RightLowerLeg"),
		Character:FindFirstChild("LeftLowerLeg"),
		Character:FindFirstChild("RightUpperArm"),
		Character:FindFirstChild("LeftUpperArm"),
	}

	for _, Part in ipairs(PartsToCheck) do
		if Part and Part:IsA("BasePart") and Visuals.IsPartVisible(Part) then
			VisiblePart = Part
			break
		end
	end

	local Width = MaxX - MinX
	local Height = MaxY - MinY
	local Size = Math.FloorVector(Vector2.new(Width, Height))
	local Position = Math.FloorVector(Vector2.new(MinX, MinY))
	local Center2D = Vector2.new(Position.X + Size.X / 2, Position.Y + Size.Y / 2)

	return {
		Visible = VisiblePart ~= nil,
		VisiblePart = VisiblePart,
		Root = Root,
		RootPosition = Root.Position,
		Height = Height,
		Width = Width,
		Size = Size,
		Position = Position,
		Center2D = Center2D,
		OnScreen = OnScreenCount > 0,
	}
end)

EntityClass.Main.Functions.GetBoundingBox = phNV(function(self, Model, Orientation) LPH_ATTRIBUTES(VM(NONE)) 
	local Parts = typeof(Model) == "Instance" and Model:GetChildren() or Model
	Orientation = Orientation or CFrame.new()

	local Inf = math.huge
	local MinX, MinY, MinZ = Inf, Inf, Inf
	local MaxX, MaxY, MaxZ = -Inf, -Inf, -Inf

	for _, Part in ipairs(Parts) do
		if Part:IsA("BasePart") then
			local Cf = Orientation:ToObjectSpace(Part.CFrame)
			local Sx, Sy, Sz = Part.Size.X, Part.Size.Y, Part.Size.Z
			local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Cf:components()

			local Wsx = 0.5 * (math.abs(R00) * Sx + math.abs(R01) * Sy + math.abs(R02) * Sz)
			local Wsy = 0.5 * (math.abs(R10) * Sx + math.abs(R11) * Sy + math.abs(R12) * Sz)
			local Wsz = 0.5 * (math.abs(R20) * Sx + math.abs(R21) * Sy + math.abs(R22) * Sz)

			MinX = math.min(MinX, X - Wsx)
			MinY = math.min(MinY, Y - Wsy)
			MinZ = math.min(MinZ, Z - Wsz)

			MaxX = math.max(MaxX, X + Wsx)
			MaxY = math.max(MaxY, Y + Wsy)
			MaxZ = math.max(MaxZ, Z + Wsz)
		end
	end

	local MinVec = Vector3.new(MinX, MinY, MinZ)
	local MaxVec = Vector3.new(MaxX, MaxY, MaxZ)
	local Middle = (MaxVec + MinVec) / 2
	local Cf = Orientation - Orientation.Position + Orientation:PointToWorldSpace(Middle)
	local Size = MaxVec - MinVec

	return Cf, Size
end)

EntityClass.Main.Functions.GetDistance = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	local root = self.Root
	if not root then
		return 9e9
	end
	return math.floor((root.Position - Camera.CFrame.Position).Magnitude)
end)

EntityClass.Main.Functions.GetHealth = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	if (self.Class == "Player" or self.Class == "AI") and self.Character then
		if self.Character.Name == "BTR" then
			return self.Character:GetAttribute("Health"), self.Character:GetAttribute("MaxHealth")
		end

		local Humanoid = self.Humanoid
		if not Humanoid then
			return 0, 100
		end
		return Humanoid.Health, Humanoid.MaxHealth
	end

	return 0, 100
end)

EntityClass.Main.Functions.GetRoot = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	local character = self.Character
	if not character then
		return
	end

	local Humanoid = character:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		self.Humanoid = Humanoid
	end

	if self.Class == "Player" or self.Class == "AI" then
		return Humanoid and Humanoid.RootPart or character:FindFirstChild("HumanoidRootPart")
	end
end)

EntityClass.Main.Functions.GetCharacter = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	if self.Class == "AI" then
		return self.Pointer
	end

	if self.Class == "Player" then
		return self.Pointer.Character
	end
end)

EntityClass.Main.Functions.ProjectSkeletonLine = phNV(function(self, part, offset) LPH_ATTRIBUTES(VM(NONE)) 
	local pos = part.Position + (offset or Vector3.zero)
	local screenPos = Camera:WorldToViewportPoint(pos)
	return Math.FloorVector(Vector2.new(screenPos.X, screenPos.Y))
end)

EntityClass.Main.Functions.SetSkeletonLine = phNV(function(self, name, from, to, transparency, color) LPH_ATTRIBUTES(VM(NONE)) 
	local line = self.Components.Skeleton[name]
	if line then
		line.Visible = true
		line.From = from
		line.To = to
		line.Color = color
		line.Transparency = 1 - transparency
	end

	local outline = self.Components.Skeleton[name .. "Outline"]
	if outline then
		outline.Visible = true
		outline.From = from
		outline.To = to
		outline.Transparency = 1 - transparency
	end
end)

EntityClass.Main.Functions.SetSkeletonsInvisible = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	if self.Components.Skeleton.RL_line.Visible then
		for _, Line in self.Components.Skeleton do
			Line.Visible = false
		end
	end
end)

EntityClass.Main.Functions.Update = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	self.Character = self:GetCharacter()
	self.Root = self:GetRoot()
	self.Distance = self:GetDistance()
	self.CoreInformation = self:GetBoxSize() or {}

	local Components = self.Components

	if not self.Root then
		Components.LOSIndicator.Visible = false
		Components.OffscreenArrow.Visible = false
		Components.BoxOutline.Visible = false
		Components.LookAngle.Visible = false
		Components.LookAngleOutline.Visible = false
		self:SetSkeletonsInvisible()
		return
	end

	do
		local MaxDistFlag = Library.Flags[self.ClassType .. "MaxDistance"]
		if MaxDistFlag and self.Distance and self.Distance > MaxDistFlag.Value then
			Components.LOSIndicator.Visible = false
			Components.OffscreenArrow.Visible = false
			Components.BoxOutline.Visible = false
			Components.LookAngle.Visible = false
			Components.LookAngleOutline.Visible = false
			self:SetSkeletonsInvisible()
			return
		end
	end

	local Health, MaxHealth = self:GetHealth()
	local CoreInformation = self.CoreInformation
	local Visible = CoreInformation.Visible
	local ClassType = self.ClassType
	local Flags = Library.Flags
	local StatusColor = not Visible and Flags[ClassType .. "OccludedColor"].Value[1]
		or Flags[ClassType .. "VisibleColor"].Value[1]

	if self == EntityClass.TargetData then
		StatusColor = Flags.TargetColor.Value[1]
		if EntityClass.ManipulatedPlayer == self.Pointer and Flags.ManipColor then
			StatusColor = Flags.ManipColor.Value[1]
		end
	end

	if ClassType == "Player" and isTeam(self.Pointer) then
		self.Friendly = true
		StatusColor = TEAMMATE_COLOR
	else
		self.Friendly = false
	end

	self.IsDead = Health <= 0.1
	local Transparency = self.IsDead and 1 or 0

	Globals:Tween(Components.BoxInlineStroke, TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad), {
		Color = StatusColor,
	})

	Globals:Tween(
		Components.BoxOutlineStroke,
		TweenInfo.new(EntityClass.AnimationSpeed + 0.25, Enum.EasingStyle.Quad),
		{
			Transparency = Transparency,
		}
	)

	local ComponentColor = Components.BoxInlineStroke.Color
	Transparency = Components.BoxOutlineStroke.Transparency
	local BoxCorners = Components.Corners
	local BottomBounds = 1
	local HasItem = self.CachedItem ~= nil

	if Flags.LockOnIndicator.Value and ClassType == "Player" and Flags.PlayerESP.Value then
		local ClientHead = Client.Character and Client.Character:FindFirstChild("Head")
		local EnemyHead = self.Character and self.Character:FindFirstChild("Head")

		if EnemyHead and ClientHead then
			local Delta = (ClientHead.Position - EnemyHead.Position)
			local Distance = Delta.Magnitude
			local Direction = Delta.Unit
			local LookVector = EnemyHead.CFrame.LookVector
			local DotProduct = LookVector:Dot(Direction)
			local CrossProduct = LookVector:Cross(Direction).Magnitude
			local Angle = math.deg(math.atan2(CrossProduct, DotProduct))
			local MaxAngle = math.clamp(60 - (Distance / 10), 15, 60)
			local Percentage = math.floor(math.clamp(100 - (Angle / MaxAngle * 100), 0, 100))
			local IsLooking = Angle <= MaxAngle
			local ThroughWalls = not Visible
			local Color = Percentage >= Flags.LockOnRisk.Value and Color3.fromRGB(255, 0, 0)
				or Color3.fromRGB(255, 255, 255)

			if IsLooking and Percentage >= Flags.LockOnThreshold.Value then
				Components.LOSIndicator.LayoutOrder = tick()
				Components.LOSIndicator.Visible = true
				Components.LOSIndicator.Text = string.format(
					"%s %s (%d%%) [%d studs]\n",
					self.Name,
					ThroughWalls and "is looking at you through walls" or "is looking at you",
					Percentage,
					math.floor(Distance)
				)

				if not Components.LOSIndicator:GetAttribute("IsTweening") then
					Components.LOSIndicator:SetAttribute("IsTweening", true)
					local Tween = Globals:Tween(
						Components.LOSIndicator,
						TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad),
						{
							TextColor3 = Color,
							Size = UDim2.new(1, 0, 0, Components.LOSIndicator.TextSize),
							TextTransparency = 0,
						}
					)
					Components.LOSStroke.Transparency = Components.LOSIndicator.TextTransparency
					Tween.Completed:Connect(function()
						Components.LOSIndicator:SetAttribute("IsTweening", false)
					end)
				end
				Components.LOSStroke.Transparency = Components.LOSIndicator.TextTransparency
			else
				if not Components.LOSIndicator:GetAttribute("IsTweening") then
					Components.LOSIndicator:SetAttribute("IsTweening", true)
					local Tween = Globals:Tween(
						Components.LOSIndicator,
						TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad),
						{
							Size = UDim2.new(1, 0, 0, 0),
							TextTransparency = 1,
						}
					)
					Tween.Completed:Connect(function()
						task.wait(0.1)
						Components.LOSIndicator:SetAttribute("IsTweening", false)
						Components.LOSIndicator.Visible = false
					end)
				end
				Components.LOSStroke.Transparency = Components.LOSIndicator.TextTransparency
			end
		end
	else
		Components.LOSIndicator.Visible = false
	end

	if CoreInformation.OnScreen and Flags[ClassType .. "ESP"].Value and (not self.Friendly or Flags.ShowTeammates.Value) then
		Components.OffscreenArrow.Visible = false
		local CanShowWeapon = ClassType == "Player" and Flags[ClassType .. "Weapon"]
		local CanShowWeaponImage = ClassType == "Player" and Flags[ClassType .. "WeaponImage"]
		local TweenProperties = TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad)

		if tick() - self.LastChamsRefresh > Flags.ChamsRefreshRate.Value then
			self.LastChamsRefresh = tick()
			for _, Part in self.Character:GetChildren() do
				if Part:IsA("Model") and Part.Name:find("Armor") then
					for Index, MeshPart in Part:GetChildren() do
						self:ApplyArmorVisuals(MeshPart)
					end
				end

				if Part:IsA("BasePart") and not EntityClass.IgnoreNames[Part.Name] then
					if not self.Adornments[Part] then
						local Adornments = {}
						local Adornment
						for Vis = 1, 2 do
							if Part.Name == "Head" then
								Adornment = Globals:Instance("CylinderHandleAdornment", {
									Name = "",
									Adornee = Part,
									Parent = Part,
									ZIndex = Vis == 1 and 2 or 1,
									Height = Vis == 1 and 0.87 or 1.02,
									Radius = Vis == 1 and 0.5 or 0.65,
									CFrame = CFrame.new(Vector3.new(), Vector3.new(0, 1, 0)),
									Visible = false,
									AlwaysOnTop = Vis == 1,
								})
							else
								local SizeOffset = Vis == 1 and -0.05 or 0.05
								Adornment = Globals:Instance("BoxHandleAdornment", {
									Name = "",
									Adornee = Part,
									Parent = Part,
									ZIndex = Vis == 1 and 2 or 1,
									AlwaysOnTop = Vis == 1,
									Size = Part.Size + Vector3.new(SizeOffset, SizeOffset, SizeOffset),
									Visible = false,
								})
							end
							Adornments[Vis] = Adornment
						end
						self.Adornments[Part] = Adornments
					else
						local Adornments = self.Adornments[Part]
						if Adornments then
							local OccludedColor = self.Friendly and TEAMMATE_COLOR_DIM or Flags[ClassType .. "ChamsOccludedColor"].Value[1]
							local OccludedTransparency = Flags[ClassType .. "ChamsOccludedColor"].Value[2]
							local ShouldShow = Flags[ClassType .. "Chams"].Value
							local GlowChams = Flags[ClassType .. "ChamsStyle"].Value == "Glow"
							local VisibleColor = self.Friendly and TEAMMATE_COLOR or Flags[ClassType .. "ChamsVisibleColor"].Value[1]
							local VisibleTransparency = Flags[ClassType .. "ChamsVisibleColor"].Value[2]

							Adornments[1].Visible = ShouldShow
							Adornments[1].Color3 = OccludedColor
							Adornments[1].Transparency = OccludedTransparency

							Adornments[2].Visible = ShouldShow
							Adornments[2].ZIndex = GlowChams and 9e9 or 1
							Adornments[2].AlwaysOnTop = GlowChams
							Adornments[2].Color3 = VisibleColor
							Adornments[2].Transparency = VisibleTransparency
						end
					end
				end
			end
		end

		Components.BoxOutline.Position = UDim2.new(0, CoreInformation.Position.X, 0, CoreInformation.Position.Y)
		Components.BoxOutline.Size = UDim2.new(0, CoreInformation.Size.X, 0, CoreInformation.Size.Y)
		Components.BoxOutline.Visible = true

		local CanUseSolid = Flags[ClassType .. "BoundingBox"].Value and Flags[ClassType .. "BoxStyle"].Value == "Solid"
		Components.BoxOutlineStroke.Enabled = CanUseSolid
		Components.BoxInlineStroke.Enabled = CanUseSolid

		ComponentColor = Components.BoxInlineStroke.Color

		Components.BoxInlineStroke.Transparency = Transparency

		for Index = 1, 16 do
			BoxCorners[Index].Visible = Flags[ClassType .. "BoundingBox"].Value
				and Flags[ClassType .. "BoxStyle"].Value == "Corner"

			if BoxCorners[Index].Visible then
				if Index <= 8 then
					BoxCorners[Index].ZIndex = 3
					BoxCorners[Index].BackgroundColor3 = ComponentColor
				end
				BoxCorners[Index].BackgroundTransparency = Transparency
			end
		end

		if Flags[ClassType .. "Healthbar"].Value then
			local HealthPercent = Health / MaxHealth
			if tostring(HealthPercent) == "nan" then
				HealthPercent = 0
			end

			local CalculatedSize = UDim2.new(1, 0, 1 - HealthPercent, 0)

			Components.HealthbarBlackout.Visible = true
			Components.Healthbar.Visible = true
			Components.Healthbar.BackgroundTransparency = Transparency
			Components.HealthbarBlackout.BackgroundTransparency = Transparency

			local ShowIfDamaged = Flags[ClassType .. "ShowHealthIfDamaged"].Value
			local CanShowHealth = not ShowIfDamaged or (ShowIfDamaged and Health < MaxHealth)

			if Flags[ClassType .. "Health"].Value and CanShowHealth then
				Components.Health.Visible = true
				Components.Health.Text = tostring(math.floor(HealthPercent * 100))
				Components.Health.TextTransparency = Transparency
				Components.HealthStroke.Transparency = (Flags.ESPTextOutline == nil or Flags.ESPTextOutline.Value) and Transparency or 1
			else
				Components.Health.Visible = false
			end

			if Health ~= self.LastHealth then
				self.LastHealth = Health
				Globals:Tween(
					Components.HealthbarBlackout,
					TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad),
					{
						Size = CalculatedSize,
					}
				)

				local LerpedColor = Flags[ClassType .. "LowerHealthColor"].Value[1]:lerp(
					Flags[ClassType .. "HigherHealthColor"].Value[1],
					Health / MaxHealth
				)

				Globals:Tween(Components.Healthbar, TweenInfo.new(EntityClass.AnimationSpeed, Enum.EasingStyle.Quad), {
					BackgroundColor3 = LerpedColor,
				})
			end
		else
			Components.Healthbar.Visible = false
		end

		if Flags[ClassType .. "Name"].Value then
			Components.Name.Visible = true
			Components.NameStroke.Transparency = (Flags.ESPTextOutline == nil or Flags.ESPTextOutline.Value) and Transparency or 1
			Components.Name.TextTransparency = Transparency
			Components.Name.Text = self.Name
			Components.Name.TextColor3 = ComponentColor
		else
			Components.Name.Visible = false
		end

		if Flags[ClassType .. "Distance"].Value then
			Components.Distance.Visible = true
			Components.DistanceStroke.Transparency = (Flags.ESPTextOutline == nil or Flags.ESPTextOutline.Value) and Transparency or 1
			Components.Distance.Text = tostring(self.Distance) .. "s"
			Components.Distance.TextColor3 = ComponentColor
			Components.Distance.TextTransparency = Transparency
			Components.Distance.Position = UDim2.new(0, 0, 1, BottomBounds)
			BottomBounds += 8
		else
			Components.Distance.Visible = false
		end

		if CanShowWeapon and CanShowWeapon.Value then
			Components.Weapon.Visible = true

			if HasItem and self.CachedItem then
				Components.Weapon.Text = self.CachedItem.Name
			end

			Components.Weapon.TextColor3 = ComponentColor

			if not Components.Weapon:GetAttribute("IsTweening") then
				Components.Weapon:SetAttribute("IsTweening", true)

				local TargetY = HasItem and BottomBounds or (BottomBounds - 4)
				local WeaponTween = Globals:Tween(Components.Weapon, TweenProperties, {
					TextTransparency = HasItem and Transparency or 1,
					Position = UDim2.new(0, 0, 1, TargetY),
				})

				Globals:Tween(Components.WeaponStroke, TweenProperties, {
					Transparency = HasItem and Transparency or 1,
				})

				WeaponTween.Completed:Connect(function()
					Components.Weapon:SetAttribute("IsTweening", false)
				end)
			end

			BottomBounds += 6
		else
			Components.Weapon.Visible = false
		end

		if CanShowWeaponImage and CanShowWeaponImage.Value then
			if not Components.Weapon.Visible then
				BottomBounds -= 4
			end

			local WeaponImage = (HasItem and self.CachedItem and EntityClass.WeaponImages[self.CachedItem.Name]) or nil
			local HasImage = HasItem and WeaponImage ~= nil

			Components.WeaponImage.Visible = HasImage
			if HasImage then
				Components.WeaponImage.Image = WeaponImage
			end

			if not Components.WeaponImage:GetAttribute("IsTweening") then
				Components.WeaponImage:SetAttribute("IsTweening", true)

				local TargetY = HasImage and BottomBounds or (BottomBounds - 5)
				local ImageTween = Globals:Tween(Components.WeaponImage, TweenProperties, {
					ImageTransparency = HasImage and Transparency or 1,
					Position = UDim2.new(0.5, 0, 1, TargetY),
				})

				ImageTween.Completed:Connect(function()
					Components.WeaponImage:SetAttribute("IsTweening", false)
				end)
			end
		else
			Components.WeaponImage.Visible = false
		end

		if ClassType == "Player" and Flags[ClassType .. "Flags"].Value then
			Components.FlagsContainer.Visible = true
			local AnimationSpeed = EntityClass.AnimationSpeed
			local EasingStyle = Enum.EasingStyle.Quad
			local TweenInfo = TweenInfo.new(AnimationSpeed, EasingStyle)

			for FlagName, FlagData in EntityClass.Flags do
				local ShouldShow = FlagData.Allow(self)
				local Flag = Components["Flag_" .. FlagName]
				local FlagStroke = Components["FlagStroke_" .. FlagName]

				if not Flag then
					Flag = Globals:Instance("TextLabel", EntityClass.FlagProperties)
					Flag.Parent = Components.FlagsContainer
					FlagStroke = Globals.ApplyTextStroke(Flag)
					FlagStroke.Transparency = 1
					Components["Flag_" .. FlagName] = Flag
					Components["FlagStroke_" .. FlagName] = FlagStroke
				end

				if Flag then
					local Text = FlagData.Text(self) or ""
					Flag.TextColor3 = FlagData.Color and FlagData.Color(self) or Flags[FlagName .. "FlagColor"].Value[1]
					Flag.Text = " " .. Text

					if not Flag:GetAttribute("IsTweening") then
						Flag:SetAttribute("IsTweening", true)
						if ShouldShow then
							Flag.Visible = true
							Flag.LayoutOrder = tick()
						end

						local FlagTween = Globals:Tween(Flag, TweenInfo, {
							TextTransparency = ShouldShow and Transparency or 1,
							Size = ShouldShow and UDim2.new(0, 200, 0, Flag.TextBounds.Y) or UDim2.new(0, 200, 0, 0),
						})

						Globals:Tween(FlagStroke, TweenInfo, {
							Transparency = ShouldShow and Transparency or 1,
						})

						FlagTween.Completed:Connect(function()
							Flag:SetAttribute("IsTweening", false)
							Flag.Visible = ShouldShow
						end)
					end
				end
			end
		else
			Components.FlagsContainer.Visible = false
		end

		if Flags[ClassType .. "LookAngle"].Value and self.Character:FindFirstChild("Head") and not Library.IsOpen then
			local Head = self.Character.Head
			local HeadPos, HeadOnScreen = Camera:WorldToViewportPoint(Head.Position)
			local LookPos, LookOnScreen = Camera:WorldToViewportPoint(Head.Position + Head.CFrame.LookVector * 5)

			local Line = Components.LookAngle
			local Outline = Components.LookAngleOutline

			if HeadOnScreen and LookOnScreen then
				local From = Vector2.new(HeadPos.X, HeadPos.Y)
				local To = Vector2.new(LookPos.X, LookPos.Y)

				From = Math.FloorVector(From)
				To = Math.FloorVector(To)

				Line.Visible = true
				Line.From = From
				Line.To = To
				Line.Color = ComponentColor
				Line.Transparency = 1 - Transparency

				Outline.Visible = true
				Outline.From = From
				Outline.To = To
				Outline.Transparency = 1 - Transparency
			else
				Line.Visible = false
				Outline.Visible = false
			end
		else
			Components.LookAngle.Visible = false
			Components.LookAngleOutline.Visible = false
		end

		if Flags[ClassType .. "Skeleton"].Value and self.Character:FindFirstChild("Head") and not Library.IsOpen then
			local Valid = true
			for _, Part in
				{
					"UpperTorso",
					"RightUpperLeg",
					"LeftFoot",
					"RightFoot",
					"LeftUpperLeg",
					"LeftUpperArm",
					"RightUpperArm",
					"RightLowerArm",
					"RightHand",
					"LeftHand",
				}
			do
				if not self.Character:FindFirstChild(Part) then
					Valid = false
					break
				end
			end

			if Valid then
				local Head = self:ProjectSkeletonLine(self.Character.Head)
				local RL = self:ProjectSkeletonLine(self.Character.RightUpperLeg)
				local LL = self:ProjectSkeletonLine(self.Character.LeftUpperLeg)

				local RightLeg = self:ProjectSkeletonLine(self.Character.RightUpperLeg, Vector3.new(0, 0.5, 0))
				local LeftLeg = self:ProjectSkeletonLine(self.Character.LeftUpperLeg, Vector3.new(0, 0.5, 0))

				local RightFoot = self:ProjectSkeletonLine(self.Character.RightFoot)
				local LeftFoot = self:ProjectSkeletonLine(self.Character.LeftFoot)

				local RightArm = self:ProjectSkeletonLine(self.Character.RightUpperArm, Vector3.new(0, 0.2, 0))
				local LeftArm = self:ProjectSkeletonLine(self.Character.LeftUpperArm, Vector3.new(0, 0.2, 0))

				local RightElbow = self:ProjectSkeletonLine(self.Character.RightLowerArm, Vector3.new(0, 0.2, 0))
				local LeftElbow = self:ProjectSkeletonLine(self.Character.LeftLowerArm, Vector3.new(0, 0.2, 0))

				local RightHand = self:ProjectSkeletonLine(self.Character.RightHand)
				local LeftHand = self:ProjectSkeletonLine(self.Character.LeftHand)

				self:SetSkeletonLine("RightFoot", RightFoot, RL, Transparency, ComponentColor)
				self:SetSkeletonLine("LeftFoot", LeftFoot, LL, Transparency, ComponentColor)

				self:SetSkeletonLine("LL_line", LeftLeg, LL, Transparency, ComponentColor)
				self:SetSkeletonLine("RL_line", RightLeg, RL, Transparency, ComponentColor)

				self:SetSkeletonLine("RightArm", RightArm, RightElbow, Transparency, ComponentColor)
				self:SetSkeletonLine("RightElbow", RightElbow, RightHand, Transparency, ComponentColor)

				self:SetSkeletonLine("LeftArm", LeftArm, LeftElbow, Transparency, ComponentColor)
				self:SetSkeletonLine("LeftElbow", LeftElbow, LeftHand, Transparency, ComponentColor)

				self:SetSkeletonLine(
					"Main",
					Vector2.new((LeftLeg.X + RightLeg.X) / 2, LeftLeg.Y),
					Head,
					Transparency,
					ComponentColor
				)
				self:SetSkeletonLine("Hips", LeftLeg, RightLeg, Transparency, ComponentColor)
				self:SetSkeletonLine("Shoulders", RightArm, LeftArm, Transparency, ComponentColor)
			else
				self:SetSkeletonsInvisible()
			end
		else
			self:SetSkeletonsInvisible()
		end
	else
		Components.BoxOutline.Visible = false
		Components.LookAngle.Visible = false
		Components.LookAngleOutline.Visible = false
		self:SetSkeletonsInvisible()

		if CoreInformation.Root and Flags[ClassType .. "Offscreen"] and Flags[ClassType .. "Offscreen"].Value then
			local ArrowRadius = Flags[ClassType .. "OffscreenRadius"].Value
			local Size = Flags[ClassType .. "OffscreenSize"].Value

			local Arrow = Components.OffscreenArrow
			local CameraPosition = Camera.CFrame.p
			local ViewAngle = Camera.CFrame.lookVector

			local ScreenPos = Camera:WorldToScreenPoint(CoreInformation.Root.Position)
			local Center = Camera.ViewportSize / 2
			local Direction = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Center.X, Center.Y)).Unit

			local OffscreenRadius = ArrowRadius
			local ClampedPosition = Vector2.new(Center.X, Center.Y) + Direction * OffscreenRadius

			Arrow.TextSize = Size
			Arrow.Size = UDim2.new(0, 25, 0, 25)
			Arrow.Position = UDim2.new(
				0,
				ClampedPosition.X - Arrow.Size.X.Offset / 2,
				0,
				ClampedPosition.Y - Arrow.Size.Y.Offset / 2
			)
			Arrow.Rotation = math.deg(math.atan2(Direction.Y, Direction.X)) + 90
			Arrow.Visible = true
			Arrow.TextColor3 = ComponentColor
			Arrow.TextTransparency = Transparency
			Components.ArrowStroke.Transparency = Transparency
		else
			Components.OffscreenArrow.Visible = false
		end
	end
end)

EntityClass.Main.Functions.AddFlag = phNV(function(self, Data) LPH_ATTRIBUTES(VM(NONE)) 
	EntityClass.Flags[Data.Name] = Data
	return EntityClass.Flags[Data.Name]
end)

Log("Loaded EntityClass main library.")

EntityClass.Misc.Functions.__index = EntityClass.Misc.Functions

EntityClass.Misc.Functions.CreateComponents = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	local Components = {}

	Components.Name = Globals:Instance("TextLabel", {
		Parent = Visuals.MiscSpace,
		ZIndex = 1,
		BackgroundTransparency = 1,
		TextSize = EntityClass.FontSize,
		Text = "",
		FontFace = EntityClass.Font,
		Size = UDim2.new(0, 0, 0, EntityClass.FontSize),
		Visible = false,
		Position = UDim2.new(0, 0, 0, 0),
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	Components.NameStroke = Globals.ApplyTextStroke(Components.Name)

	return Components
end)

EntityClass.Misc.Functions.ScanParent = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
	local ParentFolder = self.Parent
	local ClassName = self.ClassName
	local Name = self.Name
	for Index, Object in ParentFolder:GetChildren() do
		if Object.ClassName == ClassName or Name == Object.Name then
			self.Object = Object
			EntityClass.Misc.Cache[Object] = {
				Components = self:CreateComponents(),
				Listener = self,
				Object = Object,
			}
		end
	end

	ParentFolder.ChildAdded:Connect(function(Object)
		task.wait(0.5)
		if ParentFolder == Workspace:FindFirstChild("Drops") then
			task.wait(2)
		end

		if
			(Object.ClassName == ClassName or Name == Object.Name)
			and not Object:GetAttribute("IsThrow")
			and not EntityClass.Misc.Cache[Object]
		then
			EntityClass.Misc.Cache[Object] = {
				Components = self:CreateComponents(),
				Listener = self,
				Object = Object,
			}
			Object:GetPropertyChangedSignal("Parent"):Connect(function()
				if Object.Parent ~= ParentFolder and EntityClass.Misc.Cache[Object] then
					for _, Component in EntityClass.Misc.Cache[Object].Components do
						Component:Destroy()
					end
					EntityClass.Misc.Cache[Object] = nil
				end
			end)
			Object:GetAttributeChangedSignal("IsThrow"):Connect(function()
				task.wait(0.1)
				if Object:GetAttribute("IsThrow") then
					for _, Component in EntityClass.Misc.Cache[Object].Components do
						Component:Destroy()
					end
					EntityClass.Misc.Cache[Object] = nil
				end
			end)
		end
	end)

	ParentFolder.ChildRemoved:Connect(function(Object)
		if EntityClass.Misc.Cache[Object] then
			for _, Component in EntityClass.Misc.Cache[Object].Components do
				Component:Destroy()
			end
			EntityClass.Misc.Cache[Object] = nil
		end
	end)
end)

EntityClass.Misc.Functions.AddListener = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 

end)

Log("Loaded EntityClass Misc library.")

local Window = Library:Window({
	Name = "MainWindow",

})

phJITX(function() LPH_ATTRIBUTES(VM(NONE)) 
	local Pages = {
		Combat = Window:Tab({
			Name = "Combat",
			Image = "rbxassetid://7485051715",
		}),

		ESP = Window:Tab({
			Name = "ESP",
			Image = "rbxassetid://13321848320",
		}),

		Seperator1 = Window:TabSeperator(),

		Visuals = Window:Tab({
			Name = "Visuals",
			Image = "rbxassetid://18870359747",
		}),

		Misc = Window:Tab({
			Name = "Misc",
			Image = "rbxassetid://6953992690",
		}),

		Skins = Window:Tab({
			Name = "Skins",
			Image = "rbxassetid://13693164564",
		}),

		Seperator2 = Window:TabSeperator(),

		Settings = Window:Tab({
			Name = "Settings",
			Image = "rbxassetid://11956055886",
		}),
		Plugins = Window:Tab({
			Name = "Plugins",
			Image = "http://www.roblox.com/asset/?id=133292957761995",
		}),
	}

	local CombatCategories = {
		SilentAim = Pages.Combat:Category({
			Name = "Main",
		}),




		Crosshair = Pages.Combat:Category({
			Name = "Crosshair",
		}),
	}

	do

		local SilentAim = CombatCategories.SilentAim:Section({
			Name = "Silent Aim",
			Side = "Left",
		})

		SilentAim:Toggle({
			Name = "Enabled",
			Flag = "SilentAim",
			Tooltip = "Silent aim: redirects shots without moving the camera",
		})

		SilentAim:Toggle({
			Name = "Always target",
			Flag = "AlwaysTarget",
			Default = true,
			Tooltip = "Silent aim active without a key",
		})

		SilentAim:Toggle({
			Name = "Random hitpart",
			Flag = "RandomizeHitPart",
		})

		SilentAim:Toggle({
			Name = "Visibility check",
			Flag = "VisibleCheck",
			Tooltip = "Prioritizes hitboxes based on visibility",
		})

		SilentAim:Toggle({
			Name = "Manipulation",
			Flag = "Manipulation",
			Tooltip = "Uses a visible position around obstructions",
		})

		SilentAim:Toggle({
			Name = "Spin Resolver",
			Flag = "SpinResolver",
			Default = false,
			Tooltip = "Resolves spinning anti-aim by aiming at the root center",
		})

		SilentAim:Toggle({
			Name = "Velocity Resolver",
			Flag = "VelocityResolver",
			Default = false,
			Tooltip = "Corrects fake or spoofed velocity for prediction",
		})

		SilentAim:Toggle({
			Name = "Desync Resolver",
			Flag = "DesyncResolver",
			Default = false,
			Tooltip = "Holds the real position when a target desyncs",
		})

		SilentAim:Toggle({
			Name = "Pitch Resolver",
			Flag = "PitchResolver",
			Default = false,
			Tooltip = "Detects fake pitch",
		})

		SilentAim:Toggle({
			Name = "Underground Resolver",
			Flag = "UndergroundResolver",
			Default = false,
			Tooltip = "Detects players hiding underground",
		})

		SilentAim:Toggle({
			Name = "Target Teammates",
			Flag = "TargetTeammates",
			Default = false,
			Tooltip = "Allow Silent Aim and killaura to target clan teammates",
		})

		SilentAim:Toggle({
			Name = "Packet Silent",
			Flag = "PacketSilent",
			Default = true,
			Tooltip = "Rewrites outgoing shot packets toward the target",
		})

		SilentAim:Seperator()

		SilentAim:Keybind({
			Name = "Manipulation key",
			Flag = "Manipulation Activation",
			Mode = "Toggle",
		})

		SilentAim:Keybind({
			Name = "Silent aim key",
			Flag = "SilentAim Activation",
			Mode = "Hold",
		})

		SilentAim:Seperator()

		SilentAim:Toggle({
			Name = "Target Players",
			Flag = "TargetPlayer",
			Default = true,
		})

		SilentAim:Toggle({
			Name = "Target AI",
			Flag = "TargetAI",
			Default = true,
		})

		SilentAim:Toggle({
			Name = "Target Bosses",
			Flag = "TargetBoss",
			Default = true,
		})

		SilentAim:Dropdown({
			Name = "Hit part",
			Flag = "SilentAimPart",
			Options = {
				"Head",
				"LowerTorso",
				"UpperTorso",
			},
		})

		local FOVSettings = CombatCategories.SilentAim:Section({
			Name = "FOV Settings",
			Side = "Right",
		})

		FOVSettings:Toggle({
			Name = "Visualize FOV",
			Flag = "VisualizeFOV",
			Callback = function(v)
				Visuals.FOVOutline.Visible = Library.Flags.VisualizeFOV.Value
			end,
		})

		FOVSettings:Toggle({
			Name = "Dynamic Radius",
			Flag = "DynamicFOV",
			Tooltip = "Scales radius based on Camera FOV",
		})

		FOVSettings:Slider({
			Name = "Radius",
			Flag = "FOVRadius",
			Suffix = "px",
			Min = 30,
			Max = 1500,
			Default = 350,
		})

		FOVSettings:Colorpicker({
			Name = "Color",
			Flag = "FOVColor",
			Default = { Library.Theme.Accent, 0.8 },
			Callback = function(v)
				Visuals.FOVCircleStroke.Color = Library.Flags.FOVColor.Value[1]
				Visuals.FOVInline.BackgroundColor3 = Library.Flags.FOVColor.Value[1]
				Visuals.FOVInline.BackgroundTransparency = Library.Flags.FOVColor.Value[2]
			end,
		})

		FOVSettings:Colorpicker({
			Name = "Target color",
			Flag = "TargetColor",
			Default = { Library.Theme.Accent, 0 },
		})


		local ArmorViewer = CombatCategories.SilentAim:Section({
			Name = "Armor Viewer",
			Side = "Right",
		})

		ArmorViewer:Toggle({
			Name = "Enabled",
			Flag = "ArmorViewer",
			Tooltip = "Displays targets armor",
			Callback = function()
				Window.ArmorPanel.Components.Armor.Visible = Library.Flags.ArmorViewer.Value
			end,
		})

		local ToolInfoModule = ReplicatedStorage:FindFirstChild("Modules")
				and (ReplicatedStorage.Modules:FindFirstChild("chickenfried") or ReplicatedStorage.Modules:FindFirstChild("ToolInfo"))
		local ToolInfo = ToolInfoModule and require(ToolInfoModule) or {}
		local ToolInfoCopy = Globals.DeepCopy(ToolInfo)

		Globals.ToolInfo = ToolInfo
		local CrosshairSettings = CombatCategories.Crosshair:Section({
			Name = "Settings",
			Side = "Left",
		})

		CrosshairSettings:Toggle({
			Name = "Enabled",
			Flag = "Crosshair",
		})

		CrosshairSettings:Toggle({
			Name = "Apply rotation animation",
			Flag = "RotateCrosshair",
		})

		CrosshairSettings:Toggle({
			Name = "Star of David",
			Flag = "StarCrosshair",
			Tooltip = "Israel star at screen center",
		})

		CrosshairSettings:Seperator()
		CrosshairSettings:Slider({
			Name = "Length",
			Flag = "CrosshairLength",
			Min = 3,
			Max = 40,
			Default = 20,
		})

		CrosshairSettings:Slider({
			Name = "Width",
			Flag = "CrosshairWidth",
			Min = 2,
			Max = 4,
			Default = 2,
		})

		CrosshairSettings:Slider({
			Name = "Gap",
			Flag = "CrosshairGap",
			Min = 1,
			Max = 20,
			Default = 10,
		})
		CrosshairSettings:Seperator()
		CrosshairSettings:Colorpicker({
			Name = "Color",
			Flag = "CrosshairColor",
			Default = { Color3.fromRGB(255, 255, 255), 0 },
		})

		local CrosshairTargetSettings = CombatCategories.Crosshair:Section({
			Name = "Target Settings",
			Side = "Right",
		})

		CrosshairTargetSettings:Toggle({
			Name = "Stick to target",
			Flag = "StickToTarget",
			Tooltip = "Crosshair will move to targe",
		})

		CrosshairTargetSettings:Toggle({
			Name = "Sync to lock color",
			Flag = "SyncToLockColor",
			Tooltip = "Crosshair will sync with target color if locked",
		})

	end

	local ESPCategories = {
		Players = Pages.ESP:Category({ Name = "Players" }),
		AI = Pages.ESP:Category({ Name = "AI" }),
		Boss = Pages.ESP:Category({ Name = "Bosses" }),
		World = Pages.ESP:Category({ Name = "World" }),
	}

	do
		do
			local PlayersMain = ESPCategories.Players:Section({
				Name = "Main",
				Side = "Left",
			})

			local PlayersSettings = ESPCategories.Players:Section({
				Name = "Settings",
				Side = "Left",
			})

			local PlayersColors = ESPCategories.Players:Section({
				Name = "Colors",
				Side = "Right",
			})

			local PlayerModels = ESPCategories.Players:Section({
				Name = "Character model",
				Side = "Right",
			})

			local LockOn = ESPCategories.Players:Section({
				Name = "Lock on indicators",
				Side = "Left",
			})

			do
				LockOn:Toggle({
					Name = "Enabled",
					Flag = "LockOnIndicator",
				})

				LockOn:Slider({
					Name = "Lock on threshold",
					Flag = "LockOnThreshold",
					Min = 30,
					Max = 90,
					Default = 70,
				})

				LockOn:Slider({
					Name = "Lock on danger threshold",
					Flag = "LockOnRisk",
					Min = 30,
					Max = 90,
					Default = 70,
				})
			end

			do
				PlayersMain:Toggle({
					Name = "Enabled",
					Flag = "PlayerESP",
				})

				PlayersMain:Toggle({
					Name = "Show Teammates",
					Flag = "ShowTeammates",
					Default = true,
					Tooltip = "Clan teammates are drawn in green; off = hidden completely",
				})

				PlayersMain:Toggle({
					Name = "Bounding box",
					Flag = "PlayerBoundingBox",
				})

				PlayersMain:Toggle({
					Name = "Skeleton",
					Flag = "PlayerSkeleton",
				})

				PlayersMain:Toggle({
					Name = "View angle",
					Flag = "PlayerLookAngle",
				})

				PlayersMain:Toggle({
					Name = "Healthbar",
					Flag = "PlayerHealthbar",
				})

				PlayersMain:Toggle({
					Name = "Name",
					Flag = "PlayerName",
				})

				PlayersMain:Toggle({
					Name = "Distance",
					Flag = "PlayerDistance",
				})

				PlayersMain:Toggle({
					Name = "Item",
					Flag = "PlayerWeapon",
				})

				PlayersMain:Toggle({
					Name = "Health",
					Flag = "PlayerHealth",
					Tooltip = "Displays players health on text",
				})

				PlayersMain:Toggle({
					Name = "Weapon image",
					Flag = "PlayerWeaponImage",
					Tooltip = "2d icon of held weapon",
				})

				PlayersMain:Toggle({
					Name = "Flags",
					Flag = "PlayerFlags",
					Tooltip = "Flag certain actions/attributes",
				})

				PlayersMain:Dropdown({
					Multi = true,
					Name = "Selected flags",
					Flag = "PlayerFlagsList",
					Options = {
						"Aiming",
						"Reloading",
						"Healing",
						"Clan",
						"VIP",
						"Staff",
					},
				})

				PlayersMain:Toggle({
					Name = "Offscreen indicators",
					Flag = "PlayerOffscreen",
				})
			end

			do
				PlayersSettings:Toggle({
					Name = "Text outline",
					Flag = "ESPTextOutline",
					Default = true,
					Tooltip = "Black outline around ESP text for readability",
				})

				PlayersSettings:Slider({
					Name = "Max distance",
					Flag = "PlayerMaxDistance",
					Min = 100,
					Max = 4000,
					Default = 4000,
					Suffix = " studs",
					Tooltip = "Hides player ESP beyond this distance",
				})

				PlayersSettings:Toggle({
					Name = "Ignore friends",
					Flag = "IgnoreFriends",
					Tooltip = "Doesn't render in players marked as friendly",
				})

				PlayersSettings:Dropdown({
					Name = "Bounding box type",
					Flag = "PlayerBoxStyle",
					Options = {
						"Solid",
						"Corner",
					},
				})

				PlayersSettings:Toggle({
					Name = "Only show health if damaged",
					Flag = "PlayerShowHealthIfDamaged",
				})

				PlayersSettings:Slider({
					Name = "Offscreen arrow size",
					Flag = "PlayerOffscreenSize",
					Min = 10,
					Max = 30,
					Increment = 0.1,
				})

				PlayersSettings:Slider({
					Name = "Offscreen arrow radius",
					Flag = "PlayerOffscreenRadius",
					Min = 100,
					Max = 700,
					Increment = 0.1,
				})
			end

			do
				PlayersColors:Colorpicker({
					Name = "Visible color",
					Flag = "PlayerVisibleColor",
					Default = { Color3.fromRGB(255, 0, 0), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Occluded color",
					Flag = "PlayerOccludedColor",
					Default = { Color3.fromRGB(255, 255, 255), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Higher health color",
					Flag = "PlayerHigherHealthColor",
					Default = { Color3.fromRGB(120, 255, 100), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Lower health color",
					Flag = "PlayerLowerHealthColor",
					Default = { Color3.fromRGB(255, 0, 0), 0 },
				})

				PlayersColors:Seperator()
				PlayersColors:Colorpicker({
					Name = "Aiming flag color",
					Flag = "AimingFlagColor",
					Default = { Color3.fromRGB(3, 169, 252), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Reloading flag color",
					Flag = "ReloadingFlagColor",
					Default = { Color3.fromRGB(255, 255, 255), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Healing flag color",
					Flag = "HealingFlagColor",
					Default = { Color3.fromRGB(120, 255, 100), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "VIP flag color",
					Flag = "VIPFlagColor",
					Default = { Color3.fromRGB(252, 211, 3), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Safezone flag color",
					Flag = "SafezoneFlagColor",
					Default = { Color3.fromRGB(0, 211, 0), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Clan flag color",
					Flag = "ClanFlagColor",
					Default = { Color3.fromRGB(255, 255, 255), 0 },
				})

				PlayersColors:Colorpicker({
					Name = "Staff flag color",
					Flag = "StaffFlagColor",
					Default = { Color3.fromRGB(255, 255, 255), 0 },
				})
			end

			do
				PlayerModels:Toggle({
					Name = "Chams",
					Flag = "PlayerChams",
				})

				PlayerModels:Dropdown({
					Name = "Chams style",
					Flag = "PlayerChamsStyle",
					Options = {
						"Solid",
						"Glow",
					},
				})

				PlayerModels:Colorpicker({
					Name = "Chams visible color",
					Flag = "PlayerChamsVisibleColor",
					Default = { Library.Theme.Accent, 0.2 },
				})

				PlayerModels:Colorpicker({
					Name = "Chams occluded color",
					Flag = "PlayerChamsOccludedColor",
					Default = { Library.Theme.Accent, 0.8 },
				})

				PlayerModels:Seperator()

				PlayerModels:Toggle({
					Name = "Sandbox armor models",
					Flag = "SandboxPlayer",
				})

				PlayerModels:Dropdown({
					Name = "Material",
					Flag = "PlayerArmorMaterial",
					Options = {
						"ForceField",
						"Neon",
						"SmoothPlastic",
						"Plastic",
						"Glass",
					},
				})

				PlayerModels:Slider({
					Name = "Reflectance",
					Flag = "PlayerArmorReflectance",
					Min = 0,
					Max = 1,
					Increment = 0.001,
				})

				PlayerModels:Slider({
					Name = "Reflectance multiplier",
					Flag = "PlayerArmorReflectanceMul",
					Min = 0,
					Max = 100,
				})

				PlayerModels:Colorpicker({
					Name = "Color",
					Flag = "PlayerArmorColor",
					Default = { Library.Theme.Accent, 0.2 },
				})
			end
		end

		do
			local AIMain = ESPCategories.AI:Section({
				Name = "Main",
				Side = "Left",
			})

			local AISettings = ESPCategories.AI:Section({
				Name = "Settings",
				Side = "Left",
			})

			local AIColors = ESPCategories.AI:Section({
				Name = "Colors",
				Side = "Right",
			})

			local AIModels = ESPCategories.AI:Section({
				Name = "Character model",
				Side = "Right",
			})

			do
				AIMain:Toggle({
					Name = "Enabled",
					Flag = "AIESP",
				})

				AIMain:Toggle({
					Name = "Bounding box",
					Flag = "AIBoundingBox",
				})

				AIMain:Toggle({
					Name = "Skeleton",
					Flag = "AISkeleton",
				})

				AIMain:Toggle({
					Name = "View angle",
					Flag = "AILookAngle",
				})

				AIMain:Toggle({
					Name = "Healthbar",
					Flag = "AIHealthbar",
				})

				AIMain:Toggle({
					Name = "Name",
					Flag = "AIName",
				})

				AIMain:Toggle({
					Name = "Distance",
					Flag = "AIDistance",
				})

				AIMain:Toggle({
					Name = "Health",
					Flag = "AIHealth",
					Tooltip = "Displays AIs health on text",
				})
			end

			do
				AISettings:Dropdown({
					Name = "Bounding box type",
					Flag = "AIBoxStyle",
					Options = {
						"Solid",
						"Corner",
					},
				})

				AISettings:Toggle({
					Name = "Only show health if damaged",
					Flag = "AIShowHealthIfDamaged",
				})

				AISettings:Slider({
					Name = "Maximum distance",
					Flag = "AIMaxDistance",
					Min = 100,
					Max = 4000,
					Suffix = "studs",
				})
			end

			do
				AIColors:Colorpicker({
					Name = "Visible color",
					Flag = "AIVisibleColor",
					Default = { Color3.fromRGB(255, 0, 0), 0 },
				})

				AIColors:Colorpicker({
					Name = "Occluded color",
					Flag = "AIOccludedColor",
					Default = { Color3.fromRGB(255, 255, 255), 0 },
				})

				AIColors:Colorpicker({
					Name = "Higher health color",
					Flag = "AIHigherHealthColor",
					Default = { Color3.fromRGB(120, 255, 100), 0 },
				})

				AIColors:Colorpicker({
					Name = "Lower health color",
					Flag = "AILowerHealthColor",
					Default = { Color3.fromRGB(255, 0, 0), 0 },
				})
			end

			do
				AIModels:Toggle({
					Name = "Chams",
					Flag = "AIChams",
				})

				AIModels:Dropdown({
					Name = "Chams style",
					Flag = "AIChamsStyle",
					Options = {
						"Solid",
						"Glow",
					},
				})

				AIModels:Colorpicker({
					Name = "Chams visible color",
					Flag = "AIChamsVisibleColor",
					Default = { Library.Theme.Accent, 0.2 },
				})

				AIModels:Colorpicker({
					Name = "Chams occluded color",
					Flag = "AIChamsOccludedColor",
					Default = { Library.Theme.Accent, 0.8 },
				})
			end
		end

		do
			local BossMain = ESPCategories.Boss:Section({
				Name = "Main",
				Side = "Left",
			})

			local BossSettings = ESPCategories.Boss:Section({
				Name = "Settings",
				Side = "Left",
			})

			local BossColors = ESPCategories.Boss:Section({
				Name = "Colors",
				Side = "Right",
			})

			local BossModels = ESPCategories.Boss:Section({
				Name = "Character model",
				Side = "Right",
			})

			do
				BossMain:Toggle({
					Name = "Enabled",
					Flag = "BossESP",
				})

				BossMain:Toggle({
					Name = "Bounding box",
					Flag = "BossBoundingBox",
				})

				BossMain:Toggle({
					Name = "Skeleton",
					Flag = "BossSkeleton",
				})

				BossMain:Toggle({
					Name = "View angle",
					Flag = "BossLookAngle",
				})

				BossMain:Toggle({
					Name = "Healthbar",
					Flag = "BossHealthbar",
				})

				BossMain:Toggle({
					Name = "Name",
					Flag = "BossName",
				})

				BossMain:Toggle({
					Name = "Distance",
					Flag = "BossDistance",
				})

				BossMain:Toggle({
					Name = "Health",
					Flag = "BossHealth",
					Tooltip = "Displays Bosses health on text",
				})
			end

			do
				BossSettings:Dropdown({
					Name = "Bounding box type",
					Flag = "BossBoxStyle",
					Options = {
						"Solid",
						"Corner",
					},
				})

				BossSettings:Toggle({
					Name = "Only show health if damaged",
					Flag = "BossShowHealthIfDamaged",
				})

				BossSettings:Slider({
					Name = "Maximum distance",
					Flag = "BossMaxDistance",
					Min = 100,
					Max = 4000,
					Suffix = "studs",
				})
			end

			do
				BossColors:Colorpicker({
					Name = "Visible color",
					Flag = "BossVisibleColor",
					Default = { Color3.fromRGB(255, 0, 0), 0 },
				})

				BossColors:Colorpicker({
					Name = "Occluded color",
					Flag = "BossOccludedColor",
					Default = { Color3.fromRGB(255, 255, 255), 0 },
				})

				BossColors:Colorpicker({
					Name = "Higher health color",
					Flag = "BossHigherHealthColor",
					Default = { Color3.fromRGB(120, 255, 100), 0 },
				})

				BossColors:Colorpicker({
					Name = "Lower health color",
					Flag = "BossLowerHealthColor",
					Default = { Color3.fromRGB(255, 0, 0), 0 },
				})
			end

			do
				BossModels:Toggle({
					Name = "Chams",
					Flag = "BossChams",
				})

				BossModels:Dropdown({
					Name = "Chams style",
					Flag = "BossChamsStyle",
					Options = {
						"Solid",
						"Glow",
					},
				})

				BossModels:Colorpicker({
					Name = "Chams visible color",
					Flag = "BossChamsVisibleColor",
					Default = { Library.Theme.Accent, 0.2 },
				})

				BossModels:Colorpicker({
					Name = "Chams occluded color",
					Flag = "BossChamsOccludedColor",
					Default = { Library.Theme.Accent, 0.8 },
				})
			end
		end

		do

			local Global = ESPCategories.World:Section({
				Name = "Global settings",
				Side = "Left",
			})

			Global:Keybind({
				Name = "Combat Hide",
				Flag = "CombatHide",
				Mode = "Toggle",
			})

			Global:Toggle({
				Name = "Smart ESP Fade",
				Tooltip = "Fades objects not in center",
				Flag = "SmartESP",
			})

			Global:Slider({
				Name = "Smart ESP Radius",
				Flag = "FadeRadius",
				Min = 0,
				Max = 1000,
			})

			local Wool = ESPCategories.World:Section({
				Side = "Left",
				Name = "Cloth plants",
			})

			Wool:Toggle({
				Name = "Enabled",
				Flag = "ESPWoolPlants",
			})

			Wool:Colorpicker({
				Name = "Color",
				Flag = "WoolPlantsMiscColor",
				Default = { Color3.fromRGB(25, 107, 0), 1 },
			})

			Wool:Slider({
				Min = 10,
				Max = 4000,
				Suffix = "s",
				Name = "Distance",
				Flag = "WoolPlantsDistance",
			})

			local Nodes = ESPCategories.World:Section({
				Side = "Right",
				Name = "Nodes",
			})

			Nodes:Toggle({
				Name = "Enabled",
				Flag = "ESPNodes",
			})

			Nodes:Seperator()

			Nodes:Toggle({
				Name = "Stone",
				Flag = "Stone nodeCanShow",
			})

			Nodes:Colorpicker({
				Name = "Stone color",
				Flag = "Stone nodeColor",
				Default = { Color3.fromRGB(255, 255, 255), 1 },
			})

			Nodes:Seperator()

			Nodes:Toggle({
				Name = "Metal",
				Flag = "Metal nodeCanShow",
			})

			Nodes:Colorpicker({
				Name = "Metal color",
				Flag = "Metal nodeColor",
				Default = { Color3.fromRGB(214, 135, 153), 1 },
			})

			Nodes:Seperator()

			Nodes:Toggle({
				Name = "Phosphate",
				Flag = "Phosphate nodeCanShow",
			})

			Nodes:Colorpicker({
				Name = "Phosphate color",
				Flag = "Phosphate nodeColor",
				Default = { Color3.fromRGB(237, 193, 104), 1 },
			})

			Nodes:Seperator()

			Nodes:Slider({
				Min = 10,
				Max = 4000,
				Suffix = "s",
				Name = "Distance",
				Flag = "NodesDistance",
			})

			local Bodybags = ESPCategories.World:Section({
				Name = "Body bags",
				Side = "Left",
			})

			Bodybags:Toggle({
				Name = "Enabled",
				Flag = "ESPBodyBags",
				Default = { Color3.fromRGB(244, 80, 40), 0 },
			})

			Bodybags:Colorpicker({
				Name = "Color",
				Flag = "BodyBagsMiscColor",
				Default = { Color3.fromRGB(255, 255, 255), 0 },
			})
			Bodybags:Slider({
				Name = "Distance",
				Flag = "BodyBagsDistance",
				Min = 50,
				Max = 4000,
				Suffix = "s",
			})

			local Items = ESPCategories.World:Section({
				Name = "Items",
				Side = "Right",
			})

			Items:Toggle({
				Name = "Enabled",
				Flag = "ESPItems",
			})

			Items:Seperator()

			Items:Toggle({
				Name = "Guns",
				Flag = "IncludeGun",
			})

			Items:Toggle({
				Name = "Consumable ammo",
				Flag = "IncludeConsumableAmmo",
			})

			Items:Toggle({
				Name = "Consumable armor",
				Flag = "IncludeConsumableAmmoArmor",
			})

			Items:Toggle({
				Name = "Ammo",
				Flag = "IncludeAmmo",
			})

			Items:Toggle({
				Name = "Armor",
				Flag = "IncludeArmor",
			})

			Items:Toggle({
				Name = "Tools",
				Flag = "IncludeTool",
			})

			Items:Toggle({
				Name = "Locks",
				Flag = "IncludeLock",
			})

			Items:Toggle({
				Name = "Benches",
				Flag = "IncludeBench",
			})

			Items:Toggle({
				Name = "Resources",
				Flag = "IncludeResource",
			})

			Items:Toggle({
				Name = "Components / Misc",
				Flag = "IncludeMisc",
			})

			Items:Toggle({
				Name = "Attachments",
				Flag = "IncludeAttachment",
			})

			Items:Toggle({
				Name = "Consumables",
				Flag = "IncludeConsumable",
			})

			Items:Seperator()

			Items:Colorpicker({
				Name = "Color",
				Flag = "ItemsColor",
			})

			Items:Slider({ Name = "Distance", Flag = "ItemsDistance", Min = 50, Max = 4000, Suffix = "s" })

			local Raids = ESPCategories.World:Section({ Name = "Raids", Side = "Right" })
			Raids:Toggle({
				Name = "Enabled",
				Flag = "ESPRaids",
			})

			Raids:Colorpicker({
				Name = "Color",
				Flag = "RaidsMiscColor",
				Default = {
					Color3.fromRGB(255, 0, 102),
					0,
				},
			})

			Raids:Slider({
				Name = "Distance",
				Flag = "RaidsDistance",
				Min = 50,
				Max = 10000,
				Suffix = "s",
			})

			Raids:Seperator()
			Raids:Toggle({
				Name = "Notifications",
				Flag = "RaidNotifications",
				Tooltip = "Notifies you when a raid starts",
			})

			local TimedCrates = ESPCategories.World:Section({ Name = "Timed Crates", Side = "Left" })
			TimedCrates:Toggle({
				Name = "Enabled",
				Flag = "ESPTimedCrates",
			})

			TimedCrates:Colorpicker({
				Flag = "TimedCratesMiscColor",
				Default = {
					Color3.fromRGB(0, 122, 8),
					0,
				},
				Name = "Color",
			})

			TimedCrates:Slider({
				Name = "Distance",
				Flag = "TimedCratesDistance",
				Min = 50,
				Max = 4000,
				Suffix = "s",
			})

			local CarePackages = ESPCategories.World:Section({
				Name = "Care Packages",
				Side = "Right",
			})

			CarePackages:Toggle({
				Name = "Enabled",
				Flag = "ESPCarePackages",
			})

			CarePackages:Colorpicker({
				Name = "Color",
				Flag = "CarePackagesMiscColor",
				Default = {
					Color3.fromRGB(0, 244, 8),
					0,
				},
			})

			CarePackages:Slider({
				Name = "Distance",
				Flag = "CarePackagesDistance",
				Min = 50,
				Max = 10000,
				Suffix = "s",
			})

			local Sleepers = ESPCategories.World:Section({
				Name = "Sleepers",
				Side = "Right",
			})

			Sleepers:Toggle({
				Name = "Enabled",
				Flag = "ESPSleepers",
			})

			Sleepers:Colorpicker({
				Name = "Color",
				Flag = "SleepersMiscColor",
			})

			Sleepers:Slider({
				Name = "Distance",
				Flag = "SleepersDistance",
				Min = 50,
				Max = 4000,
				Suffix = "s",
			})

		end
	end

	local VisualsCategories = {
		Camera = Pages.Visuals:Category({ Name = "Camera" }),
		World = Pages.Visuals:Category({ Name = "World" }),
		Viewmodel = Pages.Visuals:Category({ Name = "Viewmodel " }),
	}

	local CamEffects = VisualsCategories.Camera:Section({
		Name = "Camera Effects",
		Side = "Left",
	})

	CamEffects:Toggle({
		Name = "Remove bobbing",
		Flag = "RemoveCameraBobbing",
	})

	CamEffects:Seperator()

	CamEffects:Toggle({
		Name = "Custom field of view",
		Flag = "ChangeFOV",
		Callback = function()
			if Library.Flags.ChangeFOV.Value then
				IriSetFov(Library.Flags.CustomFOV.Value)
			end
		end,
	})

	local MaximumFOV = 120
	CamEffects:Slider({
		Name = "Field of view",
		Suffix = "°",
		Flag = "CustomFOV",
		Min = 70,
		Max = MaximumFOV,
		Callback = function()
			if Library.Flags.ChangeFOV.Value then
				IriSetFov(Library.Flags.CustomFOV.Value)
			end
		end,
	})

	CamEffects:Seperator()

	CamEffects:Toggle({
		Name = "Zoom",
		Flag = "Zoom",
	})

	CamEffects:Slider({
		Name = "Zoom level",
		Suffix = "°",
		Flag = "ZoomFOV",
		Min = 10,
		Max = 40,
	})

	CamEffects:Keybind({
		Name = "Zoom key",
		Flag = "Zoom Activation",
		Mode = "Hold",
		Callback = function()
			if Library.Flags["Zoom"].Value and Library.Flags["Zoom Activation"].Active then
				IriSetFov(Library.Flags.ZoomFOV.Value)
			end
		end,
	})

	local LightingSection = VisualsCategories.World:Section({
		Name = "Lighting",
		Side = "Left",
	})

	local BaseSection = VisualsCategories.World:Section({
		Name = "Bases",
		Side = "Right",
	})

	local Hitmarkers = VisualsCategories.World:Section({
		Name = "Hitmarkers",
		Side = "Left",
	})

	local Tracers = VisualsCategories.World:Section({
		Name = "Tracers",
		Side = "Right",
	})

	local TerrainSection = VisualsCategories.World:Section({
		Name = "Terrain",
		Side = "Left",
	})

	local CloudsSection = VisualsCategories.World:Section({
		Name = "Clouds",
		Side = "Right",
	})

	local FogSection = VisualsCategories.World:Section({
		Name = "Fog",
		Side = "Left",
	})

	local BloomSection = VisualsCategories.World:Section({
		Name = "Bloom",
		Side = "Right",
	})

	local SkyboxSection = VisualsCategories.World:Section({
		Name = "Skyboxes",
		SIde = "Right",
	})

	local Options = {}
	for Index, Value in Visuals.Skyboxes do
		Options[#Options + 1] = Index
	end

	SkyboxSection:Dropdown({
		Name = "Sky",
		Flag = "Sky",
		Options = Options,
		Default = "Default Sky",
		Callback = function()
			Visuals.Sky:SwitchSkybox(Library.Flags.Sky.Value)
		end,
	})

	local Bloom = Lighting:FindFirstChildOfClass("BloomEffect")
		or Globals:Instance("BloomEffect", {
			Parent = Lighting,
			Enabled = false,
		})

	BloomSection:Toggle({
		Name = "Enabled",
		Flag = "Bloom",
		Callback = function()
			Bloom.Enabled = Library.Flags.Bloom.Value
		end,
	})

	BloomSection:Slider({
		Name = "Intensity",
		Flag = "BloomIntensity",
		Min = 0,
		Max = 5,
		Increment = 0.1,
		Callback = function()
			Bloom.Intensity = Library.Flags.BloomIntensity.Value
		end,
	})

	BloomSection:Slider({
		Name = "Threshold",
		Flag = "BloomThreshold",
		Min = 0,
		Max = 1,
		Increment = 0.1,
		Callback = function()
			Bloom.Threshold = Library.Flags.BloomThreshold.Value
		end,
	})

	BloomSection:Slider({
		Name = "Size",
		Flag = "BloomSize",
		Min = 0,
		Max = 50,
		Increment = 0.1,
		Callback = function()
			Bloom.Size = Library.Flags.BloomSize.Value
		end,
	})

	Tracers:Toggle({
		Name = "Enabled",
		Flag = "BulletTracers",
	})

	Tracers:Toggle({
		Name = "Show enemy tracers",
		Flag = "ShowEnemyTracers",
	})

	Tracers:Seperator()

	Tracers:Colorpicker({
		Name = "Client tracer color",
		Flag = "TracerColor",
		Default = { Library.Theme.Accent, 0 },
	})

	Tracers:Colorpicker({
		Name = "Enemy tracer color",
		Flag = "EnemyTracerColor",
		Default = { Color3.fromRGB(255, 0, 0), 0 },
	})

	Tracers:Seperator()

	Tracers:Slider({
		Name = "Brigtness",
		Min = 1,
		Max = 10,
		Flag = "TracerBrightness",
	})

	Tracers:Slider({
		Name = "Lifetime",
		Flag = "TracerLifetime",
		Min = 1,
		Max = 5,
		Increment = 0.1,
	})

	Tracers:Slider({
		Name = "Speed",
		Flag = "ReferenceTime",
		Min = 50,
		Max = 300,
		Default = 250,
	})

	Tracers:Seperator()

	Tracers:Dropdown({ Name = "Texture", Flag = "BeamTexture", Options = { "Default", "Lightning", "Dark" } })

	Hitmarkers:Toggle({
		Name = "Enabled",
		Flag = "Hitmarkers",
	})

	Hitmarkers:Toggle({
		Name = "Prioritize hitmarker visibility",
		Flag = "PrioritizeHitmarkers",
	})

	Hitmarkers:Toggle({
		Name = "Apply random rotation",
		Flag = "HitmarkerRandomRotation",
	})

	Hitmarkers:Colorpicker({
		Name = "Color",
		Flag = "HitmarkerColor",
	})

	Hitmarkers:Slider({
		Name = "Size",
		Flag = "HitmarkerSize",
		Min = 10,
		Max = 20,
	})

	Hitmarkers:Slider({
		Name = "Lifetime",
		Flag = "HitmarkerTime",
		Min = 0.1,
		Max = 3,
		Increment = 0.1,
	})

	local LightingAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	local LightingClouds = Workspace.Terrain and Workspace.Terrain:FindFirstChild("Clouds")
	local LightingOriginals = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime,
		GlobalShadows = Lighting.GlobalShadows,
		ExposureCompensation = Lighting.ExposureCompensation,
	}
	local AtmosphereOriginals = {}
	if LightingAtmosphere then
		AtmosphereOriginals = {
			Density = LightingAtmosphere.Density,
			Color = LightingAtmosphere.Color,
			Decay = LightingAtmosphere.Decay,
			Haze = LightingAtmosphere.Haze,
			Glare = LightingAtmosphere.Glare,
		}
	end

	local CloudOriginals = {}
	if LightingClouds then
		CloudOriginals = {
			Density = LightingClouds.Density,
			Cover = LightingClouds.Cover,
			Color = LightingClouds.Color,
		}
	end

	local LightingState = { Previous = {} }
	local FullbrightWhite = Color3.fromRGB(255, 255, 255)

	local function BurmaldaFlag(FlagName, Fallback)
		local Flag = Library.Flags and Library.Flags[FlagName]
		if Flag and Flag.Value ~= nil then
			return Flag.Value
		end
		return Fallback
	end

	local function BurmaldaColor(FlagName, Fallback)
		local Value = BurmaldaFlag(FlagName, nil)
		if type(Value) == "table" and Value[1] ~= nil then
			return Value[1]
		end
		return Fallback
	end

	local function WriteLighting(Object, Property, Value)
		if not Object or Value == nil then
			return
		end
		local Ok, Current = pcall(function()
			return Object[Property]
		end)
		if Ok and Current ~= Value then
			pcall(function()
				Object[Property] = Value
			end)
		end
	end

	local function ApplyLighting()
		local Previous = LightingState.Previous
		local Fullbright = BurmaldaFlag("Fullbright", false) == true
		local Ambient = BurmaldaFlag("Ambient", false) == true
		local ChangeTime = BurmaldaFlag("ChangeTime", false) == true
		local FogDensity = BurmaldaFlag("ChangeFogDensity", false) == true
		local FogColor = BurmaldaFlag("ChangeFogColor", false) == true
		local FogDecay = BurmaldaFlag("ChangeFogDecay", false) == true
		local FogHaze = BurmaldaFlag("ChangeFogHaze", false) == true
		local FogGlare = BurmaldaFlag("ChangeFogGlare", false) == true
		local CloudDensity = BurmaldaFlag("ChangeCloudDensity", false) == true
		local CloudCover = BurmaldaFlag("ChangeCloudCover", false) == true
		local CloudColor = BurmaldaFlag("ChangeCloudColor", false) == true

		if Fullbright or Previous.Fullbright then
			local Value = Fullbright and (tonumber(BurmaldaFlag("Brightness", 3)) or 3) or LightingOriginals.Brightness
			WriteLighting(Lighting, "Brightness", Value)
			local Shadows = LightingOriginals.GlobalShadows
			if Fullbright then
				Shadows = false
			end
			WriteLighting(Lighting, "GlobalShadows", Shadows)
			WriteLighting(Lighting, "ExposureCompensation", Fullbright and 0 or LightingOriginals.ExposureCompensation)
		end

		if Fullbright or Ambient or Previous.Fullbright or Previous.Ambient then
			local Color = Ambient and BurmaldaColor("AmbientColor", FullbrightWhite)
				or (Fullbright and FullbrightWhite or nil)
			WriteLighting(Lighting, "Ambient", Color or LightingOriginals.Ambient)
			WriteLighting(Lighting, "OutdoorAmbient", Color or LightingOriginals.OutdoorAmbient)
		end

		if Fullbright or ChangeTime or Previous.Fullbright or Previous.ChangeTime then
			local Value = ChangeTime and BurmaldaFlag("Time", LightingOriginals.ClockTime)
				or (Fullbright and 14 or LightingOriginals.ClockTime)
			WriteLighting(Lighting, "ClockTime", Value)
		end

		if LightingAtmosphere then
			if Fullbright or FogDensity or Previous.Fullbright or Previous.ChangeFogDensity then
				local Value = FogDensity and BurmaldaFlag("FogDensity", AtmosphereOriginals.Density)
					or (Fullbright and 0 or AtmosphereOriginals.Density)
				WriteLighting(LightingAtmosphere, "Density", Value)
			end
			if FogColor or Previous.ChangeFogColor then
				WriteLighting(LightingAtmosphere, "Color", FogColor and BurmaldaColor("FogColor", AtmosphereOriginals.Color) or AtmosphereOriginals.Color)
			end
			if FogDecay or Previous.ChangeFogDecay then
				WriteLighting(LightingAtmosphere, "Decay", FogDecay and BurmaldaColor("FogDecay", AtmosphereOriginals.Decay) or AtmosphereOriginals.Decay)
			end
			if Fullbright or FogHaze or Previous.Fullbright or Previous.ChangeFogHaze then
				local Value = FogHaze and BurmaldaFlag("FogHaze", AtmosphereOriginals.Haze)
					or (Fullbright and 0 or AtmosphereOriginals.Haze)
				WriteLighting(LightingAtmosphere, "Haze", Value)
			end
			if Fullbright or FogGlare or Previous.Fullbright or Previous.ChangeFogGlare then
				local Value = FogGlare and BurmaldaFlag("FogGlare", AtmosphereOriginals.Glare)
					or (Fullbright and 0 or AtmosphereOriginals.Glare)
				WriteLighting(LightingAtmosphere, "Glare", Value)
			end
		end

		if LightingClouds then
			if CloudDensity or Previous.ChangeCloudDensity then
				WriteLighting(LightingClouds, "Density", CloudDensity and BurmaldaFlag("CloudDensity", CloudOriginals.Density) or CloudOriginals.Density)
			end
			if CloudCover or Previous.ChangeCloudCover then
				WriteLighting(LightingClouds, "Cover", CloudCover and BurmaldaFlag("CloudCover", CloudOriginals.Cover) or CloudOriginals.Cover)
			end
			if CloudColor or Previous.ChangeCloudColor then
				WriteLighting(LightingClouds, "Color", CloudColor and BurmaldaColor("CloudColor", CloudOriginals.Color) or CloudOriginals.Color)
			end
		end

		Previous.Fullbright = Fullbright
		Previous.Ambient = Ambient
		Previous.ChangeTime = ChangeTime
		Previous.ChangeFogDensity = FogDensity
		Previous.ChangeFogColor = FogColor
		Previous.ChangeFogDecay = FogDecay
		Previous.ChangeFogHaze = FogHaze
		Previous.ChangeFogGlare = FogGlare
		Previous.ChangeCloudDensity = CloudDensity
		Previous.ChangeCloudCover = CloudCover
		Previous.ChangeCloudColor = CloudColor
	end

	if Workspace.Terrain:FindFirstChild("Clouds") then
		local OldDensity = Workspace.Terrain.Clouds.Density
		local OldCover = Workspace.Terrain.Clouds.Cover
		local OldCloudColor = Workspace.Terrain.Clouds.Color

		local function CloudCallback()
			ApplyLighting()
		end

		CloudsSection:Toggle({
			Name = "Change cloud density",
			Flag = "ChangeCloudDensity",
			Callback = CloudCallback,
		})

		CloudsSection:Slider({
			Name = "Density",
			Flag = "CloudDensity",
			Min = 0,
			Max = 1,
			Increment = 0.001,
			Callback = CloudCallback,
		})

		CloudsSection:Seperator()

		CloudsSection:Toggle({
			Name = "Change cloud cover",
			Flag = "ChangeCloudCover",
			Callback = CloudCallback,
		})

		CloudsSection:Slider({
			Name = "Density",
			Flag = "CloudCover",
			Min = 0,
			Max = 1,
			Increment = 0.001,
			Callback = CloudCallback,
		})

		CloudsSection:Seperator()

		CloudsSection:Toggle({
			Name = "Change cloud color",
			Flag = "ChangeCloudColor",
			Callback = CloudCallback,
		})

		CloudsSection:Colorpicker({
			Name = "Color",
			Flag = "CloudColor",
			Callback = CloudCallback,
		})
	end

	local Atmosphere = Lighting:FindFirstChild("Atmosphere")

	if Atmosphere then
		local OldFogDensity = Atmosphere.Density
		local OldFogColor = Atmosphere.Color
		local OldFogHaze = Atmosphere.Haze
		local OldFogGlare = Atmosphere.Glare
		local OldFogDecay = Atmosphere.Decay

		local function FogCallback()
			ApplyLighting()
		end

		FogSection:Toggle({
			Name = "Change fog density",
			Flag = "ChangeFogDensity",
			Callback = FogCallback,
		})

		FogSection:Slider({
			Name = "Density",
			Flag = "FogDensity",
			Min = 0,
			Max = 1,
			Increment = 0.001,
			Callback = FogCallback,
		})

		FogSection:Seperator()

		FogSection:Toggle({
			Name = "Change fog haze",
			Flag = "ChangeFogHaze",
			Callback = FogCallback,
		})

		FogSection:Slider({
			Name = "Haze",
			Min = 0,
			Max = 1,
			Increment = 0.001,
			Callback = FogCallback,
			Flag = "FogHaze",
		})

		FogSection:Seperator()

		FogSection:Toggle({
			Name = "Change fog glare",
			Flag = "ChangeFogGlare",
			Callback = FogCallback,
		})

		FogSection:Slider({
			Name = "Glare",
			Min = 0,
			Max = 1,
			Increment = 0.001,
			Callback = FogCallback,
			Flag = "FogGlare",
		})

		FogSection:Toggle({
			Name = "Change fog color",
			Flag = "ChangeFogColor",
			Callback = FogCallback,
		})

		FogSection:Colorpicker({
			Name = "Color",
			Flag = "FogColor",
			Callback = FogCallback,
		})

		FogSection:Seperator()

		FogSection:Toggle({
			Name = "Change fog decay",
			Flag = "ChangeFogDecay",
			Callback = FogCallback,
		})

		FogSection:Colorpicker({
			Name = "Decay",
			Flag = "FogDecay",
			Callback = FogCallback,
		})
	end

	local BrightnessCallback = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		ApplyLighting()
	end)

	local AmbientCallback = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		ApplyLighting()
	end)

	local TimeCallback = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		ApplyLighting()
	end)

	LightingSection:Toggle({ Name = "Fullbright", Flag = "Fullbright", Callback = BrightnessCallback })
	LightingSection:Slider({
		Name = "Brightness",
		Flag = "Brightness",
		Min = 2,
		Max = 6,
		Increment = 0.1,
		Callback = BrightnessCallback,
	})
	LightingSection:Seperator()
	LightingSection:Toggle({ Name = "Ambience", Flag = "Ambient", Callback = AmbientCallback })

	local SkyOrig = nil
	local function ApplySky()
		local preset = Library.Flags.SkyPreset and Library.Flags.SkyPreset.Value or "Default"
		local stars = Library.Flags.SkyStars and Library.Flags.SkyStars.Value or 1500
		pcall(function()
			local sky = Lighting:FindFirstChildOfClass("Sky")
			if not SkyOrig then
				SkyOrig = {
					ClockTime = Lighting.ClockTime,
					Ambient = Lighting.Ambient,
					OutdoorAmbient = Lighting.OutdoorAmbient,
					FogEnd = Lighting.FogEnd,
					StarCount = sky and sky.StarCount,
					SunAngularSize = sky and sky.SunAngularSize,
					MoonAngularSize = sky and sky.MoonAngularSize,
				}
			end
			if preset == "Default" then
				Lighting.ClockTime = SkyOrig.ClockTime
				Lighting.Ambient = SkyOrig.Ambient
				Lighting.OutdoorAmbient = SkyOrig.OutdoorAmbient
				Lighting.FogEnd = SkyOrig.FogEnd
				if sky then
					sky.StarCount = SkyOrig.StarCount or 3000
					sky.SunAngularSize = SkyOrig.SunAngularSize or 21
					sky.MoonAngularSize = SkyOrig.MoonAngularSize or 11
				end
			elseif preset == "Night stars" then
				Lighting.ClockTime = 0
				if sky then
					sky.StarCount = stars
					sky.SunAngularSize = 8
					sky.MoonAngularSize = 14
				end
			elseif preset == "Deep space" then
				Lighting.ClockTime = 0
				Lighting.Ambient = Color3.fromRGB(0, 0, 0)
				Lighting.OutdoorAmbient = Color3.fromRGB(4, 4, 10)
				Lighting.FogEnd = 100000
				if sky then
					sky.StarCount = 4000
				end
			elseif preset == "Sunset" then
				Lighting.ClockTime = 6.7
				Lighting.Ambient = Color3.fromRGB(120, 70, 45)
				Lighting.OutdoorAmbient = Color3.fromRGB(140, 90, 60)
			end
		end)
	end

	LightingSection:Dropdown({
		Name = "Sky",
		Flag = "SkyPreset",
		Options = { "Default", "Night stars", "Deep space", "Sunset" },
		Callback = ApplySky,
	})
	LightingSection:Slider({
		Name = "Star count",
		Flag = "SkyStars",
		Min = 0,
		Max = 4000,
		Increment = 50,
		Default = 1500,
		Callback = ApplySky,
	})
	LightingSection:Colorpicker({
		Name = "Ambient color",
		Flag = "AmbientColor",
		Default = { Library.Theme.Accent, 0.1 },
		Callback = AmbientCallback,
	})

	LightingSection:Seperator()
	LightingSection:Toggle({ Name = "Change time", Flag = "ChangeTime", Callback = TimeCallback })
	LightingSection:Slider({ Name = "Time", Flag = "Time", Min = 0, Max = 14, Increment = 0.1, Callback = TimeCallback })

	task.spawn(function()
		while true do
			ApplyLighting()
			task.wait(0.15)
		end
	end)

	BaseSection:Toggle({
		Name = "XRay",
		Flag = "XRay",
	})

	BaseSection:Keybind({
		Name = "XRay Key",
		Flag = "XRay Activation",
		Callback = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
			for Index, Part in next, Globals.XRayParts do
				if Library.Flags.XRay.Value and Library.Flags["XRay Activation"].Active then
					Part.Transparency = Library.Flags.XRayTransparency.Value
				else
					Part.Transparency = 0
				end
			end
		end),
	})

	BaseSection:Slider({
		Name = "XRay transparency",
		Flag = "XRayTransparency",
		Min = 0,
		Max = 1,
		Increment = 0.1,
		Default = 0.5,
	})

	TerrainSection:Toggle({
		Name = "Remove grass",
		Flag = "RemoveGrass",
		Callback = function()
			sethiddenproperty(Workspace.Terrain, "Decoration", not Library.Flags.RemoveGrass.Value)
		end,
	})

	local ViewmodelMaster = VisualsCategories.Viewmodel:Section({
		Name = "Master",
		Side = "Left",
	})

	ViewmodelMaster:Toggle({
		Name = "Enabled",
		Flag = "ViewmodelSandbox",
	})

	local Items = VisualsCategories.Viewmodel:Section({
		Name = "Items",
		Side = "Right",
	})

	local Arms = VisualsCategories.Viewmodel:Section({
		Name = "Arms",
		Side = "Left",
	})

	local Gloves = VisualsCategories.Viewmodel:Section({
		Name = "Gloves",
		Side = "Left",
	})

	local Sleeves = VisualsCategories.Viewmodel:Section({
		Name = "Sleeves",
		Side = "Right",
	})

	local Highlight = VisualsCategories.Viewmodel:Section({
		Name = "Highlight",
		Side = "Left",
	})

	Items:Toggle({
		Name = "Enabled",
		Flag = "ItemChams",
	})

	Items:Toggle({
		Name = "Ignore attachments",
		Flag = "IgnoreAttachments",
	})

	Items:Colorpicker({
		Name = "Color",
		Flag = "VMItemColor",
		Default = { Color3.fromRGB(0, 100, 255), 0 },
	})

	Items:Dropdown({
		Name = "Material",
		Flag = "VMItemMaterial",
		Options = { "SmoothPlastic", "ForceField", "Neon", "Glass" },
	})

	Items:Slider({
		Name = "Reflectance",
		Flag = "ItemReflectance",
		Min = 0,
		Max = 5,
		Increment = 0.001,
	})

	Arms:Toggle({
		Name = "Enabled",
		Flag = "ArmChams",
	})

	Arms:Colorpicker({
		Name = "Color",
		Flag = "ArmColor",
		Default = { Color3.fromRGB(0, 100, 255), 0 },
	})

	Arms:Dropdown({
		Name = "Material",
		Flag = "ArmMaterial",
		Options = { "SmoothPlastic", "ForceField", "Neon", "Glass" },
	})

	Arms:Slider({
		Name = "Reflectance",
		Flag = "ArmReflectance",
		Min = 0,
		Max = 5,
		Increment = 0.001,
	})

	Sleeves:Toggle({
		Name = "Enabled",
		Flag = "ShirtChams",
	})

	Sleeves:Colorpicker({
		Name = "Color",
		Flag = "ShirtColor",
		Default = { Color3.fromRGB(0, 100, 255), 0 },
	})

	Sleeves:Dropdown({
		Name = "Material",
		Flag = "ShirtMaterial",
		Options = { "SmoothPlastic", "ForceField", "Neon", "Glass" },
	})

	Sleeves:Toggle({
		Name = "Remove sleeves",
		Flag = "RemoveClothing",
	})

	Sleeves:Slider({
		Name = "Reflectance",
		Flag = "ShirtReflectance",
		Min = 0,
		Max = 5,
		Increment = 0.001,
	})

	Gloves:Toggle({
		Name = "Enabled",
		Flag = "GloveChams",
	})

	Gloves:Colorpicker({
		Name = "Color",
		Flag = "GloveColor",
		Default = { Color3.fromRGB(0, 100, 255), 0 },
	})

	Gloves:Dropdown({
		Name = "Material",
		Flag = "GloveMaterial",
		Options = { "SmoothPlastic", "ForceField", "Neon", "Glass" },
	})

	Gloves:Slider({
		Name = "Reflectance",
		Flag = "GloveReflectance",
		Min = 0,
		Max = 5,
		Increment = 0.001,
	})

	Highlight:Colorpicker({
		Name = "Fill Color",
		Flag = "VMFillColor",
		Default = { Color3.fromRGB(0, 0, 0), 1 },
	})

	Highlight:Colorpicker({
		Name = "Outline Color",
		Flag = "VMOutlineColor",
		Default = { Color3.fromRGB(0, 0, 0), 0 },
	})

	local MiscCategories = {
		Sound = Pages.Misc:Category({ Name = "Sound " }),
	}

	local SoundMain = MiscCategories.Sound:Section({
		Name = "Main",
		Side = "Left",
	})

	local HitHead = SoundService:FindFirstChild("HitHead")
	local Hit = SoundService:FindFirstChild("Hit")

	if Hit and HitHead then
		local HitVolume = Hit.Volume
		local HitId = Hit.SoundId

		local HitHeadVolume = HitHead.Volume
		local HitHeadId = HitHead.SoundId

		local SoundIds = {
			["TF2"] = "rbxassetid://8255306220",
			["Gamesense"] = "rbxassetid://4817809188",
			["Rust"] = "rbxassetid://1255040462",
			["Neverlose"] = "rbxassetid://8726881116",
			["Bubble"] = "rbxassetid://198598793",
			["Quake"] = "rbxassetid://1455817260",
			["Among-Us"] = "rbxassetid://7227567562",
			["Ding"] = "rbxassetid://2868331684",
			["Minecraft"] = "rbxassetid://6361963422",
			["Blackout"] = "rbxassetid://3748776946",
			["Osu!"] = "rbxassetid://7151989073",
		}

		local SoundList = {}

		for Index, Value in SoundIds do
			table.insert(SoundList, Index)
		end

		SoundMain:Dropdown({
			Name = "Headshot sound",
			Flag = "HeadshotSound",
			Options = SoundList,
			Default = "Default",
			Callback = function()
				local Value = Library.Flags.HeadshotSound.Value
				if Value == "Default" then
					HitHead.SoundId = HitHeadId
					HitHead.Volume = HitHeadVolume
				else
					HitHead.SoundId = SoundIds[Value]
				end
			end,
		})

		SoundMain:Slider({
			Name = "Headshot volume",
			Flag = "HeadshotVolume",
			Min = 0.1,
			Max = 10,
			Default = HitHead.Volume,
			Callback = function()
				HitHead.Volume = Library.Flags.HeadshotVolume.Value
			end,
		})

		SoundMain:Dropdown({
			Name = "Hit sound",
			Flag = "HitSound",
			Options = SoundList,
			Default = "Default",
			Callback = function()
				local Value = Library.Flags.HitSound.Value
				if Value == "Default" then
					Hit.SoundId = HitId
					Hit.Volume = HitVolume
				else
					Hit.SoundId = SoundIds[Value]
				end
			end,
		})

		SoundMain:Slider({
			Name = "Hit volume",
			Flag = "HitVolume",
			Min = 0.1,
			Max = 10,
			Default = Hit.Volume,
			Callback = function()
				Hit.Volume = Library.Flags.HitVolume.Value
			end,
		})
	end

	SoundMain:Toggle({
		Name = "Silent step",
		Flag = "SilentStep",
		Risky = true,
	})
	local SkinCategories = {
		Global = Pages.Skins:Category({ Name = "Global Settings" }),
		Guns = Pages.Skins:Category({ Name = "Items" }),
		Armor = Pages.Skins:Category({ Name = "Armor" }),
	}

	local GlobalSection = SkinCategories.Global:Section({
		Name = "Global Settings",
		Side = "Left",
	})

	GlobalSection:Toggle({
		Name = "Enable skin changer",
		Flag = "SkinChanger",
	})

	GlobalSection:Seperator()

	GlobalSection:Dropdown({
		Name = "Character model",
		Flag = "CharModelChoice",
		Options = { "Player", "Tung Tung Sahur" },
		Default = "Player",
	})

	GlobalSection:Toggle({
		Name = "Apply model to all players",
		Flag = "CharModelAll",
		Tooltip = "Also reskin other players, not just you",
	})

	GlobalSection:Slider({
		Name = "Model scale",
		Flag = "CharModelScale",
		Min = 1,
		Max = 10,
		Default = 4,
		Increment = 0.5,
	})

	if ReplicatedStorage:FindFirstChild("VMs") then
		local VMs = ReplicatedStorage.VMs
		local Sleeves = ReplicatedStorage.Sleeves

		local ItemSkins = {}
		local ArmorSkins = {}

		for Index, Item in VMs:GetChildren() do
			if Item:IsA("Folder") then
				ItemSkins[Item.Name] = {}
				for _, Skin in Item:GetChildren() do
					if Skin:IsA("Model") then
						ItemSkins[Item.Name][#ItemSkins[Item.Name] + 1] = Skin.Name
					end
				end
			end
		end

		for Index, Armor in Sleeves:GetChildren() do
			if Armor:IsA("Folder") then
				ArmorSkins[Armor.Name] = {}
				for _, Skin in Armor:GetChildren() do
					if Skin:IsA("Model") then
						ArmorSkins[Armor.Name][#ArmorSkins[Armor.Name] + 1] = Skin.Name
					end
				end
			end
		end

		do
			local GoLeft = false
			for Item, Skins in ItemSkins do
				if #Skins > 1 then
					GoLeft = not GoLeft
					local Section = SkinCategories.Guns:Section({
						Name = Item,
						Side = GoLeft and "Left" or "Right",
					})

					Section:Toggle({
						Name = "Enabled",
						Flag = "EnableSkin_" .. Item,
					})
					Section:Dropdown({
						Name = "Skin",
						Flag = "Skin_" .. Item,
						Options = Skins,
					})
				end
			end
		end

		do
			local GoLeft = false
			for Armor, Skins in ArmorSkins do
				if #Skins > 1 then
					GoLeft = not GoLeft
					local Section = SkinCategories.Armor:Section({
						Name = Armor,
						Side = GoLeft and "Left" or "Right",
					})

					Section:Toggle({
						Name = "Enabled",
						Flag = "EnableSkin_" .. Armor,
					})
					Section:Dropdown({
						Name = "Skin",
						Flag = "Skin_" .. Armor,
						Options = Skins,
					})
				end
			end
		end
	end

	local SettingsCategories = {
		Main = Pages.Settings:Category({
			Name = "Main",
		}),
	}

	local Configs = SettingsCategories.Main:Section({
		Name = "Configurations",
		Side = "Left",
	})

	Configs:Textbox({
		Name = "Configuration Name",
		Flag = "ConfigName",
	})

	local Save = Configs:Button({
		Name = "Save",
		Flag = "SaveButton",
		Confirm = true,
		Callback = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
			Library:SaveConfig(Library.Flags.ConfigName.Value)
		end),
	}):AddButton({
		Name = "Load",
		Flag = "LoadButton",
		Confirm = true,
		Callback = phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
			local s, e = pcall(function()
				Library:LoadConfig(Library.Flags.ConfigName.Value)
			end)
			if not s then
				Library:Notify("Configuration failed to load\n" .. tostring(e), 4, Color3.fromRGB(255, 0, 0))
			end
		end),
	})
	Configs:Button({
		Name = "Delete config",
		Flag = "DeleteButton",
		Confirm = true,
		Callback = function()
			local Name = tostring(Library.Flags.ConfigName.Value)
			local FilePath = ConfigsFolder .. "/" .. Name .. ".json"
			if not isfile(FilePath) then
				Library:Notify(
					"Failed to load config!\n" .. FilePath .. "does not exist!",
					4,
					Color3.fromRGB(255, 165, 0)
				)
				return
			end

			delfile(FilePath)
		end,
	})

	if game.PlaceId == 17574618959 or game.PlaceId == 18911599934 then
		Configs:Button({
			Name = "Rejoin",
			Flag = "Rejoin",
			Callback = function()
				game.TeleportService:Teleport(game.PlaceId)
			end,
		})
	end

	local HUD = SettingsCategories.Main:Section({
		Name = "Heads up Display",
		Side = "Right",
	})

	HUD:Toggle({
		Name = "Hotkeys panel",
		Flag = "HotkeysPanel",
		Default = true,
		Callback = function()
			Window.Hotkeys.Components.Hotkeys.Visible = Library.Flags.HotkeysPanel.Value
		end,
	})

	HUD:Toggle({
		Name = "Moderator panel",
		Flag = "ModeratorPanel",
		Default = true,
		Callback = function()
			Window.ModPanel.Components.Moderators.Visible = Library.Flags.ModeratorPanel.Value
		end,
	})

	local ESPSettingsGlobal = SettingsCategories.Main:Section({
		Name = "Global ESP settings",
		Side = "Left",
	})

	ESPSettingsGlobal:Slider({
		Name = "Chams refresh rate",
		Flag = "ChamsRefreshRate",
		Min = 0,
		Max = 10,
		Suffix = "s",
		Increment = 0.1,
	})

-- [Burmalda.hook] modern menu theme
do
	local function StyleMenu()
		local Components = Window.Components
		if not Components or not Components.Outline then
			return
		end

		-- A small P mark keeps the rail branded without restoring the removed F.
		if Components.LogoSpace and not Components.LogoSpace:FindFirstChild("BurmaldaMenuMark") then
			local Mark = Globals:Instance("TextLabel", {
				Name = "BurmaldaMenuMark",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 30, 0, 30),
				BackgroundColor3 = Color3.fromRGB(18, 28, 38),
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Text = "B",
				TextColor3 = Library.Theme.Accent,
				TextSize = 19,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 3,
				Parent = Components.LogoSpace,
			})
			Globals:Instance("UICorner", {
				CornerRadius = UDim.new(0, 9),
				Parent = Mark,
			})
			Globals:Instance("UIStroke", {
				Color = Library.Theme.Accent,
				Transparency = 0.35,
				Thickness = 1,
				Parent = Mark,
			})
		end

		if Components.TopSideElements and not Components.TopSideElements:FindFirstChild("BurmaldaHeaderAccent") then
			local Header = Globals:Instance("Frame", {
				Name = "BurmaldaHeaderAccent",
				BackgroundColor3 = Library.Theme.Accent,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 2),
				ZIndex = 4,
				Parent = Components.TopSideElements,
			})
			Globals:Instance("UIGradient", {
				Rotation = 0,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 164, 180)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(157, 255, 234)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 225, 211)),
				}),
				Parent = Header,
			})
		end

		for _, Object in ipairs(Components.Outline:GetDescendants()) do
			if Object:IsA("UICorner") then
				if Object.Name == "SectionCorner" then
					Object.CornerRadius = UDim.new(0, 6)
				elseif Object.Name == "CategoryCorner" or Object.Name == "DropdownButtonCorner" then
					Object.CornerRadius = UDim.new(0, 5)
				end
			elseif Object:IsA("UIStroke") then
				if Object.Name == "SectionStroke" or Object.Name == "CategoryStroke" then
					Object.Transparency = 0.2
				end
			elseif Object:IsA("TextLabel") then
				if Object.Name == "SectionTitle" then
					Object.Font = Enum.Font.GothamSemibold
					Object.TextColor3 = Color3.fromRGB(232, 242, 246)
				elseif Object.Name == "CategoryTitle" then
					Object.Font = Enum.Font.GothamSemibold
					Object.TextSize = 13
				elseif Object.Name == "SliderTitle" or Object.Name == "DropdownTitle" then
					Object.Font = Enum.Font.Gotham
				end
			end

			-- A restrained accent rail makes sections readable without changing
			-- their dimensions or the existing input/layout code.
			if Object:IsA("Frame") and Object.Name == "Section" and not Object:FindFirstChild("BurmaldaSectionAccent") then
				Globals:Instance("Frame", {
					Name = "BurmaldaSectionAccent",
					BackgroundColor3 = Library.Theme.Accent,
					BackgroundTransparency = 0.55,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 5),
					Size = UDim2.new(0, 2, 1, -10),
					ZIndex = 2,
					Parent = Object,
				})
			end
		end
	end

	StyleMenu()
end

	local Watermark = Library:CreateWatermark("")
	task.wait(0.5)

	Globals:Tween(Window.Components.Outline, TweenInfo.new(Library.HighlightSpeed, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	Window:SetTab(Pages.Combat)
	task.wait(2)

	Watermark:SetText("Burmalda.hook")

	local ArmorPanel = Window.ArmorPanel
	Globals.ArmorPanel = ArmorPanel
end)()

Log("Successfully setup UI")

local AimingAnimationId = "rbxassetid://10982316984"
local HealingAnimationIds = {
	["rbxassetid://14860445359"] = true,
	["rbxassetid://2529243689"] = true,
}

EntityClass.Main.Functions:AddFlag({
	Name = "Aiming",
	ClassTypes = { "Player" },
	Text = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return "Scope"
	end),
	Allow = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		if not (self.Character and self.Character:FindFirstChild("Humanoid")) then
			return false
		end

		local Root = self.Character.Humanoid.RootPart
		if not Root then
			return false
		end

		local Weapon = self.CachedItem
		if Weapon and Weapon.Name == "Wooden Bow" then
			local DrawAnim = Root:FindFirstChild("Wooden BowDraw")
			return DrawAnim and DrawAnim.IsPlaying
		end

		for _, track in ipairs(self.Character.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.AnimationId == AimingAnimationId then
				return true
			end
		end
		return false
	end),
})

EntityClass.Main.Functions:AddFlag({
	Name = "Reloading",
	ClassTypes = { "Player" },
	Text = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return "Reload"
	end),
	Allow = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		local Root = self.Character and self.Character:FindFirstChild("HumanoidRootPart")
		local Weapon = self.CachedItem
		if not (Root and Weapon) then
			return false
		end

		local WeaponName = Weapon.Name
		local MagIn, MagOut

		if WeaponName == "Crossbow" then
			MagIn = Root:FindFirstChild("CrossbowPlaceArrow")
			MagOut = Root:FindFirstChild("CrossbowPull")
		else
			MagIn = Root:FindFirstChild(WeaponName .. "MagIn")
			MagOut = Root:FindFirstChild(WeaponName .. "MagOut")
		end

		return (MagIn and MagIn.IsPlaying) or (MagOut and MagOut.IsPlaying)
	end),
})

EntityClass.Main.Functions:AddFlag({
	Name = "Healing",
	ClassTypes = { "Player" },
	Text = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return "Heal"
	end),
	Allow = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		if not (self.Character and self.Character:FindFirstChild("Humanoid")) then
			return false
		end

		for _, track in ipairs(self.Character.Humanoid:GetPlayingAnimationTracks()) do
			if HealingAnimationIds[track.Animation.AnimationId] then
				return true
			end
		end
		return false
	end),
})

EntityClass.Main.Functions:AddFlag({
	Name = "VIP",
	ClassTypes = { "Player" },
	Text = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return "VIP"
	end),
	Allow = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return self.Pointer and self.Pointer:GetAttribute("VIP")
	end),
})

EntityClass.Main.Functions:AddFlag({
	Name = "Clan",
	ClassTypes = { "Player" },
	Text = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		if self.Pointer:GetAttribute("ClanTag") then
			return "C: " .. self.Pointer:GetAttribute("ClanTag")
		end
		return ""
	end),
	Allow = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return self.Pointer and self.Pointer:GetAttribute("ClanTag")
	end),
})

EntityClass.Main.Functions:AddFlag({
	Name = "Staff",
	ClassTypes = { "Player" },
	Text = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return self.Pointer and Globals.FlaggedStaff[self.Pointer] and "STAFF: " .. Globals.FlaggedStaff[self.Pointer]
			or nil
	end),
	Allow = phNV(function(self) LPH_ATTRIBUTES(VM(NONE)) 
		return self.Pointer and Globals.FlaggedStaff[self.Pointer]
	end),
})

local RaidsFolder = Globals:Instance("Folder", {
	Parent = CoreGui,
	Name = "Raids",
})

Globals.RaidsFolder = RaidsFolder

local AttackersFolder = Globals:Instance("Folder", {
	Parent = CoreGui,
	Name = "AttackerFolder",
})

Globals.AttackersFolder = AttackersFolder

phJITX(function() LPH_ATTRIBUTES(VM(NONE)) 

	local ModPanel = Library.Window.ModPanel
	local FlaggedRoles = {
		"OG",
		"Game Tester",
		"Game Moderator",
		"Developers",
		"Lead Developer",
		"Co-Founder",
		"Founder",
	}

	local function CheckMod(Player)
		if Player == Client then
			Library:Notify("Test....")
			ModPanel:Add(Player.Name, "test")
		end

		local Role = "cuck"
		local IsMod = false
		if Player:IsInGroup(1154360) then
			Role = Player:GetRoleInGroup(1154360)
			if table.find(FlaggedRoles, Role) then
				Library:Notify("Staff detected! [" .. Player.Name .. "] Role: " .. Role, 15, Color3.fromRGB(255, 0, 0))
				ModPanel:Add(Player.Name, Role)
				Globals.FlaggedStaff[Player] = Role
			end
		end

		if TrialModList[Player.UserId] and not Globals.FlaggedStaff[Player] then
			Role = "Trial Moderator"
			Library:Notify("Staff detected! " .. Player.Name .. " | Role: " .. Role, 15, Color3.fromRGB(255, 0, 0))
			ModPanel:Add(Player.Name, Role)
			Globals.FlaggedStaff[Player] = Role
		end

		return IsMod, Role
	end

	for Index, Player in Players:GetChildren() do
		if Player ~= Client then
			local EntityObject = EntityClass.Global:Create(Player, {
				Class = "Player",
				ClassType = "Player",
			})

			Player.CharacterAdded:Connect(function(Character)
				EntityObject:OnCharacterAdded(Character)
			end)

			if Player.Character then
				EntityObject:OnCharacterAdded(Player.Character)
			end

			pcall(CheckMod, Player)
		end
	end

	Players.PlayerAdded:Connect(function(Player)
		local EntityObject = EntityClass.Global:Create(Player, {
			Class = "Player",
			ClassType = "Player",
		})

		Player.CharacterAdded:Connect(function(Character)
			EntityObject:OnCharacterAdded(Character)
		end)

		if Player.Character then
			EntityObject:OnCharacterAdded(Player.Character)
		end

		pcall(CheckMod, Player)
	end)

	Players.ChildRemoved:Connect(function(Player)
		EntityClass.Main.Functions:Remove(Player)
		if Globals.FlaggedStaff[Player] then
			ModPanel:UpdateModerator(Player.Name, nil, true)
		end
	end)

	local Military = Workspace:FindFirstChild("Military")
	if Military then
		local Events = Workspace:FindFirstChild("Events")
		local function CacheSoldier(Soldier)
			if table.find({ "Brutus", "Bruno", "BTR", "Boris", "Soldier" }, Soldier.Name) then
				local ClassType = "AI"
				if
					Soldier.Name == "Brutus"
					or Soldier.Name == "Bruno"
					or Soldier.Name == "Boris"
					or Soldier.Name == "BTR"
				then
					ClassType = "Boss"
				end

				local EntityObject = EntityClass.Global:Create(Soldier, {
					Class = "AI",
					ClassType = ClassType,
				})
			else
				return
			end
		end

		for Index, BTR in Events:GetChildren() do
			if BTR.Name == "BTR" then
				CacheSoldier(BTR)
			end
		end

		Events.ChildAdded:Connect(function(BTR)
			task.wait(1)
			if BTR.Name == "BTR" then
				CacheSoldier(BTR)
			end
		end)

		Events.ChildRemoved:Connect(function(BTR)
			EntityClass.Main.Functions:Remove(BTR)
		end)

		for _, Folder in Military:GetChildren() do
			for Index, Soldier in Folder:GetChildren() do
				if Soldier:IsA("Model") then
					CacheSoldier(Soldier)
				end
			end

			Folder.ChildAdded:Connect(function(Soldier)
				task.wait(1)
				if Soldier:IsA("Model") then
					CacheSoldier(Soldier)
				end
			end)

			Folder.ChildRemoved:Connect(function(Soldier)
				EntityClass.Main.Functions:Remove(Soldier)
			end)
		end
	end

	local Nodes = Workspace:FindFirstChild("Nodes")
	local Drops = Workspace:FindFirstChild("Drops")
	local Bases = Workspace:FindFirstChild("Bases")
	local Plants = Workspace:FindFirstChild("Plants")

	local FixedNames = {
		["Metal_Node"] = "Metal node",
		["Phosphate_Node"] = "Phosphate node",
		["Stone_Node"] = "Stone node",
	}

	if Nodes then
		EntityClass.Misc.Functions.AddListener({
			Parent = Nodes,
			ClassName = "Model",
			Listener = "NodeListener",
			Flag = "Nodes",
			GetColor = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				local Name = FixedNames[Data.Object.Name]
				return Library.Flags[Name .. "Color"].Value[1]
			end),

			GetAlpha = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				local Name = FixedNames[Data.Object.Name]
				return Library.Flags[Name .. "Color"].Value[2]
			end),

			GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				local HealthPercent =
					math.floor((Data.Object:GetAttribute("Health") / Data.Object:GetAttribute("MaxHealth")) * 100)
				local Name = FixedNames[Data.Object.Name]

				return Name .. " " .. tostring(HealthPercent) .. "%"
			end),

			GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object:FindFirstChild("Main") and Data.Object:FindFirstChild("Main").CFrame.p
			end),

			GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object:FindFirstChild("Main")
					and math.floor((Camera.CFrame.p - Data.Object:FindFirstChild("Main").CFrame.p).Magnitude)
			end),

			Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				local Name = FixedNames[Data.Object.Name]
				return Library.Flags[Name .. "CanShow"].Value
			end),
		})

		Library:Notify("Added node listener...")
	end

	if Drops then
		local ItemColors = {
			["Misc"] = Color3.fromRGB(210, 210, 210),
			["Gun"] = Color3.fromRGB(214, 20, 20),
			["Ammo"] = Color3.fromRGB(214, 50, 50),
			["Consumable"] = Color3.fromRGB(50, 214, 50),
			["Bench"] = Color3.fromRGB(210, 210, 210),
			["Attachment"] = Color3.fromRGB(252, 215, 3),
			["Resource"] = Color3.fromRGB(3, 252, 161),
			["Lock"] = Color3.fromRGB(210, 210, 210),
			["Tool"] = Color3.fromRGB(255, 255, 255),
			["Armor"] = Color3.fromRGB(255, 0, 183),
		}

		EntityClass.Misc.Functions.AddListener({
			Parent = Drops,
			ClassName = "Model",
			Listener = "ItemListener",
			Flag = "Items",
			GetColor = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Library.Flags["ItemsColor"].Value[1]
			end),

			GetAlpha = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Library.Flags["ItemsColor"].Value[2]
			end),

			GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				if not Data.DecodedInformation then
					local Item = Data.Object:FindFirstChild("Item")
					Item = HttpService:JSONDecode(Item.Value)
					local ID = Item.ID
					local Amount = Item.Amount

					local ItemInfo = Globals.ItemInfoTable[ID]
					local Type = ItemInfo.Type
					Data.Type = Type
					Data.DecodedInformation = {
						ID = ID,
						Amount = Amount,
					}
				end

				local Color = ItemColors[Data.Type]
				local Name = Data.Object.Name

				if Data.DecodedInformation.Amount > 1 then
					Name = Name .. " x" .. tostring(Data.DecodedInformation.Amount)
				end

				return Name
			end),

			GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object.PrimaryPart and Data.Object.PrimaryPart.CFrame.p
			end),

			GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object.PrimaryPart
					and math.floor((Camera.CFrame.p - Data.Object.PrimaryPart.CFrame.p).Magnitude)
			end),

			Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				if Data.Object:FindFirstChild("Item") then
					if not Data.DecodedInformation then
						local Item = Data.Object:FindFirstChild("Item")
						Item = HttpService:JSONDecode(Item.Value)
						local ID = Item.ID
						local Amount = Item.Amount

						local ItemInfo = Globals.ItemInfoTable[ID]
						local Type = ItemInfo.Type
						Data.Type = Type
						Data.DecodedInformation = {
							ID = ID,
							Amount = Amount,
						}
					end
					return Library.Flags["Include" .. Data.Type].Value
				end
			end),
		})

		Library:Notify("Added item listener..")
		EntityClass.Misc.Functions.AddListener({
			Parent = Globals.RaidsFolder,
			ClassName = "Part",
			Listener = "RaidListener",
			Flag = "Raids",
			GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				local Object = Data.Object
				local Type = Object.Name
				local Time = tostring(math.floor(tick() - Object.StartedAt.Value))
				return "Potential Raid - " .. Object.Name .. "\n" .. tostring(Time) .. " seconds ago"
			end),

			GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object and Data.Object.CFrame.p
			end),

			GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object and math.floor((Camera.CFrame.p - Data.Object.CFrame.p).Magnitude)
			end),

			Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return true
			end),
		})

		EntityClass.Misc.Functions.AddListener({
			Parent = Globals.AttackersFolder,
			ClassName = "Part",
			Listener = "AttackerListener",
			Flag = "Attackers",
			GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object.Name
			end),

			GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object and Data.Object.CFrame.p
			end),

			GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object and math.floor((Camera.CFrame.p - Data.Object.CFrame.p).Magnitude)
			end),

			Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return true
			end),
		})
	end

	if Bases then
		local Loners = Bases:FindFirstChild("Loners")
		local TimedCrate = Loners:FindFirstChild("Timed Crate")
		local Sleeper = Loners:FindFirstChild("Sleeper")

		if TimedCrate then
			EntityClass.Misc.Functions.AddListener({
				Parent = TimedCrate,
				ClassName = "Model",
				Listener = "TimedCrateListener",
				Flag = "TimedCrates",
				GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					local Name = Data.Object.Name
					local Timer = Data.Object:FindFirstChild("Timer")
					local GuiHolder = Timer and Timer:FindFirstChild("GuiHolder")
					local SurfaceGui = GuiHolder and GuiHolder:FindFirstChild("Label")
					local TextLabel = SurfaceGui and SurfaceGui:FindFirstChild("TextLabel")
					local TimeRemaining = TextLabel and TextLabel.Text or "12:00"

					return Name .. " [" .. TimeRemaining .. "]"
				end),

				GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					return Data.Object.PrimaryPart and Data.Object.PrimaryPart.CFrame.p
				end),

				GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					return Data.Object.PrimaryPart
						and math.floor((Camera.CFrame.p - Data.Object.PrimaryPart.CFrame.p).Magnitude)
				end),

				Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					return true
				end),
			})

			Library:Notify("Added timed crate listener...")
		end

		if Loners then
			local CarePackage = Loners:FindFirstChild("Care Package")
			local BodyBag = Loners:FindFirstChild("Body Bag")
			if CarePackage then
				EntityClass.Misc.Functions.AddListener({
					Parent = CarePackage,
					ClassName = "Model",
					Listener = "CarePackageListener",
					Flag = "CarePackages",
					GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						local Name = Data.Object.Name
						return Name
					end),

					GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						return Data.Object.PrimaryPart and Data.Object.PrimaryPart.CFrame.p
					end),

					GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						return Data.Object.PrimaryPart
							and math.floor((Camera.CFrame.p - Data.Object.PrimaryPart.CFrame.p).Magnitude)
					end),

					Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						return true
					end),
				})

				Library:Notify("Added care package listener...")
			end

			if BodyBag then
				EntityClass.Misc.Functions.AddListener({
					Parent = BodyBag,
					ClassName = "Model",
					Name = "Body Bag",
					Listener = "BodyBagListener",
					Flag = "BodyBags",
					GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						local Name = Data.Object.Name
						local OwnerName = Data.Object:GetAttribute("OwnerName")

						local FixedName = Name .. " - " .. OwnerName
						return FixedName
					end),

					GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						return Data.Object.PrimaryPart and Data.Object.PrimaryPart.CFrame.p
					end),

					GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						return Data.Object.PrimaryPart
							and math.floor((Camera.CFrame.p - Data.Object.PrimaryPart.CFrame.p).Magnitude)
					end),

					Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
						return true
					end),
				})
				Library:Notify("Added body bag listener...")
			end
		end

		if Sleeper then
			EntityClass.Misc.Functions.AddListener({
				Parent = Sleeper,
				ClassName = "Model",
				Listener = "SleeperListener",
				Flag = "Sleepers",
				GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					local Name = Data.Object.Name
					local OwnerName = "Owner"
					local NameTag = Data.Object:FindFirstChild("NameTag")
					local Label = NameTag and NameTag:FindFirstChild("Label")
					OwnerName = Label and Label.Text or OwnerName

					local FixedName = Name .. " - " .. OwnerName
					return FixedName
				end),

				GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					return Data.Object.PrimaryPart and Data.Object.PrimaryPart.CFrame.p
				end),

				GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					return Data.Object.PrimaryPart
						and math.floor((Camera.CFrame.p - Data.Object.PrimaryPart.CFrame.p).Magnitude)
				end),

				Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
					return true
				end),
			})
			Library:Notify("Added sleeper listener...")
		end
	end

	if Plants then
		EntityClass.Misc.Functions.AddListener({
			Parent = Plants,
			Name = "Wool Plant",
			Listener = "WoolListener",
			Flag = "WoolPlants",
			GetName = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return "Cloth Plant"
			end),

			GetPosition = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object.PrimaryPart and Data.Object.PrimaryPart.CFrame.p
			end),

			GetDistance = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return Data.Object.PrimaryPart
					and math.floor((Camera.CFrame.p - Data.Object.PrimaryPart.CFrame.p).Magnitude)
			end),

			Validate = phNV(function(Data) LPH_ATTRIBUTES(VM(NONE)) 
				return true
			end),
		})

		Library:Notify("Added plant listener...")
	end

	Camera:GetPropertyChangedSignal("FieldOfView"):Connect(phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		if Library.Flags.Zoom.Value and Library.Flags["Zoom Activation"].Active then
			IriSetFov(Library.Flags.ZoomFOV.Value)
			return
		end

		if Library.Flags.ChangeFOV.Value then
			IriSetFov(Library.Flags.CustomFOV.Value)
		end
	end))

	local VFX = Workspace:FindFirstChild("VFX")
	local VMs = VFX and VFX:FindFirstChild("VMs")

	if VMs then
		VMs.ChildAdded:Connect(phNV(function(Viewmodel) LPH_ATTRIBUTES(VM(NONE)) 
			task.wait()
			if Viewmodel:IsA("Model") then
				local Arms = Viewmodel:WaitForChild("Arms")
				local Weapon = Viewmodel:WaitForChild("Weapon")
				local Highlight = Viewmodel:WaitForChild("Highlight", 1)

				if Arms and Weapon then
					if Library.Flags.ViewmodelSandbox.Value then
						if Highlight then
							Highlight.FillColor = Library.Flags.VMFillColor.Value[1]
							Highlight.FillTransparency = Library.Flags.VMFillColor.Value[2]

							Highlight.OutlineColor = Library.Flags.VMOutlineColor.Value[1]
							Highlight.OutlineTransparency = Library.Flags.VMOutlineColor.Value[2]
						end

						for Index, Part in next, Arms:GetDescendants() do
							if Part:IsA("MeshPart") then
								if
									(Part.Name == "Sleeve" or Part.Name == "Armor")
									and Library.Flags.ShirtChams
									and Library.Flags.ShirtChams.Value
								then
									Part.Material = Library.Flags.ShirtMaterial.Value
									Part.Color = Library.Flags.ShirtColor.Value[1]
									Part.Transparency = Library.Flags.ShirtColor.Value[2]
									Part.Reflectance = Library.Flags.ShirtReflectance.Value
								end

								if
									(Part.Name == "Sleeve" or Part.Name == "Armor")
									and Library.Flags.RemoveClothing
									and Library.Flags.RemoveClothing.Value
								then
									Part.Transparency = 1
								end

								if
									(Part.Name == "Glove" or Part.Name == "Wrap")
									and Library.Flags.GloveChams
									and Library.Flags.GloveChams.Value
								then
									Part.Material = Library.Flags.GloveMaterial.Value
									Part.Color = Library.Flags.GloveColor.Value[1]
									Part.Transparency = Library.Flags.GloveColor.Value[2]
									Part.Reflectance = Library.Flags.GloveReflectance.Value
								end

								if
									(Part.Name == "RightArm" or Part.Name == "LeftArm")
									and Library.Flags.ArmChams
									and Library.Flags.ArmChams.Value
								then
									Part.Material = Library.Flags.ArmMaterial.Value
									Part.Color = Library.Flags.ArmColor.Value[1]
									Part.Transparency = Library.Flags.ArmColor.Value[2]
									Part.Reflectance = Library.Flags.ArmReflectance.Value
								end

								if
									Part.Material == Enum.Material.SmoothPlastic
									or Part.Material == Enum.Material.Glass
									or Part.Material == Enum.Material.Neon
								then
									Part.TextureID = ""
								end

								if Part.Material == Enum.Material.ForceField then
									Part.TextureID = "rbxassetid://5843010904"
								end
							end
						end

						if Library.Flags.ItemChams.Value then
							for Index, Part in next, Weapon:GetDescendants() do
								if Part and Part:IsA("MeshPart") and Part.Transparency ~= 1 then
									if Weapon:FindFirstChild("Attachments") then
										if Part:IsDescendantOf(Weapon:FindFirstChild("Attachments")) then
											if not Library.Flags.IgnoreAttachments.Value then
												Part.Material = Library.Flags.VMItemMaterial.Value
												Part.Color = Library.Flags.VMItemColor.Value[1]
												Part.Transparency = Library.Flags.VMItemColor.Value[2]
												Part.Reflectance = Library.Flags.ItemReflectance.Value
											end
										else
											Part.Reflectance = Library.Flags.ItemReflectance.Value
											Part.Material = Library.Flags.VMItemMaterial.Value
											Part.Color = Library.Flags.VMItemColor.Value[1]
											Part.Transparency = Library.Flags.VMItemColor.Value[2]
										end
									else
										Part.Reflectance = Library.Flags.ItemReflectance.Value
										Part.Material = Library.Flags.VMItemMaterial.Value
										Part.Color = Library.Flags.VMItemColor.Value[1]
										Part.Transparency = Library.Flags.VMItemColor.Value[2]
									end

									if
										Part.Material == Enum.Material.SmoothPlastic
										or Part.Material == Enum.Material.Glass
										or Part.Material == Enum.Material.Neon
									then
										Part.TextureID = ""
									end

									if Part.Material == Enum.Material.ForceField then
										Part.TextureID = "rbxassetid://5843010904"
									end
								end
							end
						end
					end

					if (Library.Flags.ThirdPerson and Library.Flags.ThirdPerson.Value) and (Library.Flags["Third Person Activation"] and Library.Flags["Third Person Activation"].Active) then
						for Index, Part in Viewmodel:GetDescendants() do
							if Part:IsA("MeshPart") or Part:IsA("Part") then
								if Part.Transparency ~= 1 then
									Part:SetAttribute("OriginalTransparency", Part.Transparency)
								end
								Part.Transparency = 1
							end
						end
					end
				end
			end
		end))
	end

	local TouchCollisions = {}
	local DamageParts = {}
	local XRayParts = {}
	local AllowedBuildings = {
		"Wall",
		"Half Wall",
		"Low Wall",
		"Doorway",
		"Window",
		"Foundation",
		"Floor",
		"Triangle Floor",
		"Wall Frame",
		"Floor Frame",
		"Triangle Floor Frame",
		"L-Shaped Stairs",
		"U-Shaped Stairs",
		"Foundation Steps",
		"Foundation",
		"Triangle Foundation",
	}

	local BGrade = {
		["Wood"] = 1,
		["Stone"] = 2,
		["Metal"] = 3,
		["Steel"] = 4,
	}

	if Workspace:FindFirstChild("Bases") then
		phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
			for Index, Value in next, Workspace.Bases:GetDescendants() do
				if Value:IsA("MeshPart") and Value.Name == "Detail" then
					if Value.Parent and table.find(AllowedBuildings, Value.Parent.Name) then
						XRayParts[#XRayParts + 1] = Value
					end
				end

				if Value.Name == "TouchCollision" and Value.Parent and Value.Parent.Name == "Shotgun Turret" then
					TouchCollisions[#TouchCollisions + 1] = Value
				end

				if Value.Name == "DamagePart" then
					DamageParts[#DamageParts + 1] = Value
				end
			end
		end)()

		Workspace.Bases.DescendantAdded:Connect(phNV(function(Value) LPH_ATTRIBUTES(VM(NONE)) 
			if
				Client.Character
				and Client.Character:FindFirstChild("Blueprint")
				and table.find(AllowedBuildings, Value.Name)
				and (Library.Flags.AutoUpgrade and Library.Flags.AutoUpgrade.Value)
			then
				task.spawn(function()
					if not Value.PrimaryPart then
						local StartTime = tick()
						repeat
							task.wait()
						until Value.PrimaryPart or tick() - StartTime > 2
					end

					local Main = Value.PrimaryPart
					if
						Main
						and (Main.CFrame.p - Camera.CFrame.p).Magnitude < (Library.Flags.AutoUpgradeDistance and Library.Flags.AutoUpgradeDistance.Value)
					then
						local BuildingGrade = BGrade[(Library.Flags.UpgradeMaterial and Library.Flags.UpgradeMaterial.Value)]
						Library:Notify(
							"Auto Upgrade\n[Building]: "
								.. Value.Name
								.. " [Quality]: "
								.. (Library.Flags.UpgradeMaterial and Library.Flags.UpgradeMaterial.Value)
								.. " [Distance]: "
								.. tostring(math.floor((Main.CFrame.p - Camera.CFrame.p).Magnitude))
								.. "s",
							3,
							Color3.fromRGB(255, 133, 3)
						)
						Globals.BuildingNetworkPointer(
							"Fire",
							"KyO\188~?\141\137\005\132u \190\012DuNv\140A2m82n:$\182\159y",
							"\172:U\034\015\001\172\0169[eW\007\002\0265\018\135\188|\173\148\027w\024\007&F\179\013",
							Value,
							BuildingGrade
						)
					end
				end)
			end

			task.wait(0.5)

			if Value:IsA("MeshPart") and Value.Name == "Detail" then
				if Value.Parent and table.find(AllowedBuildings, Value.Parent.Name) then
					XRayParts[#XRayParts + 1] = Value

					if Library.Flags.XRay.Value and Library.Flags["XRay Activation"].Active then
						Value.Transparency = Library.Flags.XRayTransparency.Value
					end
				end
			end

			if Value.Name == "TouchCollision" and Value.Parent and Value.Parent.Name == "Shotgun Turret" then
				TouchCollisions[#TouchCollisions + 1] = Value
				Value.CanTouch = not (Library.Flags.DisableTurrets and Library.Flags.DisableTurrets.Value)
			end

			if Value.Name == "DamagePart" then
				DamageParts[#DamageParts + 1] = Value
				Value.CanTouch = not (Library.Flags.DisableDamageParts and Library.Flags.DisableDamageParts.Value)
			end
		end))
	end

	Globals.TouchCollisions = TouchCollisions
	Globals.DamageParts = DamageParts
	Globals.XRayParts = XRayParts

end)()

local Terrain = Workspace.Terrain
local Clouds = Terrain:FindFirstChild("Clouds")
local Atmosphere = Lighting:FindFirstChild("Atmosphere")

Log("Loaded Connenctions.")

EntityClass.LastTarget = EntityClass.LastTarget or nil
EntityClass.LastArmorData = EntityClass.LastArmorData or {}

local Swing = function(Remote, Hash, Arguments)
	Globals.VMNetworkPointer(
		"Fire",
		"\136\151\150OS/\012+S\127\029x\155 ;f\1757K\015\144\155`kZOs\186*R",
		" \160H|\151\012\176'A\028z\173b=\159\172H\011P\134\029|h\003\156}(\019\024\015",
		unpack(Arguments)
	)
end

local Hit = function(Time, MeleeArguments)
	local ServerTime = Time or Workspace:GetServerTimeNow()
	local Seed = ServerTime * 10000
	local RoundedSeed = math.round(Seed)
	local RandomCode = Random.new(RoundedSeed):NextInteger(1, 1000000000)
	local RandomCode2 = Random.new(RoundedSeed):NextInteger(1, 10000000000)

	local OldTable = {
		MeleeArguments[1],
		MeleeArguments[2],
		MeleeArguments[3],
		MeleeArguments[4],
		MeleeArguments[5],
		MeleeArguments[6],
		RandomCode,
		RandomCode2,
	}

	local Table = {
		RandomCode2,
		RandomCode,
		MeleeArguments[6],
		MeleeArguments[5],
		MeleeArguments[4],
		MeleeArguments[3],
		MeleeArguments[2],
		MeleeArguments[1],
	}

	local OriginCFrame = MeleeArguments[2]
	local OriginPosition = OriginCFrame.Position
	local TargetPosition = MeleeArguments[3].Position
	local Delta = TargetPosition - OriginPosition

	local Distance = Delta.Magnitude + 20
	local Direction = Delta.Unit * Distance
	local Parent = MeleeArguments[3].Parent
	local AdjustedHitPosition

	local Params2 = RaycastParams.new()
	Params2.FilterDescendantsInstances = { Parent }
	Params2.FilterType = Enum.RaycastFilterType.Whitelist
	Params2.IgnoreWater = true

	local Result = Workspace:Raycast(OriginPosition, Direction, Globals.RaycastParams)
	local Result2 = Workspace:Raycast(OriginPosition, Direction, Params2)
	if Result and Result.Instance then
		if Result.Normal.Magnitude ~= 1 then
			Table[4] = Result.Normal
		end

		if Result2 and Result2.Normal then
			Table[4] = Result2.Normal
		end

		local HitPos = Result.Position
		Table[5] = OldTable[3].CFrame:PointToObjectSpace(HitPos)

		if not Result.Instance:IsDescendantOf(Parent) then
			return
		end
	end

	if
		typeof(OldTable[3]) == "Instance"
		and typeof(OldTable[2]) == "CFrame"
		and typeof(OldTable[5]) == "Vector3"
		and type(OldTable[8]) == "number"
	then
		pcall(function()
			table.foreach(Table, warn)
			Globals.VMNetworkPointer(
				"Fire",
				"\136\151\150OS/\012+S\127\029x\155 ;f\1757K\015\144\155`kZOs\186*R",
				"?\185U\143\181*\176\169*\028\185E\146\023A\025Q\156zsPK\175\156c\009uHpx",
				unpack(Table)
			)
		end)
	end
end

---------------------------------------------------------------- newgame silent (LOS-only aim redirect, no wall shots)
do
	if getgenv().__PHOOK_NEWGAME == true then
		local SilentNG = {}

		local function shouldAct()
			if type(debug.getstack) ~= "function" then
				return false
			end
			local F = Library.Flags
			if not (F.SilentAim and F.SilentAim.Value) then
				return false
			end
			local act = F["SilentAim Activation"] and F["SilentAim Activation"].Active
			if not (F.AlwaysTarget and F.AlwaysTarget.Value or act) then
				return false
			end
			local Target = EntityClass.TargetPart
			return Target ~= nil and Target.Parent ~= nil
		end

		local function ngClearLos(from, to, targetInst)
			local dir = to - from
			if dir.Magnitude < 0.1 then
				return true
			end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Blacklist
			params.FilterDescendantsInstances = { Camera, Client.Character }
			local hit = Workspace:Raycast(from, dir, params)
			if not hit then
				return true
			end
			if not targetInst then
				return false
			end
			local model = hit.Instance and hit.Instance:FindFirstAncestorOfClass("Model")
			return model == targetInst
		end

		local function aimPitch(from, to)
			local d = to - from
			local flat = math.sqrt(d.X * d.X + d.Z * d.Z)
			if flat < 0.001 then
				return 0
			end
			return math.atan(-d.Y, flat)
		end

		local function rewriteVal(v, targetPos, camPos, headPos)
			local vt = typeof(v)
			if vt == "CFrame" then
				if (v.Position - camPos).Magnitude < 90 then
					return CFrame.new(v.Position, targetPos)
				end
			elseif vt == "Vector3" then
				if (v - targetPos).Magnitude < 45 and (v - headPos).Magnitude > 8 then
					return targetPos
				end
				local mag = v.Magnitude
				if mag > 0.8 and mag < 1.25 then
					local toTarget = targetPos - camPos
					if toTarget.Magnitude > 1 then
						if v.Unit:Dot(toTarget.Unit) > 0.965 then
							return toTarget.Unit
						end
					end
				end
			end
			return nil
		end

		local function scrubLevel(level, targetPos, camPos, headPos)
			local ok, regs = pcall(debug.getstack, level)
			if not ok or type(regs) ~= "table" then
				return
			end
			for index = 1, 160 do
				local val = rawget(regs, index)
				local vt = typeof(val)
				if vt == "CFrame" or vt == "Vector3" then
					local nw = rewriteVal(val, targetPos, camPos, headPos)
					if nw ~= nil then
						pcall(debug.setstack, level, index, nw)
					end
				elseif vt == "table" then
					local count = 0
					for k, v in next, val do
						count += 1
						if count > 48 then
							break
						end
						local wv = typeof(v)
						if wv == "CFrame" or wv == "Vector3" then
							local nw = rewriteVal(v, targetPos, camPos, headPos)
							if nw ~= nil then
								val[k] = nw
							end
						end
					end
				end
			end
		end

		local function chooseAim(target, targetChar)
			local tPos = target.CFrame.Position
			local camPos = Camera.CFrame.Position
			local head = Client.Character and Client.Character:FindFirstChild("Head")
			local headPos = head and head.CFrame.Position or camPos
			if ngClearLos(camPos, tPos, targetChar) and ngClearLos(headPos, tPos, targetChar) then
				return tPos
			end
			local manip = Library.Flags.Manipulation and Library.Flags.Manipulation.Value
			if not manip then
				return nil
			end
			-- visible-part aim: the shot always goes at a point with clear LOS (never through walls)
			local best, bestScore = nil, -math.huge
			local function consider(part)
				local pos = part.CFrame.Position
				if not (ngClearLos(camPos, pos, targetChar) and ngClearLos(headPos, pos, targetChar)) then
					return
				end
				local score = -((pos - headPos).Magnitude)
				if part:IsA("Head") then
					score += 1000
				elseif part.Name == "Torso" or part:IsA("HumanoidRootPart") then
					score += 300
				end
				if score > bestScore then
					bestScore = score
					best = pos
				end
			end
			if targetChar then
				for _, p in ipairs(targetChar:GetChildren()) do
					if p:IsA("BasePart") then
						consider(p)
					end
				end
			end
			consider(target)
			return best
		end

		local LastApply = 0
		local function apply()
			local now = os.clock()
			if now - LastApply < 0.05 then
				return
			end
			LastApply = now
			local Target = EntityClass.TargetPart
			if not (Target and Target.Parent) then
				return
			end
			local camPos = Camera.CFrame.Position
			local head = Client.Character and Client.Character:FindFirstChild("Head")
			local headPos = head and head.CFrame.Position or camPos
			local targetChar = EntityClass.TargetCharacter or Target.Parent
			local aimPoint = chooseAim(Target, targetChar)
			if not aimPoint then
				return
			end
			local char = Client.Character
			local tc = char and char:FindFirstChild("TorsoController")
			local look = tc and tc:FindFirstChild("Look")
			if look then
				pcall(function()
					look:FireServer(aimPitch(headPos, aimPoint), 0)
				end)
			end
			for level = 1, 16 do
				scrubLevel(level, aimPoint, camPos, headPos)
			end
		end
		SilentNG.apply = apply
		SilentNG.shouldAct = shouldAct

		task.spawn(function()
			local RS = game:GetService("ReplicatedStorage")
			local chain = {
				"Modules", "Kz", "IOn", "Cyz", "wihv", "lv", "vqS", "MrE", "prxK", "IXM",
				"BGkM", "OFLG", "bMkh", "mmOR", "iym", "Dz", "znbD", "Ii", "SoX", "ieBO",
				"yLZ", "Pm", "rCnJ", "QTA", "uili", "UoEx"
			}
			-- 1) early hook: shot-chain entry points (before payload serialization)
			local okChain, node = pcall(function()
				local n = RS:WaitForChild(chain[1], 90)
				for i = 2, #chain do
					n = n and n:FindFirstChild(chain[i])
				end
				return n
			end)
			if okChain and node then
				local okReq, mod = pcall(require, node)
				local function hookFn(fn)
					if type(fn) == "function" and not isfunctionhooked(fn) then
						local orig
						orig = hookfunction(fn, function(self, ...)
							if SilentNG.shouldAct() then
								pcall(SilentNG.apply)
							end
							return orig(self, ...)
						end)
					end
				end
				if okReq then
					if type(mod) == "function" then
						hookFn(mod)
					elseif type(mod) == "table" then
						local n = 0
						for _, v in pairs(mod) do
							n += 1
							if n > 64 then
								break
							end
							if type(v) == "function" then
								hookFn(v)
							elseif type(v) == "table" then
								local m = 0
								for _, v2 in pairs(v) do
									m += 1
									if m > 64 then
										break
									end
									if type(v2) == "function" then
										hookFn(v2)
									end
								end
							end
						end
					end
				end
			end

			-- 2) late hook: multiplexed Remotes channel (last chance before dispatch)
			local okRem, remotes = pcall(function()
				return RS:WaitForChild("Remotes", 90)
			end)
			if okRem and remotes then
				local hookedR = {}
				local function wrapRemoteMethod(remote, method)
					local fn = rawget(remote, method) or remote[method]
					if type(fn) ~= "function" or isfunctionhooked(fn) then
						return
					end
					local orig
					orig = hookfunction(fn, function(self, ...)
						if SilentNG.shouldAct() then
							pcall(SilentNG.apply)
						end
						return orig(self, ...)
					end)
				end
				local function hookRemote(r)
					if not r or hookedR[r] then
						return
					end
					hookedR[r] = true
					if r:IsA("RemoteEvent") then
						pcall(wrapRemoteMethod, r, "FireServer")
					elseif r:IsA("RemoteFunction") then
						pcall(wrapRemoteMethod, r, "FireServer")
						pcall(wrapRemoteMethod, r, "InvokeServer")
					end
				end
				for _, c in ipairs(remotes:GetChildren()) do
					hookRemote(c)
				end
				pcall(function()
					remotes.ChildAdded:Connect(hookRemote)
				end)
			end
		end)
	end
end

local LastArmorTick = tick()
local LastSwing = tick()

local EntityThread = Threads.New(
	"Entity Handler",
	phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Blacklist
		Params.FilterDescendantsInstances = { Camera, Client.Character, Workspace:FindFirstChild("VFX") }
		Globals.RaycastParams = Params

		local FOVRadius = Library.Flags.FOVRadius.Value

		if Library.Flags.DynamicFOV and Library.Flags.DynamicFOV.Value then
			local CurrentFOV = Library.Flags.ChangeFOV.Value and Library.Flags.CustomFOV.Value or 90
			local Difference = (CurrentFOV / Camera.FieldOfView)
			Globals:Tween(Visuals.FOVOutline, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				Size = UDim2.new(0, Difference * FOVRadius, 0, Difference * FOVRadius),
			})
		else
			Visuals.FOVOutline.Size = UDim2.new(0, FOVRadius, 0, FOVRadius)
		end

		local LastDistance = math.huge
		local ClosestTarget, EntityCharacter, EntityData, EntityInstance = nil, nil, nil, nil
		local Manipulated, ManipulatedPosition, ManipulatedPart, ManipulatedPlayer = false, nil, nil, nil

		local KillAuraTarget, KillAuraTargets, KADistance, KillAuraPart = nil, {}, nil, nil

		local SilentAimEnabled = Library.Flags.SilentAim.Value
		local ActivationActive = (Library.Flags["SilentAim Activation"] and Library.Flags["SilentAim Activation"].Active) and true or false
		local AlwaysTarget = Library.Flags.AlwaysTarget and Library.Flags.AlwaysTarget.Value
		local HitScanTargeting = Library.Flags.HitScan and Library.Flags.HitScan.Value
		local UseVisibleCheck = Library.Flags.VisibleCheck and Library.Flags.VisibleCheck.Value
		local RandomizeHitPart = Library.Flags.RandomizeHitPart and Library.Flags.RandomizeHitPart.Value or false
		local SilentAimPart = Library.Flags.SilentAimPart and Library.Flags.SilentAimPart.Value
		local ManipulationActive = (Library.Flags.Manipulation and Library.Flags.Manipulation.Value)
			and (Library.Flags["Manipulation Activation"] and Library.Flags["Manipulation Activation"].Active)
			or false
		local DynamicFOVRadius = Visuals.FOVCircle.AbsoluteSize.X / 2
		local ClientRoot = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")

		for Entity, Object in EntityClass.Main.Cache do
			if tick() - Object.LastUpdate > 0.0145 then
				Object.LastUpdate = tick()
				Object:Update()
			end

			local Core = Object.CoreInformation
			if not (Core and Core.Root and Object.Character and Entity ~= Client) then
				continue
			end

			if Object.ClassType == "Player" then
				Object.Friendly = isTeam(Entity)
			end

			if not (Core.OnScreen and (not Object.Friendly or (Library.Flags.TargetTeammates and Library.Flags.TargetTeammates.Value)) and SilentAimEnabled) then
				continue
			end

			local TargetingFlag = Library.Flags["Target" .. Object.ClassType]
			if not (TargetingFlag and TargetingFlag.Value and (ActivationActive or AlwaysTarget)) then
				continue
			end

			local Distance = Visuals.GetDistanceFromCenter(Core.Root)

			if Distance >= LastDistance or Distance > DynamicFOVRadius then
				continue
			end

			local TargetPart
			if UseVisibleCheck and Core.Visible then
				TargetPart = Core.VisiblePart
			elseif not UseVisibleCheck or HitScanTargeting then
				TargetPart = Object.Character:FindFirstChild(SilentAimPart)
			end

			if
				Client.Character
				and Client.Character:FindFirstChild("Humanoid")
				and Client.Character.Humanoid.RootPart
				and (Library.Flags.KillAura and Library.Flags.KillAura.Value)
				and Entity.Character
				and Entity.Character:FindFirstChild("Head")
			then
				local Distance = (
					Client.Character.Humanoid.RootPart.CFrame.p - Entity.Character:FindFirstChild("Head").CFrame.p
				).Magnitude
				if Distance <= (Library.Flags.KillAuraRadius and Library.Flags.KillAuraRadius.Value) then
					table.insert(KillAuraTargets, { Entity.Character:FindFirstChild("Head"), Distance, Entity })
				end
			end

			if Core.Visible and RandomizeHitPart then
				local Now = tick()
				local Reroll = Object.RandomPartCache
				if not (Reroll and Now - Reroll.t < 0.15 and Reroll.part and Reroll.part.Parent) then
					local Parts = {}
					for _, Part in ipairs(Object.Character:GetChildren()) do
						if Part:IsA("BasePart") and Visuals.IsPartVisible(Part) then
							table.insert(Parts, Part)
						end
					end
					Object.RandomPartCache = { t = Now, part = (#Parts > 0 and Parts[math.random(1, #Parts)]) or nil }
					Reroll = Object.RandomPartCache
				end
				if Reroll.part then
					TargetPart = Reroll.part
				end
			end

			if Object.Character.Name == "BTR" then
				TargetPart = Object.Character:FindFirstChild("HumanoidRootPart")
			end

			if ManipulationActive and ClientRoot and TargetPart and not Core.Visible then
				local StartPos = ClientRoot.CFrame

				local NowManip = tick()
				local ManipCached = Object.ManipPositionCache
				local VisiblePos
				if ManipCached and NowManip - ManipCached.t < 0.1 then
					VisiblePos = ManipCached.pos
				else
					VisiblePos = EntityClass.Global.FindVisiblePosition(StartPos, TargetPart)
					Object.ManipPositionCache = { t = NowManip, pos = VisiblePos }
				end

				if not VisiblePos and HitScanTargeting then
					local ToTarget = TargetPart.Position - ClientRoot.Position
					if ToTarget.Magnitude > 8 then
						VisiblePos = TargetPart.Position - ToTarget.Unit * 6
					end
				end
				if VisiblePos then
					Manipulated = true
					ManipulatedPart = TargetPart
					ManipulatedPosition = VisiblePos
					ManipulatedPlayer = Entity
				end
			end

			if TargetPart then
				ClosestTarget = TargetPart
				EntityCharacter = Object.Character
				EntityData = Object
				EntityInstance = Entity
				LastDistance = Distance
			end
		end

		EntityClass.Manipulated = Manipulated
		EntityClass.ManipulatedPart = ManipulatedPart
		EntityClass.ManipulatedPosition = ManipulatedPosition
		EntityClass.ManipulatedPlayer = ManipulatedPlayer
		EntityClass.TargetPart = ClosestTarget
		EntityClass.TargetData = EntityData
		EntityClass.TargetInstance = EntityInstance
		EntityClass.TargetCharacter = EntityCharacter

		-- Silent Aim redirects projectiles; camera rotation is intentionally disabled.

		local ArmorPanel = Library.Window.ArmorPanel
		if EntityData and EntityData.CachedArmor and Library.Flags.ArmorViewer.Value then
			if tick() - Globals.LastArmorCheck > 0.2 then
				local seen = {}
				for _, armor in pairs(EntityData.CachedArmor) do
					if armor.Name and armor.Skin then
						local key = armor.Name .. "_" .. armor.Skin
						seen[key] = true
						ArmorPanel:Add(armor.Name, armor.Skin)
					end
				end
				local Tool = EntityCharacter and EntityCharacter:FindFirstChildOfClass("Tool")
				local WName = Tool and Tool.Name or "none"
				seen["Weapon_" .. WName] = true
				ArmorPanel:Add("Weapon", WName)

				for _, child in ipairs(ArmorPanel.Components.ArmorList:GetChildren()) do
					if child:IsA("Frame") and not seen[child.Name] then
						ArmorPanel:UpdateArmor(child.Name, nil, true)
					end
				end
				Globals.LastArmorCheck = tick()
			end
		else
			ArmorPanel:ClearAll()
		end

		if (Library.Flags.KillAura and Library.Flags.KillAura.Value) then
			if #KillAuraTargets ~= 0 and Client.Character then
				for Index, Data in KillAuraTargets do
					local Distance = Data[2]
					local HitPart = Data[1]
					if not KillAuraPart or Distance < KADistance then
						KillAuraPart = HitPart
						KADistance = Distance
						KillAuraTarget = Data[3]
					end
				end
			end

			local Weapon = Workspace:FindFirstChild("VFX") and Workspace.VFX.VMs:GetChildren()[1]
			local WeaponData = Weapon and Globals.ToolInfo[Weapon.Name]

			if
				Client.Character
				and KillAuraTarget
				and WeaponData
				and rawget(WeaponData, "Weapon")
				and rawget(WeaponData.Weapon, "Cooldown")
			then
				if KillAuraTarget:IsA("Player") then
					KillAuraTarget = KillAuraTarget.Character
				end

				local Root = Client.Character:FindFirstChild("HumanoidRootPart")

				local Cooldown = WeaponData.Weapon.Cooldown
				local Tip = Weapon:FindFirstChild("Weapon") and Weapon.Weapon:FindFirstChild("Main")
					or Weapon.Weapon:FindFirstChild("Handle")
				local Target = KillAuraTarget:FindFirstChild("Head")

				local AttackCFrame = CFrame.new(Root.Position + Vector3.new(0, 3, 0), Target.Position)
				if
					Target
					and (Root.CFrame.p - Target.CFrame.p).magnitude <= (Library.Flags.KillAuraRadius and Library.Flags.KillAuraRadius.Value)
					and tick() - LastSwing > math.max(Cooldown, 0.45) * (0.9 + math.random() * 0.25)
				then
					LastSwing = tick()

					task.spawn(function()
						local Time = Workspace:GetServerTimeNow()

						Library:Notify(
							"Kill Aura - Swinging weapon (" .. Weapon.Name .. ")",
							1,
							(Library.Flags.KillAuraColor and Library.Flags.KillAuraColor.Value[1])
						)
						local s, e = pcall(function()
							Swing("", "", { Time, Weapon.Name })
						end)

						task.wait()

						local RootToTip = Root.CFrame:PointToObjectSpace(Tip.Position)
						local Angle = (Client.Character.Head.Position - Target.Position).Unit

						if (Library.Flags.ThirdPerson and Library.Flags.ThirdPerson.Value) and (Library.Flags["Third Person Activation"] and Library.Flags["Third Person Activation"].Active) then
							local WorldModel = Client.Character:FindFirstChild(Weapon.Name)
							Tip = WorldModel and WorldModel:FindFirstChild("Handle")
							if not Tip then
								return
							end
							RootToTip = Root.CFrame:PointToObjectSpace(Tip.Position) / 10
						end

						if AttackCFrame and Target and Angle and RootToTip then
							local s, e = pcall(function()
								Library:Notify(
									"Kill Aura\nAttempting to hit: "
										.. KillAuraTarget.Name
										.. " from "
										.. tostring(math.floor((Root.CFrame.p - Target.CFrame.p).magnitude))
										.. " studs away.",
									1,
									(Library.Flags.KillAuraColor and Library.Flags.KillAuraColor.Value[1])
								)

								if Library.Flags.Hitmarkers.Value then
									Visuals.CreateHitmarker(Target, Target.Position)
								end

								SoundService.HitHead:Play()
								Hit(
									Time,
									{ math.random(1, 3), AttackCFrame, Target, Angle, RootToTip, "Plastic", "", "" }
								)
							end)

						end
					end)
				end
			end
		end
	end),
	"Entities"
)

local VisualsThread = Threads.New(
	"Visuals Handler",
	phNV(function() LPH_ATTRIBUTES(VM(NONE)) 

		Visuals.CrosshairHolder.Visible = Library.Flags.Crosshair.Value

		if Visuals.CrosshairHolder.Visible then
			local Length = Library.Flags.CrosshairLength.Value
			local Width = Library.Flags.CrosshairWidth.Value
			local Gap = Library.Flags.CrosshairGap.Value

			Visuals.CrosshairTop.Size = UDim2.new(0, Width, 0, Length)
			Visuals.CrosshairBottom.Size = UDim2.new(0, Width, 0, Length)

			Visuals.CrosshairRight.Size = UDim2.new(0, Length, 0, Width)
			Visuals.CrosshairLeft.Size = UDim2.new(0, Length, 0, Width)

			Visuals.CrosshairTop.Position = UDim2.new(0.5, 0, 0.5, -Gap - Length / 2)
			Visuals.CrosshairBottom.Position = UDim2.new(0.5, 0, 0.5, Gap + Length / 2)
			Visuals.CrosshairLeft.Position = UDim2.new(0.5, -Gap - Length / 2, 0.5, 0)
			Visuals.CrosshairRight.Position = UDim2.new(0.5, Gap + Length / 2, 0.5, 0)

			Globals:Tween(
				Visuals.CrosshairTop,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = EntityClass.TargetPart
							and Library.Flags.SyncToLockColor.Value
							and Library.Flags.TargetColor.Value[1]
						or Library.Flags.CrosshairColor.Value[1],
				}
			)
			Globals:Tween(
				Visuals.CrosshairBottom,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = EntityClass.TargetPart
							and Library.Flags.SyncToLockColor.Value
							and Library.Flags.TargetColor.Value[1]
						or Library.Flags.CrosshairColor.Value[1],
				}
			)
			Globals:Tween(
				Visuals.CrosshairLeft,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = EntityClass.TargetPart
							and Library.Flags.SyncToLockColor.Value
							and Library.Flags.TargetColor.Value[1]
						or Library.Flags.CrosshairColor.Value[1],
				}
			)
			Globals:Tween(
				Visuals.CrosshairRight,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = EntityClass.TargetPart
							and Library.Flags.SyncToLockColor.Value
							and Library.Flags.TargetColor.Value[1]
						or Library.Flags.CrosshairColor.Value[1],
				}
			)

			if Library.Flags.RotateCrosshair.Value then
				Visuals.CrosshairHolder.Rotation = Visuals.CrosshairHolder.Rotation + 0.5
			else
				Visuals.CrosshairHolder.Rotation = 0
			end

			if Library.Flags.StickToTarget.Value and EntityClass.TargetPart then
				local Position, OnScreen = Camera:WorldToViewportPoint(EntityClass.TargetPart.Position)
				if OnScreen then
					Globals:Tween(
						Visuals.CrosshairHolder,
						TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Position = UDim2.new(0, Position.X, 0, Position.Y),
						}
					)
				end
			else
				local ScreenSize = Camera.ViewportSize
				Globals:Tween(
					Visuals.CrosshairHolder,
					TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0, ScreenSize.X / 2, 0, ScreenSize.Y / 2),
					}
				)
			end
		end

		if Library.Flags.SkinChanger.Value and tick() - LastArmorTick > 3 then
			LastArmorTick = tick()
			local ArmorSleeves = Client:GetAttribute("ArmorSleeves") or ""
			local Split = string.split(ArmorSleeves, "^")

			if type(Split) == "table" and Split[1] then
				local ShirtSplit = Split[1]:split("/")
				local GloveSplit = Split[2] and Split[2]:split("/") or {}

				local Shirt = ShirtSplit[1] or ""
				local ShirtSkin = ShirtSplit[2] or "Default"
				local Glove = GloveSplit[1] or ""
				local GloveSkin = GloveSplit[2] or "Default"

				if Library.Flags["EnableSkin_" .. Shirt] and Library.Flags["EnableSkin_" .. Shirt].Value then
					local ClientSkin = Library.Flags["Skin_" .. Shirt].Value
					local SleeveFolder = ReplicatedStorage.Sleeves:FindFirstChild(Shirt)
					if SleeveFolder and SleeveFolder:FindFirstChild(ClientSkin) then
						ShirtSkin = ClientSkin
					end
				end

				if Library.Flags["EnableSkin_" .. Glove] and Library.Flags["EnableSkin_" .. Glove].Value then
					local ClientSkin = Library.Flags["Skin_" .. Glove].Value
					local SleeveFolder = ReplicatedStorage.Sleeves:FindFirstChild(Glove)
					if SleeveFolder and SleeveFolder:FindFirstChild(ClientSkin) then
						GloveSkin = ClientSkin
					end
				end

				local NewArmor = ""

				if Shirt ~= "" then
					NewArmor = Shirt .. "/" .. ShirtSkin
				end

				if Glove ~= "" then
					if Shirt ~= "" then
						NewArmor = NewArmor .. "^"
					end

					NewArmor = NewArmor .. Glove .. "/" .. GloveSkin
				end

				if NewArmor ~= "/^/" then
					Client:SetAttribute("ArmorSleeves", NewArmor)
				end
			end
		end

		for Index, Data in Visuals.Hitmarkers do
			if not Data.Hitmarker then
				continue
			end

			local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Data.Position)
			if not OnScreen then
				Data.Hitmarker.Visible = false
				continue
			end

			Data.Hitmarker.Position = UDim2.new(0, ScreenPos.X, 0, ScreenPos.Y)
			Data.Hitmarker.Visible = true
		end

		local Root = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
		local RootToGround = Root and (Root.Position - Vector3.new(0, 3, 0)) or Vector3.new(0, 3, 0)

		if Root and (Library.Flags.KillAura and Library.Flags.KillAura.Value) and not Library.IsOpen then
			local LineCount = Visuals.LineCount
			local CircleLines = Visuals.CircleLines
			local KillAuraColor = (Library.Flags.KillAuraColor and Library.Flags.KillAuraColor.Value[1])
			local KillAuraRadius = (Library.Flags.KillAuraRadius and Library.Flags.KillAuraRadius.Value)

			for i = 1, LineCount do
				local Angle1 = ((i - 1) / LineCount) * math.pi * 2
				local Angle2 = (i / LineCount) * math.pi * 2

				local From = RootToGround + Vector3.new(math.cos(Angle1), 0, math.sin(Angle1)) * KillAuraRadius
				local To = RootToGround + Vector3.new(math.cos(Angle2), 0, math.sin(Angle2)) * KillAuraRadius

				local ScreenFrom, FromVisible = Camera:WorldToViewportPoint(From)
				local ScreenTo, ToVisible = Camera:WorldToViewportPoint(To)

				local Line = CircleLines[i]
				if FromVisible or ToVisible then
					Line.Visible = true
					Line:FindFirstChildOfClass("UIStroke").Color = KillAuraColor
					Visuals.RotateLine(
						Line,
						0,
						Vector2.new(ScreenFrom.X, ScreenFrom.Y),
						Vector2.new(ScreenTo.X, ScreenTo.Y)
					)
				else
					Line.Visible = false
				end
			end
		else
			for i = 1, Visuals.LineCount do
				Visuals.CircleLines[i].Visible = false
			end
		end

		if Library.Flags.ChangeTime.Value then
			Lighting.ClockTime = Library.Flags.Time.Value
		end
	end),
	"Render"
)

local MiscLoop = Threads.New(
	"Misc entity loop",
	phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		local SmartESP = Library.Flags.SmartESP.Value
		local CombatHide = Library.Flags.CombatHide.Active
		local FadeRadius = Library.Flags.FadeRadius.Value
		local Font = EntityClass.Font
		local FontSize = EntityClass.FontSize

		if not CombatHide then
			Visuals.MiscSpace.Enabled = true
			for Entity, Data in EntityClass.Misc.Cache do
				local Listener = Data.Listener
				local Components = Data.Components
				local Object = Entity

				if not Object or not Components or not Components.Name then
					if Components and Components.Name then
						Components.Name:Destroy()
					end
					continue
				end

				local Flag = Listener.Flag
				local EnabledFlag = Library.Flags["ESP" .. Flag]
				local MaxDistanceFlag = Library.Flags[Flag .. "Distance"]

				if CombatHide or not EnabledFlag or not EnabledFlag.Value or not Listener.Validate(Data) then
					Components.Name.Visible = false
					continue
				end

				local Position = Listener.GetPosition(Data)
				if not Position then
					Components.Name.Visible = false
					continue
				end

				local Distance = Listener.GetDistance(Data)
				if not Distance or Distance > MaxDistanceFlag.Value then
					Components.Name.Visible = false
					continue
				end

				local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Position)
				if not OnScreen then
					Components.Name.Visible = false
					continue
				end

				local Name = Listener.GetName(Data)
				local NameColor = Listener.GetColor(Data)
				local Alpha = Listener.GetAlpha(Data)

				Components.Name.Text = Name
				Components.Name.TextColor3 = NameColor

				Components.Name.Position = UDim2.new(0, ScreenPos.X, 0, ScreenPos.Y)
				Components.Name.Name = Name
				Components.Name.FontFace = Font
				Components.Name.TextSize = FontSize
				Components.Name.Visible = true

				if SmartESP then
					local CenterDist = Visuals.GetDistanceFromCenter(Position)
					local Fade = math.clamp(CenterDist / FadeRadius, 0, 1)
					Components.Name.TextTransparency = Fade
					Components.Name.UIStroke.Transparency = Fade
				else
					Components.Name.TextTransparency = Alpha
					Components.Name.UIStroke.Transparency = Alpha
				end
			end
		else
			Visuals.MiscSpace.Enabled = false
		end
	end),
	"Render"
)

local MainCharacterThread = Threads.New(
	"Character thread",
	phNV(function() LPH_ATTRIBUTES(VM(NONE)) 
		local Character = Client.Character
		local Root = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChild("Humanoid")
		if Humanoid and Root then

			local UndergroundCam = Library.Flags.Underground ~= nil and (Library.Flags.Underground and Library.Flags.Underground.Value)
			if
				((Library.Flags.ThirdPerson and Library.Flags.ThirdPerson.Value) and (Library.Flags["Third Person Activation"] and Library.Flags["Third Person Activation"].Active))
				or UndergroundCam
			then
				if UndergroundCam then
					Client.CameraMaxZoomDistance = 14
					Client.CameraMinZoomDistance = 6
				else
					Client.CameraMaxZoomDistance = (Library.Flags.ThirdPersonDistance and Library.Flags.ThirdPersonDistance.Value)
					Client.CameraMinZoomDistance = (Library.Flags.ThirdPersonDistance and Library.Flags.ThirdPersonDistance.Value)
				end
				Client.CameraMode = Enum.CameraMode.Classic

				if Library.Flags.AntiAim and not Library.Flags.AntiAim.Value then
					local LookVector = Camera.CFrame.LookVector
					local Flat = Vector3.new(LookVector.X, 0, LookVector.Z)
					if Flat.Magnitude > 0.001 then
						Globals.AntiAimAngle = CFrame.new(Root.Position, Root.Position + Flat.Unit)
						Root.CFrame = Globals.AntiAimAngle
						Humanoid.AutoRotate = false
					end
				end
			else
				Client.CameraMode = Enum.CameraMode.LockFirstPerson
				if not (Library.Flags.AntiAim and Library.Flags.AntiAim.Value) then
					Humanoid.AutoRotate = true
				end
			end

			if Library.Flags.AntiAim and Library.Flags.AntiAim.Value then

				local LookVector = Camera.CFrame.LookVector
				local Angle = -math.atan2(LookVector.Z, LookVector.X) + math.rad(-90)

				if (Library.Flags.YawBase and Library.Flags.YawBase.Value) == "Random" then
					Angle = -math.atan2(LookVector.Z, LookVector.X + math.rad(math.random(-180, 120)))
				elseif (Library.Flags.YawBase and Library.Flags.YawBase.Value) == "Spin" then
					local SpinSpeed = math.clamp(tonumber(Library.Flags.SpinSpeed and Library.Flags.SpinSpeed.Value) or 180, 1, 1440)
					Angle = -math.atan2(LookVector.Z, LookVector.X) + math.rad((tick() * SpinSpeed) % 360)
				elseif (Library.Flags.YawBase and Library.Flags.YawBase.Value) == "None" then
					Angle = -math.atan2(LookVector.Z, LookVector.X) + math.rad(-90)
				end

				local Offset = math.rad((Library.Flags.YawModifier and Library.Flags.YawModifier.Value))
				local Angled = CFrame.new(Root.Position) * CFrame.Angles(0, Angle + Offset, 0)

				if ((Library.Flags.YawBase and Library.Flags.YawBase.Value) == "Targets") and EntityClass.TargetPart then
					Angled = CFrame.new(Root.Position, EntityClass.TargetPart.Position) * CFrame.Angles(0, Offset, 0)
				end

				local _, Y, _ = Angled:ToOrientation()
				Globals.AntiAimAngle = CFrame.new(Angled.Position) * CFrame.Angles(0, Y, 0)

				Root.CFrame = Globals.AntiAimAngle
				Humanoid.AutoRotate = false

				local Pitch = (Library.Flags.PitchModifier and Library.Flags.PitchModifier.Value)
				local PitchBase = (Library.Flags.PitchBase and Library.Flags.PitchBase.Value)

				if PitchBase == "Down" then
					Pitch = 0.7
				elseif PitchBase == "Up" then
					Pitch = -0.7
				elseif PitchBase == "Nod" then
					Pitch = math.sin(tick() * 3 + math.random() * 0.4)
				elseif PitchBase == "Random" then
					Pitch = math.random() / 10
				end

				Pitch = math.clamp(Pitch, -0.7, 0.7)

				local TorsoController = Client.Character:FindFirstChild("TorsoController")
				local Look = TorsoController and TorsoController:FindFirstChild("Look")
				if Look then
					Look:FireServer(Pitch, 0)
				end

			else
				if
					Client.Character:FindFirstChild("CameraController")
					and not Client.Character.CameraController:GetAttribute("FreeLooking")
				then
					Humanoid.AutoRotate = true
				end
			end

			if (Library.Flags.Bunnyhop and Library.Flags.Bunnyhop.Value) then
				local Jump = Humanoid.Jump
				local FloorMaterial = Humanoid.FloorMaterial
				if tostring(FloorMaterial) ~= "Air" and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					Humanoid.Jump = true
				end
			end

			if
				Globals.DirectionTable
				and (Library.Flags.Omnisprint and Library.Flags.Omnisprint.Value)
				and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			then

				Globals.DirectionTable.Left, Globals.DirectionTable.Right, Globals.DirectionTable.Backward, Globals.DirectionTable.Crouch =
					false, false, false, false
				Globals.DirectionTable.Forward, Globals.DirectionTable.Sprint = true, true
				Globals.DirectionTable.BackwardLeft, Globals.DirectionTable.BackwardRight = false, false
				Globals.DirectionTable.ForwardLeft, Globals.DirectionTable.ForwardRight = false, false

				Humanoid.WalkSpeed = 19

				if Character:FindFirstChild("StateController") then
					Character.StateController:SetAttribute("IsSprint", true)
					Character.StateController:SetAttribute("Direction", "Forward")
				end
			end

			local IsFlying = (Library.Flags.Fly and Library.Flags.Fly.Value) and (Library.Flags["Fly Activation"] and Library.Flags["Fly Activation"].Value)
			if (Library.Flags.DebugCamera and Library.Flags.DebugCamera.Value) and (Library.Flags["Debug Camera Activation"] and Library.Flags["Debug Camera Activation"].Active) and not IsFlying then
				task.spawn(function()
					if not Globals.DebugStarted then
						Globals.DebugStarted = tick()
					end

					Globals.NeedToReturn = true

					local CameraLookVector = Camera.CFrame.LookVector
					local NormalCameraLookVector = CameraLookVector

					if not Globals.SavedPosition then
						Globals.SavedPosition = Humanoid.RootPart.CFrame
					end

					sethiddenproperty(Humanoid.RootPart, "NetworkIsSleeping", true)

					local UpPos = Vector3.new(0, 1, 0)
					local DownPos = Vector3.new(0, -1, 0)
					local NonePos = Vector3.new(0, 0, 0)

					local BaseCFrame = Humanoid.RootPart.CFrame
					local IsUpPressed = UserInputService:IsKeyDown(Enum.KeyCode.E)
					local IsDownPressed = UserInputService:IsKeyDown(Enum.KeyCode.Q)
					local IsForwardPressed = UserInputService:IsKeyDown(119)
					local IsBackwardPressed = UserInputService:IsKeyDown(115)

					Humanoid.RootPart.Anchored = true
					Humanoid.RootPart.Velocity = NonePos

					local Delta = Globals.Delta * (Library.Flags.DebugCameraSpeed and Library.Flags.DebugCameraSpeed.Value) * 3

					local MovementVector = (
						Humanoid.MoveDirection
						+ (IsUpPressed and UpPos or NonePos)
						+ (IsDownPressed and DownPos or NonePos)
						+ (IsForwardPressed and Vector3.new(0, NormalCameraLookVector.Y, 0) or NonePos)
						+ (IsBackwardPressed and Vector3.new(0, -NormalCameraLookVector.Y, 0) or NonePos)
					) * Delta

					BaseCFrame += MovementVector

					local Position = BaseCFrame.p
					Humanoid.RootPart.CFrame =
						CFrame.new(Position, Position + Vector3.new(CameraLookVector.X, 0, CameraLookVector.Z))
					Humanoid.AutoRotate = false
				end)
			else
				Globals.DebugStarted = nil
				if Globals.NeedToReturn then
					Humanoid.AutoRotate = true
					Globals.NeedToReturn = false
					sethiddenproperty(Humanoid.RootPart, "NetworkIsSleeping", false)

					for _, Value in pairs(Character:GetChildren()) do
						if Value:IsA("BasePart") then
							sethiddenproperty(Value, "NetworkIsSleeping", false)
						end
					end

					Humanoid.RootPart.CFrame = Globals.SavedPosition
					Humanoid.RootPart.Anchored = false
					Globals.SavedPosition = nil
				end
			end

		end
	end),
	"Character"
)

local CharacterHeartbeat = RunService.Heartbeat:Connect(phNV(function(Delta) LPH_ATTRIBUTES(VM(NONE)) 
	local Character = Client.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character and Character:FindFirstChild("Humanoid")

	local IsFlying
	if Humanoid and Root then

		if (Library.Flags.Fly and Library.Flags.Fly.Value) and (Library.Flags["Fly Activation"] and Library.Flags["Fly Activation"].Active) then
			task.spawn(function()
				IsFlying = true
				if Humanoid and Humanoid.Health > 0 then
					local Speed = (Library.Flags.FlySpeed and Library.Flags.FlySpeed.Value) * 3
					local MoveVector = Humanoid.MoveDirection

					if UserInputService:IsKeyDown(Enum.KeyCode.E) then
						MoveVector += Vector3.new(0, 1, 0)
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
						MoveVector += Vector3.new(0, -1, 0)
					end
					if UserInputService:IsKeyDown(119) then
						MoveVector += Vector3.new(0, Camera.CFrame.LookVector.Y, 0)
					end
					if UserInputService:IsKeyDown(115) then
						MoveVector += Vector3.new(0, -Camera.CFrame.LookVector.Y, 0)
					end

					-- Physics-based fly: drive the root by velocity only (no CFrame
					-- teleport, no forced rotation) so motion looks natural to the
					-- server and the character does not jitter or get rolled back.
					Humanoid.PlatformStand = false
					Root.AssemblyLinearVelocity = MoveVector * Speed
				end
			end)
		end

		if (Library.Flags.InfiniteFly and Library.Flags.InfiniteFly.Value) and IsFlying then
			local Origin = Root.Position
			local Result = Workspace:Raycast(Origin, Vector3.new(0, -1000, 0), Globals.RaycastParams)
			if Result and Result.Distance > 4 then
				task.spawn(function()
					local OldVel = Root.Velocity
					for _, Part in Character:GetChildren() do
						if Part:IsA("BasePart") or Part:IsA("MeshPart") then
							Part.Velocity = Vector3.new(0, -9999, 0)
						end
					end
					RunService.RenderStepped:Wait()
					for _, Part in Character:GetChildren() do
						if Part:IsA("BasePart") or Part:IsA("MeshPart") then
							Part.Velocity = OldVel
						end
					end
				end)
			end
		end

		if (Library.Flags.NoFall and Library.Flags.NoFall.Value) and not IsFlying then
			local Origin = Root.Position
			local Result = Workspace:Raycast(Origin, Vector3.new(0, -1000, 0), Globals.RaycastParams)

			if Result and Result.Distance > 10 then
				task.spawn(function()
					local OldVel = Root.Velocity
					for _, Part in Character:GetChildren() do
						if Part:IsA("BasePart") or Part:IsA("MeshPart") then
							Part.Velocity = Vector3.new(0, 9999, 0)
						end
					end
					RunService.RenderStepped:Wait()
					for _, Part in Character:GetChildren() do
						if Part:IsA("BasePart") or Part:IsA("MeshPart") then
							Part.Velocity = OldVel
						end
					end
				end)
			end
		end

		if Library.Flags.SpeedEnabled and Library.Flags.SpeedEnabled.Value then
			Humanoid.WalkSpeed = math.clamp((Library.Flags.SpeedValue and Library.Flags.SpeedValue.Value), 4, 100)
			Globals.SpeedApplied = true
		elseif Globals.SpeedApplied then
			Globals.SpeedApplied = nil
			Humanoid.WalkSpeed = 19
		end

		if Library.Flags.Underground and Library.Flags.Underground.Value then
			local Depth = math.clamp(Library.Flags.UndergroundDepth and Library.Flags.UndergroundDepth.Value or 8, 2, 40)

			local SurfaceParams = RaycastParams.new()
			SurfaceParams.FilterType = Enum.RaycastFilterType.Blacklist
			SurfaceParams.FilterDescendantsInstances = { Character }

			local SurfaceRay = Workspace:Raycast(
				Vector3.new(Root.Position.X, Root.Position.Y + 500, Root.Position.Z),
				Vector3.new(0, -2000, 0),
				SurfaceParams
			)
			local SurfaceY = SurfaceRay and SurfaceRay.Position.Y or (Root.Position.Y + Depth)

			Root.CFrame = CFrame.new(Root.Position.X, SurfaceY - Depth, Root.Position.Z) * Root.Rotation

			local CamPart = Globals.UndergroundCamPart
			if not (CamPart and CamPart.Parent) then
				CamPart = Instance.new("Part")
				CamPart.Name = "BurmaldaCamAnchor"
				CamPart.Size = Vector3.new(1, 1, 1)
				CamPart.Transparency = 1
				CamPart.Anchored = true
				CamPart.CanCollide = false
				CamPart.CanQuery = false
				CamPart.CanTouch = false
				CamPart.CastShadow = false
				CamPart.Parent = Workspace
				Globals.UndergroundCamPart = CamPart
			end
			CamPart.CFrame = CFrame.new(Root.Position.X, SurfaceY + 3, Root.Position.Z)
			if Camera.CameraSubject ~= CamPart then
				pcall(function()
					Camera.CameraSubject = CamPart
				end)
			end
		elseif Globals.UndergroundCamPart then
			if Camera.CameraSubject == Globals.UndergroundCamPart then
				pcall(function()
					Camera.CameraSubject = Humanoid
				end)
			end
			Globals.UndergroundCamPart:Destroy()
			Globals.UndergroundCamPart = nil
		end

	end
end))

Log("Loaded threads.")

RunService.RenderStepped:Connect(phNV(function(Delta) LPH_ATTRIBUTES(VM(NONE)) 
	Globals.Delta = Delta

	for Index, Thread in Threads.Input do
		local Error = Thread:Run()
	end

	for Index, Thread in Threads.Entities do
		local Error = Thread:Run()
	end

	for Index, Thread in Threads.Character do
		local Error = Thread:Run()
	end

	for Index, Thread in Threads.Render do
		local Error = Thread:Run()
	end
end))

Log("Loaded run service connections")

local Modules = ReplicatedStorage:FindFirstChild("Modules")
if not Modules then

	Modules = ReplicatedStorage:WaitForChild("Modules", 30)
end

if not ReplicatedStorage:FindFirstChild("ClientSignals") then
	local Signals = Instance.new("Folder")
	Signals.Name = "ClientSignals"
	Signals.Parent = ReplicatedStorage
end

local RaycastModule = Modules and (Modules:FindFirstChild("roosterchickens") or Modules:FindFirstChild("RaycastUtil"))

if
	Modules
	and Modules:FindFirstChild("VFXModule")
	and Modules:FindFirstChild("Items")
	and RaycastModule
	and Modules:FindFirstChild("SoundModule")
then
	local VFX = require(Modules.VFXModule)
	local ItemsModule = require(Modules.Items)
	local RaycastUtil = require(RaycastModule)
	local SoundModule = require(Modules.SoundModule)

	local HitEvent = Instance.new("BindableEvent", ReplicatedStorage.ClientSignals)
	local TracerEvent = Instance.new("BindableEvent", ReplicatedStorage.ClientSignals)

	TracerEvent.Event:Connect(function(Origin, Destination, IsEnemy)
		local Color = (not IsEnemy and Library.Flags.TracerColor.Value[1]) or Library.Flags.EnemyTracerColor.Value[1]
		local TracerModel = Instance.new("Model", Workspace)
		TracerModel.Name = "TracerModel"

		local function CreateAnchorPart(position)
			local part = Instance.new("Part")
			part.Name = "Anchor"
			part.Size = Vector3.new(0.0001, 0.0001, 0.0001)
			part.Position = position
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Transparency = 1
			part.Parent = TracerModel
			return part
		end

		local Part0 = CreateAnchorPart(Origin)
		local Part1 = CreateAnchorPart(Origin)

		local Attachment0 = Instance.new("Attachment", Part0)
		local Attachment1 = Instance.new("Attachment", Part1)

		local Beam = Instance.new("Beam")
		Beam.Name = "MainBeam"
		Beam.Attachment0 = Attachment0
		Beam.Attachment1 = Attachment1
		Beam.FaceCamera = true
		Beam.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.0, Color),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1.0, Color),
		})
		Beam.Width0 = 0.3
		Beam.Width1 = 0.3
		Beam.LightEmission = 1
		Beam.LightInfluence = 0
		Beam.Brightness = Library.Flags.TracerBrightness.Value
		Beam.Texture = "rbxassetid://12788927812"
		Beam.TextureLength = 10
		Beam.TextureMode = Enum.TextureMode.Wrap
		Beam.TextureSpeed = 1
		Beam.Parent = TracerModel
		local TextureType = Library.Flags.BeamTexture.Value
		local Beam2, Beam3

		if TextureType == "Lightning" then
			Beam.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0),
			})
			Beam.Texture = "rbxassetid://12781800668"
			Beam.TextureLength = 4
			Beam.TextureSpeed = 10
			Beam.Width0 = 0.5
			Beam.Width1 = 0.5

			local SpeedTween = TweenService:Create(
				Beam,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 2, true),
				{
					TextureSpeed = 2,
				}
			)
			SpeedTween:Play()
		elseif TextureType == "Dark" then
			Beam.Texture = "rbxassetid://12781848822"
			Beam.TextureLength = 20
			Beam.TextureSpeed = 0.9
			Beam.TextureMode = Enum.TextureMode.Static
			Beam.LightInfluence = 1
			Beam.LightEmission = 0.25
			Beam.Width0 = 0.5
			Beam.Width1 = 0.5

			Beam2 = Beam:Clone()
			Beam2.Name = "DarkBeam2"
			Beam2.Parent = TracerModel
			Beam2.Attachment0 = Attachment0
			Beam2.Attachment1 = Attachment1

			Beam3 = Beam:Clone()
			Beam3.Name = "DarkBeam3"
			Beam3.Parent = TracerModel
			Beam3.Attachment0 = Attachment0
			Beam3.Attachment1 = Attachment1
		end

		local ReferenceDistance = 30
		local ReferenceTime = ReferenceDistance / Library.Flags.ReferenceTime.Value
		local Distance = (Destination - Origin).Magnitude
		local TravelTime = (Distance / ReferenceDistance) * ReferenceTime

		local MoveTween = TweenService:Create(Part1, TweenInfo.new(TravelTime, Enum.EasingStyle.Linear), {
			Position = Destination,
		})
		MoveTween:Play()

		local PulseTween =
			TweenService:Create(Beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true), {
				Width0 = 0.35,
				Width1 = 0.35,
			})
		PulseTween:Play()

		Delay(Library.Flags.TracerLifetime.Value, function()
			local FadeTween = TweenService:Create(Beam, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				Width0 = 0,
				Width1 = 0,
				TextureSpeed = 0,
				Brightness = 0,
			})
			FadeTween:Play()

			if Beam2 and Beam3 then
				local Fade2 = TweenService:Create(Beam2, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
					Width0 = 0,
					Width1 = 0,
					TextureSpeed = 0,
					Brightness = 0,
				})
				local Fade3 = TweenService:Create(Beam3, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
					Width0 = 0,
					Width1 = 0,
					TextureSpeed = 0,
					Brightness = 0,
				})
				Fade2:Play()
				Fade3:Play()
			end

			FadeTween.Completed:Wait()
			TracerModel:Destroy()
		end)
	end)

	HitEvent.Event:Connect(phNV(function(HitData) LPH_ATTRIBUTES(VM(NONE)) 
		if Library.Flags.Hitmarkers.Value then
			local HitPart = HitData[1]
			local HitPos = HitData[2]
			local HitMaterial = HitData[4]

			if HitMaterial == Enum.Material.Plastic then
				Visuals.CreateHitmarker(HitPart, HitPos)
			end
		end
	end))

	local RaidEvent = Instance.new("BindableEvent", ReplicatedStorage.ClientSignals)
	RaidEvent.Event:Connect(phNV(function(Type, CFrame) LPH_ATTRIBUTES(VM(NONE)) 
		local Time = tick()

		local Part = Instance.new("Part", CoreGui.Raids)
		Part.CanCollide = false
		Part.CanQuery = false
		Part.CanTouch = false
		Part.Transparency = 1
		Part.CFrame = CFrame
		Part.Name = Type

		local StartedAt = Instance.new("IntValue", Part)
		StartedAt.Name = "StartedAt"
		StartedAt.Value = Time
		Part:SetAttribute("StartedAt", Time)
		Part:SetAttribute("Type", Type)

		Delay(600, function()
			Part:Destroy()
		end)

		if Library.Flags.RaidNotifications.Value then
			local Pos = CFrame.p
			local Coordinates = tostring(math.floor(Pos.X))
				.. ", "
				.. tostring(math.floor(Pos.Y))
				.. ", "
				.. tostring(math.floor(Pos.Z))
			Library:Notify(
				"A potential raid has started using " .. Type .. " at " .. Coordinates,
				10,
				Library.Flags.RaidsMiscColor.Value[1]
			)
		end
	end))

	local InitHooks = phJITX(function() LPH_ATTRIBUTES(VM(NONE)) 
		local CreateProjectile
		CreateProjectile = hookfunction(
			VFX.CreateProjectile,
			phNUV(function(self, ...) LPH_ATTRIBUTES(VM(NONE)) 
				local Args = { ... }

				do
					local A1 = Args[1]
					if type(A1) == "table" and type(A1.Speed) == "number" and A1.Speed > 1 then
						Globals.BulletStats = { speed = A1.Speed, gravity = tonumber(A1.Gravity) or 0, range = tonumber(A1.MaxRange) or 1000 }
					end
				end

				local VMsFolder = Workspace:FindFirstChild("VFX") and Workspace.VFX:FindFirstChild("VMs")
				local CurrentVM = VMsFolder and VMsFolder:GetChildren()[1]
				local VMName = CurrentVM and CurrentVM.Name or ""
				local IsBowProjectile = VMName:lower():find("bow", 1, true) ~= nil
				if IsBowProjectile then
					return CreateProjectile(self, ...)
				end

				local FromCombatController
				do
					local OkCaller, Caller = pcall(getcallingscript)
					if OkCaller and typeof(Caller) == "Instance" then
						local CallerName = Caller.Name
						FromCombatController = CallerName:find("ViewmodelController") ~= nil
							or CallerName:find("VFXController") ~= nil
					else
						local Traceback = debug.traceback()
						FromCombatController = Traceback:find("ViewmodelController") ~= nil
							or Traceback:find("VFXController") ~= nil
					end
				end
				if
					type(Args[1]) == "table"
					and FromCombatController
					and Args[1].StepFunction ~= "FakeStepFunc"
					and Args[1].HitFunction ~= "FakeHitFunc"
					and not tostring(Args[1].HitFunction):find("Ignore")
				then


				if
					type(debug.getstack) == "function"
					and type(debug.setstack) == "function"
				then
						local HitFunction
						HitFunction = Args[1].HitFunction
						Args[1].HitFunction = function(...)
							local Arguments = { ... }

							HitEvent:Fire(Arguments)
							return HitFunction(...)
						end

					local Stack, StackLevel, Recoil = {}, 0, nil
					local FallbackStack, FallbackLevel = nil, 0
					for Level = 2, 8 do
						local Ok, Candidate = pcall(debug.getstack, Level)
						if Ok and type(Candidate) == "table" then
							local CFrameCount, VectorCount, LevelRecoil = 0, 0, nil
							for Index = 1, 120 do
								local Value = rawget(Candidate, Index)
								local ValueType = typeof(Value)
								if ValueType == "CFrame" then
									CFrameCount += 1
								elseif ValueType == "Vector3" then
									VectorCount += 1
								elseif
									ValueType == "table"
									and rawget(Value, "RecoilStart")
									and rawget(Value, "RecoilFinish")
								then
									LevelRecoil = Value
								end
							end
							if LevelRecoil and CFrameCount >= 2 then
								Stack, StackLevel, Recoil = Candidate, Level, LevelRecoil
								break
							end
							if not FallbackStack and CFrameCount >= 2 and VectorCount >= 1 then
								FallbackStack, FallbackLevel = Candidate, Level
							end
						end
					end
					if not Recoil and FallbackStack then
						Stack, StackLevel = FallbackStack, FallbackLevel
					end

					if Recoil and (Library.Flags.RemoveRecoil and Library.Flags.RemoveRecoil.Value) then
						pcall(function()
							Recoil.RecoilStart = function(...)
								return 0, 0
							end

							Recoil.RecoilFinish = function(...)
								return 0, 0
							end

							if type(Recoil.Shake) == "table" then
								Recoil.Shake.X = { 0, 0 }
								Recoil.Shake.Y = { 0, 0 }
							end
						end)
					end

						local CameraStackIndex, HRPStackIndex, FlashpartStackIndex

						for Index = 1, 80 do
							local Value = rawget(Stack, Index)
							local ValueType = typeof(Value)

							if ValueType == "CFrame" then
								if not CameraStackIndex then
									CameraStackIndex = Index
								elseif not HRPStackIndex then
									HRPStackIndex = Index
								end
							elseif ValueType == "Vector3" and not FlashpartStackIndex then
								FlashpartStackIndex = Index
							end
						end

						local CameraStack = CameraStackIndex and rawget(Stack, CameraStackIndex)
						local HRPStack = HRPStackIndex and rawget(Stack, HRPStackIndex)
						local FlashpartStack = FlashpartStackIndex and rawget(Stack, FlashpartStackIndex)
						local MouseHitStack = HRPStack

					do
						local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
						if
							(CameraStack and (CameraStack.p - Camera.CFrame.p).Magnitude > 60)
							or (HRPStack and RootPart and (HRPStack.p - RootPart.CFrame.p).Magnitude > 60)
						then
							CameraStack, HRPStack, FlashpartStack, MouseHitStack = nil, nil, nil, nil
						end
					end

						if
							typeof(CameraStack) ~= "CFrame"
							or typeof(HRPStack) ~= "CFrame"
							or typeof(FlashpartStack) ~= "Vector3"
						then
							CameraStack, HRPStack, FlashpartStack, MouseHitStack = nil, nil, nil, nil
						end

						if
							CameraStack
							and FlashpartStack
							and HRPStack
							and MouseHitStack
							and EntityClass.TargetPart
							and (Library.Flags.SilentAim and Library.Flags.SilentAim.Value)
						then
							local HitPosition = EntityClass.TargetPart.CFrame.p
							local CameraPosition = CameraStack.p

							if (Library.Flags.InstantBullet and Library.Flags.InstantBullet.Value) then
								local Speed, Gravity = Args[1].Speed, Args[1].Gravity
								local InstantOrigin = typeof(Args[1].Position) == "Vector3" and Args[1].Position or Camera.CFrame.Position
								local Distance = (HitPosition - InstantOrigin).Magnitude
								local TimeToHit = Distance / Speed

								local G = Gravity * -Workspace.Gravity
								local Drop = -0.5 * G * TimeToHit * TimeToHit
								if tostring(Drop):find("nan") then
									Drop = 0
								end

								HitPosition = HitPosition + Vector3.new(0, Drop, 0)
							end

							local FakeCameraCFrame = CFrame.new(CameraPosition, HitPosition)
							local FakeHRPCFrame = CFrame.new(HRPStack.p, HitPosition)

							local OriginalFlashOffset = FlashpartStack - CameraPosition
							local NewFlashpartPosition = CFrame.new(FlashpartStack, HitPosition).p

							if EntityClass.ManipulatedPosition then
								NewFlashpartPosition = CFrame.new(EntityClass.ManipulatedPosition, HitPosition).p

								local FlashpartOffsetCamera = CameraPosition - FlashpartStack
								local FlashpartOffsetHRP = HRPStack.p - FlashpartStack

								local NewCameraPos = NewFlashpartPosition + FlashpartOffsetCamera
								local NewHRPPos = NewFlashpartPosition + FlashpartOffsetHRP

								FakeCameraCFrame = CFrame.new(NewCameraPos, HitPosition)
								FakeHRPCFrame = CFrame.new(NewHRPPos, HitPosition)
							end

							pcall(debug.setstack, StackLevel, CameraStackIndex, FakeCameraCFrame)
							pcall(debug.setstack, StackLevel, HRPStackIndex, FakeHRPCFrame)
							pcall(debug.setstack, StackLevel, FlashpartStackIndex, NewFlashpartPosition)
						end

						if (Library.Flags.ShootOnTP and Library.Flags.ShootOnTP.Value) and (Library.Flags["Teleport Activation"] and Library.Flags["Teleport Activation"].Active) then
							local TPRoot = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
							if TPRoot then
								TPRoot.CFrame = Mouse.Hit
							end
						end
					end

					if (Library.Flags.InstantBullet and Library.Flags.InstantBullet.Value) then
						Args[1].Speed = 9e9
					end

					if (Library.Flags.ForcePenetration and Library.Flags.ForcePenetration.Value) or (Library.Flags.HitScan and Library.Flags.HitScan.Value) or (Library.Flags.WallbangPlus and Library.Flags.WallbangPlus.Value) then
						Args[1].RangeMult = 2
						Args[1].Filters = addPen(Args[1].Filters)
						if type(Args[1].FilterFunction) == "function" then
							local prevFF = Args[1].FilterFunction
							Args[1].FilterFunction = function(inst)
								if isBody(inst) then
									return nil
								end
								local skip = prevFF(inst)
								if skip then
									return skip
								end
								return inst
							end
						end
					end

					if
						EntityClass.TargetPart
						and EntityClass.TargetPart.Parent
						and (Library.Flags.SilentAim and Library.Flags.SilentAim.Value)
					then
						local TargetPart = EntityClass.TargetPart
						local HitPosition = TargetPart.CFrame.p
						do
							local Hum = TargetPart.Parent and TargetPart.Parent:FindFirstChildOfClass("Humanoid")
							local okR, Resolved = pcall(Globals.ResolveAimPoint, TargetPart, Hum)
							if okR and typeof(Resolved) == "Vector3" then HitPosition = Resolved end
						end
						local Origin = Args[1].Position
						if typeof(Origin) ~= "Vector3" then
							Origin = Camera.CFrame.Position
						end

						local Manip = EntityClass.ManipulatedPosition
						local FromPoint = (typeof(Manip) == "Vector3" and Manip) or Origin

						local AimPosition = HitPosition
						do
							local Speed = tonumber(Args[1].Speed)
							local Gravity = tonumber(Args[1].Gravity)
							local InstantFlight = Library.Flags.InstantBullet and Library.Flags.InstantBullet.Value

							if not InstantFlight and type(Speed) == "number" and Speed > 1 and type(Gravity) == "number" and Gravity > 0.01 then
								local FlyTime = (HitPosition - FromPoint).Magnitude / Speed
								local Drop = 0.5 * Workspace.Gravity * Gravity * FlyTime * FlyTime
								if tostring(Drop):find("nan") then
									Drop = 0
								end
								local DropMult = tonumber(Library.Flags.DropMultiplier and Library.Flags.DropMultiplier.Value) or 1
								AimPosition = HitPosition + Vector3.new(0, Drop * DropMult, 0)

								local PredictionMult = tonumber(Library.Flags.Prediction and Library.Flags.Prediction.Value) or 1
								if PredictionMult > 0 then
									local Hum = TargetPart.Parent and TargetPart.Parent:FindFirstChildOfClass("Humanoid")
									local okV, Velocity = pcall(Globals.ResolveVelocity, TargetPart, Hum)
									if not okV or typeof(Velocity) ~= "Vector3" then
										local VelPart = TargetPart.Parent and TargetPart.Parent:FindFirstChild("HumanoidRootPart")
										Velocity = (VelPart and VelPart.AssemblyLinearVelocity) or TargetPart.AssemblyLinearVelocity
									end
									if typeof(Velocity) == "Vector3" then
										AimPosition += Vector3.new(Velocity.X, Velocity.Y, Velocity.Z) * FlyTime * PredictionMult
									end
								end
							end
						end

						local PenetrationActive = Library.Flags.ForcePenetration and Library.Flags.ForcePenetration.Value
						local HitScanActive = Library.Flags.HitScan and Library.Flags.HitScan.Value
						local WallbangActive = Library.Flags.WallbangPlus and Library.Flags.WallbangPlus.Value

						if clearLos(FromPoint, HitPosition) or PenetrationActive or HitScanActive or WallbangActive then
							local Direction = AimPosition - FromPoint
							if Direction.Magnitude > 0.05 then
								Direction = Direction.Unit
								local ShotDistance = (HitPosition - FromPoint).Magnitude
								local StockRange = tonumber(Args[1].MaxRange)
								if type(StockRange) == "number" and StockRange < ShotDistance + 100 then
									Args[1].MaxRange = ShotDistance + 100
								end

								Args[1].Direction = Direction
								Args[1].DirectionFirst = Direction
								if typeof(Manip) == "Vector3" then
									Args[1].Position = Manip
									if Args[1].PositionFirst then
										Args[1].PositionFirst = Manip
									end
								end
								Globals.BulletOrigin = FromPoint
							end

							if not IsBowProjectile and (Library.Flags.PacketSilent == nil or Library.Flags.PacketSilent.Value) then
								TTHShot = {
									dest = HitPosition,
									manip = EntityClass.ManipulatedPosition,
									t = os.clock(),
								}
							end
						end
					end
				end

				task.spawn(function()
					if
						Library.Flags.BulletTracers.Value
						and (Args[1].Position - Camera.CFrame.Position).Magnitude < 1200
					then
						local IsEnemy = (
							Args[1].StepFunction == "FakeStepFunc"
							or Args[1].HitFunction == "FakeHitFunc"
							or tostring(Args[1].HitFunction):find("Ignore")
						)

						if IsEnemy and not Library.Flags.ShowEnemyTracers.Value then
							return
						end

						local Ray = Workspace:Raycast(
							Args[1].Position,
							Args[1].Direction * Args[1].MaxRange,
							Globals.RaycastParams
						)

						if Ray and Ray.Position then
							TracerEvent:Fire(Args[1].Position, Ray.Position, IsEnemy)
						end
					end
				end)
				return CreateProjectile(self, unpack(Args))
			end)
		)

		Log("Initialized projectiles.")

		local CreateExplosion
		CreateExplosion = hookfunction(
			VFX.CreateExplosion,
			phNUV(function(...) LPH_ATTRIBUTES(VM(NONE)) 
				local Arguments = { ... }

				local Type = tostring(Arguments[5])
				local CFrame = Arguments[2]

				task.spawn(function()
					RaidEvent:Fire(Type, CFrame)
				end)

				return CreateExplosion(...)
			end)
		)

		Log("Initialized raids")

		local OldRaycast
		OldRaycast = hookfunction(
			RaycastUtil.Raycast,
			phNUV(function(self, ...) LPH_ATTRIBUTES(VM(NONE)) 
				local Arguments = { ... }

				if not checkcaller() then
					local Traceback = debug.traceback()

					if Traceback and (Traceback:find("ViewmodelController") or Traceback:find("VFXController")) and (Library.Flags.Reach and Library.Flags.Reach.Value) then
						Arguments[2] = Arguments[2] * 10
					end

					if (Library.Flags.PerfectFarm and Library.Flags.PerfectFarm.Value) then
						local Output = { OldRaycast(self, ...) }
						local HitInstance = Output[1]
						local HitPosition = Output[2]

						if not HitInstance or typeof(HitInstance) ~= "Instance" then
							return unpack(Output)
						end

						if not HitPosition or typeof(HitPosition) ~= "Vector3" then
							return unpack(Output)
						end

						local Model = HitInstance.Parent

						if not Model or (not Model:IsA("Model")) then
							return unpack(Output)
						end

						local Folder = Model.Parent

						if Folder and (Folder.Name == "Trees" or Folder.Name == "Nodes") and Folder:IsA("Folder") then
							local CriticalPart = Model:FindFirstChild("NodeSpark") or Model:FindFirstChild("TreeX")
							if
								CriticalPart
								and typeof(CriticalPart) == "Instance"
								and CriticalPart:IsA("Model")
								and CriticalPart.PrimaryPart
							then
								Output[1] = CriticalPart.PrimaryPart
								return unpack(Output)
							end
						end
					end
				end
				return OldRaycast(self, unpack(Arguments))
			end)
		)

		Log("Initialized raycast")

		local ToggleFootstep
		ToggleFootstep = hookfunction(
			SoundModule.ToggleFootstep,
			phNUV(function(...) LPH_ATTRIBUTES(VM(NONE)) 
				local Arguments = { ... }

				if Library.Flags.SilentStep.Value and Arguments[3] then
					return SoundModule:StopSound(Arguments[3])
				end

				return ToggleFootstep(...)
			end)
		)

		local PlaySound
		PlaySound = hookfunction(
			SoundModule.PlaySound,
			phNUV(function(...) LPH_ATTRIBUTES(VM(NONE)) 
				local Arguments = { ... }
				if Library.Flags.SilentStep.Value and Arguments[2] and Arguments[2].Name == "WalkWater" then
					return SoundModule:StopSound(Arguments[2])
				end

				return PlaySound(...)
			end)
		)

		Log("Initialized sounds")

		if type(__VU) == "table" and type(__VU.FireRemote) == "function" then
			local oldFireRemote
			oldFireRemote = hookfunction(
				__VU.FireRemote,
				phNUV(function(self, ...) LPH_ATTRIBUTES(VM(NONE)) 
					local args = { ... }
					local ss = TTHShot
					if ss and typeof(ss.dest) == "Vector3" and os.clock() - ss.t < 0.25 then
						local payload = nil
						for i = #args, 1, -1 do
							local p = args[i]
							if
								type(p) == "table" and #p >= 8
								and typeof(p[2]) == "string"
								and typeof(p[3]) == "CFrame"
								and typeof(p[4]) == "Vector3"
								and typeof(p[5]) == "CFrame"
								and typeof(p[8]) == "Vector3"
							then
								payload = p
								break
							end
						end
						if payload then
						local aim8 = ss.dest
						local moved = ss.manip
						local hasMove = typeof(moved) == "Vector3"
						if hasMove and ((moved - aim8).Magnitude > 30 or not clearLos(moved, aim8)) then
							hasMove = false
						end
						if hasMove and (os.clock() - (Globals.lastMoveShot or 0) < 0.5) then
							hasMove = false
						end
						local blocked = not clearLos(payload[3].Position, aim8)
						if not (blocked and not hasMove) then
							if hasMove then
								local raw4 = payload[4]
								payload[5] = flatRoot(moved, aim8) * CFrame.new(-raw4)
								payload[3] = CFrame.new(payload[3].Position, aim8)
								Globals.lastMoveShot = os.clock()
							else
								payload[3] = CFrame.new(payload[3].Position, aim8)
								payload[5] = flatRoot(payload[5].Position, aim8)
							end
							payload[8] = aim8
						end
						end
					end
					TTHShot = nil
					return oldFireRemote(self, unpack(args))
				end)
			)
			Log("Initialized packet layer")
		end
		Log("Primary hooks initialized!")
	end)

	if getgenv().__IriShieldOK then
		InitHooks()
	end

	local HooksOnCharacterAdded = phJITX(function() LPH_ATTRIBUTES(VM(NONE)) 
		Globals.QuickStackFunctions = {}
		for _, Function in getgc(false) do
			if type(Function) ~= "function" then
				continue
			end
			if not islclosure(Function) then
				continue
			end
			if isexecutorclosure(Function) then
				continue
			end
			if isfunctionhooked(Function) then
				continue
			end

			local Constants = debug.getconstants(Function)
			local Upvalues = debug.getupvalues(Function)
			local Info = debug.getinfo(Function)
			local Source = Info.source

			if Source:find("ViewmodelController") then
				if table.find(Constants, "CameraOffset") then
					local Old
					Old = hookfunction(
						Function,
						phNUV(function(...) LPH_ATTRIBUTES(VM(NONE)) 
							if Library.Flags.RemoveCameraBobbing.Value then
								return
							end

							return Old(...)
						end)
					)
				end

				if table.find(Constants, "Landed") then
					local Old
					Old = hookfunction(
						Function,
						phNUV(function(OldState, NewState) LPH_ATTRIBUTES(VM(NONE)) 
							if (Library.Flags.AlwaysGrounded and Library.Flags.AlwaysGrounded.Value) then
								OldState = Enum.HumanoidStateType.Running
								NewState = Enum.HumanoidStateType.Running
							end

							return Old(OldState, NewState)
						end)
					)
				end

				if Constants[20] == "CreateBlood" then
					local Networking = debug.getupvalue(Function, 1)

					Globals.VMNetworkPointer = Networking
				end
			end

			if Source:find("InventoryController") then
				local Upvalues = debug.getupvalues(Function)
				if type(Upvalues[1]) == "table" and type(Upvalues[2]) == "table" and type(Upvalues[3]) == "table" then
					local Old
					Old = hookfunction(
						Function,
						phNUV(function(...) LPH_ATTRIBUTES(VM(NONE)) 

							local InventoryTable, _, _2 = Old(...)

							local Toolbar = type(InventoryTable) == "table" and InventoryTable.Toolbar
							if Toolbar and Library.Flags.SkinChanger.Value then
								for ItemIndex, ItemData in Toolbar do
									if type(ItemData) ~= "table" then
										continue
									end

									local ItemInfo = ItemData.ID and ItemsModule[ItemData.ID]
									if not (ItemInfo and ItemInfo.Name) then
										continue
									end

									local ItemName = ItemInfo.Name
									local SKIN = Library.Flags["EnableSkin_" .. ItemName]
									local SkinFlag = Library.Flags["Skin_" .. ItemName]
									if SKIN and SKIN.Value and SkinFlag then
										ItemData.Skin = SkinFlag.Value
									else
										continue
									end
								end
							end

							return InventoryTable, _, _2
						end)
					)
				end

				if Constants[1] == "ArmorEquip" and Constants[5] == "GetAttribute" then
					if (Library.Flags.InstantLoot and Library.Flags.InstantLoot.Value) then
						debug.setconstant(Function, 19, 0)
						debug.setconstant(Function, 20, 0)
						debug.setconstant(Function, 21, 0)
					end
					table.insert(Globals.QuickStackFunctions, Function)
				end
			end

			if Source:find("StateController") then
				if table.find(Constants, "Forward") then
					if
						type(Upvalues[1]) == "table" and (Upvalues[1].Forward == false or Upvalues[1].Forward == true)
					then
						Globals.DirectionTable = debug.getupvalue(Function, 1)
					end
				end
			end

			if Info.source:find("BuildController") then
				if type(Upvalues[16]) == "function" then
					local BuildEvent = debug.getupvalue(Function, 16)
					Globals.BuildingNetworkPointer = BuildEvent
				end
			end
		end

		repeat
			task.wait()
		until Client.Character ~= nil
		local Character = Client.Character
		local StateController = Character:WaitForChild("StateController", 5)

		if StateController then
			StateController:GetAttributeChangedSignal("IsSprint"):Connect(function()
				if (Library.Flags.Omnisprint and Library.Flags.Omnisprint.Value) and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					StateController:SetAttribute("IsSprint", true)
				end
			end)

			StateController:GetAttributeChangedSignal("Direction"):Connect(function()
				if (Library.Flags.Omnisprint and Library.Flags.Omnisprint.Value) and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					StateController:SetAttribute("Direction", "Forward")
				end
			end)
		end
	end)

	repeat
		task.wait()
	until Client.Character

	HooksOnCharacterAdded()

	Client.CharacterAdded:Connect(function()
		task.wait(3)
		HooksOnCharacterAdded()
	end)
end
Log("All hooks loaded!")

do
	if getgenv().__IriShieldOK then
		local ToolInfo = Globals.ToolInfo or {}
		local IriWM = { oldRPM = {}, oldRange = {}, oldCD = {}, oldAnim = {}, hooked = {} }

		local function applyWeaponBoosts()
			for W, v in pairs(IriWM.oldRPM) do
				pcall(function()
					W.RPM = v
				end)
			end
			for W, v in pairs(IriWM.oldRange) do
				pcall(function()
					W.Range = v
				end)
			end
			for W, v in pairs(IriWM.oldCD) do
				pcall(function()
					W.Cooldown = v
				end)
			end
			for W, v in pairs(IriWM.oldAnim) do
				pcall(function()
					W.SwingAnimSpeed = v
				end)
			end

			local rpm = Library.Flags.RPMBoost and Library.Flags.RPMBoost.Value or 1
			local rng = Library.Flags.MeleeRangeBoost and Library.Flags.MeleeRangeBoost.Value or 1
			local cd = Library.Flags.CooldownBoost and Library.Flags.CooldownBoost.Value or 1
			local fastOn = Library.Flags.FastCooldown and Library.Flags.FastCooldown.Value or false
			local fastHitOn = Library.Flags.FastHit and Library.Flags.FastHit.Value or false

			if getgenv().IriNoBoosts == true then
				return
			end
			if rpm <= 1.0001 and rng <= 1.0001 and not fastOn and not fastHitOn then
				return
			end
			for name, Value in pairs(ToolInfo) do
				if type(Value) == "table" and rawget(Value, "Weapon") then
					local W = Value.Weapon
					if type(W) == "table" then
						local origRPM = IriWM.oldRPM[W] or rawget(W, "RPM")
						local origRange = IriWM.oldRange[W] or rawget(W, "Range")
						if type(origRPM) == "number" then
							IriWM.oldRPM[W] = origRPM
							pcall(function()
								W.RPM = origRPM * rpm
							end)
						end
						if type(origRange) == "number" then
							IriWM.oldRange[W] = origRange
							pcall(function()
								W.Range = origRange * rng
							end)
						end
						local isMelee = type(rawget(Value, "Melee")) == "table"
						local fhCap = FastHitCaps[name] or 1.3
						local origCD = IriWM.oldCD[W] or rawget(W, "Cooldown")
						if type(origCD) == "number" then
							IriWM.oldCD[W] = origCD
							pcall(function()
								W.Cooldown = fastOn and (origCD / cd) or (fastHitOn and isMelee and (origCD / fhCap)) or origCD
							end)
						end
						if fastHitOn and isMelee then
							local origAnim = IriWM.oldAnim[W] or rawget(W, "SwingAnimSpeed")
							if type(origAnim) == "number" then
								IriWM.oldAnim[W] = origAnim
								pcall(function()
									W.SwingAnimSpeed = origAnim * fhCap
								end)
							end
						end
					end
				end
			end
		end

		task.spawn(function()
			while true do
				pcall(applyWeaponBoosts)
				task.wait(3)
			end
		end)

		task.spawn(function()
			if getgenv().IriNoBolt == true then
					return
			end
			local attempts = 0
			while true do
				attempts += 1
				if attempts > 12 then
					return
				end
				local hooked = 0
				for _, v in getgc(true) do
					if typeof(v) == "function" and not IriWM.hooked[v] then
						local ok, info = pcall(debug.getinfo, v)
						if ok and info and info.name == "PlayAnimation" then
							IriWM.hooked[v] = true
							local old
							pcall(function()
								old = hookfunction(v, function(animation_name, ...)
									local output = { old(animation_name, ...) }
									if
										animation_name == "Bolt"
										and Library.Flags.InstantBolt
										and (Library.Flags.InstantBolt and Library.Flags.InstantBolt.Value)
									then
										return { Length = 0.015 }
									end
									return table.unpack(output)
								end)
							end)
							hooked += 1
						end
					end
				end
				if hooked > 0 then
					break
				end
				task.wait(5)
			end
		end)

	end
end

task.delay(6, function()
	local function state(v)
		return v and "OK" or "MISSING"
	end

	pcall(function()
		local modulesOK = ReplicatedStorage:FindFirstChild("Modules") ~= nil
		local lines = {
			"shield=" .. state(getgenv().__IriShieldOK),
			"modules=" .. state(modulesOK),
			"toolinfo=" .. state(Globals.ToolInfo and next(Globals.ToolInfo)),
			"packet=" .. state(type(__VU) == "table" and __VU.FireRemote),
		}
		local report = "status | " .. table.concat(lines, " | ")
		print("[Burmalda.hook] " .. report)
		if Library and Library.Notify then
			Library:Notify("[Burmalda.hook] " .. report, 10, Color3.fromRGB(94, 225, 211))
		end
	end)
end)

-- [Burmalda.hook] Star of David crosshair
pcall(function()
	local RunService = game:GetService("RunService")
	local STAR_COLOR = Color3.fromRGB(0, 56, 184)
	local lines = {}
	for i = 1, 6 do
		local ok, ln = pcall(function() return Drawing.new("Line") end)
		if not ok or not ln then return end
		ln.Thickness = 2
		ln.Color = STAR_COLOR
		ln.Transparency = 1
		ln.Visible = false
		lines[i] = ln
	end
	local function vtx(cx, cy, r, deg)
		local a = math.rad(deg)
		return Vector2.new(cx + math.sin(a) * r, cy - math.cos(a) * r)
	end
	RunService.RenderStepped:Connect(function()
		local on = Library and Library.Flags and Library.Flags.StarCrosshair and Library.Flags.StarCrosshair.Value
		if not on then
			for i = 1, 6 do lines[i].Visible = false end
			return
		end
		local cam = workspace.CurrentCamera
		local vp = (cam and cam.ViewportSize) or Vector2.new(0, 0)
		local cx, cy = vp.X / 2, vp.Y / 2
		local r = 16
		local rot = 0
		if Library.Flags.RotateCrosshair and Library.Flags.RotateCrosshair.Value then
			rot = (tick() * 90) % 360
		end
		local up = { vtx(cx, cy, r, rot + 0), vtx(cx, cy, r, rot + 120), vtx(cx, cy, r, rot + 240) }
		local dn = { vtx(cx, cy, r, rot + 60), vtx(cx, cy, r, rot + 180), vtx(cx, cy, r, rot + 300) }
		local seg = {
			{ up[1], up[2] }, { up[2], up[3] }, { up[3], up[1] },
			{ dn[1], dn[2] }, { dn[2], dn[3] }, { dn[3], dn[1] },
		}
		for i = 1, 6 do
			lines[i].From = seg[i][1]
			lines[i].To = seg[i][2]
			lines[i].Color = STAR_COLOR
			lines[i].Visible = true
		end
	end)
end)

-- [Burmalda.hook] Character model swap (Tung Tung Sahur)
pcall(function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LP = Players.LocalPlayer
	local ASSET = "rbxassetid://138151705692565"
	local template = nil
	local function getTemplate()
		if template then return template end
		local ok, objs = pcall(function() return game:GetObjects(ASSET) end)
		if ok and objs and objs[1] then
			local root = objs[1]
			local mp = (root:IsA("MeshPart") and root) or root:FindFirstChildWhichIsA("MeshPart", true)
			if mp then
				template = mp:Clone()
			end
		end
		return template
	end
	local state = {}
	local function applyChar(char)
		if not char or state[char] then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
			or char:FindFirstChild("UpperTorso")
			or char:FindFirstChild("Torso")
		local tmpl = getTemplate()
		if not hrp or not tmpl then return end
		local orig = {}
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "PHTung" and p ~= hrp then
				orig[p] = p.LocalTransparencyModifier
				pcall(function() p.LocalTransparencyModifier = 1 end)
			elseif p:IsA("Decal") or p:IsA("Texture") then
				orig[p] = p.Transparency
				pcall(function() p.Transparency = 1 end)
			end
		end
		local clone = tmpl:Clone()
		clone.Name = "PHTung"
		pcall(function()
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Massless = true
		end)
		local scale = (Library and Library.Flags and Library.Flags.CharModelScale and Library.Flags.CharModelScale.Value) or 4
		pcall(function() clone.Size = clone.Size * scale end)
		clone.Parent = char
		local weld = Instance.new("Weld")
		weld.Part0 = hrp
		weld.Part1 = clone
		weld.C0 = CFrame.new(0, 0, 0)
		weld.Parent = clone
		state[char] = { clone = clone, orig = orig }
	end
	local function restoreChar(char)
		local s = state[char]
		if not s then return end
		if s.clone then pcall(function() s.clone:Destroy() end) end
		for p, v in pairs(s.orig) do
			pcall(function()
				if p:IsA("BasePart") then
					p.LocalTransparencyModifier = v or 0
				else
					p.Transparency = v or 0
				end
			end)
		end
		state[char] = nil
	end
	local lastRun = 0
	RunService.Heartbeat:Connect(function()
		if tick() - lastRun < 0.2 then return end
		lastRun = tick()
		local choice = Library and Library.Flags and Library.Flags.CharModelChoice and Library.Flags.CharModelChoice.Value
		local on = choice == "Tung Tung Sahur"
		local all = Library and Library.Flags and Library.Flags.CharModelAll and Library.Flags.CharModelAll.Value
		local targets = {}
		if on then
			if LP.Character then targets[LP.Character] = true end
			if all then
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl.Character then targets[pl.Character] = true end
				end
			end
		end
		for char in pairs(targets) do
			if not state[char] then pcall(applyChar, char) end
		end
		for char in pairs(state) do
			if (not targets[char]) or (not char.Parent) then pcall(restoreChar, char) end
		end
	end)
end)
