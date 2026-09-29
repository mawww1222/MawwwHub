--========================================================--
-- MAWWWHUB NOTIFICATION — SIMPLE VERSION
-- Foto + Loading Text + Red Bar + Status Text
--========================================================--
local Notification = {}

--========================================================--
-- SERVICES
--========================================================--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--========================================================--
-- 🎨 ASSET ID FOTO (GANTI DI SINI KALAU MAU)
--========================================================--
local ASSET_LOGO = "88250532753444"

--========================================================--
-- STATE
--========================================================--
local notifyGui = nil
local notifyContainer = nil
local currentCard = nil

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
    if notifyGui and notifyGui.Parent then return end

    local existing = CoreGui:FindFirstChild("MawwwNotify")
    if existing then existing:Destroy() end

    notifyGui = new("ScreenGui", {
        Name = "MawwwNotify",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
        Parent = CoreGui,
    })

    notifyContainer = new("Frame", {
        Name = "Container",
        Size = UDim2.new(0, 220, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = notifyGui,
    })
end

--========================================================--
-- CREATE CARD
--========================================================--
local function createCard(opts)
    initGui()

    if currentCard and currentCard.Parent then
        currentCard:Destroy()
    end

    local duration = opts.Duration or 6
    local textColor = opts.TextColor or Color3.fromRGB(255, 255, 255)
    local barColor = opts.BarColor or Color3.fromRGB(230, 60, 60)
    local showBar = opts.ShowBar ~= false

    --======================================================--
    -- CARD FRAME
    --======================================================--
    local card = new("Frame", {
        Name = "Card",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(12, 10, 18),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = notifyContainer,
    })

    new("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = card,
    })

    new("UIStroke", {
        Color = Color3.fromRGB(40, 30, 60),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = card,
    })

    --======================================================--
    -- FOTO LOGO
    --======================================================--
    local logoFrame = new("Frame", {
        Name = "LogoFrame",
        Size = UDim2.new(1, 0, 0, 120),
        Position = UDim2.fromOffset(0, 10),
        BackgroundTransparency = 1,
        Parent = card,
    })

    new("ImageLabel", {
        Name = "Logo",
        Size = UDim2.fromOffset(100, 100),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. ASSET_LOGO,
        ScaleType = Enum.ScaleType.Fit,
        Parent = logoFrame,
    })

    --======================================================--
    -- TEXT STATUS
    --======================================================--
    local statusText = new("TextLabel", {
        Name = "StatusText",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 138),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = textColor,
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = opts.Text or "LOADING...",
        Parent = card,
    })

    --======================================================--
    -- RED BAR (Loading Bar)
    --======================================================--
    local barBackground = new("Frame", {
        Name = "BarBackground",
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.fromOffset(10, 164),
        BackgroundColor3 = Color3.fromRGB(40, 20, 20),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = card,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barBackground })

    local redBar = new("Frame", {
        Name = "RedBar",
        Size = UDim2.new(0.2, 0, 1, 0),
        Position = UDim2.new(-0.2, 0, 0, 0),
        BackgroundColor3 = barColor,
        BorderSizePixel = 0,
        Parent = barBackground,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = redBar })

    --======================================================--
    -- POP-IN ANIMATION
    --======================================================--
    task.delay(0.05, function()
        TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(220, 190),
        }):Play()
    end)

    --======================================================--
    -- RED BAR ANIMATION (bergerak ke kanan, loop)
    --======================================================--
    local barLoop
    if showBar then
        barLoop = RunService.RenderStepped:Connect(function()
            if not redBar.Parent then
                barLoop:Disconnect()
                return
            end
            local posX = redBar.Position.X.Scale
            posX = posX + 0.015
            if posX > 1 then
                posX = -0.2
            end
            redBar.Position = UDim2.new(posX, 0, 0, 0)
        end)
    else
        redBar.Size = UDim2.new(1, 0, 1, 0)
        redBar.Position = UDim2.new(0, 0, 0, 0)
    end

    --======================================================--
    -- AUTO DISMISS
    --======================================================--
    if duration > 0 then
        task.delay(duration, function()
            if not card.Parent then return end
            if barLoop then barLoop:Disconnect() end

            TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 1,
            }):Play()

            task.wait(0.4)
            if card.Parent then card:Destroy() end
            if currentCard == card then currentCard = nil end
        end)
    end

    currentCard = card
    return card
end

--========================================================--
-- PUBLIC API
--========================================================--

-- 🔴 Loading (dengan red bar bergerak)
function Notification.Loading(text, duration)
    return createCard({
        Text = text or "LOADING...",
        Duration = duration or 6,
        TextColor = Color3.fromRGB(255, 255, 255),
        BarColor = Color3.fromRGB(230, 60, 60),
        ShowBar = true,
    })
end

-- ✅ Key Activated (hijau)
function Notification.KeyActivated()
    return createCard({
        Text = "KEY ACTIVATED",
        Duration = 4,
        TextColor = Color3.fromRGB(80, 230, 120),
        BarColor = Color3.fromRGB(80, 230, 120),
        ShowBar = false,
    })
end

-- ❌ Key Not Active (merah)
function Notification.KeyNotActive()
    return createCard({
        Text = "KEY NO ACTIVE",
        Duration = 4,
        TextColor = Color3.fromRGB(240, 80, 80),
        BarColor = Color3.fromRGB(240, 80, 80),
        ShowBar = false,
    })
end

-- Update text pada card yang sedang aktif
function Notification.SetText(text)
    if currentCard and currentCard.Parent then
        local statusText = currentCard:FindFirstChild("StatusText")
        if statusText then
            statusText.Text = text
        end
    end
end

-- Ganti warna teks
function Notification.SetColor(color)
    if currentCard and currentCard.Parent then
        local statusText = currentCard:FindFirstChild("StatusText")
        if statusText then
            statusText.TextColor3 = color
        end
    end
end

--========================================================--
-- COMPATIBILITY (biar gak error pas dipanggil dari MawwwHub.lua)
--========================================================--
function Notification.WelcomeImage(opts)
    opts = opts or {}
    local hasKey = opts.HasKey or false
    if hasKey then
        return Notification.Loading("VERIFYING KEY...", 5)
    else
        return Notification.Loading("LOADING...", 6)
    end
end

function Notification.Celebrate(title, message)
    return Notification.KeyActivated()
end

function Notification.Success(title, message, duration)
    return Notification.KeyActivated()
end

function Notification.Error(title, message, duration)
    return Notification.KeyNotActive()
end

function Notification.Info(title, message, duration)
    return Notification.Loading("LOADING...", duration or 4)
end

function Notification.Warning(title, message, duration)
    return Notification.Loading("PLEASE WAIT...", duration or 4)
end

function Notification.Premium(title, message, duration)
    return Notification.Loading("LOADING...", duration or 5)
end

function Notification.Show(opts)
    return createCard(opts or {})
end

function Notification.ShowImage(opts)
    opts = opts or {}
    return Notification.Loading(opts.Text or "LOADING...", opts.Duration or 5)
end

function Notification.UpdateLoading(card, opts)
    if not card or not card.Parent then return end
    local statusText = card:FindFirstChild("StatusText")
    if statusText and opts then
        if opts.Title then statusText.Text = opts.Title end
    end
end

function Notification.ClearAll()
    if notifyContainer then
        for _, child in ipairs(notifyContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    currentCard = nil
end

return Notification
