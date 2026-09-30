--[[
  POTATO LAST SCAN v3 (ONE AND ONLY, strongest version)

  HOW TO USE:
  [1] join the game, paste this whole file, Execute
  [2] wait until the window shows  "SHOOT NOW"   (~2-3 min: dispatcher hunt + module decompile)
  [3] shoot 5-10 times at VISIBLE targets (direct, NO walls)
  [4] press "DONE -> COPY" (or wait 5 min, auto-finish) and paste the output back

  WHAT IT CAPTURES (100% passive, read-only, changes nothing):
  - TRANSPORT SPY (any game): class-level hook on ALL RemoteEvents:
    shot-like packets (CFrame/Vector3 in args) full dumps, B_XX / 0xXX AC report codes,
    LoadingScreen channel, big encrypted strings
  - Kz dispatcher (upvalue v_u_99, LarpGuard): every call PRE-ENCRYPTION + upvalues (encryption box/keys)
  - module tree decompile: Kz root (LarpGuard) OR generic ReplicatedStorage scan (Fallen),
    FULL source: UoEx, VectorUtil (Fallen dispatcher), rCnJ subtree, Preload, crypto winner
  - camera: watched properties (GetPropertyChangedSignal spy) + GetAttribute reads (bypass attr) + FOV timeline 4Hz
  - Lighting: GetAttribute reads (integrity expected values) + property/attr dumps t0/t15/t30/t45
  - entity attributes: player / character / ViewmodelController (admin-bypass + IntendedFov + AC flags)
  - GUI scanner spy: CoreGui/PlayerGui GetChildren enumeration by game code (whitelist-scan detector)
  - character remote tree + RS.Remotes tree
  - Look remote samples
  - raw encrypted remote payloads (hex head) as fallback
]]

print("[PLScan v3] script LOADED - window should appear in 1-2 seconds")
local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")

local _decompile = decompile

---------------------------------------------------------------- output
local out = {}
local function line(s)
	out[#out + 1] = s
end

local sections = {}
local function sl(name, s)
	local t = sections[name]
	if not t then
		t = {}
		sections[name] = t
	end
	t[#t + 1] = s
end

local body
local statusLines = {}
local function status(s)
	statusLines[#statusLines + 1] = ("[" .. os.date("%H:%M:%S") .. "] " .. s)
	if #statusLines > 20 then table.remove(statusLines, 1) end
	if body then body.Text = table.concat(statusLines, "\n") end
	print("[PLScan] " .. s)
end

local banner, bannerBg, infoLine
local bannerText, bannerColor = "STARTING...", Color3.fromRGB(63, 201, 176)
local function setBanner(txt, col)
	bannerText = txt
	bannerColor = col or bannerColor
	if banner then
		banner.Text = txt
		if bannerBg then bannerBg.BackgroundColor3 = bannerColor end
	end
	print("[PLScan] >>> " .. txt)
end
local fileState = "file: not yet"
local function setFileState(txt)
	fileState = txt
end

do
	local okW = pcall(function() writefile("plscan_started.txt", "scan started " .. os.date("%Y-%m-%d %H:%M:%S")) end)
	if okW then
		print("[PLScan] FILE WRITE OK - reports will be saved next to plscan_started.txt (executor workspace folder)")
		setFileState("file: OK (plscan_started.txt created in executor folder)")
	else
		print("[PLScan] FILE WRITE NOT AVAILABLE in this executor - report will go to clipboard + F9 only")
		setFileState("file: NOT AVAILABLE -> clipboard + F9 only")
	end
end

local function buildWindow()
	local gui = Instance.new("ScreenGui")
	gui.Name = "PLScanGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 99999
	gui.IgnoreGuiInset = true

	local frame = Instance.new("Frame")
	frame.Name = "PLScan"
	frame.Size = UDim2.fromOffset(660, 520)
	frame.Position = UDim2.new(0.5, -330, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(10, 20, 24)
	frame.BorderSizePixel = 0
	frame.Active = true

	local cr = Instance.new("UICorner")
	cr.CornerRadius = UDim.new(0, 10)
	cr.Parent = frame

	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(63, 201, 176)
	st.Thickness = 1.5
	st.Parent = frame

	local hdr = Instance.new("TextLabel")
	hdr.BackgroundTransparency = 1
	hdr.Size = UDim2.new(1, -12, 0, 26)
	hdr.Position = UDim2.fromOffset(6, 0)
	hdr.Text = "POTATO LAST SCAN v3  [drag me]"
	hdr.Font = Enum.Font.Code
	hdr.TextSize = 13
	hdr.TextColor3 = Color3.fromRGB(63, 201, 176)
	hdr.TextXAlignment = Enum.TextXAlignment.Left
	hdr.Parent = frame

	bannerBg = Instance.new("Frame")
	bannerBg.Size = UDim2.new(1, -16, 0, 64)
	bannerBg.Position = UDim2.fromOffset(8, 28)
	bannerBg.BackgroundColor3 = bannerColor
	bannerBg.BorderSizePixel = 0
	bannerBg.Parent = frame
	local bcr0 = Instance.new("UICorner")
	bcr0.CornerRadius = UDim.new(0, 8)
	bcr0.Parent = bannerBg

	banner = Instance.new("TextLabel")
	banner.BackgroundTransparency = 1
	banner.Size = UDim2.new(1, -16, 1, 0)
	banner.Position = UDim2.fromOffset(8, 0)
	banner.Font = Enum.Font.GothamBold
	banner.TextSize = 22
	banner.TextColor3 = Color3.fromRGB(8, 20, 18)
	banner.TextWrapped = true
	banner.TextXAlignment = Enum.TextXAlignment.Left
	banner.Text = bannerText
	banner.Parent = bannerBg

	infoLine = Instance.new("TextLabel")
	infoLine.BackgroundTransparency = 1
	infoLine.Size = UDim2.new(1, -16, 0, 20)
	infoLine.Position = UDim2.fromOffset(8, 96)
	infoLine.Font = Enum.Font.Code
	infoLine.TextSize = 14
	infoLine.TextColor3 = Color3.fromRGB(255, 220, 120)
	infoLine.TextXAlignment = Enum.TextXAlignment.Left
	infoLine.Text = "shots: 0 | time: 0s | " .. fileState
	infoLine.Parent = frame

	body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Size = UDim2.new(1, -16, 1, -160)
	body.Position = UDim2.fromOffset(8, 120)
	body.Font = Enum.Font.Code
	body.TextSize = 12
	body.TextColor3 = Color3.fromRGB(205, 235, 228)
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.Text = "starting..."
	body.Parent = frame

	local doneBtn = Instance.new("TextButton")
	doneBtn.Name = "Done"
	doneBtn.Size = UDim2.new(0, 160, 0, 26)
	doneBtn.Position = UDim2.new(1, -170, 1, -36)
	doneBtn.BackgroundColor3 = Color3.fromRGB(63, 201, 176)
	doneBtn.Text = "DONE -> SAVE FILE"
	doneBtn.Font = Enum.Font.Code
	doneBtn.TextSize = 13
	doneBtn.TextColor3 = Color3.fromRGB(8, 20, 18)
	doneBtn.AutoButtonColor = true
	local bcr = Instance.new("UICorner")
	bcr.CornerRadius = UDim.new(0, 6)
	bcr.Parent = doneBtn
	doneBtn.Parent = frame

	local okPG, pg = pcall(function() return player:WaitForChild("PlayerGui", 10) end)
	local guiParent = (okPG and pg) and pg or game:GetService("CoreGui")
	gui.Parent = guiParent
	print("[PLScan] window created in " .. (guiParent == pg and "PlayerGui" or "CoreGui (fallback)"))

	local dragging, dragStart, startPos = false, nil, nil
	frame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = frame.Position
		end
	end)
	frame.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	return doneBtn
end
local okBuild, btn = pcall(buildWindow)
if not okBuild then
	print("[PLScan] WINDOW BUILD FAILED: " .. tostring(btn))
	warn("[PLScan] window build FAILED: " .. tostring(btn))
end
local doneBtn = okBuild and btn or nil

---------------------------------------------------------------- value formatting
local function fmtVal(v, depth)
	depth = depth or 0
	local t = type(v)
	if t == "number" then return tostring(v) end
	if t == "boolean" or t == "nil" then return tostring(v) end
	if t == "string" then
		if #v <= 120 then return string.format("%q", v) end
		local head = v:sub(1, 80)
		local printable = (head:gsub("[%c\127]", "") == head)
		if not printable then
			local hex = {}
			for i = 1, math.min(#v, 96) do
				hex[#hex + 1] = string.format("%02X", v:byte(i))
			end
			return ("bin+%dB[%s...]"):format(#v, table.concat(hex, " "))
		end
		return string.format("%q..+%dB", v:sub(1, 120), #v - 120)
	end
	if t == "function" then return "<fn>" end
	if t == "userdata" then return "<userdata>" end
	if t == "table" then
		local mt = getmetatable(v)
		local nm = mt and mt.__name
		if nm then
			if nm == "CFrame" then
				return ("CFrame p=%s l=%s"):format(tostring(v.Position), tostring(v.LookVector))
			end
			if nm == "Vector3" then return "V3" .. tostring(v) end
			if nm == "Vector2" then return "V2" .. tostring(v) end
			if nm == "Color3" then return "Color3" .. tostring(v) end
			if nm == "EnumItem" then return "Enum:" .. tostring(v) end
			if nm ~= "table" then
				local okn, full = pcall(function() return v:GetFullName() end)
				return nm .. ":" .. (okn and tostring(full) or "?")
			end
		end
		if depth >= 2 then return "{table}" end
		local parts, n = {}, 0
		for k, val in next, v do
			n += 1
			if n > 24 then
				parts[#parts + 1] = "...(more)"
				break
			end
			parts[#parts + 1] = tostring(k) .. "=" .. fmtVal(val, depth + 1)
		end
		return "{" .. table.concat(parts, "; ") .. "}"
	end
	return t
end

---------------------------------------------------------------- state
local shotDumps = {}
local channelMap = {}
local shotCount = 0
local camProps = {}
local camAttrNames = {}
local lightingAttrReads = {}
local lookSamples = {}
local dispatcher = nil
local dispatcherSrc = "?"
local finished = false
local currentPhase = "init"
local decompFailLog = {}
-- AC-transport captures (Claude-AC pattern: B_XX / 0xXX report codes, LoadingScreen fallback)
local acReports = {}
local lsCalls = {}
-- GUI scanner spy (Claude-AC pattern: CoreGui whitelist scan)
local guiScans = {}
local guiScanCount = { CoreGui = 0, PlayerGui = 0 }
-- FOV timeline (Claude-AC pattern: B_7B FieldOfView vs IntendedFov/witness)
local fovSamples = {}

-- 5s self-diagnostic: why is the window missing?
task.spawn(function()
	task.wait(5)
	local wstate = "window NOT created (build failed - look above for WINDOW BUILD FAILED)"
	if body then
		local okp, pfull = pcall(function() return body.Parent:GetFullName() end)
		local okv, vis = pcall(function() return body.Parent.Enabled end)
		wstate = ("window OK parent=%s enabled=%s"):format(tostring(okp and pfull or "?"), tostring(okv and vis or "?"))
	end
	print("[PLScan] DIAG t=5s: " .. wstate .. " | character=" .. tostring(player.Character ~= nil) .. " | inGame=" .. tostring(game:IsLoaded()))
end)
-- 120s checkpoint: if still not in shooting phase, say where we are
task.spawn(function()
	task.wait(120)
	if not finished then
		print("[PLScan] CHECKPOINT t=120s: phase=" .. currentPhase .. " shots=" .. shotCount .. " dispatcher=" .. tostring(dispatcher ~= nil))
	end
end)
warn("[PLScan v3] loaded. No window? Press F9 in game and look for [PLScan] lines - send them back.")



local function classOf(v)
	local mt = getmetatable(v)
	return (mt and mt.__name) or type(v)
end

local function argSig(args)
	local sig = {}
	for i = 1, #args do
		sig[i] = classOf(args[i])
	end
	return table.concat(sig, ",")
end

local function upvPreview(v)
	local t = type(v)
	if t == "string" then
		if #v <= 64 then return string.format("%q", v) end
		return string.format("%q..+%dB", v:sub(1, 48), #v)
	end
	if t == "number" or t == "boolean" or t == "nil" then return tostring(v) end
	if t == "function" then
		local oki, info = pcall(debug.getinfo, v)
		return "<fn src=" .. (oki and tostring(info.source) or "?") .. ">"
	end
	if t == "table" then
		local mt = getmetatable(v)
		local nm = mt and mt.__name
		if nm then
			if nm == "RemoteEvent" or nm == "RemoteFunction" or nm == "Instance" then
				local okf, full = pcall(function() return v:GetFullName() end)
				return nm .. ":" .. (okf and tostring(full) or "?")
			end
			return "<" .. nm .. ">"
		end
		local n = 0
		for _ in pairs(v) do
			n += 1
			if n >= 8 then return "{table ~" .. n .. "+ items}" end
		end
		return "{table " .. n .. " items}"
	end
	return "<" .. t .. ">"
end

local function dumpUpvalues(fn, label)
	sl(label, ("  ==== upvalues of " .. label .. " owner (src=" .. tostring(dispatcherSrc) .. ") ===="))
	local i = 1
	while i <= 64 do
		local ok, name, val = pcall(debug.getupvalue, fn, i)
		if not ok or name == nil then break end
		sl(label, ("  up%-2d %-12s = %s"):format(i, name, upvPreview(val)))
		i += 1
	end
end

---------------------------------------------------------------- phase 1a: dispatcher hunt
local function findDispatcher()
	local deadline = os.clock() + 25
	local checked = 0
	for _, obj in getgc(false) do
		if os.clock() > deadline then break end
		if type(obj) ~= "function" then continue end
		checked += 1
		local i = 1
		while true do
			local ok, name, val = pcall(debug.getupvalue, obj, i)
			if not ok or name == nil then break end
			if name == "v_u_99" and type(val) == "function" then
				local oki, info = pcall(debug.getinfo, obj)
				return val, (oki and info.source) or "?", checked
			end
			i += 1
		end
	end
	return nil, nil, checked
end

local function hookDispatcher(fn)
	local orig
	orig = hookfunction(fn, function(...)
		local args = { ... }
		local ch = (type(args[1]) == "string") and args[1] or "<no-ch>"
		local key = ch:sub(1, 40)
		channelMap[key] = channelMap[key] or { n = 0, sigs = {}, sample = nil }
		local cm = channelMap[key]
		cm.n += 1
		if cm.n <= 3 then
			cm.sigs[#cm.sigs + 1] = argSig(args)
		end
		if cm.sample == nil then
			cm.sample = {}
			for i = 1, #args do
				cm.sample[i] = fmtVal(args[i])
			end
		end
		local looksShot = false
		for i = 1, #args do
			local c = classOf(args[i])
			if c == "CFrame" or c == "Vector3" then
				looksShot = true
				break
			elseif type(args[i]) == "table" and getmetatable(args[i]) == nil then
				for _, val in next, args[i] do
					local vc = classOf(val)
					if vc == "CFrame" or vc == "Vector3" then
						looksShot = true
						break
					end
				end
				if looksShot then break end
			end
		end
		if looksShot and #shotDumps < 60 then
			shotCount += 1
			local entry = {
				n = ("#%d t=%.3f ch=%q args[%d] sig=%s"):format(shotCount, os.clock(), key, #args, argSig(args)),
				args = {}
			}
			for i = 1, #args do
				entry.args[i] = ("  [%d] %s = %s"):format(i, classOf(args[i]), fmtVal(args[i]))
			end
			shotDumps[#shotDumps + 1] = entry
		end
		return orig(...)
	end)
end

---------------------------------------------------------------- phase 1b: camera spies (class-level)
local cam = workspace.CurrentCamera
local camSpiesOn = false
local propSpyActive = true
local function installCamSpies(c)
	if camSpiesOn then return end
	camSpiesOn = true

	pcall(function()
		local oldPS
		oldPS = hookfunction(Instance.GetPropertyChangedSignal, function(self, prop)
			if propSpyActive and self == c then
				camProps[prop] = (camProps[prop] or 0) + 1
			end
			return oldPS(self, prop)
		end)
	end)
	-- throttle: guard subscriptions happen at init; stop counting after 45s to save FPS
	task.delay(45, function()
		propSpyActive = false
	end)
	pcall(function()
		local oldGA
		oldGA = hookfunction(Instance.GetAttribute, function(self, name)
			if self == c then
				camAttrNames[name] = true
			end
			return oldGA(self, name)
		end)
	end)

	local attrs = {}
	pcall(function()
		for k, v in pairs(c:GetAttributes()) do
			attrs[#attrs + 1] = k .. "=" .. tostring(v)
			camAttrNames[k] = true
		end
	end)
	sl("CAM", "[CAM_ATTRS_ON_SPAWN] " .. (#attrs > 0 and table.concat(attrs, ", ") or "(none)"))
	status("camera spies on (props + attrs, class-level)")
end

local function dumpCamState(tag)
	local c = workspace.CurrentCamera
	if not c then
		sl("CAM", "[CAM_STATE " .. tag .. "] no camera")
		return
	end
	local info = {}
	local props = {
		"FieldOfView", "Brightness", "CameraBias", "CameraType", "CameraSubject",
		"MinFov", "MaxFov", "CameraMinZoomDistance", "CameraMaxZoomDistance",
		"PanSpeedX", "PanSpeedY", "SubjectZoom"
	}
	for _, p in props do
		local ok, v = pcall(function() return c[p] end)
		if ok then info[#info + 1] = p .. "=" .. tostring(v) end
	end
	local okCF, cf = pcall(function() return c.CFrame end)
	if okCF then info[#info + 1] = "CFrame=" .. tostring(cf) end
	local okLV, lv = pcall(function() return c.CFrame.LookVector end)
	if okLV then info[#info + 1] = "LookVector=" .. tostring(lv) end
	local attrs = {}
	pcall(function()
		for k, v in pairs(c:GetAttributes()) do
			attrs[#attrs + 1] = k .. "=" .. tostring(v)
		end
	end)
	sl("CAM", ("[CAM_STATE %s] %s | attrs: %s"):format(tag, table.concat(info, " "), #attrs > 0 and table.concat(attrs, ", ") or "(none)"))
	if #camProps > 0 then
		local names = {}
		for k, n in pairs(camProps) do names[#names + 1] = k .. "x" .. n end
		table.sort(names)
		sl("CAM", ("[CAM_PROPS_SPOYED] %s"):format(table.concat(names, ", ")))
	end
	if next(camAttrNames) then
		local names = {}
		for k in pairs(camAttrNames) do names[#names + 1] = k end
		table.sort(names)
		sl("CAM", ("[CAM_ATTRS_SPOYED] %s"):format(table.concat(names, ", ")))
	end
end

---------------------------------------------------------------- phase 1c: lighting spies + dumps
local lightingSpyOn = false
local function installLightingSpy()
	if lightingSpyOn then return end
	lightingSpyOn = true
	pcall(function()
		local oldGA
		oldGA = hookfunction(Lighting.GetAttribute, function(self, name)
			if self == Lighting then
				lightingAttrReads[name] = (lightingAttrReads[name] or 0) + 1
			end
			return oldGA(self, name)
		end)
	end)
end

local function dumpLighting(tag)
	local attrs = {}
	pcall(function()
		for k, v in pairs(Lighting:GetAttributes()) do
			attrs[#attrs + 1] = k .. "=" .. tostring(v)
		end
	end)
	local props = {}
	for _, p in { "Ambient", "OutdoorAmbient", "ColorShift_Bottom", "ColorShift_Top", "ClockTime" } do
		local ok, v = pcall(function() return Lighting[p] end)
		if ok then props[#props + 1] = p .. "=" .. tostring(v) end
	end
	sl("LIGHTING", ("[LIGHTING %s] %s | attrs: %s"):format(tag, table.concat(props, " "), #attrs > 0 and table.concat(attrs, ", ") or "(none)"))
end

local function dumpLightingReads()
	if next(lightingAttrReads) then
		local names = {}
		for k, n in pairs(lightingAttrReads) do names[#names + 1] = k .. "x" .. n end
		table.sort(names)
		sl("LIGHTING", ("[LIGHTING_ATTR_READS] %s"):format(table.concat(names, ", ")))
	else
		sl("LIGHTING", "[LIGHTING_ATTR_READS] (none - integrity check not observed reading attributes)")
	end
end

---------------------------------------------------------------- phase 1d: Look remote capture (single class-level hook)
local lookRef = nil
local lookHooked = false
local function setLook(char)
	local tc = char:FindFirstChild("TorsoController")
	local look = tc and tc:FindFirstChild("Look")
	if not look then
		sl("LOOK", "[LOOK] TorsoController.Look NOT FOUND")
		return
	end
	lookRef = look
	if not lookHooked then
		lookHooked = true
		pcall(function()
			local orig
			orig = hookfunction(look.FireServer, function(self, ...)
				if self == lookRef then
					local args = { ... }
					if #lookSamples < 12 then
						local t = {}
						for i = 1, #args do
							t[i] = fmtVal(args[i])
						end
						lookSamples[#lookSamples + 1] = ("t=%.2f [%s]"):format(os.clock(), table.concat(t, " | "))
					end
				end
				return orig(self, ...)
			end)
		end)
	end
	sl("LOOK", ("[LOOK] tracking %s"):format(look:GetFullName()))
end

---------------------------------------------------------------- remote trees
local function dumpRemoteTree(root, label, cap)
	if not root then
		sl("REMOTES", ("[%s] not found"):format(label))
		return
	end
	local list = {}
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
			list[#list + 1] = (d:IsA("RemoteFunction") and "RF: " or "RE: ") .. d:GetFullName()
			if #list >= (cap or 120) then break end
		end
	end
	sl("REMOTES", ("[%s] %d remotes"):format(label, #list))
	for _, l in ipairs(list) do
		sl("REMOTES", "  " .. l)
	end
end

---------------------------------------------------------------- phase 1e: Kz tree decompile
local function findKzRoot()
	local a = RS:FindFirstChild("Kz")
	if a then return a end
	local m = RS:FindFirstChild("Modules")
	local b = m and m:FindFirstChild("Kz")
	if b then return b end
	for _, x in ipairs(RS:GetChildren()) do
		for _, y in ipairs(x:GetChildren()) do
			if y.Name == "Kz" then return y end
		end
	end
	return nil
end

local function markerStats(src)
	local fs = select(2, src:gsub("FireServer", ""))
	local rf = select(2, src:gsub("math.random", ""))
	local sc = select(2, src:gsub("string.char", ""))
	local ga = select(2, src:gsub("GetAttribute", ""))
	local fc = select(2, src:gsub("FireClient", ""))
	return fs, rf, sc, ga, fc
end

-- decompile with watchdog: if the call yields forever (server-side), cut it off
local function decompileTimeout(inst, timeoutSec)
	local result
	local done = false
	task.spawn(function()
		local ok, src = pcall(_decompile, inst)
		result = { ok, src }
		done = true
	end)
	local waited = 0
	while not done and waited < timeoutSec do
		task.wait(0.5)
		waited += 0.5
	end
	if not done then
		return false, ("timeout after %ds (module skipped)"):format(timeoutSec)
	end
	if result[1] then
		return true, result[2]
	end
	return false, tostring(result[2])
end

local function decompileOnce(inst, tag, capBytes)
	if not _decompile then
		return false, "NO decompile() in executor"
	end
	local ok, src = decompileTimeout(inst, 30)
	if not ok then
		return false, tostring(src)
	end
	if type(src) ~= "string" or #src < 100 then
		local sz = (type(src) == "string") and #src or 0
		return false, ("short/empty source (%dB, raw=%s)"):format(sz, tostring(src))
	end
	sl("KZ", ("[KZ_DECOMP_%s] OK size=%d cap=%d"):format(tag, #src, capBytes))
	sl("KZ", ("[KZ_DECOMP_%s_START]"):format(tag))
	local n = math.min(#src, capBytes)
	for i = 1, n, 1000 do
		sl("KZ", src:sub(i, i + 999))
	end
	if #src > capBytes then
		sl("KZ", ("[KZ_DECOMP_%s] ...truncated %dB..."):format(tag, #src - capBytes))
	end
	sl("KZ", ("[KZ_DECOMP_%s_END]"):format(tag))
	return true, #src
end

local function runKzAnalysis()
	sl("KZ", "========== KZ MODULE TREE ==========")
	if not _decompile then
		sl("KZ", "[KZ] NO decompile() in executor - module analysis skipped")
		return
	end
	local kzRoot = findKzRoot()
	local scanRoot
	if kzRoot then
		scanRoot = kzRoot
		sl("KZ", ("[KZ] root=%s"):format(kzRoot:GetFullName()))
	else
		sl("KZ", "[KZ] Kz root NOT FOUND (not LarpGuard?) - generic scan of whole ReplicatedStorage")
		scanRoot = RS
	end

	local mods = {}
	for _, d in ipairs(scanRoot:GetDescendants()) do
		if d:IsA("ModuleScript") then
			mods[#mods + 1] = d
			if #mods >= 150 then break end
		end
	end
	sl("KZ", ("[KZ] modules found: %d"):format(#mods))

	local budget = os.clock() + 90
	local done = {}
	local scores = {}

	local function shortName(m)
		local full = m:GetFullName()
		local tail = full:match("Kz%.?(.*)$")
		return tail or full
	end

	-- priority 1: UoEx full source (encryption + payload builder)
	for _, m in ipairs(mods) do
		if m.Name == "UoEx" then
			local tag = "UoEx"
			sl("KZ", ("[KZ_TRY] %s (full cap 60000)"):format(shortName(m)))
			status("decompiling UoEx...")
			local ok, r = decompileOnce(m, tag, 60000)
			if not ok then decompFailLog[#decompFailLog + 1] = ("UoEx: %s"):format(tostring(r)) end
			done[m] = true
			break
		end
	end

	-- priority 1b: VectorUtil (Fallen central FireRemote/SetupRemote dispatcher)
	for _, m in ipairs(mods) do
		if m.Name == "VectorUtil" then
			local tag = "VectorUtil"
			sl("KZ", ("[KZ_TRY] %s (full cap 20000 - Fallen dispatcher)"):format(shortName(m)))
			status("decompiling VectorUtil...")
			local ok, r = decompileOnce(m, tag, 20000)
			if not ok then decompFailLog[#decompFailLog + 1] = ("VectorUtil: %s"):format(tostring(r)) end
			done[m] = true
			break
		end
	end

	-- priority 2: everything under the rCnJ folder (UoEx parents: QTA, uili, ...)
	for _, m in ipairs(mods) do
		local full = m:GetFullName()
		if full:find(".rCnJ.", 1, true) and not done[m] then
			local tag = "rCnJ_" .. m.Name
			if os.clock() > budget then
				sl("KZ", ("[KZ_SKIP] %s (budget)"):format(shortName(m)))
				continue
			end
			sl("KZ", ("[KZ_TRY] %s (cap 12000)"):format(shortName(m)))
			local ok, r = decompileOnce(m, tag, 12000)
			if not ok then decompFailLog[#decompFailLog + 1] = (tag .. ": %s"):format(tostring(r)) end
			done[m] = true
		end
	end

	-- priority 3: Preload (self-checks) if found anywhere
	local preload = RS:FindFirstChild("Preload")
	local mMods = RS:FindFirstChild("Modules")
	if not preload and mMods then preload = mMods:FindFirstChild("Preload") end
	if preload and preload:IsA("ModuleScript") then
		sl("KZ", ("[KZ_TRY] %s (cap 4000)"):format(preload:GetFullName()))
		local ok, r = decompileOnce(preload, "Preload", 4000)
		if not ok then decompFailLog[#decompFailLog + 1] = ("Preload: %s"):format(tostring(r)) end
	end

	-- priority 4: marker scan of up to 10 other modules, full-dump the crypto winner
	local others = 0
	for _, m in ipairs(mods) do
		if not done[m] and os.clock() <= budget then
			others += 1
			sl("KZ", ("[KZ_TRY] %s (markers)"):format(shortName(m)))
			local ok, src = decompileTimeout(m, 20)
			if ok and type(src) == "string" and #src >= 100 then
				local fs, rf, sc, ga, fc = markerStats(src)
				scores[m] = { score = sc * 3 + rf * 2 + (fs > 0 and 1 or 0), fs = fs, rf = rf, sc = sc, ga = ga, fc = fc, src = src, size = #src }
				sl("KZ", ("[KZ_MOD] %s | size=%d | FireServer=%d math.random=%d string.char=%d GetAttribute=%d FireClient=%d | head=%q"):format(
					shortName(m), #src, fs, rf, sc, ga, fc, src:sub(1, 120)))
			else
				decompFailLog[#decompFailLog + 1] = ("marker/" .. m.Name .. ": " .. tostring(ok and "short" or src))
			end
			if others >= 10 then break end
		end
	end

	local best, bestScore = nil, 2
	for m, s in pairs(scores) do
		if s.score > bestScore then
			best, bestScore = m, s.score
		end
	end
	if best then
		local s = scores[best]
		sl("KZ", ("[KZ_CRYPO_WINNER] %s score=%d (string.char=%d math.random=%d) - full dump cap 60000"):format(best:GetFullName(), bestScore, s.sc, s.rf))
		local tag = "CRYPTO_" .. best.Name
		local ok, r = decompileOnce(best, tag, 60000)
		if not ok then decompFailLog[#decompFailLog + 1] = (tag .. ": %s"):format(tostring(r)) end
	else
		sl("KZ", "[KZ_CRYPO_WINNER] none (no strong string.char/math.random module found)")
	end
end

---------------------------------------------------------------- main
local t0 = os.clock()
status("phase 1: waiting for character...")
task.spawn(function()
	task.wait(20)
	if not player.Character then
		status("NO CHARACTER YET - if you are in a lobby, press ENTER/PLAY to join the map")
	end
end)

local function mainBody()

local char = player.Character or player.CharacterAdded:Wait()
status("character: " .. char:GetFullName())

cam = workspace.CurrentCamera
installCamSpies(cam)
installLightingSpy()
setLook(char)
dumpLighting("t0")
dumpRemoteTree(RS:FindFirstChild("Remotes"), "RS.Remotes", 120)
dumpRemoteTree(char, "CHARACTER", 60)

-- Claude-AC pattern (B_7B): FOV timeline 4Hz x 60s - shows guard force-restore jumps
task.spawn(function()
	local deadline = os.clock() + 60
	while os.clock() < deadline and #fovSamples < 240 do
		local c = workspace.CurrentCamera
		if c then
			local ok1, fov = pcall(function() return c.FieldOfView end)
			local ok2, ct = pcall(function() return c.CameraType end)
			fovSamples[#fovSamples + 1] = ("t=%.1f fov=%s type=%s"):format(os.clock(), tostring(ok1 and fov or "?"), tostring(ok2 and ct or "?"))
		end
		task.wait(0.25)
	end
end)

-- entity attribute dumps (admin-bypass attrs like AdminFullbright, IntendedFov, AC flags)
local function dumpEntityAttrs(inst, label)
	local attrs = {}
	pcall(function()
		for k, v in pairs(inst:GetAttributes()) do
			attrs[#attrs + 1] = k .. "=" .. tostring(v)
		end
	end)
	sl("ATTRS", ("[" .. label .. "] " .. (#attrs > 0 and table.concat(attrs, ", ") or "(none)")))
end
dumpEntityAttrs(player, "PLAYER")
local vmc0 = char:FindFirstChild("ViewmodelController")
if vmc0 then dumpEntityAttrs(vmc0, "VIEWMODEL") end
dumpEntityAttrs(char, "CHARACTER")
local function dumpViewmodelAttrs(c)
	local vmc = c:FindFirstChild("ViewmodelController")
	if vmc then dumpEntityAttrs(vmc, "VIEWMODEL") end
end

-- Claude-AC pattern: CoreGui/PlayerGui whitelist scanner - spy GetChildren on our containers
pcall(function()
	local CG = game:GetService("CoreGui")
	local PG = player:FindFirstChild("PlayerGui")
	local oldGC
	oldGC = hookfunction(Instance.GetChildren, function(self)
		local tag
		if self == CG then
			tag = "CoreGui"
		elseif self == PG then
			tag = "PlayerGui"
		end
		if tag then
			guiScanCount[tag] += 1
			local n = guiScanCount[tag]
			if (n <= 3 or n % 50 == 0) and #guiScans < 24 then
				local kids = {}
				for _, c in ipairs(oldGC(self)) do
					kids[#kids + 1] = c.ClassName .. ":" .. c.Name
					if #kids > 30 then break end
				end
				guiScans[#guiScans + 1] = ("[" .. tag .. " scan #" .. n .. " t=" .. string.format("%.2f", os.clock()) .. "] " .. table.concat(kids, " | "))
			end
		end
		return oldGC(self)
	end)
end)
sl("PROBE", ("[SHARED] shared global type = %s"):format(tostring(rawget(_G, "shared") and type(rawget(_G, "shared")) or "absent")))

player.CharacterAdded:Connect(function(newChar)
	status("respawn detected, re-hooking Look")
	task.spawn(function()
		task.wait(2)
		setLook(newChar)
		dumpViewmodelAttrs(newChar)
	end)
end)

-- TRANSPORT SPY: ONE class-level hook on RemoteEvent.FireServer, covers ALL remotes in the game.
-- Installed via a throwaway probe remote (no dependency on any specific folder).
pcall(function()
	local found = {}
	local function findBig(v, depth)
		if depth > 2 then return end
		if type(v) == "string" and #v >= 40 then
			found[#found + 1] = v
		elseif type(v) == "table" and getmetatable(v) == nil then
			for _, val in pairs(v) do
				findBig(val, depth + 1)
			end
		end
	end
	local shotLike = false
	local function scanShot(v, depth)
		if depth > 2 or shotLike then return end
		local mt = getmetatable(v)
		if mt then
			local nm = mt.__name
			if nm == "CFrame" or nm == "Vector3" then
				shotLike = true
				return
			end
		elseif type(v) == "table" then
			for _, val in pairs(v) do
				if shotLike then return end
				scanShot(val, depth + 1)
			end
		end
	end
	local function installFrom(sampleRemote)
		local orig
		orig = hookfunction(sampleRemote.FireServer, function(self, ...)
			local args = { ... }
			-- (1) AC report codes (Claude-AC transport: B_XX / 0xXX short codes in args)
			for i = 1, #args do
				local a = args[i]
				if type(a) == "string" and #a <= 16 and (a:match("^B_%x+$") or a:match("^0x%x+$")) then
					if #acReports < 200 then
						local entry = ("[AC_REPORT #%d t=%.2f remote=%s]:"):format(#acReports + 1, os.clock(), self:GetFullName())
						for j = 1, #args do
							entry = entry .. " [" .. j .. "] " .. fmtVal(args[j]) .. " |"
						end
						acReports[#acReports + 1] = entry
					end
					break
				end
			end
			-- (2) LoadingScreen channel (Claude-AC fallback + heartbeat "124")
			if self.Name:find("LoadingScreen", 1, true) then
				if #lsCalls < 100 then
					local entry = ("[LS_CALL t=%.2f remote=%s]:"):format(os.clock(), self.Name)
					for j = 1, #args do
						entry = entry .. " [" .. j .. "] " .. fmtVal(args[j]) .. " |"
					end
					lsCalls[#lsCalls + 1] = entry
				end
			end
			-- (3) big strings: encrypted shot payloads (raw fallback if dispatcher not hooked)
			for i = 1, #args do
				findBig(args[i], 0)
			end
			if #found > 0 then
				local entry = ("[RAW t=%.2f remote=%s strs=%d]"):format(os.clock(), self.Name, #found)
				for i = 1, #found do
					entry = entry .. " [" .. i .. "] " .. fmtVal(found[i]) .. " |"
				end
				found = {}
				if #shotDumps < 60 then
					shotDumps[#shotDumps + 1] = { n = entry, args = { "(raw encrypted - dispatcher not hooked)" } }
				end
				local key = "RAW:" .. self.Name
				channelMap[key] = channelMap[key] or { n = 0, sigs = {}, sample = nil }
				channelMap[key].n += 1
			else
				found = {}
			end
			-- (4) shot-like: CFrame/Vector3 anywhere in args (game-agnostic shot detector)
			shotLike = false
			for i = 1, #args do
				if shotLike then break end
				scanShot(args[i], 0)
			end
			if shotLike and #shotDumps < 120 then
				shotCount += 1
				local entry = {
					n = ("#%d t=%.3f remote=%s args[%d] sig=%s"):format(shotCount, os.clock(), self.Name, #args, argSig(args)),
					args = {}
				}
				for i = 1, #args do
					entry.args[i] = ("  [%d] %s = %s"):format(i, classOf(args[i]), fmtVal(args[i]))
				end
				shotDumps[#shotDumps + 1] = entry
				local key = "SHOT:" .. self.Name
				channelMap[key] = channelMap[key] or { n = 0, sigs = {}, sample = nil }
				channelMap[key].n += 1
			end
			return orig(self, ...)
		end)
		sl("STATUS", "[STATUS] transport spy installed (class-level, all remotes in game)")
	end
	local probe = Instance.new("RemoteEvent")
	installFrom(probe)
	probe:Destroy()
end)

currentPhase = "dispatcher hunt (max 25s)"
setBanner("WAIT - DO NOT SHOOT YET\nanalyzing game (step 1 of 2, ~30s)", Color3.fromRGB(255, 190, 80))
status("phase 1: hunting Kz dispatcher (getgc)...")
local okD, errD = pcall(function()
	local found, src, checked = findDispatcher()
	if found then
		dispatcher = found
		dispatcherSrc = src
		hookDispatcher(found)
		sl("DISPATCHER", ("[DISPATCHER] FOUND upvalue=v_u_99 owner_src=%s checked=%d"):format(tostring(src), checked))
		status("dispatcher HOOKED (checked " .. checked .. " objs) - dumping upvalues...")
		dumpUpvalues(found, "DISPATCHER")
	else
		sl("DISPATCHER", ("[DISPATCHER] NOT FOUND in getgc (checked=%d) - raw fallback only"):format(checked))
		status("dispatcher NOT FOUND (raw fallback active)")
	end
end)
if not okD then
	sl("DISPATCHER", "[DISPATCHER] phase error: " .. tostring(errD))
	status("dispatcher phase error (continuing with raw fallback)")
end

currentPhase = "Kz decompile (max ~2min)"
setBanner("WAIT - DO NOT SHOOT YET\nreading game modules (step 2 of 2, up to 2 min)", Color3.fromRGB(255, 190, 80))
status("phase 1: Kz module tree + decompile (up to 90s)...")
local okK, errK = pcall(runKzAnalysis)
if not okK then
	sl("KZ", "[KZ] phase error: " .. tostring(errK))
	status("Kz analysis error (continuing)")
end

currentPhase = "SHOOT NOW"
setBanner("SHOOT NOW!  5-10 shots at visible targets (no walls)\nthen just keep playing until the timer ends", Color3.fromRGB(120, 230, 140))
status("phase 2: SHOOT NOW - 5-10 shots at VISIBLE targets (NO WALLS)")
sl("STATUS", "[STATUS] shooting phase started; dispatcher capture live")

-- liveness heartbeat: window must never look frozen
task.spawn(function()
	while not finished do
		task.wait(10)
		status(("alive: t=%ds shots=%d | %s"):format(math.floor(os.clock() - t0), shotCount, currentPhase))
		if currentPhase == "SHOOT NOW" and shotCount >= 5 then
			local left = math.max(0, 300 - math.floor(os.clock() - t0))
			setBanner(("SHOTS OK (%d)  -  keep playing, auto-finish in %d s\n(you can also press DONE now)"):format(shotCount, left), Color3.fromRGB(120, 230, 140))
		end
	end
end)
task.spawn(function()
	while not finished do
		task.wait(1)
		if infoLine then
			infoLine.Text = ("shots: %d | time: %ds / 300s | %s"):format(shotCount, math.floor(os.clock() - t0), fileState)
		end
	end
end)
-- nudge if no shots arrive
task.spawn(function()
	while not finished and shotCount == 0 do
		task.wait(45)
		if not finished and shotCount == 0 then
			status("STILL NO SHOTS - aim at a VISIBLE bot and shoot 5-10 times")
			setBanner("NO SHOTS DETECTED YET - shoot 5-10 times at a visible target!", Color3.fromRGB(255, 120, 120))
		end
	end
end)

task.spawn(function()
	task.wait(15)
	dumpLighting("t15")
	task.wait(15)
	dumpLighting("t30")
	task.wait(15)
	dumpLighting("t45")
	task.wait(15)
	dumpCamState("t60")
	task.wait(30)
	dumpCamState("t90")
end)

end -- mainBody

local okMain, mainErr = pcall(mainBody)
if not okMain then
	local tb = tostring(mainErr) .. "\n-- stack --\n" .. debug.traceback()
	sl("ERROR", tb)
	status("ERROR (scan stopped early): " .. tostring(mainErr):sub(1, 80))
	setBanner("ERROR - scan stopped early. Press DONE to save what we have and send it.", Color3.fromRGB(255, 120, 120))
	print("[PLScan v3] MAIN ERROR:\n" .. tb)
	if body then
		body.Text = ("SCAN ERROR (press DONE -> COPY and send me the text):\n\n" .. tostring(mainErr))
	end
end

local function partialDump(tag)
	local okP = pcall(function()
		local parts = { "=== POTATO LAST SCAN v3 (PARTIAL " .. tostring(tag) .. ", t=" .. math.floor(os.clock() - t0) .. "s) ===" }
		for name, t in pairs(sections) do
			parts[#parts + 1] = "========== " .. name .. " (" .. #t .. ") =========="
			for i = 1, math.min(#t, 400) do parts[#parts + 1] = t[i] end
		end
		parts[#parts + 1] = "=== PARTIAL ENDS (scan still running) ==="
		writefile("plscan_partial.txt", table.concat(parts, "\n"))
	end)
	if okP then
		status("partial report saved: plscan_partial.txt")
		setFileState("file: plscan_partial.txt saved (" .. os.date("%H:%M:%S") .. ")")
	end
end
task.spawn(function()
	local n = 0
	while not finished do
		task.wait(60)
		n += 1
		if not finished then partialDump(n) end
	end
end)

local function finish()
	if finished then return end
	finished = true
	setBanner("FINISHING - building report, wait a few seconds...", Color3.fromRGB(255, 190, 80))
	status("finishing, building report...")

	dumpCamState("final")
	dumpLightingReads()

	line("=== POTATO LAST SCAN v3 ===")
	line(("[INFO] place=%s job=%s total=%.0fs"):format(tostring(game.PlaceId), tostring(game.JobId), os.clock() - t0))

	local order = { "ERROR", "DISPATCHER", "ATTRS", "CAM", "KZ", "REMOTES", "LOOK", "LIGHTING", "PROBE", "STATUS" }
	for _, name in ipairs(order) do
		local t = sections[name]
		if t and #t > 0 then
			line("========== " .. name .. " ==========")
			for _, l in ipairs(t) do line(l) end
		end
	end

	line("========== AC_TRANSPORT (report codes + LoadingScreen) ==========")
	if #acReports > 0 then
		for _, l in ipairs(acReports) do line(l) end
	else
		line("(no B_XX / 0xXX report codes observed on any RemoteEvent)")
	end
	if #lsCalls > 0 then
		for _, l in ipairs(lsCalls) do line(l) end
	else
		line("(no LoadingScreen remote calls observed)")
	end

	line("========== GUI_SCANS (CoreGui/PlayerGui enumeration by game code) ==========")
	line(("[GUI_SCAN_COUNT] CoreGui=%d PlayerGui=%d"):format(guiScanCount.CoreGui, guiScanCount.PlayerGui))
	if #guiScans > 0 then
		for _, l in ipairs(guiScans) do line(l) end
	else
		line("(no suspicious container enumeration observed)")
	end

	line("========== FOV_TIMELINE (4Hz x 60s) ==========")
	for _, l in ipairs(fovSamples) do line(l) end

	line("========== CHANNELS ==========")
	local chList = {}
	for k, cm in pairs(channelMap) do
		chList[#chList + 1] = ("  %q n=%d sigs[%s] first[%s]"):format(
			k, cm.n,
			table.concat(cm.sigs, " // "),
			cm.sample and table.concat(cm.sample, " | ") or "")
	end
	table.sort(chList)
	for _, l in ipairs(chList) do line(l) end

	line("========== SHOTS (pre-encryption, up to 60) ==========")
	line("[SHOT_COUNT] " .. tostring(shotCount))
	for _, e in ipairs(shotDumps) do
		line(e.n)
		for _, l in ipairs(e.args) do line(l) end
	end

	if #lookSamples > 0 then
		line("========== LOOK_SAMPLES ==========")
		for _, l in ipairs(lookSamples) do line(l) end
	end

	if #decompFailLog > 0 then
		line("========== DECOMP_FAILURES ==========")
		for _, l in ipairs(decompFailLog) do line(l) end
	end

	line("=== END OF SCAN ===")

	local text = table.concat(out, "\n")
	pcall(function() setclipboard(text) end)
	-- save report to a file in the executor workspace (folder of the injector)
	local fileSaved = false
	pcall(function()
		writefile("plscan_report.txt", text)
		fileSaved = true
	end)
	if fileSaved then
		print("[PLScan v3] report SAVED to file: plscan_report.txt (executor/injector folder)")
	else
		print("[PLScan v3] writefile not available here - use clipboard (Ctrl+V) or copy from F9")
	end
	print(("[PLScan v3] output " .. #text .. "B - clipboard set, printing..."))
	for _, l in ipairs(out) do
		print(l)
	end
	print("[PLScan v3] === REPORT ENDS - copy ALL lines above (or use clipboard) and send back ===")
	if fileSaved then
		setFileState("file: plscan_report.txt SAVED (" .. #text .. " B)")
		setBanner("DONE!  FILE SAVED: plscan_report.txt\n(executor folder, next to plscan_started.txt) - send it", Color3.fromRGB(120, 230, 140))
	else
		setFileState("file: NOT saved -> clipboard + F9")
		setBanner("DONE!  no file access - report is in CLIPBOARD (Ctrl+V)\nand in F9 console. Paste it back.", Color3.fromRGB(255, 190, 80))
	end
	if infoLine then
		infoLine.Text = ("shots: %d | time: %ds | %s"):format(shotCount, math.floor(os.clock() - t0), fileState)
	end
	if body then
		if fileSaved then
			body.Text = ("Report saved to plscan_report.txt (" .. #text .. " B) and copied to clipboard.\nYou can close the game now.")
		else
			body.Text = ("DONE - " .. #text .. "B copied to clipboard (also printed to console/F9). Paste it back.")
		end
	end
end

if doneBtn then
	pcall(function()
		doneBtn.Activated:Connect(finish)
	end)
end
task.delay(300, finish)
