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
local Camera = workspace.CurrentCamera

-- GLOBAL STATES
_G.SpeedEnabled, _G.JumpEnabled, _G.AutoClicker, _G.Flying, _G.KillAura, _G.EspEnabled = false, false, false, false, false, false
_G.WalkSpeedValue, _G.JumpPowerValue, _G.FlySpeedValue = 100, 100, 50

-- UI SETUP (Sidebar Style)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FiveHub_V9"
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

-- SIDEBAR & PAGES (Code simplified for brevity, same as V8)
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

-- TOGGLE & ACTION FUNCTIONS
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

AddToggle("Speed Boost", MainPage, function(v) _G.SpeedEnabled = v end)
AddToggle("Infinity Jump", MainPage, function(v) _G.JumpEnabled = v end)
AddToggle("Fly Mode", MainPage, function(v) _G.Flying = v end)
AddToggle("Box ESP", EspPage, function(v) _G.EspEnabled = v end)

-- BOX ESP LOGIC
local function CreateBox()
    local Box = Instance.new("Frame")
    Box.Name = "ESPBox"
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 2
    Box.BorderColor3 = Color3.fromRGB(255, 0, 0)
    Box.Size = UDim2.new(0, 0, 0, 0)
    Box.Visible = false
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, -20)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = 12
    Label.Parent = Box
    
    return Box
end

RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local boxName = plr.Name .. "_ESP"
            local Box = ScreenGui:FindFirstChild(boxName) or CreateBox()
            Box.Name = boxName
            Box.Parent = ScreenGui
            
            if _G.EspEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local size = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y)
                    Box.Size = UDim2.new(0, size * 0.7, 0, size)
                    Box.Position = UDim2.new(0, pos.X - Box.Size.X.Offset / 2, 0, pos.Y - Box.Size.Y.Offset / 2)
                    Box.Visible = true
                    Box.TextLabel.Text = plr.Name
                else
                    Box.Visible = false
                end
            else
                Box.Visible = false
            end
        end
    end
end)

-- TABS LOGIC
MainTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = true, false, false, false end)
CombatTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, true, false, false end)
AuraTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, false, true, false end)
EspTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, CombatPage.Visible, AuraPage.Visible, EspPage.Visible = false, false, false, true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
