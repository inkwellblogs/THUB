-- Mobile Workspace Dumper - Save to File
local HttpService = game:GetService("HttpService")
local seen = {}

local function dumpStructure(obj, depth, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or 2 -- Mobile ke liye kam depth
    if depth > maxDepth then return "" end
    if seen[obj] then return "" end
    seen[obj] = true
    
    local result = ""
    local indent = string.rep("  ", depth)
    
    for _, child in ipairs(obj:GetChildren()) do
        -- Skip large tree/leaf folders
        if child.Name == "Trees" or child.Name == "Leaves" or child.Name == "Grass" then
            result = result .. indent .. "[" .. child.ClassName .. "] " .. child.Name .. " (skipped)\n"
        else
            result = result .. indent .. "[" .. child.ClassName .. "] " .. child.Name
            
            -- Attributes
            pcall(function()
                local attrs = child:GetAttributes()
                if attrs and next(attrs) then
                    result = result .. " {"
                    for k, v in pairs(attrs) do
                        result = result .. k .. "=" .. tostring(v) .. ", "
                    end
                    result = result .. "}"
                end
            end)
            
            result = result .. "\n"
            
            -- Children
            if #child:GetChildren() > 0 and depth < maxDepth then
                result = result .. dumpStructure(child, depth + 1, maxDepth)
            end
        end
    end
    return result
end

-- Collect data
local fullDump = "=== TSB FULL WORKSPACE DUMP ===\n"
fullDump = fullDump .. "PlaceId: " .. game.PlaceId .. "\n"
fullDump = fullDump .. "Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"

-- 1. Workspace (depth 3 for important folders)
seen = {}
fullDump = fullDump .. "=== WORKSPACE ===\n"
for _, child in ipairs(workspace:GetChildren()) do
    local depth = (child.Name == "Live" or child.Name == "Map") and 3 or 1
    seen = {}
    fullDump = fullDump .. dumpStructure(child, 0, depth)
    fullDump = fullDump .. "\n"
end

-- 2. ReplicatedStorage Remotes
fullDump = fullDump .. "\n=== ReplicatedStorage ===\n"
seen = {}
local rs = game:GetService("ReplicatedStorage")
for _, child in ipairs(rs:GetChildren()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("UnreliableRemoteEvent") then
        fullDump = fullDump .. "[" .. child.ClassName .. "] " .. child.Name .. "\n"
    elseif child:IsA("Folder") and (child.Name:lower():find("remote") or child.Name:lower():find("event")) then
        fullDump = fullDump .. "[Folder] " .. child.Name .. "\n"
        for _, sub in ipairs(child:GetChildren()) do
            fullDump = fullDump .. "  [" .. sub.ClassName .. "] " .. sub.Name .. "\n"
        end
    end
end

-- 3. PlayerGui
fullDump = fullDump .. "\n=== PlayerGui ===\n"
seen = {}
pcall(function()
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        for _, screen in ipairs(pg:GetChildren()) do
            fullDump = fullDump .. "[" .. screen.ClassName .. "] " .. screen.Name
            if screen:IsA("ScreenGui") then
                fullDump = fullDump .. " (Enabled: " .. tostring(screen.Enabled) .. ")"
            end
            fullDump = fullDump .. "\n"
        end
    end
end)

-- 4. Live folder full detail
fullDump = fullDump .. "\n=== LIVE FOLDER (Full Detail) ===\n"
seen = {}
local live = workspace:FindFirstChild("Live")
if live then
    fullDump = fullDump .. dumpStructure(live, 0, 4)
end

-- 5. Backpack
fullDump = fullDump .. "\n=== BACKPACK ===\n"
pcall(function()
    for _, tool in ipairs(lp.Backpack:GetChildren()) do
        fullDump = fullDump .. "[" .. tool.ClassName .. "] " .. tool.Name .. "\n"
    end
end)

-- Save to file
local fileName = "TSB_workspace_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
writefile(fileName, fullDump)
setclipboard(fullDump)

print("=== DUMP COMPLETE ===")
print("File saved: " .. fileName)
print("Also copied to clipboard!")
print("Size: " .. #fullDump .. " characters")
print("\nFile location: Your executor's workspace folder")
print("Paste in notes app to see full content!")
