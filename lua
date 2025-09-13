--// Loader.lua with Rayfield UI and full logic
--// Features: Infinite Sprint, ESP, Aimlock, Auto-reset on death, Rayfield UI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    InfiniteSprint = false,
    AimlockEnabled = false,
    ESPEnabled = false,
    AimlockFOV = 150,
}

-- Load Rayfield
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
    KeySystem = false -- Set true if you want key system
})

-- Create Features Tab
local Tab = Window:CreateTab("Features", 4483362458)

-- Toggles
Tab:CreateToggle({
    Name = "Infinite Sprint",
    CurrentValue = Settings.InfiniteSprint,
    Flag = "InfiniteSprint",
    Callback = function(Value)
        Settings.InfiniteSprint = Value
    end
})

Tab:CreateToggle({
    Name = "ESP",
    CurrentValue = Settings.ESPEnabled,
    Flag = "ESP",
    Callback = function(Value)
        Settings.ESPEnabled = Value
    end
})

Tab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = Settings.AimlockEnabled,
    Flag = "Aimlock",
    Callback = function(Value)
        Settings.AimlockEnabled = Value
    end
})

-- ESP Table
local ESPBoxes = {}

local function resetESP()
    for _, box in pairs(ESPBoxes) do
        box:Remove()
    end
    ESPBoxes = {}
end

-- Logic functions
local function runInfiniteSprint()
    if Settings.InfiniteSprint then
        pcall(function()
            for i,v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v,"S") then
                    v.S = 100
                end
            end
        end)
    end
end

local function runESP()
    for i,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local part = v.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                if not ESPBoxes[v] then
                    local box = Drawing.new("Square")
                    box.Color = Color3.fromRGB(0, 255, 0)
                    box.Thickness = 2
                    box.Transparency = 1
                    box.Filled = false
                    ESPBoxes[v] = box
                end
                ESPBoxes[v].Position = Vector2.new(pos.X - 25, pos.Y - 50)
                ESPBoxes[v].Size = Vector2.new(50,100)
            else
                if ESPBoxes[v] then ESPBoxes[v].Visible = false end
            end
        end
    end
end

local function runAimlock()
    local closest
    local shortest = Settings.AimlockFOV
    for i,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortest then
                    shortest = distance
                    closest = v
                end
            end
        end
    end
    if closest and closest.Character then
        Mouse.Target = closest.Character.HumanoidRootPart
    end
end

-- Apply all features
local function applyFeatures()
    RunService.RenderStepped:Connect(function()
        if Settings.InfiniteSprint then runInfiniteSprint() end
        if Settings.ESPEnabled then runESP() else resetESP() end
        if Settings.AimlockEnabled then runAimlock() end
    end)
end

-- Initial application
applyFeatures()

-- Reset features on respawn
LocalPlayer.CharacterAdded:Connect(function()
    resetESP()
    wait(0.5)
    applyFeatures()
end)

print("Loader Enhanced: Infinite Sprint, ESP, Aimlock, Rayfield UI ready! Auto-reset on death enabled.")
