-- TITANIC HUB TSB - Perma Attach + Auto Attack
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

repeat task.wait() until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

-- Remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:FindFirstChild("Event")

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
                if v.Name ~= lp.Name and v.Humanoid.Health > 0 then
                    table.insert(players, v)
                end
            end
        end
    end
    return players
end

-- Settings
getgenv().AttachEnabled = false
getgenv().AttachTarget = nil
getgenv().AttachPosition = "Back" -- Back, Front, Left, Right
getgenv().AttachDistance = 4
getgenv().AutoAttack = false
getgenv().AttackSpeed = 0.15 -- Seconds between M1s

-- Attack function
local lastM1 = 0
local function doM1()
    if os.clock() - lastM1 < getgenv().AttackSpeed then return end
    lastM1 = os.clock()
    
    local char = getChar()
    if not char then return end
    
    -- Method 1: Communicate remote
    local communicate = char:FindFirstChild("Communicate")
    if communicate and communicate:IsA("RemoteEvent") then
        pcall(function()
            communicate:FireServer("M1")
        end)
    end
    
    -- Method 2: Direct Event
    if Event then
        pcall(function()
            Event:FireServer("M1")
        end)
    end
    
    -- Method 3: Attribute trick
    pcall(function()
        char:SetAttribute("M1Ready", true)
        char:SetAttribute("HoldingM1", true)
    end)
end

-- Main Attach Loop - Force lock
local attachConnection
local function toggleAttach(enable)
    getgenv().AttachEnabled = enable
    
    if enable then
        -- Disable character movement
        local hum = getHum()
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
        end
        
        attachConnection = RunService.Stepped:Connect(function()
            if not getgenv().AttachEnabled then return end
            
            local target = getgenv().AttachTarget
            if not target then return end
            
            local targetHRP = target:FindFirstChild("HumanoidRootPart")
            local myHRP = getHRP()
            
            if not targetHRP or not myHRP then return end
            
            -- Calculate position based on side
            local targetCF = targetHRP.CFrame
            local offset = Vector3.new(0, 0, 0)
            
            if getgenv().AttachPosition == "Back" then
                offset = Vector3.new(0, 0, -getgenv().AttachDistance)
            elseif getgenv().AttachPosition == "Front" then
                offset = Vector3.new(0, 0, getgenv().AttachDistance)
            elseif getgenv().AttachPosition == "Left" then
                offset = Vector3.new(-getgenv().AttachDistance, 0, 0)
            elseif getgenv().AttachPosition == "Right" then
                offset = Vector3.new(getgenv().AttachDistance, 0, 0)
            end
            
            -- Force set position every frame
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.RotVelocity = Vector3.new(0, 0, 0)
            myHRP.CFrame = targetCF * CFrame.new(offset) * CFrame.Angles(0, targetCF.Rotation.Y, 0)
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            -- Auto attack
            if getgenv().AutoAttack then
                doM1()
            end
        end)
    else
        -- Restore movement
        local hum = getHum()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        
        if attachConnection then
            attachConnection:Disconnect()
            attachConnection = nil
        end
    end
end

-- ================ RAYFIELD UI ================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TITANIC HUB - TSB",
    Icon = 4483362458,
    LoadingTitle = "TITANIC HUB",
    LoadingSubtitle = "Perma Attach + Auto Attack",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = {Enabled = true, FolderName = "THUB/tsb", FileName = "attach_config"},
    KeySystem = false,
})

local MainTab = Window:CreateTab("Attach", 4483362458)

MainTab:CreateSection("Target Player")

local function updatePlayerList()
    local players = {}
    for _, v in ipairs(getAllPlayers()) do
        table.insert(players, v.Name)
    end
    if #players == 0 then
        table.insert(players, "No players found")
    end
    return players
end

local PlayerDropdown = MainTab:CreateDropdown({
    Name = "Select Player",
    Options = updatePlayerList(),
    CurrentOption = "",
    Flag = "TargetPlayer",
    Callback = function(option)
        local live = workspace:FindFirstChild("Live")
        if live then
            getgenv().AttachTarget = live:FindFirstChild(option)
        end
    end,
})

MainTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        PlayerDropdown:Refresh(updatePlayerList())
    end,
})

MainTab:CreateSection("Position")

MainTab:CreateDropdown({
    Name = "Attach Side",
    Options = {"Back", "Front", "Left", "Right"},
    CurrentOption = "Back",
    Flag = "AttachSide",
    Callback = function(option)
        getgenv().AttachPosition = option
    end,
})

MainTab:CreateSlider({
    Name = "Distance",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 4,
    Flag = "AttachDistance",
    Callback = function(value)
        getgenv().AttachDistance = value
    end,
})

MainTab:CreateSection("Controls")

MainTab:CreateToggle({
    Name = "Attach + Lock",
    CurrentValue = false,
    Flag = "AttachToggle",
    Callback = function(value)
        toggleAttach(value)
    end,
})

MainTab:CreateToggle({
    Name = "Auto Attack (M1)",
    CurrentValue = false,
    Flag = "AutoAttackToggle",
    Callback = function(value)
        getgenv().AutoAttack = value
    end,
})

MainTab:CreateSlider({
    Name = "Attack Speed",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = 0.15,
    Flag = "AttackSpeedSlider",
    Callback = function(value)
        getgenv().AttackSpeed = value
    end,
})

MainTab:CreateLabel("1. Select Player")
MainTab:CreateLabel("2. Set Position & Distance")
MainTab:CreateLabel("3. Toggle ATTACH ON")
MainTab:CreateLabel("4. Toggle AUTO ATTACK ON")
MainTab:CreateLabel("")
MainTab:CreateLabel("Move joystick se nahi hatega!")
MainTab:CreateLabel("Toggle OFF karke chhodo")

-- Auto refresh player list
task.spawn(function()
    while true do
        pcall(function()
            PlayerDropdown:Refresh(updatePlayerList())
        end)
        task.wait(3)
    end
end)

-- Anti-detach: Re-enable attach on character respawn
task.spawn(function()
    local lastChar
    while true do
        local char = getChar()
        if char ~= lastChar and getgenv().AttachEnabled then
            lastChar = char
            task.wait(0.5)
            toggleAttach(false)
            task.wait(0.2)
            toggleAttach(true)
        end
        lastChar = char
        task.wait(1)
    end
end)

Rayfield:Notify({
    Title = "TITANIC HUB",
    Content = "Perma Attach Loaded!\nAttach ON = Character lock ho jayega\nAuto Attack ON = Automatic M1",
    Duration = 5,
    Image = 4483362458,
})

Rayfield:LoadConfiguration()
