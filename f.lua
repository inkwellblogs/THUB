-- TSB Live & Player Structure Scanner
print("===== TSB LIVE & PLAYER SCAN =====")

-- Live Folder Details
print("\n=== LIVE FOLDER (Players inside map) ===")
local live = workspace:FindFirstChild("Live")
if live then
    for _, child in ipairs(live:GetChildren()) do
        print("Live:", child.Name, "| Class:", child.ClassName)
        
        -- Check if this is our player
        if child.Name == lp.Name then
            print("  >>> THIS IS OUR PLAYER <<<")
            -- Show Humanoid
            local hum = child:FindFirstChild("Humanoid")
            if hum then
                print("  Humanoid Health:", hum.Health, "/", hum.MaxHealth)
            end
            -- Show important attributes
            pcall(function()
                local attrs = child:GetAttributes()
                for k, v in pairs(attrs) do
                    print("  Attribute:", k, "=", tostring(v))
                end
            end)
            -- Show key parts
            for _, partName in ipairs({"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"}) do
                local part = child:FindFirstChild(partName)
                if part then print("  Part:", partName, "- Position:", part.Position) end
            end
        end
    end
end

-- Map important folders
print("\n=== MAP STRUCTURE (1 level deep) ===")
local map = workspace:FindFirstChild("Map")
if map then
    local function show1Level(parent, indent)
        indent = indent or ""
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("Folder") then
                print(indent .. "Folder:", child.Name, "(" .. #child:GetChildren() .. " children)")
                if #child:GetChildren() <= 10 then
                    for _, sub in ipairs(child:GetChildren()) do
                        print(indent .. "  -", sub.Name, "[" .. sub.ClassName .. "]")
                    end
                end
            end
        end
    end
    show1Level(map)
end

print("===== SCAN COMPLETE =====")
