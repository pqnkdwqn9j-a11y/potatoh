local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local __burmaldaTostringEnv = getgenv and getgenv() or _G
local __burmaldaTostringState = __burmaldaTostringEnv.__BURMALDA_LONE_TOSTRING
if type(__burmaldaTostringState) == "table" and tostring == __burmaldaTostringState.wrapper then
  tostring = __burmaldaTostringState.original
end

local v1 = tostring

function tostring(p1)
  local gsub = v1(p1)

  if type(gsub) == "string" then
    gsub = gsub:gsub("^(.-):%d+:", "%1:1:", 1)
  end

  return gsub
end

__burmaldaTostringState = {original = v1, wrapper = tostring}
__burmaldaTostringEnv.__BURMALDA_LONE_TOSTRING = __burmaldaTostringState

local integrityOk = true
local gmatch = string.gmatch

local function tamperDetected()
  error("Tamper Detected!")
end

local random = math.random
local v33 = table and table.unpack or unpack
local v34 = random(3, 65)
local v35 = 0
local v36 = 0
local v37 = ({ pcall(function() return "cKIDXOuo" / (909561 - "xeNvRox0Xr0g" ^ 9709017) end) })[2]
local v38 = tonumber(gmatch(tostring(v37), ":(%d*):")())
local v39 = 1
local v40 = v39 < 0
local v41 = 1 - v39

while true do
  v41 = v39 + v41

  if not (v40 and v41 >= v34 or not v40 and v41 <= v34) then
    break
  end

  local v42 = v41
  local v43 = math.random(1, 100)
  local v44 = random(0, 255)
  local v45 = random(1, v43)
  local v46 = random(1, 2) == 1
  local gsub2 = v37:gsub(":(%d*):", ":" .. tostring(random(0, 10000)) .. ":")

  local v47 = {
    pcall(function()
      if random(1, 2) == 1 or v42 == v34 then
        integrityOk = integrityOk and v38 == tonumber(gmatch(tostring(({
          pcall(function() return "BWxVH" / (2006289 - "XRf8jjLAzI7B" ^ 11584697) end),
        })[2]), ":(%d*):")())
      end

      if v46 then
        error(gsub2, 0)
      end

      local v48 = {}

      for k = 1, v43, 1 do
        v48[k] = random(0, 255)
      end

      v48[v45] = v44
      return v33(v48)
    end),
  }

  if v46 then
    integrityOk = integrityOk and v47[1] == false and v47[2] == gsub2
  else
    integrityOk = integrityOk and v47[1]
    v35 = (v35 + v47[v45 + 1]) % 256
    v36 = (v36 + v44) % 256
  end
end

integrityOk = integrityOk and v35 == v36

local applyFullbright, getEspGui, isTargetVisible, collectTargets, installProjectileHook,
  createTextDrawing, createBoxDrawing, saveLightingState, solveBallisticDirection,
  getFovCircle, updateTextDrawing, renderEsp, tableKeys, getPlayerNames, getPerformanceLabel,
  ensureEspPool, updateBoxDrawing, localPlayer, mainGame, cfg, fullbrightBindingName,
  fullbrightSettings, setFullbright, isLocalCharacter, getTargetVelocity, getAimPart,
  selectTarget, makeDrawingWrapper, createEspEntry, hideEspEntry, updateFovCircle,
  getCachedTargets, buildUi, toggleUi, performanceLabel, perfFrames, perfElapsed,
  perfScriptTime, perfScriptSamples, perfRedraws, espAccumulator, hookError

if integrityOk then
  localPlayer = players.LocalPlayer
  mainGame = getgenv().__mainGame

  if type(mainGame) ~= "table" then
    mainGame = {}
    getgenv().__mainGame = mainGame
  end

  if mainGame.movementCleanup then pcall(mainGame.movementCleanup) end
  mainGame.movementCleanup = nil
  mainGame.movement = nil

  mainGame.RestoreTostring = function()
    if __burmaldaTostringState and tostring == __burmaldaTostringState.wrapper then
      tostring = __burmaldaTostringState.original
    end
    if __burmaldaTostringEnv.__BURMALDA_LONE_TOSTRING == __burmaldaTostringState then
      __burmaldaTostringEnv.__BURMALDA_LONE_TOSTRING = nil
    end
  end

  local v79 = mainGame
  local v80 = "cfg"

  v79[v80] = mainGame.cfg or {
    ESP = {
      Enabled = false,
      Players = false,
      NPCs = false,
      MaxDistance = 1500,
      Box = false,
      BoxFill = false,
      Name = false,
      Health = false,
      Distance = false,
      Tracer = false,
      PlayerColor = Color3.fromRGB(255, 70, 70),
      NPCColor = Color3.fromRGB(255, 170, 40),
    },
    Silent = {
      Enabled = false,
      FOV = 120,
      MaxDistance = 10000,
      AimPart = "Head",
      VisibleOnly = false,
      Prediction = false,
      TargetNPCs = false,
      PriorityPlayers = false,
    },
    Misc = { PerfOverlay = false, Fullbright = false },
  }

  cfg = mainGame.cfg

  if cfg.ESP.UpdateRate == nil then
    cfg.ESP.UpdateRate = 30
  end

  if cfg.ESP.ScanInterval == nil then
    cfg.ESP.ScanInterval = 0.15
  end

  if cfg.ESP.MaxTargets == nil then
    cfg.ESP.MaxTargets = 64
  end

  if cfg.Misc == nil then
    cfg.Misc = {}
  end

  if cfg.Misc.PerfOverlay == nil then
    cfg.Misc.PerfOverlay = false
  end

  if cfg.Misc.Fullbright == nil then
    cfg.Misc.Fullbright = false
  end

  if cfg.Silent.ShowFOV == nil then
    cfg.Silent.ShowFOV = false
  end

  if cfg.Silent.FOVColor == nil then
    cfg.Silent.FOVColor = Color3.fromRGB(255, 255, 255)
  end

  if cfg.Silent.FOVThickness == nil then
    cfg.Silent.FOVThickness = 1
  end

  if type(cfg.Silent.IgnorePlayers) ~= "table" then
    cfg.Silent.IgnorePlayers = {}
  end

  local ignorePlayer = cfg.Silent.IgnorePlayer

  if type(ignorePlayer) == "string" and ignorePlayer ~= "" and ignorePlayer ~= "None" then
    cfg.Silent.IgnorePlayers[ignorePlayer] = true
  end

  cfg.Silent.IgnorePlayer = nil
  cfg.Silent.ForceTypes = { Bullet = true, Rocket = true }
  cfg.Silent.CrosshairTypes = { Arrow = true }
  cfg.Silent.LobTypes = { Grenade = true }

  if cfg.Silent.AimAll == nil then
    cfg.Silent.AimAll = false
  end

  if cfg.Silent.ExtendThrows == nil then
    cfg.Silent.ExtendThrows = false
  end

  cfg.Silent.SpeedBoost = nil

  if type(cfg.Silent.MaxDistance) ~= "number" then
    cfg.Silent.MaxDistance = 10000
  else
    cfg.Silent.MaxDistance = math.clamp(cfg.Silent.MaxDistance, 50, 20000)
  end

  local v81 = mainGame
  local v82 = "stats"

  v81[v82] = mainGame.stats or {
    shots = 0,
    redirected = 0,
    frames = 0,
    espPlayers = 0,
    espNPCs = 0,
    targets = 0,
  }

  if type(mainGame.conns) == "table" then
    for index2, value2 in ipairs(mainGame.conns) do
      local v83 = value2
      pcall(function() v83:Disconnect() end)
    end
  end

  mainGame.conns = {}

  if type(mainGame.draws) == "table" then
    for index3, value3 in ipairs(mainGame.draws) do
      local v84 = value3

      pcall(function()
        if v84.Destroy then
          v84:Destroy()
        else
          v84:Remove()
        end
      end)
    end
  end

  if mainGame.gui then
    pcall(function() mainGame.gui:Destroy() end)
  end

  mainGame.gui = nil
  mainGame.draws = {}
  mainGame.pool = {}
  mainGame.fovCircle = nil

  if mainGame.Window then
    pcall(function() mainGame.Window:Destroy() end)
  end

  mainGame.Window = nil
  mainGame.tabsBuilt = false
  mainGame.friendDropdown = nil

  local v85 = mainGame
  local v86 = mainGame
  local v87 = mainGame
  local v88 = mainGame
  mainGame._fovR = nil
  v85._fovX = nil
  v86._fovY = nil
  v87._fovT = nil
  v88._fovC = nil

  if mainGame.hooked and mainGame.projModule and mainGame.origNew then
    pcall(function() mainGame.projModule.New = mainGame.origNew end)
    mainGame.hooked = false
  end

  if mainGame.fbBound then
    pcall(function() runService:UnbindFromRenderStep("MG_Fullbright") end)
    mainGame.fbBound = false
  end

  -- Invalidates asynchronous hook retries from an older execute/Unload.
  mainGame.hookGeneration = (mainGame.hookGeneration or 0) + 1
  mainGame.unloaded = false

  local function trackConnection(p4)
    mainGame.conns[#mainGame.conns + 1] = p4
    return p4
  end

  fullbrightBindingName = "MG_Fullbright"

  fullbrightSettings = {
    Brightness = 3,
    ClockTime = 14,
    Ambient = Color3.fromRGB(175, 175, 175),
    OutdoorAmbient = Color3.fromRGB(175, 175, 175),
    GlobalShadows = false,
    FogStart = 0,
    FogEnd = 1000000,
    ColorShift_Top = Color3.fromRGB(0, 0, 0),
    ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
    EnvironmentDiffuseScale = 1,
    EnvironmentSpecularScale = 1,
  }

  function saveLightingState()
    if mainGame.fbSaved then
      return
    else
      local v89 = { light = {}, atmo = {} }

      for key in pairs(fullbrightSettings) do
        local v90 = key
        local v91, v92 = pcall(function() return lighting[v90] end)

        if v91 then
          v89.light[v90] = v92
        end
      end

      for index4, value4 in ipairs(lighting:GetChildren()) do
        if value4:IsA("Atmosphere") then
          v89.atmo[value4] = {
            Density = value4.Density,
            Haze = value4.Haze,
            Glare = value4.Glare,
          }
        end
      end

      mainGame.fbSaved = v89
      return
    end
  end

  function applyFullbright()
    for key2, value5 in pairs(fullbrightSettings) do
      if lighting[key2] ~= value5 then
        lighting[key2] = value5
      end
    end

    for index5, value6 in ipairs(lighting:GetChildren()) do
      if value6:IsA("Atmosphere") then
        if value6.Density ~= 0 then
          value6.Density = 0
        end

        if value6.Haze ~= 0 then
          value6.Haze = 0
        end

        if value6.Glare ~= 0 then
          value6.Glare = 0
        end
      end
    end
  end

  function getEspGui()
    if mainGame.gui and mainGame.gui.Parent then
      return mainGame.gui
    end

    local instance = Instance.new("ScreenGui")
    instance.Name = "MainGameESP"
    instance.ResetOnSpawn = false
    instance.IgnoreGuiInset = true
    instance.DisplayOrder = 999999999

    if not pcall(function()
      local v93 = "Parent"
      instance[v93] = gethui and gethui() or coreGui
    end) or not instance.Parent then
      instance.Parent = localPlayer:WaitForChild("PlayerGui")
    end

    mainGame.gui = instance
    return instance
  end

  function setFullbright(p5)
    cfg.Misc.Fullbright = p5 and true or false

    if p5 then
      saveLightingState()
      applyFullbright()

      if not mainGame.fbBound then
        mainGame.fbBound = pcall(function()
          runService:BindToRenderStep(
            fullbrightBindingName, Enum.RenderPriority.Last.Value, applyFullbright
          )
        end)
      end
    else
      if mainGame.fbBound then
        mainGame.fbBound = false
        pcall(function() runService:UnbindFromRenderStep(fullbrightBindingName) end)
      end

      local fbSaved = mainGame.fbSaved

      if fbSaved then
        for key3, value7 in pairs(fbSaved.light) do
          local v94 = key3
          local v95 = value7
          pcall(function() lighting[v94] = v95 end)
        end

        for key4, value8 in pairs(fbSaved.atmo) do
          local v96 = key4
          local v97 = value8

          if v96.Parent then
            pcall(function()
              local haze = v97.Haze
              local glare = v97.Glare

              v96.Density = v97.Density
              v96.Haze = haze
              v96.Glare = glare
            end)
          end
        end
      end
      mainGame.fbSaved = nil
    end
  end

  function isTargetVisible(p6, p7, p8)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    local v98 = { workspace.CurrentCamera, localPlayer.Character, p7.Parent }

    if p8 then
      for index6, value9 in ipairs(p8) do
        v98[#v98 + 1] = value9
      end
    end

    raycastParams.FilterDescendantsInstances = v98
    local raycast = workspace:Raycast(p6, p7.Position - p6, raycastParams)
    return raycast == nil or raycast.Instance:IsDescendantOf(p7.Parent)
  end

  function collectTargets()
    local v99 = {}
    local players2 = workspace:FindFirstChild("Players")

    if players2 then
      for index7, value10 in ipairs(players2:GetChildren()) do
        if value10:IsA("Model") and not isLocalCharacter(value10) then
          local humanoid = value10:FindFirstChildOfClass("Humanoid")
          local head = value10:FindFirstChild("Head")
          local v100 = humanoid
          local humanoidRootPart = value10:FindFirstChild("HumanoidRootPart")

          if humanoid then
            v100 = humanoid.Health > 0 and head and humanoidRootPart
          end

          if v100 then
            v99[#v99 + 1] = {
              model = value10,
              name = value10.Name,
              hum = humanoid,
              head = head,
              hrp = humanoidRootPart,
              player = true,
            }
          end
        end
      end
    end

    local ai = workspace:FindFirstChild("AI")

    if ai then
      for index8, value11 in ipairs(ai:GetChildren()) do
        if value11:IsA("Model") then
          local humanoid2 = value11:FindFirstChildOfClass("Humanoid")
          local findFirstChild = value11:FindFirstChild("Head", true)

          local findFirstChild2 = value11:FindFirstChild("HumanoidRootPart", true)
            or humanoid2 and humanoid2.RootPart

          if humanoid2 and humanoid2.Health > 0 and findFirstChild then
            v99[#v99 + 1] = {
              model = value11,
              name = value11.Name,
              hum = humanoid2,
              head = findFirstChild,
              hrp = findFirstChild2,
              player = false,
            }
          end
        end
      end
    end

    return v99
  end

  function isLocalCharacter(p9)
    return p9 == localPlayer.Character or p9.Name == localPlayer.Name
  end

  function getTargetVelocity(p10)
    if p10.hrp then
      return p10.hrp.AssemblyLinearVelocity
    end

    if p10.head then
      return p10.head.AssemblyLinearVelocity
    end

    return Vector3.zero
  end

  function getAimPart(p11)
    if cfg.Silent.AimPart == "Body" then
      return p11.hrp or p11.head
    end

    return p11.head or p11.hrp
  end

  function solveBallisticDirection(p12, p13, p14, p15, p16)
    local unit = nil
    local v101 = 3
    local v102 = (p15 or 2000) * 2
    local v103 = 1
    local v104 = p13
    local v105 = p16 or 0
    local v106

    for i6 = 1, v101, v103 do
      local v107 = v104 - p12
      local vector = Vector3.new(v107.X, 0, v107.Z)
      local magnitude = vector.Magnitude

      if magnitude < 0.05 then
        unit = v107.Magnitude > 0.001 and v107.Unit or Vector3.new(0, 0, -1)
        break
      else
        local y = v107.Y
        local v108 = v105 * magnitude * magnitude / (2 * v102 * v102)

        if v108 > 1e-9 then
          local v109 = magnitude * magnitude - 4 * v108 * (y + v108)
          v106 = v109 >= 0 and (magnitude - math.sqrt(v109)) / (2 * v108) or 1
        else
          v106 = y / magnitude
        end

        local unit2 = vector.Unit
        local v110 = 1 / math.sqrt(1 + v106 * v106)
        unit = Vector3.new(unit2.X * v110, v106 * v110, unit2.Z * v110)

        if cfg.Silent.Prediction and p14 and p14.Magnitude > 0.01 then
          v104 = p13 + p14 * (magnitude / (v102 * v110))
        end
      end
    end

    return unit
  end

  function installProjectileHook()
    local installGeneration = mainGame.hookGeneration
    local v111, v112 = pcall(function()
      return require(replicatedStorage.Modules.Client.Physics.Projectile)
    end)

    local v113 = not v111 or type(v112) ~= "table" or type(v112.New) ~= "function"
    local v114

    if v113 then
      return false, tostring(v112)
    else
      if mainGame.unloaded or mainGame.hookGeneration ~= installGeneration then
        return false, "cancelled"
      end
      v114 = nil

      local v115, v116 = pcall(function()
        return require(replicatedStorage.Modules.Shared.ModuleLoader):Load("CrosshairManager")
      end)

      if mainGame.unloaded or mainGame.hookGeneration ~= installGeneration then
        return false, "cancelled"
      end
      if v115 and type(v116) == "table" and v116.AdjustSpring then
        v114 = v116
      end

      mainGame.projModule = v112
      mainGame.origNew = v112.New
      mainGame.hooked = false

      function v112.New(p17, p18, ...)
        mainGame.stats.shots = mainGame.stats.shots + 1
        local v117 = nil
        local position = nil

        pcall(function()
          if type(p18) ~= "table" or p18.FromServer then
            return
          end

          mainGame.stats.localShots = (mainGame.stats.localShots or 0) + 1
          local amogusState = mainGame.amogus
          if amogusState and amogusState.Active
            and amogusState.silentRedirectAt and amogusState.silentRedirectAt > 0
            and os.clock() - amogusState.silentRedirectAt < 0.25
            and type(p18.Stats) == "table"
            and cfg.Silent.ForceTypes[tostring(p18.Stats.Type)] == true
          then
            mainGame.stats.lastAim = { reason = "amogus mouse raycast" }
            return
          end
          local v118, gravity

          if not cfg.Silent.Enabled then
            mainGame.stats.lastAim = { reason = "silent off" }
            return
          else
            local stats = p18.Stats

            if not stats then
              mainGame.stats.lastAim = { reason = "no stats" }
              return
            else
              local v119 = tostring(stats.Type)
              local v120 = mainGame.stats
              local v121 = "types"
              v120[v121] = mainGame.stats.types or {}
              mainGame.stats.types[v119] = (mainGame.stats.types[v119] or 0) + 1

              if p18.ForceDown then
                mainGame.stats.lastAim = { reason = "forced down", type = v119 }
                return
              else
                local v122 = cfg.Silent.ForceTypes[v119] == true and stats.Velocity ~= nil
                local v123 = cfg.Silent.CrosshairTypes[v119] == true and stats.Velocity ~= nil
                local v124 = cfg.Silent.LobTypes[v119] == true and stats.Speed ~= nil

                local aimAll = not v122 and not v123 and not v124 and stats.Velocity ~= nil
                  and cfg.Silent.AimAll

                if not (v122 or v123 or v124 or aimAll) then
                  mainGame.stats.lastAim = { reason = "type=" .. v119 }
                  return
                else
                  if cfg.Silent.ExtendThrows and aimAll and stats.Drop and stats.Drop > 0 then
                    local v125 = {}

                    for key5, value12 in pairs(stats) do
                      v125[key5] = value12
                    end

                    v125.Drop = 0
                    local v126 = getmetatable(stats)

                    if v126 then
                      setmetatable(v125, v126)
                    end

                    p18.Stats = v125
                    stats = v125
                  end

                  local origin = p18.Origin or workspace.CurrentCamera.CFrame.Position

                  if v124 then
                    v118 = stats.Speed * 0.5
                    gravity = workspace.Gravity
                  else
                    v118 = stats.Velocity
                    gravity = stats.Drop
                  end

                  local v127 = cfg.Silent.MaxDistance

                  if gravity and gravity > 0 and v118 then
                    local v128 = v118 * 2
                    v127 = math.min(v127, v128 * v128 / gravity * 0.95)
                  end

                  local v129, v130 = selectTarget(v127)
                  v130.type = v119
                  local v131 = "model"

                  v130[v131] = v122 and "force" or v123 and "crosshair" or v124 and "lob"
                    or "lookvector"

                  local v132 = "reason"
                  v130[v132] = v129 and "redirect" or "no target"
                  mainGame.stats.lastAim = v130

                  if not v129 then
                    return
                  else
                    local v133 = solveBallisticDirection(
                      origin, v129.part.Position, v129.vel, v118, gravity
                    )

                    if not v133 then
                      return
                    end

                    v130.pitch = math.deg(math.asin(math.clamp(v133.Y, -1, 1)))
                    v130.dist = math.floor((v129.part.Position - origin).Magnitude)
                    v130.vel = v118
                    v130.drop = gravity

                    if v114 then
                      position = v114.AdjustSpring.Position
                      v114.AdjustSpring.Position = 0
                    end

                    if v122 then
                      p18.ForceHitVector = origin + v133 * (v130.dist + 200)
                      mainGame.stats.redirected = mainGame.stats.redirected + 1
                    else
                      local v134 = workspace.CurrentCamera
                      local v135 = v134.CFrame
                      v117 = v135
                      local v136 = v135.Position
                      v134.CFrame = CFrame.lookAt(v136, v136 + v133)

                      if v123 then
                        local v137 = (v134.ViewportSize - Vector2.new(0, 72)) / 2
                        local v138 = 3
                        local v139 = 1
                        local v140 = v139 < 0
                        local v141 = 1 - v139

                        while true do
                          v141 = v139 + v141

                          if not (v140 and v141 >= v138 or not v140 and v141 <= v138) then
                            break
                          end

                          local direction = v134:ScreenPointToRay(v137.X, v137.Y).Direction
                          local cross = direction:Cross(v133)

                          if cross.Magnitude < 1e-7 then
                            break
                          else
                            local v142 = math.acos(math.clamp(direction:Dot(v133), -1, 1))

                            if v142 < 0.0001 then
                              break
                            else
                              local cframe = CFrame.fromAxisAngle(cross.Unit, v142)

                              v134.CFrame = CFrame.new(v136) * cframe * CFrame.new(-v136)
                                * v134.CFrame
                            end
                          end
                        end
                      end

                      mainGame.stats.redirected = mainGame.stats.redirected + 1
                    end

                    return
                  end
                end
              end
            end
          end
        end)

        -- Preserve varargs/multi-returns and always restore temporary camera /
        -- AdjustSpring state, including when the original function errors.
        local originalResults = table.pack(pcall(mainGame.origNew, p17, p18, ...))

        if v117 then
          pcall(function() workspace.CurrentCamera.CFrame = v117 end)
        end

        if position ~= nil and v114 then
          pcall(function() v114.AdjustSpring.Position = position end)
        end

        if not originalResults[1] then
          error(originalResults[2], 0)
        end
        return table.unpack(originalResults, 2, originalResults.n)
      end

      mainGame.hooked = true
      return true
    end
  end

  function selectTarget(p19)
    local maxDistance = p19
    local currentCamera = workspace.CurrentCamera
    local position2 = currentCamera.CFrame.Position
    local lookVector = currentCamera.CFrame.LookVector

    if not maxDistance then
      maxDistance = cfg.Silent.MaxDistance
    end

    local v144 = cfg.Silent.FOV + 1
    local v145 = nil
    local v146 = cfg.Silent.FOV + 1
    local v147 = nil

    local v148 = {
      total = 0,
      inFov = 0,
      nearest = "none",
      nearestAng = nil,
      nearestDist = nil,
    }

    for index9, value13 in ipairs(collectTargets()) do
      local v149 = false

      if cfg.Silent.IgnorePlayers and cfg.Silent.IgnorePlayers[value13.name] then
        v149 = true
      end

      if not v149 and (value13.player or cfg.Silent.TargetNPCs) then
        local v150 = getAimPart(value13)

        if v150 then
          v148.total = v148.total + 1
          local v151 = v150.Position - position2
          local magnitude2 = v151.Magnitude

          if magnitude2 > 0.1 and magnitude2 <= maxDistance then
            local v152 = math.deg(math.acos(math.clamp(lookVector:Dot(v151 / magnitude2), -1, 1)))

            if v148.nearestAng == nil or v152 < v148.nearestAng then
              v148.nearestAng = v152
              v148.nearest = value13.name
              v148.nearestDist = math.floor(magnitude2)
            end

            if v152 <= cfg.Silent.FOV then
              local v153 = true

              if cfg.Silent.VisibleOnly then
                v153 = isTargetVisible(position2, v150)
              end

              if v153 then
                v148.inFov = v148.inFov + 1

                if value13.player and v152 < v144 then
                  v144 = v152
                  v145 = { part = v150, t = value13, vel = getTargetVelocity(value13) }
                end

                if v152 < v146 then
                  v146 = v152
                  v147 = { part = v150, t = value13, vel = getTargetVelocity(value13) }
                end
              end
            end
          end
        end
      end
    end

    if cfg.Silent.PriorityPlayers and v145 then
      v148.chosen = v145.t.name
      return v145, v148
    end

    if v147 then
      v148.chosen = v147.t.name
    else
      local v154 = "chosen"
      v148[v154] = v145 and v145.t.name or "none"
    end

    return v147 or v145, v148
  end

  function createTextDrawing(p20, p21)
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold

    local v155 = "TextSize"
    textLabel[v155] = p20 or 13
    local v156 = "AnchorPoint"

    textLabel[v156] = p21 == false and Vector2.new(0, 0) or Vector2.new(0.5, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Text = ""
    textLabel.Visible = false
    textLabel.ZIndex = 3
    textLabel.Parent = getEspGui()

    mainGame.draws[#mainGame.draws + 1] = textLabel

    return makeDrawingWrapper(textLabel, function(p22, p23)
      if p23 == "Position" then
        return Vector2.new(p22.Position.X.Offset, p22.Position.Y.Offset)
      elseif p23 == "Color" then
        return p22.TextColor3
      elseif p23 == "Outline" then
        return p22.TextStrokeTransparency == 0
      elseif p23 == "OutlineColor" then
        return p22.TextStrokeColor3
      else
        if p23 == "Size" then
          return p22.TextSize
        end

        if p23 == "Text" then
          return p22.Text
        end

        return
      end
    end, function(p24, p25, p26)
      if p25 == "Position" then
        p24.Position = UDim2.fromOffset(p26.X, p26.Y)
        return true
      elseif p25 == "Color" then
        p24.TextColor3 = p26
        return true
      elseif p25 == "Outline" then
        p24.TextStrokeTransparency = p26 and 0 or 1
        return true
      elseif p25 == "OutlineColor" then
        p24.TextStrokeColor3 = p26
        return true
      elseif p25 == "Size" then
        p24.TextSize = p26
        return true
      else
        if p25 == "Text" then
          p24.Text = p26
          return true
        end

        if p25 == "Transparency" then
          p24.TextTransparency = 1 - p26
          return true
        end

        return
      end
    end)
  end

  function makeDrawingWrapper(inst, p27, p28)
    local v157 = { __inst = inst, __props = {} }

    setmetatable(v157, {
      __index = function(object, key6)
        local v158 = rawget(object, "__inst")

        if p27 then
          local v159 = p27(v158, key6)

          if v159 ~= nil then
            return v159
          end

          return rawget(object, "__props")[key6]
        end

        return rawget(object, "__props")[key6]
      end,
      __newindex = function(object2, key7, value14)
        local v160 = rawget(object2, "__inst")

        if p28 and p28(v160, key7, value14) then
          return
        end

        rawget(object2, "__props")[key7] = value14

        if key7 == "Visible" then
          v160.Visible = value14
        end
      end,
    })

    function v157.Destroy()
      pcall(function() v157.__inst:Destroy() end)
    end

    v157.Remove = v157.Destroy

    return v157
  end

  function createBoxDrawing(p29, p30, p31, p32)
    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 2

    local uiStroke = nil

    if p29 then
      local v161 = "BackgroundColor3"
      frame[v161] = p31 or Color3.new(1, 1, 1)
      frame.BackgroundTransparency = 1 - (p32 or 1)
    else
      frame.BackgroundTransparency = 1
      uiStroke = Instance.new("UIStroke")
      local v162 = uiStroke
      local v163 = "Color"
      v162[v163] = p31 or Color3.new(1, 1, 1)

      uiStroke.Thickness = p30 or 1
      uiStroke.Transparency = 1 - (p32 or 1)
      uiStroke.Parent = frame
    end

    frame.Parent = getEspGui()
    mainGame.draws[#mainGame.draws + 1] = frame

    return makeDrawingWrapper(frame, function(p33, p34)
      if p34 == "Position" then
        return Vector2.new(p33.Position.X.Offset, p33.Position.Y.Offset)
      end

      if p34 == "Size" then
        return Vector2.new(p33.Size.X.Offset, p33.Size.Y.Offset)
      end

      if p34 == "Color" then
        return uiStroke and uiStroke.Color or p33.BackgroundColor3
      end
    end, function(p35, p36, p37)
      if p36 == "Position" then
        p35.Position = UDim2.fromOffset(p37.X, p37.Y)
        return true
      elseif p36 == "Size" then
        p35.Size = UDim2.fromOffset(p37.X, p37.Y)
        return true
      else
        if p36 == "Color" then
          if uiStroke then
            uiStroke.Color = p37
          else
            p35.BackgroundColor3 = p37
          end

          return true
        end

        if p36 == "Transparency" then
          if uiStroke then
            uiStroke.Transparency = 1 - p37
          else
            p35.BackgroundTransparency = 1 - p37
          end

          return true
        end

        return
      end
    end)
  end

  function createEspEntry()
    return {
      box = createBoxDrawing(false, 1, Color3.new(1, 1, 1), 1),
      outline = createBoxDrawing(false, 3, Color3.new(0, 0, 0), 1),
      fill = createBoxDrawing(true, 1, Color3.new(1, 1, 1), 0.15),
      name = createTextDrawing(13, true),
      hpBg = createBoxDrawing(true, 1, Color3.new(0, 0, 0), 0.6),
      hpFill = createBoxDrawing(true, 1, Color3.new(0, 1, 0), 1),
      dist = createTextDrawing(12, true),
      s = {},
    }
  end

  local v164 = mainGame
  local v165 = "pool"
  v164[v165] = mainGame.pool or {}

  function ensureEspPool(p38)
    while #mainGame.pool < p38 do
      mainGame.pool[#mainGame.pool + 1] = createEspEntry()
    end
  end

  function updateBoxDrawing(p39, p40, p41, p42, p43, p44, p45, p46, p47)
    local v169 = p39.s[p40]

    if not v169 then
      v169 = {}
      p39.s[p40] = v169
    end

    if v169.v ~= p42 then
      v169.v = p42
      p41.Visible = p42
    end

    if not p42 then
      return
    end

    if v169.bx ~= p43 or v169.by ~= p44 or v169.w ~= p45 or v169.h ~= p46 then
      v169.bx = p43
      v169.by = p44
      v169.w = p45
      v169.h = p46

      p41.Position = Vector2.new(p43, p44)
      p41.Size = Vector2.new(p45, p46)
    end

    if p47 ~= nil and v169.col ~= p47 then
      v169.col = p47
      p41.Color = p47
    end
  end

  function getFovCircle()
    local uiStroke2

    if not mainGame.fovCircle and Drawing ~= nil and type(Drawing.new) == "function" then
      local drawingOk, drawingCircle = pcall(function()
        local circle = Drawing.new("Circle")
        circle.Visible = false
        circle.Transparency = 1
        circle.Filled = false
        circle.NumSides = 32
        circle.ZIndex = 2
        circle.Color = cfg.Silent.FOVColor or Color3.new(1, 1, 1)
        circle.Thickness = cfg.Silent.FOVThickness or 1
        return circle
      end)
      if drawingOk and drawingCircle then
        mainGame.draws[#mainGame.draws + 1] = drawingCircle
        mainGame.fovCircle = drawingCircle
      end
    end

    if not mainGame.fovCircle then
      local frame2 = Instance.new("Frame")
      frame2.BorderSizePixel = 0
      frame2.BackgroundTransparency = 1
      frame2.AnchorPoint = Vector2.new(0.5, 0.5)
      frame2.Visible = false
      frame2.ZIndex = 2

      local uiCorner = Instance.new("UICorner")
      uiCorner.CornerRadius = UDim.new(1, 0)
      uiCorner.Parent = frame2

      uiStroke2 = Instance.new("UIStroke")
      uiStroke2.Thickness = cfg.Silent.FOVThickness or 1

      local v170 = "Color"

      uiStroke2[v170] = cfg.Silent.FOVColor or Color3.new(1, 1, 1)
      uiStroke2.Parent = frame2

      frame2.Parent = getEspGui()

      mainGame.draws[#mainGame.draws + 1] = frame2

      mainGame.fovCircle = makeDrawingWrapper(frame2, function(p48, p49)
        if p49 == "Position" then
          return Vector2.new(p48.Position.X.Offset, p48.Position.Y.Offset)
        elseif p49 == "Size" then
          return Vector2.new(p48.Size.X.Offset, p48.Size.Y.Offset)
        elseif p49 == "Color" then
          return uiStroke2.Color
        else
          if p49 == "Thickness" then
            return uiStroke2.Thickness
          end

          if p49 == "Radius" then
            return p48.Size.X.Offset / 2
          end

          return
        end
      end, function(p50, p51, p52)
        if p51 == "Position" then
          p50.Position = UDim2.fromOffset(p52.X, p52.Y)
          return true
        elseif p51 == "Radius" then
          p50.Size = UDim2.fromOffset(p52 * 2, p52 * 2)
          return true
        else
          if p51 == "Color" then
            uiStroke2.Color = p52
            return true
          end

          if p51 == "Thickness" then
            uiStroke2.Thickness = p52
            return true
          end

          return
        end
      end)
    end

    return mainGame.fovCircle
  end

  function updateTextDrawing(p53, p54, p55, p56, p57, p58, p59, p60)
    local v171 = p53.s[p54]

    if not v171 then
      v171 = {}
      p53.s[p54] = v171
    end

    if v171.v ~= p56 then
      v171.v = p56
      p55.Visible = p56
    end

    if not p56 then
      return
    end

    if v171.bx ~= p57 or v171.by ~= p58 then
      v171.bx = p57
      v171.by = p58
      p55.Position = Vector2.new(p57, p58)
    end

    if v171.t ~= p59 then
      v171.t = p59
      p55.Text = p59
    end

    if p60 ~= nil and v171.col ~= p60 then
      v171.col = p60
      p55.Color = p60
    end
  end

  function hideEspEntry(p61)
    updateBoxDrawing(p61, "box", p61.box, false)
    updateBoxDrawing(p61, "outline", p61.outline, false)
    updateBoxDrawing(p61, "fill", p61.fill, false)
    updateBoxDrawing(p61, "hpBg", p61.hpBg, false)
    updateBoxDrawing(p61, "hpFill", p61.hpFill, false)
    updateBoxDrawing(p61, "name", p61.name, false)
    updateBoxDrawing(p61, "dist", p61.dist, false)
  end

  function updateFovCircle(p62)
    local v172 = getFovCircle()

    if cfg.Silent.Enabled and cfg.Silent.ShowFOV then
      local viewportSize = p62.ViewportSize
      local v173 = math.rad(p62.FieldOfView)

      local v174 = viewportSize.Y * 0.5
          * math.tan(math.rad(math.min(cfg.Silent.FOV, 175) * 0.5))
        / math.tan(v173 * 0.5)

      local v175 = math.min(viewportSize.X, viewportSize.Y) * 0.45

      if v174 > v175 then
        v174 = v175
      end

      if mainGame._fovR ~= v174 then
        mainGame._fovR = v174
        v172.Radius = v174
      end

      local v176 = viewportSize.Y * 0.5
      local v177 = viewportSize.X * 0.5

      if mainGame._fovX ~= v177 or mainGame._fovY ~= v176 then
        local v178 = mainGame
        mainGame._fovX = v177
        v178._fovY = v176
        v172.Position = Vector2.new(v177, v176)
      end

      local fovThickness = cfg.Silent.FOVThickness or 1

      if mainGame._fovT ~= fovThickness then
        mainGame._fovT = fovThickness
        v172.Thickness = fovThickness
      end

      if mainGame._fovC ~= cfg.Silent.FOVColor then
        mainGame._fovC = cfg.Silent.FOVColor
        local v179 = "Color"
        v172[v179] = cfg.Silent.FOVColor or Color3.new(1, 1, 1)
      end

      if not v172.Visible then
        v172.Visible = true
      end
    elseif v172.Visible then
      v172.Visible = false
    end
  end

  function renderEsp()
    mainGame.stats.frames = mainGame.stats.frames + 1
    local currentCamera2 = workspace.CurrentCamera
    local position3 = currentCamera2.CFrame.Position
    local v180 = getCachedTargets()
    local maxTargets = cfg.ESP.MaxTargets or 64
    local v181 = {}

    if cfg.ESP.Enabled then
      for index10, value15 in ipairs(v180) do
        local players3 = value15.player and cfg.ESP.Players
          or not value15.player and cfg.ESP.NPCs

        local head2 = value15.head

        if players3 and head2 and head2.Parent and value15.hum and value15.hum.Parent
          and value15.hum.Health > 0 then
          if (head2.Position - position3).Magnitude <= cfg.ESP.MaxDistance then
            v181[#v181 + 1] = value15

            if #v181 >= maxTargets then
              break
            end
          end
        end
      end
    end

    mainGame.stats.espPlayers = 0
    mainGame.stats.espNPCs = 0

    ensureEspPool(#v181)
    mainGame.stats.targets = #v181
    local color

    for index11, value16 in ipairs(mainGame.pool) do
      local v182 = v181[index11]

      if not v182 then
        hideEspEntry(value16)
      else
        if v182.player then
          mainGame.stats.espPlayers = mainGame.stats.espPlayers + 1
        else
          mainGame.stats.espNPCs = mainGame.stats.espNPCs + 1
        end

        local head3 = v182.head
        local hrp = v182.hrp
        local v183 = head3.Position + Vector3.new(0, head3.Size.Y * 0.5, 0)

        local v184 = hrp and hrp.Position - Vector3.new(0, 3, 0)
          or head3.Position - Vector3.new(0, 3, 0)

        local v185, v186 = currentCamera2:WorldToViewportPoint(v183)
        local v187, v188 = currentCamera2:WorldToViewportPoint(v184)

        if v186 and v188 and v185.Z > 0 and v187.Z > 0 then
          local v189 = v185.X
          local v190 = "Y"
          local v191 = v187.Y
          local v192 = v185[v190]

          if v192 > v191 then
            local v193 = v191
            v191 = v192
            v192 = v193
          end

          local v194 = math.abs(v191 - v192)

          if v194 < 4 then
            v194 = 4
          end

          local v195 = v194 * 0.6
          local v196 = v189 - v195 / 2
          local v197 = v182.player
          local playerColor = v197
          local v198 = v192

          if v197 then
            playerColor = cfg.ESP.PlayerColor
          end

          local v199 = playerColor
          v199 = playerColor or cfg.ESP.NPCColor

          updateBoxDrawing(
            value16, "outline", value16.outline, cfg.ESP.Box, v196, v198, v195, v194
          )

          updateBoxDrawing(
            value16, "box", value16.box, cfg.ESP.Box, v196, v198, v195, v194, v199
          )

          updateBoxDrawing(
            value16, "fill", value16.fill, cfg.ESP.BoxFill, v196, v198, v195, v194, v199
          )

          updateTextDrawing(
            value16, "name", value16.name, cfg.ESP.Name, v189, v198 - 16, v182.name, v199
          )

          if cfg.ESP.Health and v182.hum then
            local v200 = 0

            if v182.hum.MaxHealth > 0 then
              v200 = math.clamp(v182.hum.Health / v182.hum.MaxHealth, 0, 1)
            end

            local v201 = v194 * v200

            updateBoxDrawing(
              value16, "hpBg", value16.hpBg, true, v196 - 6, v198, 3, v194, Color3.new(0, 0, 0)
            )

            if v200 > 0.6 then
              color = Color3.fromRGB(0, 220, 0)
            elseif v200 > 0.3 then
              color = Color3.fromRGB(240, 220, 0)
            else
              color = Color3.fromRGB(230, 40, 40)
            end

            updateBoxDrawing(
              value16, "hpFill", value16.hpFill, true, v196 - 6, v198 + (v194 - v201), 3, v201,
              color
            )
          else
            updateBoxDrawing(value16, "hpBg", value16.hpBg, false)
            updateBoxDrawing(value16, "hpFill", value16.hpFill, false)
          end

          if cfg.ESP.Distance then
            updateTextDrawing(value16, "dist", value16.dist, true, v189, v198 + v194 + 3, string.format(
              "[%d]", math.floor((head3.Position - position3).Magnitude)
            ), v199)
          else
            updateTextDrawing(value16, "dist", value16.dist, false)
          end
        else
          hideEspEntry(value16)
        end
      end
    end
  end

  function tableKeys(p63)
    local v202 = {}

    if type(p63) == "table" then
      for key8 in pairs(p63) do
        v202[#v202 + 1] = key8
      end
    end

    return v202
  end

  function getPlayerNames()
    local v203 = {}

    for index12, value17 in ipairs(players:GetPlayers()) do
      if value17 ~= localPlayer then
        v203[#v203 + 1] = value17.Name
      end
    end

    table.sort(v203, function(p64, p65) return string.lower(p64) < string.lower(p65) end)
    return v203
  end

  function getCachedTargets(maximumAge)
    local v204 = os.clock()
    local scanInterval = cfg.ESP.ScanInterval or 0.15
    if maximumAge then scanInterval = math.min(scanInterval, maximumAge) end

    if mainGame.targetList and v204 < (mainGame.nextScan or 0)
      and (not maximumAge or v204 - (mainGame.targetListAt or 0) < maximumAge) then
      return mainGame.targetList
    end

    mainGame.nextScan = v204 + scanInterval
    mainGame.targetListAt = v204
    mainGame.targetList = collectTargets()

    return mainGame.targetList
  end


  function buildUi()
    local function uiBuildTraceback(value)
      local message = tostring(value)
      if type(value) == "table" then
        local ok, fields = pcall(function()
          local parts = {}
          for key, child in pairs(value) do
            parts[#parts + 1] = tostring(key) .. "=" .. tostring(child)
            if #parts >= 8 then break end
          end
          return table.concat(parts, ", ")
        end)
        if ok and fields ~= "" then message = "table{" .. fields .. "}" end
      end
      if debug and type(debug.traceback) == "function" then
        local ok, trace = pcall(debug.traceback, message, 2)
        if ok and type(trace) == "string" then
          if string.find(trace, message, 1, true) then return trace end
          return message .. "\n" .. trace
        end
      end
      return message
    end

    local ok, result = xpcall(function()
    if mainGame.tabsBuilt and mainGame.Window and not mainGame.Window.Destroyed then
      return mainGame.Window
    end

    -- Standalone adapter for the exact 621x542 source-structure menu. Only UI code is shared;
    -- unrelated gameplay and crafting are not included in this build.
    local _burmaldaEnv = getgenv and getgenv() or _G
    local TS = game:GetService("TweenService")
    local UIS = userInputService
    local Runtime = { Unloaded = false, StartClosed = true }
    local menuCleanup = {}
    local windowAdapter = nil
    local function onCleanup(fn)
      table.insert(menuCleanup, fn)
    end
    local camera = workspace.CurrentCamera
    local _isLargeScreen = camera ~= nil and camera.ViewportSize.X >= 1024

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


    local sg = Instance.new("ScreenGui")
    sg.Name = "BurmaldaHookLoneSurvival"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 1000000000
    local parentOk = pcall(function()
      sg.Parent = gethui and gethui() or coreGui
    end)
    if not parentOk or sg.Parent == nil then
      sg.Parent = localPlayer:WaitForChild("PlayerGui")
    end

    -- Shared second-screen HUD; hiding the menu never hides or destroys it.
    local statsHud = createBurmaldaStatsHud({
      Parent = sg,
      Workspace = workspace,
      LocalPlayer = localPlayer,
      Stats = game:GetService("Stats"),
      IsActive = function() return not Runtime.Unloaded end,
    })
    onCleanup(function() statsHud.Destroy() end)

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

    -- Draggable floating open button; all connections belong to this window.
    do
      local dragging, dragInput, dragStart, startPos
      local changedConnection = nil
      local connections = {}
      table.insert(connections, openBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
          or input.UserInputType == Enum.UserInputType.Touch then
          dragging = true
          dragStart = input.Position
          startPos = openBtn.Position
          if changedConnection then changedConnection:Disconnect() end
          changedConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
              dragging = false
              if changedConnection then
                changedConnection:Disconnect()
                changedConnection = nil
              end
            end
          end)
        end
      end))
      table.insert(connections, openBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
          or input.UserInputType == Enum.UserInputType.Touch then
          dragInput = input
        end
      end))
      table.insert(connections, UIS.InputChanged:Connect(function(input)
        if not Runtime.Unloaded and input == dragInput and dragging then
          local delta = input.Position - dragStart
          openBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
      end))
      onCleanup(function()
        dragging = false
        if changedConnection then pcall(function() changedConnection:Disconnect() end) end
        for _, connection in ipairs(connections) do
          pcall(function() connection:Disconnect() end)
        end
      end)
    end
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
    ["Instant Equip"] = true, ["Shoot While Sprinting"] = true,
    ["Reload While Sprinting"] = true, ["Instant Reload"] = true,
    ["Auto Reload"] = true, ["Fast Bow"] = true, ["Instant Eoka"] = true,
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
	["Target Indicator"] = true,
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
	["FOV Circle"] = "COMBAT", ["Dynamic FOV"] = "COMBAT",
	["Snapline"] = "COMBAT", ["Target Indicator"] = "VISUALS",
	["FOV Changer"] = "VISUALS", ["Zoom"] = "VISUALS",
	["Aim All Projectiles"] = "COMBAT", ["Extend Throws"] = "COMBAT",
	["Night Mode"] = "MISC", ["Night Vision"] = "MISC", ["Low PC"] = "MISC",
	["Fullbright"] = "MISC", ["No Decoration"] = "MISC", ["Sky Color"] = "MISC",
	["Skybox"] = "MISC", ["Delete Spikes"] = "MISC", ["Delete Leaves"] = "MISC",
	["Custom Models"] = "MISC", ["Custom Fog"] = "MISC", ["Custom Water"] = "MISC",
	["X-Ray"] = "VISUALS", ["Remove Fog"] = "MISC", ["Remove Grass"] = "MISC",
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
	if windowAdapter then windowAdapter.Closed = not menuOpen end
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


    -- Programmatic control registry and standalone JSON config support.
    local featureStates, featureForContainer = {}, {}
    local optionApis, bindApis = {}, {}
    local baseCreateFeature = createFeature
    createFeature = function(parent, name, default, callback, hasSettings)
      local container = baseCreateFeature(parent, name, default, function(value)
        featureStates[name] = value
        if callback then callback(value) end
      end, hasSettings)
      featureStates[name] = default
      featureForContainer[container] = name
      return container
    end

    local function optionKey(parent, name)
      return (featureForContainer[parent] or "Unknown") .. " :: " .. name
    end

    local baseAddSlider = addSlider
    addSlider = function(parent, name, minValue, maxValue, default, callback)
      local entry = { Value = default }
      local key = optionKey(parent, name)
      entry.Set = baseAddSlider(parent, name, minValue, maxValue, default, function(value)
        entry.Value = value
        if callback then callback(value) end
      end)
      optionApis[key] = entry
      return entry.Set
    end

    local baseAddDropdown = addDropdown
    addDropdown = function(parent, name, options, defaultIndex, callback)
      local entry = { Value = options[defaultIndex] }
      local key = optionKey(parent, name)
      entry.Set = baseAddDropdown(parent, name, options, defaultIndex, function(value)
        entry.Value = value
        if callback then callback(value) end
      end)
      optionApis[key] = entry
      return entry.Set
    end

    local baseAddColor = addColor
    addColor = function(parent, name, callback, defaultColor)
      local entry = { Value = defaultColor or Color3.new(1, 1, 1) }
      local key = optionKey(parent, name)
      entry.Set = baseAddColor(parent, name, function(value)
        entry.Value = value
        if callback then callback(value) end
      end, defaultColor)
      optionApis[key] = entry
      return entry.Set
    end

    local baseAddBind = addBind
    addBind = function(parent, name, default, onPress, onChanged)
      local featureName = featureForContainer[parent] or name
      local entry = { Value = default or "None" }
      local api = baseAddBind(parent, name, default, onPress, function(keyName)
        entry.Value = keyName
        if onChanged then onChanged(keyName) end
      end)
      entry.Get = api.Get
      entry.Set = api.Set
      bindApis[featureName] = entry
      return api
    end

    mainGame.featureStates = featureStates
    mainGame.optionApis = optionApis
    mainGame.bindApis = bindApis

    local httpService = game:GetService("HttpService")
    local configFolder = "BurmaldaHook/LoneSurvival/configs"
    local configApi = {}
    mainGame.configApi = configApi

    local function encodeValue(value)
      local valueType = typeof(value)
      if valueType == "Color3" then
        return { __burmaldaType = "Color3", R = value.R, G = value.G, B = value.B }
      end
      if type(value) == "table" then
        local result = {}
        for key, child in pairs(value) do
          if type(key) == "string" or type(key) == "number" then
            result[key] = encodeValue(child)
          end
        end
        return result
      end
      if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
        return value
      end
      return nil
    end

    local function decodeValue(value)
      if type(value) ~= "table" then return value end
      if value.__burmaldaType == "Color3" then
        return Color3.new(value.R or 0, value.G or 0, value.B or 0)
      end
      local result = {}
      for key, child in pairs(value) do result[key] = decodeValue(child) end
      return result
    end

    local function mergeTables(destination, source)
      for key, value in pairs(source) do
        if type(value) == "table" and type(destination[key]) == "table" then
          mergeTables(destination[key], value)
        else
          destination[key] = value
        end
      end
    end

    local function ensureConfigFolders()
      for _, folder in ipairs({ "BurmaldaHook", "BurmaldaHook/LoneSurvival", configFolder }) do
        if not isfolder(folder) then makefolder(folder) end
      end
    end

    function configApi.List()
      local names = {}
      local ok, files = pcall(function()
        ensureConfigFolders()
        return listfiles(configFolder)
      end)
      if not ok or type(files) ~= "table" then return names end
      for _, path in ipairs(files) do
        if type(path) ~= "string" then continue end
        local name = string.match(path, "([^/\\]+)%.json$")
        if name then names[#names + 1] = name end
      end
      table.sort(names)
      return names
    end

    function configApi.Save()
      local options, binds = {}, {}
      for key, entry in pairs(optionApis) do options[key] = encodeValue(entry.Value) end
      for key, entry in pairs(bindApis) do binds[key] = entry.Get() end
      local payload = {
        Version = 1,
        Cfg = encodeValue(cfg),
        Toggles = encodeValue(featureStates),
        Options = options,
        Binds = binds,
      }
      local ok, encoded = pcall(httpService.JSONEncode, httpService, payload)
      if not ok then return nil, encoded end
      local existing = {}
      for _, name in ipairs(configApi.List()) do existing[name] = true end
      local index = 1
      while existing["config" .. index] do index = index + 1 end
      local name = "config" .. index
      local writeOk, writeError = pcall(function()
        ensureConfigFolders()
        writefile(configFolder .. "/" .. name .. ".json", encoded)
      end)
      if not writeOk then return nil, writeError end
      return name
    end

    function configApi.Load(name)
      if type(name) ~= "string" or name == "" then return false, "no config selected" end
      local ok, decoded = pcall(function()
        local content = readfile(configFolder .. "/" .. name .. ".json")
        return httpService:JSONDecode(content)
      end)
      if not ok or type(decoded) ~= "table" then return false, decoded end
      if type(decoded.Cfg) == "table" then
        mergeTables(cfg, decodeValue(decoded.Cfg))
        -- IgnorePlayers is a map, not a schema with additive defaults. Loading
        -- must remove keys that were absent from the saved map.
        local savedSilent = decoded.Cfg.Silent
        if type(savedSilent) == "table" and type(savedSilent.IgnorePlayers) == "table" then
          cfg.Silent.IgnorePlayers = decodeValue(savedSilent.IgnorePlayers)
        end
      end
      if type(cfg.Silent) == "table" then
        for _, key in ipairs({ "ForceHit", "Hitscan", "HitscanDistance", "HitscanIndicator", "HitscanIndicatorColor" }) do
          cfg.Silent[key] = nil
        end
        if cfg.Silent.AimPart == "Torso" then
          cfg.Silent.AimPart = "Body"
        elseif cfg.Silent.AimPart ~= "Body" then
          cfg.Silent.AimPart = "Head"
        end
      end
      for featureName, value in pairs(decodeValue(decoded.Toggles or {})) do
        if featureName ~= "Force Hit" and featureName ~= "Hitscan" and featureName ~= "Hitscan Indicator" then
          featureStates[featureName] = value
          if _fFS[featureName] then _fFS[featureName](value) end
        end
      end
      for key, value in pairs(decoded.Options or {}) do
        local entry = optionApis[key]
        if entry and entry.Set then entry.Set(decodeValue(value)) end
      end
      for key, value in pairs(decoded.Binds or {}) do
        local entry = bindApis[key]
        if entry and entry.Set then entry.Set(value) end
      end
      if mainGame.calamariVisuals then mainGame.calamariVisuals.SyncUI() end
      if mainGame.friendDropdown and mainGame.friendDropdown.Set then
        mainGame.friendDropdown.Set(cfg.Silent.IgnorePlayers or {})
      end
      return true
    end

    function configApi.Delete(name)
      if type(name) ~= "string" or name == "" then return false end
      local ok = pcall(delfile, configFolder .. "/" .. name .. ".json")
      return ok
    end


    -- Lone-only controls use the same source sections and 14px Gotham controls.
    local function resolveControlParent(parent, name)
      if sectionContents[parent] then return parent end
      if columnSections[parent] then return getSection(parent, defaultSectionName(parent, name)).Content end
      return parent
    end
    local function addButton(parent, name, callback)
      parent = resolveControlParent(parent, name)
      local button = Instance.new("TextButton", parent)
      button.Size = UDim2.new(1, 0, 0, 20)
      button.BackgroundColor3 = Theme.Element
      button.BorderSizePixel = 0
      button.AutoButtonColor = false
      button.Font = Enum.Font.Gotham
      button.TextSize = 14
      button.TextColor3 = Theme.Text
      button.Text = name
      sourceStroke(button)
      sourceGradient(button, 90, Color3.fromRGB(220, 220, 220))
      button.MouseButton1Click:Connect(function()
        if not Runtime.Unloaded then callback() end
      end)
      return button
    end

    local function addLabel(parent, text)
      parent = resolveControlParent(parent, text)
      local label = Instance.new("TextLabel", parent)
      label.Size = UDim2.new(1, 0, 0, 15)
      label.AutomaticSize = Enum.AutomaticSize.Y
      label.BackgroundTransparency = 1
      label.Font = Enum.Font.Gotham
      label.TextSize = 14
      label.TextColor3 = Theme.SubText
      label.TextWrapped = true
      label.TextXAlignment = Enum.TextXAlignment.Left
      label.Text = text
      return label
    end

    local function addMultiDropdown(parent, name, options, selected, callback)
      parent = resolveControlParent(parent, name)
      local selectedSet = {}
      for key, value in pairs(selected or {}) do
        if value then selectedSet[key] = true end
      end
      local currentOptions = {}
      local container = Instance.new("Frame", parent)
      container.Size = UDim2.new(1, 0, 0, 0)
      container.AutomaticSize = Enum.AutomaticSize.Y
      container.BackgroundColor3 = Theme.Element
      container.BorderSizePixel = 0
      sourceStroke(container)
      local padding = Instance.new("UIPadding", container)
      padding.PaddingLeft = UDim.new(0, 10)
      padding.PaddingRight = UDim.new(0, 10)
      padding.PaddingTop = UDim.new(0, 7)
      padding.PaddingBottom = UDim.new(0, 8)
      local layout = Instance.new("UIListLayout", container)
      layout.Padding = UDim.new(0, 4)
      local title = Instance.new("TextLabel", container)
      title.Size = UDim2.new(1, 0, 0, 15)
      title.BackgroundTransparency = 1
      title.Font = Enum.Font.Gotham
      title.TextSize = 14
      title.TextColor3 = Theme.Text
      title.TextXAlignment = Enum.TextXAlignment.Left
      local list = Instance.new("Frame", container)
      list.Size = UDim2.new(1, 0, 0, 0)
      list.AutomaticSize = Enum.AutomaticSize.Y
      list.BackgroundTransparency = 1
      local listLayout = Instance.new("UIListLayout", list)
      listLayout.Padding = UDim.new(0, 3)
      local optionButtons = {}
      local api = {}

      local function countSelected()
        local count = 0
        for _, value in pairs(selectedSet) do if value then count = count + 1 end end
        return count
      end
      local function emit()
        title.Text = name .. " (" .. countSelected() .. ")"
        local copy = {}
        for key, value in pairs(selectedSet) do if value then copy[key] = true end end
        callback(copy)
      end
      local function refresh(newOptions)
        currentOptions = newOptions or {}
        for _, button in pairs(optionButtons) do button:Destroy() end
        table.clear(optionButtons)
        for _, option in ipairs(currentOptions) do
          local button = Instance.new("TextButton", list)
          button.Size = UDim2.new(1, 0, 0, 20)
          button.BackgroundColor3 = Theme.Element
          button.BorderSizePixel = 0
          button.AutoButtonColor = false
          button.Font = Enum.Font.Gotham
          button.TextSize = 14
          button.TextColor3 = Theme.Text
          button.TextXAlignment = Enum.TextXAlignment.Left
          button.Text = selectedSet[option] and "  [x] " .. option or "  [ ] " .. option
          button.MouseButton1Click:Connect(function()
            selectedSet[option] = not selectedSet[option] or nil
            button.Text = selectedSet[option] and "  [x] " .. option or "  [ ] " .. option
            emit()
          end)
          table.insert(optionButtons, button)
        end
        title.Text = name .. " (" .. countSelected() .. ")"
      end
      function api.Refresh(newOptions) refresh(newOptions) end
      function api.Set(newSelected)
        table.clear(selectedSet)
        for key, value in pairs(newSelected or {}) do
          if value then selectedSet[key] = true end
        end
        refresh(currentOptions)
      end
      function api.SelectAll()
        for _, option in ipairs(currentOptions) do selectedSet[option] = true end
        refresh(currentOptions)
        emit()
      end
      function api.Clear()
        table.clear(selectedSet)
        refresh(currentOptions)
        emit()
      end
      refresh(options)
      return api
    end

    local function addControlGroup(parent, name)
      local section = getSection(parent, name)
      featureForContainer[section.Content] = name
      return section.Content
    end

    -- Rost-style player/NPC ESP plus an independent world-resource overlay.
    -- Resource entries are rendered only here: collectTargets/selectTarget and
    -- Projectile.New never consume this list.
    do
      local espDefaults = {
        BoxType = "Normal",
        TeamCheck = false,
        BoxFillTransparency = 0.7,
        FillColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        DistanceColor = Color3.fromRGB(255, 255, 255),
        Weapon = false,
        WeaponColor = Color3.fromRGB(255, 255, 255),
        Tracers = cfg.ESP.Tracer == true,
        TracerOrigin = "Bottom",
        TracerColor = Color3.fromRGB(255, 255, 255),
        HealthBarSide = "Side",
        HealthNumber = false,
        HealthDynamicColor = false,
        HealthColor = Color3.fromRGB(80, 220, 100),
        Chams = false,
        ChamsFillColor = Color3.fromRGB(255, 70, 70),
        ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
        ChamsFillTransparency = 0.5,
        ChamsOutlineTransparency = 0.2,
        Fade = false,
        VisibleOnly = false,
        VisibleColors = false,
        BoxThickness = 1,
        TracerThickness = 1,
        TextScale = 1,
      }
      for key, value in pairs(espDefaults) do
        if cfg.ESP[key] == nil then cfg.ESP[key] = value end
      end

      cfg.ResourceESP = cfg.ResourceESP or {}
      local resourceDefaults = {
        Enabled = false,
        MaxDistance = 1500,
        ScanInterval = 1,
        MaxTargets = 128,
        Boxes = false,
        Names = false,
        Distance = false,
        Cloth = false,
        Iron = false,
        Sulfur = false,
        Stone = false,
        BodyBag = false,
        ClothColor = Color3.fromRGB(235, 220, 180),
        IronColor = Color3.fromRGB(170, 190, 210),
        SulfurColor = Color3.fromRGB(240, 210, 60),
        StoneColor = Color3.fromRGB(155, 155, 155),
        BodyBagColor = Color3.fromRGB(255, 101, 40),
      }
      for key, value in pairs(resourceDefaults) do
        if cfg.ResourceESP[key] == nil then cfg.ResourceESP[key] = value end
      end
      -- Optional workload reduction; user sliders and saved values stay intact.
      cfg.Misc.LowPC = cfg.Misc.LowPC == true

      local resourceLabels = {
        Cloth = "Cloth", Iron = "Iron", Sulfur = "Sulfur", Stone = "Stone", BodyBag = "Body Bag",
      }
      local resourceAliases = {
        cloth = "Cloth",
        iron = "Iron",
        sulfur = "Sulfur",
        sulphur = "Sulfur",
        brimstone = "Sulfur",
        stone = "Stone",
        backpack = "BodyBag",
        bodybag = "BodyBag",
      }
      local resourceAffixes = { "ore", "node", "deposit", "rock", "resource", "pickup", "bundle", "plant" }
      local hpLow = Color3.fromRGB(255, 60, 60)
      local hpMedium = Color3.fromRGB(255, 193, 0)
      local hpHigh = Color3.fromRGB(80, 220, 100)
      local hpBackground = Color3.new(0, 0, 0)
      local occludedColor = Color3.fromRGB(255, 70, 70)
      -- Target tables are rebuilt on ordinary rescans; key visibility by Model
      -- so the 0.2 s raycast cache survives those allocations.
      local espVisibilityCache = setmetatable({}, { __mode = "k" })
      local drawingEsp = Drawing ~= nil and type(Drawing.new) == "function"
      if drawingEsp then
        mainGame.espRenderer = "BurmaldaDrawing"
        local legacyCreateBoxDrawing = createBoxDrawing
        local legacyCreateTextDrawing = createTextDrawing
        local function ownDrawing(className)
          local ok, object = pcall(Drawing.new, className)
          if not ok or not object then return nil end
          mainGame.draws[#mainGame.draws + 1] = object
          return object
        end
        createBoxDrawing = function(filled, thickness, color, transparency)
          local object = ownDrawing("Square")
          if not object then
            return legacyCreateBoxDrawing(filled, thickness, color, transparency)
          end
          object.Visible = false
          object.Filled = filled == true
          object.Thickness = thickness or 1
          object.Color = color or Color3.new(1, 1, 1)
          object.Transparency = transparency == nil and 1 or transparency
          object.Position = Vector2.new(0, 0)
          object.Size = Vector2.new(0, 0)
          return object
        end
        createTextDrawing = function(size, centered)
          local object = ownDrawing("Text")
          if not object then return legacyCreateTextDrawing(size, centered) end
          object.Visible = false
          object.Size = size or 13
          object.Center = centered ~= false
          object.Outline = true
          object.Color = Color3.new(1, 1, 1)
          object.Transparency = 1
          object.Position = Vector2.new(0, 0)
          object.Text = ""
          return object
        end
        createEspEntry = function()
          return {
            box = createBoxDrawing(false, 1, Color3.new(1, 1, 1), 1),
            outline = createBoxDrawing(false, 3, Color3.new(0, 0, 0), 1),
            fill = createBoxDrawing(true, 1, Color3.new(1, 1, 1), 0.15),
            name = createTextDrawing(13, true),
            hpBg = createBoxDrawing(true, 1, Color3.new(0, 0, 0), 0.6),
            hpFill = createBoxDrawing(true, 1, Color3.new(0, 1, 0), 1),
            dist = createTextDrawing(12, true),
            s = {},
          }
        end
        updateBoxDrawing = function(entry, key, object, visible, x, y, width, height, color)
          local state = entry.s[key]
          if not state then state = {}; entry.s[key] = state end
          if not object then return end
          if state.v ~= visible then state.v = visible; object.Visible = visible end
          if not visible then return end
          if state.bx ~= x or state.by ~= y or state.w ~= width or state.h ~= height then
            state.bx, state.by, state.w, state.h = x, y, width, height
            object.Position = Vector2.new(x, y)
            object.Size = Vector2.new(width, height)
          end
          if color ~= nil and state.col ~= color then state.col = color; object.Color = color end
        end
        updateTextDrawing = function(entry, key, object, visible, x, y, text, color)
          local state = entry.s[key]
          if not state then state = {}; entry.s[key] = state end
          if not object then return end
          if state.v ~= visible then state.v = visible; object.Visible = visible end
          if not visible then return end
          if state.bx ~= x or state.by ~= y then
            state.bx, state.by = x, y
            object.Position = Vector2.new(x, y)
          end
          if state.t ~= text then state.t = text; object.Text = text end
          if color ~= nil and state.col ~= color then state.col = color; object.Color = color end
        end
        hideEspEntry = function(entry)
          for _, key in ipairs({"box", "outline", "fill", "hpBg", "hpFill"}) do
            updateBoxDrawing(entry, key, entry[key], false)
          end
          updateTextDrawing(entry, "name", entry.name, false)
          updateTextDrawing(entry, "dist", entry.dist, false)
        end
      end

      local function classifyResourceName(value)
        if type(value) ~= "string" then return nil end
        local compact = string.lower(value):gsub("[^%w]", ""):gsub("%d+$", "")
        local direct = resourceAliases[compact]
        if direct then return direct end
        local hasAlias = false
        for alias in pairs(resourceAliases) do
          if string.find(compact, alias, 1, true) then
            hasAlias = true
            break
          end
        end
        if not hasAlias then return nil end
        for alias, kind in pairs(resourceAliases) do
          if compact == alias .. "s" then return kind end
          for _, affix in ipairs(resourceAffixes) do
            if compact == alias .. affix or compact == affix .. alias
              or compact == alias .. affix .. "s" or compact == affix .. alias .. "s" then
              return kind
            end
          end
        end
        return nil
      end

      local function getResourceKind(instance)
        local kind = classifyResourceName(instance.Name)
        if kind then return kind end
        if instance:IsA("Model") and instance.GetAttribute then
          local ok, value = pcall(function()
            return instance:GetAttribute("ResourceType") or instance:GetAttribute("Resource")
          end)
          if ok then return classifyResourceName(value) end
        end
        return nil
      end

      local function getResourceRoot(instance, kind)
        if instance:IsA("Model") then return instance end
        local ancestor = instance.Parent
        while ancestor and ancestor ~= workspace do
          if ancestor:IsA("Model") and getResourceKind(ancestor) == kind then
            return ancestor
          end
          ancestor = ancestor.Parent
        end
        return instance
      end

      local function collectResources()
        local result, seen = {}, {}
        local playersFolder = workspace:FindFirstChild("Players")
        local aiFolder = workspace:FindFirstChild("AI")
        local descendants = {}
        local resourcesFolder = workspace:FindFirstChild("Resources")
        local clothPlantsFolder = workspace:FindFirstChild("ClothPlants")
        local droppedPacksFolder = workspace:FindFirstChild("DroppedPacks")
        if resourcesFolder and clothPlantsFolder then
          -- Confirmed static reference layout: keep the hot scan limited to the
          -- world-resource containers instead of walking the whole map.
          local containers = { resourcesFolder, clothPlantsFolder }
          if droppedPacksFolder then containers[#containers + 1] = droppedPacksFolder end
          for _, container in ipairs(containers) do
            for _, instance in ipairs(container:GetDescendants()) do
              descendants[#descendants + 1] = instance
            end
          end
        else
          -- Offline/legacy fallback for maps without the reference containers.
          descendants = workspace:GetDescendants()
        end
        for _, instance in ipairs(descendants) do
          if instance:IsA("Model") or instance:IsA("BasePart") then
            local kind = getResourceKind(instance)
            if kind then
              local root = getResourceRoot(instance, kind)
              local excluded = root == localPlayer.Character
                or playersFolder and root:IsDescendantOf(playersFolder)
                or aiFolder and root:IsDescendantOf(aiFolder)
              if root.Parent and not excluded and not seen[root] then
                seen[root] = true
                result[#result + 1] = { root = root, kind = kind, name = resourceLabels[kind] }
              end
            end
          end
        end
        return result
      end

      local function getCachedResources()
        local now = os.clock()
        if mainGame.resourceList and now < (mainGame.nextResourceScan or 0) then
          return mainGame.resourceList
        end
        local scanInterval = math.max(0.1, tonumber(cfg.ResourceESP.ScanInterval) or 1)
        if cfg.Misc.LowPC then scanInterval = math.max(scanInterval, 2) end
        mainGame.nextResourceScan = now + scanInterval
        mainGame.resourceList = collectResources()
        return mainGame.resourceList
      end

      mainGame.getCachedResources = getCachedResources

      local function getResourceGeometry(object)
        if object:IsA("BasePart") then
          return object.Position, object.Size or Vector3.new(2, 2, 2)
        end
        local ok, pivot, size = pcall(function() return object:GetBoundingBox() end)
        if ok and pivot and size then return pivot.Position, size end
        local pivotOk, pivotOnly = pcall(function() return object:GetPivot() end)
        if pivotOk and pivotOnly then return pivotOnly.Position, Vector3.new(2, 2, 2) end
        local part = object:FindFirstChildWhichIsA("BasePart")
        if part then return part.Position, part.Size or Vector3.new(2, 2, 2) end
        return nil, nil
      end

      local function getWorldmodelHash(model)
        local values = {}
        local hasNestedModel = model:FindFirstChildOfClass("Model") ~= nil
        for _, child in ipairs(model:GetChildren()) do
          if hasNestedModel then
            local sum = 0
            for _, byte in ipairs({ string.byte(child.Name, 1, -1) }) do sum = sum + byte end
            values[#values + 1] = sum
          end
          if child.ClassName == "MeshPart" then
            local assetId = tonumber(string.sub(child.MeshId or "", 14, -1))
            if assetId then values[#values + 1] = assetId end
          end
        end
        if #values == 0 then return nil end
        table.sort(values)
        return table.concat(values, "")
      end

      local function rebuildWeaponCatalog()
        local catalog = {}
        local assets = replicatedStorage:FindFirstChild("Assets")
        local prefabs = assets and assets:FindFirstChild("Prefabs")
        if prefabs then
          local projectiles = prefabs:FindFirstChild("Projectiles")
          if projectiles then
            for _, model in ipairs(projectiles:GetChildren()) do
              if model:IsA("Model") and not string.find(model.Name, "Old", 1, true) then
                local hash = getWorldmodelHash(model)
                if hash then catalog[hash] = model.Name end
              end
            end
          end
          local tools = prefabs:FindFirstChild("Tools")
          if tools then
            for _, tool in ipairs(tools:GetChildren()) do
              if not string.find(tool.Name, "ADMIN", 1, true) then
                local worldmodel = tool:FindFirstChild("Worldmodel")
                local hash = worldmodel and getWorldmodelHash(worldmodel)
                if hash then catalog[hash] = tool.Name end
              end
            end
          end
        end
        mainGame.weaponCatalog = catalog
        mainGame.weaponCatalogReady = prefabs ~= nil
        mainGame.nextWeaponCatalogScan = os.clock() + 5
      end

      local function resolveWeaponName(character)
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool then return tool.Name end
        local worldmodel = character and character:FindFirstChild("Worldmodel", true)
        if not worldmodel then return "Unarmed" end
        mainGame.weaponNameCache = mainGame.weaponNameCache or {}
        local cached = mainGame.weaponNameCache[worldmodel]
        if cached then return cached end
        if not mainGame.weaponCatalog or os.clock() >= (mainGame.nextWeaponCatalogScan or 0) then
          rebuildWeaponCatalog()
        end
        local hash = getWorldmodelHash(worldmodel)
        local weaponName = hash and mainGame.weaponCatalog and mainGame.weaponCatalog[hash]
        if weaponName then
          mainGame.weaponNameCache[worldmodel] = weaponName
          return weaponName
        end
        return "Unarmed"
      end

      local drawingLines = setmetatable({}, { __mode = "k" })
      local function createLine(color, thickness)
        if drawingEsp then
          local ok, line = pcall(Drawing.new, "Line")
          if ok and line then
            line.Visible = false
            line.Color = color
            line.Thickness = thickness or 1
            line.Transparency = 1
            line.From = Vector2.new(0, 0)
            line.To = Vector2.new(0, 0)
            mainGame.draws[#mainGame.draws + 1] = line
            drawingLines[line] = true
            return line
          end
        end
        local line = Instance.new("Frame")
        line.Name = "BurmaldaESPLine"
        line.BorderSizePixel = 0
        line.BackgroundColor3 = color
        line.BackgroundTransparency = 0
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Visible = false
        line.ZIndex = 1
        line.Parent = getEspGui()
        mainGame.draws[#mainGame.draws + 1] = line
        return line
      end

      local function updateLine(entry, key, line, visible, from, to, color, thickness)
        local state = entry.s[key]
        if not state then state = {}; entry.s[key] = state end
        if state.visible ~= visible then state.visible = visible; line.Visible = visible end
        if not visible then return end
        if drawingLines[line] then
          if state.from ~= from or state.to ~= to then
            state.from, state.to = from, to
            line.From = from
            line.To = to
          end
          if state.color ~= color then state.color = color; line.Color = color end
          if state.thickness ~= thickness then state.thickness = thickness; line.Thickness = thickness end
          return
        end
        local dx, dy = to.X - from.X, to.Y - from.Y
        local length = math.sqrt(dx * dx + dy * dy)
        local mx, my = (from.X + to.X) * 0.5, (from.Y + to.Y) * 0.5
        local rotation = math.deg(math.atan2(dy, dx))
        if state.mx ~= mx or state.my ~= my or state.length ~= length
          or state.rotation ~= rotation or state.thickness ~= thickness then
          state.mx, state.my, state.length = mx, my, length
          state.rotation, state.thickness = rotation, thickness
          line.Position = UDim2.fromOffset(mx, my)
          line.Size = UDim2.fromOffset(math.max(length, 0.1), thickness)
          line.Rotation = rotation
        end
        if state.color ~= color then state.color = color; line.BackgroundColor3 = color end
      end

      local function createCharacterEspEntry()
        local entry = createEspEntry()
        entry.corners = {}
        for index = 1, 8 do
          entry.corners[index] = createBoxDrawing(true, 1, Color3.new(1, 1, 1), 1)
        end
        entry.tracer = createLine(Color3.new(1, 1, 1), 1)
        entry.weapon = createTextDrawing(12, true)
        entry.hpText = createTextDrawing(11, true)
        entry.chams = nil
        entry.chamsFailed = false
        return entry
      end

      local function createResourceEspEntry()
        return {
          box = createBoxDrawing(false, 1, Color3.new(1, 1, 1), 1),
          outline = createBoxDrawing(false, 3, Color3.new(0, 0, 0), 1),
          name = createTextDrawing(12, true),
          dist = createTextDrawing(11, true),
          s = {},
        }
      end

      local function ensureCharacterPool(count)
        mainGame.pool = mainGame.pool or {}
        while #mainGame.pool < count do
          mainGame.pool[#mainGame.pool + 1] = createCharacterEspEntry()
        end
      end

      local function ensureResourcePool(count)
        mainGame.resourcePool = mainGame.resourcePool or {}
        while #mainGame.resourcePool < count do
          mainGame.resourcePool[#mainGame.resourcePool + 1] = createResourceEspEntry()
        end
      end

      local function hideCorners(entry)
        for index = 1, 8 do
          updateBoxDrawing(entry, "corner" .. index, entry.corners[index], false)
        end
      end

      local function updateChams(entry, enabled, model)
        local state = entry.chamsState
        if not enabled then
          if entry.chams and (not state or state.enabled ~= false) then
            pcall(function() entry.chams.Enabled = false end)
          end
          if state then state.enabled = false end
          return
        end
        if not entry.chams and not entry.chamsFailed then
          local ok, highlight = pcall(Instance.new, "Highlight")
          if not ok or not highlight then
            entry.chamsFailed = true
            return
          end
          highlight.Name = "BurmaldaHookESP"
          highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
          entry.chams = highlight
          mainGame.draws[#mainGame.draws + 1] = highlight
        end
        if entry.chams then
          state = state or {}
          entry.chamsState = state
          pcall(function()
            local highlight = entry.chams
            if state.adornee ~= model then state.adornee = model; highlight.Adornee = model end
            if state.fillColor ~= cfg.ESP.ChamsFillColor then
              state.fillColor = cfg.ESP.ChamsFillColor
              highlight.FillColor = cfg.ESP.ChamsFillColor
            end
            if state.outlineColor ~= cfg.ESP.ChamsOutlineColor then
              state.outlineColor = cfg.ESP.ChamsOutlineColor
              highlight.OutlineColor = cfg.ESP.ChamsOutlineColor
            end
            if state.fillTransparency ~= cfg.ESP.ChamsFillTransparency then
              state.fillTransparency = cfg.ESP.ChamsFillTransparency
              highlight.FillTransparency = cfg.ESP.ChamsFillTransparency
            end
            if state.outlineTransparency ~= cfg.ESP.ChamsOutlineTransparency then
              state.outlineTransparency = cfg.ESP.ChamsOutlineTransparency
              highlight.OutlineTransparency = cfg.ESP.ChamsOutlineTransparency
            end
            if highlight.Parent ~= coreGui then highlight.Parent = coreGui end
            if state.enabled ~= true then state.enabled = true; highlight.Enabled = true end
          end)
        end
      end

      local function hideCharacterEspEntry(entry)
        if entry.s.characterHidden then return end
        entry.s.characterHidden = true
        hideEspEntry(entry)
        hideCorners(entry)
        updateLine(entry, "tracer", entry.tracer, false)
        updateTextDrawing(entry, "weapon", entry.weapon, false)
        updateTextDrawing(entry, "hpText", entry.hpText, false)
        updateChams(entry, false)
      end

      local function hideResourceEspEntry(entry)
        if entry.s.resourceHidden then return end
        entry.s.resourceHidden = true
        updateBoxDrawing(entry, "box", entry.box, false)
        updateBoxDrawing(entry, "outline", entry.outline, false)
        updateTextDrawing(entry, "name", entry.name, false)
        updateTextDrawing(entry, "dist", entry.dist, false)
      end

      local function setCornerBox(entry, x, y, width, height, color)
        local armX = math.max(3, math.min(12, width * 0.35))
        local armY = math.max(3, math.min(12, height * 0.35))
        local right, bottom = x + width - 1, y + height - 1
        updateBoxDrawing(entry, "corner1", entry.corners[1], true, x, y, armX, 1, color)
        updateBoxDrawing(entry, "corner2", entry.corners[2], true, x, y, 1, armY, color)
        updateBoxDrawing(entry, "corner3", entry.corners[3], true, x + width - armX, y, armX, 1, color)
        updateBoxDrawing(entry, "corner4", entry.corners[4], true, right, y, 1, armY, color)
        updateBoxDrawing(entry, "corner5", entry.corners[5], true, x, bottom, armX, 1, color)
        updateBoxDrawing(entry, "corner6", entry.corners[6], true, x, y + height - armY, 1, armY, color)
        updateBoxDrawing(entry, "corner7", entry.corners[7], true, x + width - armX, bottom, armX, 1, color)
        updateBoxDrawing(entry, "corner8", entry.corners[8], true, right, y + height - armY, 1, armY, color)
      end

      local function getHealthColor(ratio)
        if not cfg.ESP.HealthDynamicColor then return cfg.ESP.HealthColor end
        if ratio < 0.5 then return hpLow:Lerp(hpMedium, ratio * 2) end
        return hpMedium:Lerp(hpHigh, (ratio - 0.5) * 2)
      end

      local function updateFill(entry, visible, x, y, width, height)
        updateBoxDrawing(entry, "fill", entry.fill, visible, x, y, width, height, cfg.ESP.FillColor)
        if visible then
          local opacity = 1 - math.clamp(cfg.ESP.BoxFillTransparency, 0, 1)
          local state = entry.s.fill
          if state.opacity ~= opacity then
            state.opacity = opacity
            entry.fill.Transparency = opacity
          end
        end
      end

      local function applyAdvancedEntry(entry, distance)
        local advanced = entry.s.advanced
        if not advanced then advanced = {}; entry.s.advanced = advanced end
        local alpha = cfg.ESP.Fade
          and math.clamp(1 - distance / math.max(1, cfg.ESP.MaxDistance), 0.15, 1) or 1
        if advanced.alpha ~= alpha then
          advanced.alpha = alpha
          for _, key in ipairs({"box", "outline", "name", "dist", "weapon", "hpText", "hpFill", "tracer"}) do
            local object = entry[key]
            if object then pcall(function() object.Transparency = alpha end) end
          end
          for _, object in ipairs(entry.corners or {}) do
            pcall(function() object.Transparency = alpha end)
          end
          if entry.hpBg then pcall(function() entry.hpBg.Transparency = alpha * 0.6 end) end
        end
        local fillAlpha = alpha * (1 - math.clamp(cfg.ESP.BoxFillTransparency, 0, 1))
        if entry.fill and advanced.fillAlpha ~= fillAlpha then
          advanced.fillAlpha = fillAlpha
          pcall(function() entry.fill.Transparency = fillAlpha end)
        end
        local scale = tonumber(cfg.ESP.TextScale) or 1
        if advanced.scale ~= scale then
          advanced.scale = scale
          for key, size in pairs({name = 13, dist = 12, weapon = 12, hpText = 11}) do
            local object = entry[key]
            if object then pcall(function() object.Size = size * scale end) end
          end
        end
        local thickness = tonumber(cfg.ESP.BoxThickness) or 1
        if advanced.boxThickness ~= thickness then
          advanced.boxThickness = thickness
          if entry.box then pcall(function() entry.box.Thickness = thickness end) end
          if entry.outline then pcall(function() entry.outline.Thickness = thickness + 2 end) end
          for _, object in ipairs(entry.corners or {}) do
            pcall(function() object.Thickness = thickness end)
          end
        end
      end

      local function renderResourceEntries(camera, cameraPosition)
        if not cfg.ResourceESP.Enabled and not mainGame.resourceEspRendered then
          mainGame.stats.espResources = 0
          return
        end
        mainGame.resourceEspRendered = cfg.ResourceESP.Enabled
        local visibleResources = {}
        local resourceLimit = cfg.ResourceESP.MaxTargets or 128
        if cfg.Misc.LowPC then resourceLimit = math.min(resourceLimit, 48) end
        if cfg.ResourceESP.Enabled then
          local resources = getCachedResources()
          for _, resource in ipairs(resources) do
            if cfg.ResourceESP[resource.kind] and resource.root.Parent then
              local position, size = getResourceGeometry(resource.root)
              if position and (position - cameraPosition).Magnitude <= cfg.ResourceESP.MaxDistance then
                visibleResources[#visibleResources + 1] = {
                  root = resource.root,
                  kind = resource.kind,
                  name = resource.name,
                  position = position,
                  size = size,
                }
                if #visibleResources >= resourceLimit then break end
              end
            end
          end
        end

        mainGame.stats.espResources = #visibleResources
        ensureResourcePool(#visibleResources)
        local previousUsed = mainGame.resourcePoolUsed or 0
        for index = 1, math.max(#visibleResources, previousUsed) do
          local entry = mainGame.resourcePool[index]
          local resource = visibleResources[index]
          if not resource then
            hideResourceEspEntry(entry)
          else
            local halfHeight = math.max((resource.size and resource.size.Y or 2) * 0.5, 0.5)
            local top = camera:WorldToViewportPoint(resource.position + Vector3.new(0, halfHeight, 0))
            local bottom = camera:WorldToViewportPoint(resource.position - Vector3.new(0, halfHeight, 0))
            if top.Z > 0 and bottom.Z > 0 then
              entry.s.resourceHidden = false
              local yTop, yBottom = math.min(top.Y, bottom.Y), math.max(top.Y, bottom.Y)
              local height = math.max(yBottom - yTop, 6)
              local width = math.max(height * 0.75, 8)
              local centerX = (top.X + bottom.X) * 0.5
              local x = centerX - width * 0.5
              local color = cfg.ResourceESP[resource.kind .. "Color"]
              updateBoxDrawing(entry, "outline", entry.outline, cfg.ResourceESP.Boxes,
                x, yTop, width, height)
              updateBoxDrawing(entry, "box", entry.box, cfg.ResourceESP.Boxes,
                x, yTop, width, height, color)
              updateTextDrawing(entry, "name", entry.name, cfg.ResourceESP.Names,
                centerX, yTop - 14, resource.name, color)
              updateTextDrawing(entry, "dist", entry.dist, cfg.ResourceESP.Distance,
                centerX, yTop + height + 3, string.format("%d m", math.floor(
                  (resource.position - cameraPosition).Magnitude + 0.5)), color)
            else
              hideResourceEspEntry(entry)
            end
          end
        end
        mainGame.resourcePoolUsed = #visibleResources
      end

      renderEsp = function()
        mainGame.stats.frames = mainGame.stats.frames + 1
        local camera = workspace.CurrentCamera
        if not camera then return end
        local cameraPosition = camera.CFrame.Position
        local targets = cfg.ESP.Enabled and getCachedTargets() or {}
        local visibleTargets = {}
        local playerLimit = cfg.ESP.MaxTargets or 64
        if cfg.Misc.LowPC then playerLimit = math.min(playerLimit, 24) end

        if cfg.ESP.Enabled then
          for _, target in ipairs(targets) do
            local categoryEnabled = target.player and cfg.ESP.Players or not target.player and cfg.ESP.NPCs
            local teamDot = target.player and cfg.ESP.TeamCheck
              and target.model:FindFirstChild("TeamDot")
            local teamExcluded = target.player and cfg.ESP.TeamCheck and teamDot and teamDot.Enabled
            local head = target.head
            local espVisible = true
            if head and head.Parent and (cfg.ESP.VisibleOnly or cfg.ESP.VisibleColors) then
              local now = os.clock()
              local cached = espVisibilityCache[target.model]
              if not cached or cached.part ~= head or now >= cached.next then
                cached = {
                  part = head,
                  visible = isTargetVisible(cameraPosition, head),
                  next = now + (cfg.Misc.LowPC and 0.4 or 0.2),
                }
                espVisibilityCache[target.model] = cached
              end
              espVisible = cached.visible ~= false
            end
            target.espVisible = espVisible
            if categoryEnabled and not teamExcluded and head and head.Parent and target.hum and target.hum.Parent
              and target.hum.Health > 0 and (not cfg.ESP.VisibleOnly or espVisible)
              and (head.Position - cameraPosition).Magnitude <= cfg.ESP.MaxDistance then
              visibleTargets[#visibleTargets + 1] = target
              if #visibleTargets >= playerLimit then break end
            end
          end
        end

        mainGame.stats.espPlayers = 0
        mainGame.stats.espNPCs = 0
        mainGame.stats.targets = #visibleTargets
        local playerPoolLimit = 0
        if cfg.ESP.Enabled or mainGame.playerEspRendered then
          ensureCharacterPool(#visibleTargets)
          playerPoolLimit = math.max(#visibleTargets, mainGame.playerPoolUsed or 0)
        end

        for index = 1, playerPoolLimit do
          local entry = mainGame.pool[index]
          local target = visibleTargets[index]
          if not target then
            hideCharacterEspEntry(entry)
          else
            if target.player then
              mainGame.stats.espPlayers = mainGame.stats.espPlayers + 1
            else
              mainGame.stats.espNPCs = mainGame.stats.espNPCs + 1
            end

            local head, root = target.head, target.hrp
            local topPosition = head.Position + Vector3.new(0, head.Size.Y * 0.5, 0)
            local bottomPosition = root and root.Position - Vector3.new(0, 3, 0)
              or head.Position - Vector3.new(0, 3, 0)
            local top, topOnScreen = camera:WorldToViewportPoint(topPosition)
            local bottom, bottomOnScreen = camera:WorldToViewportPoint(bottomPosition)
            if topOnScreen and bottomOnScreen and top.Z > 0 and bottom.Z > 0 then
              entry.s.characterHidden = false
              local yTop, yBottom = math.min(top.Y, bottom.Y), math.max(top.Y, bottom.Y)
              local height = math.max(yBottom - yTop, 4)
              local width = height * 0.6
              local centerX = (top.X + bottom.X) * 0.5
              local x = centerX - width * 0.5
              local boxColor = target.player and cfg.ESP.PlayerColor or cfg.ESP.NPCColor
              if cfg.ESP.VisibleColors then
                boxColor = target.espVisible == false and occludedColor or hpHigh
              end
              local cornerStyle = cfg.ESP.BoxType == "Corner"
              local normalBox = cfg.ESP.Box and not cornerStyle
              local cornerBox = cfg.ESP.Box and cornerStyle

              updateBoxDrawing(entry, "outline", entry.outline, normalBox, x, yTop, width, height)
              updateBoxDrawing(entry, "box", entry.box, normalBox, x, yTop, width, height, boxColor)
              if cornerBox then setCornerBox(entry, x, yTop, width, height, boxColor) else hideCorners(entry) end
              updateFill(entry, cfg.ESP.BoxFill, x, yTop, width, height)

              local viewport = camera.ViewportSize
              local originY = viewport.Y * 0.5
              if cfg.ESP.TracerOrigin == "Top" then originY = 0
              elseif cfg.ESP.TracerOrigin == "Bottom" then originY = viewport.Y end
              updateLine(entry, "tracer", entry.tracer, cfg.ESP.Tracers,
                Vector2.new(viewport.X * 0.5, originY), Vector2.new(centerX, (yTop + yBottom) * 0.5),
                cfg.ESP.TracerColor, cfg.ESP.TracerThickness or 1)

              local topHealth = cfg.ESP.Health and cfg.ESP.HealthBarSide == "Top"
              updateTextDrawing(entry, "name", entry.name, cfg.ESP.Name, centerX,
                yTop - (topHealth and 25 or 16), target.name, cfg.ESP.NameColor)

              local distanceText = cfg.ESP.Distance and string.format("%d m", math.floor(
                (head.Position - cameraPosition).Magnitude + 0.5)) or ""
              updateTextDrawing(entry, "dist", entry.dist, cfg.ESP.Distance, centerX,
                yTop + height + 3, distanceText, cfg.ESP.DistanceColor)

              local weaponName = cfg.ESP.Weapon and resolveWeaponName(target.model) or ""
              updateTextDrawing(entry, "weapon", entry.weapon, cfg.ESP.Weapon, centerX,
                yTop + height + (cfg.ESP.Distance and 18 or 3), weaponName, cfg.ESP.WeaponColor)

              if cfg.ESP.Health and target.hum then
                local ratio = target.hum.MaxHealth > 0
                  and math.clamp(target.hum.Health / target.hum.MaxHealth, 0, 1) or 0
                local healthColor = getHealthColor(ratio)
                if cfg.ESP.HealthBarSide == "Top" then
                  updateBoxDrawing(entry, "hpBg", entry.hpBg, true, x, yTop - 6, width, 3,
                    hpBackground)
                  updateBoxDrawing(entry, "hpFill", entry.hpFill, true, x, yTop - 6,
                    width * ratio, 3, healthColor)
                  updateTextDrawing(entry, "hpText", entry.hpText, cfg.ESP.HealthNumber,
                    x + width * ratio, yTop - 20, tostring(math.floor(target.hum.Health + 0.5)), healthColor)
                else
                  updateBoxDrawing(entry, "hpBg", entry.hpBg, true, x - 6, yTop, 3, height,
                    hpBackground)
                  updateBoxDrawing(entry, "hpFill", entry.hpFill, true, x - 6,
                    yTop + height * (1 - ratio), 3, height * ratio, healthColor)
                  updateTextDrawing(entry, "hpText", entry.hpText, cfg.ESP.HealthNumber,
                    x - 12, yTop + height * (1 - ratio) - 5,
                    tostring(math.floor(target.hum.Health + 0.5)), healthColor)
                end
              else
                updateBoxDrawing(entry, "hpBg", entry.hpBg, false)
                updateBoxDrawing(entry, "hpFill", entry.hpFill, false)
                updateTextDrawing(entry, "hpText", entry.hpText, false)
              end

              applyAdvancedEntry(entry, (head.Position - cameraPosition).Magnitude)
              updateChams(entry, cfg.ESP.Chams, target.model)
            else
              hideCharacterEspEntry(entry)
            end
          end
        end
        mainGame.playerPoolUsed = #visibleTargets
        mainGame.playerEspRendered = cfg.ESP.Enabled and (cfg.ESP.Players or cfg.ESP.NPCs)

        renderResourceEntries(camera, cameraPosition)
      end

      mainGame.resourcePool = {}
      mainGame.resourcePoolUsed = 0
      mainGame.playerPoolUsed = 0
      mainGame.playerEspRendered = false
      mainGame.resourceEspRendered = false
      mainGame.resourceList = nil
      mainGame.nextResourceScan = 0
      mainGame.weaponCatalog = nil
      mainGame.weaponNameCache = {}
      mainGame.nextWeaponCatalogScan = 0
      mainGame.stats.espResources = 0
    end


    -- Our local movement package. It is independent from Projectile.New and
    -- keeps per-character baselines so disable/respawn/reinit/Unload can restore.
    cfg.Movement = cfg.Movement or {}
    local movementDefaults = {
      Speed = false,
      SpeedValue = 30,
      SpeedMethod = "WalkSpeed",
      HighJump = false,
      JumpPower = 65,
      Fly = false,
      FlySpeed = 50,
      InfiniteJump = false,
      Freecam = false,
      FreecamSpeed = 50,
      FreecamSensitivity = 0.2,
    }
    for key, value in pairs(movementDefaults) do
      if cfg.Movement[key] == nil then cfg.Movement[key] = value end
    end

    local function updateMovement(dt)
      if mainGame.movement and mainGame.movement.Active then
        local ok, err = pcall(mainGame.movement.Update, dt)
        if not ok then mainGame.movementError = tostring(err) end
      end
    end

    if not mainGame.movement then
      local movement = {
        Active = true,
        char = nil,
        humanoid = nil,
        root = nil,
        speedOriginal = nil,
        jumpOriginal = nil,
        flyOriginal = nil,
        flyBody = nil,
      }
      mainGame.movement = movement

      local function destroyFly()
        if movement.flyBody then
          pcall(function() movement.flyBody:Destroy() end)
          movement.flyBody = nil
        end
      end

      local freecam = { active = false }
      -- Kept only to remove stale bindings from the previous Freecam build.
      local freecamBindingName = "MG_LoneFreecam"
      local freecamActionName = "BurmaldaLoneFreecamMovement"
      local contextActionService = game:GetService("ContextActionService")
      movement.freecam = freecam
      movement.freecamBindingName = freecamBindingName

      local function finiteNumber(value)
        return type(value) == "number" and value == value
          and value ~= math.huge and value ~= -math.huge
      end
      local function validVector(vector)
        return vector and finiteNumber(vector.X) and finiteNumber(vector.Y) and finiteNumber(vector.Z)
      end
      local function restoreFreecamMouse()
        if freecam.originalMouseBehavior ~= nil then
          pcall(function() UIS.MouseBehavior = freecam.originalMouseBehavior end)
        end
        if freecam.originalMouseIcon ~= nil then
          pcall(function() UIS.MouseIconEnabled = freecam.originalMouseIcon end)
        end
      end

      function movement.StopFreecam()
        if not freecam.active then return end
        freecam.active = false
        -- Defensive migration cleanup; this build does not create either binding.
        pcall(function() runService:UnbindFromRenderStep(freecamBindingName) end)
        if contextActionService then
          pcall(function() contextActionService:UnbindAction(freecamActionName) end)
        end
        local currentCamera = workspace.CurrentCamera
        local camera = freecam.camera or currentCamera
        if camera then
          pcall(function() camera.CameraType = freecam.originalCameraType or Enum.CameraType.Custom end)
          if freecam.originalCameraSubject ~= nil then
            pcall(function() camera.CameraSubject = freecam.originalCameraSubject end)
          end
          if camera == currentCamera and freecam.originalCFrame then
            pcall(function() camera.CFrame = freecam.originalCFrame end)
          end
        end
        restoreFreecamMouse()
        freecam.camera = nil
        freecam.originalCameraType = nil
        freecam.originalCameraSubject = nil
        freecam.originalCFrame = nil
        freecam.originalMouseBehavior = nil
        freecam.originalMouseIcon = nil
        freecam.lookX = 0
        freecam.lookY = 0
        freecam.menuOpen = nil
      end

      function movement.UpdateFreecam(dt)
        if not freecam.active then return end
        if not cfg.Movement.Freecam or mainGame.unloaded then
          movement.StopFreecam()
          return
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        if camera ~= freecam.camera then
          movement.StopFreecam()
          movement.SetFreecam(true)
          return
        end
        if camera.CameraType ~= Enum.CameraType.Scriptable then
          camera.CameraType = Enum.CameraType.Scriptable
        end

        local menuIsOpen = menuOpen == true
        if freecam.menuOpen ~= menuIsOpen then
          freecam.menuOpen = menuIsOpen
          freecam.lookX = 0
          freecam.lookY = 0
          pcall(function()
            UIS.MouseBehavior = menuIsOpen and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCurrentPosition
            UIS.MouseIconEnabled = menuIsOpen
          end)
        end
        if not finiteNumber(freecam.yaw) or not finiteNumber(freecam.pitch)
          or not validVector(freecam.position) or not finiteNumber(freecam.lookX or 0)
          or not finiteNumber(freecam.lookY or 0) then
          error("invalid Freecam state", 0)
        end

        local rotation = CFrame.fromEulerAnglesYXZ(freecam.pitch, freecam.yaw, 0)
        if not menuIsOpen then
          -- InputChanged supplies each mouse delta once. Never poll a sticky
          -- GetMouseDelta value and reapply it on every rendered frame.
          local deltaX = math.clamp(freecam.lookX or 0, -500, 500)
          local deltaY = math.clamp(freecam.lookY or 0, -500, 500)
          freecam.lookX = 0
          freecam.lookY = 0
          local sensitivity = math.clamp(tonumber(cfg.Movement.FreecamSensitivity) or 0.2, 0.01, 1) * 0.01
          freecam.yaw = freecam.yaw - deltaX * sensitivity
          freecam.pitch = math.clamp(freecam.pitch - deltaY * sensitivity, -1.45, 1.45)
          rotation = CFrame.fromEulerAnglesYXZ(freecam.pitch, freecam.yaw, 0)

          local direction = Vector3.zero
          if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + Vector3.new(0, 0, -1) end
          if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction + Vector3.new(0, 0, 1) end
          if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction + Vector3.new(-1, 0, 0) end
          if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + Vector3.new(1, 0, 0) end
          if UIS:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
          if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction + Vector3.new(0, -1, 0) end
          if direction.Magnitude > 0 then
            local speed = math.clamp(tonumber(cfg.Movement.FreecamSpeed) or 50, 1, 300)
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 3 end
            local step = math.clamp(tonumber(dt) or 0, 0, 0.05)
            freecam.position = freecam.position + rotation:VectorToWorldSpace(direction.Unit) * speed * step
          end
        end
        if not validVector(freecam.position) or not finiteNumber(freecam.yaw)
          or not finiteNumber(freecam.pitch) then
          error("invalid Freecam transform", 0)
        end
        camera.CFrame = CFrame.new(freecam.position) * rotation
      end

      function movement.StartFreecam()
        if freecam.active then return true end
        local camera = workspace.CurrentCamera
        if not camera then return false end
        local position = camera.CFrame.Position
        local look = camera.CFrame.LookVector
        if not validVector(position) or not validVector(look) then
          error("invalid camera CFrame", 0)
        end
        freecam.camera = camera
        freecam.originalCameraType = camera.CameraType
        freecam.originalCameraSubject = camera.CameraSubject
        freecam.originalCFrame = camera.CFrame
        freecam.originalMouseBehavior = UIS.MouseBehavior
        freecam.originalMouseIcon = UIS.MouseIconEnabled
        freecam.position = position
        freecam.yaw = math.abs(look.X) + math.abs(look.Z) > 1e-6
          and math.atan2(-look.X, -look.Z) or 0
        freecam.pitch = math.asin(math.clamp(look.Y, -1, 1))
        freecam.lookX = 0
        freecam.lookY = 0
        freecam.menuOpen = nil
        freecam.active = true
        camera.CameraType = Enum.CameraType.Scriptable
        return true
      end

      local function disableFreecamWithError(err)
        cfg.Movement.Freecam = false
        pcall(movement.StopFreecam)
        mainGame.movementError = "Freecam disabled: " .. tostring(err)
        if mainGame.Window and not mainGame.Window.Destroyed and featureStates.Freecam then
          pcall(function() mainGame.Window:SetFeature("Freecam", false) end)
        end
        if type(warn) == "function" then pcall(warn, "[MainGame] " .. mainGame.movementError) end
      end

      local function freecamInput(input)
        if not freecam.active or not cfg.Movement.Freecam
          or not movement.Active or mainGame.unloaded then return end
        local ok, err = pcall(function()
          if menuOpen == true or not input
            or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
          local delta = input.Delta
          if delta == nil then return end
          local deltaX = tonumber(delta.X)
          local deltaY = tonumber(delta.Y)
          if not finiteNumber(deltaX) or not finiteNumber(deltaY) then
            error("invalid Freecam mouse delta", 0)
          end
          freecam.lookX = math.clamp((freecam.lookX or 0)
            + math.clamp(deltaX, -500, 500), -500, 500)
          freecam.lookY = math.clamp((freecam.lookY or 0)
            + math.clamp(deltaY, -500, 500), -500, 500)
        end)
        if not ok then disableFreecamWithError(err) end
      end
      movement.FreecamInput = freecamInput
      trackConnection(UIS.InputChanged:Connect(freecamInput))

      local function freecamFrame(dt)
        if not movement.Active or mainGame.unloaded then return end
        if not cfg.Movement.Freecam then
          if freecam.active then movement.StopFreecam() end
          return
        end
        if not freecam.active then
          local ok, started = pcall(movement.StartFreecam)
          if not ok then
            disableFreecamWithError(started)
            return
          end
          if not started then return end
        end
        local ok, err = pcall(movement.UpdateFreecam, dt)
        if not ok then disableFreecamWithError(err) end
      end
      movement.FreecamFrame = freecamFrame

      function movement.SetFreecam(enabled)
        cfg.Movement.Freecam = enabled == true
        if cfg.Movement.Freecam then
          freecamFrame(0)
        else
          movement.StopFreecam()
        end
        return cfg.Movement.Freecam
      end

      trackConnection(runService.RenderStepped:Connect(freecamFrame))

      function movement.Unbind()
        if movement.humanoid then
          if movement.speedOriginal ~= nil then
            pcall(function() movement.humanoid.WalkSpeed = movement.speedOriginal end)
          end
          if movement.jumpOriginal then
            local original = movement.jumpOriginal
            pcall(function()
              if original.UseJumpPower ~= nil then
                movement.humanoid.UseJumpPower = original.UseJumpPower
              end
              if original.JumpPower ~= nil then
                movement.humanoid.JumpPower = original.JumpPower
              end
              if original.JumpHeight ~= nil then
                movement.humanoid.JumpHeight = original.JumpHeight
              end
            end)
          end
          if movement.flyOriginal ~= nil then
            pcall(function() movement.humanoid.PlatformStand = movement.flyOriginal end)
          end
        end
        movement.speedOriginal = nil
        movement.jumpOriginal = nil
        movement.flyOriginal = nil
        destroyFly()
        movement.char = nil
        movement.humanoid = nil
        movement.root = nil
      end

      function movement.Update(dt)
        if not movement.Active or mainGame.unloaded then return end
        local character = localPlayer.Character
        if character ~= movement.char then
          movement.Bind(character)
          return
        end
        if character and (not movement.humanoid or not movement.humanoid.Parent
          or not movement.root or not movement.root.Parent) then
          movement.Bind(character)
          return
        end

        local humanoid = movement.humanoid
        local root = movement.root
        if cfg.Movement.Speed and humanoid and cfg.Movement.SpeedMethod == "CFrame" then
          if movement.speedOriginal ~= nil then
            pcall(function() humanoid.WalkSpeed = movement.speedOriginal end)
            movement.speedOriginal = nil
          end
          if root then
            local direction = humanoid.MoveDirection
            if direction and direction.Magnitude > 0.05 then
              local step = math.clamp(tonumber(dt) or (1 / 60), 0, 0.05)
              root.CFrame = root.CFrame + direction.Unit * cfg.Movement.SpeedValue * step
            end
          end
        elseif cfg.Movement.Speed and humanoid and cfg.Movement.SpeedMethod == "Velocity" then
          if movement.speedOriginal ~= nil then
            pcall(function() humanoid.WalkSpeed = movement.speedOriginal end)
            movement.speedOriginal = nil
          end
          if root then
            local velocity = root.Velocity or root.AssemblyLinearVelocity or Vector3.zero
            local direction = humanoid.MoveDirection
            root.Velocity = Vector3.new(direction.X * cfg.Movement.SpeedValue, velocity.Y,
              direction.Z * cfg.Movement.SpeedValue)
          end
        elseif cfg.Movement.Speed and humanoid then
          if movement.speedOriginal == nil then
            movement.speedOriginal = humanoid.WalkSpeed
          end
          if humanoid.WalkSpeed ~= cfg.Movement.SpeedValue then
            humanoid.WalkSpeed = cfg.Movement.SpeedValue
          end
        elseif movement.speedOriginal ~= nil then
          if humanoid then pcall(function() humanoid.WalkSpeed = movement.speedOriginal end) end
          movement.speedOriginal = nil
        end

        if cfg.Movement.HighJump and humanoid then
          if not movement.jumpOriginal then
            movement.jumpOriginal = {
              UseJumpPower = humanoid.UseJumpPower,
              JumpPower = humanoid.JumpPower,
              JumpHeight = humanoid.JumpHeight,
            }
          end
          humanoid.UseJumpPower = true
          humanoid.JumpPower = cfg.Movement.JumpPower
        elseif movement.jumpOriginal then
          local original = movement.jumpOriginal
          if humanoid then
            pcall(function()
              if original.UseJumpPower ~= nil then humanoid.UseJumpPower = original.UseJumpPower end
              if original.JumpPower ~= nil then humanoid.JumpPower = original.JumpPower end
              if original.JumpHeight ~= nil then humanoid.JumpHeight = original.JumpHeight end
            end)
          end
          movement.jumpOriginal = nil
        end

        if cfg.Movement.Fly and humanoid and root and humanoid.Health > 0 then
          if movement.flyOriginal == nil then
            movement.flyOriginal = humanoid.PlatformStand
          end
          humanoid.PlatformStand = true
          if not movement.flyBody or movement.flyBody.Parent ~= root then
            destroyFly()
            movement.flyBody = Instance.new("BodyVelocity")
            movement.flyBody.Name = "BurmaldaLoneFly"
            movement.flyBody.MaxForce = Vector3.new(1000000, 1000000, 1000000)
            movement.flyBody.Velocity = Vector3.zero
            movement.flyBody.Parent = root
          end
          local direction = Vector3.zero
          local camera = workspace.CurrentCamera
          if camera then
            if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
          end
          if UIS:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
          if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction = direction - Vector3.new(0, 1, 0)
          end
          movement.flyBody.Velocity = direction.Magnitude > 0
            and direction.Unit * cfg.Movement.FlySpeed or Vector3.zero
        else
          if movement.flyOriginal ~= nil then
            if humanoid then pcall(function() humanoid.PlatformStand = movement.flyOriginal end) end
            movement.flyOriginal = nil
          end
          destroyFly()
        end

      end

      function movement.Bind(character)
        movement.Unbind()
        movement.char = character
        if character then
          movement.humanoid = character:FindFirstChildOfClass("Humanoid")
          movement.root = character:FindFirstChild("HumanoidRootPart")
        end
        if movement.humanoid and movement.root then movement.Update() end
      end

      mainGame.movementCleanup = function()
        -- Reinit must preserve the user's enabled setting; Unload clears it later.
        pcall(movement.StopFreecam)
        movement.Active = false
        pcall(movement.Unbind)
        if mainGame.movement == movement then mainGame.movement = nil end
        mainGame.movementCleanup = nil
        local callbacks = mainGame.extendedCleanups or {}
        mainGame.extendedCleanups = {}
        for index = #callbacks, 1, -1 do pcall(callbacks[index]) end
      end

      trackConnection(runService.RenderStepped:Connect(updateMovement))
      trackConnection(UIS.JumpRequest:Connect(function()
        if not cfg.Movement.InfiniteJump or mainGame.unloaded then return end
        local humanoid = movement.humanoid
        if humanoid and humanoid.Health > 0 then
          pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
      end))
      trackConnection(localPlayer.CharacterAdded:Connect(function(character)
        if movement.Active and not mainGame.unloaded then
          local ok, err = pcall(movement.Bind, character)
          if not ok then mainGame.movementError = tostring(err) end
          if cfg.Movement.Freecam then movement.SetFreecam(true) end
        end
      end))
      trackConnection(localPlayer.CharacterRemoving:Connect(function(character)
        if freecam.active then movement.StopFreecam() end
        if movement.char == character then movement.Unbind() end
      end))
      movement.Bind(localPlayer.Character)
      if cfg.Movement.Freecam then movement.SetFreecam(true) end
    end


    -- Amogus feature equivalents implemented against our own lifecycle and UI.
    -- No remote UI/ESP library, HTTP loader or third-party gameplay file is used.
    do
      local silentDefaults = {
        TeamCheck = false,
        IgnoreDowned = false,
        Snapline = false,
        SnaplineColor = Color3.fromRGB(255, 255, 255),
        DynamicFOV = false,
      }
      for key, value in pairs(silentDefaults) do
        if cfg.Silent[key] == nil then cfg.Silent[key] = value end
      end
      for _, key in ipairs({ "ForceHit", "Hitscan", "HitscanDistance", "HitscanIndicator", "HitscanIndicatorColor" }) do
        cfg.Silent[key] = nil
      end
      if cfg.Silent.AimPart == "Torso" then
        cfg.Silent.AimPart = "Body"
      elseif cfg.Silent.AimPart ~= "Body" then
        cfg.Silent.AimPart = "Head"
      end

      cfg.WeaponMods = cfg.WeaponMods or {}
      local weaponDefaults = {
        Recoil = 100,
        Spread = 100,
        FireRate = 1,
        InstantEquip = false,
        ShootSprinting = false,
        ReloadSprinting = false,
        InstantReload = false,
        AutoReload = false,
        FastBow = false,
        InstantEoka = false,
      }
      for key, value in pairs(weaponDefaults) do
        if cfg.WeaponMods[key] == nil then cfg.WeaponMods[key] = value end
      end

      cfg.LocalFeatures = cfg.LocalFeatures or {}
      local localDefaults = {
        InstantLoot = false,
        NoFall = false,
        SilentWalk = false,
        RemoveGrass = false,
        DetectionNotifier = false,
        KeybindList = false,
      }
      for key, value in pairs(localDefaults) do
        if cfg.LocalFeatures[key] == nil then cfg.LocalFeatures[key] = value end
      end
      if cfg.Misc.XRay == nil then cfg.Misc.XRay = false end
      if type(cfg.Misc.XRayTransparency) ~= "number" then
        cfg.Misc.XRayTransparency = 0.5
      else
        cfg.Misc.XRayTransparency = math.clamp(cfg.Misc.XRayTransparency, 0, 0.9)
      end

      cfg.Remote = cfg.Remote or {}
      local remoteDefaults = { BlockChecks = false, BlockProjectile = false, BlockRecoil = false }
      for key, value in pairs(remoteDefaults) do
        if cfg.Remote[key] == nil then cfg.Remote[key] = value end
      end

      local state = {
        Active = true,
        restores = {},
        patchedWeaponModules = {},
        patchedFunctions = {},
        weaponOriginalFire = {},
        weaponRecoilPatches = {},
        weaponSpreadPatches = {},
        recoilPatches = 0,
        spreadPatches = 0,
        nextInstall = 0,
        currentTarget = nil,
        detectionUntil = 0,
      }
      mainGame.amogus = state
      mainGame.extendedCleanups = mainGame.extendedCleanups or {}

      local function addRestore(callback)
        state.restores[#state.restores + 1] = callback
      end

      local detectionConnections = {}
      local function disconnectDetection(player)
        local connections = detectionConnections[player]
        if not connections then return end
        detectionConnections[player] = nil
        for _, connection in ipairs(connections) do
          pcall(function() connection:Disconnect() end)
          if type(mainGame.conns) == "table" then
            for index = #mainGame.conns, 1, -1 do
              if mainGame.conns[index] == connection then
                table.remove(mainGame.conns, index)
                break
              end
            end
          end
        end
      end
      local function clearDetectionConnections()
        for player in pairs(detectionConnections) do disconnectDetection(player) end
      end

      local grassOriginals = nil
      local function readGrassFlag(name)
        if type(getfflag) ~= "function" then return nil end
        local ok, value = pcall(getfflag, name)
        if ok and value ~= nil then return tostring(value) end
        return nil
      end
      local function setGrassRemoved(enabled)
        if not setfflag then return end
        if enabled then
          if not grassOriginals then
            grassOriginals = {min = readGrassFlag("FRMMinGrassDistance"), max = readGrassFlag("FRMMaxGrassDistance")}
          end
          pcall(setfflag, "FRMMinGrassDistance", "-1")
          pcall(setfflag, "FRMMaxGrassDistance", "-1")
        elseif grassOriginals then
          local originals = grassOriginals
          grassOriginals = nil
          pcall(setfflag, "FRMMinGrassDistance", originals.min or "100")
          pcall(setfflag, "FRMMaxGrassDistance", originals.max or "290")
        end
      end

      -- Building-only X-Ray. Matching parts are cached with their own original
      -- transparency; characters, resources and unrelated map parts are ignored.
      local xrayCache = setmetatable({}, { __mode = "k" })
      local xrayScanId = 0
      local xrayNames = { "TwigWall", "SoloTwigFrame", "TrigTwigRoof", "TwigFrame", "TwigWindow", "TwigRoof" }
      local function isXRayPart(object)
        if not object or not object:IsA("BasePart") then return false end
        for _, keyword in ipairs(xrayNames) do
          if string.find(object.Name, keyword, 1, true) then return true end
        end
        return false
      end
      local function registerXRay(object)
        if not cfg.Misc.XRay or not state.Active or not object.Parent
          or not isXRayPart(object) or xrayCache[object] then return end
        if (tonumber(object.Transparency) or 0) >= 0.95 then return end
        xrayCache[object] = object.Transparency
        pcall(function() object.Transparency = cfg.Misc.XRayTransparency end)
      end
      local function restoreXRay()
        xrayScanId = xrayScanId + 1
        for object, transparency in pairs(xrayCache) do
          if object and object.Parent then
            pcall(function() object.Transparency = transparency end)
          end
        end
        table.clear(xrayCache)
      end
      local function scanXRay()
        if not cfg.Misc.XRay or not state.Active then return end
        xrayScanId = xrayScanId + 1
        local scanId = xrayScanId
        local descendants = workspace:GetDescendants()
        local index = 1
        local function processBatch()
          if scanId ~= xrayScanId or not cfg.Misc.XRay or not state.Active then return end
          local last = math.min(index + 249, #descendants)
          while index <= last do
            pcall(registerXRay, descendants[index])
            index = index + 1
          end
          if index <= #descendants then task.defer(processBatch) end
        end
        processBatch()
      end
      local function setXRay(enabled)
        cfg.Misc.XRay = enabled == true
        if cfg.Misc.XRay then scanXRay() else restoreXRay() end
      end
      local function setXRayTransparency(value)
        cfg.Misc.XRayTransparency = math.clamp((tonumber(value) or 0.5), 0, 0.9)
        if cfg.Misc.XRay then
          for object in pairs(xrayCache) do
            if object and object.Parent then
              pcall(function() object.Transparency = cfg.Misc.XRayTransparency end)
            end
          end
        end
      end
      state.SetXRay = setXRay
      state.SetXRayTransparency = setXRayTransparency
      state.ScanXRay = scanXRay
      state.RestoreXRay = restoreXRay
      state.IsXRayPart = isXRayPart
      state.XRayCache = xrayCache
      addRestore(restoreXRay)
      trackConnection(workspace.DescendantAdded:Connect(function(object)
        if cfg.Misc.XRay and state.Active then pcall(registerXRay, object) end
      end))

      mainGame.extendedCleanups[#mainGame.extendedCleanups + 1] = function()
        state.Active = false
        clearDetectionConnections()
        if state.crouchConnection then state.crouchConnection:Disconnect(); state.crouchConnection = nil end
        for index = #state.restores, 1, -1 do pcall(state.restores[index]) end
        state.restores = {}
        setGrassRemoved(false)
        local character = localPlayer.Character
        if character and cfg.LocalFeatures.SilentWalk then
          pcall(function() character:SetAttribute("Crouching", false) end)
        end
        if state.snapline then state.snapline.Visible = false end
        if state.detectionText then state.detectionText.Visible = false end
        if state.keybindText then state.keybindText.Visible = false end
      end

      local function isTeammate(model)
        local teamDot = model and model:FindFirstChild("TeamDot")
        return teamDot and teamDot.Enabled or false
      end

      local function targetAllowed(target)
        if cfg.Silent.IgnoreDowned and target.model then
          local ok, downed = pcall(function() return target.model:GetAttribute("Downed") end)
          if ok and downed then return false end
        end
        if target.player and cfg.Silent.TeamCheck and isTeammate(target.model) then return false end
        return true
      end

      -- Keep the original Lone collector/selector and add only the optional
      -- Team Check / Ignore Downed filters. Dynamic FOV changes the circle,
      -- never the original angular shot-selection range.
      local baseCollectTargets = collectTargets
      local baseUpdateFovCircle = updateFovCircle
      collectTargets = function()
        local result = {}
        for _, target in ipairs(baseCollectTargets()) do
          if targetAllowed(target) then result[#result + 1] = target end
        end
        return result
      end

      local function effectiveSilentFov(camera)
        local configured = math.clamp(tonumber(cfg.Silent.FOV) or 120, 0, 175)
        if not camera or typeof(camera.ViewportSize) ~= "Vector2" then return configured end
        local viewport = camera.ViewportSize
        local fieldOfView = math.clamp(tonumber(camera.FieldOfView) or 70, 1, 175)
        if viewport.X <= 0 or viewport.Y <= 0 then return configured end
        local radius = math.min(viewport.X, viewport.Y) * 0.45
        local maximum = math.deg(2 * math.atan((radius / (viewport.Y * 0.5)) * math.tan(math.rad(fieldOfView) * 0.5)))
        return math.min(configured, maximum)
      end

      updateFovCircle = function(camera)
        local fovCamera = camera
        if not cfg.Silent.DynamicFOV then
          fovCamera = { ViewportSize = camera.ViewportSize, FieldOfView = 70 }
        end
        local previousFov = cfg.Silent.FOV
        cfg.Silent.FOV = effectiveSilentFov(fovCamera)
        local results = table.pack(pcall(baseUpdateFovCircle, fovCamera))
        cfg.Silent.FOV = previousFov
        if not results[1] then error(results[2], 0) end
        return table.unpack(results, 2, results.n)
      end

      addRestore(function()
        collectTargets = baseCollectTargets
        updateFovCircle = baseUpdateFovCircle
      end)

      local function createOverlayLine()
        local line = Instance.new("Frame")
        line.Name = "BurmaldaSnapline"
        line.BorderSizePixel = 0
        line.BackgroundTransparency = 0
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.ZIndex = 4
        line.Visible = false
        line.Parent = getEspGui()
        mainGame.draws[#mainGame.draws + 1] = line
        return line
      end

      local function setLine(line, from, to, color)
        local dx, dy = to.X - from.X, to.Y - from.Y
        local length = math.sqrt(dx * dx + dy * dy)
        line.Position = UDim2.fromOffset((from.X + to.X) * 0.5, (from.Y + to.Y) * 0.5)
        line.Size = UDim2.fromOffset(math.max(length, 0.1), 1)
        line.Rotation = math.deg(math.atan2(dy, dx))
        line.BackgroundColor3 = color
        line.Visible = true
      end

      local function hookMetatable(instance, method, handler)
        if not (getrawmetatable and setrawmetatable and table.clone and setreadonly and newcclosure) then
          return false
        end
        local ok, original = pcall(function()
          local originalMetatable = getrawmetatable(instance)
          local cloned = table.clone(originalMetatable)
          setreadonly(cloned, false)
          local old = rawget(cloned, method)
          if type(old) ~= "function" then error("missing " .. method) end
          cloned[method] = newcclosure(function(...) return handler(old, ...) end)
          if table.freeze then table.freeze(cloned) end
          setrawmetatable(instance, cloned)
          return originalMetatable
        end)
        if ok then
          addRestore(function() pcall(setrawmetatable, instance, original) end)
        else
          state.installError = tostring(original)
        end
        return ok
      end

      local function shouldBlockRemote(action, firstArgument)
        if type(action) ~= "string" then return false end
        local lowerAction = string.lower(action)
        if cfg.Remote.BlockChecks and (string.find(lowerAction, "check player", 1, true)
          or action == "Network Activity") then
          return true
        end
        if cfg.Remote.BlockProjectile and action == "Simulate Projectile" and type(firstArgument) == "table"
          and not rawget(firstArgument, "AIIndex") then
          return true
        end
        if cfg.Remote.BlockRecoil and action == "Whitelist Recoil" then return true end
        if cfg.LocalFeatures.NoFall and action == "TFD" then return true end
        if cfg.LocalFeatures.SilentWalk and (action == "Change Crouch State"
          or action == "Change Sprinting State") then
          return true
        end
        return false
      end
      state.ShouldBlockRemote = shouldBlockRemote

      local function installRemoteHook()
        if state.remoteInstalled then return end
        local remotes = replicatedStorage:FindFirstChild("Remotes")
        local remote = remotes and remotes:FindFirstChild("RemoteEvent")
        if not remote then return end
        state.remote = remote
        state.remoteInstalled = hookMetatable(remote, "__namecall", function(old, self, ...)
          if self ~= remote or getnamecallmethod() ~= "FireServer" or checkcaller() then
            return old(self, ...)
          end
          local action, firstArgument = ...
          if shouldBlockRemote(action, firstArgument) then return end
          return old(self, ...)
        end)
      end

      local function safeRequire(module)
        if not module then return nil end
        local ok, value = pcall(require, module)
        if ok then return value end
        state.installError = tostring(value)
        return nil
      end

      local function getClientPath()
        local modules = replicatedStorage:FindFirstChild("Modules")
        local client = modules and modules:FindFirstChild("Client")
        local shared = modules and modules:FindFirstChild("Shared")
        return client, shared
      end

      local function patchDelay(fn, enabled)
        if type(fn) ~= "function" or state.patchedFunctions[fn] or not (getfenv and setfenv) then return end
        local ok, originalEnvironment = pcall(getfenv, fn)
        if not ok then return end
        local originalTask = originalEnvironment.task
        local originalDelay = originalTask and originalTask.delay or task.delay
        local newTask = setmetatable({
          delay = function(delayTime, callback, ...)
            if enabled() and type(callback) == "function" then return callback(...) end
            return originalDelay(delayTime, callback, ...)
          end,
        }, { __index = originalTask })
        local newEnvironment = setmetatable({ task = newTask }, { __index = originalEnvironment })
        local setOk = pcall(setfenv, fn, newEnvironment)
        if setOk then
          state.patchedFunctions[fn] = true
          addRestore(function() pcall(setfenv, fn, originalEnvironment) end)
        end
      end

      local function patchRandom(fn, enabled, eoka)
        if type(fn) ~= "function" or not (getfenv and setfenv) then return false end
        if state.patchedFunctions[fn] then return true end
        local ok, originalEnvironment = pcall(getfenv, fn)
        if not ok then return false end
        local originalMath = originalEnvironment.math
        local originalRandom = originalMath and originalMath.random or math.random
        local newMath = setmetatable({
          random = function(...)
            if not enabled() then return originalRandom(...) end
            if eoka then
              local first, second = ...
              return second or first or 1
            end
            return originalRandom(...) * cfg.WeaponMods.Spread / 100
          end,
        }, { __index = originalMath })
        local newEnvironment = setmetatable({ math = newMath }, { __index = originalEnvironment })
        local setOk = pcall(setfenv, fn, newEnvironment)
        if setOk then
          state.patchedFunctions[fn] = true
          addRestore(function() pcall(setfenv, fn, originalEnvironment) end)
        end
        return setOk
      end

      local function eachUpvalue(fn, callback)
        if not (debug and debug.getupvalues and debug.setupvalue) then return end
        local ok, values, iteratorState, control = pcall(debug.getupvalues, fn)
        if not ok then error(values, 0) end
        if type(values) == "table" then
          for key, value in pairs(values) do callback(key, value) end
        elseif type(values) == "function" then
          for key, value in values, iteratorState, control do callback(key, value) end
        end
      end

      local function getWeaponFunctionInfo(fn)
        local source, name = "", ""
        if type(debug.info) == "function" then
          local sourceOk, sourceValue = pcall(debug.info, fn, "s")
          local nameOk, nameValue = pcall(debug.info, fn, "n")
          if sourceOk and type(sourceValue) == "string" then source = sourceValue end
          if nameOk and type(nameValue) == "string" then name = nameValue end
        end
        if (source == "" or name == "") and type(debug.getinfo) == "function" then
          local ok, info = pcall(debug.getinfo, fn, "sn")
          if ok and type(info) == "table" then
            if source == "" then source = info.source or info.short_src or "" end
            if name == "" then name = info.name or "" end
          end
        end
        return source, name
      end

      local function patchWeaponBallistics(fire, recoilModule)
        if type(fire) ~= "function" then return end
        eachUpvalue(fire, function(key, value)
          if type(value) ~= "function" then return end
          local source, name = getWeaponFunctionInfo(value)
          if (string.find(source, "Recoil", 1, true) or name == "Recoil") and recoilModule
            and not state.weaponRecoilPatches[fire] then
            local originalRecoil = value
            local function recoilWrapper(a, b, c, d)
              local originalFourth = d
              if type(d) == "number" then d = d * cfg.WeaponMods.Recoil / 100 end
              local first, second = recoilModule(a, b, c, d)
              return first, second, originalFourth
            end
            local ok, err = pcall(debug.setupvalue, fire, key, recoilWrapper)
            if not ok then error(err, 0) end
            state.weaponRecoilPatches[fire] = true
            state.recoilPatches = state.recoilPatches + 1
            addRestore(function() pcall(debug.setupvalue, fire, key, originalRecoil) end)
          elseif name == "GetSpreadDirection" and not state.weaponSpreadPatches[fire] then
            if patchRandom(value, function() return cfg.WeaponMods.Spread ~= 100 end, false) then
              state.weaponSpreadPatches[fire] = true
              state.spreadPatches = state.spreadPatches + 1
            end
          end
        end)
      end

      local function patchWeaponModule(module, recoilModule)
        if type(module) ~= "table" then return end
        local fire = state.weaponOriginalFire[module] or rawget(module, "Fire")
        if not state.patchedWeaponModules[module] then state.weaponOriginalFire[module] = fire end
        patchWeaponBallistics(fire, recoilModule)
        if state.patchedWeaponModules[module] then return end
        patchDelay(rawget(module, "Setup"), function() return cfg.WeaponMods.InstantEquip end)
        patchRandom(rawget(module, "TryFire"), function() return cfg.WeaponMods.InstantEoka end, true)

        if type(fire) == "function" then
          local function fireWrapper(tool, ...)
            local originalTool = tool
            local proxy = setmetatable({}, {
              __index = function(_, key)
                local value = originalTool[key]
                if key == "RPM" and type(value) == "number" then
                  return value / cfg.WeaponMods.FireRate
                elseif key == "Ready" and cfg.WeaponMods.FastBow then
                  return true
                elseif key == "Viewmodel" and cfg.WeaponMods.ShootSprinting then
                  return setmetatable({ Sprinting = false }, { __index = value, __newindex = value })
                end
                return value
              end,
              __newindex = originalTool,
            })
            if cfg.WeaponMods.AutoReload then
              task.delay(0, module.Reload or function() end, originalTool)
            end
            return fire(proxy, ...)
          end
          if getfenv and setfenv then pcall(setfenv, fireWrapper, getfenv(fire)) end
          rawset(module, "Fire", fireWrapper)
          addRestore(function() rawset(module, "Fire", fire) end)
        end

        local reload = rawget(module, "Reload")
        if type(reload) == "function" then
          local function reloadWrapper(tool, ...)
            local originalTool = tool
            local viewmodelOverride = {}
            if cfg.WeaponMods.ReloadSprinting then viewmodelOverride.Sprinting = false end
            if cfg.WeaponMods.InstantReload then
              viewmodelOverride.Play = function(_, animation, ...)
                local originalViewmodel = originalTool.Viewmodel
                local played = false
                if getconnections and firesignal and originalViewmodel and originalViewmodel.Animator then
                  pcall(function()
                    local track = originalViewmodel.Animator.LoadedAnimations[animation]
                    local finish = track:GetMarkerReachedSignal("FinishReload")
                    local insertBullet = track:GetMarkerReachedSignal("InsertBullet")
                    local insert = track:GetMarkerReachedSignal("Insert")
                    local signal = #getconnections(finish) > 0 and finish
                      or #getconnections(insertBullet) > 0 and insertBullet or insert
                    firesignal(signal)
                    rawset(originalTool, "Reloading", false)
                    played = true
                  end)
                end
                if not played then return originalViewmodel:Play(animation, ...) end
              end
            end
            local proxy = setmetatable({}, {
              __index = function(_, key)
                local value = originalTool[key]
                if key == "Viewmodel" then
                  return setmetatable(viewmodelOverride, { __index = value, __newindex = value })
                end
                return value
              end,
              __newindex = originalTool,
            })
            return reload(proxy, ...)
          end
          if getfenv and setfenv then pcall(setfenv, reloadWrapper, getfenv(reload)) end
          rawset(module, "Reload", reloadWrapper)
          addRestore(function() rawset(module, "Reload", reload) end)
        end
        state.patchedWeaponModules[module] = true
      end

      local function installWeaponModules()
        if state.weaponInstalled and state.recoilPatches > 0 and state.spreadPatches > 0 then return end
        local client = getClientPath()
        if not client then return end
        local tools = client:FindFirstChild("Tools")
        local toolModule = tools and tools:FindFirstChild("Tool")
        local viewmodel = toolModule and toolModule:FindFirstChild("Viewmodel")
        if not viewmodel then return end
        local cameraFolder = client:FindFirstChild("Character")
        local cameraModule = cameraFolder and cameraFolder:FindFirstChild("Camera")
        local recoilScript = cameraModule and cameraModule:FindFirstChild("Recoil")
        local recoilModule = safeRequire(recoilScript)
        local foundModules = false
        local complete = true
        for _, child in ipairs(viewmodel:GetChildren()) do
          if child:IsA("ModuleScript") then
            foundModules = true
            local module = safeRequire(child)
            if type(module) == "table" then
              patchWeaponModule(module, recoilModule)
            else
              complete = false
            end
          end
        end
        if foundModules and complete then state.weaponInstalled = true end
      end

      local function installQuickLoot()
        if state.quickLootInstalled then return end
        local client = getClientPath()
        local inventoryFolder = client and client:FindFirstChild("Inventory")
        local inventoryScript = inventoryFolder and inventoryFolder:FindFirstChild("Inventory")
        local inventory = safeRequire(inventoryScript)
        if inventory and type(inventory.QuickLoot) == "function" then
          patchDelay(inventory.QuickLoot, function() return cfg.LocalFeatures.InstantLoot end)
          state.quickLootInstalled = true
        end
      end

      state.silentShots = 0
      state.silentRedirects = 0
      state.silentRedirectAt = 0
      state.silentError = nil
      state.targetError = nil
      state.silentInstalled = false
      state.silentMode = nil

      local function projectileAllowed(kind, stats)
        local force = cfg.Silent.ForceTypes[kind] == true and stats.Velocity ~= nil
        local crosshair = cfg.Silent.CrosshairTypes[kind] == true and stats.Velocity ~= nil
        local lob = cfg.Silent.LobTypes[kind] == true and stats.Speed ~= nil
        local aimAll = not force and not crosshair and not lob
          and stats.Velocity ~= nil and cfg.Silent.AimAll
        return force or crosshair or lob or aimAll, force, crosshair, lob, aimAll
      end

      -- Original Lone Projectile.New behavior. Bullet/Rocket use the projectile's
      -- ForceHitVector; Arrow/Grenade/AimAll use the original temporary camera
      -- alignment. The camera and CrosshairManager spring are always restored.
      local function redirectProjectile(data, context)
        if not cfg.Silent.Enabled then
          mainGame.stats.lastAim = { reason = "silent off" }
          return
        end
        local stats = data.Stats
        if type(stats) ~= "table" then
          mainGame.stats.lastAim = { reason = "no stats" }
          return
        end
        local kind = tostring(stats.Type)
        if data.ForceDown then
          mainGame.stats.lastAim = { reason = "forced down", type = kind }
          return
        end

        local allowed, force, crosshair, lob, aimAll = projectileAllowed(kind, stats)
        if not allowed then
          mainGame.stats.lastAim = { reason = "type=" .. kind }
          return
        end
        if cfg.Silent.ExtendThrows and aimAll and stats.Drop and stats.Drop > 0 then
          local extended = {}
          for key, value in pairs(stats) do extended[key] = value end
          extended.Drop = 0
          local metatable = getmetatable(stats)
          if metatable then setmetatable(extended, metatable) end
          data.Stats = extended
          stats = extended
        end

        local camera = workspace.CurrentCamera
        local origin = data.Origin or camera and camera.CFrame.Position
        if typeof(origin) ~= "Vector3" then
          mainGame.stats.lastAim = { reason = "no origin", type = kind }
          return
        end
        local speed, gravity
        if lob then
          speed = stats.Speed * 0.5
          gravity = workspace.Gravity
        else
          speed = stats.Velocity
          gravity = stats.Drop
        end
        local maxDistance = cfg.Silent.MaxDistance
        if gravity and gravity > 0 and speed then
          local doubledSpeed = speed * 2
          maxDistance = math.min(maxDistance, doubledSpeed * doubledSpeed / gravity * 0.95)
        end

        local chosen, selection = selectTarget(maxDistance)
        selection.type = kind
        selection.model = force and "force" or crosshair and "crosshair" or lob and "lob" or "lookvector"
        selection.reason = chosen and "redirect" or "no target"
        mainGame.stats.lastAim = selection
        if not chosen then
          state.currentTarget = nil
          return
        end

        local direction = solveBallisticDirection(origin, chosen.part.Position, chosen.vel, speed, gravity)
        if typeof(direction) ~= "Vector3" or direction.Magnitude < 0.001 then return end
        direction = direction.Unit
        local distance = (chosen.part.Position - origin).Magnitude
        selection.pitch = math.deg(math.asin(math.clamp(direction.Y, -1, 1)))
        selection.dist = math.floor(distance)
        selection.vel = speed
        selection.drop = gravity
        state.currentTarget = { part = chosen.part, position = chosen.part.Position, target = chosen.t }

        local spring = context.crosshairManager and context.crosshairManager.AdjustSpring
        if spring then
          context.spring = spring
          context.springPosition = spring.Position
          spring.Position = 0
        end

        if force then
          data.ForceHitVector = origin + direction * (selection.dist + 200)
        else
          if not camera then return end
          context.camera = camera
          context.cameraCFrame = camera.CFrame
          local cameraPosition = context.cameraCFrame.Position
          camera.CFrame = CFrame.lookAt(cameraPosition, cameraPosition + direction)

          if crosshair then
            local screenCenter = (camera.ViewportSize - Vector2.new(0, 72)) / 2
            for _ = 1, 3 do
              local rayDirection = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y).Direction
              local cross = rayDirection:Cross(direction)
              if cross.Magnitude < 1e-7 then break end
              local angle = math.acos(math.clamp(rayDirection:Dot(direction), -1, 1))
              if angle < 0.0001 then break end
              camera.CFrame = CFrame.new(cameraPosition) * CFrame.fromAxisAngle(cross.Unit, angle)
                * CFrame.new(-cameraPosition) * camera.CFrame
            end
          end
        end

        state.silentRedirects = state.silentRedirects + 1
        state.silentRedirectAt = os.clock()
        state.silentLastPosition = chosen.part.Position
        state.silentError = nil
        mainGame.stats.redirected = mainGame.stats.redirected + 1
      end

      installProjectileHook = function()
        local generation = mainGame.hookGeneration
        local ok, module = pcall(function()
          return require(replicatedStorage.Modules.Client.Physics.Projectile)
        end)
        if not ok or type(module) ~= "table" or type(module.New) ~= "function" then
          return false, tostring(module)
        end
        if mainGame.hooked and mainGame.projectileDirect and mainGame.projectileWrapper == module.New then
          return true
        end
        if mainGame.unloaded or mainGame.hookGeneration ~= generation then return false, "cancelled" end

        local crosshairManager
        local managerOk, manager = pcall(function()
          return require(replicatedStorage.Modules.Shared.ModuleLoader):Load("CrosshairManager")
        end)
        if managerOk and type(manager) == "table" and manager.AdjustSpring then
          crosshairManager = manager
        end
        if mainGame.unloaded or mainGame.hookGeneration ~= generation then return false, "cancelled" end

        local original = mainGame.projModule == module and mainGame.origNew or module.New
        mainGame.projModule = module
        mainGame.origNew = original
        mainGame.hooked = false
        mainGame.projectileDirect = false
        local wrapper = function(self, data, ...)
          mainGame.stats.shots = mainGame.stats.shots + 1
          local context = { crosshairManager = crosshairManager }
          if type(data) == "table" and not data.FromServer then
            mainGame.stats.localShots = (mainGame.stats.localShots or 0) + 1
            state.silentShots = state.silentShots + 1
            local shotStats = data.Stats
            if type(shotStats) == "table" then
              local kind = tostring(shotStats.Type)
              mainGame.stats.types = mainGame.stats.types or {}
              mainGame.stats.types[kind] = (mainGame.stats.types[kind] or 0) + 1
            end
            local redirectOk, redirectError = pcall(redirectProjectile, data, context)
            if not redirectOk then
              mainGame.stats.lastAim = { reason = "error", error = tostring(redirectError) }
              state.silentError = tostring(redirectError)
            end
          end

          -- Calamari visuals observe the already-owned local Projectile.New call.
          -- They never redirect data and perform no work until a shot visual is on.
          if type(data) == "table" and not data.FromServer and mainGame.calamariVisuals then
            local origin = data.Origin
            local camera = workspace.CurrentCamera
            local direction
            if typeof(origin) == "Vector3" and typeof(data.ForceHitVector) == "Vector3" then
              direction = data.ForceHitVector - origin
            elseif camera then
              direction = camera.CFrame.LookVector
            end
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" and direction.Magnitude > 0.001 then
              pcall(mainGame.calamariVisuals.TraceShot, origin, direction, 1000)
            end
          end

          local results = table.pack(pcall(original, self, data, ...))
          if context.cameraCFrame and context.camera then
            pcall(function() context.camera.CFrame = context.cameraCFrame end)
          end
          if context.spring and context.springPosition ~= nil then
            pcall(function() context.spring.Position = context.springPosition end)
          end
          if not results[1] then error(results[2], 0) end
          return table.unpack(results, 2, results.n)
        end

        local written = pcall(function() module.New = wrapper end)
        if not written or module.New ~= wrapper then
          if type(make_writeable) == "function" then pcall(make_writeable, module) end
          if type(setreadonly) == "function" then pcall(setreadonly, module, false) end
          written = pcall(function() module.New = wrapper end)
        end
        if not written or module.New ~= wrapper then
          mainGame.hooked = false
          mainGame.projectileDirect = false
          mainGame.projectileWrapper = nil
          return false, "cannot write Projectile.New"
        end
        mainGame.projectileWrapper = wrapper
        mainGame.projectileDirect = true
        mainGame.hooked = true
        return true
      end

      local function restoreAmogusSilent()
        if mainGame.projModule and mainGame.origNew and mainGame.projectileWrapper
          and mainGame.projModule.New == mainGame.projectileWrapper then
          pcall(function() mainGame.projModule.New = mainGame.origNew end)
        end
        mainGame.hooked = false
        mainGame.projectileDirect = false
        mainGame.projectileWrapper = nil
        state.silentInstalled = false
        state.silentMode = nil
      end
      addRestore(restoreAmogusSilent)

      local function installAmogusSilent()
        if state.silentInstalled and state.silentMode == "projectile"
          and mainGame.hooked and mainGame.projectileDirect and mainGame.projModule
          and mainGame.projModule.New == mainGame.projectileWrapper then
          return true
        end
        state.silentInstalled = false
        state.silentMode = nil
        local projectileOk, projectileError = installProjectileHook()
        state.silentInstalled = projectileOk == true
        state.silentMode = state.silentInstalled and "projectile" or nil
        state.silentError = state.silentInstalled and nil or tostring(projectileError)
        return state.silentInstalled
      end
      state.InstallSilent = installAmogusSilent
      state.RestoreSilent = restoreAmogusSilent

      trackConnection(localPlayer.CharacterRemoving:Connect(function()
        restoreAmogusSilent()
        state.currentTarget = nil
        state.silentRedirectAt = 0
        state.nextSilentInstallAttempt = 0
      end))
      trackConnection(localPlayer.CharacterAdded:Connect(function()
        restoreAmogusSilent()
        state.silentRedirectAt = 0
        state.nextSilentTargetUpdate = 0
        state.nextSilentInstallAttempt = 0
      end))

      trackConnection(runService.RenderStepped:Connect(function()
        if not state.Active or not cfg.Silent.Enabled then
          state.currentTarget = nil
          return
        end
        local now = os.clock()
        if not state.silentInstalled and now >= (state.nextSilentInstallAttempt or 0) then
          state.nextSilentInstallAttempt = now + 0.5
          local ok, err = pcall(installAmogusSilent)
          if not ok then state.silentError = tostring(err) end
        end
        if cfg.Silent.Snapline and now >= (state.nextSilentTargetUpdate or 0) then
          state.nextSilentTargetUpdate = now + 1 / 15
          local ok, chosen = pcall(selectTarget, cfg.Silent.MaxDistance)
          if ok then
            state.currentTarget = chosen and {
              part = chosen.part,
              position = chosen.part.Position,
              target = chosen.t,
            } or nil
            state.targetError = nil
          else
            state.currentTarget = nil
            state.targetError = tostring(chosen)
          end
        end
      end))


      state.installErrors = state.installErrors or {}
      state.installWarnings = state.installWarnings or {}

      local function installTraceback(value)
        local message = tostring(value)
        if type(value) == "table" then
          local ok, fields = pcall(function()
            local parts = {}
            for key, child in pairs(value) do
              parts[#parts + 1] = tostring(key) .. "=" .. tostring(child)
              if #parts >= 8 then break end
            end
            return table.concat(parts, ", ")
          end)
          if ok and fields ~= "" then message = "table{" .. fields .. "}" end
        end
        if debug and type(debug.traceback) == "function" then
          local ok, trace = pcall(debug.traceback, message, 2)
          if ok and type(trace) == "string" then
            -- Some executor shims return only a source label. Never lose the
            -- original error text when that happens.
            if string.find(trace, message, 1, true) then return trace end
            return message .. "\n" .. trace
          end
        end
        return message
      end

      local function runInstallStage(name, callback)
        local ok, message = xpcall(callback, installTraceback)
        if ok then
          state.installErrors[name] = nil
          state.installWarnings[name] = nil
          return true
        end

        state.installErrors[name] = message
        state.lastInstallError = { Stage = name, Error = message }
        -- RenderStepped retries installation. Report each distinct failure once,
        -- not every two seconds, and never let it abort construction of the UI.
        if state.installWarnings[name] ~= message then
          state.installWarnings[name] = message
          local output = "[Burmalda.hook] " .. name .. " install failed:\n" .. message
          if type(warn) == "function" then pcall(warn, output) else print(output) end
        end
        return false
      end

      local function installAll()
        local allOk = true
        for _, stage in ipairs({
          { "Amogus Silent", installAmogusSilent },
          { "Remote", installRemoteHook },
          { "Weapon Modules", installWeaponModules },
          { "Quick Loot", installQuickLoot },
        }) do
          if not runInstallStage(stage[1], stage[2]) then allOk = false end
        end
        return allOk
      end
      state.Install = installAll

      local function getNetwork()
        if state.network then return state.network end
        local _, shared = getClientPath()
        state.network = safeRequire(shared and shared:FindFirstChild("Network"))
        return state.network
      end

      local function fireNetwork(action, value)
        local network = getNetwork()
        if network and type(network.Fire) == "function" then pcall(network.Fire, network, action, value) end
      end

      function state.SetSilentWalk(enabled)
        enabled = enabled == true
        local wasApplied = state.silentWalkApplied == true
        -- Building the UI with an Off default must not touch the character or network.
        if not enabled and not wasApplied then return end
        state.silentWalkApplied = enabled
        local character = localPlayer.Character
        if character then pcall(function() character:SetAttribute("Crouching", enabled) end) end
        if enabled then
          fireNetwork("Change Crouch State", true)
        else
          fireNetwork("Change Crouch State", false)
          fireNetwork("Change Sprinting State", false)
        end
      end
      state.SetRemoveGrass = setGrassRemoved

      local function bindSilentWalkCharacter(character)
        if state.crouchConnection then state.crouchConnection:Disconnect(); state.crouchConnection = nil end
        if character then
          state.crouchConnection = trackConnection(character:GetAttributeChangedSignal("Crouching"):Connect(function()
            if state.Active and cfg.LocalFeatures.SilentWalk and character:GetAttribute("Crouching") ~= true then
              character:SetAttribute("Crouching", true)
            end
          end))
          if cfg.LocalFeatures.SilentWalk then state.SetSilentWalk(true) end
        end
      end
      trackConnection(localPlayer.CharacterAdded:Connect(bindSilentWalkCharacter))
      trackConnection(localPlayer.CharacterRemoving:Connect(function()
        if state.crouchConnection then state.crouchConnection:Disconnect(); state.crouchConnection = nil end
      end))
      bindSilentWalkCharacter(localPlayer.Character)

      local function checkDetection(player)
        if not cfg.LocalFeatures.DetectionNotifier then return end
        for _, attribute in ipairs({ "NSBIP", "PlayerSettingsProcessed", "FlaggedByModerators" }) do
          if player:GetAttribute(attribute) then
            state.detectionUntil = os.clock() + 3
            state.detectionMessage = (player == localPlayer and "LOCALPLAYER" or player.DisplayName)
              .. " has been flagged by the anticheat!"
            return
          end
        end
      end
      local function bindDetection(player)
        disconnectDetection(player)
        local connections = {}
        detectionConnections[player] = connections
        for _, attribute in ipairs({ "NSBIP", "PlayerSettingsProcessed", "FlaggedByModerators" }) do
          local connection = trackConnection(player:GetAttributeChangedSignal(attribute):Connect(function() checkDetection(player) end))
          table.insert(connections, connection)
        end
        checkDetection(player)
      end
      for _, player in ipairs(players:GetPlayers()) do bindDetection(player) end
      trackConnection(players.PlayerAdded:Connect(bindDetection))
      trackConnection(players.PlayerRemoving:Connect(disconnectDetection))

      trackConnection(runService.RenderStepped:Connect(function()
        if not state.Active then return end
        local now = os.clock()
        if now >= state.nextInstall then
          state.nextInstall = now + (cfg.Misc.LowPC and 5 or 2)
          pcall(installAll)
        end

        local camera = workspace.CurrentCamera
        if not camera then return end
        if not cfg.Silent.Enabled then state.currentTarget = nil end

        local target = state.currentTarget
        if cfg.Silent.Snapline and cfg.Silent.Enabled and target then
          if not state.snapline then state.snapline = createOverlayLine() end
          local screen, visible = camera:WorldToViewportPoint(target.position)
          if visible and screen.Z > 0 then
            local mouse = userInputService:GetMouseLocation()
            setLine(state.snapline, mouse, Vector2.new(screen.X, screen.Y), cfg.Silent.SnaplineColor)
          else
            state.snapline.Visible = false
          end
        elseif state.snapline then
          state.snapline.Visible = false
        end

        if state.detectionUntil > now and cfg.LocalFeatures.DetectionNotifier then
          if not state.detectionText then state.detectionText = createTextDrawing(14, true) end
          state.detectionText.Text = state.detectionMessage or "anticheat detection"
          state.detectionText.Color = Color3.fromRGB(255, 80, 80)
          state.detectionText.Position = Vector2.new(camera.ViewportSize.X * 0.5, 80)
          state.detectionText.Visible = true
        elseif state.detectionText then
          state.detectionText.Visible = false
        end

        if cfg.LocalFeatures.KeybindList then
          local lines = {}
          for featureName, entry in pairs(bindApis) do
            local key = entry.Get()
            if key ~= "None" then
              lines[#lines + 1] = (featureStates[featureName] and "[x] " or "[ ] ")
                .. featureName .. "  [" .. key .. "]"
            end
          end
          table.sort(lines)
          if #lines > 0 then
            if not state.keybindText then state.keybindText = createTextDrawing(13, false) end
            state.keybindText.Text = table.concat(lines, "\n")
            state.keybindText.Position = Vector2.new(12, 120)
            state.keybindText.Visible = true
          elseif state.keybindText then
            state.keybindText.Visible = false
          end
        elseif state.keybindText then
          state.keybindText.Visible = false
        end
      end))

      setGrassRemoved(cfg.LocalFeatures.RemoveGrass)
      installAll()
    end


    -- Additional Lone features recovered from the Qwerty reference behavior.
    -- They use our own config, Drawing objects and lifecycle; no Qwerty UI,
    -- authorization, HTTP loader or second projectile owner is included.
    do
      cfg.Extra = cfg.Extra or {}
      local extra = cfg.Extra
      local sectionDefaults = {
        Aimbot = {
          Enabled = false, FOV = 30, MaxDistance = 10000, Speed = 90,
          ShowFOV = false, WallCheck = false, TargetNPCs = false, PriorityPlayers = false,
          FOVColor = Color3.fromRGB(255, 255, 255), FOVThickness = 1,
        },
        Trigger = {
          Enabled = false, Delay = 0.1, UseSilent = false, UseAimbot = false,
          RequireVisible = false, RequireFOV = false,
        },
        Movement = { Noclip = false, AntiFall = false, AntiSpikes = false },
        Camera = {
          CustomFOV = false, FOV = 90, Zoom = false, ZoomFOV = 20,
          ThirdPerson = false, Distance = 10, Height = 1.5, Side = 0, Sensitivity = 0.2,
        },
        World = { RemoveLeafs = false, RemoveBushes = false },
        ESP = {
          ScanInterval = 1, MaxTargets = 96, GhostTTL = 60, GhostMaxDistance = 5000,
          Categories = {}, Colors = {},
        },
        Crosshair = {
          Enabled = false, Shape = "Star", Size = 12, Gap = 4, Thickness = 2,
          Spin = 0, RGB = false, RGBSpeed = 5, Color = Color3.fromRGB(255, 255, 255),
        },
        AntiAim = { Enabled = false, Type = "Spin", SpinSpeed = 10, Jitter = 10 },
        Pose = { Enabled = false, Drop = 1.5, Pitch = -10, Turn = 180 },
      }
      local function fillDefaults(destination, defaults)
        for key, value in pairs(defaults) do
          if type(value) == "table" then
            if type(destination[key]) ~= "table" then destination[key] = {} end
            fillDefaults(destination[key], value)
          elseif destination[key] == nil then
            destination[key] = value
          end
        end
      end
      fillDefaults(extra, sectionDefaults)

      cfg.ESP.Skeleton = cfg.ESP.Skeleton == true
      cfg.ESP.SkeletonColor = cfg.ESP.SkeletonColor or Color3.fromRGB(255, 255, 255)
      cfg.ESP.SkeletonThickness = tonumber(cfg.ESP.SkeletonThickness) or 1
      cfg.ESP.Fade = cfg.ESP.Fade == true
      cfg.ESP.VisibleOnly = cfg.ESP.VisibleOnly == true
      cfg.ESP.VisibleColors = cfg.ESP.VisibleColors == true
      cfg.ESP.BoxThickness = tonumber(cfg.ESP.BoxThickness) or 1
      cfg.ESP.TracerThickness = tonumber(cfg.ESP.TracerThickness) or 1
      cfg.ESP.TextScale = tonumber(cfg.ESP.TextScale) or 1

      local categoryDefinitions = {
        { key = "DroppedItems", label = "Dropped Item", container = "Dropped", distance = 250,
          color = Color3.fromRGB(240, 220, 60) },
        { key = "KeyDrops", label = "Key Drop", container = "KeyDrops", distance = 1000,
          color = Color3.fromRGB(255, 100, 200) },
        { key = "OfflinePlayers", label = "Offline Player", container = "OfflinePlayers", distance = 500,
          color = Color3.fromRGB(80, 220, 240) },
        { key = "ToolBox", label = "ToolBox", container = "LootCrates", distance = 1500,
          color = Color3.fromRGB(165, 110, 60), match = "ToolBox" },
        { key = "FoodCrate", label = "FoodCrate", container = "LootCrates", distance = 1500,
          color = Color3.fromRGB(165, 110, 60), match = "FoodCrate" },
        { key = "LargeCrate", label = "LargeCrate", container = "LootCrates", distance = 1500,
          color = Color3.fromRGB(165, 110, 60), match = "LargeCrate" },
        { key = "Medbag", label = "Medbag", container = "LootCrates", distance = 1500,
          color = Color3.fromRGB(165, 110, 60), match = "Medbag" },
        { key = "Military", label = "Military", container = "LootCrates", distance = 1500,
          color = Color3.fromRGB(165, 110, 60), match = "Military" },
        { key = "SNTech", label = "SNTech", container = "LootCrates", distance = 1500,
          color = Color3.fromRGB(80, 220, 100), match = "SNTech" },
        { key = "Raider", label = "Raider X", container = "ActiveRaiderX", distance = 5000,
          color = Color3.fromRGB(255, 70, 70) },
      }
      for _, definition in ipairs(categoryDefinitions) do
        if extra.ESP.Categories[definition.key] == nil then
          extra.ESP.Categories[definition.key] = false
        end
        extra.ESP.Colors[definition.key] = extra.ESP.Colors[definition.key] or definition.color
      end
      if extra.ESP.Categories.Ghost == nil then extra.ESP.Categories.Ghost = false end
      extra.ESP.Colors.Ghost = extra.ESP.Colors.Ghost or Color3.fromRGB(190, 120, 255)

      local state = {
        Active = true,
        owned = {},
        noclipOriginals = {},
        noclipParts = {},
        worldGeometry = setmetatable({}, { __mode = "k" }),
        skeletonBones = setmetatable({}, { __mode = "k" }),
        spikeOriginals = {},
        leafOriginals = {},
        bushOriginals = {},
        worldEspPool = {},
        worldEspPoolUsed = 0,
        skeletonLines = {},
        skeletonLineStates = {},
        skeletonLinesUsed = 0,
        ghosts = {},
        targetVisibility = setmetatable({}, { __mode = "k" }),
        third = { active = false, lookX = 0, lookY = 0 },
        frozenTracks = {},
      }
      mainGame.extraFeatures = state
      state.CategoryDefinitions = categoryDefinitions

      local function ownDrawing(className)
        if Drawing == nil or type(Drawing.new) ~= "function" then return nil end
        local ok, object = pcall(Drawing.new, className)
        if not ok or not object then return nil end
        object.Visible = false
        state.owned[#state.owned + 1] = object
        mainGame.draws[#mainGame.draws + 1] = object
        return object
      end
      local function hide(object)
        if object then pcall(function() object.Visible = false end) end
      end
      local function dot(a, b)
        return a.X * b.X + a.Y * b.Y + a.Z * b.Z
      end
      local function anyCategoryEnabled()
        for _, enabled in pairs(extra.ESP.Categories) do
          if enabled then return true end
        end
        return false
      end

      -- Character collision ownership: scan only on character changes and new
      -- descendants, while still enforcing collision every rendered frame.
      function state.RestoreNoclip()
        if state.noclipAdded then pcall(function() state.noclipAdded:Disconnect() end) end
        state.noclipAdded = nil
        for part, original in pairs(state.noclipOriginals) do
          if part then pcall(function() part.CanCollide = original end) end
        end
        table.clear(state.noclipOriginals)
        table.clear(state.noclipParts)
        state.noclipCharacter = nil
      end
      function state.SetNoclip(enabled)
        extra.Movement.Noclip = enabled == true
        if not extra.Movement.Noclip then state.RestoreNoclip() end
      end
      local function updateNoclip()
        if not extra.Movement.Noclip then
          if next(state.noclipOriginals) ~= nil then state.RestoreNoclip() end
          return
        end
        local character = localPlayer.Character
        if character ~= state.noclipCharacter then
          state.RestoreNoclip()
          state.noclipCharacter = character
          if character then
            for _, object in ipairs(character:GetDescendants()) do
              if object:IsA("BasePart") then
                state.noclipOriginals[object] = object.CanCollide
                state.noclipParts[#state.noclipParts + 1] = object
              end
            end
            state.noclipAdded = trackConnection(character.DescendantAdded:Connect(function(object)
              if extra.Movement.Noclip and state.noclipCharacter == character
                and object:IsA("BasePart") and state.noclipOriginals[object] == nil then
                state.noclipOriginals[object] = object.CanCollide
                state.noclipParts[#state.noclipParts + 1] = object
                object.CanCollide = false
              end
            end))
          end
        end
        if not character then return end
        for index = #state.noclipParts, 1, -1 do
          local object = state.noclipParts[index]
          if not object:IsDescendantOf(character) then
            local original = state.noclipOriginals[object]
            if original ~= nil then pcall(function() object.CanCollide = original end) end
            state.noclipOriginals[object] = nil
            table.remove(state.noclipParts, index)
          elseif object.CanCollide then
            object.CanCollide = false
          end
        end
      end

      function state.RestoreGravity()
        if state.gravityOriginal ~= nil then
          local original = state.gravityOriginal
          state.gravityOriginal = nil
          pcall(function() workspace.Gravity = original end)
        end
      end
      function state.SetAntiFall(enabled)
        extra.Movement.AntiFall = enabled == true
        if not extra.Movement.AntiFall then state.RestoreGravity() end
      end
      local function updateGravity()
        if not extra.Movement.AntiFall then return end
        if state.gravityOriginal == nil then state.gravityOriginal = workspace.Gravity end
        if workspace.Gravity ~= 0 then workspace.Gravity = 0 end
      end

      local function nameMatches(object, words)
        local current = object
        for _ = 1, 3 do
          if not current or current == workspace then return false end
          local name = string.lower(tostring(current.Name or ""))
          for _, word in ipairs(words) do
            if string.find(name, word, 1, true) then return true end
          end
          current = current.Parent
        end
        return false
      end
      local function scanBatches(objects, callback, tokenName)
        local token = (state[tokenName] or 0) + 1
        state[tokenName] = token
        local index = 1
        local function process()
          if not state.Active or state[tokenName] ~= token then return end
          local last = math.min(index + 249, #objects)
          while index <= last do
            pcall(callback, objects[index])
            index = index + 1
          end
          if index <= #objects then task.defer(process) end
        end
        process()
      end
      local function registerSpike(object)
        if not extra.Movement.AntiSpikes or not object:IsA("BasePart")
          or state.spikeOriginals[object] ~= nil or not nameMatches(object, { "spike" }) then return end
        state.spikeOriginals[object] = { CanTouch = object.CanTouch, CanCollide = object.CanCollide }
        object.CanTouch = false
        object.CanCollide = false
      end
      function state.RestoreSpikes()
        state.spikeScanToken = (state.spikeScanToken or 0) + 1
        for part, original in pairs(state.spikeOriginals) do
          if part and part.Parent then
            pcall(function()
              part.CanTouch = original.CanTouch
              part.CanCollide = original.CanCollide
            end)
          end
        end
        table.clear(state.spikeOriginals)
      end
      function state.SetAntiSpikes(enabled)
        extra.Movement.AntiSpikes = enabled == true
        if extra.Movement.AntiSpikes then
          scanBatches(workspace:GetDescendants(), registerSpike, "spikeScanToken")
        else
          state.RestoreSpikes()
        end
      end

      local vegetationWords = {
        Leafs = { "leaf", "leafs", "leaves" },
        Bushes = { "bush", "bushes", "shrub" },
      }
      local function vegetationMap(kind)
        return kind == "Leafs" and state.leafOriginals or state.bushOriginals
      end
      local function vegetationEnabled(kind)
        return kind == "Leafs" and extra.World.RemoveLeafs or extra.World.RemoveBushes
      end
      local function registerVegetation(kind, object)
        if not vegetationEnabled(kind) or not object:IsA("BasePart") then return end
        local originals = vegetationMap(kind)
        if originals[object] ~= nil or not nameMatches(object, vegetationWords[kind]) then return end
        originals[object] = object.Transparency
        object.Transparency = 1
      end
      function state.RestoreVegetation(kind)
        local originals = vegetationMap(kind)
        local tokenName = kind == "Leafs" and "leafScanToken" or "bushScanToken"
        state[tokenName] = (state[tokenName] or 0) + 1
        for part, transparency in pairs(originals) do
          if part and part.Parent then pcall(function() part.Transparency = transparency end) end
        end
        table.clear(originals)
      end
      function state.SetVegetation(kind, enabled)
        local value = enabled == true
        if kind == "Leafs" then extra.World.RemoveLeafs = value else extra.World.RemoveBushes = value end
        if value then
          scanBatches(workspace:GetDescendants(), function(object)
            registerVegetation(kind, object)
          end, kind == "Leafs" and "leafScanToken" or "bushScanToken")
        else
          state.RestoreVegetation(kind)
        end
      end

      -- FOV and third-person camera have separate backups and never share the
      -- Freecam owner. Zoom has priority over the normal custom FOV value.
      function state.RestoreFOV()
        if state.fovCamera and state.fovOriginal ~= nil then
          pcall(function() state.fovCamera.FieldOfView = state.fovOriginal end)
        end
        state.fovCamera, state.fovOriginal = nil, nil
      end
      local function updateFOV()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local enabled = extra.Camera.CustomFOV or extra.Camera.Zoom
        if not enabled then
          if state.fovOriginal ~= nil then state.RestoreFOV() end
          return
        end
        if state.fovCamera ~= camera then
          state.RestoreFOV()
          state.fovCamera, state.fovOriginal = camera, camera.FieldOfView
        end
        local desired = extra.Camera.Zoom and extra.Camera.ZoomFOV or extra.Camera.FOV
        desired = math.clamp(tonumber(desired) or 70, 5, 120)
        if camera.FieldOfView ~= desired then camera.FieldOfView = desired end
      end
      function state.SetCustomFOV(enabled)
        extra.Camera.CustomFOV = enabled == true
        if not extra.Camera.CustomFOV and not extra.Camera.Zoom then state.RestoreFOV() end
      end
      function state.SetZoom(enabled)
        extra.Camera.Zoom = enabled == true
        if not extra.Camera.Zoom and not extra.Camera.CustomFOV then state.RestoreFOV() end
      end

      local function restoreThirdMouse()
        local third = state.third
        if third.originalMouseBehavior ~= nil then
          pcall(function() userInputService.MouseBehavior = third.originalMouseBehavior end)
        end
        if third.originalMouseIcon ~= nil then
          pcall(function() userInputService.MouseIconEnabled = third.originalMouseIcon end)
        end
        third.originalMouseBehavior, third.originalMouseIcon = nil, nil
      end
      function state.StopThirdPerson()
        local third = state.third
        if not third.active then return end
        third.active = false
        local camera = third.camera or workspace.CurrentCamera
        if camera then
          pcall(function()
            camera.CameraType = third.originalCameraType or Enum.CameraType.Custom
            if third.originalCameraSubject ~= nil then camera.CameraSubject = third.originalCameraSubject end
            if third.originalCFrame then camera.CFrame = third.originalCFrame end
          end)
        end
        restoreThirdMouse()
        third.camera, third.originalCameraType, third.originalCameraSubject = nil, nil, nil
        third.originalCFrame, third.lookX, third.lookY = nil, 0, 0
      end
      local function startThirdPerson()
        local third = state.third
        local camera = workspace.CurrentCamera
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if third.active or not camera or not root then return false end
        third.camera = camera
        third.originalCameraType = camera.CameraType
        third.originalCameraSubject = camera.CameraSubject
        third.originalCFrame = camera.CFrame
        third.originalMouseBehavior = userInputService.MouseBehavior
        third.originalMouseIcon = userInputService.MouseIconEnabled
        local look = camera.CFrame.LookVector
        third.yaw = math.abs(look.X) + math.abs(look.Z) > 1e-6 and math.atan2(-look.X, -look.Z) or 0
        third.pitch = math.asin(math.clamp(look.Y, -1, 1))
        third.lookX, third.lookY = 0, 0
        third.active = true
        camera.CameraType = Enum.CameraType.Scriptable
        return true
      end
      function state.SetThirdPerson(enabled)
        extra.Camera.ThirdPerson = enabled == true
        if extra.Camera.ThirdPerson and cfg.Movement.Freecam and mainGame.Window then
          mainGame.Window:SetFeature("Freecam", false)
        end
        if not extra.Camera.ThirdPerson then state.StopThirdPerson() end
      end
      local function updateThirdPerson()
        if not extra.Camera.ThirdPerson or cfg.Movement.Freecam then
          if state.third.active then state.StopThirdPerson() end
          return
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        if state.third.active and state.third.camera ~= camera then state.StopThirdPerson() end
        if not state.third.active and not startThirdPerson() then return end
        local third = state.third
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local open = menuOpen == true
        userInputService.MouseBehavior = open and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCurrentPosition
        userInputService.MouseIconEnabled = open
        if not open then
          local sensitivity = math.clamp(tonumber(extra.Camera.Sensitivity) or 0.2, 0.01, 1) * 0.01
          third.yaw = third.yaw - math.clamp(third.lookX or 0, -500, 500) * sensitivity
          third.pitch = math.clamp(third.pitch - math.clamp(third.lookY or 0, -500, 500) * sensitivity,
            -1.35, 1.35)
        end
        third.lookX, third.lookY = 0, 0
        if extra.Aimbot.Enabled and state.aimbotTarget then return end
        local rotation = CFrame.fromEulerAnglesYXZ(third.pitch or 0, third.yaw or 0, 0)
        local focus = root.Position + Vector3.new(0, 1.5, 0)
        local look = rotation.LookVector or Vector3.new(0, 0, -1)
        local right = rotation.RightVector or Vector3.new(1, 0, 0)
        local position = focus - look * math.clamp(tonumber(extra.Camera.Distance) or 10, 2, 30)
          + right * math.clamp(tonumber(extra.Camera.Side) or 0, -10, 10)
          + Vector3.new(0, math.clamp(tonumber(extra.Camera.Height) or 1.5, -5, 10), 0)
        camera.CFrame = CFrame.lookAt(position, focus)
      end

      -- Aimbot target selection is independent from the Silent projectile hook.
      local function cachedVisibility(target, part, origin)
        local now = os.clock()
        local cached = state.targetVisibility[target.model]
        if cached and cached.part == part and now < cached.next then return cached.visible end
        local visible = isTargetVisible(origin, part)
        state.targetVisibility[target.model] = { part = part, visible = visible, next = now + 0.2 }
        return visible
      end
      local function currentTargetList()
        -- Share the projectile/ESP target cache instead of scanning players
        -- again for Aimbot on every rendered frame.
        return getCachedTargets(0.1)
      end
      local function findAimbotTarget()
        local camera = workspace.CurrentCamera
        if not camera then return nil end
        local origin, look = camera.CFrame.Position, camera.CFrame.LookVector
        local best, bestPlayer = nil, nil
        local bestAngle, bestPlayerAngle = math.huge, math.huge
        for _, target in ipairs(currentTargetList()) do
          if (target.player or extra.Aimbot.TargetNPCs)
            and not (cfg.Silent.IgnorePlayers and cfg.Silent.IgnorePlayers[target.name]) then
            local teamDot = target.player and cfg.Silent.TeamCheck
              and target.model:FindFirstChild("TeamDot")
            if not (cfg.Silent.TeamCheck and teamDot and teamDot.Enabled) then
              local part = getAimPart(target)
              if part and part.Parent then
                local offset = part.Position - origin
                local distance = offset.Magnitude
                if distance > 0.1 and distance <= extra.Aimbot.MaxDistance then
                  local angle = math.deg(math.acos(math.clamp(dot(look, offset) / distance, -1, 1)))
                  if angle <= extra.Aimbot.FOV then
                    local visible = not extra.Aimbot.WallCheck or cachedVisibility(target, part, origin)
                    if visible then
                      local candidate = { t = target, part = part, vel = getTargetVelocity(target),
                        angle = angle, visible = extra.Aimbot.WallCheck and true or nil, source = "Aimbot" }
                      if angle < bestAngle then best, bestAngle = candidate, angle end
                      if target.player and angle < bestPlayerAngle then
                        bestPlayer, bestPlayerAngle = candidate, angle
                      end
                    end
                  end
                end
              end
            end
          end
        end
        if extra.Aimbot.PriorityPlayers and bestPlayer then return bestPlayer end
        return best or bestPlayer
      end
      function state.SetAimbot(enabled)
        extra.Aimbot.Enabled = enabled == true
        if not extra.Aimbot.Enabled then state.aimbotTarget = nil end
      end
      local function updateAimbot()
        state.aimbotTarget = extra.Aimbot.Enabled and findAimbotTarget() or nil
        local camera = workspace.CurrentCamera
        local target = state.aimbotTarget
        if not camera or not extra.Aimbot.Enabled or not target or menuOpen == true or cfg.Movement.Freecam then return end
        local desired = CFrame.lookAt(camera.CFrame.Position, target.part.Position)
        local current = camera.CFrame
        if current.Lerp then
          current = current:Lerp(desired, math.clamp((tonumber(extra.Aimbot.Speed) or 90) / 100, 0.01, 1))
        else
          current = desired
        end
        camera.CFrame = current
      end
      local function updateAimbotFOV(camera)
        local visible = extra.Aimbot.Enabled and extra.Aimbot.ShowFOV
        local circle = state.aimbotFovCircle
        if not visible then
          if circle and state.aimbotFovVisible ~= false then
            circle.Visible = false
            state.aimbotFovVisible = false
          end
          return
        end
        if not circle then
          circle = ownDrawing("Circle")
          state.aimbotFovCircle = circle
          state.aimbotFovVisible = false
          state.aimbotFovState = {}
          if circle then circle.Filled = false; circle.NumSides = 32 end
        end
        if not circle then return end
        local viewport = camera.ViewportSize
        local radius = math.min(viewport.Y * 0.5
          * math.tan(math.rad(math.min(extra.Aimbot.FOV, 175) * 0.5))
          / math.tan(math.rad(camera.FieldOfView) * 0.5),
          math.min(viewport.X, viewport.Y) * 0.45)
        local position = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        local cached = state.aimbotFovState
        if state.aimbotFovVisible ~= true then state.aimbotFovVisible = true; circle.Visible = true end
        if cached.radius ~= radius then cached.radius = radius; circle.Radius = radius end
        if cached.position ~= position then cached.position = position; circle.Position = position end
        if cached.color ~= extra.Aimbot.FOVColor then
          cached.color = extra.Aimbot.FOVColor
          circle.Color = extra.Aimbot.FOVColor
        end
        if cached.thickness ~= extra.Aimbot.FOVThickness then
          cached.thickness = extra.Aimbot.FOVThickness
          circle.Thickness = extra.Aimbot.FOVThickness
        end
        if cached.transparency ~= 1 then cached.transparency = 1; circle.Transparency = 1 end
      end

      local function fireTrigger()
        if type(mouse1press) == "function" and type(mouse1release) == "function" then
          pcall(mouse1press)
          task.delay(0.03, function() pcall(mouse1release) end)
          return true
        end
        local character = localPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool and type(tool.Activate) == "function" then
          pcall(tool.Activate, tool)
          return true
        end
        return false
      end
      function state.SetTriggerBot(enabled)
        extra.Trigger.Enabled = enabled == true
        state.triggerTarget, state.nextTrigger = nil, 0
      end
      local function updateTrigger()
        if not extra.Trigger.Enabled or menuOpen == true then return end
        local focused = userInputService.GetFocusedTextBox and userInputService:GetFocusedTextBox()
        if focused then return end
        local target = nil
        if extra.Trigger.UseAimbot and extra.Aimbot.Enabled then target = state.aimbotTarget end
        local now = os.clock()
        if not target and extra.Trigger.UseSilent and cfg.Silent.Enabled and now >= (state.nextSilentTriggerScan or 0) then
          state.nextSilentTriggerScan = now + 0.1
          local selection = selectTarget()
          if selection then
            local camera = workspace.CurrentCamera
            local origin, look = camera.CFrame.Position, camera.CFrame.LookVector
            local offset = selection.part.Position - origin
            local distance = offset.Magnitude
            target = { part = selection.part, t = selection.t, source = "Silent",
              angle = distance > 0 and math.deg(math.acos(math.clamp(dot(look, offset) / distance, -1, 1))) or 0,
              visible = not extra.Trigger.RequireVisible or isTargetVisible(origin, selection.part) }
          end
        end
        if not target then state.triggerTarget = nil return end
        if extra.Trigger.RequireFOV then
          local allowed = target.source == "Aimbot" and extra.Aimbot.FOV or cfg.Silent.FOV
          if target.angle and target.angle > allowed then return end
        end
        if extra.Trigger.RequireVisible and target.visible == false then return end
        if extra.Trigger.RequireVisible and target.visible == nil then
          local camera = workspace.CurrentCamera
          if not camera or not isTargetVisible(camera.CFrame.Position, target.part) then return end
        end
        state.triggerTarget = target
        if now >= (state.nextTrigger or 0) and fireTrigger() then
          state.nextTrigger = now + math.max(0.05, tonumber(extra.Trigger.Delay) or 0.1)
          mainGame.stats.triggerShots = (mainGame.stats.triggerShots or 0) + 1
        end
      end

      -- Additional world ESP. Only enabled containers are scanned, at most once
      -- per configured interval. Entries never enter collectTargets/selectTarget.
      local function newWorldEspEntry()
        local entry = {
          box = ownDrawing("Square"), outline = ownDrawing("Square"),
          name = ownDrawing("Text"), dist = ownDrawing("Text"), s = {},
        }
        if entry.box then entry.box.Filled = false; entry.box.Thickness = 1; entry.box.Transparency = 1 end
        if entry.outline then
          entry.outline.Filled = false; entry.outline.Color = Color3.new(0, 0, 0)
          entry.outline.Thickness = 3; entry.outline.Transparency = 1
        end
        if entry.name then
          entry.name.Center = true; entry.name.Outline = true; entry.name.Size = 12; entry.name.Transparency = 1
        end
        if entry.dist then
          entry.dist.Center = true; entry.dist.Outline = true; entry.dist.Size = 11; entry.dist.Transparency = 1
        end
        return entry
      end
      local function hideWorldEntry(entry)
        updateBoxDrawing(entry, "box", entry.box, false)
        updateBoxDrawing(entry, "outline", entry.outline, false)
        updateTextDrawing(entry, "name", entry.name, false)
        updateTextDrawing(entry, "dist", entry.dist, false)
      end
      local function rootGeometry(object)
        if object:IsA("BasePart") then return object.Position, object.Size or Vector3.new(2, 2, 2) end
        local ok, pivot, size = pcall(function() return object:GetBoundingBox() end)
        if ok and pivot and size then return pivot.Position, size end
        local part = object:FindFirstChildWhichIsA("BasePart", true)
        if not part then
          for _, descendant in ipairs(object:GetDescendants()) do
            if descendant:IsA("BasePart") then part = descendant; break end
          end
        end
        if part then return part.Position, part.Size or Vector3.new(2, 2, 2) end
        return nil, nil
      end
      local function cachedWorldGeometry(object)
        local now = os.clock()
        local cached = state.worldGeometry[object]
        if cached and now < cached.next then return cached.position, cached.size end
        local position, size = rootGeometry(object)
        if position then
          state.worldGeometry[object] = {
            position = position, size = size,
            next = now + (cfg.Misc.LowPC and 0.75 or 0.25),
          }
        end
        return position, size
      end
      local function compactName(value)
        return string.lower(tostring(value or "")):gsub("[^%w]", ""):gsub("%d+$", "")
      end
      local function collectWorldEsp()
        local result, seen = {}, {}
        for _, definition in ipairs(categoryDefinitions) do
          if extra.ESP.Categories[definition.key] then
            local container = workspace:FindFirstChild(definition.container)
            if container then
              local objects
              if container:IsA("Model") and definition.container == "ActiveRaiderX" then
                objects = { container }
              else
                objects = container:GetChildren()
              end
              for _, object in ipairs(objects) do
                if (object:IsA("Model") or object:IsA("BasePart")) and not seen[object] then
                  local matches = not definition.match
                    or compactName(object.Name) == compactName(definition.match)
                  if matches then
                    seen[object] = true
                    result[#result + 1] = {
                      root = object, kind = definition.key, distance = definition.distance,
                      name = definition.container == "LootCrates" and definition.label or object.Name,
                      color = extra.ESP.Colors[definition.key],
                    }
                  end
                end
              end
            end
          end
        end
        return result
      end
      function state.SetWorldESP(key, enabled)
        extra.ESP.Categories[key] = enabled == true
        state.nextWorldEspScan = 0
        if key == "Ghost" and not enabled then table.clear(state.ghosts) end
      end
      local function updateGhosts()
        if not extra.ESP.Categories.Ghost then return end
        local now = os.clock()
        for _, player in ipairs(players:GetPlayers()) do
          if player ~= localPlayer then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local ghost = state.ghosts[player]
            if root and humanoid and humanoid.Health > 0 then
              state.ghosts[player] = {
                name = player.Name, position = root.Position, size = root.Size or Vector3.new(2, 2, 1),
                lastSeen = now, active = true,
              }
            elseif ghost then
              ghost.active = false
            end
          end
        end
        for player, ghost in pairs(state.ghosts) do
          if now - ghost.lastSeen > math.max(1, tonumber(extra.ESP.GhostTTL) or 60) then
            state.ghosts[player] = nil
          end
        end
      end
      local function worldEntriesWithGhosts()
        local result = collectWorldEsp()
        if extra.ESP.Categories.Ghost then
          updateGhosts()
          for _, ghost in pairs(state.ghosts) do
            if not ghost.active then
              result[#result + 1] = {
                kind = "Ghost", ghost = true, name = ghost.name .. " [last seen]",
                position = ghost.position, size = ghost.size,
                distance = extra.ESP.GhostMaxDistance, color = extra.ESP.Colors.Ghost,
              }
            end
          end
        end
        return result
      end
      local function renderWorldEsp(camera)
        if not anyCategoryEnabled() then
          for index = 1, state.worldEspPoolUsed or 0 do hideWorldEntry(state.worldEspPool[index]) end
          state.worldEspPoolUsed = 0
          mainGame.stats.espExtra = 0
          return
        end
        local now = os.clock()
        if not state.worldEspEntries or now >= (state.nextWorldEspScan or 0) then
          local scanInterval = math.max(0.25, tonumber(extra.ESP.ScanInterval) or 1)
          if cfg.Misc.LowPC then scanInterval = math.max(scanInterval, 2) end
          state.nextWorldEspScan = now + scanInterval
          state.worldEspEntries = worldEntriesWithGhosts()
        end
        local cameraPosition, used = camera.CFrame.Position, 0
        local previousUsed = state.worldEspPoolUsed or 0
        local targetLimit = math.max(1, tonumber(extra.ESP.MaxTargets) or 96)
        if cfg.Misc.LowPC then targetLimit = math.min(targetLimit, 32) end
        for _, resource in ipairs(state.worldEspEntries or {}) do
          if used >= targetLimit then break end
          local position, size = resource.position, resource.size
          if not position and resource.root and resource.root.Parent then
            if resource.kind == "Raider" then
              position, size = rootGeometry(resource.root)
            else
              position, size = cachedWorldGeometry(resource.root)
            end
          end
          if position and (position - cameraPosition).Magnitude <= (tonumber(resource.distance) or 1500) then
            used = used + 1
            local entry = state.worldEspPool[used]
            if not entry then entry = newWorldEspEntry(); state.worldEspPool[used] = entry end
            local halfHeight = math.max((size and size.Y or 2) * 0.5, 0.5)
            local top = camera:WorldToViewportPoint(position + Vector3.new(0, halfHeight, 0))
            local bottom = camera:WorldToViewportPoint(position - Vector3.new(0, halfHeight, 0))
            if top.Z > 0 and bottom.Z > 0 then
              local yTop, yBottom = math.min(top.Y, bottom.Y), math.max(top.Y, bottom.Y)
              local height = math.max(yBottom - yTop, 6)
              local width = math.max(height * 0.75, 8)
              local centerX = (top.X + bottom.X) * 0.5
              local x = centerX - width * 0.5
              updateBoxDrawing(entry, "outline", entry.outline, true, x, yTop, width, height)
              updateBoxDrawing(entry, "box", entry.box, true, x, yTop, width, height, resource.color)
              local text = resource.name
              if resource.kind == "Raider" and resource.root then
                local humanoid = resource.root:FindFirstChildOfClass("Humanoid")
                if humanoid then text = text .. " [" .. math.floor(humanoid.Health + 0.5) .. "]" end
              end
              updateTextDrawing(entry, "name", entry.name, true,
                centerX, yTop - 14, text, resource.color)
              updateTextDrawing(entry, "dist", entry.dist, true,
                centerX, yTop + height + 3,
                string.format("%d m", math.floor((position - cameraPosition).Magnitude + 0.5)),
                resource.color)
            else
              hideWorldEntry(entry)
            end
          end
        end
        for index = used + 1, math.max(used, previousUsed) do
          hideWorldEntry(state.worldEspPool[index])
        end
        state.worldEspPoolUsed = used
        mainGame.stats.espExtra = used
      end

      local skeletonPairs = {
        { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
        { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
        { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
        { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
        { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
        { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
        { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
      }
      local skeletonBoneNames = {}
      for _, pair in ipairs(skeletonPairs) do
        skeletonBoneNames[pair[1]] = true
        skeletonBoneNames[pair[2]] = true
      end
      local function getSkeletonBones(model)
        local now = os.clock()
        local cached = state.skeletonBones[model]
        if cached and now < cached.next then return cached.bones end
        local bones = {}
        for _, object in ipairs(model:GetDescendants()) do
          if object:IsA("BasePart") and skeletonBoneNames[object.Name] and not bones[object.Name] then
            bones[object.Name] = object
          end
        end
        state.skeletonBones[model] = {
          bones = bones, next = now + (cfg.Misc.LowPC and 1 or 0.5),
        }
        return bones
      end
      local function renderSkeleton(camera)
        local used, targetsUsed = 0, 0
        local previousUsed = state.skeletonLinesUsed or 0
        if cfg.ESP.Enabled and cfg.ESP.Skeleton and (cfg.ESP.Players or cfg.ESP.NPCs) then
          local cameraPosition = camera.CFrame.Position
          local targetLimit = cfg.Misc.LowPC and 4 or 16
          for _, target in ipairs(getCachedTargets()) do
            if targetsUsed >= targetLimit then break end
            local category = target.player and cfg.ESP.Players or cfg.ESP.NPCs
            if category and target.head and (target.head.Position - cameraPosition).Magnitude <= cfg.ESP.MaxDistance then
              targetsUsed = targetsUsed + 1
              local bones = getSkeletonBones(target.model)
              for _, pair in ipairs(skeletonPairs) do
                local first, second = bones[pair[1]], bones[pair[2]]
                if first and second and first.Parent and second.Parent then
                  local a = camera:WorldToViewportPoint(first.Position)
                  local b = camera:WorldToViewportPoint(second.Position)
                  if a.Z > 0 and b.Z > 0 then
                    used = used + 1
                    local line = state.skeletonLines[used]
                    if not line then line = ownDrawing("Line"); state.skeletonLines[used] = line end
                    local cached = state.skeletonLineStates[used]
                    if not cached then cached = {}; state.skeletonLineStates[used] = cached end
                    if line then
                      local from, to = Vector2.new(a.X, a.Y), Vector2.new(b.X, b.Y)
                      if cached.visible ~= true then cached.visible = true; line.Visible = true end
                      if cached.from ~= from then cached.from = from; line.From = from end
                      if cached.to ~= to then cached.to = to; line.To = to end
                      if cached.color ~= cfg.ESP.SkeletonColor then
                        cached.color = cfg.ESP.SkeletonColor; line.Color = cfg.ESP.SkeletonColor
                      end
                      if cached.thickness ~= cfg.ESP.SkeletonThickness then
                        cached.thickness = cfg.ESP.SkeletonThickness; line.Thickness = cfg.ESP.SkeletonThickness
                      end
                      if cached.transparency ~= 1 then cached.transparency = 1; line.Transparency = 1 end
                    end
                  end
                end
              end
            end
          end
        end
        for index = used + 1, math.max(used, previousUsed) do
          local line = state.skeletonLines[index]
          local cached = state.skeletonLineStates[index]
          if line and (not cached or cached.visible ~= false) then line.Visible = false end
          if cached then cached.visible = false end
        end
        state.skeletonLinesUsed = used
      end

      -- Crosshair: eight owned lines cover Cross/Star; Circle and Dot are
      -- separate primitives, so no external UI library is required.
      local function hsvColor(hue)
        hue = hue % 1
        local index = math.floor(hue * 6)
        local fraction = hue * 6 - index
        local q, t = 1 - fraction, fraction
        if index == 0 then return Color3.new(1, t, 0) end
        if index == 1 then return Color3.new(q, 1, 0) end
        if index == 2 then return Color3.new(0, 1, t) end
        if index == 3 then return Color3.new(0, q, 1) end
        if index == 4 then return Color3.new(t, 0, 1) end
        return Color3.new(1, 0, q)
      end
      function state.SetCrosshair(enabled)
        extra.Crosshair.Enabled = enabled == true
        state.crosshairSignature = nil
        if not extra.Crosshair.Enabled and state.crosshair and state.crosshairVisible ~= false then
          for _, object in ipairs(state.crosshair.lines) do hide(object) end
          hide(state.crosshair.circle); hide(state.crosshair.dot)
        end
        if not extra.Crosshair.Enabled then state.crosshairVisible = false end
      end
      local function updateCrosshair(camera)
        if not extra.Crosshair.Enabled then
          if state.crosshair and state.crosshairVisible ~= false then state.SetCrosshair(false) end
          return
        end
        local shape = extra.Crosshair.Shape
        local animated = extra.Crosshair.RGB or ((shape == "Cross" or shape == "Star")
          and (tonumber(extra.Crosshair.Spin) or 0) ~= 0)
        local now = os.clock()
        local color = extra.Crosshair.Color
        local viewport = camera.ViewportSize
        local signature = table.concat({
          tostring(shape), tostring(extra.Crosshair.Size), tostring(extra.Crosshair.Gap),
          tostring(extra.Crosshair.Thickness), tostring(extra.Crosshair.Spin),
          tostring(extra.Crosshair.RGB), tostring(extra.Crosshair.RGBSpeed),
          tostring(color.R), tostring(color.G), tostring(color.B),
          tostring(viewport.X), tostring(viewport.Y),
        }, ":")
        if state.crosshair and not animated and state.crosshairSignature == signature then return end
        if animated and now < (state.nextCrosshairUpdate or 0) then return end
        state.crosshairSignature = signature
        state.nextCrosshairUpdate = now + (animated and cfg.Misc.LowPC and 1 / 15 or 0)
        if not state.crosshair then
          local lines = {}
          for index = 1, 8 do lines[index] = ownDrawing("Line") end
          state.crosshair = { lines = lines, circle = ownDrawing("Circle"), dot = ownDrawing("Square") }
          if state.crosshair.circle then state.crosshair.circle.Filled = false; state.crosshair.circle.NumSides = 32 end
          if state.crosshair.dot then state.crosshair.dot.Filled = true end
        end
        local cross = state.crosshair
        local viewport = camera.ViewportSize
        local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        local color = extra.Crosshair.RGB and hsvColor(os.clock() * (tonumber(extra.Crosshair.RGBSpeed) or 5) / 10)
          or extra.Crosshair.Color
        for _, line in ipairs(cross.lines) do hide(line) end
        hide(cross.circle); hide(cross.dot)
        local shape = extra.Crosshair.Shape
        if shape == "Circle" and cross.circle then
          cross.circle.Visible = true; cross.circle.Position = center
          cross.circle.Radius = extra.Crosshair.Size; cross.circle.Thickness = extra.Crosshair.Thickness
          cross.circle.Color = color; cross.circle.Transparency = 1
        elseif shape == "Dot" and cross.dot then
          local thickness = math.max(2, extra.Crosshair.Thickness * 2)
          cross.dot.Visible = true; cross.dot.Position = Vector2.new(center.X - thickness * 0.5, center.Y - thickness * 0.5)
          cross.dot.Size = Vector2.new(thickness, thickness); cross.dot.Color = color; cross.dot.Transparency = 1
        else
          local count = shape == "Cross" and 4 or 8
          local rotation = math.rad((os.clock() * (tonumber(extra.Crosshair.Spin) or 0)) % 360)
          for index = 1, count do
            local line = cross.lines[index]
            if line then
              local angle = rotation + (index - 1) * math.pi * 2 / count
              local x, y = math.cos(angle), math.sin(angle)
              line.Visible = true
              line.From = Vector2.new(center.X + x * extra.Crosshair.Gap, center.Y + y * extra.Crosshair.Gap)
              line.To = Vector2.new(center.X + x * (extra.Crosshair.Gap + extra.Crosshair.Size),
                center.Y + y * (extra.Crosshair.Gap + extra.Crosshair.Size))
              line.Thickness = extra.Crosshair.Thickness; line.Color = color; line.Transparency = 1
            end
          end
        end
        state.crosshairVisible = true
      end

      -- Anti-Aim / Pose share one character owner. Pose has priority if a
      -- config manually enables both; normal UI callbacks make them exclusive.
      local function restoreFrozenTracks()
        for track, speed in pairs(state.frozenTracks) do
          pcall(function()
            if track.AdjustSpeed then track:AdjustSpeed(speed) else track.Speed = speed end
          end)
        end
        table.clear(state.frozenTracks)
      end
      function state.RestoreCharacterPose()
        restoreFrozenTracks()
        local backup = state.poseBackup
        if not backup then return end
        state.poseBackup = nil
        if backup.humanoid and backup.humanoid.Parent then
          pcall(function()
            backup.humanoid.AutoRotate = backup.autoRotate
            backup.humanoid.HipHeight = backup.hipHeight
          end)
        end
        if backup.root and backup.root.Parent and backup.rootCFrame then
          pcall(function()
            local position = backup.root.Position
            backup.root.CFrame = CFrame.lookAt(position, position + backup.rootCFrame.LookVector)
          end)
        end
      end
      local function preparePoseOwner(character, humanoid, root)
        if state.poseBackup and state.poseBackup.character ~= character then state.RestoreCharacterPose() end
        if not state.poseBackup then
          state.poseBackup = {
            character = character, humanoid = humanoid, root = root,
            autoRotate = humanoid.AutoRotate, hipHeight = humanoid.HipHeight, rootCFrame = root.CFrame,
          }
        end
      end
      function state.SetAntiAim(enabled)
        extra.AntiAim.Enabled = enabled == true
        if extra.AntiAim.Enabled and extra.Pose.Enabled and mainGame.Window then
          mainGame.Window:SetFeature("Pose Lock", false)
        end
        if not extra.AntiAim.Enabled and not extra.Pose.Enabled then state.RestoreCharacterPose() end
      end
      function state.SetPose(enabled)
        extra.Pose.Enabled = enabled == true
        if extra.Pose.Enabled and extra.AntiAim.Enabled and mainGame.Window then
          mainGame.Window:SetFeature("Anti-Aim", false)
        end
        if not extra.Pose.Enabled and not extra.AntiAim.Enabled then state.RestoreCharacterPose() end
      end
      local function updatePoseOwner()
        local enabled = extra.AntiAim.Enabled or extra.Pose.Enabled
        if not enabled then
          if state.poseBackup then state.RestoreCharacterPose() end
          return
        end
        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not character or not humanoid or not root or humanoid.Health <= 0 then
          if state.poseBackup then state.RestoreCharacterPose() end
          return
        end
        preparePoseOwner(character, humanoid, root)
        local backup = state.poseBackup
        humanoid.AutoRotate = false
        local camera = workspace.CurrentCamera
        local look = camera and camera.CFrame.LookVector or root.CFrame.LookVector
        local baseYaw = math.atan2(look.X, look.Z)
        if extra.Pose.Enabled then
          humanoid.HipHeight = backup.hipHeight - math.abs(tonumber(extra.Pose.Drop) or 1.5)
          local yaw = -baseYaw + math.rad(tonumber(extra.Pose.Turn) or 180)
          root.CFrame = CFrame.new(root.Position)
            * CFrame.fromEulerAnglesYXZ(math.rad(tonumber(extra.Pose.Pitch) or -10), yaw, 0)
          if humanoid.GetPlayingAnimationTracks then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
              if state.frozenTracks[track] == nil then
                state.frozenTracks[track] = track.Speed or 1
                if track.AdjustSpeed then track:AdjustSpeed(0) else track.Speed = 0 end
              end
            end
          end
        elseif extra.AntiAim.Enabled then
          humanoid.HipHeight = backup.hipHeight
          local yaw
          if extra.AntiAim.Type == "Spin" then
            yaw = -baseYaw + os.clock() * (tonumber(extra.AntiAim.SpinSpeed) or 10)
          else
            yaw = math.rad(math.random(-(tonumber(extra.AntiAim.Jitter) or 10), tonumber(extra.AntiAim.Jitter) or 10))
          end
          root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
        end
      end

      function state.SetAll(enabled)
        local value = enabled == true
        state.SetNoclip(value); state.SetAntiFall(value); state.SetAntiSpikes(value)
        state.SetCustomFOV(value); state.SetZoom(value); state.SetThirdPerson(value)
        state.SetAimbot(value); state.SetTriggerBot(value); state.SetCrosshair(value)
        state.SetAntiAim(value); state.SetPose(value)
        for _, definition in ipairs(categoryDefinitions) do state.SetWorldESP(definition.key, value) end
        state.SetWorldESP("Ghost", value)
        state.SetVegetation("Leafs", value); state.SetVegetation("Bushes", value)
      end

      trackConnection(userInputService.InputChanged:Connect(function(input)
        if not state.Active or not state.third.active or menuOpen == true then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement or not input.Delta then return end
        state.third.lookX = math.clamp((state.third.lookX or 0) + (tonumber(input.Delta.X) or 0), -500, 500)
        state.third.lookY = math.clamp((state.third.lookY or 0) + (tonumber(input.Delta.Y) or 0), -500, 500)
      end))
      trackConnection(workspace.DescendantAdded:Connect(function(object)
        if not state.Active then return end
        if extra.Movement.AntiSpikes then pcall(registerSpike, object) end
        if extra.World.RemoveLeafs then pcall(registerVegetation, "Leafs", object) end
        if extra.World.RemoveBushes then pcall(registerVegetation, "Bushes", object) end
      end))
      trackConnection(players.PlayerRemoving:Connect(function(player)
        local ghost = state.ghosts[player]
        if ghost then ghost.active = false end
        mainGame.targetList = nil
        mainGame.nextScan = 0
      end))
      trackConnection(localPlayer.CharacterRemoving:Connect(function()
        state.RestoreNoclip()
        state.RestoreCharacterPose()
        state.StopThirdPerson()
      end))

      local worldEspAccumulator = 0
      trackConnection(runService.RenderStepped:Connect(function(dt)
        if not state.Active or mainGame.unloaded then return end
        if extra.Movement.Noclip or state.noclipCharacter then updateNoclip() end
        if extra.Movement.AntiFall or state.gravityOriginal ~= nil then updateGravity() end
        if extra.Camera.CustomFOV or extra.Camera.Zoom or state.fovOriginal ~= nil then updateFOV() end
        if extra.Camera.ThirdPerson or state.third.active then updateThirdPerson() end
        if extra.Aimbot.Enabled or state.aimbotTarget then updateAimbot() end
        if extra.Trigger.Enabled then updateTrigger() end
        if extra.AntiAim.Enabled or extra.Pose.Enabled or state.poseBackup then updatePoseOwner() end
        local camera = workspace.CurrentCamera
        if camera then
          if state.aimbotFovCircle or (extra.Aimbot.Enabled and extra.Aimbot.ShowFOV) then
            updateAimbotFOV(camera)
          end
          if extra.Crosshair.Enabled or (state.crosshair and state.crosshairVisible ~= false) then
            updateCrosshair(camera)
          end
          worldEspAccumulator = worldEspAccumulator + (tonumber(dt) or 0)
          local updateInterval = cfg.Misc.LowPC and 1 / 8 or 1 / 15
          if worldEspAccumulator >= updateInterval then
            worldEspAccumulator = 0
            if anyCategoryEnabled() or (state.worldEspPoolUsed or 0) > 0 then
              renderWorldEsp(camera)
            end
            if (cfg.ESP.Enabled and cfg.ESP.Skeleton and (cfg.ESP.Players or cfg.ESP.NPCs))
              or (state.skeletonLinesUsed or 0) > 0 then
              renderSkeleton(camera)
            end
          end
        end
      end))

      mainGame.extendedCleanups[#mainGame.extendedCleanups + 1] = function()
        state.Active = false
        state.RestoreNoclip(); state.RestoreGravity(); state.RestoreSpikes()
        state.RestoreVegetation("Leafs"); state.RestoreVegetation("Bushes")
        state.RestoreFOV(); state.StopThirdPerson(); state.RestoreCharacterPose()
        for _, object in ipairs(state.owned) do hide(object) end
        table.clear(state.ghosts)
        if mainGame.extraFeatures == state then mainGame.extraFeatures = nil end
        if mainGame.unloaded then
          extra.Aimbot.Enabled = false; extra.Trigger.Enabled = false
          extra.Movement.Noclip = false; extra.Movement.AntiFall = false; extra.Movement.AntiSpikes = false
          extra.Camera.CustomFOV = false; extra.Camera.Zoom = false; extra.Camera.ThirdPerson = false
          extra.World.RemoveLeafs = false; extra.World.RemoveBushes = false
          extra.Crosshair.Enabled = false; extra.AntiAim.Enabled = false; extra.Pose.Enabled = false
          for key in pairs(extra.ESP.Categories) do extra.ESP.Categories[key] = false end
          cfg.ESP.Skeleton = false; cfg.ESP.Fade = false; cfg.ESP.VisibleOnly = false; cfg.ESP.VisibleColors = false
        end
      end
    end


    local function unloadFromMenu()
      -- Invalidate retry/async installs before any operation that can fail.
      mainGame.unloaded = true
      mainGame.hookGeneration = (mainGame.hookGeneration or 0) + 1
      if mainGame.movementCleanup then pcall(mainGame.movementCleanup) end
      mainGame.movementCleanup = nil
      mainGame.movement = nil
      if mainGame.RestoreTostring then pcall(mainGame.RestoreTostring) end
      mainGame.RestoreTostring = nil
      if cfg.Movement then
        cfg.Movement.Speed = false
        cfg.Movement.HighJump = false
        cfg.Movement.Fly = false
        cfg.Movement.InfiniteJump = false
        cfg.Movement.Freecam = false
      end
      if mainGame.hooked and mainGame.projModule and mainGame.origNew then
        local restored = pcall(function()
          mainGame.projModule.New = mainGame.origNew
        end)
        if restored then mainGame.hooked = false end
      end
      for _, connection in ipairs(mainGame.conns or {}) do
        pcall(function() connection:Disconnect() end)
      end
      mainGame.conns = {}
      cfg.Silent.Enabled = false
      cfg.ESP.Enabled = false
      cfg.ResourceESP.Enabled = false
      cfg.Misc.XRay = false
      -- Each cleanup stage is isolated: one failure must not skip the menu,
      -- drawings, lighting restore or global-reference teardown.
      pcall(function() setFullbright(false) end)
      for _, drawing in ipairs(mainGame.draws or {}) do
        pcall(function()
          if drawing.Destroy then drawing:Destroy() else drawing:Remove() end
        end)
      end
      mainGame.draws = {}
      if mainGame.gui then pcall(function() mainGame.gui:Destroy() end) end
      if windowAdapter and not windowAdapter.Destroyed then
        pcall(function() windowAdapter:Destroy() end)
      end
      mainGame.gui = nil
      mainGame.tabsBuilt = false
      mainGame.Window = nil
      mainGame.pool = {}
      mainGame.resourcePool = {}
      mainGame.resourceList = nil
      mainGame.fovCircle = nil
      mainGame.friendDropdown = nil
      if _burmaldaEnv.__mainGame == mainGame then _burmaldaEnv.__mainGame = nil end
      if _burmaldaEnv._mainGame == mainGame then _burmaldaEnv._mainGame = nil end
      pcall(function() cwarn("[MainGame] unloaded") end)
    end

    -- COMBAT: Silent Aim, Amogus targeting and weapon-module modifiers.
    do
      local lc, rc = getTab("COMBAT")
      local silentSet = createFeature(lc, "Silent Aim", cfg.Silent.Enabled, function(v)
        cfg.Silent.Enabled = v
      end)
      addSlider(silentSet, "FOV", 10, 360, cfg.Silent.FOV, function(v) cfg.Silent.FOV = v end)
      addSlider(silentSet, "Max Distance", 50, 20000, cfg.Silent.MaxDistance, function(v)
        cfg.Silent.MaxDistance = v
      end)
      addDropdown(silentSet, "Aim Part", {"Head", "Body"},
        cfg.Silent.AimPart == "Body" and 2 or 1,
        function(v) cfg.Silent.AimPart = v end)
      addBind(silentSet, "Silent Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Silent Aim", not cfg.Silent.Enabled) end
      end)
      createFeature(lc, "Team Check", cfg.Silent.TeamCheck, function(v) cfg.Silent.TeamCheck = v end)
      createFeature(lc, "Ignore Downed", cfg.Silent.IgnoreDowned, function(v)
        cfg.Silent.IgnoreDowned = v
      end)
      createFeature(lc, "Visible Only", cfg.Silent.VisibleOnly, function(v)
        cfg.Silent.VisibleOnly = v
      end)
      createFeature(lc, "Target NPCs", cfg.Silent.TargetNPCs, function(v)
        cfg.Silent.TargetNPCs = v
      end)
      createFeature(lc, "Prediction", cfg.Silent.Prediction, function(v)
        cfg.Silent.Prediction = v
      end)
      createFeature(lc, "Aim All Projectiles", cfg.Silent.AimAll, function(v)
        cfg.Silent.AimAll = v
      end)
      createFeature(lc, "Extend Throws", cfg.Silent.ExtendThrows, function(v)
        cfg.Silent.ExtendThrows = v
      end)

      local snaplineSet = createFeature(lc, "Snapline", cfg.Silent.Snapline, function(v)
        cfg.Silent.Snapline = v
      end)
      addColor(snaplineSet, "Snapline Color", function(c) cfg.Silent.SnaplineColor = c end,
        cfg.Silent.SnaplineColor)

      local fovSet = createFeature(lc, "FOV Circle", cfg.Silent.ShowFOV, function(v)
        cfg.Silent.ShowFOV = v
      end)
      addSlider(fovSet, "Thickness", 1, 10, cfg.Silent.FOVThickness, function(v)
        cfg.Silent.FOVThickness = v
      end)
      addColor(fovSet, "Circle Color", function(c) cfg.Silent.FOVColor = c end, cfg.Silent.FOVColor)
      createFeature(lc, "Dynamic FOV", cfg.Silent.DynamicFOV, function(v)
        cfg.Silent.DynamicFOV = v
      end)
      createFeature(lc, "Players First", cfg.Silent.PriorityPlayers, function(v)
        cfg.Silent.PriorityPlayers = v
      end)

      local weaponGroup = addControlGroup(rc, "Weapon Mods")
      addSlider(weaponGroup, "Recoil", 0, 100, cfg.WeaponMods.Recoil, function(v)
        cfg.WeaponMods.Recoil = v
      end)
      addSlider(weaponGroup, "Spread", 0, 100, cfg.WeaponMods.Spread, function(v)
        cfg.WeaponMods.Spread = v
      end)
      addSlider(weaponGroup, "Fire Rate", 1, 10, cfg.WeaponMods.FireRate, function(v)
        cfg.WeaponMods.FireRate = v
      end)
      createFeature(rc, "Instant Equip", cfg.WeaponMods.InstantEquip, function(v)
        cfg.WeaponMods.InstantEquip = v
      end)
      createFeature(rc, "Shoot While Sprinting", cfg.WeaponMods.ShootSprinting, function(v)
        cfg.WeaponMods.ShootSprinting = v
      end)
      createFeature(rc, "Reload While Sprinting", cfg.WeaponMods.ReloadSprinting, function(v)
        cfg.WeaponMods.ReloadSprinting = v
      end)
      createFeature(rc, "Instant Reload", cfg.WeaponMods.InstantReload, function(v)
        cfg.WeaponMods.InstantReload = v
      end)
      createFeature(rc, "Auto Reload", cfg.WeaponMods.AutoReload, function(v)
        cfg.WeaponMods.AutoReload = v
      end)
      createFeature(rc, "Fast Bow", cfg.WeaponMods.FastBow, function(v)
        cfg.WeaponMods.FastBow = v
      end)
      createFeature(rc, "Instant Eoka", cfg.WeaponMods.InstantEoka, function(v)
        cfg.WeaponMods.InstantEoka = v
      end)

      local remoteGroup = addControlGroup(rc, "Remote")
      createFeature(remoteGroup, "Block AC Checks", cfg.Remote.BlockChecks, function(v)
        cfg.Remote.BlockChecks = v
      end)
      createFeature(remoteGroup, "Block Projectile Remote", cfg.Remote.BlockProjectile, function(v)
        cfg.Remote.BlockProjectile = v
      end)
      createFeature(remoteGroup, "Block Recoil Remote", cfg.Remote.BlockRecoil, function(v)
        cfg.Remote.BlockRecoil = v
      end)

      local ignoreGroup = addControlGroup(rc, "Ignore Players")
      local ignoreApi = addMultiDropdown(ignoreGroup, "Ignore Players", getPlayerNames(),
        cfg.Silent.IgnorePlayers, function(v) cfg.Silent.IgnorePlayers = v end)
      mainGame.friendDropdown = ignoreApi
      addButton(ignoreGroup, "Ignore all players", function() ignoreApi.SelectAll() end)
      addButton(ignoreGroup, "Clear ignore list", function() ignoreApi.Clear() end)
      addButton(ignoreGroup, "Refresh player list", function() ignoreApi.Refresh(getPlayerNames()) end)
    end

    -- VISUALS: our rost-style renderer, with resources isolated from aim targets.
    do
      local lc, rc = getTab("VISUALS")
      local espSet = createFeature(lc, "ESP", cfg.ESP.Enabled, function(v) cfg.ESP.Enabled = v end)
      addSlider(espSet, "Max Distance", 100, 5000, cfg.ESP.MaxDistance, function(v)
        cfg.ESP.MaxDistance = v
      end)
      addSlider(espSet, "Update Rate Hz", 5, 144, cfg.ESP.UpdateRate, function(v)
        cfg.ESP.UpdateRate = v
      end)
      addSlider(espSet, "Max Targets", 8, 200, cfg.ESP.MaxTargets, function(v)
        cfg.ESP.MaxTargets = v
      end)
      addSlider(espSet, "Target Rescan ms", 50, 1000,
        math.floor((cfg.ESP.ScanInterval or 0.15) * 1000), function(v)
          cfg.ESP.ScanInterval = v / 1000
        end)
      addBind(espSet, "ESP Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("ESP", not cfg.ESP.Enabled) end
      end)
      createFeature(lc, "Players", cfg.ESP.Players, function(v) cfg.ESP.Players = v end)
      createFeature(lc, "ESP Team Check", cfg.ESP.TeamCheck, function(v) cfg.ESP.TeamCheck = v end)
      createFeature(lc, "NPC / Bots", cfg.ESP.NPCs, function(v) cfg.ESP.NPCs = v end)
      local boxSet = createFeature(lc, "Boxes", cfg.ESP.Box, function(v) cfg.ESP.Box = v end)
      addDropdown(boxSet, "Box Type", {"Normal", "Corner"}, cfg.ESP.BoxType == "Corner" and 2 or 1,
        function(v) cfg.ESP.BoxType = v end)
      addColor(boxSet, "Player Color", function(c) cfg.ESP.PlayerColor = c end, cfg.ESP.PlayerColor)
      addColor(boxSet, "NPC Color", function(c) cfg.ESP.NPCColor = c end, cfg.ESP.NPCColor)
      local fillSet = createFeature(lc, "Box Fill", cfg.ESP.BoxFill, function(v) cfg.ESP.BoxFill = v end)
      addSlider(fillSet, "Fill Alpha", 0, 9, math.floor(cfg.ESP.BoxFillTransparency * 10 + 0.5),
        function(v) cfg.ESP.BoxFillTransparency = v / 10 end)
      addColor(fillSet, "Fill Color", function(c) cfg.ESP.FillColor = c end, cfg.ESP.FillColor)
      local tracerSet = createFeature(lc, "Tracers", cfg.ESP.Tracers, function(v) cfg.ESP.Tracers = v end)
      addDropdown(tracerSet, "Origin", {"Top", "Bottom", "Center"},
        cfg.ESP.TracerOrigin == "Top" and 1 or cfg.ESP.TracerOrigin == "Center" and 3 or 2,
        function(v) cfg.ESP.TracerOrigin = v end)
      addColor(tracerSet, "Tracer Color", function(c) cfg.ESP.TracerColor = c end, cfg.ESP.TracerColor)
      local distanceSet = createFeature(lc, "Distance", cfg.ESP.Distance, function(v) cfg.ESP.Distance = v end)
      addColor(distanceSet, "Distance Color", function(c) cfg.ESP.DistanceColor = c end, cfg.ESP.DistanceColor)
      local weaponSet = createFeature(lc, "Weapon", cfg.ESP.Weapon, function(v) cfg.ESP.Weapon = v end)
      addColor(weaponSet, "Weapon Color", function(c) cfg.ESP.WeaponColor = c end, cfg.ESP.WeaponColor)

      local namesSet = createFeature(rc, "Names", cfg.ESP.Name, function(v) cfg.ESP.Name = v end)
      addColor(namesSet, "Name Color", function(c) cfg.ESP.NameColor = c end, cfg.ESP.NameColor)
      local hpSet = createFeature(rc, "HP Bar", cfg.ESP.Health, function(v) cfg.ESP.Health = v end)
      addDropdown(hpSet, "Position", {"Side", "Top"}, cfg.ESP.HealthBarSide == "Top" and 2 or 1,
        function(v) cfg.ESP.HealthBarSide = v end)
      addDropdown(hpSet, "Health Number", {"Off", "On"}, cfg.ESP.HealthNumber and 2 or 1,
        function(v) cfg.ESP.HealthNumber = v == "On" end)
      addDropdown(hpSet, "Dynamic Color", {"Off", "On"}, cfg.ESP.HealthDynamicColor and 2 or 1,
        function(v) cfg.ESP.HealthDynamicColor = v == "On" end)
      addColor(hpSet, "HP Color", function(c) cfg.ESP.HealthColor = c end, cfg.ESP.HealthColor)
      local chamsSet = createFeature(rc, "Chams", cfg.ESP.Chams, function(v) cfg.ESP.Chams = v end)
      addColor(chamsSet, "Chams Fill", function(c) cfg.ESP.ChamsFillColor = c end, cfg.ESP.ChamsFillColor)
      addColor(chamsSet, "Chams Outline", function(c) cfg.ESP.ChamsOutlineColor = c end,
        cfg.ESP.ChamsOutlineColor)
      addSlider(chamsSet, "Fill Alpha", 0, 9, math.floor(cfg.ESP.ChamsFillTransparency * 10 + 0.5),
        function(v) cfg.ESP.ChamsFillTransparency = v / 10 end)
      addSlider(chamsSet, "Outline Alpha", 0, 9,
        math.floor(cfg.ESP.ChamsOutlineTransparency * 10 + 0.5),
        function(v) cfg.ESP.ChamsOutlineTransparency = v / 10 end)

      local xraySet = createFeature(rc, "X-Ray", cfg.Misc.XRay, function(v)
        cfg.Misc.XRay = v
        if mainGame.amogus then mainGame.amogus.SetXRay(v) end
      end)
      addSlider(xraySet, "Transparency", 0, 9,
        math.floor(cfg.Misc.XRayTransparency * 10 + 0.5), function(v)
          if mainGame.amogus then
            mainGame.amogus.SetXRayTransparency(v / 10)
          else
            cfg.Misc.XRayTransparency = v / 10
          end
        end)
      addBind(xraySet, "X-Ray Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("X-Ray", not cfg.Misc.XRay) end
      end)

      local resourceSet = createFeature(rc, "Resource ESP", cfg.ResourceESP.Enabled,
        function(v) cfg.ResourceESP.Enabled = v end)
      addSlider(resourceSet, "Resource Distance", 100, 5000, cfg.ResourceESP.MaxDistance,
        function(v) cfg.ResourceESP.MaxDistance = v end)
      addSlider(resourceSet, "Resource Rescan ms", 250, 5000,
        math.floor(cfg.ResourceESP.ScanInterval * 1000 + 0.5),
        function(v) cfg.ResourceESP.ScanInterval = v / 1000 end)
      addSlider(resourceSet, "Max Resources", 16, 256, cfg.ResourceESP.MaxTargets,
        function(v) cfg.ResourceESP.MaxTargets = v end)
      createFeature(rc, "Resource Boxes", cfg.ResourceESP.Boxes, function(v) cfg.ResourceESP.Boxes = v end)
      createFeature(rc, "Resource Names", cfg.ResourceESP.Names, function(v) cfg.ResourceESP.Names = v end)
      createFeature(rc, "Resource Distance", cfg.ResourceESP.Distance,
        function(v) cfg.ResourceESP.Distance = v end)
      for _, kind in ipairs({"Cloth", "Iron", "Sulfur", "Stone"}) do
        local kindSet = createFeature(rc, kind, cfg.ResourceESP[kind], function(v)
          cfg.ResourceESP[kind] = v
        end)
        addColor(kindSet, kind .. " Color", function(c)
          cfg.ResourceESP[kind .. "Color"] = c
        end, cfg.ResourceESP[kind .. "Color"])
      end
      local bodyBagSet = createFeature(rc, "Body Bag", cfg.ResourceESP.BodyBag,
        function(v) cfg.ResourceESP.BodyBag = v end)
      addColor(bodyBagSet, "Body Bag Color", function(c) cfg.ResourceESP.BodyBagColor = c end,
        cfg.ResourceESP.BodyBagColor)
    end

    -- MOVEMENT: our local character controls plus recovered projectile options.
    do
      local lc, rc = getTab("MOVEMENT")
      local speedSet = createFeature(lc, "Speed", cfg.Movement.Speed, function(v)
        cfg.Movement.Speed = v
        updateMovement()
      end)
      addDropdown(speedSet, "Speed Method", {"WalkSpeed", "Velocity", "CFrame"},
        cfg.Movement.SpeedMethod == "Velocity" and 2 or cfg.Movement.SpeedMethod == "CFrame" and 3 or 1,
        function(v)
          cfg.Movement.SpeedMethod = v
          updateMovement()
        end)
      addSlider(speedSet, "Speed Value", 8, 200, cfg.Movement.SpeedValue, function(v)
        cfg.Movement.SpeedValue = v
        updateMovement()
      end)
      addBind(speedSet, "Speed Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Speed", not cfg.Movement.Speed) end
      end)
      local jumpSet = createFeature(lc, "High Jump", cfg.Movement.HighJump, function(v)
        cfg.Movement.HighJump = v
        updateMovement()
      end)
      addSlider(jumpSet, "Jump Power", 20, 150, cfg.Movement.JumpPower, function(v)
        cfg.Movement.JumpPower = v
        updateMovement()
      end)
      local flySet = createFeature(lc, "Fly", cfg.Movement.Fly, function(v)
        cfg.Movement.Fly = v
        updateMovement()
      end)
      addSlider(flySet, "Fly Speed", 10, 300, cfg.Movement.FlySpeed, function(v)
        cfg.Movement.FlySpeed = v
        updateMovement()
      end)
      addBind(flySet, "Fly Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Fly", not cfg.Movement.Fly) end
      end)
      createFeature(lc, "Infinite Jump", cfg.Movement.InfiniteJump, function(v)
        cfg.Movement.InfiniteJump = v
      end)
      addLabel(lc, "Fly: WASD + Space / LeftControl.")

      local freecamSet = createFeature(rc, "Freecam", cfg.Movement.Freecam, function(v)
        if v and cfg.Extra and cfg.Extra.Camera and cfg.Extra.Camera.ThirdPerson and mainGame.Window then
          mainGame.Window:SetFeature("Third Person", false)
        end
        cfg.Movement.Freecam = v
        if mainGame.movement then mainGame.movement.SetFreecam(v) end
      end)
      addSlider(freecamSet, "Camera Speed", 10, 300, cfg.Movement.FreecamSpeed, function(v)
        cfg.Movement.FreecamSpeed = v
      end)
      addSlider(freecamSet, "Sensitivity", 1, 10,
        math.floor(cfg.Movement.FreecamSensitivity * 10 + 0.5), function(v)
          cfg.Movement.FreecamSensitivity = v / 10
        end)
      addBind(freecamSet, "Freecam Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Freecam", not cfg.Movement.Freecam) end
      end)
      addLabel(rc, "Freecam: WASD + Space / Ctrl; Shift = fast.")
    end

    -- MISC: world lighting, performance overlay and recovered diagnostics.
    do
      local lc, rc = getTab("MISC")
      createFeature(lc, "Fullbright", cfg.Misc.Fullbright, function(v)
        cfg.Misc.Fullbright = v
        setFullbright(v)
      end)
      createFeature(rc, "Instant Loot", cfg.LocalFeatures.InstantLoot, function(v)
        cfg.LocalFeatures.InstantLoot = v
      end)
      createFeature(rc, "No Fall", cfg.LocalFeatures.NoFall, function(v)
        cfg.LocalFeatures.NoFall = v
      end)
      createFeature(rc, "Silent Walk", cfg.LocalFeatures.SilentWalk, function(v)
        cfg.LocalFeatures.SilentWalk = v
        if mainGame.amogus then mainGame.amogus.SetSilentWalk(v) end
      end)
      createFeature(lc, "Remove Grass", cfg.LocalFeatures.RemoveGrass, function(v)
        cfg.LocalFeatures.RemoveGrass = v
        if mainGame.amogus then mainGame.amogus.SetRemoveGrass(v) end
      end)
      createFeature(rc, "Detection Notifier", cfg.LocalFeatures.DetectionNotifier, function(v)
        cfg.LocalFeatures.DetectionNotifier = v
      end)
      createFeature(rc, "Keybind List", cfg.LocalFeatures.KeybindList, function(v)
        cfg.LocalFeatures.KeybindList = v
      end)
      createFeature(lc, "Low PC", cfg.Misc.LowPC, function(v)
        cfg.Misc.LowPC = v
        mainGame.nextResourceScan = 0
        if mainGame.extraFeatures then
          mainGame.extraFeatures.nextWorldEspScan = 0
          mainGame.extraFeatures.nextCrosshairUpdate = 0
        end
      end)
      createFeature(lc, "Performance Overlay", cfg.Misc.PerfOverlay, function(v)
        cfg.Misc.PerfOverlay = v
      end)
      addButton(rc, "Print debug", function()
        local currentStats = mainGame.stats
        print(string.format(
          "[MainGame] ESP=%s SA=%s | shots=%d redirected=%d | esp P=%d NPC=%d R=%d | targets=%d",
          tostring(cfg.ESP.Enabled), tostring(cfg.Silent.Enabled), currentStats.shots,
          currentStats.redirected, currentStats.espPlayers, currentStats.espNPCs,
          currentStats.espResources or 0, currentStats.targets))
        local shotTypes = {}
        for kind, count in pairs(currentStats.types or {}) do
          table.insert(shotTypes, kind .. "=" .. count)
        end
        print("[MainGame] shot types: " ..
          (#shotTypes > 0 and table.concat(shotTypes, ", ") or "none"))
        local lastAim = currentStats.lastAim or {}
        print(string.format(
          "[MainGame] lastAim: reason=%s chosen=%s nearest=%s ang=%s dist=%s type=%s model=%s error=%s",
          tostring(lastAim.reason), tostring(lastAim.chosen), tostring(lastAim.nearest),
          tostring(lastAim.nearestAng), tostring(lastAim.nearestDist), tostring(lastAim.type),
          tostring(lastAim.model), tostring(lastAim.error)))
        local silentState = mainGame.amogus
        if silentState then
          print(string.format(
            "[MainGame] ProjectileSilent: installed=%s projectile=%s shots=%d redirected=%d error=%s mode=%s targetError=%s",
            tostring(silentState.silentInstalled), tostring(mainGame.projectileDirect),
            silentState.silentShots or 0, silentState.silentRedirects or 0,
            tostring(silentState.silentError), tostring(silentState.silentMode),
            tostring(silentState.targetError)))
          print(string.format(
            "[MainGame] WeaponModules: installed=%s recoil=%s recoilPatches=%d error=%s",
            tostring(silentState.weaponInstalled), tostring(cfg.WeaponMods.Recoil),
            silentState.recoilPatches or 0, tostring(silentState.installErrors["Weapon Modules"])))
        end
        if currentStats.espError then
          print("[MainGame] ESP error: " .. tostring(currentStats.espError))
        end
      end)
      addButton(rc, "Reset aim stats", function()
        mainGame.stats = {
          shots = 0,
          redirected = 0,
          frames = mainGame.stats.frames,
          espPlayers = 0,
          espNPCs = 0,
          espResources = 0,
          targets = 0,
          localShots = 0,
        }
        local silentState = mainGame.amogus
        if silentState then
          silentState.silentShots = 0
          silentState.silentRedirects = 0
          silentState.silentRedirectAt = 0
          silentState.silentStackLevel = nil
          silentState.silentError = nil
          silentState.targetError = nil
        end
        print("[MainGame] stats reset")
      end)
      addLabel(rc, "Insert / RightShift: menu   |   F1: ESP   |   F2: Silent Aim")
    end

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
  cfg.Calamari = type(cfg.Calamari) == "table" and cfg.Calamari or {}
  local resourceCategory = {Cloth = "Wool", Iron = "Metal", Sulfur = "Phosphate", Stone = "Stone", BodyBag = "Body Bag"}
  local calamari = calamariFactory({
    Game = "Lone Survival",
    State = cfg.Calamari,
    Camera = "None",
    Lighting = false,
    IsActive = function() return not Runtime.Unloaded and not mainGame.unloaded end,
    IsLowPC = function() return cfg.Misc.LowPC == true end,
    Adapter = {
      GetTargets = function()
        local ok, targets = pcall(getCachedTargets, 0.1)
        if not ok or type(targets) ~= "table" then return nil end
        local result = {}
        for _, target in ipairs(targets) do
          if target.player and target.model and (target.hrp or target.head) then
            local playerOk, player = pcall(players.GetPlayerFromCharacter, players, target.model)
            result[#result + 1] = {
              Key = target.model, Model = target.model, Root = target.hrp or target.head,
              Humanoid = target.hum, Head = target.head, Name = target.name,
              Player = playerOk and player or nil,
            }
          end
        end
        return result
      end,
      WorldRoots = {"Deployables", "Animals", "Drops", "DroppedItems", "WorldItems", "Pickups", "SpawnedPickups", "GroundItems"},
      GetWorldEntries = function()
        local ok, resources = pcall(mainGame.getCachedResources)
        if not ok or type(resources) ~= "table" then return {} end
        local result = {}
        for _, entry in ipairs(resources) do
          local category = resourceCategory[entry.kind]
          if category and entry.root then
            result[#result + 1] = {Object = entry.root, Category = category, Name = entry.name}
          end
        end
        return result
      end,
    },
  })
  mainGame.calamariVisuals = calamari
  onCleanup(function()
    calamari.Unload()
    if mainGame.calamariVisuals == calamari then mainGame.calamariVisuals = nil end
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
  mountCalamari(calamari, {Camera = "None", Lighting = false})
end

    -- Qwerty-equivalent controls, organized into the existing five tabs.
    local extraRuntime = mainGame.extraFeatures
    do
      local lc, rc = getTab("COMBAT")
      local aimbotSet = createFeature(lc, "Aimbot", cfg.Extra.Aimbot.Enabled, function(v)
        extraRuntime.SetAimbot(v)
      end)
      addSlider(aimbotSet, "Aimbot FOV", 5, 180, cfg.Extra.Aimbot.FOV, function(v)
        cfg.Extra.Aimbot.FOV = v
      end)
      addSlider(aimbotSet, "Aimbot Max Distance", 50, 20000, cfg.Extra.Aimbot.MaxDistance, function(v)
        cfg.Extra.Aimbot.MaxDistance = v
      end)
      addSlider(aimbotSet, "Aimbot Speed", 1, 100, cfg.Extra.Aimbot.Speed, function(v)
        cfg.Extra.Aimbot.Speed = v
      end)
      addBind(aimbotSet, "Aimbot Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Aimbot", not cfg.Extra.Aimbot.Enabled) end
      end)
      createFeature(lc, "Aimbot Wall Check", cfg.Extra.Aimbot.WallCheck, function(v)
        cfg.Extra.Aimbot.WallCheck = v
      end)
      createFeature(lc, "Aimbot NPCs", cfg.Extra.Aimbot.TargetNPCs, function(v)
        cfg.Extra.Aimbot.TargetNPCs = v
      end)
      createFeature(lc, "Aimbot Players First", cfg.Extra.Aimbot.PriorityPlayers, function(v)
        cfg.Extra.Aimbot.PriorityPlayers = v
      end)
      local aimbotFovSet = createFeature(lc, "Aimbot FOV Circle", cfg.Extra.Aimbot.ShowFOV, function(v)
        cfg.Extra.Aimbot.ShowFOV = v
      end)
      addSlider(aimbotFovSet, "Aimbot FOV Thickness", 1, 10, cfg.Extra.Aimbot.FOVThickness, function(v)
        cfg.Extra.Aimbot.FOVThickness = v
      end)
      addColor(aimbotFovSet, "Aimbot FOV Color", function(c) cfg.Extra.Aimbot.FOVColor = c end,
        cfg.Extra.Aimbot.FOVColor)

      local triggerSet = createFeature(rc, "Trigger Bot", cfg.Extra.Trigger.Enabled, function(v)
        extraRuntime.SetTriggerBot(v)
      end)
      addSlider(triggerSet, "Reaction ms", 50, 1000, math.floor(cfg.Extra.Trigger.Delay * 1000 + 0.5),
        function(v) cfg.Extra.Trigger.Delay = v / 1000 end)
      addBind(triggerSet, "Trigger Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Trigger Bot", not cfg.Extra.Trigger.Enabled) end
      end)
      createFeature(rc, "Trigger Use Silent", cfg.Extra.Trigger.UseSilent, function(v)
        cfg.Extra.Trigger.UseSilent = v
      end)
      createFeature(rc, "Trigger Use Aimbot", cfg.Extra.Trigger.UseAimbot, function(v)
        cfg.Extra.Trigger.UseAimbot = v
      end)
      createFeature(rc, "Trigger Visible Only", cfg.Extra.Trigger.RequireVisible, function(v)
        cfg.Extra.Trigger.RequireVisible = v
      end)
      createFeature(rc, "Trigger Inside FOV", cfg.Extra.Trigger.RequireFOV, function(v)
        cfg.Extra.Trigger.RequireFOV = v
      end)
    end

    do
      local lc, rc = getTab("VISUALS")
      local skeletonSet = createFeature(lc, "Skeleton", cfg.ESP.Skeleton, function(v)
        cfg.ESP.Skeleton = v
      end)
      addSlider(skeletonSet, "Skeleton Thickness", 1, 5, cfg.ESP.SkeletonThickness, function(v)
        cfg.ESP.SkeletonThickness = v
      end)
      addColor(skeletonSet, "Skeleton Color", function(c) cfg.ESP.SkeletonColor = c end,
        cfg.ESP.SkeletonColor)
      createFeature(lc, "ESP Fade", cfg.ESP.Fade, function(v) cfg.ESP.Fade = v end)
      createFeature(lc, "Visible Only ESP", cfg.ESP.VisibleOnly, function(v) cfg.ESP.VisibleOnly = v end)
      createFeature(lc, "Visible Colors", cfg.ESP.VisibleColors, function(v) cfg.ESP.VisibleColors = v end)

      local advanced = addControlGroup(lc, "ESP Advanced")
      addSlider(advanced, "Box Thickness", 1, 5, cfg.ESP.BoxThickness, function(v)
        cfg.ESP.BoxThickness = v
      end)
      addSlider(advanced, "Tracer Thickness", 1, 6, cfg.ESP.TracerThickness, function(v)
        cfg.ESP.TracerThickness = v
      end)
      addSlider(advanced, "Text Scale", 5, 20, math.floor(cfg.ESP.TextScale * 10 + 0.5), function(v)
        cfg.ESP.TextScale = v / 10
      end)

      local crosshairSet = createFeature(rc, "Crosshair", cfg.Extra.Crosshair.Enabled, function(v)
        extraRuntime.SetCrosshair(v)
      end)
      addDropdown(crosshairSet, "Shape", {"Cross", "Star", "Circle", "Dot"},
        cfg.Extra.Crosshair.Shape == "Star" and 2 or cfg.Extra.Crosshair.Shape == "Circle" and 3
          or cfg.Extra.Crosshair.Shape == "Dot" and 4 or 1,
        function(v) cfg.Extra.Crosshair.Shape = v end)
      addSlider(crosshairSet, "Crosshair Size", 2, 40, cfg.Extra.Crosshair.Size, function(v)
        cfg.Extra.Crosshair.Size = v
      end)
      addSlider(crosshairSet, "Crosshair Gap", 0, 30, cfg.Extra.Crosshair.Gap, function(v)
        cfg.Extra.Crosshair.Gap = v
      end)
      addSlider(crosshairSet, "Crosshair Thickness", 1, 8, cfg.Extra.Crosshair.Thickness, function(v)
        cfg.Extra.Crosshair.Thickness = v
      end)
      addSlider(crosshairSet, "Crosshair Spin", -180, 180, cfg.Extra.Crosshair.Spin, function(v)
        cfg.Extra.Crosshair.Spin = v
      end)
      addColor(crosshairSet, "Crosshair Color", function(c) cfg.Extra.Crosshair.Color = c end,
        cfg.Extra.Crosshair.Color)
      local rgbSet = createFeature(rc, "Crosshair RGB", cfg.Extra.Crosshair.RGB, function(v)
        cfg.Extra.Crosshair.RGB = v
      end)
      addSlider(rgbSet, "RGB Speed", 1, 20, cfg.Extra.Crosshair.RGBSpeed, function(v)
        cfg.Extra.Crosshair.RGBSpeed = v
      end)

      local worldGroup = addControlGroup(rc, "World ESP")
      local worldControls = {
        { "Dropped Items ESP", "DroppedItems" },
        { "Key Drops ESP", "KeyDrops" },
        { "Offline Players ESP", "OfflinePlayers" },
        { "ToolBox ESP", "ToolBox" },
        { "Food Crate ESP", "FoodCrate" },
        { "Large Crate ESP", "LargeCrate" },
        { "Medbag ESP", "Medbag" },
        { "Military ESP", "Military" },
        { "SNTech ESP", "SNTech" },
        { "Raider X ESP", "Raider" },
      }
      for _, control in ipairs(worldControls) do
        local set = createFeature(worldGroup, control[1], cfg.Extra.ESP.Categories[control[2]], function(v)
          extraRuntime.SetWorldESP(control[2], v)
        end)
        addColor(set, control[1] .. " Color", function(c)
          cfg.Extra.ESP.Colors[control[2]] = c
        end, cfg.Extra.ESP.Colors[control[2]])
      end
      local ghostSet = createFeature(worldGroup, "Ghost ESP", cfg.Extra.ESP.Categories.Ghost, function(v)
        extraRuntime.SetWorldESP("Ghost", v)
      end)
      addSlider(ghostSet, "Ghost TTL", 5, 180, cfg.Extra.ESP.GhostTTL, function(v)
        cfg.Extra.ESP.GhostTTL = v
      end)
      addSlider(ghostSet, "Ghost Max Distance", 100, 10000, cfg.Extra.ESP.GhostMaxDistance, function(v)
        cfg.Extra.ESP.GhostMaxDistance = v
      end)
      addColor(ghostSet, "Ghost Color", function(c) cfg.Extra.ESP.Colors.Ghost = c end,
        cfg.Extra.ESP.Colors.Ghost)
      addSlider(worldGroup, "World Rescan ms", 250, 5000,
        math.floor(cfg.Extra.ESP.ScanInterval * 1000 + 0.5), function(v)
          cfg.Extra.ESP.ScanInterval = v / 1000
        end)
      addSlider(worldGroup, "World Max Targets", 16, 256, cfg.Extra.ESP.MaxTargets, function(v)
        cfg.Extra.ESP.MaxTargets = v
      end)
    end

    do
      local lc, rc = getTab("MOVEMENT")
      local noclipSet = createFeature(lc, "Noclip", cfg.Extra.Movement.Noclip, function(v)
        extraRuntime.SetNoclip(v)
      end)
      addBind(noclipSet, "Noclip Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Noclip", not cfg.Extra.Movement.Noclip) end
      end)
      local antiFallSet = createFeature(lc, "Anti-Fall", cfg.Extra.Movement.AntiFall, function(v)
        extraRuntime.SetAntiFall(v)
      end)
      addBind(antiFallSet, "Anti-Fall Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Anti-Fall", not cfg.Extra.Movement.AntiFall) end
      end)
      createFeature(lc, "Anti Spikes", cfg.Extra.Movement.AntiSpikes, function(v)
        extraRuntime.SetAntiSpikes(v)
      end)

      local fovSet = createFeature(rc, "Custom FOV", cfg.Extra.Camera.CustomFOV, function(v)
        extraRuntime.SetCustomFOV(v)
      end)
      addSlider(fovSet, "Custom FOV Value", 30, 120, cfg.Extra.Camera.FOV, function(v)
        cfg.Extra.Camera.FOV = v
      end)
      local zoomSet = createFeature(rc, "Zoom", cfg.Extra.Camera.Zoom, function(v)
        extraRuntime.SetZoom(v)
      end)
      addSlider(zoomSet, "Zoom FOV", 5, 70, cfg.Extra.Camera.ZoomFOV, function(v)
        cfg.Extra.Camera.ZoomFOV = v
      end)
      addBind(zoomSet, "Zoom Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Zoom", not cfg.Extra.Camera.Zoom) end
      end)
      local thirdSet = createFeature(rc, "Third Person", cfg.Extra.Camera.ThirdPerson, function(v)
        extraRuntime.SetThirdPerson(v)
      end)
      addSlider(thirdSet, "Camera Distance", 2, 30, cfg.Extra.Camera.Distance, function(v)
        cfg.Extra.Camera.Distance = v
      end)
      addSlider(thirdSet, "Camera Height", -5, 10, cfg.Extra.Camera.Height, function(v)
        cfg.Extra.Camera.Height = v
      end)
      addSlider(thirdSet, "Camera Side", -10, 10, cfg.Extra.Camera.Side, function(v)
        cfg.Extra.Camera.Side = v
      end)
      addSlider(thirdSet, "Camera Sensitivity", 1, 10,
        math.floor(cfg.Extra.Camera.Sensitivity * 10 + 0.5), function(v)
          cfg.Extra.Camera.Sensitivity = v / 10
        end)
      addBind(thirdSet, "Third Person Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Third Person", not cfg.Extra.Camera.ThirdPerson) end
      end)

      local antiAimSet = createFeature(lc, "Anti-Aim", cfg.Extra.AntiAim.Enabled, function(v)
        extraRuntime.SetAntiAim(v)
      end)
      addDropdown(antiAimSet, "Anti-Aim Type", {"Spin", "Jitter"},
        cfg.Extra.AntiAim.Type == "Jitter" and 2 or 1, function(v) cfg.Extra.AntiAim.Type = v end)
      addSlider(antiAimSet, "Spin Speed", 1, 50, cfg.Extra.AntiAim.SpinSpeed, function(v)
        cfg.Extra.AntiAim.SpinSpeed = v
      end)
      addSlider(antiAimSet, "Jitter Range", 0, 45, cfg.Extra.AntiAim.Jitter, function(v)
        cfg.Extra.AntiAim.Jitter = v
      end)
      local poseSet = createFeature(lc, "Pose Lock", cfg.Extra.Pose.Enabled, function(v)
        extraRuntime.SetPose(v)
      end)
      addSlider(poseSet, "Pose Drop", 0, 50, math.floor(cfg.Extra.Pose.Drop * 10 + 0.5), function(v)
        cfg.Extra.Pose.Drop = v / 10
      end)
      addSlider(poseSet, "Pose Pitch", -90, 90, cfg.Extra.Pose.Pitch, function(v)
        cfg.Extra.Pose.Pitch = v
      end)
      addSlider(poseSet, "Pose Turn", -360, 360, cfg.Extra.Pose.Turn, function(v)
        cfg.Extra.Pose.Turn = v
      end)
    end

    do
      local lc, rc = getTab("MISC")
      createFeature(lc, "Remove Leafs", cfg.Extra.World.RemoveLeafs, function(v)
        extraRuntime.SetVegetation("Leafs", v)
      end)
      createFeature(lc, "Remove Bushes", cfg.Extra.World.RemoveBushes, function(v)
        extraRuntime.SetVegetation("Bushes", v)
      end)
    end



    -- CONFIG: JSON configs plus menu presentation and lifecycle teardown.
    do
      local lc, rc = getTab("CONFIG")
      local configGroup = addControlGroup(rc, "Configs")
      local configStatus = addLabel(configGroup, "No config selected")
      local selectedConfig = nil
      local configButtons = {}
      local function refreshConfigs()
        for _, button in ipairs(configButtons) do button:Destroy() end
        configButtons = {}
        for _, name in ipairs(configApi.List()) do
          local button = addButton(configGroup, name, function()
            selectedConfig = name
            configStatus.Text = "Selected: " .. name
          end)
          configButtons[#configButtons + 1] = button
        end
      end
      addButton(lc, "Disable All Features", function()
        for featureName, enabled in pairs(featureStates) do
          if enabled and featureName ~= "Menu Accent" and featureName ~= "UI Animations" then
            local setter = _fFS[featureName]
            if setter then setter(false) end
          end
        end
      end)
      addButton(lc, "Save New Config", function()
        local name, err = configApi.Save()
        configStatus.Text = name and ("Saved: " .. name) or ("Save failed: " .. tostring(err))
        refreshConfigs()
      end)
      addButton(lc, "Load Selected Config", function()
        local ok, err = configApi.Load(selectedConfig)
        configStatus.Text = ok and ("Loaded: " .. tostring(selectedConfig))
          or ("Load failed: " .. tostring(err))
      end)
      addButton(lc, "Delete Selected Config", function()
        if selectedConfig and configApi.Delete(selectedConfig) then
          configStatus.Text = "Deleted: " .. selectedConfig
          selectedConfig = nil
          refreshConfigs()
        else
          configStatus.Text = "Delete failed / no config selected"
        end
      end)
      addButton(lc, "Refresh Configs", refreshConfigs)
      refreshConfigs()
      addButton(lc, "Unload Burmalda.hook", function() task.defer(unloadFromMenu) end)
      local accentSet = createFeature(lc, "Menu Accent", true, function() end)
      addColor(accentSet, "Accent Color", function(c) setMenuAccent(c) end, Theme.Accent)
      addDropdown(accentSet, "Preset", {"White", "Silver", "Graphite", "Blue"}, 1, function(v)
        if v == "White" then setMenuAccent(Color3.fromRGB(255, 255, 255))
        elseif v == "Silver" then setMenuAccent(Color3.fromRGB(190, 190, 190))
        elseif v == "Graphite" then setMenuAccent(Color3.fromRGB(105, 105, 105))
        else setMenuAccent(Color3.fromRGB(0, 82, 255)) end
      end)
      createFeature(lc, "UI Animations", true, function(v) UIAnimations = v end)
      addLabel(rc, "Burmalda.hook\nLone Survival / local source-structure UI\n621 x 542 / five tabs")
    end

    if menuOpen then toggleMenu() end
    windowAdapter = {
      Destroyed = false,
      Closed = not menuOpen,
    }
    function windowAdapter.Open()
      if not windowAdapter.Destroyed and not menuOpen then toggleMenu() end
    end
    function windowAdapter.Close()
      if not windowAdapter.Destroyed and menuOpen then toggleMenu() end
    end
    function windowAdapter.Toggle()
      if not windowAdapter.Destroyed then toggleMenu() end
    end
    function windowAdapter.SetFeature(_, name, value)
      local setter = _fFS[name]
      if setter and not windowAdapter.Destroyed then setter(value) end
    end
    function windowAdapter.SetToggleKey() end
    function windowAdapter.Unload()
      if not windowAdapter.Destroyed then task.defer(unloadFromMenu) end
    end
    function windowAdapter.SelectTab(_, index)
      local names = {"COMBAT", "VISUALS", "MOVEMENT", "MISC", "CONFIG"}
      if names[index] then selectTab(names[index]) end
    end
    function windowAdapter.Destroy()
      if windowAdapter.Destroyed then return end
      Runtime.Unloaded = true
      for index = #menuCleanup, 1, -1 do
        pcall(menuCleanup[index])
      end
      windowAdapter.Destroyed = true
      windowAdapter.Closed = true
      sg:Destroy()
      mainGame.tabsBuilt = false
    end

    mainGame.Window = windowAdapter
    mainGame.tabsBuilt = true
    return windowAdapter
    end, uiBuildTraceback)

    if not ok then
      mainGame.uiError = result
      mainGame.tabsBuilt = false
      local output = "[MainGame] UI build failed:\n" .. tostring(result)
      if type(warn) == "function" then pcall(warn, output) else print(output) end
      return nil
    end
    mainGame.uiError = nil
    return result
  end
  function toggleUi()
    local v213 = mainGame.Window

    if not v213 or v213.Destroyed then
      mainGame.tabsBuilt = false
      buildUi()
      return
    end

    pcall(function()
      if v213.Closed then
        v213:Open()
      else
        v213:Close()
      end
    end)
  end

  trackConnection(userInputService.InputBegan:Connect(function(input, p66)
    if p66 then
      return
    end

    if input.KeyCode == Enum.KeyCode.Insert then
      toggleUi()
    elseif input.KeyCode == Enum.KeyCode.F1 then
      cfg.ESP.Enabled = not cfg.ESP.Enabled
      if mainGame.Window and not mainGame.Window.Destroyed then
        pcall(function() mainGame.Window:SetFeature("ESP", cfg.ESP.Enabled) end)
      end
    elseif input.KeyCode == Enum.KeyCode.F2 then
      cfg.Silent.Enabled = not cfg.Silent.Enabled
      if mainGame.Window and not mainGame.Window.Destroyed then
        pcall(function() mainGame.Window:SetFeature("Silent Aim", cfg.Silent.Enabled) end)
      end
    end
  end))

  performanceLabel = nil

  function getPerformanceLabel()
    if not performanceLabel then
      performanceLabel = createTextDrawing(15, false)
      performanceLabel.Position = Vector2.new(10, 10)
      performanceLabel.Visible = false
    end

    return performanceLabel
  end

  perfFrames = 0
  perfElapsed = 0
  perfScriptTime = 0
  perfScriptSamples = 0
  perfRedraws = 0
  espAccumulator = 0

  trackConnection(runService.RenderStepped:Connect(function(delta)
    perfFrames = perfFrames + 1
    perfElapsed = perfElapsed + delta

    if perfElapsed >= 0.5 then
      local v214 = getPerformanceLabel()

      if cfg.Misc.PerfOverlay then
        local v215 = perfScriptSamples > 0 and perfScriptTime / perfScriptSamples * 1000 or 0

        v214.Text = string.format(
          "FPS %d  |  script %.3f ms  |  redraw %d/s  |  targets %d",
          math.floor(perfFrames / perfElapsed + 0.5), v215,
          math.floor(perfRedraws / perfElapsed + 0.5), mainGame.stats.targets or 0
        )

        v214.Visible = true
      elseif v214.Visible then
        v214.Visible = false
      end

      perfFrames = 0
      perfElapsed = 0
      perfScriptTime = 0
      perfScriptSamples = 0
      perfRedraws = 0
    end

    local currentCamera3 = workspace.CurrentCamera
    local fovCircleActive = cfg.Silent.Enabled and cfg.Silent.ShowFOV

    if currentCamera3 and (fovCircleActive or (mainGame.fovCircle and mainGame.fovCircle.Visible)) then
      local v216, v217 = pcall(updateFovCircle, currentCamera3)

      if not v216 then
        mainGame.stats.espError = tostring(v217)
      end
    end

    espAccumulator = espAccumulator + delta
    local effectiveESPUpdateRate = cfg.ESP.UpdateRate or 30
    if cfg.Misc.LowPC then
      effectiveESPUpdateRate = math.min(effectiveESPUpdateRate, 10)
    end

    if espAccumulator < 1 / effectiveESPUpdateRate then
      return
    else
      espAccumulator = 0
      local playerEspActive = cfg.ESP.Enabled and (cfg.ESP.Players or cfg.ESP.NPCs)
      if not playerEspActive and not cfg.ResourceESP.Enabled
        and not mainGame.playerEspRendered and not mainGame.resourceEspRendered then
        return
      end
      perfRedraws = perfRedraws + 1
      local v218 = os.clock()
      local v219, v220 = pcall(renderEsp)
      perfScriptTime = perfScriptTime + (os.clock() - v218)
      perfScriptSamples = perfScriptSamples + 1

      if not v219 then
        mainGame.stats.espError = tostring(v220)
      end

      return
    end
  end))

  buildUi()
  local v221
  v221, hookError = installProjectileHook()

  if not v221 then
    local retryGeneration = mainGame.hookGeneration
    task.spawn(function()
      while mainGame.hookGeneration == retryGeneration and not mainGame.unloaded do
        if mainGame.hooked then
          break
        end

        task.wait(2)
        if mainGame.hookGeneration ~= retryGeneration or mainGame.unloaded then
          break
        end
        local v222, v223 = installProjectileHook()
        if mainGame.hookGeneration ~= retryGeneration or mainGame.unloaded then
          break
        end

        if v222 then
          print("[MainGame] hook installed on retry")
          break
        end

        hookError = v223
      end
    end)
  end

  setFullbright(cfg.Misc.Fullbright)

  local v224 = print

  v224(string.format(
    "[MainGame] loaded | ESP:%s SilentAim:%s | hook:%s%s", tostring(cfg.ESP.Enabled),
    tostring(cfg.Silent.Enabled), tostring(v221),
    v221 and "" or " (" .. tostring(hookError) .. ")"
  ))

  getgenv()._mainGame = mainGame

  function mainGame._devinfo()
    local v225 = "esp"
    local enabled = cfg.ESP.Enabled
    local v226 = "silent"
    local enabled2 = cfg.Silent.Enabled
    local v227 = "hooked"
    local v228 = mainGame.hooked

    return {
      [v225] = enabled,
      [v226] = enabled2,
      [v227] = v228,
      stats = mainGame.stats,
      espPool = #mainGame.pool,
      window = mainGame.Window ~= nil and not mainGame.Window.Destroyed,
      tabsBuilt = mainGame.tabsBuilt,
    }
  end

  return
else
  local function triggerTamperLoop()
    while true do
      local v229 = l1
      l1 = l2
      l2 = v229
      tamperDetected()
    end
  end

  return triggerTamperLoop()
end
