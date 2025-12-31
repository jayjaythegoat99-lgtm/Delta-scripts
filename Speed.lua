local CorrectKey = "MYPRIVATEKEY"

-- PROTECTION
if _G.Key ~= CorrectKey then
    game.Players.LocalPlayer:Kick("Access Denied: Incorrect Key")
    return
end

-- SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATES
_G.SpeedEnabled, _G.JumpEnabled, _G.AutoClicker, _G.Flying, _G.KillAura, _G.EspEnabled = false, false, false, false, false, false
_G.NoClip, _G.FullBright = false, false
_G.WalkSpeedValue, _G.JumpPowerValue = 100, 100

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FiveHub_Rounded"

-- ROUNDING FUNCTION (Reusable)
local function RoundElement(element, radius)
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
RoundElement(OpenBtn, 10)

-- MAIN FRAME
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
RoundElement(MainFrame, 12)

-- SIDEBAR
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 100, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SideBar.BorderSizePixel = 0
RoundElement(SideBar, 12)

-- TITLE
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0, 100, 0, 30)
Title.Text = "5 HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local function CreateTabBtn(text, posY)
    local btn = Instance.new("TextButton", SideBar)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, posY + 30)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    RoundElement(btn, 6)
    return btn
end

local MainTabBtn = CreateTabBtn("Player", 10)
local ExtraTabBtn = CreateTabBtn("Extras", 50)
local EspTabBtn = CreateTabBtn("ESP", 90)

-- PAGES
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

local MainPage, ExtraPage, EspPage = CreatePage(), CreatePage(), CreatePage()
MainPage.Visible = true

-- HELPERS
local function AddToggle(name, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    RoundElement(btn, 6)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 100) or Color3.fromRGB(50, 50, 70)
        callback(enabled)
    end)
end

-- CONTENT
AddToggle("Speed Boost", MainPage, function(v) _G.SpeedEnabled = v end)
AddToggle("Infinity Jump", MainPage, function(v) _G.JumpEnabled = v end)
AddToggle("NoClip", ExtraPage, function(v) _G.NoClip = v end)
AddToggle("FullBright", ExtraPage, function(v) _G.FullBright = v end)
AddToggle("Wall Hacks", EspPage, function(v) _G.EspEnabled = v end)

-- LOGIC LOOPS (NoClip, FullBright, ESP, etc. remain the same as V11)
RunService.Stepped:Connect(function()
    if _G.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- TAB NAVIGATION & TOGGLE VISIBILITY
MainTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, ExtraPage.Visible, EspPage.Visible = true, false, false end)
ExtraTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, ExtraPage.Visible, EspPage.Visible = false, true, false end)
EspTabBtn.MouseButton1Click:Connect(function() MainPage.Visible, ExtraPage.Visible, EspPage.Visible = false, false, true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
