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
      Enabled = true,
      Players = true,
      NPCs = true,
      MaxDistance = 1500,
      Box = true,
      BoxFill = false,
      Name = true,
      Health = true,
      Distance = true,
      Tracer = false,
      PlayerColor = Color3.fromRGB(255, 70, 70),
      NPCColor = Color3.fromRGB(255, 170, 40),
    },
    Silent = {
      Enabled = true,
      FOV = 120,
      MaxDistance = 10000,
      AimPart = "Head",
      VisibleOnly = false,
      Prediction = true,
      TargetNPCs = true,
      PriorityPlayers = true,
    },
    Misc = { PerfOverlay = true, Fullbright = true },
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
    cfg.Misc.PerfOverlay = true
  end

  if cfg.Misc.Fullbright == nil then
    cfg.Misc.Fullbright = true
  end

  if cfg.Silent.ShowFOV == nil then
    cfg.Silent.ShowFOV = true
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
    cfg.Silent.AimAll = true
  end

  if cfg.Silent.ExtendThrows == nil then
    cfg.Silent.ExtendThrows = true
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

    local v144 = math.huge
    local v145 = nil
    local v146 = math.huge
    local v147 = nil
    local cameraFov = math.clamp(tonumber(currentCamera.FieldOfView) or 70, 1, 175)
    local pixelFov = math.max(0, tonumber(cfg.Silent.FOV) or 120)
    if cfg.Silent.DynamicFOV ~= false then
      pixelFov = pixelFov * math.tan(math.rad(35)) / math.tan(math.rad(cameraFov * 0.5))
    end
    local viewportSize = currentCamera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.5)

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

            local projected, onScreen = currentCamera:WorldToViewportPoint(v150.Position)
            local screenDistance = (Vector2.new(projected.X, projected.Y) - screenCenter).Magnitude
            if onScreen and projected.Z > 0 and screenDistance <= pixelFov then
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
      local cameraFov = math.clamp(tonumber(p62.FieldOfView) or 70, 1, 175)
      local pixelFov = math.max(0, tonumber(cfg.Silent.FOV) or 120)

      -- Target selection compares screen-space distance with cfg.Silent.FOV.
      -- Keep the circle in the same pixel unit at the reference 70-degree
      -- camera instead of interpreting the slider as an angle and moving the
      -- stroke outside the viewport. Dynamic FOV still scales with camera zoom.
      local v174 = pixelFov * math.tan(math.rad(35))
        / math.tan(math.rad(cameraFov * 0.5))

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

  function getCachedTargets()
    local v204 = os.clock()

    if mainGame.targetList and v204 < (mainGame.nextScan or 0) then
      return mainGame.targetList
    end

    mainGame.nextScan = v204 + (cfg.ESP.ScanInterval or 0.15)
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
      if not ok then return names end
      for _, path in ipairs(files) do
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
      for featureName, value in pairs(decodeValue(decoded.Toggles or {})) do
        featureStates[featureName] = value
        if _fFS[featureName] then _fFS[featureName](value) end
      end
      for key, value in pairs(decoded.Options or {}) do
        local entry = optionApis[key]
        if entry and entry.Set then entry.Set(decodeValue(value)) end
      end
      for key, value in pairs(decoded.Binds or {}) do
        local entry = bindApis[key]
        if entry and entry.Set then entry.Set(value) end
      end
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
        HealthDynamicColor = true,
        HealthColor = Color3.fromRGB(80, 220, 100),
        Chams = false,
        ChamsFillColor = Color3.fromRGB(255, 70, 70),
        ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
        ChamsFillTransparency = 0.5,
        ChamsOutlineTransparency = 0.2,
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
        Boxes = true,
        Names = true,
        Distance = true,
        Cloth = true,
        Iron = true,
        Sulfur = true,
        Stone = true,
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
        mainGame.nextResourceScan = now + (cfg.ResourceESP.ScanInterval or 1)
        mainGame.resourceList = collectResources()
        return mainGame.resourceList
      end

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
        local drawingLine = false
        if drawingEsp then
          local ok, value = pcall(function() return line.From end)
          drawingLine = ok and value ~= nil
        end
        if drawingLine then
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
        if not enabled then
          if entry.chams then pcall(function() entry.chams.Enabled = false end) end
          return
        end
        if not entry.chams and not entry.chamsFailed then
          local ok, highlight = pcall(Instance.new, "Highlight")
          if not ok or not highlight then
            entry.chamsFailed = true
            return
          end
          highlight.Name = "BurmaldaHookESP"
          entry.chams = highlight
          mainGame.draws[#mainGame.draws + 1] = highlight
        end
        if entry.chams then
          pcall(function()
            local highlight = entry.chams
            highlight.Adornee = model
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = cfg.ESP.ChamsFillColor
            highlight.OutlineColor = cfg.ESP.ChamsOutlineColor
            highlight.FillTransparency = cfg.ESP.ChamsFillTransparency
            highlight.OutlineTransparency = cfg.ESP.ChamsOutlineTransparency
            if highlight.Parent ~= coreGui then highlight.Parent = coreGui end
            highlight.Enabled = true
          end)
        end
      end

      local function hideCharacterEspEntry(entry)
        hideEspEntry(entry)
        hideCorners(entry)
        updateLine(entry, "tracer", entry.tracer, false)
        updateTextDrawing(entry, "weapon", entry.weapon, false)
        updateTextDrawing(entry, "hpText", entry.hpText, false)
        updateChams(entry, false)
      end

      local function hideResourceEspEntry(entry)
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

      local function renderResourceEntries(camera, cameraPosition)
        local visibleResources = {}
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
                if #visibleResources >= (cfg.ResourceESP.MaxTargets or 128) then break end
              end
            end
          end
        end

        mainGame.stats.espResources = #visibleResources
        ensureResourcePool(#visibleResources)
        for index, entry in ipairs(mainGame.resourcePool or {}) do
          local resource = visibleResources[index]
          if not resource then
            hideResourceEspEntry(entry)
          else
            local halfHeight = math.max((resource.size and resource.size.Y or 2) * 0.5, 0.5)
            local top = camera:WorldToViewportPoint(resource.position + Vector3.new(0, halfHeight, 0))
            local bottom = camera:WorldToViewportPoint(resource.position - Vector3.new(0, halfHeight, 0))
            if top.Z > 0 and bottom.Z > 0 then
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
      end

      renderEsp = function()
        mainGame.stats.frames = mainGame.stats.frames + 1
        local camera = workspace.CurrentCamera
        if not camera then return end
        local cameraPosition = camera.CFrame.Position
        local targets = getCachedTargets()
        local visibleTargets = {}

        if cfg.ESP.Enabled then
          for _, target in ipairs(targets) do
            local categoryEnabled = target.player and cfg.ESP.Players or not target.player and cfg.ESP.NPCs
            local teamDot = target.player and target.model:FindFirstChild("TeamDot")
            local teamExcluded = target.player and cfg.ESP.TeamCheck and teamDot and teamDot.Enabled
            local head = target.head
            if categoryEnabled and not teamExcluded and head and head.Parent and target.hum and target.hum.Parent
              and target.hum.Health > 0
              and (head.Position - cameraPosition).Magnitude <= cfg.ESP.MaxDistance then
              visibleTargets[#visibleTargets + 1] = target
              if #visibleTargets >= (cfg.ESP.MaxTargets or 64) then break end
            end
          end
        end

        mainGame.stats.espPlayers = 0
        mainGame.stats.espNPCs = 0
        mainGame.stats.targets = #visibleTargets
        ensureCharacterPool(#visibleTargets)

        for index, entry in ipairs(mainGame.pool) do
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
              local yTop, yBottom = math.min(top.Y, bottom.Y), math.max(top.Y, bottom.Y)
              local height = math.max(yBottom - yTop, 4)
              local width = height * 0.6
              local centerX = (top.X + bottom.X) * 0.5
              local x = centerX - width * 0.5
              local boxColor = target.player and cfg.ESP.PlayerColor or cfg.ESP.NPCColor
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
                cfg.ESP.TracerColor, 1)

              local topHealth = cfg.ESP.Health and cfg.ESP.HealthBarSide == "Top"
              updateTextDrawing(entry, "name", entry.name, cfg.ESP.Name, centerX,
                yTop - (topHealth and 25 or 16), target.name, cfg.ESP.NameColor)

              local distanceText = string.format("%d m", math.floor(
                (head.Position - cameraPosition).Magnitude + 0.5))
              updateTextDrawing(entry, "dist", entry.dist, cfg.ESP.Distance, centerX,
                yTop + height + 3, distanceText, cfg.ESP.DistanceColor)

              local weaponName = resolveWeaponName(target.model)
              updateTextDrawing(entry, "weapon", entry.weapon, cfg.ESP.Weapon, centerX,
                yTop + height + (cfg.ESP.Distance and 18 or 3), weaponName, cfg.ESP.WeaponColor)

              if cfg.ESP.Health and target.hum then
                local ratio = target.hum.MaxHealth > 0
                  and math.clamp(target.hum.Health / target.hum.MaxHealth, 0, 1) or 0
                local healthColor = getHealthColor(ratio)
                if cfg.ESP.HealthBarSide == "Top" then
                  updateBoxDrawing(entry, "hpBg", entry.hpBg, true, x, yTop - 6, width, 3,
                    Color3.new(0, 0, 0))
                  updateBoxDrawing(entry, "hpFill", entry.hpFill, true, x, yTop - 6,
                    width * ratio, 3, healthColor)
                  updateTextDrawing(entry, "hpText", entry.hpText, cfg.ESP.HealthNumber,
                    x + width * ratio, yTop - 20, tostring(math.floor(target.hum.Health + 0.5)), healthColor)
                else
                  updateBoxDrawing(entry, "hpBg", entry.hpBg, true, x - 6, yTop, 3, height,
                    Color3.new(0, 0, 0))
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

              updateChams(entry, cfg.ESP.Chams, target.model)
            else
              hideCharacterEspEntry(entry)
            end
          end
        end

        renderResourceEntries(camera, cameraPosition)
      end

      mainGame.resourcePool = {}
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
    }
    for key, value in pairs(movementDefaults) do
      if cfg.Movement[key] == nil then cfg.Movement[key] = value end
    end

    local function updateMovement()
      if mainGame.movement and mainGame.movement.Active then
        local ok, err = pcall(mainGame.movement.Update)
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

      function movement.Update()
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
        if cfg.Movement.Speed and humanoid and cfg.Movement.SpeedMethod == "Velocity" then
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
        end
      end))
      trackConnection(localPlayer.CharacterRemoving:Connect(function(character)
        if movement.char == character then movement.Unbind() end
      end))
      movement.Bind(localPlayer.Character)
    end


    -- Amogus feature equivalents implemented against our own lifecycle and UI.
    -- No remote UI/ESP library, HTTP loader or third-party gameplay file is used.
    do
      local silentDefaults = {
        TeamCheck = false,
        IgnoreDowned = true,
        ForceHit = false,
        Hitscan = false,
        HitscanDistance = 7,
        HitscanIndicator = true,
        HitscanIndicatorColor = Color3.fromRGB(255, 196, 0),
        Snapline = false,
        SnaplineColor = Color3.fromRGB(255, 255, 255),
        DynamicFOV = true,
      }
      for key, value in pairs(silentDefaults) do
        if cfg.Silent[key] == nil then cfg.Silent[key] = value end
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
        DetectionNotifier = true,
        KeybindList = false,
      }
      for key, value in pairs(localDefaults) do
        if cfg.LocalFeatures[key] == nil then cfg.LocalFeatures[key] = value end
      end

      cfg.Remote = cfg.Remote or {}
      local remoteDefaults = { BlockChecks = true, BlockProjectile = false, BlockRecoil = true }
      for key, value in pairs(remoteDefaults) do
        if cfg.Remote[key] == nil then cfg.Remote[key] = value end
      end

      local state = {
        Active = true,
        restores = {},
        patchedWeaponModules = {},
        patchedFunctions = {},
        nextInstall = 0,
        nextTargetUpdate = 0,
        currentTarget = nil,
        detectionUntil = 0,
      }
      mainGame.amogus = state
      mainGame.extendedCleanups = mainGame.extendedCleanups or {}

      local function addRestore(callback)
        state.restores[#state.restores + 1] = callback
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

      mainGame.extendedCleanups[#mainGame.extendedCleanups + 1] = function()
        state.Active = false
        if state.crouchConnection then state.crouchConnection:Disconnect(); state.crouchConnection = nil end
        for index = #state.restores, 1, -1 do pcall(state.restores[index]) end
        state.restores = {}
        setGrassRemoved(false)
        local character = localPlayer.Character
        if character and cfg.LocalFeatures.SilentWalk then
          pcall(function() character:SetAttribute("Crouching", false) end)
        end
        if state.snapline then state.snapline.Visible = false end
        if state.hitscanText then state.hitscanText.Visible = false end
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

      local hitscanOffsets = {
        Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
        Vector3.new(1, 0, 1).Unit, Vector3.new(-1, 0, 1).Unit,
        Vector3.new(1, 0, -1).Unit, Vector3.new(-1, 0, -1).Unit, Vector3.new(0, 1, 0),
      }

      local function rayClear(origin, destination, model)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.RespectCanCollide = true
        params.IgnoreWater = true
        local ignored = workspace:FindFirstChild("Ignored")
        params.FilterDescendantsInstances = { model, workspace.CurrentCamera, localPlayer.Character, ignored }
        local result = workspace:Raycast(origin, destination - origin, params)
        return result == nil, result
      end

      local function findHitscanPosition(origin, position, model)
        local distance = cfg.Silent.HitscanDistance or 7
        for _, direction in ipairs(hitscanOffsets) do
          local offset = direction * (direction.Y ~= 0 and math.min(distance, 7.5) or distance)
          local candidate = position + offset
          local clear, obstruction = rayClear(position, candidate, model)
          if not clear and obstruction and obstruction.Distance then
            local directionTo = candidate - position
            if directionTo.Magnitude > 0.2 then
              candidate = position + directionTo.Unit * math.max(obstruction.Distance - 0.2, 0)
            end
          end
          if rayClear(origin, candidate, model) then return candidate end
        end
        return nil
      end

      local closestParts = {
        "Head", "UpperTorso", "RightHand", "RightUpperArm", "LeftHand", "LeftUpperArm",
        "RightUpperLeg", "LeftUpperLeg", "HumanoidRootPart",
      }
      local baseGetAimPart = getAimPart
      local baseSelectTarget = selectTarget
      local baseCollectTargets = collectTargets
      local baseUpdateFovCircle = updateFovCircle
      local rawCollectTargets = baseCollectTargets

      local function collectLoneTargets()
        local result = rawCollectTargets()
        local seen = {}
        for _, target in ipairs(result) do seen[target.model] = true end
        local function addModel(model, isPlayer)
          if seen[model] or not model or not model:IsA("Model") or isLocalCharacter(model) then return end
          local humanoid = model:FindFirstChildOfClass("Humanoid")
          local head = model:FindFirstChild("Head", true)
          local root = model:FindFirstChild("HumanoidRootPart", true)
            or humanoid and humanoid.RootPart
          if not humanoid or humanoid.Health <= 0 or not head then return end
          seen[model] = true
          result[#result + 1] = {
            model = model,
            name = model.Name,
            hum = humanoid,
            head = head,
            hrp = root,
            player = isPlayer == true,
          }
        end
        for _, player in ipairs(players:GetPlayers()) do
          if player ~= localPlayer then addModel(player.Character, true) end
        end
        for _, name in ipairs({"NPCs", "Bots", "Characters"}) do
          local folder = workspace:FindFirstChild(name)
          if folder then
            for _, model in ipairs(folder:GetChildren()) do
              local owner = players.GetPlayerFromCharacter and players:GetPlayerFromCharacter(model)
              addModel(model, owner ~= nil)
            end
          end
        end
        return result
      end
      collectTargets = collectLoneTargets
      baseCollectTargets = collectLoneTargets

      local function closestBodyPart(model)
        local camera = workspace.CurrentCamera
        if not camera then return nil end
        local origin = camera.CFrame.Position
        local look = camera.CFrame.LookVector
        local best, bestAngle = nil, math.huge
        for _, name in ipairs(closestParts) do
          local part = model:FindFirstChild(name)
          if part then
            local delta = part.Position - origin
            local distance = delta.Magnitude
            if distance > 0.1 then
              local angle = math.deg(math.acos(math.clamp(look:Dot(delta / distance), -1, 1)))
              if angle < bestAngle then best, bestAngle = part, angle end
            end
          end
        end
        return best
      end

      getAimPart = function(target)
        local part
        if cfg.Silent.AimPart == "Closest" then
          part = closestBodyPart(target.model)
        elseif cfg.Silent.AimPart == "Torso" or cfg.Silent.AimPart == "Body" then
          part = target.model:FindFirstChild("UpperTorso") or target.hrp or target.head
        else
          part = target.head or target.hrp
        end
        if not part then return baseGetAimPart(target) end
        target.hitscanPosition = nil
        if cfg.Silent.Hitscan then
          local origin = workspace.CurrentCamera.CFrame.Position
          if not isTargetVisible(origin, part) then
            local override = findHitscanPosition(origin, part.Position, target.model)
            if override then
              target.hitscanPosition = override
              return {
                Position = override,
                Parent = part.Parent,
                AssemblyLinearVelocity = part.AssemblyLinearVelocity,
                Size = part.Size,
                Name = part.Name,
                _realPart = part,
              }
            end
          end
        end
        return part
      end

      selectTarget = function(maxDistance)
        local previousCollect = collectTargets
        collectTargets = function()
          local result = {}
          for _, target in ipairs(baseCollectTargets()) do
            if targetAllowed(target) then result[#result + 1] = target end
          end
          return result
        end
        local results = table.pack(pcall(baseSelectTarget, maxDistance))
        collectTargets = previousCollect
        if not results[1] then error(results[2], 0) end
        local chosen, stats = results[2], results[3]
        if chosen then
          local realPart = chosen.part._realPart or chosen.part
          state.currentTarget = { part = realPart, position = chosen.part.Position, target = chosen.t }
          stats.hitscan = chosen.t.hitscanPosition ~= nil
          stats.hitscanPosition = chosen.t.hitscanPosition
        else
          state.currentTarget = nil
        end
        return chosen, stats
      end

      updateFovCircle = function(camera)
        if cfg.Silent.DynamicFOV then return baseUpdateFovCircle(camera) end
        return baseUpdateFovCircle({ ViewportSize = camera.ViewportSize, FieldOfView = 70 })
      end

      addRestore(function()
        getAimPart = baseGetAimPart
        selectTarget = baseSelectTarget
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

      local function containsInstance(list, needle)
        if type(list) ~= "table" or not needle then return false end
        for _, value in ipairs(list) do if value == needle then return true end end
        return false
      end

      local function installForceHitHook()
        if state.forceHitInstalled then return true end
        state.forceHitInstalled = hookMetatable(workspace, "__namecall", function(old, self, ...)
          if self ~= workspace or getnamecallmethod() ~= "Raycast" or checkcaller() then
            return old(self, ...)
          end
          local target = state.currentTarget
          local origin, direction, params = ...
          if not (cfg.Silent.Enabled and cfg.Silent.ForceHit and target and target.part) then
            return old(self, ...)
          end
          local shotAt = state.forceHitShotAt
          if type(shotAt) ~= "number" or os.clock() - shotAt > 0.35
            or typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
            return old(self, ...)
          end
          local shotOrigin = state.forceHitShotOrigin
          if shotOrigin and (origin - shotOrigin).Magnitude > 25 then
            return old(self, ...)
          end
          if type(params) ~= "table" or not params.IgnoreWater
            or not containsInstance(params.FilterDescendantsInstances, localPlayer.Character) then
            return old(self, ...)
          end
          local position = target.position
          return {
            Instance = target.part,
            Position = position,
            Normal = Vector3.new(0, 1, 0),
            Material = target.part.Material or Enum.Material.Plastic,
            Distance = typeof(origin) == "Vector3" and (position - origin).Magnitude
              or typeof(direction) == "Vector3" and direction.Magnitude or 0,
          }
        end)
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
        if type(fn) ~= "function" or state.patchedFunctions[fn] or not (getfenv and setfenv) then return end
        local ok, originalEnvironment = pcall(getfenv, fn)
        if not ok then return end
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
      end

      local function eachUpvalue(fn, callback)
        if not (debug and debug.getupvalues and debug.setupvalue) then return end
        for key, value in debug.getupvalues(fn) do callback(key, value) end
      end

      local function patchWeaponModule(module, recoilModule)
        if type(module) ~= "table" or state.patchedWeaponModules[module] then return end
        state.patchedWeaponModules[module] = true
        patchDelay(rawget(module, "Setup"), function() return cfg.WeaponMods.InstantEquip end)
        patchRandom(rawget(module, "TryFire"), function() return cfg.WeaponMods.InstantEoka end, true)

        local fire = rawget(module, "Fire")
        if type(fire) == "function" then
          eachUpvalue(fire, function(key, value)
            if type(value) == "function" and debug.info then
              local source = debug.info(value, "s") or ""
              local name = debug.info(value, "n") or ""
              if string.find(source, "Recoil", 1, true) and recoilModule then
                local originalRecoil = value
                local function recoilWrapper(a, b, c, d)
                  local originalFourth = d
                  if type(d) == "number" then d = d * cfg.WeaponMods.Recoil / 100 end
                  local first, second = recoilModule(a, b, c, d)
                  return first, second, originalFourth
                end
                debug.setupvalue(fire, key, recoilWrapper)
                addRestore(function() debug.setupvalue(fire, key, originalRecoil) end)
              elseif name == "GetSpreadDirection" then
                patchRandom(value, function() return cfg.WeaponMods.Spread ~= 100 end, false)
              end
            end
          end)

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
      end

      local function installWeaponModules()
        if state.weaponInstalled then return end
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
        for _, child in ipairs(viewmodel:GetChildren()) do
          if child:IsA("ModuleScript") then patchWeaponModule(safeRequire(child), recoilModule) end
        end
        state.weaponInstalled = true
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
      state.silentFallbacks = 0
      state.silentRedirectAt = 0
      state.forceHitShotAt = nil
      state.forceHitShotOrigin = nil
      state.silentError = nil
      state.silentStackLevel = nil
      state.raycastInstalled = false
      local raycastHooks = {}
      local raycastHookedFunctions = {}
      local workspaceRaycastHook = nil

      local function vectorPair(args)
        for index = 1, args.n - 1 do
          if typeof(args[index]) == "Vector3" and typeof(args[index + 1]) == "Vector3" then
            return index, index + 1
          end
        end
        return nil, nil
      end

      local function callerName()
        if type(getcallingscript) ~= "function" then return "" end
        local ok, script = pcall(getcallingscript)
        if not ok or not script then return "" end
        local okName, name = pcall(function() return script.Name end)
        return okName and string.lower(tostring(name)) or ""
      end

      local function shootingCaller(name)
        return string.find(name, "viewmodel", 1, true) ~= nil
          or string.find(name, "projectile", 1, true) ~= nil
          or string.find(name, "weapon", 1, true) ~= nil
          or string.find(name, "ballistic", 1, true) ~= nil
          or string.find(name, "crossbow", 1, true) ~= nil
          or string.find(name, "gun", 1, true) ~= nil
          or string.find(name, "tool", 1, true) ~= nil
      end

      local function nearLocalOrigin(origin)
        local camera = workspace.CurrentCamera
        if camera and (origin - camera.CFrame.Position).Magnitude <= 35 then return true end
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        return root ~= nil and (origin - root.Position).Magnitude <= 35
      end

      local function shotContext(origin, direction, modulePath)
        if direction.Magnitude < 20 then return false end
        local name = callerName()
        if shootingCaller(name) then return true end
        if name ~= "" and not modulePath then return false end
        return direction.Magnitude >= 50 and nearLocalOrigin(origin)
      end

      local function executorCall()
        if type(checkcaller) ~= "function" then return false end
        local ok, value = pcall(checkcaller)
        return ok and value == true
      end

      local function validVector(value)
        if typeof(value) ~= "Vector3" then return false end
        local magnitude = value.Magnitude
        return magnitude == magnitude and magnitude > 0.0001 and magnitude < math.huge
      end

      local function resolveShotTarget(origin)
        if not state.Active or not cfg.Silent.Enabled then return nil end
        local ok, chosen, selection = pcall(selectTarget, cfg.Silent.MaxDistance)
        if not ok then
          state.targetError = tostring(chosen)
          state.currentTarget = nil
          return nil
        end
        if not chosen or not chosen.part then
          state.currentTarget = nil
          return nil
        end
        local realPart = chosen.part._realPart or chosen.part
        if not realPart or not realPart.Parent then
          state.currentTarget = nil
          return nil
        end
        local position = chosen.t and chosen.t.hitscanPosition or chosen.part.Position
        if typeof(position) ~= "Vector3" then
          state.currentTarget = nil
          return nil
        end
        local target = {
          part = realPart,
          position = position,
          velocity = chosen.vel,
          target = chosen.t,
          selection = selection,
          hitscan = chosen.t and chosen.t.hitscanPosition ~= nil or false,
        }
        state.currentTarget = target
        return target
      end

      local function resultHitsTarget(result, target)
        if result == nil then return false end
        local ok, instance = pcall(function() return result.Instance end)
        if not ok or not instance then return false end
        if instance == target.part then return true end
        if target.target and target.target.model then
          local descendantOk, descendant = pcall(function() return instance:IsDescendantOf(target.target.model) end)
          return descendantOk and descendant
        end
        return false
      end

      local function forcedRayResult(original, target, origin)
        local result = type(original) == "table" and original or {}
        if type(original) == "table" then
          result = {}
          for key, value in pairs(original) do result[key] = value end
        end
        result.Instance = target.part
        result.Position = target.position
        result.Distance = (target.position - origin).Magnitude
        if result.Normal == nil then result.Normal = Vector3.new(0, 1, 0) end
        if result.Material == nil then
          result.Material = target.part.Material or Enum.Material.Plastic
        end
        return result
      end

      local function callRedirectedRaycast(original, args, originIndex, directionIndex, target)
        local origin = args[originIndex]
        local direction = args[directionIndex]
        local delta = target.position - origin
        if not validVector(delta) or not validVector(direction) then
          return original(table.unpack(args, 1, args.n))
        end
        local magnitude = direction.Magnitude
        args[directionIndex] = delta.Unit * magnitude
        state.forceHitShotAt = os.clock()
        state.forceHitShotOrigin = origin
        local results = table.pack(pcall(original, table.unpack(args, 1, args.n)))
        if not results[1] then error(results[2], 0) end
        if cfg.Silent.ForceHit or target.hitscan then
          if not resultHitsTarget(results[2], target) then
            results[2] = forcedRayResult(results[2], target, origin)
          elseif target.hitscan then
            local positionOk = pcall(function() results[2].Position = target.position end)
            if not positionOk then results[2] = forcedRayResult(results[2], target, origin) end
          end
        end
        return table.unpack(results, 2, results.n)
      end

      local function handleRaycast(original, modulePath, ...)
        local args = table.pack(...)
        local originIndex, directionIndex = vectorPair(args)
        if not originIndex then return original(...) end
        local origin, direction = args[originIndex], args[directionIndex]
        if not state.Active or not cfg.Silent.Enabled or executorCall()
          or not shotContext(origin, direction, modulePath) then
          return original(...)
        end
        state.silentShots = state.silentShots + 1
        state.forceHitShotAt = os.clock()
        state.forceHitShotOrigin = origin
        local target = resolveShotTarget(origin)
        if not target then
          state.silentFallbacks = state.silentFallbacks + 1
          mainGame.stats.lastAim = {reason = "no target", model = "raycast"}
          return original(...)
        end
        state.silentRedirects = state.silentRedirects + 1
        state.silentRedirectAt = os.clock()
        state.silentLastPosition = target.position
        state.silentError = nil
        mainGame.stats.redirected = mainGame.stats.redirected + 1
        mainGame.stats.lastAim = {
          reason = "redirect",
          chosen = target.target and target.target.name or "none",
          model = "raycast",
          dist = math.floor((target.position - origin).Magnitude),
          position = target.position,
        }
        return callRedirectedRaycast(original, args, originIndex, directionIndex, target)
      end

      local function restoreRaycastHooks()
        for index = #raycastHooks, 1, -1 do
          local entry = raycastHooks[index]
          pcall(entry.restore)
        end
        raycastHooks = {}
        raycastHookedFunctions = {}
        if workspaceRaycastHook then
          pcall(workspaceRaycastHook)
          workspaceRaycastHook = nil
        end
        state.raycastInstalled = false
      end

      local function hookRaycastModule(module)
        if type(module) ~= "table" then return false end
        local original = rawget(module, "Raycast")
        if type(original) ~= "function" or raycastHookedFunctions[original] then return false end
        raycastHookedFunctions[original] = true
        local oldFunction = original
        local wrapper = function(...)
          return handleRaycast(oldFunction, true, ...)
        end
        if type(hookfunction) == "function" then
          local ok, previous = pcall(hookfunction, original, wrapper)
          if ok then
            oldFunction = type(previous) == "function" and previous or original
            raycastHooks[#raycastHooks + 1] = {
              restore = function() pcall(hookfunction, wrapper, oldFunction) end,
            }
            return true
          end
        end
        local ok = pcall(function() module.Raycast = wrapper end)
        if not ok or rawget(module, "Raycast") ~= wrapper then
          raycastHookedFunctions[original] = nil
          return false
        end
        raycastHooks[#raycastHooks + 1] = {
          restore = function()
            if rawget(module, "Raycast") == wrapper then module.Raycast = original end
          end,
        }
        return true
      end

      local function installWorkspaceRaycast()
        if workspaceRaycastHook or type(hookmetamethod) ~= "function" then return false end
        local old
        local wrapper = function(self, ...)
          if self == workspace and type(getnamecallmethod) == "function"
            and getnamecallmethod() == "Raycast" and not executorCall() then
            return handleRaycast(old, false, self, ...)
          end
          return old(self, ...)
        end
        local ok, previous = pcall(hookmetamethod, game, "__namecall", newcclosure and newcclosure(wrapper) or wrapper)
        if not ok or type(previous) ~= "function" then return false end
        old = previous
        workspaceRaycastHook = function()
          pcall(hookmetamethod, game, "__namecall", previous)
        end
        return true
      end

      local function moduleCandidate(module)
        local value = safeRequire(module)
        return type(value) == "table" and rawget(value, "Raycast") and value or nil
      end

      local function installRaycastHooks()
        local installed = false
        local modules = replicatedStorage:FindFirstChild("Modules")
        local client = modules and modules:FindFirstChild("Client")
        local shared = modules and modules:FindFirstChild("Shared")
        local physics = client and client:FindFirstChild("Physics")
        local candidates = {
            modules and modules:FindFirstChild("RaycastUtil"),
            modules and modules:FindFirstChild("Raycast"),
            physics and physics:FindFirstChild("Raycast"),
            shared and shared:FindFirstChild("Raycast"),
            shared and shared:FindFirstChild("RaycastUtil"),
        }
        for _, module in ipairs(candidates) do
          if hookRaycastModule(moduleCandidate(module)) then installed = true end
        end
        if type(getgc) == "function" then
          local ok, garbage = pcall(getgc, true)
          if ok and type(garbage) == "table" then
            for _, value in pairs(garbage) do
              if type(value) == "table" and rawget(value, "Raycast") then
                if hookRaycastModule(value) then installed = true end
              end
            end
          end
        end
        if not installed and installWorkspaceRaycast() then installed = true end
        state.raycastInstalled = installed
        return installed
      end

      local function projectileAllowed(kind, stats)
        local lower = string.lower(kind)
        local function enabled(group)
          if group[kind] == true or group[lower] == true then return true end
          for key, value in pairs(group) do
            if value == true and string.lower(tostring(key)) == lower then return true end
          end
          return false
        end
        local force = enabled(cfg.Silent.ForceTypes) and stats.Velocity ~= nil
        local crosshair = enabled(cfg.Silent.CrosshairTypes) and stats.Velocity ~= nil
        local lob = enabled(cfg.Silent.LobTypes) and stats.Speed ~= nil
        local all = not force and not crosshair and not lob and stats.Velocity ~= nil and cfg.Silent.AimAll
        return force or crosshair or lob or all, force, crosshair, lob
      end

      local function redirectVector(container, key, direction)
        if type(container) ~= "table" then return false end
        local value = rawget(container, key)
        if typeof(value) ~= "Vector3" or value.Magnitude < 0.001 then return false end
        container[key] = direction.Unit * value.Magnitude
        return true
      end

      local function redirectProjectile(data)
        if type(data) ~= "table" or data.FromServer or not cfg.Silent.Enabled then return end
        local stats = rawget(data, "Stats")
        if type(stats) ~= "table" or data.ForceDown then return end
        local kind = tostring(rawget(stats, "Type"))
        local allowed, force, crosshair, lob = projectileAllowed(kind, stats)
        if not allowed then return end
        local camera = workspace.CurrentCamera
        local origin = rawget(data, "Origin") or camera and camera.CFrame.Position
        if typeof(origin) ~= "Vector3" then return end
        local target = resolveShotTarget(origin)
        mainGame.stats.lastAim = {
          reason = target and "redirect" or "no target",
          chosen = target and target.target and target.target.name or "none",
          type = kind,
          model = force and "force" or crosshair and "crosshair" or lob and "lob" or "lookvector",
        }
        if not target then return end
        local speed = lob and (tonumber(rawget(stats, "Speed")) or 0) * 0.5
          or tonumber(rawget(stats, "Velocity")) or 0
        local gravity = lob and workspace.Gravity or tonumber(rawget(stats, "Drop")) or 0
        local delta = target.position - origin
        if not validVector(delta) then return end
        local direction
        if speed > 0 then
          direction = solveBallisticDirection(origin, target.position, target.velocity, speed, gravity)
        end
        if not validVector(direction) then direction = delta.Unit end
        direction = direction.Unit
        local changed = false
        if redirectVector(data, "Direction", direction) then changed = true end
        if redirectVector(data, "Velocity", direction) then changed = true end
        if redirectVector(data, "LookVector", direction) then changed = true end
        if redirectVector(stats, "Direction", direction) then changed = true end
        if redirectVector(stats, "VelocityVector", direction) then changed = true end
        if force or crosshair or lob or cfg.Silent.AimAll then
          local distance = (target.position - origin).Magnitude
          data.ForceHitVector = origin + direction * math.max(distance + 200, 1000)
          changed = true
        end
        if not changed then return end
        state.forceHitShotAt = os.clock()
        state.forceHitShotOrigin = origin
        state.silentRedirects = state.silentRedirects + 1
        state.silentRedirectAt = os.clock()
        state.silentLastPosition = target.position
        mainGame.stats.redirected = mainGame.stats.redirected + 1
        mainGame.stats.lastAim.dist = math.floor((target.position - origin).Magnitude)
        mainGame.stats.lastAim.position = target.position
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
        local original = mainGame.hooked and mainGame.projModule == module
          and mainGame.origNew or module.New
        mainGame.projModule = module
        mainGame.origNew = original
        mainGame.hooked = false
        mainGame.projectileDirect = false
        local wrapper = function(self, data, ...)
          mainGame.stats.shots = mainGame.stats.shots + 1
          if type(data) == "table" and not data.FromServer then
            mainGame.stats.localShots = (mainGame.stats.localShots or 0) + 1
            local okRedirect, err = pcall(redirectProjectile, data)
            if not okRedirect then mainGame.stats.lastAim = {reason = "error", error = tostring(err)} end
          end
          return original(self, data, ...)
        end
        module.New = wrapper
        mainGame.projectileWrapper = wrapper
        mainGame.projectileDirect = true
        mainGame.hooked = true
        return true
      end

      local function restoreAmogusSilent()
        restoreRaycastHooks()
        state.silentInstalled = false
        state.silentMouseFunction = nil
        state.silentClone = nil
      end
      addRestore(restoreAmogusSilent)

      local function installAmogusSilent()
        if state.silentInstalled and state.raycastInstalled then return true end
        local raycastOk = installRaycastHooks()
        local projectileOk, projectileError = installProjectileHook()
        state.silentInstalled = raycastOk or projectileOk == true
        if state.silentInstalled then
          state.silentError = nil
        else
          state.silentError = tostring(projectileError or "Raycast and Projectile paths unavailable")
        end
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
        if not state.Active or not cfg.Silent.Enabled then return end
        local now = os.clock()
        if not state.silentInstalled and now >= (state.nextSilentInstallAttempt or 0) then
          state.nextSilentInstallAttempt = now + 0.5
          local ok, err = pcall(installAmogusSilent)
          if not ok then state.silentError = tostring(err) end
        end
        if now >= (state.nextSilentTargetUpdate or 0) then
          state.nextSilentTargetUpdate = now + 1 / 30
          local ok, err = pcall(selectTarget, cfg.Silent.MaxDistance)
          if not ok then
            state.currentTarget = nil
            state.targetError = tostring(err)
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
          { "Force Hit", installForceHitHook },
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
        for _, attribute in ipairs({ "NSBIP", "PlayerSettingsProcessed", "FlaggedByModerators" }) do
          trackConnection(player:GetAttributeChangedSignal(attribute):Connect(function() checkDetection(player) end))
        end
        checkDetection(player)
      end
      for _, player in ipairs(players:GetPlayers()) do bindDetection(player) end
      trackConnection(players.PlayerAdded:Connect(bindDetection))

      trackConnection(runService.RenderStepped:Connect(function()
        if not state.Active then return end
        local now = os.clock()
        if now >= state.nextInstall then
          state.nextInstall = now + 2
          pcall(installAll)
        end

        local camera = workspace.CurrentCamera
        if not camera then return end
        local needsTarget = cfg.Silent.Enabled
        if needsTarget and now >= state.nextTargetUpdate then
          state.nextTargetUpdate = now + 1 / 30
          local ok, err = pcall(selectTarget, cfg.Silent.MaxDistance)
          if not ok then state.currentTarget = nil; state.targetError = tostring(err) end
        elseif not cfg.Silent.Enabled then
          state.currentTarget = nil
        end

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

        local showHitscan = cfg.Silent.Enabled and cfg.Silent.HitscanIndicator and target
          and target.target.hitscanPosition ~= nil
        if showHitscan then
          if not state.hitscanText then state.hitscanText = createTextDrawing(13, true) end
          state.hitscanText.Text = "hitscanning"
          state.hitscanText.Color = cfg.Silent.HitscanIndicatorColor
          state.hitscanText.Position = Vector2.new(camera.ViewportSize.X * 0.5,
            camera.ViewportSize.Y * 0.5 + 43)
          state.hitscanText.Visible = true
        elseif state.hitscanText then
          state.hitscanText.Visible = false
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
      addDropdown(silentSet, "Aim Part", {"Head", "Torso", "Closest"},
        cfg.Silent.AimPart == "Torso" and 2 or cfg.Silent.AimPart == "Closest" and 3 or 1,
        function(v) cfg.Silent.AimPart = v end)
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

      local forceSet = createFeature(rc, "Force Hit", cfg.Silent.ForceHit, function(v)
        cfg.Silent.ForceHit = v
      end)
      addBind(forceSet, "Toggle Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Force Hit", not cfg.Silent.ForceHit) end
      end)
      local hitscanSet = createFeature(rc, "Hitscan", cfg.Silent.Hitscan, function(v)
        cfg.Silent.Hitscan = v
      end)
      addSlider(hitscanSet, "Hitscan Distance", 0, 20, cfg.Silent.HitscanDistance, function(v)
        cfg.Silent.HitscanDistance = v
      end)
      addBind(hitscanSet, "Toggle Bind", "None", function()
        if mainGame.Window then mainGame.Window:SetFeature("Hitscan", not cfg.Silent.Hitscan) end
      end)
      local hitscanIndicator = createFeature(rc, "Hitscan Indicator", cfg.Silent.HitscanIndicator,
        function(v) cfg.Silent.HitscanIndicator = v end)
      addColor(hitscanIndicator, "Indicator Color", function(c)
        cfg.Silent.HitscanIndicatorColor = c
      end, cfg.Silent.HitscanIndicatorColor)
      local snaplineSet = createFeature(rc, "Snapline", cfg.Silent.Snapline, function(v)
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
      createFeature(rc, "Players First", cfg.Silent.PriorityPlayers, function(v)
        cfg.Silent.PriorityPlayers = v
      end)

      local weaponGroup = addControlGroup(lc, "Weapon Mods")
      addSlider(weaponGroup, "Recoil", 0, 100, cfg.WeaponMods.Recoil, function(v)
        cfg.WeaponMods.Recoil = v
      end)
      addSlider(weaponGroup, "Spread", 0, 100, cfg.WeaponMods.Spread, function(v)
        cfg.WeaponMods.Spread = v
      end)
      addSlider(weaponGroup, "Fire Rate", 1, 10, cfg.WeaponMods.FireRate, function(v)
        cfg.WeaponMods.FireRate = v
      end)
      createFeature(lc, "Instant Equip", cfg.WeaponMods.InstantEquip, function(v)
        cfg.WeaponMods.InstantEquip = v
      end)
      createFeature(lc, "Shoot While Sprinting", cfg.WeaponMods.ShootSprinting, function(v)
        cfg.WeaponMods.ShootSprinting = v
      end)
      createFeature(lc, "Reload While Sprinting", cfg.WeaponMods.ReloadSprinting, function(v)
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

      createFeature(rc, "Block AC Checks", cfg.Remote.BlockChecks, function(v)
        cfg.Remote.BlockChecks = v
      end)
      createFeature(rc, "Block Projectile Remote", cfg.Remote.BlockProjectile, function(v)
        cfg.Remote.BlockProjectile = v
      end)
      createFeature(rc, "Block Recoil Remote", cfg.Remote.BlockRecoil, function(v)
        cfg.Remote.BlockRecoil = v
      end)

      local ignoreApi = addMultiDropdown(rc, "Ignore Players", getPlayerNames(),
        cfg.Silent.IgnorePlayers, function(v) cfg.Silent.IgnorePlayers = v end)
      mainGame.friendDropdown = ignoreApi
      addButton(rc, "Ignore all players", function() ignoreApi.SelectAll() end)
      addButton(rc, "Clear ignore list", function() ignoreApi.Clear() end)
      addButton(rc, "Refresh player list", function() ignoreApi.Refresh(getPlayerNames()) end)
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
      addDropdown(speedSet, "Speed Method", {"WalkSpeed", "Velocity"},
        cfg.Movement.SpeedMethod == "Velocity" and 2 or 1, function(v)
          cfg.Movement.SpeedMethod = v
          updateMovement()
        end)
      addSlider(speedSet, "Speed Value", 8, 100, cfg.Movement.SpeedValue, function(v)
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
      addSlider(flySet, "Fly Speed", 10, 150, cfg.Movement.FlySpeed, function(v)
        cfg.Movement.FlySpeed = v
        updateMovement()
      end)
      createFeature(lc, "Infinite Jump", cfg.Movement.InfiniteJump, function(v)
        cfg.Movement.InfiniteJump = v
      end)
      addLabel(lc, "Fly: WASD + Space up / LeftControl down. Movement restores on disable and Unload.")
      createFeature(rc, "Aim All Projectiles", cfg.Silent.AimAll, function(v)
        cfg.Silent.AimAll = v
      end)
      createFeature(rc, "Extend Throws", cfg.Silent.ExtendThrows, function(v)
        cfg.Silent.ExtendThrows = v
      end)
      addLabel(rc, "No camera rotation is added. The original Projectile.New path is preserved.")
    end

    -- MISC: world lighting, performance overlay and recovered diagnostics.
    do
      local lc, rc = getTab("MISC")
      createFeature(lc, "Fullbright", cfg.Misc.Fullbright, function(v)
        cfg.Misc.Fullbright = v
        setFullbright(v)
      end)
      createFeature(lc, "Instant Loot", cfg.LocalFeatures.InstantLoot, function(v)
        cfg.LocalFeatures.InstantLoot = v
      end)
      createFeature(lc, "No Fall", cfg.LocalFeatures.NoFall, function(v)
        cfg.LocalFeatures.NoFall = v
      end)
      createFeature(lc, "Silent Walk", cfg.LocalFeatures.SilentWalk, function(v)
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
          "[MainGame] lastAim: reason=%s chosen=%s nearest=%s ang=%s dist=%s type=%s model=%s",
          tostring(lastAim.reason), tostring(lastAim.chosen), tostring(lastAim.nearest),
          tostring(lastAim.nearestAng), tostring(lastAim.nearestDist), tostring(lastAim.type),
          tostring(lastAim.model)))
        local silentState = mainGame.amogus
        if silentState then
          print(string.format(
            "[MainGame] RaycastSilent: installed=%s raycast=%s projectile=%s shots=%d redirected=%d fallback=%d error=%s",
            tostring(silentState.silentInstalled), tostring(silentState.raycastInstalled),
            tostring(mainGame.projectileDirect), silentState.silentShots or 0,
            silentState.silentRedirects or 0, silentState.silentFallbacks or 0,
            tostring(silentState.silentError)))
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
          silentState.silentFallbacks = 0
          silentState.silentRedirectAt = 0
          silentState.silentStackLevel = nil
          silentState.silentError = nil
        end
        print("[MainGame] stats reset")
      end)
      addLabel(rc, "Insert / RightShift: menu   |   F1: ESP   |   F2: Silent Aim")
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

    if currentCamera3 then
      local v216, v217 = pcall(updateFovCircle, currentCamera3)

      if not v216 then
        mainGame.stats.espError = tostring(v217)
      end
    end

    espAccumulator = espAccumulator + delta

    if espAccumulator < 1 / (cfg.ESP.UpdateRate or 30) then
      return
    else
      espAccumulator = 0
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
