local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
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
    Discord = {
        Enabled = true,
        Invite = "yourdiscordinvitecode",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Access Key",
        Subtitle = "Enter the key to continue",
        Note = "Join our Discord for the key",
        FileName = "AccessKey",
        SaveKey = true
    }
})
local Tab = Window:CreateTab("Features", 4483362458) -- Using a Lucide icon ID

local InfiniteSprintToggle = Tab:CreateToggle({
    Name = "Infinite Sprint",
    CurrentValue = false,
    Flag = "InfiniteSprint",
    Callback = function(Value)
        Settings.InfiniteSprint = Value
        -- Add your Infinite Sprint logic here
    end
})

local ESPToggle = Tab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        Settings.ESPEnabled = Value
        -- Add your ESP logic here
    end
})

local AimlockToggle = Tab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = false,
    Flag = "Aimlock",
    Callback = function(Value)
        Settings.AimlockEnabled = Value
        -- Add your Aimlock logic here
    end
})
local function applySettings()
    -- Reapply settings like Infinite Sprint, ESP, and Aimlock
    -- Add your logic here
end

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(1) -- Wait for the character to load
    applySettings()
end)
