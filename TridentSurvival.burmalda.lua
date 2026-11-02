-- Burmalda.hook | Trident Survival | standalone runtime
-- Statically recovered from the supplied Trident sources. No external UI,
-- ESP, analytics or gameplay payloads are loaded by this file.
local Env = getgenv and getgenv() or _G
if Env.__BURMALDA_TRIDENT and type(Env.__BURMALDA_TRIDENT.Unload) == "function" then
  pcall(Env.__BURMALDA_TRIDENT.Unload)
end

local function ref(service)
  local ok, result = pcall(function() return game:GetService(service) end)
  if not ok then return nil end
  if cloneref then
    local clonedOk, cloned = pcall(cloneref, result)
    if clonedOk then return cloned end
  end
  return result
end

local players = ref("Players")
local replicatedStorage = ref("ReplicatedStorage")
local runService = ref("RunService")
local userInputService = ref("UserInputService")
local lighting = ref("Lighting")
local httpService = ref("HttpService")
local guiService = ref("GuiService")
local workspaceService = ref("Workspace") or workspace
local localPlayer = players and players.LocalPlayer
local camera = workspaceService and workspaceService.CurrentCamera
local guiInset = Vector2.new()
if guiService and guiService.GetGuiInset then
  local ok, inset = pcall(function() return guiService:GetGuiInset() end)
  if ok and typeof(inset) == "Vector2" then guiInset = inset end
end

local runtime = {
  Active = true,
  connections = {},
  restores = {},
  drawings = {},
  shotBullets = {},
  stats = { shots = 0, redirects = 0, remoteRedirects = 0, fallbacks = 0 },
  nextDiscovery = 0,
  nextTargetUpdate = 0,
  nextEquipUpdate = 0,
  nextEntityScan = 0,
}
Env.__BURMALDA_TRIDENT = runtime

local cfg = {
  Silent = {
    Enabled = false, HitChance = 100, AimPart = "Head", TargetNPCs = true,
    TeamCheck = true, IgnoreSleepers = true, VisibleOnly = false,
    Prediction = true, UseFOV = true, FOV = 180, ShowFOV = false,
    DynamicFOV = true, Snapline = false, TargetIndicator = false,
    MaxDistance = 1200,
  },
  Weapon = {
    NoRecoil = false, NoSpread = false, AlwaysShoot = false,
    ForceHeadshots = false, NoSlowdown = false,
  },
  ESP = {
    Enabled = false, Players = true, NPCs = true, Resources = false,
    Box = true, Names = true, Distance = true, Weapon = false,
    Tracers = false, Skeleton = false, TeamCheck = true, IgnoreSleepers = true,
    MaxDistance = 1600,
  },
  Visuals = {
    BigHead = false, HeadScale = 2, HeadTransparency = 0,
    FOVChanger = false, CustomFOV = 90, Zoom = false, ZoomFOV = 30,
  },
  Movement = {
    Speed = false, SpeedValue = 30, Fly = false, FlySpeed = 55,
    InfiniteJump = false, Gravity = false, GravityPercent = 100,
  },
  World = {
    Fullbright = false, RemoveFog = false, RemoveGrass = false,
    RemoveShadows = false, TimeChanger = false,
    ClockTime = lighting and lighting.ClockTime or 12,
  },
  Calamari = {},
}
runtime.cfg = cfg

local function trackConnection(connection)
  if connection then runtime.connections[#runtime.connections + 1] = connection end
  return connection
end
local function addRestore(callback)
  runtime.restores[#runtime.restores + 1] = callback
end
local function newDrawing(kind, properties)
  if not Drawing or not Drawing.new then return nil end
  local ok, object = pcall(Drawing.new, kind)
  if not ok then return nil end
  for key, value in pairs(properties or {}) do pcall(function() object[key] = value end) end
  runtime.drawings[#runtime.drawings + 1] = object
  return object
end
local function shallowCopy(source)
  if table.clone then
    local ok, result = pcall(table.clone, source)
    if ok then return result end
  end
  local result = {}
  for key, value in pairs(source) do result[key] = value end
  return result
end
local function getUpvalues(fn)
  if not (debug and debug.getupvalues and type(fn) == "function") then return {} end
  local ok, values, state, control = pcall(debug.getupvalues, fn)
  if not ok then return {} end
  if type(values) == "table" then return values end
  if type(values) ~= "function" then return {} end
  local result = {}
  for key, value in values, state, control do result[key] = value end
  return result
end
local function getUpvalue(fn, index)
  if debug and debug.getupvalue and type(fn) == "function" then
    local ok, value = pcall(debug.getupvalue, fn, index)
    if ok then return value end
  end
  return getUpvalues(fn)[index]
end
local function patchUpvalue(fn, key, replacement)
  if not (debug and debug.setupvalue) then return false end
  local original = getUpvalue(fn, key)
  local ok = pcall(debug.setupvalue, fn, key, replacement)
  if ok then
    addRestore(function() pcall(debug.setupvalue, fn, key, original) end)
  end
  return ok
end
local function patchField(container, key, replacement)
  if type(container) ~= "table" or type(rawget(container, key)) ~= "function" then return false end
  local original = rawget(container, key)
  local ok = pcall(rawset, container, key, replacement)
  if ok then addRestore(function() pcall(rawset, container, key, original) end) end
  return ok
end

local NPC_TYPES = {
  Soldier = true, Officer = true, General = true, Ghoul = true,
  LabWorker = true, GasMaskSoldier = true,
}
local RESOURCE_NAMES = {
  IronOre = "Iron", StoneOre = "Stone", NitrateOre = "Nitrate",
  Backpack = "Backpack", ClaimTotem = "Totem", MetalCrate = "Metal Crate",
}
local BODY_PARTS = {
  Head = true, Torso = true, HumanoidRootPart = true,
  RightUpperArm = true, RightLowerArm = true, RightHand = true,
  LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
  RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
  LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
}
local SKELETON = {
  { "Head", "Torso" }, { "Torso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" },
  { "Torso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" },
  { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" },
  { "Torso", "LowerTorso" }, { "RightUpperLeg", "RightLowerLeg" },
  { "LowerTorso", "RightUpperLeg" }, { "LeftLowerLeg", "LeftFoot" },
  { "RightLowerLeg", "RightFoot" }, { "RightLowerArm", "RightHand" },
  { "LeftLowerArm", "LeftHand" },
}

local function findChild(parent, name)
  if not parent then return nil end
  local ok, result = pcall(function() return parent:FindFirstChild(name) end)
  return ok and result or nil
end
local function getLocalCharacter()
  return localPlayer and localPlayer.Character
end
local function getLocalParts()
  local character = getLocalCharacter()
  return character, character and findChild(character, "HumanoidRootPart"),
    character and findChild(character, "Humanoid")
end
local function getIgnoreFolder()
  local const = workspaceService and findChild(workspaceService, "Const")
  return const and findChild(const, "Ignore")
end
local function getTridentRig()
  local ignore = getIgnoreFolder()
  local model = ignore and findChild(ignore, "LocalCharacter")
  if not model then return nil, nil end
  local parts = {}
  for _, name in ipairs({ "Middle", "Bottom", "Top" }) do
    local part = findChild(model, name)
    if part then parts[#parts + 1] = part end
  end
  if #parts == 0 then return nil, nil end
  return model, parts
end
runtime.GetTridentRig = getTridentRig

local function cacheScore(cache)
  if type(cache) ~= "table" then return 0 end
  local score = 0
  for _, entity in pairs(cache) do
    if type(entity) == "table" and rawget(entity, "model") and rawget(entity, "type") then
      score = score + 1
      if score >= 8 then break end
    end
  end
  return score
end
local function selectCache(functions, fallback)
  local best, bestScore = nil, 0
  for _, fn in pairs(functions) do
    for _, value in pairs(getUpvalues(fn)) do
      if type(value) == "table" then
        local score = cacheScore(value)
        if score > bestScore then best, bestScore = value, score end
      end
    end
  end
  return best or fallback
end

local function functionInfo(fn)
  local source, name = "", ""
  if debug and type(debug.info) == "function" then
    local okSource, value = pcall(debug.info, fn, "s")
    if okSource then source = tostring(value or "") end
    local okName, value = pcall(debug.info, fn, "n")
    if okName then name = tostring(value or "") end
  end
  if debug and type(debug.getinfo) == "function" then
    local ok, info = pcall(debug.getinfo, fn)
    if ok and type(info) == "table" then
      if source == "" then source = tostring(info.source or info.short_src or "") end
      if name == "" then name = tostring(info.name or "") end
    end
  end
  return source, name
end
local function hasFirstConstant(fn, expected)
  if not debug or type(fn) ~= "function" then return false end
  if type(debug.getconstants) == "function" then
    local ok, constants = pcall(debug.getconstants, fn)
    return ok and type(constants) == "table" and constants[1] == expected or false
  end
  if type(debug.getconstant) == "function" then
    local ok, value = pcall(debug.getconstant, fn, 1)
    return ok and value == expected or false
  end
  return false
end

local function discoverModules()
  if runtime.classes and runtime.cacheValidated then return true end
  if not getgc then runtime.discoveryError = "getgc unavailable" return false end
  local ok, garbage = pcall(getgc, true)
  if not ok or type(garbage) ~= "table" then
    runtime.discoveryError = "getgc failed"
    return false
  end
  local classes = runtime.classes
  local weaponTables = {}
  local playerUpdate = nil
  for _, value in pairs(garbage) do
    if type(value) == "function" then
      local source, name = functionInfo(value)
      if source:find("RangedWeaponClient", 1, true) and hasFirstConstant(value, "ProjectileSpeed") then
        runtime.discoveredCreateProjectile = value
      elseif source:find("PlayerClient", 1, true) and name == "updatePlayers" then
        playerUpdate = value
      end
    elseif type(value) == "table" then
      if rawget(value, "Damage") ~= nil or rawget(value, "recoilOffset") ~= nil
        or type(rawget(value, "AimRecoil")) == "table" or type(rawget(value, "HipRecoil")) == "table"
        or type(rawget(value, "RecoilData")) == "table" then
        weaponTables[#weaponTables + 1] = value
      end
      if type(rawget(value, "updateCharacter")) == "function" then
        runtime.sprintCharacter = value
      end
      local entityClient = rawget(value, "EntityClient")
      if type(entityClient) == "table" and type(rawget(entityClient, "GetEntityFromPart")) == "function" then
        classes = value
      end
      if not classes then
        local cameraClass = rawget(value, "Camera")
        if type(cameraClass) == "table" and rawget(cameraClass, "type") == "Camera" then
          classes = value
        end
      end
    end
  end
  if not classes then runtime.discoveryError = "Trident classes not found" return false end
  runtime.weaponTables = weaponTables
  runtime.classes = classes
  local entityClient = rawget(classes, "EntityClient")
  local getEntity = entityClient and rawget(entityClient, "GetEntityFromPart")
  local createEntity = entityClient and rawget(entityClient, "Create")
  local fallbackCache = getUpvalue(getEntity, 1)
  if type(fallbackCache) ~= "table" then fallbackCache = getUpvalue(createEntity, 2) end
  runtime.entityCache = selectCache({ getEntity, createEntity }, fallbackCache)
  local playerClient = rawget(classes, "PlayerClient")
  local npcClient = rawget(classes, "NPCClient")
  local onDestroy = playerClient and rawget(playerClient, "OnDestroy")
  local onCreate = npcClient and rawget(npcClient, "OnCreate")
  runtime.playerCache = selectCache({ onDestroy, playerUpdate },
    getUpvalue(onDestroy, 1) or getUpvalue(playerUpdate, 1))
  runtime.npcCache = selectCache({ onCreate }, getUpvalue(onCreate, 1))
  runtime.validTypes = { Player = true }
  for name in pairs(NPC_TYPES) do runtime.validTypes[name] = true end
  local shared = findChild(replicatedStorage, "Shared")
  local entities = findChild(shared, "entities")
  local npcFolder = findChild(entities, "NPC")
  if npcFolder then
    for _, child in ipairs(npcFolder:GetChildren()) do runtime.validTypes[child.Name] = true end
  end
  runtime.cacheValidated = cacheScore(runtime.entityCache) > 0
    and type(runtime.playerCache) == "table" and type(runtime.npcCache) == "table"
  runtime.discoveryError = runtime.cacheValidated and nil or "Trident entity cache not found"
  return true
end
runtime.DiscoverModules = discoverModules

local function classifyEntity(entity)
  if type(entity) ~= "table" then return nil end
  local model = rawget(entity, "model")
  if not model then return nil end
  local entityType = tostring(rawget(entity, "type") or "")
  if RESOURCE_NAMES[entityType] then return "resource", RESOURCE_NAMES[entityType] end
  local validTypes = runtime.validTypes or NPC_TYPES
  if entityType == "Player" then return "player", "Player" end
  if validTypes[entityType] or NPC_TYPES[entityType] then return "npc", entityType end
  return nil
end

local WORLD_RESOURCE_TYPES = {
  IronOre = "IronOre", Iron = "IronOre", StoneOre = "StoneOre", Stone = "StoneOre",
  NitrateOre = "NitrateOre", Nitrate = "NitrateOre", Backpack = "Backpack",
  ClaimTotem = "ClaimTotem", MetalCrate = "MetalCrate",
}
local function scanWorldResources()
  local now = os.clock()
  if runtime.worldResources and now < (runtime.nextEntityScan or 0) then return runtime.worldResources end
  runtime.nextEntityScan = now + 1
  local result, seen = {}, {}
  local function visit(model)
    if not model or seen[model] or not model.Parent then return end
    local entityType = WORLD_RESOURCE_TYPES[tostring(model.Name)]
    if not entityType then return end
    seen[model] = true
    result[#result + 1] = { model = model, type = entityType, name = RESOURCE_NAMES[entityType] }
  end
  if workspaceService and workspaceService.GetChildren then
    local ok, children = pcall(function() return workspaceService:GetChildren() end)
    if ok then for _, child in ipairs(children) do visit(child) end end
  end
  runtime.worldResources = result
  return result
end
local function eachEntity(callback, includeResources)
  local seen = {}
  local function visit(entity)
    local kind, label = classifyEntity(entity)
    if not kind then return end
    local model = rawget(entity, "model")
    if seen[model] then return end
    seen[model] = true
    callback(entity, model, kind, label)
  end
  for _, cache in ipairs({ runtime.entityCache, runtime.playerCache, runtime.npcCache }) do
    if type(cache) == "table" then for _, entity in pairs(cache) do visit(entity) end end
  end
  if includeResources ~= false then
    for _, entity in ipairs(scanWorldResources()) do visit(entity) end
  end
  if players and players.GetPlayers then
    for _, player in ipairs(players:GetPlayers()) do
      if player ~= localPlayer and player.Character and not seen[player.Character] then
        seen[player.Character] = true
        callback({ model = player.Character, type = "Player", player = player, name = player.Name },
          player.Character, "player", "Player")
      end
    end
  end
end

local function isLocalEntity(entity, model)
  if model == getLocalCharacter() then return true end
  local player = rawget(entity, "player")
  return player ~= nil and player == localPlayer
end
local function isTeammate(model)
  local head = findChild(model, "Head")
  local tag = head and findChild(head, "Teamtag")
  return tag and tag.Enabled == true or false
end
local function isSleeper(entity, model)
  if rawget(entity, "sleeping") == true then return true end
  local lowerTorso = findChild(model, "LowerTorso")
  local rootRig = lowerTorso and findChild(lowerTorso, "RootRig")
  return rootRig and typeof(rootRig.CurrentAngle) == "number" and rootRig.CurrentAngle ~= 0 or false
end
runtime.IsSleeper = isSleeper
local function entityName(entity, label)
  local player = rawget(entity, "player")
  if player then return tostring(player.DisplayName or player.Name or label) end
  return tostring(rawget(entity, "name") or label or rawget(entity, "type") or "Entity")
end
local function entityWeapon(entity, model)
  local equipped = rawget(entity, "equippedItem") or rawget(entity, "EquippedItem")
  if type(equipped) == "table" then
    return tostring(rawget(equipped, "name") or rawget(equipped, "type") or "Unknown")
  end
  local tool = model and model:FindFirstChildOfClass("Tool")
  return tool and tostring(tool.Name) or "Unarmed"
end
local function aimPart(model, preferred)
  return findChild(model, preferred or cfg.Silent.AimPart)
    or findChild(model, "Torso") or findChild(model, "HumanoidRootPart")
    or findChild(model, "Head") or model.PrimaryPart
end

local function screenPoint(position)
  if not camera then return Vector2.new(), false, -1 end
  local ok, point, visible = pcall(function() return camera:WorldToViewportPoint(position) end)
  if not ok then return Vector2.new(), false, -1 end
  return Vector2.new(point.X, point.Y), visible == true, point.Z
end
local function mousePosition()
  if userInputService and userInputService.GetMouseLocation then
    local ok, position = pcall(function() return userInputService:GetMouseLocation() end)
    if ok then return position + guiInset end
  end
  return camera and Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2) or Vector2.new()
end
local function currentFovRadius()
  local fieldOfView = camera and camera.FieldOfView or 70
  if cfg.Silent.DynamicFOV and fieldOfView > 0 then return cfg.Silent.FOV * (70 / fieldOfView) end
  return cfg.Silent.FOV
end
local function visibleFrom(origin, position, model)
  local params = RaycastParams.new()
  params.FilterDescendantsInstances = { model, getLocalCharacter(), camera, getIgnoreFolder() }
  params.FilterType = Enum.RaycastFilterType.Blacklist
  params.CollisionGroup = "WeaponRaycast"
  params.IgnoreWater = true
  local ok, result = pcall(function() return workspaceService:Raycast(origin, position - origin, params) end)
  return ok and result == nil
end

local function updateTarget()
  runtime.currentTarget = nil
  if not (runtime.Active and cfg.Silent.Enabled and camera) then return end
  local bestDistance = math.huge
  local mouse = mousePosition()
  local origin = camera.CFrame.Position
  local radius = currentFovRadius()
  eachEntity(function(entity, model, kind, label)
    if kind == "resource" or isLocalEntity(entity, model) then return end
    if kind == "npc" and not cfg.Silent.TargetNPCs then return end
    if cfg.Silent.TeamCheck and isTeammate(model) then return end
    if cfg.Silent.IgnoreSleepers and isSleeper(entity, model) then return end
    local part = aimPart(model)
    if not part or not part.Parent then return end
    local worldDistance = (part.Position - origin).Magnitude
    if worldDistance > cfg.Silent.MaxDistance then return end
    local screen, onScreen, depth = screenPoint(part.Position)
    if depth <= 0 or (cfg.Silent.UseFOV and not onScreen) then return end
    local fovDistance = (screen - mouse).Magnitude
    if cfg.Silent.UseFOV and fovDistance > radius then return end
    if cfg.Silent.VisibleOnly and not visibleFrom(origin, part.Position, model) then return end
    if fovDistance < bestDistance then
      bestDistance = fovDistance
      runtime.currentTarget = {
        entity = entity, model = model, part = part, kind = kind,
        name = entityName(entity, label), screen = screen,
      }
    end
  end)
end
runtime.UpdateTarget = updateTarget

local function refreshEquipped()
  runtime.equippedItem = nil
  runtime.equippedInfo = nil
  local classes = runtime.classes
  local fps = classes and rawget(classes, "FPS")
  local getEquipped = fps and rawget(fps, "GetEquippedItem")
  local item = getUpvalue(getEquipped, 1)
  if type(item) ~= "table" then return end
  runtime.equippedItem = item
  if rawget(item, "ProjectileSpeed") ~= nil then
    runtime.equippedInfo = item
  else
    local itemType = rawget(item, "type")
    runtime.equippedInfo = classes and rawget(classes, itemType) or nil
  end
end
runtime.RefreshEquipped = refreshEquipped

local function weaponInfo(weaponData)
  if type(weaponData) == "table" and rawget(weaponData, "ProjectileSpeed") ~= nil then return weaponData end
  if runtime.equippedInfo then return runtime.equippedInfo end
  refreshEquipped()
  return runtime.equippedInfo
end
local function predictedPosition(origin, target, info)
  local position = target.part.Position
  if not cfg.Silent.Prediction then return position end
  local speed = info and rawget(info, "ProjectileSpeed")
  local drop = info and rawget(info, "ProjectileDrop") or 0
  if type(speed) ~= "number" or speed <= 0 or type(drop) ~= "number" then return position end
  local entity = target.entity
  local velocity = nil
  local goal, start = rawget(entity, "goalPosition"), rawget(entity, "startPosition")
  if typeof(goal) == "Vector3" and typeof(start) == "Vector3" then
    velocity = (goal - start) / 0.15 * Vector3.new(1, 0, 1)
  elseif typeof(rawget(entity, "velocityVector")) == "Vector3" then
    velocity = rawget(entity, "velocityVector") * 7.4
  elseif typeof(target.part.AssemblyLinearVelocity) == "Vector3" then
    velocity = target.part.AssemblyLinearVelocity
  else
    velocity = Vector3.zero
  end
  local time = (position - origin).Magnitude / speed
  local predicted = position + velocity * time
  time = (predicted - origin).Magnitude / speed
  predicted = position + velocity * time
  local exponent = time * drop
  local offset = drop ^ exponent - 1
  if offset ~= offset or offset == math.huge or offset == -math.huge then return predicted end
  return predicted + Vector3.yAxis * offset
end
local function computeSilentCFrame(origin, weaponData)
  if not (runtime.Active and cfg.Silent.Enabled) then return nil end
  updateTarget()
  local target = runtime.currentTarget
  if not target or not target.part or not target.part.Parent then return nil end
  if math.random(0, 99) >= (cfg.Silent.HitChance or 100) then return nil end
  local info = weaponInfo(weaponData)
  local position = predictedPosition(origin, target, info)
  if not position then return nil end
  return CFrame.lookAt(origin, position), position
end
runtime.ComputeSilentCFrame = computeSilentCFrame

local function setPendingShot(cframe, hitPosition)
  runtime.pendingShot = { cframe = cframe, hitPosition = hitPosition, at = os.clock() }
  runtime.stats.redirects = runtime.stats.redirects + 1
end

local function calamariShotVisuals()
  local api = runtime.CalamariVisuals
  return api and (api.State.Bullet.Enabled or api.State.HitEffects.Enabled or api.State.HitNotifications.Enabled) or false
end
local function observeCalamariShot(cframe, source)
  if not runtime.Active or not calamariShotVisuals() or typeof(cframe) ~= "CFrame" then return end
  local origin, direction = cframe.Position, cframe.LookVector
  if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" or direction.Magnitude <= 0 then return end
  local now = os.clock()
  local previous = runtime.calamariLastVisualShot
  -- CreateProjectile and Fire can describe the same shot. Dedupe only across
  -- sources; repeated rounds from one source must remain visible.
  if previous and previous.Source ~= source and now - previous.At <= 0.15
    and (previous.Origin - origin).Magnitude < 2 and (previous.Direction - direction).Magnitude < 0.08 then
    return
  end
  runtime.calamariLastVisualShot = {At = now, Source = source, Origin = origin, Direction = direction}
  local api = runtime.CalamariVisuals
  if api and type(api.TraceShot) == "function" then pcall(api.TraceShot, origin, direction, 1000) end
end

local function installCreateProjectileHook()
  local classes = runtime.classes
  local ranged = classes and rawget(classes, "RangedWeaponClient")
  local fieldFunction = ranged and rawget(ranged, "CreateProjectile")
  local targetFunction = runtime.discoveredCreateProjectile or fieldFunction
  if type(targetFunction) ~= "function" or runtime.createProjectileInstalled then return false end
  local original = targetFunction
  local wrapper = function(startCFrame, weaponData, isLocal, ...)
    runtime.stats.shots = runtime.stats.shots + 1
    if runtime.Active and isLocal then
      runtime.createProjectileObserved = true
      runtime.lastLocalProjectileAt = os.clock()
      runtime.pendingShot = nil
    end
    if not runtime.Active or not isLocal or not cfg.Silent.Enabled then
      if runtime.Active and isLocal then observeCalamariShot(startCFrame, "projectile") end
      return original(startCFrame, weaponData, isLocal, ...)
    end
    local origin = typeof(startCFrame) == "CFrame" and startCFrame.Position
      or (camera and camera.CFrame.Position) or Vector3.zero
    local ok, silentCFrame, hitPosition = pcall(computeSilentCFrame, origin, weaponData)
    if ok and silentCFrame then
      startCFrame = silentCFrame
      setPendingShot(silentCFrame, hitPosition)
      runtime.silentMode = "CreateProjectile"
    elseif not ok then
      runtime.silentError = tostring(silentCFrame)
      runtime.stats.fallbacks = runtime.stats.fallbacks + 1
    end
    observeCalamariShot(startCFrame, "projectile")
    return original(startCFrame, weaponData, isLocal, ...)
  end
  if type(hookfunction) == "function" then
    local ok, previous = pcall(hookfunction, targetFunction, wrapper)
    if ok and type(previous) == "function" then
      original = previous
      runtime.createProjectileInstalled = true
      runtime.createProjectileMode = "function"
      runtime.originalCreateProjectile = original
      runtime.silentMode = "CreateProjectile"
      addRestore(function()
        if type(restorefunction) == "function" then
          pcall(restorefunction, targetFunction)
        elseif type(hookfunction) == "function" then
          pcall(hookfunction, targetFunction, previous)
        end
      end)
      return true
    end
    if ok and type(restorefunction) == "function" then pcall(restorefunction, targetFunction) end
  end
  if type(fieldFunction) == "function" then
    original = fieldFunction
    if patchField(ranged, "CreateProjectile", wrapper) then
      runtime.createProjectileInstalled = true
      runtime.createProjectileMode = "field"
      runtime.originalCreateProjectile = original
      runtime.silentMode = "CreateProjectile"
      return true
    end
  end
  return false
end

local function installSkewedOriginHooks()
  if not (getfenv and debug and debug.getupvalues and debug.setupvalue) then return false end
  local classes = runtime.classes
  local installed = false
  for _, moduleName in ipairs({ "BowClient", "RangedWeaponClient" }) do
    local module = classes and rawget(classes, moduleName)
    local fire = module and rawget(module, "Fire")
    if type(fire) == "function" then
      local ok, environment = pcall(getfenv, fire)
      local skewed = ok and type(environment) == "table" and rawget(environment, "getSkewedOrigin")
      if type(skewed) == "function" then
        for key, value in pairs(getUpvalues(skewed)) do
          if value == CFrame.fromOrientation then
            local originalOrientation = value
            local replacement = function(...)
              if runtime.Active and cfg.Silent.Enabled and not runtime.createProjectileObserved then
                local callerMatches = true
                if debug.info then
                  local infoOk, caller = pcall(debug.info, 3, "f")
                  callerMatches = infoOk and caller == fire
                end
                if callerMatches and debug.getstack and debug.setstack then
                  local stackOk, stack = pcall(debug.getstack, 2)
                  if stackOk and type(stack) == "table" and typeof(stack[1]) == "CFrame" then
                    local cfOk, silentCFrame, hitPosition = pcall(computeSilentCFrame, stack[1].Position, nil)
                    if cfOk and silentCFrame then
                      local setOk = pcall(debug.setstack, 2, 1, silentCFrame)
                      if setOk then
                        runtime.skewedObserved = true
                        setPendingShot(silentCFrame, hitPosition)
                        runtime.silentMode = "getSkewedOrigin"
                      end
                    end
                  end
                end
              end
              return originalOrientation(...)
            end
            if patchUpvalue(skewed, key, replacement) then
              installed = true
              runtime.skewedInstalled = true
              if not runtime.createProjectileInstalled then runtime.silentMode = "getSkewedOrigin" end
            end
            break
          end
        end
      end
    end
  end
  return installed
end

local function installCharacterModuleClones()
  if runtime.characterClonesInstalled then return true end
  if not (debug and debug.getupvalues and debug.setupvalue) then return false end
  local classes = runtime.classes
  local character = classes and rawget(classes, "Character")
  local fps = classes and rawget(classes, "FPS")
  if not (character and fps) then return false end
  local clones = { Character = shallowCopy(character), FPS = shallowCopy(fps) }
  local patched = 0
  local functionsToPatch = {
    rawget(character, "SetVehicle"), rawget(fps, "EquipItem"),
  }
  -- These are gun modifiers. Do not clone/patch MeleeClient or MiningDrillClient:
  -- their ordinary swing/hit path must remain the game's original path.
  for _, name in ipairs({ "BowClient", "RangedWeaponClient", "FlameThrowerClient", "DebugWandClient" }) do
    local module = rawget(classes, name)
    functionsToPatch[#functionsToPatch + 1] = module and rawget(module, "Update")
  end
  for _, fn in ipairs(functionsToPatch) do
    if type(fn) == "function" then
      for key, value in pairs(getUpvalues(fn)) do
        if value == character and patchUpvalue(fn, key, clones.Character) then patched = patched + 1 break end
        if value == fps and patchUpvalue(fn, key, clones.FPS) then patched = patched + 1 break end
      end
    end
  end
  runtime.moduleClones = clones
  runtime.characterClonesInstalled = patched > 0
  return patched > 0
end

local sprintBlockStates = {}
local function restoreSprintBlock()
  for environment, state in pairs(sprintBlockStates) do
    pcall(rawset, environment, "sprintBlocked", state.value)
    sprintBlockStates[environment] = nil
  end
  runtime.sprintBlockState = nil
end
addRestore(restoreSprintBlock)
local function resetSprintBlock(environment, allowMissing)
  if type(environment) ~= "table" then return end
  if not allowMissing and type(rawget(environment, "sprintBlocked")) ~= "boolean" then return end
  local state = sprintBlockStates[environment]
  if not state then
    state = { environment = environment, value = rawget(environment, "sprintBlocked") }
    sprintBlockStates[environment] = state
  end
  runtime.sprintBlockState = state
  pcall(rawset, environment, "sprintBlocked", false)
end
local function updateSprintBlock()
  if not cfg.Weapon.NoSlowdown then restoreSprintBlock() return end
  resetSprintBlock(runtime.sprintCharacter, true)
  local classes = runtime.classes
  local character = classes and rawget(classes, "Character")
  local setter = character and rawget(character, "SetSprintBlocked")
  if type(setter) ~= "function" or type(getfenv) ~= "function" then return end
  local ok, environment = pcall(getfenv, setter)
  if ok then resetSprintBlock(environment) end
end
local function updateModuleClones()
  local classes, clones = runtime.classes, runtime.moduleClones
  updateSprintBlock()
  if not (classes and clones) then return end
  local character, fps = rawget(classes, "Character"), rawget(classes, "FPS")
  clones.Character.IsGrounded = cfg.Weapon.AlwaysShoot and function() return true end or rawget(character, "IsGrounded")
  clones.Character.IsSwimming = cfg.Weapon.AlwaysShoot and function() return false end or rawget(character, "IsSwimming")
  clones.Character.GetPilotedVehicle = cfg.Weapon.AlwaysShoot and function() return nil end or rawget(character, "GetPilotedVehicle")
  clones.Character.SetSprintBlocked = cfg.Weapon.NoSlowdown and function() end or rawget(character, "SetSprintBlocked")
  clones.FPS.UnEquipItem = cfg.Weapon.AlwaysShoot and function() end or rawget(fps, "UnEquipItem")
end
runtime.UpdateModuleClones = updateModuleClones

local function remoteCode(name)
  local classes = runtime.classes
  local sendCodes = classes and rawget(classes, "SendCodes")
  return sendCodes and rawget(sendCodes, name) or nil
end
local function isGameRemote(instance)
  if not localPlayer then return false end
  if instance == findChild(localPlayer, "TCP") or instance == findChild(localPlayer, "UDP") then return true end
  return instance.Parent == localPlayer and (tostring(instance) == "TCP" or tostring(instance) == "UDP")
end
local NON_RANGED_TYPES = {
  melee = true, miningdrill = true, drill = true, hatchet = true, pickaxe = true,
  crowbar = true, hammer = true, kabar = true, tool = true,
}
local function validRangedInfo(item, info)
  if type(item) ~= "table" or type(info) ~= "table" then return nil end
  local itemType = string.lower(tostring(rawget(item, "type") or ""))
  if itemType == "" or NON_RANGED_TYPES[itemType] then return nil end
  local speed = rawget(info, "ProjectileSpeed")
  local drop = rawget(info, "ProjectileDrop")
  if type(speed) ~= "number" or speed <= 0 or type(drop) ~= "number" then return nil end
  return info
end
local function getRangedWeaponInfo()
  refreshEquipped()
  local item, info = runtime.equippedItem, runtime.equippedInfo
  return validRangedInfo(item, info)
end
runtime.GetRangedWeaponInfo = getRangedWeaponInfo

local weaponModOriginals = { Recoil = {}, Spread = {}, AutoShoot = {} }
local function restoreWeaponModGroup(group)
  for container, values in pairs(weaponModOriginals[group]) do
    for key, state in pairs(values) do pcall(rawset, container, key, state.value) end
  end
  weaponModOriginals[group] = {}
  if group == "Recoil" then runtime.recoilInstalled = false end
  if group == "Spread" then runtime.spreadInstalled = false end
  if group == "AutoShoot" then runtime.autoShootInstalled = false end
end
local function restoreWeaponDataMods()
  restoreWeaponModGroup("Recoil")
  restoreWeaponModGroup("Spread")
  restoreWeaponModGroup("AutoShoot")
end
addRestore(restoreWeaponDataMods)
local function writeWeaponValue(group, container, key, value)
  local values = weaponModOriginals[group][container]
  if not values then
    values = {}
    weaponModOriginals[group][container] = values
  end
  if not values[key] then values[key] = { value = rawget(container, key) } end
  pcall(rawset, container, key, value)
end
local function refreshWeaponModTables()
  if not runtime.weaponModsNeedScan or not getgc then return end
  local ok, garbage = pcall(getgc, true)
  if not ok or type(garbage) ~= "table" then return end
  local tables, seen = {}, {}
  for _, value in pairs(garbage) do
    if type(value) == "table" and not seen[value] then
      seen[value] = true
      if rawget(value, "Damage") ~= nil or rawget(value, "recoilOffset") ~= nil
        or type(rawget(value, "AimRecoil")) == "table" or type(rawget(value, "HipRecoil")) == "table"
        or type(rawget(value, "RecoilData")) == "table" then
        tables[#tables + 1] = value
      end
      if type(rawget(value, "updateCharacter")) == "function" then
        runtime.sprintCharacter = value
      end
    end
  end
  runtime.weaponTables = tables
  runtime.weaponModsNeedScan = false
end
local function rangedWeaponTable(info)
  if type(info) ~= "table" or rawget(info, "Damage") == nil then return false end
  local speed = rawget(info, "ProjectileSpeed")
  if type(speed) ~= "number" or speed <= 0 then return false end
  return not NON_RANGED_TYPES[string.lower(tostring(rawget(info, "type") or ""))]
end
local function applyWeaponDataMods()
  refreshWeaponModTables()
  if cfg.Weapon.NoRecoil then
    for _, info in ipairs(runtime.weaponTables or {}) do
      local recoilOffset = rawget(info, "recoilOffset")
      if typeof(recoilOffset) == "CFrame" then
        writeWeaponValue("Recoil", info, "recoilOffset", CFrame.new())
      elseif type(recoilOffset) == "number" then
        writeWeaponValue("Recoil", info, "recoilOffset", 0)
      end
      for _, key in ipairs({ "recoilLerpSpeed", "recoilReturnSpeed" }) do
        if type(rawget(info, key)) == "number" then writeWeaponValue("Recoil", info, key, 0) end
      end
      for _, key in ipairs({ "AimRecoil", "HipRecoil", "RecoilData" }) do
        local nested = rawget(info, key)
        if type(nested) == "table" then
          for nestedKey, value in pairs(nested) do
            if type(value) == "number" then
              writeWeaponValue("Recoil", nested, nestedKey, 0)
            elseif typeof(value) == "CFrame" then
              writeWeaponValue("Recoil", nested, nestedKey, CFrame.new())
            elseif typeof(value) == "Vector3" then
              writeWeaponValue("Recoil", nested, nestedKey, Vector3.zero)
            end
          end
        end
      end
    end
  else
    restoreWeaponModGroup("Recoil")
  end
  runtime.recoilInstalled = next(weaponModOriginals.Recoil) ~= nil
  if cfg.Weapon.NoSpread then
    for _, info in ipairs(runtime.weaponTables or {}) do
      if rangedWeaponTable(info) then
        local accuracyKey
        for key in pairs(info) do
          if string.find(string.lower(tostring(key)), "accuracy", 1, true) then accuracyKey = key end
        end
        if accuracyKey then writeWeaponValue("Spread", info, accuracyKey, math.huge) end
      end
    end
  else
    restoreWeaponModGroup("Spread")
  end
  runtime.spreadInstalled = next(weaponModOriginals.Spread) ~= nil
  if cfg.Weapon.AlwaysShoot then
    for _, info in ipairs(runtime.weaponTables or {}) do
      if rangedWeaponTable(info) then
        local fireActionKey
        for key in pairs(info) do
          local name = string.lower(tostring(key))
          if string.find(name, "fire", 1, true)
            and (string.find(name, "action", 1, true) or string.find(name, "mode", 1, true)) then
            fireActionKey = key
          end
        end
        if fireActionKey then writeWeaponValue("AutoShoot", info, fireActionKey, "auto") end
      end
    end
  else
    restoreWeaponModGroup("AutoShoot")
  end
  runtime.autoShootInstalled = next(weaponModOriginals.AutoShoot) ~= nil
end
runtime.ApplyWeaponDataMods = applyWeaponDataMods

local function combatEntity(entityId)
  if type(entityId) == "table" then
    local kind = classifyEntity(entityId)
    if kind == "player" or kind == "npc" then return entityId end
    return nil
  end
  for _, cache in ipairs({ runtime.entityCache, runtime.playerCache, runtime.npcCache }) do
    if type(cache) == "table" then
      local entity = cache[entityId]
      if not entity and type(entityId) == "number" then entity = cache[tostring(entityId)] end
      if not entity and type(entityId) == "string" then entity = cache[tonumber(entityId)] end
      if entity then
        local kind = classifyEntity(entity)
        if kind == "player" or kind == "npc" then return entity end
        return nil
      end
    end
  end
  return false
end
local function processRemote(args)
  local code = args[1]
  if code == remoteCode("INV_EQUIP_ITEM") or code == remoteCode("INV_UNEQUIP_ITEM") then
    runtime.nextEquipUpdate = 0
    runtime.pendingShot = nil
    return
  end
  local useItem = remoteCode("INV_USE_ITEM")
  if code ~= useItem and code ~= 10 then return end
  local action = args[2]
  local count = args.n or #args
  if action == "Fire" then
    if not runtime.Active or typeof(args[4]) ~= "CFrame" then return end
    if not cfg.Silent.Enabled then
      observeCalamariShot(args[4], "remote")
      return
    end
    if not getRangedWeaponInfo() then
      observeCalamariShot(args[4], "remote")
      return
    end
    local pending = runtime.pendingShot
    runtime.pendingShot = nil
    local hitPosition = nil
    if pending and os.clock() - pending.at <= 0.75 then
      args[4] = pending.cframe
      hitPosition = pending.hitPosition
      runtime.stats.remoteRedirects = runtime.stats.remoteRedirects + 1
    elseif not runtime.createProjectileObserved and not runtime.skewedObserved then
      local silentCFrame, predictedHit = computeSilentCFrame(camera.CFrame.Position, nil)
      if silentCFrame then
        args[4] = silentCFrame
        hitPosition = predictedHit
        runtime.stats.remoteRedirects = runtime.stats.remoteRedirects + 1
        runtime.silentMode = "Remote"
      end
    end
    if hitPosition and args[3] ~= nil then runtime.shotBullets[args[3]] = hitPosition end
    observeCalamariShot(args[4], "remote")
  elseif action == "Hit" then
    if not runtime.Active or not cfg.Weapon.ForceHeadshots then return end
    local partIndex, entityIndex, positionIndex
    if count == 8 then
      if type(args[5]) ~= "number" or type(args[6]) ~= "string" or typeof(args[7]) ~= "Vector3" then return end
      partIndex, entityIndex, positionIndex = 6, 5, 7
    elseif count == 7 then
      if type(args[4]) ~= "number" or type(args[5]) ~= "string" or typeof(args[6]) ~= "Vector3" then return end
      partIndex, entityIndex, positionIndex = 5, 4, 6
    else return end
    local trackedPosition = count == 8 and runtime.shotBullets[args[3]] or nil
    if not trackedPosition and not getRangedWeaponInfo() then return end
    local entity = combatEntity(args[entityIndex])
    local model = entity and rawget(entity, "model")
    if not model or not findChild(model, "Head") then return end
    if count == 8 then runtime.shotBullets[args[3]] = nil end
    if BODY_PARTS[args[partIndex]] then
      args[partIndex] = "Head"
      args[positionIndex] = trackedPosition or Vector3.zero
    end
  end
end
runtime.ProcessRemote = processRemote

local function installRemoteHook()
  if runtime.remoteInstalled then return true end
  local handler
  local original
  local metatable
  if getrawmetatable then
    local ok, value = pcall(getrawmetatable, game)
    if ok and value then
      metatable = value
      local old = rawget(value, "__namecall")
      if type(old) == "function" then original = old end
    end
  end
  local function executorCall()
    if type(checkcaller) ~= "function" then return false end
    local ok, value = pcall(checkcaller)
    return ok and value == true
  end
  handler = function(self, ...)
    if executorCall() then return original(self, ...) end
    local method
    if getnamecallmethod then
      local ok, value = pcall(getnamecallmethod)
      if ok then method = value end
    end
    if method == "FireServer" and isGameRemote(self) then
      local args = table.pack(...)
      local ok, err = pcall(processRemote, args)
      if not ok then runtime.remoteError = tostring(err) end
      return original(self, table.unpack(args, 1, args.n))
    end
    return original(self, ...)
  end
  if newcclosure then handler = newcclosure(handler) end
  if hookmetamethod then
    local ok, result = pcall(hookmetamethod, game, "__namecall", handler)
    if ok then
      if type(result) == "function" then original = result end
      if type(original) == "function" then
        runtime.remoteInstalled = true
        addRestore(function() pcall(hookmetamethod, game, "__namecall", original) end)
        return true
      end
    end
  end
  if metatable and setreadonly and type(rawget(metatable, "__namecall")) == "function" then
    original = rawget(metatable, "__namecall")
    local readonlyState = nil
    if isreadonly then
      local readOk, value = pcall(isreadonly, metatable)
      if readOk then readonlyState = value end
    end
    local function restoreReadonly()
      local targetState = readonlyState
      if targetState == nil then targetState = true end
      pcall(setreadonly, metatable, targetState)
    end
    pcall(setreadonly, metatable, false)
    local setOk = pcall(rawset, metatable, "__namecall", handler)
    restoreReadonly()
    if setOk then
      runtime.remoteInstalled = true
      addRestore(function()
        pcall(setreadonly, metatable, false)
        pcall(rawset, metatable, "__namecall", original)
        restoreReadonly()
      end)
      return true
    end
  end
  return false
end

local function combatHookRequested()
  return cfg.Silent.Enabled or cfg.Weapon.ForceHeadshots or cfg.Weapon.NoRecoil
    or cfg.Weapon.NoSpread or cfg.Weapon.AlwaysShoot or cfg.Weapon.NoSlowdown
end
local function hookSignature()
  return table.concat({
    tostring(cfg.Silent.Enabled), tostring(cfg.Weapon.ForceHeadshots), tostring(cfg.Weapon.NoRecoil),
    tostring(cfg.Weapon.NoSpread), tostring(cfg.Weapon.AlwaysShoot), tostring(cfg.Weapon.NoSlowdown),
    tostring(calamariShotVisuals()),
  }, ":")
end
runtime.hookSignature = hookSignature()
runtime.hooksDirty = true
local function installGameHooks()
  local visualShots = calamariShotVisuals()
  if not discoverModules() then
    if visualShots then installRemoteHook() end
    runtime.hooksDirty = combatHookRequested() or (visualShots and not runtime.remoteInstalled)
    return false
  end
  refreshEquipped()
  if not cfg.Silent.Enabled then runtime.pendingShot = nil end
  if cfg.Silent.Enabled or visualShots then installCreateProjectileHook() end
  if cfg.Silent.Enabled then installSkewedOriginHooks() end
  if cfg.Silent.Enabled or cfg.Weapon.ForceHeadshots or visualShots then installRemoteHook() end
  applyWeaponDataMods()
  if cfg.Weapon.AlwaysShoot or cfg.Weapon.NoSlowdown then installCharacterModuleClones() end
  updateModuleClones()
  local retry = false
  if cfg.Silent.Enabled and not (runtime.createProjectileInstalled or runtime.skewedInstalled) then retry = true end
  if (cfg.Silent.Enabled or cfg.Weapon.ForceHeadshots) and not runtime.remoteInstalled then retry = true end
  if visualShots and not runtime.createProjectileInstalled and not runtime.remoteInstalled then retry = true end
  if cfg.Weapon.AlwaysShoot and not runtime.characterClonesInstalled then retry = true end
  if cfg.Weapon.NoSlowdown and not runtime.characterClonesInstalled and not runtime.sprintBlockState then retry = true end
  runtime.hooksDirty = retry
  return true
end
runtime.InstallGameHooks = installGameHooks
local function requestGameHooks()
  runtime.hooksDirty = true
  runtime.weaponModsNeedScan = true
  if not runtime.Active then return end
  local ok, err = pcall(installGameHooks)
  if not ok then runtime.hookError = tostring(err) end
end
runtime.RequestGameHooks = requestGameHooks

local fovCircle = newDrawing("Circle", {
  Visible = false, Filled = false, Thickness = 1, NumSides = 64, Transparency = 1,
  ZIndex = 30, Color = Color3.new(1, 1, 1),
})
local snapline = newDrawing("Line", { Visible = false, Thickness = 1, Transparency = 1, ZIndex = 30, Color = Color3.new(1, 1, 1) })
local targetText = newDrawing("Text", { Visible = false, Size = 15, Center = true, Outline = true, Transparency = 1, ZIndex = 30, Color = Color3.fromRGB(255, 220, 100) })
runtime.fovCircle, runtime.snapline, runtime.targetText = fovCircle, snapline, targetText
runtime.fovRenderer = "BurmaldaDrawing"

local espPool = {}
runtime.espPool = espPool
runtime.espRenderer = "BurmaldaDrawing"
local ESP_OBJECTS = { "boxOutline", "box", "name", "distance", "weapon", "tracer" }
local function espEntry(model)
  local entry = espPool[model]
  if entry then return entry end
  entry = {
    boxOutline = newDrawing("Square", { Visible = false, Filled = false, Thickness = 3, Transparency = 1, Color = Color3.new(0, 0, 0), ZIndex = 2 }),
    box = newDrawing("Square", { Visible = false, Filled = false, Thickness = 1, Transparency = 1, ZIndex = 3 }),
    name = newDrawing("Text", { Visible = false, Size = 13, Center = true, Outline = true, Transparency = 1, ZIndex = 4 }),
    distance = newDrawing("Text", { Visible = false, Size = 12, Center = true, Outline = true, Transparency = 1, ZIndex = 4 }),
    weapon = newDrawing("Text", { Visible = false, Size = 12, Center = true, Outline = true, Transparency = 1, ZIndex = 4 }),
    tracer = newDrawing("Line", { Visible = false, Thickness = 1, Transparency = 1, ZIndex = 2 }),
  }
  espPool[model] = entry
  return entry
end
local function hideSkeleton(entry)
  for _, item in ipairs(entry.skeleton or {}) do
    if item.line and item.line.Visible then item.line.Visible = false end
  end
end
local function ensureSkeleton(entry)
  if entry.skeleton then return entry.skeleton end
  entry.skeleton = {}
  for _, pair in ipairs(SKELETON) do
    entry.skeleton[#entry.skeleton + 1] = {
      line = newDrawing("Line", { Visible = false, Thickness = 1, Transparency = 1, ZIndex = 3 }),
      a = pair[1], b = pair[2],
    }
  end
  return entry.skeleton
end
local function hideEntry(entry)
  for _, key in ipairs(ESP_OBJECTS) do
    local object = entry[key]
    if object and object.Visible then object.Visible = false end
  end
  hideSkeleton(entry)
end
local function hideModelEntry(model)
  local entry = espPool[model]
  if entry then hideEntry(entry) end
end
local function removeEspEntries(models)
  if #models == 0 then return end
  local removed = {}
  for _, model in ipairs(models) do
    local entry = espPool[model]
    if entry then
      for _, key in ipairs(ESP_OBJECTS) do
        local object = entry[key]
        if object then removed[object] = true; object:Remove() end
      end
      for _, item in ipairs(entry.skeleton or {}) do
        if item.line then removed[item.line] = true; item.line:Remove() end
      end
      espPool[model] = nil
    end
  end
  for index = #runtime.drawings, 1, -1 do
    if removed[runtime.drawings[index]] then table.remove(runtime.drawings, index) end
  end
end
local function entityRoot(model)
  local root = findChild(model, "HumanoidRootPart") or findChild(model, "Torso") or model.PrimaryPart or findChild(model, "Head")
  if root then return root end
  local ok, part = pcall(function() return model:FindFirstChildWhichIsA("BasePart") end)
  return ok and part or nil
end
local function renderEntity(entity, model, kind, label)
  local enabled = runtime.Active and cfg.ESP.Enabled and model.Parent ~= nil and not isLocalEntity(entity, model)
  if kind == "player" then enabled = enabled and cfg.ESP.Players end
  if kind == "npc" then enabled = enabled and cfg.ESP.NPCs end
  if kind == "resource" then enabled = enabled and cfg.ESP.Resources end
  if not enabled or (kind ~= "resource" and cfg.ESP.TeamCheck and isTeammate(model))
    or (kind ~= "resource" and cfg.ESP.IgnoreSleepers and isSleeper(entity, model)) then
    hideModelEntry(model) return
  end
  local root = entityRoot(model)
  if not root or not camera then hideModelEntry(model) return end
  local origin = camera.CFrame.Position
  local distance = (root.Position - origin).Magnitude
  if distance > cfg.ESP.MaxDistance then hideModelEntry(model) return end
  local head = findChild(model, "Head")
  local topPosition = (head and head.Position or root.Position) + Vector3.new(0, kind == "resource" and 1 or 0.75, 0)
  local bottomPosition = root.Position - Vector3.new(0, kind == "resource" and 1 or 2, 0)
  local top, topVisible, topDepth = screenPoint(topPosition)
  local bottom, bottomVisible, bottomDepth = screenPoint(bottomPosition)
  if topDepth <= 0 and bottomDepth <= 0 or not (topVisible or bottomVisible) then hideModelEntry(model) return end
  local entry = espEntry(model)
  local height = math.max(8, math.abs(bottom.Y - top.Y))
  local width = math.max(6, height * (kind == "resource" and 0.8 or 0.62))
  local centerX = (top.X + bottom.X) / 2
  local topY = math.min(top.Y, bottom.Y)
  local color = kind == "player" and Color3.fromRGB(255, 255, 255)
    or kind == "npc" and Color3.fromRGB(255, 145, 80) or Color3.fromRGB(110, 220, 130)
  if entry.box and entry.boxOutline then
    entry.box.Visible = cfg.ESP.Box
    entry.boxOutline.Visible = cfg.ESP.Box
    if cfg.ESP.Box then
      entry.box.Position, entry.boxOutline.Position = Vector2.new(centerX - width / 2, topY), Vector2.new(centerX - width / 2, topY)
      entry.box.Size, entry.boxOutline.Size = Vector2.new(width, height), Vector2.new(width, height)
      entry.box.Color = color
    end
  end
  if entry.name then
    entry.name.Visible = cfg.ESP.Names
    if cfg.ESP.Names then
      entry.name.Text = kind == "resource" and label or entityName(entity, label)
      entry.name.Position = Vector2.new(centerX, topY - 16)
      entry.name.Color = color
    end
  end
  if entry.distance then
    entry.distance.Visible = cfg.ESP.Distance
    if cfg.ESP.Distance then
      entry.distance.Text = tostring(math.floor(distance + 0.5)) .. "m"
      entry.distance.Position = Vector2.new(centerX, topY + height + 3)
      entry.distance.Color = color
    end
  end
  if entry.weapon then
    local showWeapon = cfg.ESP.Weapon and kind ~= "resource"
    entry.weapon.Visible = showWeapon
    if showWeapon then
      entry.weapon.Text = entityWeapon(entity, model)
      entry.weapon.Position = Vector2.new(centerX, topY + height + (cfg.ESP.Distance and 18 or 3))
      entry.weapon.Color = color
    end
  end
  if entry.tracer then
    entry.tracer.Visible = cfg.ESP.Tracers
    if cfg.ESP.Tracers then
      entry.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
      entry.tracer.To = Vector2.new(centerX, topY + height / 2)
      entry.tracer.Color = color
    end
  end
  if cfg.ESP.Skeleton and (kind == "player" or kind == "npc") then
    for _, item in ipairs(ensureSkeleton(entry)) do
      local first, second = findChild(model, item.a), findChild(model, item.b)
      if item.line and first and second then
        local from, fromVisible, fromDepth = screenPoint(first.Position)
        local to, toVisible, toDepth = screenPoint(second.Position)
        item.line.Visible = fromVisible and toVisible and fromDepth > 0 and toDepth > 0
        if item.line.Visible then
          item.line.From, item.line.To = from, to
          item.line.Color = color
        end
      elseif item.line then
        item.line.Visible = false
      end
    end
  else
    hideSkeleton(entry)
  end
end
local function renderEsp()
  if not (runtime.Active and cfg.ESP.Enabled) then
    for _, entry in pairs(espPool) do hideEntry(entry) end
    runtime.espRendered = false
    return
  end
  runtime.espRendered = true
  local seen, stale = {}, {}
  eachEntity(function(entity, model, kind, label)
    local categoryEnabled = kind == "player" and cfg.ESP.Players
      or kind == "npc" and cfg.ESP.NPCs or kind == "resource" and cfg.ESP.Resources
    if categoryEnabled then seen[model] = true end
    renderEntity(entity, model, kind, label)
  end, cfg.ESP.Resources)
  for model in pairs(espPool) do
    if not seen[model] or not model or not model.Parent then stale[#stale + 1] = model end
  end
  removeEspEntries(stale)
end
runtime.RenderESP = renderEsp

local savedHeads = {}
runtime.savedHeads = savedHeads
local function restoreHead(head)
  local original = savedHeads[head]
  if not original then return end
  savedHeads[head] = nil
  pcall(function()
    head.Size = original.Size
    head.Transparency = original.Transparency
  end)
end
local function restoreAllHeads()
  for head in pairs(savedHeads) do restoreHead(head) end
end
local function updateBigHead()
  if not (runtime.Active and cfg.Visuals.BigHead) then restoreAllHeads() return end
  local seen = {}
  eachEntity(function(entity, model, kind)
    if kind ~= "player" and kind ~= "npc" or isLocalEntity(entity, model) then return end
    local head = findChild(model, "Head")
    if not head then return end
    seen[head] = true
    if not savedHeads[head] then
      savedHeads[head] = { Size = head.Size, Transparency = head.Transparency }
    end
    pcall(function()
      head.Size = Vector3.new(cfg.Visuals.HeadScale, cfg.Visuals.HeadScale, cfg.Visuals.HeadScale)
      head.Transparency = cfg.Visuals.HeadTransparency
    end)
  end, false)
  for head in pairs(savedHeads) do
    if not seen[head] then restoreHead(head) end
  end
end
runtime.UpdateBigHead = updateBigHead
addRestore(restoreAllHeads)

local originalFOV = camera and camera.FieldOfView or 70
runtime.originalFOV = originalFOV -- diagnostics/fallback only; not a lifecycle baseline
runtime.cameraBaseline = nil
local function restoreCamera()
  if camera and runtime.cameraControlled then
    pcall(function() camera.FieldOfView = runtime.cameraBaseline or originalFOV end)
  end
  runtime.cameraControlled = false
  runtime.cameraBaseline = nil
end
local function updateCamera()
  if not camera then return end
  if not cfg.Visuals.Zoom then runtime.zoomHeld = false end
  local custom = cfg.Visuals.FOVChanger
  local zooming = cfg.Visuals.Zoom and runtime.zoomHeld == true
  if custom or zooming then
    local entering = not runtime.cameraControlled
    if entering then runtime.cameraBaseline = camera.FieldOfView end
    local base = custom and cfg.Visuals.CustomFOV or runtime.cameraBaseline or originalFOV
    local target = zooming and math.min(base, cfg.Visuals.ZoomFOV) or base
    local ok = pcall(function() camera.FieldOfView = target end)
    if ok then
      runtime.cameraControlled = true
    elseif entering then
      runtime.cameraBaseline = nil
    end
  elseif runtime.cameraControlled then
    restoreCamera()
  end
end
runtime.UpdateCamera = updateCamera
addRestore(function()
  runtime.zoomHeld = false
  restoreCamera()
end)

local originalGravity = workspaceService and workspaceService.Gravity or 196.2
runtime.originalGravity = originalGravity -- diagnostics/fallback only
local worldStates = {}
runtime.worldStates = worldStates
local function restoreWorldEntry(key)
  local state = worldStates[key]
  if not state then return end
  worldStates[key] = nil
  for property, value in pairs(state.values) do
    pcall(function() state.object[property] = value end)
  end
end
local function controlWorld(key, enabled, object, properties, apply)
  if enabled and object then
    if not worldStates[key] then
      local values = {}
      for _, property in ipairs(properties) do values[property] = object[property] end
      worldStates[key] = {object = object, values = values}
    end
    apply()
  else
    restoreWorldEntry(key)
  end
end
local function applyWorld()
  controlWorld("Fullbright", cfg.World.Fullbright, lighting,
    {"Brightness", "Ambient", "OutdoorAmbient"}, function()
      lighting.Brightness = 2
      lighting.Ambient = Color3.new(1, 1, 1)
      lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end)
  controlWorld("RemoveFog", cfg.World.RemoveFog, lighting, {"FogStart", "FogEnd"}, function()
    lighting.FogStart = 1000000
    lighting.FogEnd = 10000000
  end)
  controlWorld("RemoveShadows", cfg.World.RemoveShadows, lighting, {"GlobalShadows"}, function()
    lighting.GlobalShadows = false
  end)
  controlWorld("TimeChanger", cfg.World.TimeChanger, lighting, {"ClockTime"}, function()
    lighting.ClockTime = cfg.World.ClockTime
  end)
  controlWorld("Gravity", cfg.Movement.Gravity, workspaceService, {"Gravity"}, function()
    workspaceService.Gravity = cfg.Movement.GravityPercent * 1.962
  end)
end
runtime.ApplyWorld = applyWorld
local grassActive, grassOriginals = false, nil
local function readFlag(name)
  if type(getfflag) ~= "function" then return nil end
  local ok, value = pcall(getfflag, name)
  if ok and value ~= nil then return tostring(value) end
  return nil
end
local function restoreGrass()
  if not grassActive then return end
  grassActive = false
  local originals = grassOriginals or {}
  grassOriginals = nil
  if setfflag then
    -- getfflag preserves pre-existing custom values. Constants are only a
    -- last-resort fallback on executors without a readable FFlag API.
    pcall(setfflag, "FRMMinGrassDistance", originals.min or "100")
    pcall(setfflag, "FRMMaxGrassDistance", originals.max or "290")
  end
end
local function applyGrass()
  if not setfflag then return end
  if cfg.World.RemoveGrass then
    if not grassActive then
      grassOriginals = {min = readFlag("FRMMinGrassDistance"), max = readFlag("FRMMaxGrassDistance")}
      grassActive = true
    end
    pcall(setfflag, "FRMMinGrassDistance", "-1")
    pcall(setfflag, "FRMMaxGrassDistance", "-1")
  else
    restoreGrass()
  end
end
runtime.ApplyGrass = applyGrass
addRestore(function()
  local keys = {}
  for key in pairs(worldStates) do keys[#keys + 1] = key end
  for _, key in ipairs(keys) do restoreWorldEntry(key) end
  restoreGrass()
end)

local flyObject
local rigBaselines = {}
local rigSpeedWritten, rigFlyWritten = false, false
local function stopFly()
  if flyObject then pcall(function() flyObject:Destroy() end) flyObject = nil end
end
runtime.StopFly = stopFly
addRestore(stopFly)
local function readVelocity(part)
  local ok, value = pcall(function() return part.AssemblyLinearVelocity end)
  if ok and typeof(value) == "Vector3" then return value end
  local oldOk, oldValue = pcall(function() return part.Velocity end)
  return oldOk and typeof(oldValue) == "Vector3" and oldValue or Vector3.zero
end
local function writeVelocity(part, value)
  local ok = pcall(function() part.AssemblyLinearVelocity = value end)
  if not ok then pcall(function() part.Velocity = value end) end
end
local function rememberRigParts(parts)
  for _, part in ipairs(parts) do
    if rigBaselines[part] == nil then rigBaselines[part] = readVelocity(part) end
  end
end
local function restoreRigMovement()
  for part, velocity in pairs(rigBaselines) do writeVelocity(part, velocity) end
  rigBaselines = {}
  rigSpeedWritten, rigFlyWritten = false, false
end
runtime.RestoreRigMovement = restoreRigMovement
addRestore(restoreRigMovement)
local function keyDown(key)
  if not userInputService or not userInputService.IsKeyDown then return false end
  local ok, value = pcall(function() return userInputService:IsKeyDown(key) end)
  return ok and value == true
end
local function inputDirection(flat)
  local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
  local right = camera and camera.CFrame.RightVector or Vector3.new(1, 0, 0)
  if flat then
    look = Vector3.new(look.X, 0, look.Z)
    right = Vector3.new(right.X, 0, right.Z)
  end
  local direction = Vector3.zero
  if keyDown(Enum.KeyCode.W) then direction = direction + look end
  if keyDown(Enum.KeyCode.S) then direction = direction - look end
  if keyDown(Enum.KeyCode.D) then direction = direction + right end
  if keyDown(Enum.KeyCode.A) then direction = direction - right end
  if not flat then
    if keyDown(Enum.KeyCode.Space) then direction = direction + Vector3.yAxis end
    if keyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.yAxis end
  end
  if direction.Magnitude > 0.05 then return direction.Unit end
  return Vector3.zero
end
local function updateRigMovement()
  local model, parts = getTridentRig()
  if not model or not parts then return false end
  local hadRigMovement = rigSpeedWritten or rigFlyWritten
  local _, _, humanoid = getLocalParts()
  local direction = humanoid and humanoid.MoveDirection or Vector3.zero
  if typeof(direction) == "Vector3" then direction = Vector3.new(direction.X, 0, direction.Z) end
  if direction.Magnitude <= 0.05 then direction = inputDirection(true) else direction = direction.Unit end
  if cfg.Movement.Fly then
    rememberRigParts(parts)
    local flyDirection = inputDirection(false)
    local velocity = flyDirection.Magnitude > 0.05 and flyDirection * cfg.Movement.FlySpeed or Vector3.zero
    for _, part in ipairs(parts) do writeVelocity(part, velocity) end
    rigFlyWritten, rigSpeedWritten = true, false
  else
    if rigFlyWritten then
      for part, baseline in pairs(rigBaselines) do
        local current = readVelocity(part)
        writeVelocity(part, Vector3.new(current.X, baseline.Y, current.Z))
      end
      rigFlyWritten = false
    end
    if cfg.Movement.Speed and direction.Magnitude > 0.05 then
      rememberRigParts(parts)
      for _, part in ipairs(parts) do
        local current = readVelocity(part)
        local horizontal = direction * cfg.Movement.SpeedValue
        writeVelocity(part, Vector3.new(horizontal.X, current.Y, horizontal.Z))
      end
      rigSpeedWritten = true
    elseif rigSpeedWritten then
      for _, part in ipairs(parts) do
        local current = readVelocity(part)
        writeVelocity(part, Vector3.new(0, current.Y, 0))
      end
      rigSpeedWritten = false
    end
  end
  if not cfg.Movement.Speed and not cfg.Movement.Fly and hadRigMovement then restoreRigMovement() end
  return true
end
local function updateMovement()
  if updateRigMovement() then return end
  local character, root, humanoid = getLocalParts()
  if not (character and root and humanoid) then stopFly() return end
  if cfg.Movement.Speed then
    local direction = humanoid.MoveDirection
    if direction and direction.Magnitude > 0.05 then
      local velocity = root.AssemblyLinearVelocity or root.Velocity or Vector3.zero
      local horizontal = direction.Unit * cfg.Movement.SpeedValue
      local nextVelocity = Vector3.new(horizontal.X, velocity.Y, horizontal.Z)
      if root.AssemblyLinearVelocity then root.AssemblyLinearVelocity = nextVelocity else root.Velocity = nextVelocity end
    end
  end
  if cfg.Movement.Fly then
    if not flyObject or flyObject.Parent ~= root then
      stopFly()
      flyObject = Instance.new("BodyVelocity")
      flyObject.Name = "BurmaldaTridentFly"
      flyObject.MaxForce = Vector3.new(100000, 100000, 100000)
      flyObject.Parent = root
    end
    local direction = inputDirection(false)
    flyObject.Velocity = direction.Magnitude > 0.05 and direction * cfg.Movement.FlySpeed or Vector3.zero
  else
    stopFly()
  end
end
runtime.UpdateMovement = updateMovement

local function updateVisuals()
  local mouse = mousePosition()
  if fovCircle then
    fovCircle.Position = mouse
    fovCircle.Radius = currentFovRadius()
    fovCircle.Visible = runtime.Active and cfg.Silent.Enabled and cfg.Silent.ShowFOV
  end
  local target = runtime.currentTarget
  if snapline then
    snapline.Visible = runtime.Active and cfg.Silent.Enabled and cfg.Silent.Snapline and target ~= nil
    if target then snapline.From, snapline.To = mouse, target.screen end
  end
  if targetText then
    targetText.Visible = runtime.Active and cfg.Silent.Enabled and cfg.Silent.TargetIndicator and target ~= nil
    if target and camera then
      targetText.Text = "TARGET  " .. target.name
      targetText.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y - 52)
    end
  end
end

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


local function buildUi()
  local coreGui
  pcall(function() coreGui = gethui and gethui() end)
  coreGui = coreGui or game:GetService("CoreGui")
  local old = coreGui:FindFirstChild("BurmaldaHookTrident")
  if old then old:Destroy() end

  -- Adapter for the same local 621x542 source-structure menu used by the other games.
  local _burmaldaEnv = Env
  local TS = ref("TweenService")
  local UIS = userInputService
  local Runtime = {
    Unloaded = false,
    StartClosed = true,
    TabNames = { "COMBAT", "VISUALS", "MOVEMENT", "WORLD", "CONFIG" },
    OnTabChanged = function(name) runtime.currentTab = name end,
  }
  local function onCleanup(callback) addRestore(callback) end
  local _isLargeScreen = camera ~= nil and camera.ViewportSize.X >= 1024

  local sg = Instance.new("ScreenGui")
  sg.Name = "BurmaldaHookTrident"
  sg.ResetOnSpawn = false
  sg.IgnoreGuiInset = true
  sg.DisplayOrder = 1000000000
  sg.Parent = coreGui
  runtime.gui = sg

  local statsHud = createBurmaldaStatsHud({
    Parent = sg, Workspace = workspaceService, LocalPlayer = localPlayer,
    Stats = ref("Stats"), IsActive = function() return runtime.Active end,
  })
  runtime.statsHud = statsHud
  onCleanup(function() statsHud.Destroy() end)

  local openBtn = Instance.new("TextButton", sg)
  openBtn.Name = "BurmaldaTridentOpen"
  openBtn.Text = "B"
  openBtn.Size = UDim2.new(0, 34, 0, 34)
  openBtn.Position = UDim2.new(0, 20, 0, 100)
  openBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
  openBtn.TextColor3 = Color3.fromRGB(225, 225, 225)
  openBtn.BorderSizePixel = 0
  openBtn.Font = Enum.Font.Gotham
  openBtn.TextSize = 14
  openBtn.AutoButtonColor = false
  local openStroke = Instance.new("UIStroke", openBtn)
  openStroke.Color = Color3.fromRGB(40, 40, 40)
  openStroke.Thickness = 1
  runtime.openButton = openBtn

-- Burmalda.hook | local port of the supplied patapim/bred UI structure.
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

-- UI-only organization: keep the original geometry and callbacks, but do not mix
-- aiming, weapon mods, visual effects, world options and movement on one page.
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


  runtime.SetAccent = setMenuAccent
  local featureBindings, optionBindings = {}, {}
  runtime.featureBindings, runtime.optionBindings = featureBindings, optionBindings
  local hookFeatures = {
    ["Silent Aim"] = true, ["No Recoil"] = true, ["No Spread"] = true,
    ["Always Shoot"] = true, ["No Slowdown"] = true, ["Force Headshots"] = true,
  }

  local function feature(parent, name, default, onChanged, getter)
    local state = default == true
    local panel = createFeature(parent, name, default, function(value)
      state = value
      if onChanged then onChanged(value) end
      if hookFeatures[name] then runtime.RequestGameHooks() end
    end)
    featureBindings[name] = {
      Set = function(value) _fFS[name](value == true) end,
      Get = getter or function() return state end,
    }
    return panel
  end

  local function slider(panel, featureName, name, minimum, maximum, default, callback, getter)
    local set = addSlider(panel, name, minimum, maximum, default, callback)
    optionBindings[featureName .. " :: " .. name] = {
      Set = function(value) set(value) end,
      Get = getter or function() return default end,
    }
    return set
  end

  local function dropdown(panel, featureName, name, options, default, callback, getter)
    local defaultIndex = 1
    for index, option in ipairs(options) do if option == default then defaultIndex = index break end end
    local set = addDropdown(panel, name, options, defaultIndex, callback)
    optionBindings[featureName .. " :: " .. name] = {
      Set = function(value) set(value) end,
      Get = getter or function() return default end,
    }
    return set
  end

  local function actionButton(parent, text, callback)
    local button = Instance.new("TextButton", parent)
    button.Size = UDim2.new(1, 0, 0, 20)
    button.BackgroundColor3 = Theme.Element
    button.TextColor3 = Theme.Text
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Text = text
    button.AutoButtonColor = false
    sourceStroke(button)
    sourceGradient(button, 90, Color3.fromRGB(220, 220, 220))
    button.MouseButton1Click:Connect(function() if runtime.Active then callback() end end)
    return button
  end

  local combatLeft, combatRight = getTab("COMBAT")
  local silent = feature(combatLeft, "Silent Aim", cfg.Silent.Enabled, function(value)
    cfg.Silent.Enabled = value
    if not value then runtime.currentTarget, runtime.pendingShot = nil, nil end
  end, function() return cfg.Silent.Enabled end)
  dropdown(silent, "Silent Aim", "Hit Part", { "Head", "Torso" }, cfg.Silent.AimPart,
    function(value) cfg.Silent.AimPart = value end, function() return cfg.Silent.AimPart end)
  slider(silent, "Silent Aim", "Hit Chance", 0, 100, cfg.Silent.HitChance,
    function(value) cfg.Silent.HitChance = value end, function() return cfg.Silent.HitChance end)
  slider(silent, "Silent Aim", "FOV", 10, 800, cfg.Silent.FOV,
    function(value) cfg.Silent.FOV = value end, function() return cfg.Silent.FOV end)
  slider(silent, "Silent Aim", "Max Distance", 50, 3000, cfg.Silent.MaxDistance,
    function(value) cfg.Silent.MaxDistance = value end, function() return cfg.Silent.MaxDistance end)
  local silentOptions = feature(combatLeft, "Silent Options", true, function() end)
  dropdown(silentOptions, "Silent Options", "Prediction", { "On", "Off" }, cfg.Silent.Prediction and "On" or "Off",
    function(value) cfg.Silent.Prediction = value == "On" end, function() return cfg.Silent.Prediction and "On" or "Off" end)
  dropdown(silentOptions, "Silent Options", "Visible Check", { "Off", "On" }, cfg.Silent.VisibleOnly and "On" or "Off",
    function(value) cfg.Silent.VisibleOnly = value == "On" end, function() return cfg.Silent.VisibleOnly and "On" or "Off" end)
  dropdown(silentOptions, "Silent Options", "Target NPCs", { "On", "Off" }, cfg.Silent.TargetNPCs and "On" or "Off",
    function(value) cfg.Silent.TargetNPCs = value == "On" end, function() return cfg.Silent.TargetNPCs and "On" or "Off" end)
  dropdown(silentOptions, "Silent Options", "Team Check", { "On", "Off" }, cfg.Silent.TeamCheck and "On" or "Off",
    function(value) cfg.Silent.TeamCheck = value == "On" end, function() return cfg.Silent.TeamCheck and "On" or "Off" end)
  dropdown(silentOptions, "Silent Options", "Ignore Sleepers", { "On", "Off" }, cfg.Silent.IgnoreSleepers and "On" or "Off",
    function(value) cfg.Silent.IgnoreSleepers = value == "On" end, function() return cfg.Silent.IgnoreSleepers and "On" or "Off" end)
  dropdown(silentOptions, "Silent Options", "Use FOV", { "On", "Off" }, cfg.Silent.UseFOV and "On" or "Off",
    function(value) cfg.Silent.UseFOV = value == "On" end, function() return cfg.Silent.UseFOV and "On" or "Off" end)

  local fov = feature(combatLeft, "FOV Circle", cfg.Silent.ShowFOV, function(value) cfg.Silent.ShowFOV = value end,
    function() return cfg.Silent.ShowFOV end)
  dropdown(fov, "FOV Circle", "Dynamic FOV", { "On", "Off" }, cfg.Silent.DynamicFOV and "On" or "Off",
    function(value) cfg.Silent.DynamicFOV = value == "On" end, function() return cfg.Silent.DynamicFOV and "On" or "Off" end)
  feature(combatLeft, "Snapline", cfg.Silent.Snapline, function(value) cfg.Silent.Snapline = value end,
    function() return cfg.Silent.Snapline end)
  feature(combatLeft, "Target Indicator", cfg.Silent.TargetIndicator, function(value) cfg.Silent.TargetIndicator = value end,
    function() return cfg.Silent.TargetIndicator end)

  feature(combatRight, "No Recoil", cfg.Weapon.NoRecoil, function(value) cfg.Weapon.NoRecoil = value end,
    function() return cfg.Weapon.NoRecoil end)
  feature(combatRight, "No Spread", cfg.Weapon.NoSpread, function(value) cfg.Weapon.NoSpread = value end,
    function() return cfg.Weapon.NoSpread end)
  feature(combatRight, "Always Shoot", cfg.Weapon.AlwaysShoot, function(value)
    cfg.Weapon.AlwaysShoot = value updateModuleClones()
  end, function() return cfg.Weapon.AlwaysShoot end)
  feature(combatRight, "No Slowdown", cfg.Weapon.NoSlowdown, function(value)
    cfg.Weapon.NoSlowdown = value updateModuleClones()
  end, function() return cfg.Weapon.NoSlowdown end)
  feature(combatRight, "Force Headshots", cfg.Weapon.ForceHeadshots, function(value) cfg.Weapon.ForceHeadshots = value end,
    function() return cfg.Weapon.ForceHeadshots end)

  local visualsLeft, visualsRight = getTab("VISUALS")
  local esp = feature(visualsLeft, "ESP", cfg.ESP.Enabled, function(value) cfg.ESP.Enabled = value end,
    function() return cfg.ESP.Enabled end)
  slider(esp, "ESP", "Max Distance", 100, 4000, cfg.ESP.MaxDistance,
    function(value) cfg.ESP.MaxDistance = value end, function() return cfg.ESP.MaxDistance end)
  feature(visualsLeft, "Player ESP", cfg.ESP.Players, function(value) cfg.ESP.Players = value end,
    function() return cfg.ESP.Players end)
  feature(visualsLeft, "NPC ESP", cfg.ESP.NPCs, function(value) cfg.ESP.NPCs = value end,
    function() return cfg.ESP.NPCs end)
  feature(visualsLeft, "Resource ESP", cfg.ESP.Resources, function(value) cfg.ESP.Resources = value end,
    function() return cfg.ESP.Resources end)
  feature(visualsLeft, "Boxes", cfg.ESP.Box, function(value) cfg.ESP.Box = value end,
    function() return cfg.ESP.Box end)
  feature(visualsLeft, "Skeleton", cfg.ESP.Skeleton, function(value) cfg.ESP.Skeleton = value end,
    function() return cfg.ESP.Skeleton end)
  feature(visualsRight, "Names", cfg.ESP.Names, function(value) cfg.ESP.Names = value end,
    function() return cfg.ESP.Names end)
  feature(visualsRight, "Distance", cfg.ESP.Distance, function(value) cfg.ESP.Distance = value end,
    function() return cfg.ESP.Distance end)
  feature(visualsRight, "Weapon", cfg.ESP.Weapon, function(value) cfg.ESP.Weapon = value end,
    function() return cfg.ESP.Weapon end)
  feature(visualsRight, "Tracers", cfg.ESP.Tracers, function(value) cfg.ESP.Tracers = value end,
    function() return cfg.ESP.Tracers end)
  feature(visualsRight, "ESP Team Check", cfg.ESP.TeamCheck, function(value) cfg.ESP.TeamCheck = value end,
    function() return cfg.ESP.TeamCheck end)
  feature(visualsRight, "Ignore Sleepers ESP", cfg.ESP.IgnoreSleepers, function(value) cfg.ESP.IgnoreSleepers = value end,
    function() return cfg.ESP.IgnoreSleepers end)
  local bigHead = feature(visualsRight, "Big Head", cfg.Visuals.BigHead, function(value)
    cfg.Visuals.BigHead = value updateBigHead()
  end, function() return cfg.Visuals.BigHead end)
  slider(bigHead, "Big Head", "Scale", 1, 5, cfg.Visuals.HeadScale,
    function(value) cfg.Visuals.HeadScale = value updateBigHead() end, function() return cfg.Visuals.HeadScale end)
  slider(bigHead, "Big Head", "Transparency %", 0, 100, cfg.Visuals.HeadTransparency * 100,
    function(value) cfg.Visuals.HeadTransparency = value / 100 updateBigHead() end,
    function() return cfg.Visuals.HeadTransparency * 100 end)

  local movementLeft, movementRight = getTab("MOVEMENT")
  local speed = feature(movementLeft, "Speed", cfg.Movement.Speed, function(value) cfg.Movement.Speed = value end,
    function() return cfg.Movement.Speed end)
  slider(speed, "Speed", "Value", 0, 100, cfg.Movement.SpeedValue,
    function(value) cfg.Movement.SpeedValue = value end, function() return cfg.Movement.SpeedValue end)
  local fly = feature(movementLeft, "Fly", cfg.Movement.Fly, function(value)
    cfg.Movement.Fly = value if not value then stopFly() end
  end, function() return cfg.Movement.Fly end)
  slider(fly, "Fly", "Speed", 10, 250, cfg.Movement.FlySpeed,
    function(value) cfg.Movement.FlySpeed = value end, function() return cfg.Movement.FlySpeed end)
  feature(movementRight, "Infinite Jump", cfg.Movement.InfiniteJump, function(value) cfg.Movement.InfiniteJump = value end,
    function() return cfg.Movement.InfiniteJump end)
  local gravity = feature(movementRight, "Gravity", cfg.Movement.Gravity, function(value)
    cfg.Movement.Gravity = value applyWorld()
  end, function() return cfg.Movement.Gravity end)
  slider(gravity, "Gravity", "Percent", 0, 200, cfg.Movement.GravityPercent,
    function(value) cfg.Movement.GravityPercent = value applyWorld() end,
    function() return cfg.Movement.GravityPercent end)

  local worldLeft, worldRight = getTab("WORLD")
  feature(worldLeft, "Fullbright", cfg.World.Fullbright, function(value) cfg.World.Fullbright = value applyWorld() end,
    function() return cfg.World.Fullbright end)
  feature(worldLeft, "Remove Fog", cfg.World.RemoveFog, function(value) cfg.World.RemoveFog = value applyWorld() end,
    function() return cfg.World.RemoveFog end)
  feature(worldRight, "Remove Grass", cfg.World.RemoveGrass, function(value) cfg.World.RemoveGrass = value applyGrass() end,
    function() return cfg.World.RemoveGrass end)
  feature(worldRight, "Remove Shadows", cfg.World.RemoveShadows, function(value) cfg.World.RemoveShadows = value applyWorld() end,
    function() return cfg.World.RemoveShadows end)
  local timeChanger = feature(worldLeft, "Time Changer", cfg.World.TimeChanger, function(value)
    cfg.World.TimeChanger = value applyWorld()
  end, function() return cfg.World.TimeChanger end)
  slider(timeChanger, "Time Changer", "Clock Time", 0, 24, cfg.World.ClockTime,
    function(value) cfg.World.ClockTime = value applyWorld() end, function() return cfg.World.ClockTime end)
  local fovChanger = feature(worldLeft, "FOV Changer", cfg.Visuals.FOVChanger, function(value)
    cfg.Visuals.FOVChanger = value updateCamera()
  end, function() return cfg.Visuals.FOVChanger end)
  slider(fovChanger, "FOV Changer", "Value", 30, 120, cfg.Visuals.CustomFOV,
    function(value) cfg.Visuals.CustomFOV = value updateCamera() end, function() return cfg.Visuals.CustomFOV end)
  local zoom = feature(worldRight, "Zoom", cfg.Visuals.Zoom, function(value)
    cfg.Visuals.Zoom = value
    if not value then runtime.zoomHeld = false end
    updateCamera()
  end, function() return cfg.Visuals.Zoom end)
  slider(zoom, "Zoom", "FOV", 5, 70, cfg.Visuals.ZoomFOV,
    function(value) cfg.Visuals.ZoomFOV = value updateCamera() end, function() return cfg.Visuals.ZoomFOV end)

  local configLeftColumn, configRightColumn = getTab("CONFIG")
  local configLeft = getSection(configLeftColumn, "Configs").Content
  local configRight = getSection(configRightColumn, "Saved Configs").Content
  local configLabel = sourceText(configLeft, "Config Name", UDim2.new(1, 0, 0, 15), Theme.SubText)
  local configName = Instance.new("TextBox", configLeft)
  configName.Text = ""
  configName.PlaceholderText = "config1"
  configName.ClearTextOnFocus = false
  configName.Size = UDim2.new(1, 0, 0, 20)
  configName.BackgroundColor3 = Theme.Element
  configName.TextColor3 = Theme.Text
  configName.BorderSizePixel = 0
  configName.Font = Enum.Font.Gotham
  configName.TextSize = 14
  sourceStroke(configName)
  local status = sourceText(configLeft, "PRIVATE / LOCAL CONFIG", UDim2.new(1, 0, 0, 15), Theme.SubText)

  local configFolder = "BurmaldaHook/TridentSurvival/configs"
  local function ensureFolders()
    if not (isfolder and makefolder) then return false end
    for _, folder in ipairs({ "BurmaldaHook", "BurmaldaHook/TridentSurvival", configFolder }) do
      if not isfolder(folder) then makefolder(folder) end
    end
    return true
  end
  local function cleanName(name)
    name = tostring(name or ""):gsub("[^%w%-_]", "_")
    return name:sub(1, 40)
  end
  local function merge(destination, source)
    for key, value in pairs(source) do
      if type(value) == "table" and type(destination[key]) == "table" then merge(destination[key], value)
      else destination[key] = value end
    end
  end
  local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = deepCopy(child) end
    return result
  end
  local configApi = {}
  runtime.configApi = configApi
  function configApi.List()
    local result = {}
    if not (listfiles and ensureFolders()) then return result end
    local ok, files = pcall(listfiles, configFolder)
    if not ok then return result end
    for _, path in ipairs(files) do
      local name = string.match(path, "([^/\\]+)%.json$")
      if name then result[#result + 1] = name end
    end
    table.sort(result)
    return result
  end
  function configApi.Save(name)
    name = cleanName(name)
    if name == "" then
      local existing = {}
      for _, item in ipairs(configApi.List()) do existing[item] = true end
      local index = 1
      while existing["config" .. index] do index = index + 1 end
      name = "config" .. index
    end
    if not (writefile and httpService and ensureFolders()) then return nil, "filesystem unavailable" end
    local ok, encoded = pcall(httpService.JSONEncode, httpService, { Version = 1, Cfg = deepCopy(cfg) })
    if not ok then return nil, encoded end
    local writeOk, err = pcall(writefile, configFolder .. "/" .. name .. ".json", encoded)
    if not writeOk then return nil, err end
    return name
  end
  function configApi.Load(name)
    name = cleanName(name)
    if name == "" or not (readfile and httpService) then return false, "invalid config" end
    local ok, decoded = pcall(function()
      return httpService:JSONDecode(readfile(configFolder .. "/" .. name .. ".json"))
    end)
    if not ok or type(decoded) ~= "table" or type(decoded.Cfg) ~= "table" then return false, decoded end
    merge(cfg, decoded.Cfg)
    if runtime.CalamariVisuals then runtime.CalamariVisuals.SyncUI() end
    for _, binding in pairs(featureBindings) do binding.Set(binding.Get()) end
    for _, binding in pairs(optionBindings) do binding.Set(binding.Get()) end
    applyWorld() applyGrass() updateModuleClones() updateCamera() updateBigHead()
    runtime.RequestGameHooks()
    return true
  end
  function configApi.Delete(name)
    name = cleanName(name)
    if name == "" or not delfile then return false end
    return pcall(delfile, configFolder .. "/" .. name .. ".json")
  end

  actionButton(configLeft, "Save Config", function()
    local name, err = configApi.Save(configName.Text)
    status.Text = name and ("SAVED / " .. name) or ("ERROR / " .. tostring(err))
    if name then configName.Text = name end
  end)
  actionButton(configLeft, "Load Config", function()
    local ok, err = configApi.Load(configName.Text)
    status.Text = ok and "LOADED" or ("ERROR / " .. tostring(err))
  end)
  actionButton(configLeft, "Delete Config", function()
    status.Text = configApi.Delete(configName.Text) and "DELETED" or "DELETE FAILED"
  end)

  local accentSet = feature(configRightColumn, "Menu Accent", true, function() end)
  addDropdown(accentSet, "Preset", { "White", "Silver", "Graphite" }, 1, function(value)
    if value == "Silver" then setMenuAccent(Color3.fromRGB(190, 190, 190))
    elseif value == "Graphite" then setMenuAccent(Color3.fromRGB(105, 105, 105))
    else setMenuAccent(Color3.fromRGB(255, 255, 255)) end
  end)
  feature(configRightColumn, "UI Animations", true, function(value) UIAnimations = value end)
  local savedTitle = sourceText(configRight, "Saved configs are listed through the local filesystem API.",
    UDim2.new(1, 0, 0, 30), Theme.SubText)
  savedTitle.TextWrapped = true
  local hotkeys = sourceText(configRight, "INSERT / RIGHTSHIFT  MENU\nF1  ESP     F2  SILENT     X  ZOOM",
    UDim2.new(1, 0, 0, 30), Theme.SubText)
  hotkeys.TextWrapped = true
  local unloadButton = actionButton(configRight, "Unload Burmalda.hook", function() runtime.Unload() end)
  unloadButton.TextColor3 = Color3.fromRGB(255, 110, 110)

  local Window = { Closed = not menuOpen }
  runtime.Window = Window
  local sourceToggleMenu = toggleMenu
  toggleMenu = function(viaSHIFT)
    sourceToggleMenu(viaSHIFT)
    Window.Closed = not menuOpen
  end
  function Window.SetFeature(_, name, value)
    local binding = featureBindings[name]
    if binding then binding.Set(value == true) end
  end
  function Window.SetOption(_, name, value)
    local binding = optionBindings[name]
    if binding then binding.Set(value) end
  end
  function Window.Open() if not menuOpen then toggleMenu() end end
  function Window.Close() if menuOpen then toggleMenu() end end
  function Window.Toggle() toggleMenu() end
  function Window.SelectTab(_, index)
    local names = Runtime.TabNames
    if type(index) == "number" and names[index] then selectTab(names[index])
    elseif type(index) == "string" then selectTab(index) end
  end
  Window.Unload = function() runtime.Unload() end

  trackConnection(userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not runtime.Active then return end
    if input.KeyCode == Enum.KeyCode.Insert then toggleMenu()
    elseif input.KeyCode == Enum.KeyCode.F1 then Window:SetFeature("ESP", not cfg.ESP.Enabled)
    elseif input.KeyCode == Enum.KeyCode.F2 then Window:SetFeature("Silent Aim", not cfg.Silent.Enabled) end
  end))

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
  local function resourceCategory(entity, model, label)
    local kind = tostring(rawget(entity, "type") or model.Name or label or "")
    local lower = string.lower(kind .. " " .. tostring(label or ""))
    if string.find(lower, "nitrate", 1, true) or string.find(lower, "sulfur", 1, true)
      or string.find(lower, "phosphate", 1, true) then return "Phosphate" end
    if string.find(lower, "iron", 1, true) or string.find(lower, "metal", 1, true) then return "Metal" end
    if string.find(lower, "stone", 1, true) then return "Stone" end
    if string.find(lower, "egg", 1, true) then return "Eggs" end
    if string.find(lower, "body", 1, true) or string.find(lower, "bag", 1, true) then return "Body Bag" end
    if string.find(lower, "backpack", 1, true) or string.find(lower, "crate", 1, true)
      or string.find(lower, "totem", 1, true) then return "Drops" end
    return nil
  end
  local calamari = calamariFactory({
    Game = "Trident Survival",
    State = cfg.Calamari,
    Camera = "ThirdPerson",
    Lighting = false,
    IsActive = function() return runtime.Active end,
    IsLowPC = function() return runtime.LowPC == true end,
    Adapter = {
      WorldRoots = {
        "Nodes", "OreNodes", "Resources", "Loot", "Deployables", "Drops", "DroppedItems",
        "WorldItems", "Plants", "Animals", "Pickups", "SpawnedPickups", "GroundItems", "Eggs",
      },
      GetTargets = function()
        local result = {}
        eachEntity(function(entity, model, kind, label)
          if kind ~= "player" and kind ~= "npc" then return end
          if isLocalEntity(entity, model) then return end
          if cfg.ESP.TeamCheck and isTeammate(model) then return end
          if cfg.ESP.IgnoreSleepers and isSleeper(entity, model) then return end
          local root = findChild(model, "HumanoidRootPart") or findChild(model, "Torso")
            or findChild(model, "LowerTorso") or findChild(model, "Head") or model.PrimaryPart
          if not root then return end
          local humanoid = findChild(model, "Humanoid")
          result[#result + 1] = {
            Model = model, Root = root, Humanoid = humanoid,
            Player = rawget(entity, "player"), Name = entityName(entity, label),
            Weapon = entityWeapon(entity, model),
          }
        end, false)
        return result
      end,
      GetWorldEntries = function()
        local result, seen = {}, {}
        eachEntity(function(entity, model, kind, label)
          if kind ~= "resource" or seen[model] then return end
          local category = resourceCategory(entity, model, label)
          if category then
            seen[model] = true
            result[#result + 1] = {Object = model, Category = category, Name = entityName(entity, label)}
          end
        end, true)
        return result
      end,
    },
  })
  runtime.CalamariVisuals = calamari
  addRestore(function()
    calamari.Unload()
    if runtime.CalamariVisuals == calamari then runtime.CalamariVisuals = nil end
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
  mountCalamari(calamari, {Camera = "ThirdPerson", Lighting = false})
end


  selectTab("COMBAT")
  if menuOpen then toggleMenu() end
end


trackConnection(runService.RenderStepped:Connect(function(deltaTime)
  if not runtime.Active then return end
  local now = os.clock()
  camera = workspaceService and workspaceService.CurrentCamera or camera
  local signature = hookSignature()
  if signature ~= runtime.hookSignature then
    runtime.hookSignature = signature
    runtime.hooksDirty = true
  end
  local discoveryNeeded = cfg.ESP.Enabled or combatHookRequested()
    or (calamariShotVisuals() and not runtime.remoteInstalled)
  if now >= runtime.nextDiscovery and (runtime.hooksDirty
    or (discoveryNeeded and (not runtime.classes or not runtime.cacheValidated))) then
    runtime.nextDiscovery = now + 1
    pcall(installGameHooks)
  end
  if now >= runtime.nextEquipUpdate then
    runtime.nextEquipUpdate = now + 0.25
    pcall(refreshEquipped)
  end
  if now >= runtime.nextTargetUpdate then
    runtime.nextTargetUpdate = now + 1 / 30
    local ok, err = pcall(updateTarget)
    if not ok then runtime.targetError = tostring(err) runtime.currentTarget = nil end
  end
  pcall(updateVisuals)
  pcall(updateCamera)
  if now >= (runtime.nextHeadUpdate or 0) then
    runtime.nextHeadUpdate = now + 0.2
    pcall(updateBigHead)
  end
  if cfg.ESP.Enabled and now >= (runtime.nextEspUpdate or 0) then
    runtime.nextEspUpdate = now + 1 / 30
    pcall(renderEsp)
  elseif not cfg.ESP.Enabled and runtime.espRendered then
    pcall(renderEsp)
  end
  if cfg.Weapon.NoSlowdown then pcall(updateSprintBlock) end
  pcall(updateMovement)
end))

if localPlayer then
  trackConnection(localPlayer.CharacterAdded:Connect(function()
    runtime.currentTarget = nil
    runtime.pendingShot = nil
    restoreRigMovement()
    stopFly()
  end))
  trackConnection(localPlayer.CharacterRemoving:Connect(function()
    runtime.currentTarget = nil
    runtime.pendingShot = nil
    restoreRigMovement()
    stopFly()
  end))
end
trackConnection(userInputService.InputBegan:Connect(function(input, gameProcessed)
  if gameProcessed or not runtime.Active or not cfg.Visuals.Zoom then return end
  if input.KeyCode == Enum.KeyCode.X then runtime.zoomHeld = true end
end))
trackConnection(userInputService.InputEnded:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.X then runtime.zoomHeld = false end
end))
trackConnection(userInputService.JumpRequest:Connect(function()
  if not (runtime.Active and cfg.Movement.InfiniteJump) then return end
  local _, _, humanoid = getLocalParts()
  local _, rigParts = getTridentRig()
  if rigParts then
    for _, part in ipairs(rigParts) do
      local velocity = readVelocity(part)
      writeVelocity(part, Vector3.new(velocity.X, 50, velocity.Z))
    end
  elseif humanoid then
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
  end
end))

function runtime.Unload()
  if not runtime.Active then return end
  runtime.Active = false
  for _, connection in ipairs(runtime.connections) do pcall(function() connection:Disconnect() end) end
  for index = #runtime.restores, 1, -1 do pcall(runtime.restores[index]) end
  for _, drawing in ipairs(runtime.drawings) do pcall(function() drawing:Remove() end) end
  if runtime.gui then pcall(function() runtime.gui:Destroy() end) end
  if runtime.openButton then pcall(function() runtime.openButton:Destroy() end) end
  if Env.__BURMALDA_TRIDENT == runtime then Env.__BURMALDA_TRIDENT = nil end
end

pcall(installGameHooks)
buildUi()
applyWorld()
applyGrass()
