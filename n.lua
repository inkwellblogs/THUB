-- TSB Workspace & Remote Scanner
print("===== TSB STRUCTURE SCAN =====")
print("PlaceId:", game.PlaceId)

-- Workspace
print("\n=== WORKSPACE ===")
for _, child in ipairs(workspace:GetChildren()) do
    print("WS Child:", child.Name, "| Class:", child.ClassName)
end

-- ReplicatedStorage Remotes
print("\n=== REMOTES ===")
local rs = game:GetService("ReplicatedStorage")
for _, folder in ipairs(rs:GetChildren()) do
    if folder.Name:lower():find("remote") or folder.Name:lower():find("event") or folder.Name:lower():find("function") then
        print("Folder:", folder.Name)
        for _, rem in ipairs(folder:GetChildren()) do
            print("  ", rem.Name, "| Class:", rem.ClassName)
        end
    end
end

-- Characters folder
print("\n=== CHARACTERS ===")
local chars = workspace:FindFirstChild("Characters") or workspace:FindFirstChild("Players")
if chars then
    for _, plr in ipairs(chars:GetChildren()) do
        print("Character:", plr.Name)
    end
end

print("===== SCAN COMPLETE =====")
