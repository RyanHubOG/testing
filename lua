--// Loader.lua for Roblox
--// Features: Infinite Sprint, Enhanced ESP, Right-Click Predictive Head Aimlock, Aimlock FOV, Player FOV, Copy Server Link, Rayfield UI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    InfiniteSprint = false,
    ESPEnabled = false,
    AimlockEnabled = false,
    AimlockFOV = 150,
    AimlockActive = false,
    PlayerFOV = Camera.FieldOfView,
    AimlockPrediction = 0.18, -- Default prediction factor
}

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "Criminality Enhancer",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by YourName",
    Theme = "Dark",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CriminalityScripts",
        FileName = "Settings"
    },
    KeySystem = false
})

-- Features Tab
local Tab = Window:CreateTab("Features", 4483362458)

-- ESP Table
local ESPs = {}

-- ESP Functions
local function createESP(player)
    if ESPs[player] then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.Adornee = character.HumanoidRootPart
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = game.CoreGui

    -- Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(0,1,0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    -- Health Bar
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 0.2, 0)
    healthBar.Position = UDim2.new(0,0,0.4,0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = billboard

    -- Distance Label
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0,0,0.6,0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.new(1,1,0)
    distLabel.TextStrokeTransparency = 0
    distLabel.Font = Enum.Font.SourceSansBold
    distLabel.TextScaled = true
    distLabel.Text = ""
    distLabel.Parent = billboard

    ESPs[player] = {Billboard = billboard, Name = nameLabel, HealthBar = healthBar, Distance = distLabel}
end

local function removeESP(player)
    if ESPs[player] then
        ESPs[player].Billboard:Destroy()
        ESPs[player] = nil
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if Settings.ESPEnabled then
                if not ESPs[player] then createESP(player) end
                local hum = player.Character.Humanoid
                local root = player.Character.HumanoidRootPart
                ESPs[player].HealthBar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 0.2, 0)
                local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                ESPs[player].Distance.Text = string.format("%.0f studs", distance)
            else
                removeESP(player)
            end
        else
            removeESP(player)
        end
    end
end

-- Infinite Sprint
local function runInfiniteSprint()
    pcall(function()
        for i,v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v,"S") then
                v.S = 100
            end
        end
    end)
end

-- Predictive Head Aimlock
local function aimAtTarget(target)
    if target and target:FindFirstChild("Head") and target:FindFirstChild("HumanoidRootPart") then
        local cam = workspace.CurrentCamera
        local head = target.Head
        local root = target.HumanoidRootPart

        -- Prediction
        local predictedPos = head.Position + root.Velocity * (Settings.AimlockPrediction or 0.18)
        local direction = (predictedPos - cam.CFrame.Position).Unit
        cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + direction)
    end
end

local function runAimlock()
    if not Settings.AimlockActive then return end
    local closest
    local shortest = Settings.AimlockFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    if closest then
        aimAtTarget(closest.Character)
    end
end

-- Run Features Each Frame
RunService.RenderStepped:Connect(function()
    if Settings.InfiniteSprint then runInfiniteSprint() end
    if Settings.ESPEnabled then updateESP() end
    if Settings.AimlockEnabled then runAimlock() end
    Camera.FieldOfView = Settings.PlayerFOV
end)

-- Rayfield Toggles and Sliders
Tab:CreateToggle({
    Name = "Infinite Sprint",
    CurrentValue = Settings.InfiniteSprint,
    Flag = "InfiniteSprint",
    Callback = function(Value) Settings.InfiniteSprint = Value end
})

Tab:CreateToggle({
    Name = "ESP",
    CurrentValue = Settings.ESPEnabled,
    Flag = "ESP",
    Callback = function(Value)
        Settings.ESPEnabled = Value
        if not Value then
            for _,v in pairs(ESPs) do v:Destroy() end
            ESPs = {}
        end
    end
})

Tab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = Settings.AimlockEnabled,
    Flag = "Aimlock",
    Callback = function(Value) Settings.AimlockEnabled = Value end
})

Tab:CreateSlider({
    Name = "Aimlock FOV",
    Range = {50, 500},
    Increment = 5,
    Suffix = "px",
    CurrentValue = Settings.AimlockFOV,
    Flag = "AimlockFOV",
    Callback = function(Value) Settings.AimlockFOV = Value end
})

Tab:CreateSlider({
    Name = "Aimlock Prediction",
    Range = {0, 0.5},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = Settings.AimlockPrediction,
    Flag = "AimlockPrediction",
    Callback = function(Value) Settings.AimlockPrediction = Value end
})

Tab:CreateSlider({
    Name = "Player FOV",
    Range = {70, 120},
    Increment = 1,
    Suffix = "",
    CurrentValue = Settings.PlayerFOV,
    Flag = "PlayerFOV",
    Callback = function(Value) Settings.PlayerFOV = Value end
})

Tab:CreateButton({
    Name = "Copy Server Link",
    Callback = function()
        local serverLink = "https://www.roblox.com/games/"..game.PlaceId.."/"..game.JobId
        setclipboard(serverLink)
    end
})

-- Right-Click Aimlock Activation
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.AimlockActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.AimlockActive = false
    end
end)

-- Reset ESP on respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    if Settings.ESPEnabled then updateESP() end
end)

print("Loader Enhanced: Infinite Sprint, ESP with Health/Distance, Right-Click Predictive Head Aimlock, Aimlock FOV, Player FOV, Copy Server Link ready!")
