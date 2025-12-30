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

-- SETTINGS
_G.SpeedEnabled = true
_G.JumpEnabled = true
_G.AutoClicker = false
_G.Flying = false
_G.SpeedValue = 100
_G.JumpPower = 50
_G.FlySpeed = 50

-- CREATE MOBILE UI BUTTONS
local ScreenGui = Instance.new("ScreenGui")
local ToggleFrame = Instance.new("Frame")
local ClickerBtn = Instance.new("TextButton")
local FlyBtn = Instance.new("TextButton")
local KillBtn = Instance.new("TextButton")

ScreenGui.Name = "DeltaHelpers"
ScreenGui.Parent = game.CoreGui
ToggleFrame.Parent = ScreenGui
ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleFrame.Size = UDim2.new(0, 120, 0, 150) -- Made frame taller for fly button
ToggleFrame.Active = true
ToggleFrame.Draggable = true 

ClickerBtn.Parent = ToggleFrame
ClickerBtn.Size = UDim2.new(1, 0, 0.33, 0)
ClickerBtn.Text = "AutoClick: OFF"
ClickerBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ClickerBtn.TextColor3 = Color3.new(1,1,1)

FlyBtn.Parent = ToggleFrame
FlyBtn.Position = UDim2.new(0, 0, 0.33, 0)
FlyBtn.Size = UDim2.new(1, 0, 0.33, 0)
FlyBtn.Text = "Fly: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FlyBtn.TextColor3 = Color3.new(1,1,1)

KillBtn.Parent = ToggleFrame
KillBtn.Position = UDim2.new(0, 0, 0.66, 0)
KillBtn.Size = UDim2.new(1, 0, 0.34, 0)
KillBtn.Text = "RESET CHAR"
KillBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KillBtn.TextColor3 = Color3.new(1,1,1)

-- BUTTON FUNCTIONS
ClickerBtn.MouseButton1Click:Connect(function()
    _G.AutoClicker = not _G.AutoClicker
    ClickerBtn.Text = _G.AutoClicker and "AutoClick: ON" or "AutoClick: OFF"
    ClickerBtn.BackgroundColor3 = _G.AutoClicker and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

FlyBtn.MouseButton1Click:Connect(function()
    _G.Flying = not _G.Flying
    FlyBtn.Text = _G.Flying and "Fly: ON" or "Fly: OFF"
    FlyBtn.BackgroundColor3 = _G.Flying and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

KillBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- FLY LOGIC
RunService.RenderStepped:Connect(function()
    if _G.Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        root.Velocity = camera.CFrame.LookVector * _G.FlySpeed
    end
end)

-- CONSTANT LOOP (Fixes Speed & Jump)
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if not _G.Flying then
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedValue
            LocalPlayer.Character.Humanoid.JumpPower = _G.JumpPower
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 0 -- Disable walking while flying
        end
    end
end)

-- AUTO-CLICKER ENGINE
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    while true do
        if _G.AutoClicker then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0,0))
        end
        task.wait(0.01)
    end
end)
