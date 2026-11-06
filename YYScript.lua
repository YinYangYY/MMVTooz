-- 1. Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "Yin Yang YY",
	Icon = "crosshair",
	Author = "by NotJDM 🦆",
	Folder = "YY",
	Size = UDim2.fromOffset(500, 400),
	Theme = "Dark",
	Transparent = true,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables
local espObjects = {}
local toggles = { Innocent = false, Murderer = false, Sheriff = false, Hero = false }
local autoShootActive = false
local targetMurderer = nil

----------------------------------------------------------------
-- MAIN TAB
----------------------------------------------------------------
local MainTab = Window:Tab({Title = "Main", Icon = "home"})

MainTab:Section({Title = "Welcome to Yin Yang YY"})
MainTab:Paragraph({
	Title = "Version 1.0",
	Desc = "Welcome to the ultimate Murder Mystery V experience. Yin Yang YY is designed to give you complete control over the game. Use the Visuals tab to see every player's role through walls with our ESP. Use the Combat tab to lock onto the Murderer with our smooth Aimbot and Auto-Shoot, ensuring you never miss a shot when you are the Sheriff. \n\nPlease note: This is Version 1.0. If you encounter any bugs, such as the ESP disappearing after a round, simply re-toggle the switch. Stay safe, and happy hunting."
})

----------------------------------------------------------------
-- VISUALS TAB (ESP)
----------------------------------------------------------------
local VisualTab = Window:Tab({Title = "Visuals", Icon = "eye"})
VisualTab:Section({Title = "Role ESP"})

VisualTab:Toggle({ Title = "Innocent ESP", Default = false, Callback = function(v) toggles.Innocent = v if not v then clearESP("Innocent") end end })
VisualTab:Toggle({ Title = "Murderer ESP", Default = false, Callback = function(v) toggles.Murderer = v if not v then clearESP("Murderer") end end })
VisualTab:Toggle({ Title = "Sheriff ESP", Default = false, Callback = function(v) toggles.Sheriff = v if not v then clearESP("Sheriff") end end })
VisualTab:Toggle({ Title = "Hero ESP", Default = false, Callback = function(v) toggles.Hero = v if not v then clearESP("Hero") end end })

----------------------------------------------------------------
-- COMBAT TAB
----------------------------------------------------------------
local CombatTab = Window:Tab({Title = "Combat", Icon = "crosshair"})
CombatTab:Section({Title = "Weapon Mods"})

CombatTab:Toggle({
	Title = "Auto Shoot + Aimbot (Murderer)",
	Default = false,
	Callback = function(v) autoShootActive = v end
})

CombatTab:Button({
	Title = "Kill Everyone",
	Callback = function()
        task.spawn(function()
            local char = LocalPlayer.Character
            local tool = char and (char:FindFirstChild("Revolver") or char:FindFirstChild("Gun") or char:FindFirstChild("Knife"))
            
            if tool then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if thrp then
                            char.HumanoidRootPart.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
                            task.wait(0.1)
                            pcall(function() tool:Activate() end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end)
	end
})

----------------------------------------------------------------
-- THE ESP & TARGET LOGIC
----------------------------------------------------------------
function clearESP(role)
    for plr, highlight in pairs(espObjects) do
        if highlight:GetAttribute("Role") == role then
            highlight:Destroy()
            espObjects[plr] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    local foundMurderer = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            
            local hasKnife, hasGun, hasHero = false, false, false
            
            if plr.Character:FindFirstChild("Knife") or plr.Character:FindFirstChild("Dagger") then hasKnife = true end
            if plr.Character:FindFirstChild("Gun") or plr.Character:FindFirstChild("Revolver") then hasGun = true end
            if plr.Character:FindFirstChild("Hero") or plr.Character:FindFirstChild("Bow") then hasHero = true end
            
            local backpack = plr:FindFirstChild("Backpack")
            if backpack then
                if backpack:FindFirstChild("Knife") or backpack:FindFirstChild("Dagger") then hasKnife = true end
                if backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver") then hasGun = true end
                if backpack:FindFirstChild("Hero") or backpack:FindFirstChild("Bow") then hasHero = true end
            end

            local role = "Innocent"
            local color = Color3.fromRGB(0, 255, 0)
            
            if hasKnife then role = "Murderer" color = Color3.fromRGB(255, 0, 0)
            elseif hasGun then role = "Sheriff" color = Color3.fromRGB(0, 100, 255)
            elseif hasHero then role = "Hero" color = Color3.fromRGB(255, 255, 0) end

            if role == "Murderer" then foundMurderer = plr end

            if toggles[role] then
                if not espObjects[plr] or not espObjects[plr].Parent or espObjects[plr].Adornee ~= plr.Character then
                    if espObjects[plr] then espObjects[plr]:Destroy() end
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = plr.Character
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight:SetAttribute("Role", role)
                    highlight.Parent = plr.Character
                    espObjects[plr] = highlight
                end
                
                espObjects[plr].FillColor = color
                espObjects[plr].OutlineColor = color
            else
                if espObjects[plr] then espObjects[plr]:Destroy() espObjects[plr] = nil end
            end
        end
    end

    targetMurderer = foundMurderer
end)

----------------------------------------------------------------
-- THE COMBAT LOGIC (Aimbot + Auto Shoot)
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not autoShootActive then return end
    if not targetMurderer or not targetMurderer.Character then return end
    
    local char = LocalPlayer.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    local myTool = char and (char:FindFirstChild("Revolver") or char:FindFirstChild("Gun"))
    
    if myHRP and myTool then
        local targetHRP = targetMurderer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHRP.Position)
            
            pcall(function()
                myTool:Activate()
            end)
        end
    end
end)
