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
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATES
_G.SpeedEnabled, _G.JumpEnabled, _G.AutoClicker, _G.Flying, _G.KillAura, _G.EspEnabled = false, false, false, false, false, false
_G.NoClip, _G.FullBright = false, false
_G.WalkSpeedValue = 100 
_G.FlySpeedValue = 50
_G.AuraRange = 15

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FiveHub_Final_V14"

local function Round(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = element
end

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 80, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0, 10)
OpenBtn.Text = "5 HUB"
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Draggable = true
Round(OpenBtn, 10)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
Round(MainFrame, 12)

local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 100, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SideBar.BorderSizePixel = 0
Round(SideBar, 12)

local Title = Instance.new("TextLabel", SideBar)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "5 HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

-- PAGE NAVIGATION
local function CreatePage()
    local page = Instance.new("ScrollingFrame", MainFrame)
    page.Size = UDim2.new(1, -115, 1, -20)
    page.Position = UDim2.new(0, 105, 0, 10)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 0
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)
    return page
end

local MainPage, CombatPage, ExtraPage, EspPage = CreatePage(), CreatePage(), CreatePage(), CreatePage()
MainPage.Visible = true

local function AddToggle(name, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Round(btn, 6)
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 100) or Color3.fromRGB(50, 50, 70)
        callback(enabled)
    end)
end

-- TABS
local function CreateTab(text, pos, page)
    local btn = Instance.new("TextButton", SideBar)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, pos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Round(btn, 6)
    btn.MouseButton1Click:Connect(function()
        MainPage.Visible, CombatPage.Visible, ExtraPage.Visible, EspPage.Visible = false, false, false, false
        page.Visible = true
    end)
end

CreateTab("Player", 50, MainPage)
CreateTab("Combat", 90, CombatPage)
CreateTab("Extras", 130, ExtraPage)
CreateTab("ESP", 170, EspPage)

-- CONTENT
AddToggle("Force Speed", MainPage, function(v) _G.SpeedEnabled = v end)
AddToggle("Inf Jump", MainPage, function(v) _G.JumpEnabled = v end)
AddToggle("Fly Mode", MainPage, function(v) _G.Flying = v end)
AddToggle("AutoClick", CombatPage, function(v) _G.AutoClicker = v end)
AddToggle("Kill Aura", CombatPage, function(v) _G.KillAura = v end)
AddToggle("NoClip", ExtraPage, function(v) _G.NoClip = v end)
AddToggle("FullBright", ExtraPage, function(v) _G.FullBright = v end)
AddToggle("Wall Hacks", EspPage, function(v) _G.EspEnabled = v end)

-- 🔥 CORE FORCE LOGIC 🔥

-- Speed Bypass (CFrame Movement)
RunService.Stepped:Connect(function()
    if _G.SpeedEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (_G.WalkSpeedValue / 50))
        end
    end
end)

-- Inf Jump Bypass
UserInputService.JumpRequest:Connect(function()
    if _G.JumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- Wall Hacks (Highlight Bypass)
RunService.Heartbeat:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("FiveHub_Highlight")
            if _G.EspEnabled then
                if not highlight then
                    local h = Instance.new("Highlight", plr.Character)
                    h.Name = "FiveHub_Highlight"
                    h.FillColor = Color3.new(1, 0, 0)
                    h.AlwaysOnTop = true
                end
            elseif highlight then highlight:Destroy() end
        end
    end
end)

-- NoClip & Fly Logic
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if _G.NoClip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        if _G.Flying and hrp then
            hum.PlatformStand = true
            hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.FlySpeedValue
        elseif hum then
            hum.PlatformStand = false
        end
    end
end)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
