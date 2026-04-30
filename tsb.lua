--[[
    TITANIC HUB - The Strongest Battlegrounds
    Features: Auto Kill, Kill Aura, Auto Block, Auto Dash, ESP, Teleport, Fly, Fling, Speed, Infinite Jump
]]

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

-- Wait for character
repeat task.wait() until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

-- Remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:FindFirstChild("Event")
local UnreliableEvent = ReplicatedStorage:FindFirstChild("UnreliableRemoteEvent")
local RemoteFunction = ReplicatedStorage:FindFirstChild("RemoteFunction")
local Replication = ReplicatedStorage:FindFirstChild("Replication")

-- Settings
getgenv().AutoKill = false
getgenv().KillAura = false
getgenv().KillAuraRange = 50
getgenv().AutoBlock = false
getgenv().AutoDash = false
getgenv().InfiniteDash = false
getgenv().AutoUltimate = false
getgenv().AutoCombo = false
getgenv().ESP = false
getgenv().TeleportToPlayer = false
getgenv().FlyEnabled = false
getgenv().FlingEnabled = false
getgenv().SpeedHack = false
getgenv().SpeedValue = 50
getgenv().InfiniteJump = false
getgenv().NoCooldown = false
getgenv().AutoSkills = false

-- Functions
local function getChar()
    local live = workspace:FindFirstChild("Live")
    if live then
        return live:FindFirstChild(lp.Name)
    end
    return lp.Character
end

local function getHRP()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = getChar()
    return char and char:FindFirstChild("Humanoid")
end

local function getAllPlayers()
    local players = {}
    local live = workspace:FindFirstChild("Live")
    if live then
        for _, v in ipairs(live:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if v.Name ~= lp.Name and not v:GetAttribute("NPC") and not v:GetAttribute("RealDummy") then
                    local hum = v:FindFirstChild("Humanoid")
                    if hum.Health > 0 then
                        table.insert(players, v)
                    end
                end
            end
        end
    end
    return players
end

local function getNearestPlayer(range)
    local nearest = nil
    local minDist = range or math.huge
    local hrp = getHRP()
    if not hrp then return nil end
    
    for _, v in ipairs(getAllPlayers()) do
        local vhrp = v:FindFirstChild("HumanoidRootPart")
        if vhrp then
            local dist = (hrp.Position - vhrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = v
            end
        end
    end
    return nearest
end

local function getNearestDummy(range)
    local nearest = nil
    local minDist = range or math.huge
    local hrp = getHRP()
    if not hrp then return nil end
    
    local live = workspace:FindFirstChild("Live")
    if live then
        for _, v in ipairs(live:GetChildren()) do
            if v:IsA("Model") and (v:GetAttribute("NPC") or v:GetAttribute("RealDummy")) then
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    local vhrp = v:FindFirstChild("HumanoidRootPart")
                    if vhrp and hrp then
                        local dist = (hrp.Position - vhrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = v
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- Attack function (M1)
local lastM1 = 0
local function doM1()
    if os.clock() - lastM1 < 0.15 then return end
    lastM1 = os.clock()
    
    local char = getChar()
    if not char then return end
    
    -- Fire M1 through character's Communicate remote
    local communicate = char:FindFirstChild("Communicate")
    if communicate and communicate:IsA("RemoteEvent") then
        pcall(function()
            communicate:FireServer("M1")
        end)
    end
    
    -- Try main Event remote
    if Event then
        pcall(function()
            Event:FireServer("M1")
        end)
    end
end

-- Block function
local function toggleBlock(enable)
    local char = getChar()
    if not char then return end
    
    pcall(function()
        char:SetAttribute("Blocking", enable)
    end)
    
    local communicate = char:FindFirstChild("Communicate")
    if communicate and communicate:IsA("RemoteEvent") then
        pcall(function()
            communicate:FireServer(enable and "Block" or "Unblock")
        end)
    end
end

-- Dash function
local lastDash = 0
local function doDash(direction)
    if not getgenv().InfiniteDash and os.clock() - lastDash < 0.5 then return end
    lastDash = os.clock()
    
    local char = getChar()
    if not char then return end
    
    local hrp = getHRP()
    if not hrp then return end
    
    local dashDir = direction or "Front"
    
    local communicate = char:FindFirstChild("Communicate")
    if communicate and communicate:IsA("RemoteEvent") then
        pcall(function()
            communicate:FireServer("Dash", dashDir)
        end)
    end
    
    -- Manual dash velocity
    pcall(function()
        local hum = getHum()
        if hum then
            local vel = Vector3.new(0, 0, 0)
            local rootCF = hrp.CFrame
            if dashDir == "Front" then
                vel = rootCF.LookVector * 100
            elseif dashDir == "Back" then
                vel = -rootCF.LookVector * 100
            elseif dashDir == "Left" then
                vel = -rootCF.RightVector * 100
            elseif dashDir == "Right" then
                vel = rootCF.RightVector * 100
            end
            hrp.Velocity = vel
        end
    end)
end

-- Ultimate function
local function doUltimate()
    local char = getChar()
    if not char then return end
    
    local communicate = char:FindFirstChild("Communicate")
    if communicate and communicate:IsA("RemoteEvent") then
        pcall(function()
            communicate:FireServer("Ultimate")
        end)
    end
    
    if Event then
        pcall(function()
            Event:FireServer("Ultimate")
        end)
    end
end

-- ESP
local espObjects = {}
local function updateESP()
    -- Clear old ESP
    for _, obj in ipairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    if not getgenv().ESP then return end
    
    for _, player in ipairs(getAllPlayers()) do
        local hrp = player:FindFirstChild("HumanoidRootPart")
        local head = player:FindFirstChild("Head")
        if hrp and head then
            -- Billboard
            local bb = Instance.new("BillboardGui")
            bb.Name = "ESP"
            bb.Size = UDim2.new(0, 200, 0, 50)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = head
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.Parent = bb
            
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(1, 0, 0.6, 0)
            name.Text = player.Name
            name.TextColor3 = Color3.fromRGB(255, 255, 255)
            name.TextScaled = true
            name.BackgroundTransparency = 1
            name.Parent = frame
            
            local health = Instance.new("TextLabel")
            health.Size = UDim2.new(1, 0, 0.4, 0)
            health.Position = UDim2.new(0, 0, 0.6, 0)
            health.Text = "HP: " .. math.floor(player.Humanoid.Health)
            health.TextColor3 = Color3.fromRGB(0, 255, 0)
            health.TextScaled = true
            health.BackgroundTransparency = 1
            health.Parent = frame
            
            -- Highlight
            local hl = Instance.new("Highlight")
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = player
            
            table.insert(espObjects, bb)
            table.insert(espObjects, hl)
        end
    end
end

-- Fly
local flyBodyVel, flyBodyGyro
local function toggleFly(enable)
    local hrp = getHRP()
    if not hrp then return end
    
    if enable then
        -- BodyVelocity
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVel.Velocity = Vector3.new(0, 0, 0)
        flyBodyVel.Parent = hrp
        
        -- BodyGyro
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp
    else
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    end
end

-- Fling
local function flingPlayer(target)
    local targetHRP = target and target:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    local hrp = getHRP()
    if not hrp then return end
    
    -- Move to target
    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
    task.wait(0.1)
    
    -- Apply fling force
    local attach0 = Instance.new("Attachment")
    attach0.Parent = hrp
    local attach1 = Instance.new("Attachment")
    attach1.Parent = targetHRP
    
    local fling = Instance.new("AlignPosition")
    fling.Attachment0 = attach0
    fling.Attachment1 = attach1
    fling.MaxForce = 999999
    fling.MaxVelocity = 9999
    fling.Responsiveness = 200
    fling.Parent = hrp
    
    task.wait(0.1)
    fling:Destroy()
    attach0:Destroy()
    attach1:Destroy()
end

-- Teleport to player
local function teleportToTarget(target)
    local targetHRP = target and target:FindFirstChild("HumanoidRootPart")
    local hrp = getHRP()
    if not targetHRP or not hrp then return end
    
    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
end

-- ================ RAYFIELD UI ================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TITANIC HUB - TSB",
    Icon = 4483362458,
    LoadingTitle = "TITANIC HUB",
    LoadingSubtitle = "The Strongest Battlegrounds",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = {Enabled = true, FolderName = "THUB/tsb", FileName = "config"},
    KeySystem = false,
})

local MainTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- ====== COMBAT TAB ======
MainTab:CreateSection("Auto Combat")

MainTab:CreateToggle({
    Name = "Auto Kill (Nearest Player)", CurrentValue = false, Flag = "AutoKillToggle",
    Callback = function(v) getgenv().AutoKill = v end,
})

MainTab:CreateToggle({
    Name = "Kill Aura", CurrentValue = false, Flag = "KillAuraToggle",
    Callback = function(v) getgenv().KillAura = v end,
})

MainTab:CreateSlider({
    Name = "Kill Aura Range", Range = {10, 200}, Increment = 1, CurrentValue = 50, Flag = "KillAuraRange",
    Callback = function(v) getgenv().KillAuraRange = v end,
})

MainTab:CreateToggle({
    Name = "Auto Combo (M1 Spam)", CurrentValue = false, Flag = "AutoComboToggle",
    Callback = function(v) getgenv().AutoCombo = v end,
})

MainTab:CreateToggle({
    Name = "Auto Ultimate", CurrentValue = false, Flag = "AutoUltimateToggle",
    Callback = function(v) getgenv().AutoUltimate = v end,
})

MainTab:CreateToggle({
    Name = "Auto Skills/Moves", CurrentValue = false, Flag = "AutoSkillsToggle",
    Callback = function(v) getgenv().AutoSkills = v end,
})

MainTab:CreateSection("Defense")

MainTab:CreateToggle({
    Name = "Auto Block", CurrentValue = false, Flag = "AutoBlockToggle",
    Callback = function(v)
        getgenv().AutoBlock = v
        if not v then toggleBlock(false) end
    end,
})

MainTab:CreateSection("Misc")

MainTab:CreateToggle({
    Name = "No Cooldown", CurrentValue = false, Flag = "NoCooldownToggle",
    Callback = function(v) getgenv().NoCooldown = v end,
})

MainTab:CreateButton({
    Name = "Kill Nearest Player",
    Callback = function()
        local nearest = getNearestPlayer(200)
        if nearest then
            teleportToTarget(nearest)
            for i = 1, 30 do
                doM1()
                task.wait(0.1)
            end
        end
    end,
})

MainTab:CreateButton({
    Name = "Fling Nearest Player",
    Callback = function()
        local nearest = getNearestPlayer(200)
        if nearest then
            flingPlayer(nearest)
        end
    end,
})

-- ====== MOVEMENT TAB ======
MovementTab:CreateSection("Movement")

MovementTab:CreateToggle({
    Name = "Auto Dash", CurrentValue = false, Flag = "AutoDashToggle",
    Callback = function(v) getgenv().AutoDash = v end,
})

MovementTab:CreateToggle({
    Name = "Infinite Dash", CurrentValue = false, Flag = "InfiniteDashToggle",
    Callback = function(v) getgenv().InfiniteDash = v end,
})

MovementTab:CreateDropdown({
    Name = "Dash Direction", Options = {"Front", "Back", "Left", "Right"}, CurrentOption = "Front", Flag = "DashDirection",
})

MovementTab:CreateToggle({
    Name = "Fly", CurrentValue = false, Flag = "FlyToggle",
    Callback = function(v)
        getgenv().FlyEnabled = v
        toggleFly(v)
    end,
})

MovementTab:CreateToggle({
    Name = "Infinite Jump", CurrentValue = false, Flag = "InfiniteJumpToggle",
    Callback = function(v) getgenv().InfiniteJump = v end,
})

MovementTab:CreateToggle({
    Name = "Speed Hack", CurrentValue = false, Flag = "SpeedToggle",
    Callback = function(v)
        getgenv().SpeedHack = v
        local hum = getHum()
        if hum then
            hum.WalkSpeed = v and getgenv().SpeedValue or 16
        end
    end,
})

MovementTab:CreateSlider({
    Name = "Speed Value", Range = {16, 200}, Increment = 1, CurrentValue = 50, Flag = "SpeedSlider",
    Callback = function(v)
        getgenv().SpeedValue = v
        if getgenv().SpeedHack then
            local hum = getHum()
            if hum then hum.WalkSpeed = v end
        end
    end,
})

MovementTab:CreateToggle({
    Name = "Teleport to Nearest Player", CurrentValue = false, Flag = "TeleportToggle",
    Callback = function(v)
        getgenv().TeleportToPlayer = v
    end,
})

-- ====== VISUAL TAB ======
VisualTab:CreateSection("ESP")

VisualTab:CreateToggle({
    Name = "ESP", CurrentValue = false, Flag = "ESPToggle",
    Callback = function(v)
        getgenv().ESP = v
        updateESP()
    end,
})

-- ====== SETTINGS TAB ======
SettingsTab:CreateSection("Settings")
SettingsTab:CreateKeybind({
    Name = "Toggle UI", CurrentKeybind = "RightControl", HoldToInteract = false, Flag = "MenuKeybind",
})

-- ====== MAIN LOOPS ======
-- Auto Kill / Kill Aura Loop
task.spawn(function()
    while true do
        if getgenv().AutoKill or getgenv().KillAura then
            local target = nil
            if getgenv().AutoKill then
                target = getNearestPlayer(200)
            elseif getgenv().KillAura then
                target = getNearestPlayer(getgenv().KillAuraRange)
            end
            
            -- Also target dummy if no players
            if not target then
                target = getNearestDummy(100)
            end
            
            if target then
                -- Teleport if needed
                local hrp = getHRP()
                local targetHRP = target:FindFirstChild("HumanoidRootPart")
                if hrp and targetHRP then
                    local dist = (hrp.Position - targetHRP.Position).Magnitude
                    if dist > 15 then
                        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                    end
                end
                
                -- Attack
                doM1()
                
                -- Auto Ultimate
                if getgenv().AutoUltimate then
                    local char = getChar()
                    if char then
                        local ultimateTime = char:GetAttribute("UltimateTime") or 0
                        if ultimateTime <= 0 then
                            doUltimate()
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)

-- Auto Block Loop
task.spawn(function()
    while true do
        if getgenv().AutoBlock then
            local nearest = getNearestPlayer(20)
            if nearest and not getgenv().AutoDash then
                -- Enemy is close, block
                toggleBlock(true)
                task.wait(0.5)
                toggleBlock(false)
                doDash("Front")
            end
        end
        task.wait(0.1)
    end
end)

-- Auto Dash Loop
task.spawn(function()
    while true do
        if getgenv().AutoDash then
            local nearest = getNearestPlayer(getgenv().KillAuraRange)
            if nearest then
                doDash(Rayfield.Flags.DashDirection.CurrentOption)
            end
        end
        task.wait(getgenv().InfiniteDash and 0.1 or 1)
    end
end)

-- Teleport Loop
task.spawn(function()
    while true do
        if getgenv().TeleportToPlayer then
            local nearest = getNearestPlayer(200)
            if nearest then
                teleportToTarget(nearest)
            end
        end
        task.wait(0.5)
    end
end)

-- ESP Update Loop
task.spawn(function()
    while true do
        if getgenv().ESP then
            updateESP()
        end
        task.wait(2)
    end
end)

-- Fly Control
UserInputService.JumpRequest:Connect(function()
    if getgenv().FlyEnabled and flyBodyVel then
        flyBodyVel.Velocity = Vector3.new(0, 50, 0)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJump then
        local hum = getHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Mobile touch controls for fly
task.spawn(function()
    while true do
        if getgenv().FlyEnabled and flyBodyVel and flyBodyGyro then
            local hrp = getHRP()
            if hrp then
                local moveDir = Vector3.new(0, 0, 0)
                
                -- Check virtual keys for mobile
                if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService.TouchEnabled then
                    moveDir = moveDir + hrp.CFrame.LookVector * 2
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - hrp.CFrame.LookVector * 2
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - hrp.CFrame.RightVector * 2
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + hrp.CFrame.RightVector * 2
                end
                
                if moveDir.Magnitude > 0 then
                    flyBodyVel.Velocity = moveDir * 50
                else
                    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
                end
                flyBodyGyro.CFrame = hrp.CFrame
            end
        end
        task.wait()
    end
end)

-- Cleanup on teleport
local oldChar
task.spawn(function()
    while true do
        local char = getChar()
        if char ~= oldChar then
            oldChar = char
            if getgenv().FlyEnabled then
                toggleFly(false)
                task.wait(0.5)
                toggleFly(true)
            end
            if getgenv().ESP then
                updateESP()
            end
        end
        task.wait(1)
    end
end)

Rayfield:Notify({
    Title = "TITANIC HUB",
    Content = "TSB Script Loaded! Check tabs for features.",
    Duration = 5,
    Image = 4483362458,
})

Rayfield:LoadConfiguration()
