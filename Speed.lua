local CorrectKey = "MYPRIVATEKEY"

-- PROTECTION
if _G.Key ~= CorrectKey then
    game.Players.LocalPlayer:Kick("Access Denied: Incorrect Key")
    return
end

-- SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATES (Starts everything OFF for safety)
_G.SpeedEnabled, _G.JumpEnabled, _G.AutoClicker, _G.Flying, _G.KillAura = false, false, false, false, false
_G.WalkSpeedValue, _G.JumpPowerValue, _G.FlySpeedValue, _G.AuraRange = 100, 100, 50, 14

-- UI SETUP (Same Tabbed System)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JayJayStealth_V4"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 180, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Active = true
MainFrame.Draggable = true

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabBar.Parent = MainFrame

local function CreateTabBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, 0, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.Text = text
    btn.Parent = TabBar
    return btn
end

local MainTabBtn = CreateTabBtn("Main", 0)
local CombatTabBtn = CreateTabBtn("Combat", 0.33)
local AuraTabBtn = CreateTabBtn("Aura", 0.66)

local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, -30)
    page.Position = UDim2.new(0, 0, 0, 30)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = MainFrame
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)
    return page
end

local MainPage, CombatPage, AuraPage = CreatePage(), CreatePage(), CreatePage()
MainPage.Visible = true

MainTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible = true, false, false end)
CombatTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible = false, true, false end)
AuraTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible = false, false, true end)

local function AddToggle(name, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Parent = parent
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
        callback(enabled)
    end)
end

AddToggle("Speed", MainPage, function(v) _G.SpeedEnabled = v end)
AddToggle("Inf Jump", MainPage, function(v) _G.JumpEnabled = v end)
AddToggle("Fly", MainPage, function(v) _G.Flying = v end)
AddToggle("AutoClick", CombatPage, function(v) _G.AutoClicker = v end)
AddToggle("Kill Aura", AuraPage, function(v) _G.KillAura = v end)

-- STEALTH LOGIC 1: RANDOMIZED CLICKER (Prevents "Pattern Detection")
task.spawn(function()
    local VU = game:GetService("VirtualUser")
    while true do
        if _G.AutoClicker then
            VU:CaptureController()
            VU:ClickButton1(Vector2.new(0,0))
            -- Random wait between 0.01 and 0.03 makes it look human
            task.wait(0.01 + (math.random() * 0.02))
        else
            task.wait(0.5)
        end
    end
end)

-- STEALTH LOGIC 2: RAYCAST KILL AURA (Only hits if they aren't behind walls)
task.spawn(function()
    while task.wait(0.1) do
        if _G.KillAura and LocalPlayer.Character then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = player.Character.HumanoidRootPart.Position
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local dist = (myPos - targetPos).Magnitude
                    
                    if dist <= _G.AuraRange then
                        -- Check if player is visible (not through walls)
                        local ray = Ray.new(myPos, (targetPos - myPos).Unit * _G.AuraRange)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                        
                        if hit and hit:IsDescendantOf(player.Character) then
                            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                        end
                    end
                end
            end
        end
    end
end)

-- STEALTH LOGIC 3: SMOOTH SPEED (Avoids "Teleport" flag)
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        if _G.Flying and hrp then
            hum.PlatformStand = true
            hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.FlySpeedValue
        else
            hum.PlatformStand = false
            -- Apply speed only when moving so you don't jitter
            if _G.SpeedEnabled and hum.MoveDirection.Magnitude > 0 then
                hum.WalkSpeed = _G.WalkSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end
end)
