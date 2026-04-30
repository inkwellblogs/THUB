print("===== TSB SKILLS & REMOTES SCAN =====")

-- Player's current moveset skills
print("\n=== PLAYER MOVESET ===")
pcall(function()
    local char = workspace.Live:FindFirstChild(lp.Name)
    if char then
        -- Check for skills folder or module
        for _, child in ipairs(char:GetDescendants()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                print("Remote in char:", child:GetFullName())
            end
            if child:IsA("ModuleScript") then
                print("Module:", child.Name, "| Parent:", child.Parent and child.Parent.Name)
            end
        end
    end
end)

-- Backpack tools (moves)
print("\n=== BACKPACK TOOLS ===")
pcall(function()
    for _, tool in ipairs(lp.Backpack:GetChildren()) do
        print("Tool:", tool.Name, "[", tool.ClassName, "]")
        for _, child in ipairs(tool:GetDescendants()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                print("  Remote:", child.Name, "[", child.ClassName, "]")
            end
        end
    end
end)

-- PlayerGui buttons/moves
print("\n=== PLAYER GUI MOVES ===")
pcall(function()
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        for _, screen in ipairs(pg:GetChildren()) do
            pcall(function()
                if screen:IsA("ScreenGui") then
                    for _, element in ipairs(screen:GetDescendants()) do
                        if element:IsA("TextButton") or element:IsA("ImageButton") then
                            if element.Visible and element.Text ~= "" then
                                print("Button:", element.Text, "| Visible:", element.Visible)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Try to find move names from attributes
print("\n=== MOVE NAMES (from attributes) ===")
pcall(function()
    local char = workspace.Live:FindFirstChild(lp.Name)
    if char then
        for _, child in ipairs(char:GetDescendants()) do
            pcall(function()
                if child:IsA("StringValue") or child:IsA("Configuration") then
                    print(child.Name, "=", tostring(child.Value))
                end
            end)
        end
    end
end)

print("===== SCAN COMPLETE =====")
