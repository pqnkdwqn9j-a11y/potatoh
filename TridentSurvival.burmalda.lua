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
  local ok, values = pcall(debug.getupvalues, fn)
  return ok and type(values) == "table" and values or {}
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
  local original = getUpvalues(fn)[key]
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
  for _, value in pairs(garbage) do
    if type(value) == "table" then
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
  runtime.playerCache = selectCache({ onDestroy }, getUpvalue(onDestroy, 1))
  runtime.npcCache = selectCache({ onCreate }, getUpvalue(onCreate, 1))
  runtime.validTypes = { Player = true }
  for name in pairs(NPC_TYPES) do runtime.validTypes[name] = true end
  local shared = findChild(replicatedStorage, "Shared")
  local entities = findChild(shared, "entities")
  local npcFolder = findChild(entities, "NPC")
  if npcFolder then
    for _, child in ipairs(npcFolder:GetChildren()) do runtime.validTypes[child.Name] = true end
  end
  runtime.cacheValidated = runtime.entityCache ~= nil or runtime.playerCache ~= nil or runtime.npcCache ~= nil
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
local function eachEntity(callback)
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
  for _, entity in ipairs(scanWorldResources()) do visit(entity) end
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
  params.FilterDescendantsInstances = { model, getIgnoreFolder() }
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
  local velocity = rawget(entity, "velocityVector")
  local goal, start = rawget(entity, "goalPosition"), rawget(entity, "startPosition")
  if goal and start then
    velocity = (goal - start) / 0.15 * Vector3.new(1, 0, 1)
  end
  velocity = velocity or target.part.AssemblyLinearVelocity or Vector3.zero
  local time = (position - origin).Magnitude / speed
  local predicted = position + velocity * time
  time = time + (predicted - position).Magnitude / speed
  local exponent = time * drop
  local offset = drop ^ exponent - 1
  if offset ~= offset or offset == math.huge or offset == -math.huge then return predicted end
  return predicted + Vector3.yAxis * offset
end
local function computeSilentCFrame(origin, weaponData)
  if not (runtime.Active and cfg.Silent.Enabled) then return nil end
  local target = runtime.currentTarget
  if not target or not target.part or not target.part.Parent then return nil end
  if math.random(0, 99) >= (cfg.Silent.HitChance or 100) then return nil end
  local info = weaponInfo(weaponData)
  local position = predictedPosition(origin, target, info)
  if not position then return nil end
  return CFrame.lookAt(origin, position)
end
runtime.ComputeSilentCFrame = computeSilentCFrame

local function setPendingShot(cframe)
  runtime.pendingShot = { cframe = cframe, at = os.clock() }
  runtime.stats.redirects = runtime.stats.redirects + 1
end

local function installCreateProjectileHook()
  local classes = runtime.classes
  local ranged = classes and rawget(classes, "RangedWeaponClient")
  local createProjectile = ranged and rawget(ranged, "CreateProjectile")
  if type(createProjectile) ~= "function" or runtime.createProjectileInstalled then return false end
  local original = createProjectile
  local wrapper = function(startCFrame, weaponData, isLocal, ...)
    runtime.stats.shots = runtime.stats.shots + 1
    -- Pending state belongs to one local attempt only. A no-target, disabled or
    -- failed-chance shot must never leave the previous CFrame for the next Fire.
    if runtime.Active and isLocal then runtime.pendingShot = nil end
    if not runtime.Active or not isLocal or not cfg.Silent.Enabled then
      return original(startCFrame, weaponData, isLocal, ...)
    end
    local origin = typeof(startCFrame) == "CFrame" and startCFrame.Position
      or (camera and camera.CFrame.Position) or Vector3.zero
    local ok, silentCFrame = pcall(computeSilentCFrame, origin, weaponData)
    if ok and silentCFrame then
      startCFrame = silentCFrame
      setPendingShot(silentCFrame)
      runtime.silentMode = "CreateProjectile"
    elseif not ok then
      runtime.silentError = tostring(silentCFrame)
      runtime.stats.fallbacks = runtime.stats.fallbacks + 1
    end
    return original(startCFrame, weaponData, isLocal, ...)
  end
  if patchField(ranged, "CreateProjectile", wrapper) then
    runtime.createProjectileInstalled = true
    runtime.originalCreateProjectile = original
    runtime.silentMode = "CreateProjectile"
    return true
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
              if runtime.Active and cfg.Silent.Enabled and not runtime.createProjectileInstalled then
                local callerMatches = true
                if debug.info then
                  local infoOk, caller = pcall(debug.info, 3, "f")
                  callerMatches = infoOk and caller == fire
                end
                if callerMatches and debug.getstack and debug.setstack then
                  local stackOk, stack = pcall(debug.getstack, 2)
                  if stackOk and type(stack) == "table" and typeof(stack[1]) == "CFrame" then
                    local cfOk, silentCFrame = pcall(computeSilentCFrame, stack[1].Position, nil)
                    if cfOk and silentCFrame then
                      local setOk = pcall(debug.setstack, 2, 1, silentCFrame)
                      if setOk then
                        setPendingShot(silentCFrame)
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
      if rawget(info, "recoilOffset") ~= nil then
        writeWeaponValue("Recoil", info, "recoilOffset", CFrame.new())
        writeWeaponValue("Recoil", info, "recoilLerpSpeed", 0)
        writeWeaponValue("Recoil", info, "recoilReturnSpeed", 0)
      end
      for _, key in ipairs({ "AimRecoil", "HipRecoil", "RecoilData" }) do
        local nested = rawget(info, key)
        if type(nested) == "table" then
          for nestedKey in pairs(nested) do writeWeaponValue("Recoil", nested, nestedKey, 0) end
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
    if not runtime.Active or not cfg.Silent.Enabled or typeof(args[4]) ~= "CFrame" then return end
    if not getRangedWeaponInfo() then return end
    local pending = runtime.pendingShot
    runtime.pendingShot = nil
    if pending and os.clock() - pending.at <= 0.75 then
      args[4] = pending.cframe
      runtime.stats.remoteRedirects = runtime.stats.remoteRedirects + 1
    elseif not runtime.createProjectileInstalled and not runtime.skewedInstalled then
      local silentCFrame = computeSilentCFrame(camera.CFrame.Position, nil)
      if silentCFrame then
        args[4] = silentCFrame
        runtime.stats.remoteRedirects = runtime.stats.remoteRedirects + 1
        runtime.silentMode = "Remote"
      end
    end
  elseif action == "Hit" then
    if not runtime.Active or not cfg.Weapon.ForceHeadshots or not getRangedWeaponInfo() then return end
    local partIndex, entityIndex
    if count == 8 then
      if type(args[5]) ~= "number" or type(args[6]) ~= "string" or typeof(args[7]) ~= "Vector3" then return end
      partIndex, entityIndex = 6, 5
    elseif count == 7 then
      if type(args[4]) ~= "number" or type(args[5]) ~= "string" or typeof(args[6]) ~= "Vector3" then return end
      partIndex, entityIndex = 5, 4
    else return end
    local entity = combatEntity(args[entityIndex])
    local model = entity and rawget(entity, "model")
    if not model or not findChild(model, "Head") then return end
    if BODY_PARTS[args[partIndex]] then args[partIndex] = "Head" end
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
  }, ":")
end
runtime.hookSignature = hookSignature()
runtime.hooksDirty = true
local function installGameHooks()
  if not discoverModules() then runtime.hooksDirty = combatHookRequested() return false end
  refreshEquipped()
  if not cfg.Silent.Enabled then runtime.pendingShot = nil end
  if cfg.Silent.Enabled then
    installCreateProjectileHook()
    installSkewedOriginHooks()
    installRemoteHook()
  elseif cfg.Weapon.ForceHeadshots then
    installRemoteHook()
  end
  applyWeaponDataMods()
  if cfg.Weapon.AlwaysShoot or cfg.Weapon.NoSlowdown then installCharacterModuleClones() end
  updateModuleClones()
  local retry = false
  if cfg.Silent.Enabled and not (runtime.createProjectileInstalled or runtime.skewedInstalled) then retry = true end
  if (cfg.Silent.Enabled or cfg.Weapon.ForceHeadshots) and not runtime.remoteInstalled then retry = true end
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
local function espEntry(model)
  local entry = espPool[model]
  if entry then return entry end
  entry = {
    boxOutline = newDrawing("Square", { Visible = false, Filled = false, Thickness = 3, Color = Color3.new(0, 0, 0), ZIndex = 2 }),
    box = newDrawing("Square", { Visible = false, Filled = false, Thickness = 1, ZIndex = 3 }),
    name = newDrawing("Text", { Visible = false, Size = 13, Center = true, Outline = true, ZIndex = 4 }),
    distance = newDrawing("Text", { Visible = false, Size = 12, Center = true, Outline = true, ZIndex = 4 }),
    weapon = newDrawing("Text", { Visible = false, Size = 12, Center = true, Outline = true, ZIndex = 4 }),
    tracer = newDrawing("Line", { Visible = false, Thickness = 1, ZIndex = 2 }),
  }
  espPool[model] = entry
  return entry
end
local function hideSkeleton(entry)
  for _, item in ipairs(entry.skeleton or {}) do
    if item.line then item.line.Visible = false end
  end
end
local function ensureSkeleton(entry)
  if entry.skeleton then return entry.skeleton end
  entry.skeleton = {}
  for _, pair in ipairs(SKELETON) do
    entry.skeleton[#entry.skeleton + 1] = {
      line = newDrawing("Line", { Visible = false, Thickness = 1, ZIndex = 3 }),
      a = pair[1], b = pair[2],
    }
  end
  return entry.skeleton
end
local function hideEntry(entry)
  for _, key in ipairs({ "boxOutline", "box", "name", "distance", "weapon", "tracer" }) do
    if entry[key] then entry[key].Visible = false end
  end
  hideSkeleton(entry)
end
local function entityRoot(model)
  local root = findChild(model, "HumanoidRootPart") or findChild(model, "Torso") or model.PrimaryPart or findChild(model, "Head")
  if root then return root end
  local ok, part = pcall(function() return model:FindFirstChildWhichIsA("BasePart") end)
  return ok and part or nil
end
local function renderEntity(entity, model, kind, label)
  local entry = espEntry(model)
  local enabled = runtime.Active and cfg.ESP.Enabled and model.Parent ~= nil and not isLocalEntity(entity, model)
  if kind == "player" then enabled = enabled and cfg.ESP.Players end
  if kind == "npc" then enabled = enabled and cfg.ESP.NPCs end
  if kind == "resource" then enabled = enabled and cfg.ESP.Resources end
  if not enabled or (kind ~= "resource" and cfg.ESP.TeamCheck and isTeammate(model))
    or (kind ~= "resource" and cfg.ESP.IgnoreSleepers and isSleeper(entity, model)) then
    hideEntry(entry) return
  end
  local root = entityRoot(model)
  if not root or not camera then hideEntry(entry) return end
  local origin = camera.CFrame.Position
  local distance = (root.Position - origin).Magnitude
  if distance > cfg.ESP.MaxDistance then hideEntry(entry) return end
  local head = findChild(model, "Head")
  local topPosition = (head and head.Position or root.Position) + Vector3.new(0, kind == "resource" and 1 or 0.75, 0)
  local bottomPosition = root.Position - Vector3.new(0, kind == "resource" and 1 or 2, 0)
  local top, topVisible, topDepth = screenPoint(topPosition)
  local bottom, bottomVisible, bottomDepth = screenPoint(bottomPosition)
  if topDepth <= 0 and bottomDepth <= 0 or not (topVisible or bottomVisible) then hideEntry(entry) return end
  local height = math.max(8, math.abs(bottom.Y - top.Y))
  local width = math.max(6, height * (kind == "resource" and 0.8 or 0.62))
  local centerX = (top.X + bottom.X) / 2
  local topY = math.min(top.Y, bottom.Y)
  local color = kind == "player" and Color3.fromRGB(255, 255, 255)
    or kind == "npc" and Color3.fromRGB(255, 145, 80) or Color3.fromRGB(110, 220, 130)
  if entry.box and entry.boxOutline then
    entry.box.Visible = cfg.ESP.Box
    entry.boxOutline.Visible = cfg.ESP.Box
    entry.box.Position, entry.boxOutline.Position = Vector2.new(centerX - width / 2, topY), Vector2.new(centerX - width / 2, topY)
    entry.box.Size, entry.boxOutline.Size = Vector2.new(width, height), Vector2.new(width, height)
    entry.box.Color = color
  end
  if entry.name then
    entry.name.Visible = cfg.ESP.Names
    entry.name.Text = kind == "resource" and label or entityName(entity, label)
    entry.name.Position = Vector2.new(centerX, topY - 16)
    entry.name.Color = color
  end
  if entry.distance then
    entry.distance.Visible = cfg.ESP.Distance
    entry.distance.Text = tostring(math.floor(distance + 0.5)) .. "m"
    entry.distance.Position = Vector2.new(centerX, topY + height + 3)
    entry.distance.Color = color
  end
  if entry.weapon then
    entry.weapon.Visible = cfg.ESP.Weapon and kind ~= "resource"
    entry.weapon.Text = entityWeapon(entity, model)
    entry.weapon.Position = Vector2.new(centerX, topY + height + (cfg.ESP.Distance and 18 or 3))
    entry.weapon.Color = color
  end
  if entry.tracer then
    entry.tracer.Visible = cfg.ESP.Tracers
    entry.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    entry.tracer.To = Vector2.new(centerX, topY + height / 2)
    entry.tracer.Color = color
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
  local seen = {}
  eachEntity(function(entity, model, kind, label)
    seen[model] = true
    renderEntity(entity, model, kind, label)
  end)
  for model, entry in pairs(espPool) do
    if not seen[model] or not model or not model.Parent then hideEntry(entry) end
  end
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
  end)
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
local interfaceFeatures = {
	["Menu Accent"] = true, ["UI Animations"] = true,
}

function defaultSectionName(parent, featureName)
	local existing = sectionContents[parent]
	if existing then return existing.Name end
	local tabName = columnTabs[parent] or "MISC"
	if tabName == "COMBAT" then
		return gunFeatures[featureName] and "Gun Mods" or "Aimbot"
	elseif tabName == "VISUALS" then
		if resourceFeatures[featureName] then return "Resources" end
		return worldFeatures[featureName] and "World" or "Players"
	elseif tabName == "MOVEMENT" then
		return projectileFeatures[featureName] and "Projectiles" or "Movement"
	elseif tabName == "MISC" then
		return "Misc"
	elseif tabName == "WORLD" then
		return "World"
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
  if cfg.ESP.Enabled then pcall(renderEsp) else
    for _, entry in pairs(espPool) do hideEntry(entry) end
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
