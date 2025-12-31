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
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GLOBAL STATES
_G.SpeedEnabled, _G.JumpEnabled, _G.AutoClicker, _G.Flying, _G.KillAura, _G.EspEnabled = false, false, false, false, false, false
_G.NoClip, _G.FullBright, _G.SuperFastClick = false, false, false
_G.WalkSpeedValue = 100 
_G.MenuKeybind = Enum.KeyCode.K -- Change "K" to any key you prefer

-- UI SETUP (Rounded & Sidebar)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FiveHub_Final_V17"

local function Round(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = element
end

-- OPEN/CLOSE BUTTON
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 80, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0, 10)
OpenBtn.Text = "5 HUB"
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Draggable = true
Round(OpenBtn, 10)

-- MAIN WINDOW
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
Round(SideBar, 12)

local Title = Instance.new("TextLabel", SideBar)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "5 HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

-- PAGE SYSTEM
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

-- TABS & CONTENT
CreateTab("Player", 50, MainPage)
CreateTab("Combat", 90, CombatPage)
CreateTab("Extras", 130, ExtraPage)
CreateTab("ESP", 170, EspPage)

AddToggle("Force Speed", MainPage, function(v) _G.SpeedEnabled = v end)
AddToggle("Inf Jump", MainPage, function(v) _G.JumpEnabled = v end)
AddToggle("Fly Mode", MainPage, function(v) _G.Flying = v end)

AddToggle("AutoClick Center", CombatPage, function(v) _G.AutoClicker = v end)
AddToggle("Super Fast Mode", CombatPage, function(v) _G.SuperFastClick = v end)
AddToggle("Kill Aura", CombatPage, function(v) _G.KillAura = v end)

AddToggle("NoClip", ExtraPage, function(v) _G.NoClip = v end)
AddToggle("FullBright", ExtraPage, function(v) _G.FullBright = v end)

AddToggle("Wall Hacks", EspPage, function(v) _G.EspEnabled = v end)

--- 🔥 CORE SYSTEMS 🔥 ---

-- KEYBIND SYSTEM
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == _G.MenuKeybind then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- SPEED BYPASS
RunService.Stepped:Connect(function()
    if _G.SpeedEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (_G.WalkSpeedValue / 50))
        end
    end
end)

-- AUTO-CLICKER (CENTER SCREEN)
task.spawn(function()
    while true do
        if _G.AutoClicker then
            local CX, CY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(CX, CY))
            task.wait(_G.SuperFastClick and 0.001 or 0.02)
        else
            task.wait(0.5)
        end
    end
end)

-- ESP / WALL HACKS (FORCE HIGHLIGHT)
RunService.Heartbeat:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("FiveHub_High")
            if _G.EspEnabled then
                if not highlight then
                    local h = Instance.new("Highlight", plr.Character)
                    h.Name = "FiveHub_High"
                    h.FillColor = Color3.new(1, 0, 0)
                    h.AlwaysOnTop = true
                end
            elseif highlight then highlight:Destroy() end
        end
    end
end)

-- JUMP & UI TOGGLE
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
UserInputService.JumpRequest:Connect(function()
    if _G.JumpEnabled and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
