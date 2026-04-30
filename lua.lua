print("===== TSB CHARACTER DEEP SCAN =====")

-- Find our actual character
local live = workspace:FindFirstChild("Live")
local ourChar = nil

if live then
    for _, child in ipairs(live:GetChildren()) do
        pcall(function()
            print("Checking:", child.Name, "| Class:", child.ClassName)
            
            -- Check if this is our character (has Humanoid)
            if child:IsA("Model") and child:FindFirstChild("Humanoid") then
                print("  -> Has Humanoid!")
                print("  -> Health:", child.Humanoid.Health)
                
                -- Check if this model belongs to us
                local humRoot = child:FindFirstChild("HumanoidRootPart")
                if humRoot then
                    local dist = (humRoot.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                    print("  -> Distance from camera:", math.floor(dist))
                end
                
                -- Show all children types
                for _, c in ipairs(child:GetChildren()) do
                    pcall(function()
                        print("    Child:", c.Name, "[" .. c.ClassName .. "]")
                    end)
                end
                
                -- Show attributes
                pcall(function()
                    local attrs = child:GetAttributes()
                    if attrs and next(attrs) then
                        print("    Attributes:")
                        for k, v in pairs(attrs) do
                            print("      " .. k .. " = " .. tostring(v))
                        end
                    end
                end)
                
                print("  ---")
            end
        end)
    end
end

-- Backpack details
print("\n=== BACKPACK ===")
pcall(function()
    if lp.Backpack then
        for _, item in ipairs(lp.Backpack:GetChildren()) do
            print("Backpack:", item.Name, "[" .. item.ClassName .. "]")
        end
    else
        print("Backpack not found or empty")
    end
end)

-- Character from workspace directly
print("\n=== WORKSPACE CHARACTER CHECK ===")
pcall(function()
    print("lp.Character:", lp.Character and lp.Character.Name or "NIL")
    if lp.Character then
        print("lp.Character parent:", lp.Character.Parent and lp.Character.Parent.Name or "NIL")
    end
end)

print("===== DEEP SCAN COMPLETE =====")
