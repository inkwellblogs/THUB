-- TSB Attach Test - Remote Finder
print("===== TSB ATTACH TEST =====")

local char = workspace.Live:FindFirstChild(lp.Name)
if not char then
    print("Character not found in Live!")
    return
end

-- 1. Check Communicate Remote
local communicate = char:FindFirstChild("Communicate")
if communicate then
    print("Communicate Remote: FOUND | Class:", communicate.ClassName)
    print("  Parent:", communicate.Parent.Name)
else
    print("Communicate Remote: NOT FOUND")
end

-- 2. Check all remotes in character
print("\n=== ALL REMOTES IN CHARACTER ===")
for _, child in ipairs(char:GetDescendants()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        print(child:GetFullName(), "| Class:", child.ClassName)
    end
end

-- 3. Check ReplicatedStorage remotes
print("\n=== REPLICATED STORAGE REMOTES ===")
local rs = game:GetService("ReplicatedStorage")
for _, child in ipairs(rs:GetDescendants()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("UnreliableRemoteEvent") then
        print(child:GetFullName(), "| Class:", child.ClassName)
    end
end

-- 4. Try direct HRP manipulation
print("\n=== HRP TEST ===")
local hrp = char:FindFirstChild("HumanoidRootPart")
if hrp then
    print("HRP Found!")
    print("  Position:", hrp.Position)
    print("  Velocity:", hrp.Velocity)
    print("  AssemblyLinearVelocity:", hrp.AssemblyLinearVelocity)
    
    -- Try to set network ownership
    pcall(function()
        hrp:SetNetworkOwner(nil)
        print("  Network Ownership: SET TO NIL (Server)")
    end)
else
    print("HRP NOT FOUND!")
end

-- 5. List all Live players
print("\n=== ALL PLAYERS IN LIVE ===")
local live = workspace:FindFirstChild("Live")
if live then
    for _, v in ipairs(live:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            print("  " .. v.Name .. " | Health: " .. v.Humanoid.Health .. " | NPC: " .. tostring(v:GetAttribute("NPC")))
        end
    end
end

-- 6. Try simple attach test
print("\n=== SIMPLE ATTACH TEST ===")
local target = nil
if live then
    for _, v in ipairs(live:GetChildren()) do
        if v.Name ~= lp.Name and v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            target = v
            break
        end
    end
end

if target and hrp then
    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    print("Target found:", target.Name)
    print("Moving to target...")
    
    -- Force move
    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -4)
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    
    print("Moved! New position:", hrp.Position)
    print("Distance from target:", (hrp.Position - targetHRP.Position).Magnitude)
else
    print("No target found or no HRP!")
end

print("===== TEST COMPLETE =====")
