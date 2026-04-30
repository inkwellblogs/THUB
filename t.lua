-- TSB Detailed Remote Scanner
print("===== TSB DETAILED REMOTE SCAN =====")

local rs = game:GetService("ReplicatedStorage")

-- Scan ALL remotes with their full paths
local function findRemotes(parent, depth)
    depth = depth or 0
    if depth > 5 then return end
    
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("UnreliableRemoteEvent") then
            print("REMOTE:", child:GetFullName(), "| Class:", child.ClassName)
        end
        if child:IsA("Folder") then
            findRemotes(child, depth + 1)
        end
    end
end

findRemotes(rs)

-- Live folder structure
print("\n=== LIVE FOLDER ===")
local live = workspace:FindFirstChild("Live")
if live then
    for _, child in ipairs(live:GetChildren()) do
        print("Live Child:", child.Name, "| Class:", child.ClassName)
        if child:IsA("Folder") then
            for _, sub in ipairs(child:GetChildren()) do
                print("  Sub:", sub.Name, "| Class:", sub.ClassName)
            end
        end
    end
end

-- Map folder
print("\n=== MAP FOLDER ===")
local map = workspace:FindFirstChild("Map")
if map then
    for _, child in ipairs(map:GetChildren()) do
        print("Map Child:", child.Name, "| Class:", child.ClassName)
    end
end

-- PlayerGui
print("\n=== PLAYER GUI ===")
for _, gui in ipairs(lp.PlayerGui:GetChildren()) do
    print("GUI:", gui.Name, "| Class:", gui.ClassName)
end

print("===== SCAN COMPLETE =====")
