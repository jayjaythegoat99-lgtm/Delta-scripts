-- Delta Stealth Hub v1.7 (Final)
-- KEY_HOLDER (The GitHub Action updates the key below)
local CorrectKey = "MYPRIVATEKEY" 

-- KEY PROTECTION
if _G.Key ~= CorrectKey then
    game.Players.LocalPlayer:Kick("Access Denied: Incorrect or Missing Key.")
    return
end

-- SERVICES
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 280)
Frame.Position = UDim2.new(0.1, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    return btn
end

-- BUTTONS
local SBtn = createBtn("Stealth Speed: OFF", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(40, 40, 40))
local JBtn = createBtn("Infinite Jump: OFF", UDim2.new(0.05, 0, 0.18, 0), Color3.fromRGB(40, 40, 40))
local EBtn = createBtn("ESP / Wallhack: OFF", UDim2.new(0.05, 0, 0.31, 0), Color3.fromRGB(40, 40, 40))
local ABtn = createBtn("Smooth Aimbot: OFF", UDim2.new(0.05, 0, 0.44, 0), Color3.fromRGB(40, 40, 40))
local HBtn = createBtn("Server Hop", UDim2.new(0.05, 0, 0.57, 0), Color3.fromRGB(70, 30, 100))
local KBtn = createBtn("Copy Key Link", UDim2.new(0.05, 0, 0.70, 0), Color3.fromRGB(0, 100, 200))
local MBtn = createBtn("Minimize", UDim2.new(0.05, 0, 0.85, 0), Color3.fromRGB(120, 30, 30))

-- STATES
local speedActive, infJumpActive, espActive, aimbotActive = false, false, false, false

-- SPEED LOGIC (28.8 Stealth)
RunService.Stepped:Connect(function()
    if speedActive then
        pcall(function()
            local hum = player.Character.Humanoid
            local root = player.Character.HumanoidRootPart
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * (28.8 / 55))
            end
        end)
    end
end)

-- ESP LOGIC
RunService.RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end
end)

-- AIMBOT LOGIC
local function getClosest()
    local target, dist = nil, math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            local pos, vis = camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mDist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mDist < dist then dist = mDist; target = v end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if aimbotActive and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getClosest()
        if t then camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, t.Character.Head.Position), 0.1) end
    end
end)

-- JUMP LOGIC
UserInputService.JumpRequest:Connect(function()
    if infJumpActive then player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

-- BUTTON CLICKS
SBtn.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    SBtn.Text = speedActive and "Speed: ON" or "Speed: OFF"
    SBtn.BackgroundColor3 = speedActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

JBtn.MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    JBtn.Text = infJumpActive and "Inf Jump: ON" or "Inf Jump: OFF"
    JBtn.BackgroundColor3 = infJumpActive and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(40, 40, 40)
end)

EBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    EBtn.BackgroundColor3 = espActive and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(40, 40, 40)
end)

ABtn.MouseButton1Click:Connect(function()
    aimbotActive = not aimbotActive
    ABtn.BackgroundColor3 = aimbotActive and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)
end)

HBtn.MouseButton1Click:Connect(function()
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, v in pairs(Servers.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
            break
        end
    end
end)

KBtn.MouseButton1Click:Connect(function()
    setclipboard("YOUR_LINKVERTISE_LINK_HERE")
end)

MBtn.MouseButton1Click:Connect(function()
    local mini = (Frame.Size.Y.Offset == 280)
    Frame.Size = mini and UDim2.new(0, 200, 0, 40) or UDim2.new(0, 200, 0, 280)
    MBtn.Text = mini and "+" or "Minimize"
end)
