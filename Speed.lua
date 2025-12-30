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
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATES
_G.SpeedEnabled, _G.JumpEnabled, _G.AutoClicker, _G.Flying, _G.KillAura, _G.EspEnabled = false, false, false, false, false, false
_G.WalkSpeedValue, _G.JumpPowerValue, _G.FlySpeedValue = 100, 100, 50

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FiveHub_V10"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
OpenBtn.Size = UDim2.new(0, 80, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0, 10)
OpenBtn.Text = "5 HUB"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Draggable = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
MainFrame.Active = true
MainFrame.Draggable = true

-- SIDEBAR & NAVIGATION
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 100, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SideBar.Parent = MainFrame

local function CreateTabBtn(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = SideBar
    return btn
end

local MainTabBtn = CreateTabBtn("Player", 10)
local CombatTabBtn = CreateTabBtn("Combat", 50)
local AuraTabBtn = CreateTabBtn("Aura", 90)
local EspTabBtn = CreateTabBtn("ESP", 130)

local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -110, 1, -10)
    page.Position = UDim2.new(0, 105, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = MainFrame
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)
    return page
end

local MainPage, CombatPage, AuraPage, EspPage = CreatePage(), CreatePage(), CreatePage(), CreatePage()
MainPage.Visible = true

-- HELPERS
local function AddToggle(name, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = parent
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 100) or Color3.fromRGB(50, 50, 70)
        callback(enabled)
    end)
end

-- PAGE CONTENT
AddToggle("Speed Boost", MainPage, function(v) _G.SpeedEnabled = v end)
AddToggle("Infinity Jump", MainPage, function(v) _G.JumpEnabled = v end)
AddToggle("Fly Mode", MainPage, function(v) _G.Flying = v end)
Instance.new("TextButton", MainPage).Text = "Rejoin" -- Simple Rejoin
MainPage:GetChildren()[#MainPage:GetChildren()].MouseButton1Click:Connect(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)

AddToggle("AutoClicker", CombatPage, function(v) _G.AutoClicker = v end)
AddToggle("Kill Aura", AuraPage, function(v) _G.KillAura = v end)
AddToggle("Wall Hacks", EspPage, function(v) _G.EspEnabled = v end)

-- TAB LOGIC
MainTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = true, false, false, false end)
CombatTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, true, false, false end)
AuraTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, false, true, false end)
EspTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, false, false, true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- FIXED WALL HACK (ESP) LOGIC
local function ApplyESP(plr)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        if not hrp:FindFirstChild("FiveHub_ESP") then
            local bgui = Instance.new("BillboardGui", hrp)
            bgui.Name = "FiveHub_ESP"
            bgui.AlwaysOnTop = true
            bgui.Size = UDim2.new(4, 0, 5.5, 0)
            
            local frame = Instance.new("Frame", bgui)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            Instance.new("UIStroke", frame).Color = Color3.new(1, 0, 0)
            
            local name = Instance.new("TextLabel", bgui)
            name.Text = plr.Name
            name.Size = UDim2.new(1, 0, 0, 20)
            name.Position = UDim2.new(0, 0, 0, -25)
            name.TextColor3 = Color3.new(1, 1, 1)
            name.BackgroundTransparency = 1
            
            -- Chams Effect
            local highlight = Instance.new("Highlight", plr.Character)
            highlight.Name = "FiveHub_Chams"
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.FillTransparency = 0.5
        end
    end
end

RunService.Heartbeat:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if _G.EspEnabled and hrp then
                ApplyESP(plr)
            else
                if hrp and hrp:FindFirstChild("FiveHub_ESP") then hrp.FiveHub_ESP:Destroy() end
                if plr.Character:FindFirstChild("FiveHub_Chams") then plr.Character.FiveHub_Chams:Destroy() end
            end
        end
    end
end)

-- JUMP / SPEED / CLICKER LOOPS (Same as V9)
UserInputService.JumpRequest:Connect(function()
    if _G.JumpEnabled then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end
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
end)
task.spawn(function()
    local VU = game:GetService("VirtualUser")
    while true do
        if _G.AutoClicker then VU:CaptureController() VU:ClickButton1(Vector2.new(0,0)) end
        task.wait(0.01 + (math.random() * 0.02))
    end
end)
