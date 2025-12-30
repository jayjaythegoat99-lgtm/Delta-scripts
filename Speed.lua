local CorrectKey = "MYPRIVATEKEY"

-- PROTECTION
if _G.Key ~= CorrectKey then
    game.Players.LocalPlayer:Kick("Access Denied: Incorrect Key")
    return
end

-- SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATES
_G.SpeedEnabled, _G.JumpEnabled, _G.AutoClicker, _G.Flying, _G.KillAura, _G.EspEnabled = false, false, false, false, false, false
_G.WalkSpeedValue, _G.JumpPowerValue, _G.FlySpeedValue, _G.AuraRange = 100, 100, 50, 14

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FiveHub_V7"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- OPEN/CLOSE BUTTON (Mobile Friendly)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.BorderSizePixel = 2
OpenBtn.Position = UDim2.new(0, 10, 0, 10)
OpenBtn.Size = UDim2.new(0, 60, 0, 30)
OpenBtn.Text = "CLOSE"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Draggable = true -- You can move the button anywhere

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 180, 0, 250)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Active = true
MainFrame.Draggable = true

-- TITLE BAR
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "5 HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- OPEN/CLOSE LOGIC
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    OpenBtn.Text = MainFrame.Visible and "CLOSE" or "OPEN"
end)

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 25)
TabBar.Position = UDim2.new(0, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBar.Parent = MainFrame

local function CreateTabBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.Text = text
    btn.TextSize = 10
    btn.Parent = TabBar
    return btn
end

local MainTabBtn = CreateTabBtn("Main", 0)
local CombatTabBtn = CreateTabBtn("Comb", 0.25)
local AuraTabBtn = CreateTabBtn("Aura", 0.5)
local EspTabBtn = CreateTabBtn("ESP", 0.75)

local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, -55)
    page.Position = UDim2.new(0, 0, 0, 55)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = MainFrame
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)
    return page
end

local MainPage, CombatPage, AuraPage, EspPage = CreatePage(), CreatePage(), CreatePage(), CreatePage()
MainPage.Visible = true

MainTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = true, false, false, false end)
CombatTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, true, false, false end)
AuraTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, false, true, false end)
EspTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, false, false, true end)

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
AddToggle("Box ESP", EspPage, function(v) _G.EspEnabled = v end)

-- ESP / JUMP / FLY / CLICKER LOGIC (RETAINED FROM PREVIOUS)
UserInputService.JumpRequest:Connect(function()
    if _G.JumpEnabled then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if _G.Flying and hrp then
            LocalPlayer.Character.Humanoid.PlatformStand = true
            hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.FlySpeedValue
        else
            LocalPlayer.Character.Humanoid.PlatformStand = false
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedEnabled and _G.WalkSpeedValue or 16
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("ESPHighlight")
            if _G.EspEnabled then
                if not highlight then 
                    local h = Instance.new("Highlight", plr.Character)
                    h.Name = "ESPHighlight"
                    h.FillColor = Color3.new(1, 0, 0)
                end
            elseif highlight then highlight:Destroy() end
        end
    end
end)

task.spawn(function()
    local VU = game:GetService("VirtualUser")
    while true do
        if _G.AutoClicker then VU:CaptureController() VU:ClickButton1(Vector2.new(0,0)) end
        task.wait(0.01 + (math.random() * 0.02))
    end
end)
