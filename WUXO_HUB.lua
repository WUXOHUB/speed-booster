--// WUXO HUB BOOSTER with Velocity Speed Bypass

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local targetSpeed = 28.5 -- default speed
local enabled = false
local connection

-- Functions to enable/disable speed bypass
local function enableSpeedBypass()
    if connection then connection:Disconnect() end

    connection = RunService.Stepped:Connect(function()
        if not enabled then return end

        local character = player.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart then
            local state = humanoid:GetState()
            if state ~= Enum.HumanoidStateType.Seated and state ~= Enum.HumanoidStateType.Dead then
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    rootPart.Velocity = Vector3.new(
                        moveDirection.X * targetSpeed,
                        rootPart.Velocity.Y,
                        moveDirection.Z * targetSpeed
                    )
                end
            end
        end
    end)
end

local function disableSpeedBypass()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WuxoHub_Booster"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel")
title.Text = "WUXO HUB BOOSTER"
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.TextColor3 = Color3.fromRGB(220, 235, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Status Label
local status = Instance.new("TextLabel")
status.Text = "Ready"
status.Size = UDim2.new(1, -20, 0, 24)
status.Position = UDim2.new(0, 10, 0, 32)
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = mainFrame

-- TextBox to set speed
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 34)
speedBox.Position = UDim2.new(0, 10, 0, 62)
speedBox.PlaceholderText = "Enter Speed"
speedBox.Text = tostring(targetSpeed)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
speedBox.Parent = mainFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

-- Toggle (green/gray style)
local function makeToggle(text, yPos, default)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 38)
    holder.Position = UDim2.new(0, 10, 0, yPos)
    holder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    holder.Parent = mainFrame
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.fromOffset(38, 20)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, -10)
    toggleBtn.Text = ""
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(60, 60, 60)
    toggleBtn.Parent = holder
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local enabledState = default

    toggleBtn.MouseButton1Click:Connect(function()
        enabledState = not enabledState
        toggleBtn.BackgroundColor3 = enabledState and Color3.fromRGB(0,200,120) or Color3.fromRGB(60,60,60)
        enabled = enabledState
        if enabled then
            enableSpeedBypass()
            status.Text = "speed: ON"
        else
            disableSpeedBypass()
            status.Text = "speed: OFF"
        end
    end)
end

-- Create toggle
makeToggle("Enable Speed", 110, false)

-- Update speed from TextBox
speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newSpeed = tonumber(speedBox.Text)
        if newSpeed and newSpeed > 0 and newSpeed <= 200 then
            targetSpeed = newSpeed
        else
            speedBox.Text = tostring(targetSpeed)
        end
    end
end)

-- Drag system
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Reapply speed on respawn
player.CharacterAdded:Connect(function()
    if enabled then task.wait(0.5) enableSpeedBypass() end
end)
