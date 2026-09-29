--========================================================--
-- MAWWWHUB NOTIFICATION SYSTEM
-- Muncul otomatis saat script di-load
--========================================================--
local Notification = {}

--========================================================--
-- CONFIG
--========================================================--
local COLORS = {
    Success = Color3.fromRGB(80, 220, 140),
    Error   = Color3.fromRGB(255, 100, 100),
    Info    = Color3.fromRGB(80, 170, 255),
    Warning = Color3.fromRGB(255, 200, 90),
}

local ICONS = {
    Success = "✅",
    Error   = "❌",
    Info    = "ℹ️",
    Warning = "⚠️",
}

--========================================================--
-- GET PLAYER INFO
--========================================================--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--========================================================--
-- CHECK DEVICE
--========================================================--
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

--========================================================--
-- NOTIFICATION GUI
--========================================================--
local notifyContainer = nil

local function getContainer()
    if notifyContainer and notifyContainer.Parent then
        return notifyContainer
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MawwwNotify"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    pcall(function() screenGui.Parent = CoreGui end)

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 320, 0, 0)
    container.Position = UDim2.new(0.5, -160, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = container

    notifyContainer = container
    return container
end

--========================================================--
-- SHOW NOTIFICATION
--========================================================--
function Notification.Show(opts)
    opts = opts or {}
    local title = opts.Title or "MawwwHub"
    local message = opts.Message or ""
    local type_ = opts.Type or "Info"
    local duration = opts.Duration or 5
    local icon = opts.Icon or ICONS[type_] or "ℹ️"
    local color = opts.Color or COLORS[type_] or COLORS.Info

    local container = getContainer()

    -- Card frame
    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(320, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.Position = UDim2.new(1, 400, 0, 0)  -- start off-screen right
    card.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = card

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 210, 255)),
    })
    grad.Rotation = 45
    grad.Parent = stroke

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = card

    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.fromOffset(30, 30)
    iconLabel.Position = UDim2.fromOffset(0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 22
    iconLabel.Text = icon
    iconLabel.TextXAlignment = Enum.TextXAlignment.Left
    iconLabel.Parent = card

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 0, 18)
    titleLabel.Position = UDim2.fromOffset(38, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = color
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = card

    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Name = "Message"
    msgLabel.Size = UDim2.new(1, -40, 0, 0)
    msgLabel.Position = UDim2.fromOffset(38, 22)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 11
    msgLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.TextWrapped = true
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    msgLabel.Text = message
    msgLabel.Parent = card

    -- Separator bar
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.Position = UDim2.new(0, 0, 1, -2)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = card

    -- Animate slide in
    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()

    -- Play sound
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = type_ == "Error" and "rbxassetid://5251135118" or "rbxassetid://5251135118"
        sound.Volume = 0.3
        sound.Parent = card
        sound:Play()
    end)

    -- Auto dismiss
    task.delay(duration, function()
        if not card.Parent then return end
        local out = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(-1, -400, 0, 0),
            BackgroundTransparency = 1,
        })
        out:Play()
        out.Completed:Connect(function()
            card:Destroy()
        end)
    end)

    return card
end

--========================================================--
-- SHORTCUT METHODS
--========================================================--
function Notification.Success(title, message, duration)
    return Notification.Show({
        Title = title or "Success",
        Message = message or "",
        Type = "Success",
        Duration = duration or 5,
    })
end

function Notification.Error(title, message, duration)
    return Notification.Show({
        Title = title or "Error",
        Message = message or "",
        Type = "Error",
        Duration = duration or 6,
    })
end

function Notification.Info(title, message, duration)
    return Notification.Show({
        Title = title or "Info",
        Message = message or "",
        Type = "Info",
        Duration = duration or 5,
    })
end

function Notification.Warning(title, message, duration)
    return Notification.Show({
        Title = title or "Warning",
        Message = message or "",
        Type = "Warning",
        Duration = duration or 5,
    })
end

--========================================================--
-- WELCOME POPUP (Muncul saat login Roblox pertama kali)
--========================================================--
function Notification.WelcomePopup(opts)
    opts = opts or {}
    local hasKey = opts.HasKey or false
    local playerName = Player.DisplayName or Player.Name

    -- Build welcome message
    local title, message, type_

    if hasKey then
        title = "👋 Selamat Datang Kembali, " .. playerName .. "!"
        message = "Key kamu terdeteksi. Sistem sedang memverifikasi...\n\n⏳ Tunggu sebentar ya!"
        type_ = "Info"
    else
        title = "🎉 Selamat Datang di MawwwHub!"
        message = "Halo " .. playerName .. "!\n\n" ..
                  "Sepertinya kamu belum memasukkan key.\n" ..
                  "Silakan masukkan key untuk mengakses script.\n\n" ..
                  "💡 Belum punya key? Klik tombol BELI KEY di UI."
        type_ = "Warning"
    end

    return Notification.Show({
        Title = title,
        Message = message,
        Type = type_,
        Duration = 7,
    })
end

--========================================================--
-- CLEAR ALL NOTIFICATIONS
--========================================================--
function Notification.ClearAll()
    if notifyContainer then
        for _, child in ipairs(notifyContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
end

--========================================================--
-- RETURN
--========================================================--
return Notification
