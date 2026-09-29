--========================================================--
-- MAWWWHUB NOTIFICATION — SIMPLE (Perfect Center)
--========================================================--
local Notification = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local ASSET_LOGO = "88250532753444"

local notifyGui = nil
local currentCard = nil
local activeCards = {}

local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function getScreenCenter()
    local camera = Workspace.CurrentCamera
    if not camera then return 640, 360 end
    local vp = camera.ViewportSize
    if not vp or vp.X <= 0 or vp.Y <= 0 then return 640, 360 end
    return vp.X / 2, vp.Y / 2
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
        DisplayOrder = 998,
        Parent = CoreGui,
    })
end

local function createCard(opts)
    initGui()
    if not notifyGui then return nil end

    if currentCard and currentCard.Parent then
        currentCard:Destroy()
    end

    local duration = opts.Duration or 3
    local textColor = opts.TextColor or Color3.fromRGB(255, 255, 255)
    local barColor = opts.BarColor or Color3.fromRGB(230, 60, 60)
    local showBar = opts.ShowBar ~= false

    local cx, cy = getScreenCenter()

    local card = new("Frame", {
        Name = "Card",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(cx, cy),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(12, 10, 18),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = notifyGui,
    })

    new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = card })
    new("UIStroke", {
        Color = Color3.fromRGB(40, 30, 60),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = card,
    })

    local logoFrame = new("Frame", {
        Name = "LogoFrame",
        Size = UDim2.new(1, 0, 0, 100),
        Position = UDim2.fromOffset(0, 10),
        BackgroundTransparency = 1,
        Parent = card,
    })

    new("ImageLabel", {
        Name = "Logo",
        Size = UDim2.fromOffset(80, 80),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. ASSET_LOGO,
        ScaleType = Enum.ScaleType.Fit,
        Parent = logoFrame,
    })

    new("TextLabel", {
        Name = "StatusText",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 118),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = textColor,
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = opts.Text or "LOADING...",
        Parent = card,
    })

    local barBackground = new("Frame", {
        Name = "BarBackground",
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.fromOffset(10, 144),
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

    local camera = Workspace.CurrentCamera
    local resizeConn
    if camera then
        resizeConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if card and card.Parent then
                local newCx, newCy = getScreenCenter()
                card.Position = UDim2.fromOffset(newCx, newCy)
            end
        end)
    end

    task.delay(0.05, function()
        if not card.Parent then return end
        TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(220, 160),
        }):Play()
    end)

    local barLoop
    if showBar then
        barLoop = RunService.RenderStepped:Connect(function()
            if not redBar.Parent then
                barLoop:Disconnect()
                return
            end
            local posX = redBar.Position.X.Scale + 0.02
            if posX > 1 then posX = -0.2 end
            redBar.Position = UDim2.new(posX, 0, 0, 0)
        end)
    else
        redBar.Size = UDim2.new(1, 0, 1, 0)
        redBar.Position = UDim2.new(0, 0, 0, 0)
    end

    if duration > 0 then
        task.delay(duration, function()
            if not card.Parent then return end
            if barLoop then barLoop:Disconnect() end
            if resizeConn then resizeConn:Disconnect() end

            TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 1,
            }):Play()

            task.wait(0.3)
            if card.Parent then card:Destroy() end
            if currentCard == card then currentCard = nil end
        end)
    end

    currentCard = card
    table.insert(activeCards, card)
    card.Destroying:Connect(function()
        for i, c in ipairs(activeCards) do
            if c == card then table.remove(activeCards, i) break end
        end
    end)

    return card
end

--========================================================--
-- PUBLIC API
--========================================================--
function Notification.Loading(text, duration)
    return createCard({
        Text = text or "LOADING...",
        Duration = duration or 3,
        TextColor = Color3.fromRGB(255, 255, 255),
        BarColor = Color3.fromRGB(230, 60, 60),
        ShowBar = true,
    })
end

function Notification.KeyActivated()
    return createCard({
        Text = "KEY ACTIVATED",
        Duration = 3,
        TextColor = Color3.fromRGB(80, 230, 120),
        BarColor = Color3.fromRGB(80, 230, 120),
        ShowBar = false,
    })
end

function Notification.KeyNotActive()
    return createCard({
        Text = "KEY NO ACTIVE",
        Duration = 3,
        TextColor = Color3.fromRGB(240, 80, 80),
        BarColor = Color3.fromRGB(240, 80, 80),
        ShowBar = false,
    })
end

-- Compatibility aliases
function Notification.WelcomeImage(opts) return Notification.Loading("LOADING...", 3) end
function Notification.Celebrate() return Notification.KeyActivated() end
function Notification.Success() return Notification.KeyActivated() end
function Notification.Error() return Notification.KeyNotActive() end
function Notification.Info(t, m, d) return Notification.Loading("LOADING...", d or 3) end
function Notification.Warning(t, m, d) return Notification.Loading("PLEASE WAIT...", d or 3) end
function Notification.Premium(t, m, d) return Notification.Loading("LOADING...", d or 4) end
function Notification.Show(opts) return createCard(opts or {}) end
function Notification.ShowImage(opts) return Notification.Loading(opts.Text or "LOADING...", opts.Duration or 3) end
function Notification.UpdateLoading(card, opts)
    if not card or not card.Parent then return end
    local s = card:FindFirstChild("StatusText")
    if s and opts and opts.Title then s.Text = opts.Title end
end

function Notification.ClearAll()
    if notifyGui then
        for _, child in ipairs(notifyGui:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
    end
    currentCard = nil
    activeCards = {}
end

return Notification
