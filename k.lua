-- TSB Safe Scanner - Crash Proof
print("===== TSB SAFE SCAN =====")

-- Live Folder - One by one with full protection
print("\n=== LIVE FOLDER ===")
local live = workspace:FindFirstChild("Live")
if live then
    local count = 0
    for _, child in ipairs(live:GetChildren()) do
        count = count + 1
        pcall(function()
            if child then
                print(count .. ": " .. tostring(child.Name) .. " | " .. tostring(child.ClassName))
            end
        end)
    end
    print("Total objects in Live:", count)
end

-- Our Player from workspace.Live
print("\n=== OUR PLAYER ===")
pcall(function()
    local ourChar = live and live:FindFirstChild(lp.Name)
    if ourChar then
        print("Found our character!")
        
        -- Humanoid
        local hum = ourChar:FindFirstChild("Humanoid")
        if hum then
            print("Health:", hum.Health)
            print("MaxHealth:", hum.MaxHealth)
            print("WalkSpeed:", hum.WalkSpeed)
        end
        
        -- All children names
        print("Children:")
        for _, c in ipairs(ourChar:GetChildren()) do
            pcall(function()
                print("  " .. c.Name .. " [" .. c.ClassName .. "]")
            end)
        end
        
        -- Attributes
        pcall(function()
            local attrs = ourChar:GetAttributes()
            if attrs then
                print("Attributes:")
                for k, v in pairs(attrs) do
                    print("  " .. k .. " = " .. tostring(v))
                end
            end
        end)
    else
        print("Our character NOT FOUND in Live folder!")
        print("Looking in workspace...")
        -- Try Characters folder
        local chars = workspace:FindFirstChild("Characters")
        if chars then
            ourChar = chars:FindFirstChild(lp.Name)
            if ourChar then
                print("Found in Characters folder!")
                for _, c in ipairs(ourChar:GetChildren()) do
                    pcall(function() print("  " .. c.Name .. " [" .. c.ClassName .. "]") end)
                end
            end
        end
    end
end)

-- Backpack
print("\n=== BACKPACK ===")
pcall(function()
    local bp = lp:FindFirstChild("Backpack")
    if bp then
        print("Backpack contents:")
        for _, tool in ipairs(bp:GetChildren()) do
            print("  " .. tool.Name .. " [" .. tool.ClassName .. "]")
        end
    end
end)

-- PlayerGui Screens
print("\n=== PLAYER GUI SCREENS ===")
pcall(function()
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        for _, screen in ipairs(pg:GetChildren()) do
            print(screen.Name .. " [" .. screen.ClassName .. "]")
        end
    end
end)

print("===== SCAN COMPLETE =====")
