-- LocalScript (place in StarterPlayerScripts or similar)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- === Anti-Crash for Other Players ===
local function applyAntiCrashToPlayer(player)
    local function onCharacterAdded(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        
        local animator = hum:WaitForChild("Animator", 5)
        if not animator then return end

        -- Stop any new animation from playing properly
        animator.AnimationPlayed:Connect(function(track)
            track:AdjustSpeed(-math.huge)
            track:Stop()
        end)

        -- Stop currently playing tracks
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(-math.huge)
            track:Stop()
        end
    end

    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Apply to existing players (except self)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= localPlayer then
        applyAntiCrashToPlayer(plr)
    end
end

-- Apply to new players
Players.PlayerAdded:Connect(function(plr)
    if plr ~= localPlayer then
        applyAntiCrashToPlayer(plr)
    end
end)

-- === Crashing Loop with Toggle ===
local crashingEnabled = false
local crashLoop

local function startCrashing()
    if crashLoop then return end
    
    crashLoop = task.spawn(function()
        while crashingEnabled do
            for i = 1, 5 do
                if not crashingEnabled then break end
                
                local anim = Instance.new("Animation")
                anim.AnimationId = "http" .. HttpService:GenerateGUID() .. "=108713182294229"
                
                pcall(function()
                    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                    local hum = character:FindFirstChild("Humanoid")
                    if not hum then return end
                    local animator = hum:FindFirstChild("Animator")
                    if not animator then return end
                    
                    local track = animator:LoadAnimation(anim)
                    track:Play(21474836471234)  -- absurd playback value
                    RunService.PreRender:Wait()
                    track:AdjustSpeed(-math.huge)
                end)
            end
            task.wait()  -- small delay to prevent complete client freeze
        end
        crashLoop = nil
    end)
end

local function stopCrashing()
    crashingEnabled = false
    if crashLoop then
        task.cancel(crashLoop)  -- Roblox supports task.cancel in newer engines
        crashLoop = nil
    end
end

-- === GUI Toggle ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CrashToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 60)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 100, 100)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.4, 0)
title.BackgroundTransparency = 1
title.Text = "Crash Control"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0.4, 0)
toggleButton.Position = UDim2.new(0.05, 0, 0.5, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.Text = "Crash: OFF"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 16
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
    crashingEnabled = not crashingEnabled
    if crashingEnabled then
        toggleButton.Text = "Crash: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        startCrashing()
    else
        toggleButton.Text = "Crash: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        stopCrashing()
    end
end)

-- Optional: Make frame draggable
local dragging = false
local dragInput, mousePos, framePos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end
end)

print("Anti-crash + toggleable crasher loaded")
