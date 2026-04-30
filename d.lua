-- TSB Live & Player Scanner (FIXED)
print("===== TSB LIVE & PLAYER SCAN =====")

-- Live Folder Details
print("\n=== LIVE FOLDER ===")
local live = workspace:FindFirstChild("Live")
if live then
    for _, child in ipairs(live:GetChildren()) do
        if child and child.Name then
            print("Live:", child.Name, "| Class:", child.ClassName)
            
            if child.Name == lp.Name then
                print("  >>> THIS IS OUR PLAYER <<<")
                
                -- Humanoid
                local hum = child:FindFirstChild("Humanoid")
                if hum then
                    print("  Health:", hum.Health, "/", hum.MaxHealth)
                    print("  WalkSpeed:", hum.WalkSpeed)
                    print("  JumpPower:", hum.JumpPower)
                end
                
                -- Attributes
                pcall(function()
                    local attrs = child:GetAttributes()
                    if attrs and next(attrs) then
                        print("  --- Attributes ---")
                        for k, v in pairs(attrs) do
                            print("  ", k, "=", tostring(v))
                        end
                    end
                end)
                
                -- Key Parts
                print("  --- Body Parts ---")
                for _, partName in ipairs({"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso", "RightHand", "LeftHand"}) do
                    local part = child:FindFirstChild(partName)
                    if part then
                        print("  " .. partName .. ":", math.floor(part.Position.X), math.floor(part.Position.Y), math.floor(part.Position.Z))
                    end
                end
                
                -- Children overview
                print("  --- Children Count:", #child:GetChildren(), "---")
                for _, c in ipairs(child:GetChildren()) do
                    print("  ", c.Name, "[" .. c.ClassName .. "]")
                end
            end
        end
    end
end

-- Show other players
print("\n=== OTHER PLAYERS IN LIVE ===")
if live then
    for _, child in ipairs(live:GetChildren()) do
        if child and child.Name and child.Name ~= lp.Name and child:IsA("Model") and child:FindFirstChild("Humanoid") then
            print("Player:", child.Name)
        end
    end
end

print("===== SCAN COMPLETE =====")
