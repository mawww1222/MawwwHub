--========================================================--
-- MAWWWHUB NOTIFICATION SYSTEM v5.0
-- Center Position + Roblox Asset Photo
--========================================================--
local Notification = {}

--========================================================--
-- SERVICES
--========================================================--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--========================================================--
-- 🎨 ASSET ID FOTO (GANTI DI SINI)
--========================================================--
local ASSET_LOGO = "88250532753444"  -- Roblox asset ID foto MawwwHub

--========================================================--
-- THEME
--========================================================--
local THEME = {
    Background      = Color3.fromRGB(10, 8, 18),
    CardBackground  = Color3.fromRGB(18, 14, 28),
    TextPrimary     = Color3.fromRGB(245, 245, 255),
    TextSecondary   = Color3.fromRGB(155, 155, 175),
    TextTertiary    = Color3.fromRGB(100, 100, 125),
}

local TYPE_THEME = {
    Success = {
        Color1 = Color3.fromRGB(52, 211, 153),
        Color2 = Color3.fromRGB(16, 185, 129),
        Glow   = Color3.fromRGB(52, 211, 153),
        Icon   = "✓",
        Title  = "Berhasil",
    },
    Error = {
        Color1 = Color3.fromRGB(248, 113, 113),
        Color2 = Color3.fromRGB(239, 68, 68),
        Glow   = Color3.fromRGB(248, 113, 113),
        Icon   = "✕",
        Title  = "Error",
    },
    Info = {
        Color1 = Color3.fromRGB(96, 165, 250),
        Color2 = Color3.fromRGB(59, 130, 246),
        Glow   = Color3.fromRGB(96, 165, 250),
        Icon   = "i",
        Title  = "Info",
    },
    Warning = {
        Color1 = Color3.fromRGB(251, 191, 36),
        Color2 = Color3.fromRGB(245, 158, 11),
        Glow   = Color3.fromRGB(251, 191, 36),
        Icon   = "!",
        Title  = "Peringatan",
    },
    Loading = {
        Color1 = Color3.fromRGB(167, 139, 250),
        Color2 = Color3.fromRGB(139, 92, 246),
        Glow   = Color3.fromRGB(167, 139, 250),
        Icon   = "⟳",
        Title  = "Memuat",
    },
    Premium = {
        Color1 = Color3.fromRGB(192, 132, 252),
        Color2 = Color3.fromRGB(236, 72, 153),
        Glow   = Color3.fromRGB(192, 132, 252),
        Icon   = "★",
        Title  = "Premium",
    },
}

local CONFETTI_COLORS = {
    Color3.fromRGB(255, 87, 87),
    Color3.fromRGB(255, 193, 87),
    Color3.fromRGB(87, 255, 145),
    Color3.fromRGB(87, 193, 255),
    Color3.fromRGB(193, 87, 255),
    Color3.fromRGB(255, 87, 193),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 214, 87),
}

--========================================================--
-- STATE
--========================================================--
local notifyGui = nil
local notifyContainer = nil
local activeNotifications = {}
local MAX_NOTIFICATIONS = 3

--========================================================--
-- HELPER
--========================================================--
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function initGui()
    if notifyGui and notifyGui.Parent then
        return
    end

    local existing = CoreGui:FindFirstChild("MawwwNotifications")
    if existing then
        existing:Destroy()
    end

    notifyGui = new("ScreenGui", {
        Name = "MawwwNotifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
        Parent = CoreGui,
    })

    local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

    notifyContainer = new("Frame", {
        Name = "Container",
        Size = UDim2.new(0, isMobile and 300 or 340, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = notifyGui,
    })

    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = notifyContainer,
    })
end

--========================================================--
-- CONFETTI
--========================================================--
local function spawnConfetti(parentFrame, duration)
    duration = duration or 3
    local startTime = tick()

    local confettiLayer = new("Frame", {
        Name = "ConfettiLayer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 100,
        ClipsDescendants = true,
        Parent = parentFrame,
    })

    task.spawn(function()
        while tick() - startTime < duration do
            for i = 1, 6 do
                local confetti = new("Frame", {
                    Size = UDim2.fromOffset(math.random(6, 12), math.random(10, 18)),
                    Position = UDim2.new(
                        math.random() / 10 + 0.45,
                        math.random(-60, 60),
                        -0.05, 0
                    ),
                    BackgroundColor3 = CONFETTI_COLORS[math.random(1, #CONFETTI_COLORS)],
                    BorderSizePixel = 0,
                    Rotation = math.random(0, 360),
                    ZIndex = 101,
                    Parent = confettiLayer,
                })
                new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = confetti })

                local fallDuration = math.random(15, 25) / 10
                local xDrift = math.random(-100, 100)

                TweenService:Create(confetti, TweenInfo.new(fallDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(
                        confetti.Position.X.Scale + xDrift / 500,
                        confetti.Position.X.Offset + xDrift,
                        1.2, 0
                    ),
                    Rotation = confetti.Rotation + math.random(180, 720),
                }):Play()

                TweenService:Create(confetti, TweenInfo.new(fallDuration * 0.7), {
                    BackgroundTransparency = 1,
                }):Play()

                task.delay(fallDuration, function()
                    if confetti.Parent then confetti:Destroy() end
                end)
            end
            task.wait(0.05)
        end
    end)

    task.delay(duration + 3, function()
        if confettiLayer.Parent then confettiLayer:Destroy() end
    end)
end

--========================================================--
-- PARTICLE TRAIL
--========================================================--
local function spawnParticleTrail(parentFrame, color1, color2, duration)
    duration = duration or 4
    local startTime = tick()
    local particleIds = {
        "rbxassetid://5014978988",
        "rbxassetid://5014979922",
        "rbxassetid://5014978844",
        "rbxassetid://5028857084",
    }

    task.spawn(function()
        while tick() - startTime < duration do
            local sparkle = new("ImageLabel", {
                Size = UDim2.fromOffset(math.random(12, 22), math.random(12, 22)),
                Position = UDim2.new(
                    math.random() / 4 + 0.38,
                    math.random(-30, 30),
                    math.random() / 3 + 0.3,
                    math.random(-20, 20)
                ),
                BackgroundTransparency = 1,
                Image = particleIds[math.random(1, #particleIds)],
                ImageColor3 = math.random() > 0.5 and color1 or (math.random() > 0.5 and color2 or Color3.fromRGB(255, 255, 255)),
                ImageTransparency = 0.2,
                Rotation = math.random(0, 360),
                ZIndex = 6,
                Parent = parentFrame,
            })

            local targetX = sparkle.Position.X.Scale + (math.random() - 0.5) * 0.3
            local targetY = sparkle.Position.Y.Scale - 0.3

            TweenService:Create(sparkle, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(targetX, sparkle.Position.X.Offset, targetY, sparkle.Position.Y.Offset),
                ImageTransparency = 1,
                Rotation = sparkle.Rotation + math.random(180, 540),
                Size = UDim2.fromOffset(6, 6),
            }):Play()

            task.delay(1.5, function()
                if sparkle.Parent then sparkle:Destroy() end
            end)

            task.wait(0.08)
        end
    end)
end

--========================================================--
-- SPARKLE BURST
--========================================================--
local function spawnSparkleBurst(parentFrame, color1, color2, count)
    count = count or 12
    local centerX = 0.5
    local centerY = 0.5

    for i = 1, count do
        task.spawn(function()
            local angle = (i / count) * math.pi * 2
            local radius = 60
            local sparkle = new("ImageLabel", {
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(centerX, 0, centerY, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://5014978988",
                ImageColor3 = math.random() > 0.5 and color1 or color2,
                ImageTransparency = 0,
                ZIndex = 7,
                Parent = parentFrame,
            })

            local endX = centerX + math.cos(angle) * (radius / 400)
            local endY = centerY + math.sin(angle) * (radius / 400)

            TweenService:Create(sparkle, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(endX, 0, endY, 0),
                ImageTransparency = 1,
                Size = UDim2.fromOffset(4, 4),
                Rotation = math.random(180, 720),
            }):Play()

            task.delay(1.3, function()
                if sparkle.Parent then sparkle:Destroy() end
            end)
        end)
    end
end

--========================================================--
-- CREATE CARD (STANDARD)
--========================================================--
local function createCard(opts)
    initGui()

    local type_ = opts.Type or "Info"
    local theme = TYPE_THEME[type_] or TYPE_THEME.Info
    local title = opts.Title or theme.Title
    local message = opts.Message or ""
    local duration = opts.Duration or 5
    local icon = opts.Icon or theme.Icon

    if #activeNotifications >= MAX_NOTIFICATIONS then
        local oldest = table.remove(activeNotifications, 1)
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
    end

    local card = new("Frame", {
        Name = "Notification_" .. tick(),
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.CardBackground,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = notifyContainer,
    })

    new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = card })

    local glow = new("Frame", {
        Name = "Glow",
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Glow,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = card,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 18), Parent = glow })

    local stroke = new("UIStroke", {
        Color = theme.Color1,
        Thickness = 1.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0.3,
        Parent = card,
    })
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Color1),
            ColorSequenceKeypoint.new(1, theme.Color2),
        }),
        Rotation = 45,
        Parent = stroke,
    })

    local accentBar = new("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = theme.Color1,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = card,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = accentBar })
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Color1),
            ColorSequenceKeypoint.new(1, theme.Color2),
        }),
        Parent = accentBar,
    })

    new("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        Parent = card,
    })

    local iconFrame = new("Frame", {
        Name = "IconFrame",
        Size = UDim2.fromOffset(36, 36),
        BackgroundColor3 = theme.Color1,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = card,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = iconFrame })
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Color1),
            ColorSequenceKeypoint.new(1, theme.Color2),
        }),
        Rotation = 135,
        Parent = iconFrame,
    })

    new("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = icon,
        ZIndex = 3,
        Parent = iconFrame,
    })

    new("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -50, 0, 18),
        Position = UDim2.fromOffset(48, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = THEME.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        ZIndex = 2,
        Parent = card,
    })

    new("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -48, 0, 0),
        Position = UDim2.fromOffset(48, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = THEME.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = message,
        AutomaticSize = Enum.AutomaticSize.Y,
        LineHeight = 1.4,
        ZIndex = 2,
        Parent = card,
    })

    local progressBg = new("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = THEME.CardBackground,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = card,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = progressBg })

    local progressBar = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.Color1,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = progressBg,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = progressBar })
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Color1),
            ColorSequenceKeypoint.new(1, theme.Color2),
        }),
        Parent = progressBar,
    })

    -- Pop-in animation
    card.Position = UDim2.new(0, 0, 0, 0)
    task.delay(0.05, function()
        TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundTransparency = 0.15,
        }):Play()
    end)

    iconFrame.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(iconFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(36, 36),
    }):Play()

    if type_ == "Success" or type_ == "Premium" then
        spawnConfetti(card, 2)
        spawnSparkleBurst(card, theme.Color1, theme.Color2, 10)
    end

    pcall(function()
        local sound = new("Sound", {
            SoundId = "rbxassetid://6042053626",
            Volume = 0.25,
            PlayOnRemove = true,
            Parent = card,
        })
        sound:Play()
        task.delay(2, function()
            if sound then sound:Destroy() end
        end)
    end)

    if duration > 0 then
        task.spawn(function()
            local startTime = tick()
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if not card.Parent then
                    conn:Disconnect()
                    return
                end
                local elapsed = tick() - startTime
                local remaining = math.max(0, 1 - elapsed / duration)
                progressBar.Size = UDim2.new(remaining, 0, 1, 0)
                if remaining <= 0 then conn:Disconnect() end
            end)

            task.wait(duration)

            if card.Parent then
                local slideOut = TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                })
                slideOut:Play()
                slideOut.Completed:Connect(function()
                    card:Destroy()
                end)
            end
        end)
    end

    table.insert(activeNotifications, card)
    card.Destroying:Connect(function()
        for i, c in ipairs(activeNotifications) do
            if c == card then
                table.remove(activeNotifications, i)
                break
            end
        end
    end)

    return card
end

--========================================================--
-- SHOW IMAGE (dengan foto Roblox asset id)
--========================================================--
function Notification.ShowImage(opts)
    opts = opts or {}
    initGui()

    -- 🎯 Pakai Roblox asset id
    local imageAsset = opts.AssetId or ASSET_LOGO
    local title = opts.Title or "MawwwHub"
    local message = opts.Message or ""
    local duration = opts.Duration or 8
    local type_ = opts.Type or "Premium"
    local theme = TYPE_THEME[type_] or TYPE_THEME.Premium
    local enableConfetti = opts.Confetti ~= false

    if #activeNotifications >= MAX_NOTIFICATIONS then
        local oldest = table.remove(activeNotifications, 1)
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
    end

    local card = new("Frame", {
        Name = "ImageNotif",
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.CardBackground,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = notifyContainer,
    })

    new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = card })

    local outerGlow = new("Frame", {
        Size = UDim2.new(1, 24, 1, 24),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Glow,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = card,
    })
    new("UICorner", { CornerRadius = UDim.new(0, 20), Parent = outerGlow })

    local stroke = new("UIStroke", {
        Color = theme.Color1,
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0.2,
        Parent = card,
    })
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Color1),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 210, 255)),
            ColorSequenceKeypoint.new(1, theme.Color2),
        }),
        Rotation = 45,
        Parent = stroke,
    })

    new("UIPadding", {
        PaddingTop = UDim.new(0, 18),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        Parent = card,
    })

    local imageHolder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 160),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = card,
    })

    local imgGlow = new("ImageLabel", {
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = theme.Glow,
        ImageTransparency = 0.5,
        ZIndex = 1,
        Parent = imageHolder,
    })

    -- 🎯 LOGO PAKAI RBXASSETID
    local logo = new("ImageLabel", {
        Size = UDim2.new(0, 140, 0, 140),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. imageAsset,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 3,
        Parent = imageHolder,
    })

    if enableConfetti then
        spawnParticleTrail(imageHolder, theme.Color1, theme.Color2, duration)
    end

    task.spawn(function()
        while logo.Parent do
            TweenService:Create(logo, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.5, 0, 0.5, -8),
            }):Play()
            task.wait(1.2)
            if not logo.Parent then break end
            TweenService:Create(logo, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.5, 0, 0.5, 8),
            }):Play()
            task.wait(1.2)
        end
    end)

    task.spawn(function()
        while imgGlow.Parent do
            TweenService:Create(imgGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.3,
                Size = UDim2.new(1, 50, 1, 50),
            }):Play()
            task.wait(1)
            if not imgGlow.Parent then break end
            TweenService:Create(imgGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.6,
                Size = UDim2.new(1, 40, 1, 40),
            }):Play()
            task.wait(1)
        end
    end)

    task.spawn(function()
        while logo.Parent do
            task.wait(3 + math.random() * 3)
            if not logo.Parent then break end
            local shakeSequence = { 8, -8, 6, -6, 3, -3, 0 }
            for _, rot in ipairs(shakeSequence) do
                if not logo.Parent then break end
                TweenService:Create(logo, TweenInfo.new(0.08), {
                    Rotation = rot,
                }):Play()
                task.wait(0.08)
            end
        end
    end)

    local titleLabel = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 168),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        TextSize = 17,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Text = title,
        ZIndex = 5,
        Parent = card,
    })
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.Color1),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, theme.Color2),
        }),
        Rotation = 90,
        Parent = titleLabel,
    })

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, 192),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = THEME.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = message,
        AutomaticSize = Enum.AutomaticSize.Y,
        LineHeight = 1.4,
        ZIndex = 5,
        Parent = card,
    })

    if enableConfetti then
        task.wait(0.3)
        spawnConfetti(card, 3)
        spawnSparkleBurst(imageHolder, theme.Color1, theme.Color2, 14)
    end

    -- Pop-in
    task.delay(0.05, function()
        TweenService:Create(card, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 240),
            BackgroundTransparency = 0.1,
        }):Play()
    end)

    logo.Size = UDim2.fromOffset(0, 0)
    logo.ImageTransparency = 1
    TweenService:Create(logo, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(140, 140),
        ImageTransparency = 0,
    }):Play()

    pcall(function()
        local sound = new("Sound", {
            SoundId = "rbxassetid://6042053626",
            Volume = 0.3,
            PlayOnRemove = true,
            Parent = card,
        })
        sound:Play()
        task.delay(2, function()
            if sound then sound:Destroy() end
        end)
    end)

    if duration > 0 then
        task.delay(duration, function()
            if not card.Parent then return end
            local slideOut = TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            })
            slideOut:Play()
            slideOut.Completed:Connect(function()
                card:Destroy()
            end)
        end)
    end

    table.insert(activeNotifications, card)
    card.Destroying:Connect(function()
        for i, c in ipairs(activeNotifications) do
            if c == card then
                table.remove(activeNotifications, i)
                break
            end
        end
    end)

    return card
end

--========================================================--
-- PUBLIC API
--========================================================--
function Notification.Show(opts)
    return createCard(opts or {})
end

function Notification.Success(title, message, duration)
    return createCard({
        Type = "Success",
        Title = title or "Berhasil",
        Message = message or "",
        Duration = duration or 5,
    })
end

function Notification.Error(title, message, duration)
    return createCard({
        Type = "Error",
        Title = title or "Error",
        Message = message or "",
        Duration = duration or 6,
    })
end

function Notification.Info(title, message, duration)
    return createCard({
        Type = "Info",
        Title = title or "Info",
        Message = message or "",
        Duration = duration or 5,
    })
end

function Notification.Warning(title, message, duration)
    return createCard({
        Type = "Warning",
        Title = title or "Peringatan",
        Message = message or "",
        Duration = duration or 5,
    })
end

function Notification.Loading(title, message)
    return createCard({
        Type = "Loading",
        Title = title or "Memuat...",
        Message = message or "",
        Duration = 0,
    })
end

function Notification.Premium(title, message, duration)
    return createCard({
        Type = "Premium",
        Title = title or "Premium",
        Message = message or "",
        Duration = duration or 8,
    })
end

--========================================================--
-- WELCOME IMAGE (pakai Roblox asset id)
--========================================================--
function Notification.WelcomeImage(opts)
    opts = opts or {}
    local playerName = Player.DisplayName or Player.Name
    local hasKey = opts.HasKey or false

    local msg
    if hasKey then
        msg = "Halo " .. playerName .. "!\n\n" ..
              "Key kamu terdeteksi.\n" ..
              "Sedang memverifikasi..."
    else
        msg = "Halo " .. playerName .. "!\n\n" ..
              "Selamat datang di MawwwHub.\n" ..
              "Silakan masukkan key untuk mulai."
    end

    return Notification.ShowImage({
        AssetId = ASSET_LOGO,  -- 🎯 pakai Roblox asset id
        Title = "AKU LAH MAWWWHUB",
        Message = msg,
        Duration = hasKey and 6 or 9,
        Type = "Premium",
        Confetti = true,
    })
end

--========================================================--
-- CELEBRATE
--========================================================--
function Notification.Celebrate(title, message)
    initGui()

    local overlay = new("Frame", {
        Name = "CelebrateOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 500,
        ClipsDescendants = true,
        Parent = notifyGui,
    })

    local startTime = tick()
    task.spawn(function()
        while tick() - startTime < 5 do
            for i = 1, 10 do
                local confetti = new("Frame", {
                    Size = UDim2.fromOffset(math.random(8, 16), math.random(12, 22)),
                    Position = UDim2.new(
                        math.random(),
                        0,
                        -0.05, 0
                    ),
                    BackgroundColor3 = CONFETTI_COLORS[math.random(1, #CONFETTI_COLORS)],
                    BorderSizePixel = 0,
                    Rotation = math.random(0, 360),
                    ZIndex = 501,
                    Parent = overlay,
                })
                new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = confetti })

                local fallDuration = math.random(20, 35) / 10
                local xDrift = math.random(-150, 150)

                TweenService:Create(confetti, TweenInfo.new(fallDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(
                        confetti.Position.X.Scale + xDrift / 800,
                        0,
                        1.2, 0
                    ),
                    Rotation = confetti.Rotation + math.random(180, 1080),
                }):Play()

                TweenService:Create(confetti, TweenInfo.new(fallDuration * 0.7), {
                    BackgroundTransparency = 1,
                }):Play()

                task.delay(fallDuration, function()
                    if confetti.Parent then confetti:Destroy() end
                end)
            end
            task.wait(0.08)
        end
    end)

    task.delay(7, function()
        if overlay.Parent then overlay:Destroy() end
    end)

    return Notification.ShowImage({
        AssetId = ASSET_LOGO,  -- 🎯 pakai Roblox asset id
        Title = title or "SELAMAT!",
        Message = message or "Key kamu valid. Selamat menggunakan MawwwHub!",
        Duration = 6,
        Type = "Success",
        Confetti = false,
    })
end

--========================================================--
-- CLEAR ALL
--========================================================--
function Notification.ClearAll()
    for _, card in ipairs(activeNotifications) do
        if card and card.Parent then
            card:Destroy()
        end
    end
    activeNotifications = {}
end

--========================================================--
-- UPDATE LOADING
--========================================================--
function Notification.UpdateLoading(card, opts)
    if not card or not card.Parent then return end
    local type_ = opts.Type or "Success"
    local theme = TYPE_THEME[type_] or TYPE_THEME.Success

    local stroke = card:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Color = theme.Color1 end

    local iconFrame = card:FindFirstChild("IconFrame")
    if iconFrame then
        local iconText = iconFrame:FindFirstChild("IconText") or iconFrame:FindFirstChildWhichIsA("TextLabel")
        if iconText then iconText.Text = theme.Icon end
    end

    local titleLabel = card:FindFirstChild("Title")
    if titleLabel then titleLabel.Text = opts.Title or theme.Title end

    local msgLabel = card:FindFirstChild("Message")
    if msgLabel then msgLabel.Text = opts.Message or "" end

    if type_ == "Success" then
        spawnConfetti(card, 2)
    end
end

return Notification