-- TITANIC HUB TSB - Attach to Player
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

repeat task.wait() until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

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

local function getAllPlayers()
    local players = {}
    local live = workspace:FindFirstChild("Live")
    if live then
        for _, v in ipairs(live:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if v.Name ~= lp.Name then
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

-- Attach settings
getgenv().AttachEnabled = false
getgenv().AttachTarget = nil
getgenv().AttachOffset = Vector3.new(0, 0, -4) -- Default: Player ke peeche 4 studs
getgenv().AttachSide = "Back" -- Back, Front, Left, Right, Above, Below
getgenv().AttachDistance = 4 -- Distance in studs

local function getAttachOffset(side, distance)
    if side == "Back" then
        return Vector3.new(0, 0, -distance)
    elseif side == "Front" then
        return Vector3.new(0, 0, distance)
    elseif side == "Left" then
        return Vector3.new(-distance, 0, 0)
    elseif side == "Right" then
        return Vector3.new(distance, 0, 0)
    elseif side == "Above" then
        return Vector3.new(0, distance, 0)
    elseif side == "Below" then
        return Vector3.new(0, -distance, 0)
    end
    return Vector3.new(0, 0, -distance)
end

-- Main Attach Loop
local attachConnection
local function toggleAttach(enable)
    getgenv().AttachEnabled = enable
    
    if enable then
        attachConnection = RunService.Heartbeat:Connect(function()
            if not getgenv().AttachEnabled then return end
            
            local target = getgenv().AttachTarget
            if not target then return end
            
            local targetHRP = target:FindFirstChild("HumanoidRootPart")
            local myHRP = getHRP()
            
            if not targetHRP or not myHRP then return end
            
            local offset = getAttachOffset(getgenv().AttachSide, getgenv().AttachDistance)
            local targetCFrame = targetHRP.CFrame
            local newPos = targetCFrame.Position + (targetCFrame.LookVector * offset.Z) + (targetCFrame.RightVector * offset.X) + (targetCFrame.UpVector * offset.Y)
            
            myHRP.CFrame = CFrame.new(newPos) * CFrame.Angles(targetCFrame.Rotation.X, targetCFrame.Rotation.Y, targetCFrame.Rotation.Z)
        end)
    else
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
    LoadingSubtitle = "Attach to Player",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = {Enabled = true, FolderName = "THUB/tsb", FileName = "attach_config"},
    KeySystem = false,
})

local MainTab = Window:CreateTab("Attach", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

MainTab:CreateSection("Attach to Player")

-- Player list dropdown
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

MainTab:CreateLabel("Select target player:")

local PlayerDropdown = MainTab:CreateDropdown({
    Name = "Target Player",
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

MainTab:CreateSection("Position Settings")

MainTab:CreateDropdown({
    Name = "Attach Position",
    Options = {"Back", "Front", "Left", "Right", "Above", "Below"},
    CurrentOption = "Back",
    Flag = "AttachSide",
    Callback = function(option)
        getgenv().AttachSide = option
    end,
})

MainTab:CreateSlider({
    Name = "Distance",
    Range = {1, 20},
    Increment = 0.5,
    CurrentValue = 4,
    Flag = "AttachDistance",
    Callback = function(value)
        getgenv().AttachDistance = value
    end,
})

MainTab:CreateSection("Control")

MainTab:CreateToggle({
    Name = "Attach to Player",
    CurrentValue = false,
    Flag = "AttachToggle",
    Callback = function(value)
        toggleAttach(value)
    end,
})

MainTab:CreateLabel("Toggle ON to attach | OFF to detach")
MainTab:CreateLabel("Default: Player ke peeche 4 studs")

-- Settings
SettingsTab:CreateSection("UI Settings")
SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "MenuKeybind",
})

-- Refresh player list periodically
task.spawn(function()
    while true do
        PlayerDropdown:Refresh(updatePlayerList())
        task.wait(5)
    end
end)

Rayfield:Notify({
    Title = "TITANIC HUB",
    Content = "Attach to Player loaded!\n1. Select player\n2. Set position\n3. Toggle ON",
    Duration = 5,
    Image = 4483362458,
})

Rayfield:LoadConfiguration()
