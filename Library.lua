--========================================================--
-- MAWWWHUB UI LIBRARY (v8 - Fixed Dropdown + Premium Toggle)
--========================================================--
local Library = {}
Library.__index = Library

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--========================================================--
-- SCHEME
--========================================================--
Library.Scheme = {
    AccentColor     = Color3.fromRGB(80, 170, 255),
    BackgroundColor = Color3.fromRGB(8, 14, 26),
    MainColor       = Color3.fromRGB(20, 32, 52),
    OutlineColor    = Color3.fromRGB(80, 170, 255),
    FontColor       = Color3.fromRGB(235, 242, 255),
}

Library.ToggleColors = {
    On  = Color3.fromRGB(46, 204, 113),
    Off = Color3.fromRGB(231, 76, 60),
}

Library.ToggleEffects = {
    Glow = true,
    Ripple = true,
    Particle = true,
    Sound = true,
    Bounce = true,
}

Library.ShowCustomCursor = false
Library.NotifySide       = "Right"
Library.ToggleKeybind    = Enum.KeyCode.LeftControl
Library._configFlags     = {}
Library._gui             = nil
Library._unloaded        = false
Library._cursorGui       = nil
Library._cursorConn      = nil

--========================================================--
-- HELPERS
--========================================================--
local function new(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then i[k] = v end
    end
    if props and props.Parent then i.Parent = props.Parent end
    return i
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = parent })
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Color = color or Library.Scheme.OutlineColor,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function safeCoreGui()
    local ok, gui = pcall(function() return CoreGui end)
    return gui
end

local function tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function isTouchOnly()
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        return true
    end
    return false
end

--========================================================--
-- SOUND
--========================================================--
local SOUND_IDS = {
    On  = "rbxassetid://4612375809",
    Off = "rbxassetid://4612376259",
}

local function playToggleSound(parent, isOn)
    if not Library.ToggleEffects.Sound then return end
    pcall(function()
        local sound = new("Sound", {
            SoundId = isOn and SOUND_IDS.On or SOUND_IDS.Off,
            Volume = 0.35,
            PlayOnRemove = true,
            Parent = parent,
        })
        sound:Play()
        task.delay(1, function()
            if sound then sound:Destroy() end
        end)
    end)
end

--========================================================--
-- RIPPLE
--========================================================--
local function createRipple(parent, xPos, yPos, color)
    if not Library.ToggleEffects.Ripple then return end

    local ripple = new("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.new(0, xPos - 5, 0, yPos - 5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = parent,
    })
    corner(ripple, 999)

    local grow = TweenService:Create(ripple, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(90, 90),
        Position = UDim2.new(0, xPos - 45, 0, yPos - 45),
        BackgroundTransparency = 1,
    })
    grow:Play()
    grow.Completed:Connect(function()
        ripple:Destroy()
    end)
end

--========================================================--
-- PARTICLE BURST
--========================================================--
local function createParticleBurst(parent, centerX, centerY, color)
    if not Library.ToggleEffects.Particle then return end

    local particleIds = {
        "rbxassetid://5014978988",
        "rbxassetid://5014979922",
        "rbxassetid://5014978844",
    }

    for i = 1, 6 do
        task.spawn(function()
            local angle = (i / 6) * math.pi * 2
            local radius = 25
            local p = new("ImageLabel", {
                Size = UDim2.fromOffset(10, 10),
                Position = UDim2.new(0, centerX - 5, 0, centerY - 5),
                BackgroundTransparency = 1,
                Image = particleIds[math.random(1, #particleIds)],
                ImageColor3 = math.random() > 0.5 and color or Color3.fromRGB(255, 255, 255),
                ImageTransparency = 0,
                ZIndex = 15,
                Parent = parent,
            })

            local endX = centerX + math.cos(angle) * radius
            local endY = centerY + math.sin(angle) * radius

            local anim = TweenService:Create(p, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, endX - 5, 0, endY - 5),
                ImageTransparency = 1,
                Size = UDim2.fromOffset(3, 3),
                Rotation = math.random(180, 720),
            })
            anim:Play()
            anim.Completed:Connect(function()
                p:Destroy()
            end)
        end)
    end
end

--========================================================--
-- GLOW PULSE
--========================================================--
local function startGlowPulse(btn, strokeObj)
    if not Library.ToggleEffects.Glow then return end

    task.spawn(function()
        while btn.Parent and strokeObj.Parent do
            TweenService:Create(strokeObj, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0,
                Thickness = 1.6,
            }):Play()
            task.wait(0.8)
            if not btn.Parent or not strokeObj.Parent then break end
            TweenService:Create(strokeObj, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.3,
                Thickness = 1,
            }):Play()
            task.wait(0.8)
        end
        if strokeObj.Parent then
            strokeObj.Transparency = 0.5
            strokeObj.Thickness = 1
        end
    end)
end

--========================================================--
-- DRAGGABLE
--========================================================--
function Library:MakeDraggable(frame, dragTarget)
    if not frame then return end
    dragTarget = dragTarget or frame
    local dragging, dragInput, dragStart, startPos

    dragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    dragTarget.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

--========================================================--
-- CUSTOM CURSOR
--========================================================--
local function destroyCursor()
    if Library._cursorConn then
        Library._cursorConn:Disconnect()
        Library._cursorConn = nil
    end
    if Library._cursorGui then
        Library._cursorGui:Destroy()
        Library._cursorGui = nil
    end
    local cg = safeCoreGui()
    local old = cg and cg:FindFirstChild("MawwwCursor")
    if old then old:Destroy() end
end

local function applyCustomCursor()
    destroyCursor()
    if not Library.ShowCustomCursor then return end
    if isTouchOnly() then return end

    local cg = safeCoreGui()
    if not cg then return end

    local gui = new("ScreenGui", {
        Name = "MawwwCursor",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = cg,
    })
    Library._cursorGui = gui

    local dot = new("Frame", {
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Library.Scheme.AccentColor,
        BorderSizePixel = 0,
        ZIndex = 99999,
        Parent = gui,
    })
    corner(dot, 99)

    Library._cursorConn = RunService.RenderStepped:Connect(function()
        if not gui.Parent then destroyCursor() return end
        if isTouchOnly() then destroyCursor() return end
        if UserInputService.MouseEnabled then
            local m = UserInputService:GetMouseLocation()
            dot.Visible = true
            dot.Position = UDim2.fromOffset(m.X - 4, m.Y - 4)
        else
            dot.Visible = false
        end
    end)
end

function Library.RefreshCursor()
    applyCustomCursor()
end

--========================================================--
-- NOTIFICATION
--========================================================--
local notifyGui, notifyContainer

local function ensureNotify()
    if notifyGui and notifyGui.Parent then return end
    local cg = safeCoreGui()
    if not cg then return end
    notifyGui = new("ScreenGui", {
        Name = "MawwwNotify",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = cg,
    })
    notifyContainer = new("Frame", {
        Name = "Container",
        Size = UDim2.new(0, 240, 1, -40),
        Position = UDim2.new(Library.NotifySide == "Right" and 1 or 0, Library.NotifySide == "Right" and -250 or 20, 0, 20),
        BackgroundTransparency = 1,
        Parent = notifyGui,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Library.NotifySide == "Right" and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left,
        Parent = notifyContainer,
    })
end

function Library:SetNotifySide(side)
    self.NotifySide = side
    if notifyContainer then
        notifyContainer.Position = UDim2.new(side == "Right" and 1 or 0, side == "Right" and -250 or 20, 0, 20)
        notifyContainer.UIListLayout.HorizontalAlignment = side == "Right" and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
    end
end

function Library:Notify(opt)
    ensureNotify()
    if not notifyContainer then return end
    local title    = opt.Title or "Notification"
    local content  = opt.Content or ""
    local duration = opt.Duration or 3

    local card = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Library.Scheme.MainColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = notifyContainer,
    })
    corner(card, 8)
    stroke(card, Library.Scheme.AccentColor, 1.3)

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.fromOffset(10, 6),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Library.Scheme.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        Parent = card,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.fromOffset(10, 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextWrapped = true,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = content,
        Parent = card,
    })

    tween(card, 0.25, { BackgroundTransparency = 0.05 })
    task.delay(duration, function()
        tween(card, 0.3, { BackgroundTransparency = 1 })
        task.wait(0.35)
        card:Destroy()
    end)
end

--========================================================--
-- WINDOW
--========================================================--
local Window = {}
Window.__index = Window

function Library:CreateWindow(config)
    config = config or {}
    local title        = config.Title or "MawwwHub"
    local footer       = config.Footer or "MawwwHub"
    local iconId       = config.Icon
    local cornerRadius = config.CornerRadius or 8
    local toggleKey    = config.ToggleKeybind or Enum.KeyCode.LeftControl

    Library.ToggleKeybind = toggleKey
    local touchOnly = isTouchOnly()
    Library.ShowCustomCursor = (config.ShowCustomCursor or false) and not touchOnly

    local WIN_W = 500
    local WIN_H = 340

    local gui = new("ScreenGui", {
        Name = "MawwwHubUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = safeCoreGui(),
    })
    Library._gui = gui

    local main = new("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(WIN_W, WIN_H),
        Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = Library.Scheme.BackgroundColor,
        BorderSizePixel = 0,
        Parent = gui,
    })
    corner(main, cornerRadius)
    stroke(main, Library.Scheme.OutlineColor, 1.4)
    Library:MakeDraggable(main, main)

    local topBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Library.Scheme.MainColor,
        BorderSizePixel = 0,
        Parent = main,
    })
    corner(topBar, cornerRadius)

    new("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        Parent = topBar,
    })

    if iconId then
        new("ImageLabel", {
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(1, -56, 0.5, -9),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. iconId,
            Parent = topBar,
        })
    end

    local closeBtn = new("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -28, 0.5, -11),
        BackgroundColor3 = Library.Scheme.MainColor,
        Text = "×",
        TextColor3 = Library.Scheme.AccentColor,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = topBar,
    })
    corner(closeBtn, 6)
    stroke(closeBtn, Library.Scheme.AccentColor, 1)
    closeBtn.MouseButton1Click:Connect(function() Library:Toggle() end)

    local sidebar = new("ScrollingFrame", {
        Size = UDim2.new(0, 100, 1, -32),
        Position = UDim2.fromOffset(0, 32),
        BackgroundColor3 = Library.Scheme.MainColor,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Library.Scheme.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = main,
    })

    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar,
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = sidebar,
    })

    local content = new("Frame", {
        Size = UDim2.new(1, -100, 1, -48),
        Position = UDim2.fromOffset(100, 32),
        BackgroundTransparency = 1,
        Parent = main,
    })

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Library.Scheme.AccentColor,
        Text = footer,
        Parent = main,
    })

    local self = setmetatable({
        Gui = gui,
        Main = main,
        Sidebar = sidebar,
        Content = content,
        Tabs = {},
        CurrentTab = nil,
        _baseW = WIN_W,
        _baseH = WIN_H,
    }, Window)

    function self:SetSize(w, h)
        w = math.clamp(w, 300, 1200)
        h = math.clamp(h, 180, 800)
        self._baseW = w
        self._baseH = h
        main.Size = UDim2.fromOffset(w, h)
        main.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    end

    function self:SetScale(scale)
        scale = math.clamp(scale, 0.5, 2.0)
        self:SetSize(math.floor(self._baseW * scale), math.floor(self._baseH * scale))
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Library.ToggleKeybind then Library:Toggle() end
    end)

    applyCustomCursor()
    return self
end

function Library:Toggle()
    if not self._gui then return end
    local main = self._gui:FindFirstChild("Main")
    if not main then return end
    main.Visible = not main.Visible
end

function Library:Unload()
    if self._gui then self._gui:Destroy() end
    destroyCursor()
    local cg = safeCoreGui()
    local notify = cg and cg:FindFirstChild("MawwwNotify")
    if notify then notify:Destroy() end
    self._unloaded = true
end

--========================================================--
-- TAB
--========================================================--
function Window:AddTab(name, icon)
    local tabBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Library.Scheme.BackgroundColor,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = self.Sidebar,
    })
    corner(tabBtn, 6)

    local tabLabel = new("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
        Parent = tabBtn,
    })

    local tabPage = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Library.Scheme.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Content,
    })

    new("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Parent = tabPage,
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = tabPage,
    })

    local tab = {
        Name = name,
        Button = tabBtn,
        Label = tabLabel,
        Page = tabPage,
    }

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            t.Label.TextColor3 = Library.Scheme.FontColor
            t.Button.BackgroundTransparency = 1
            t.Button.BackgroundColor3 = Library.Scheme.BackgroundColor
        end
        tabPage.Visible = true
        tabLabel.TextColor3 = Library.Scheme.AccentColor
        tabBtn.BackgroundTransparency = 0.7
        tabBtn.BackgroundColor3 = Library.Scheme.AccentColor
        self.CurrentTab = tab
    end)

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        task.defer(function() tabBtn.MouseButton1Click:Fire() end)
    end

    local TabObj = {}
    TabObj._tab = tab
    TabObj._window = self
    function TabObj:AddLeftGroupbox(gname, gicon)
        return self._window:_CreateGroupbox(self._tab, gname)
    end
    function TabObj:AddRightGroupbox(gname, gicon)
        return self._window:_CreateGroupbox(self._tab, gname)
    end
    return setmetatable(TabObj, { __index = self })
end

--========================================================--
-- GROUPBOX
--========================================================--
local Groupbox = {}
Groupbox.__index = Groupbox

function Window:_CreateGroupbox(tab, name)
    local box = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Library.Scheme.MainColor,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab.Page,
    })
    corner(box, 8)
    stroke(box, Library.Scheme.AccentColor, 1.2)

    new("UIPadding", {
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = box,
    })

    new("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = box,
    })

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Library.Scheme.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
        LayoutOrder = -1000000,
        Parent = box,
    })

    return setmetatable({
        Box = box,
        Inner = box,
        _order = 0,
        Tab = tab,
    }, Groupbox)
end

function Groupbox:_nextOrder()
    self._order = (self._order or 0) + 1
    return self._order
end

--========================================================--
-- TOGGLE (Premium Animated)
--========================================================--
function Groupbox:AddToggle(id, opt)
    opt = opt or {}
    local text    = opt.Text or id
    local default = opt.Default or false
    local cb      = opt.Callback

    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = frame,
    })

    local wrapper = new("Frame", {
        Size = UDim2.fromOffset(44, 22),
        Position = UDim2.new(1, -44, 0.5, -11),
        BackgroundTransparency = 1,
        Parent = frame,
    })

    local glow = new("Frame", {
        Size = UDim2.new(1, 8, 1, 8),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = default and Library.ToggleColors.On or Library.ToggleColors.Off,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = wrapper,
    })
    corner(glow, 999)

    local btn = new("TextButton", {
        Name = id,
        Size = UDim2.fromOffset(44, 22),
        BackgroundColor3 = default and Library.ToggleColors.On or Library.ToggleColors.Off,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = wrapper,
    })
    corner(btn, 11)
    local btnStroke = stroke(btn, default and Library.ToggleColors.On or Library.ToggleColors.Off, 1)
    btnStroke.Transparency = 0.5

    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
        }),
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(1, 0.95),
        }),
        Parent = btn,
    })

    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = btn,
    })
    corner(knob, 8)

    local knobGlow = new("Frame", {
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = knob,
    })
    corner(knobGlow, 999)

    local checkIcon = new("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = default and "✓" or "✕",
        TextTransparency = default and 0 or 1,
        ZIndex = 4,
        Parent = knob,
    })

    local state = default
    Library._configFlags[id] = default

    if default then startGlowPulse(btn, btnStroke) end

    local function setState(v)
        state = v
        Library._configFlags[id] = v
        local targetColor = v and Library.ToggleColors.On or Library.ToggleColors.Off

        playToggleSound(btn, v)
        tween(btn, 0.25, { BackgroundColor3 = targetColor })
        tween(btnStroke, 0.25, { Color = targetColor })
        tween(glow, 0.25, { BackgroundColor3 = targetColor })

        if Library.ToggleEffects.Bounce then
            TweenService:Create(knob, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(3, 3),
            }):Play()
        else
            tween(knob, 0.2, { Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(3, 3) })
        end

        if v then
            checkIcon.Text = "✓"
            checkIcon.TextTransparency = 1
            tween(checkIcon, 0.2, { TextTransparency = 0 })
        else
            checkIcon.Text = "✕"
            tween(checkIcon, 0.2, { TextTransparency = 1 })
        end

        if v then
            startGlowPulse(btn, btnStroke)
        else
            tween(btnStroke, 0.3, { Transparency = 0.5, Thickness = 1 })
        end

        local origSize = btn.Size
        btn.Size = UDim2.fromOffset(48, 24)
        task.delay(0.1, function()
            if btn.Parent then
                tween(btn, 0.15, { Size = origSize })
            end
        end)

        if Library.ToggleEffects.Particle then
            createParticleBurst(wrapper, 22, 11, targetColor)
        end
        if Library.ToggleEffects.Ripple then
            createRipple(wrapper, 22, 11, targetColor)
        end

        if cb then task.spawn(cb, v) end
    end

    btn.MouseButton1Click:Connect(function() setState(not state) end)

    btn.MouseEnter:Connect(function() tween(glow, 0.2, { BackgroundTransparency = 0.4 }) end)
    btn.MouseLeave:Connect(function() tween(glow, 0.2, { BackgroundTransparency = state and 0.5 or 0.7 }) end)

    return { Set = setState, Get = function() return state end, Frame = frame }
end

--========================================================--
-- CHECKBOX
--========================================================--
function Groupbox:AddCheckbox(id, opt)
    opt = opt or {}
    local text    = opt.Text or id
    local default = opt.Default or false
    local cb      = opt.Callback

    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })

    local wrapper = new("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Parent = frame,
    })

    local glow = new("Frame", {
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = default and Library.ToggleColors.On or Library.ToggleColors.Off,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = wrapper,
    })
    corner(glow, 999)

    local check = new("TextButton", {
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = default and Library.ToggleColors.On or Library.ToggleColors.Off,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = wrapper,
    })
    corner(check, 6)
    local checkStroke = stroke(check, default and Library.ToggleColors.On or Library.ToggleColors.Off, 1)
    checkStroke.Transparency = 0.4

    local icon = new("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = default and "✓" or "✕",
        TextTransparency = default and 0 or 1,
        ZIndex = 3,
        Parent = check,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.fromOffset(30, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = frame,
    })

    local state = default
    Library._configFlags[id] = default

    local function setState(v)
        state = v
        Library._configFlags[id] = v
        local targetColor = v and Library.ToggleColors.On or Library.ToggleColors.Off

        playToggleSound(check, v)
        tween(check, 0.25, { BackgroundColor3 = targetColor })
        tween(checkStroke, 0.25, { Color = targetColor })
        tween(glow, 0.25, { BackgroundColor3 = targetColor })

        if v then
            icon.Text = "✓"
            icon.TextTransparency = 1
            tween(icon, 0.2, { TextTransparency = 0 })
        else
            icon.Text = "✕"
            tween(icon, 0.2, { TextTransparency = 1 })
        end

        if v then
            startGlowPulse(check, checkStroke)
        else
            tween(checkStroke, 0.3, { Transparency = 0.4 })
        end

        local origSize = check.Size
        check.Size = UDim2.fromOffset(23, 23)
        task.delay(0.1, function()
            if check.Parent then
                tween(check, 0.15, { Size = origSize })
            end
        end)

        if Library.ToggleEffects.Particle then
            createParticleBurst(wrapper, 10, 10, targetColor)
        end
        if Library.ToggleEffects.Ripple then
            createRipple(wrapper, 10, 10, targetColor)
        end

        if cb then task.spawn(cb, v) end
    end

    check.MouseButton1Click:Connect(function() setState(not state) end)

    return { Set = setState, Get = function() return state end }
end

--========================================================--
-- SLIDER
--========================================================--
function Groupbox:AddSlider(id, opt)
    opt = opt or {}
    local text     = opt.Text or id
    local default  = opt.Default or 0
    local min      = opt.Min or 0
    local max      = opt.Max or 100
    local rounding = opt.Rounding or 0
    local cb       = opt.Callback

    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })

    new("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = frame,
    })

    local valueLbl = new("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 15),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Library.Scheme.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(default),
        Parent = frame,
    })

    local bar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 7),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = Color3.fromRGB(50, 45, 60),
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(bar, 4)

    local fill = new("Frame", {
        Size = UDim2.new((default - min) / math.max(1, max - min), 0, 1, 0),
        BackgroundColor3 = Library.Scheme.AccentColor,
        BorderSizePixel = 0,
        Parent = bar,
    })
    corner(fill, 4)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new((default - min) / math.max(1, max - min), -6, 0.5, -6),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = bar,
    })
    corner(knob, 6)

    local dragging = false
    local value = default
    Library._configFlags[id] = default

    local function setValue(v)
        v = math.clamp(v, min, max)
        if rounding > 0 then
            local m = 10 ^ rounding
            v = math.floor(v * m + 0.5) / m
        else
            v = math.floor(v + 0.5)
        end
        value = v
        Library._configFlags[id] = v
        local pct = (v - min) / math.max(0.001, max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -6, 0.5, -6)
        valueLbl.Text = tostring(v)
        if cb then task.spawn(cb, v) end
    end

    local function inputToValue(pos)
        local rel = (pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        setValue(min + rel * (max - min))
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            inputToValue(input.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            inputToValue(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Set = setValue, Get = function() return value end }
end

--========================================================--
-- 🎯 DROPDOWN (FIXED — auto-expand, tidak nutup fitur lain)
--========================================================--
function Groupbox:AddDropdown(id, opt)
    opt = opt or {}
    local text    = opt.Text or id
    local values  = opt.Values or {}
    local default = opt.Default or (values[1] or "")
    local multi   = opt.Multi or false
    local cb      = opt.Callback

    -- 🎯 FRAME CONTAINER dengan AutomaticSize
    -- Ini yang bikin dropdown mendorong konten di bawah, bukan nutupin
    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = frame,
    })

    -- Header row (label + button side by side)
    local header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = frame,
    })

    new("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = header,
    })

    -- Dropdown button
    local ddBtn = new("TextButton", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = Library.Scheme.BackgroundColor,
        Text = tostring(default),
        TextColor3 = Library.Scheme.AccentColor,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        AutoButtonColor = false,
        Parent = header,
    })
    corner(ddBtn, 6)
    local ddStroke = stroke(ddBtn, Library.Scheme.AccentColor, 1)

    -- 🎯 LIST HOLDER — jadi bagian dari flow, bukan overlay
    local listHolder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Library.Scheme.MainColor,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        LayoutOrder = 2,
        Parent = frame,
    })
    corner(listHolder, 6)
    stroke(listHolder, Library.Scheme.AccentColor, 1)

    new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = listHolder,
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = listHolder,
    })

    local selected = multi and { [default] = true } or default
    Library._configFlags[id] = multi and selected or default

    local function updateText()
        if multi then
            local t = {}
            for k in pairs(selected) do table.insert(t, k) end
            ddBtn.Text = #t > 0 and table.concat(t, ", ") or "None"
        else
            ddBtn.Text = tostring(selected)
        end
    end

    for _, v in ipairs(values) do
        local opt_btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = Library.Scheme.BackgroundColor,
            BackgroundTransparency = 0.3,
            Text = tostring(v),
            TextColor3 = Library.Scheme.FontColor,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            AutoButtonColor = false,
            Parent = listHolder,
        })
        corner(opt_btn, 4)

        opt_btn.MouseEnter:Connect(function()
            tween(opt_btn, 0.15, { BackgroundTransparency = 0, TextColor3 = Library.Scheme.AccentColor })
        end)
        opt_btn.MouseLeave:Connect(function()
            tween(opt_btn, 0.15, { BackgroundTransparency = 0.3, TextColor3 = Library.Scheme.FontColor })
        end)

        opt_btn.MouseButton1Click:Connect(function()
            if multi then
                if selected[v] then selected[v] = nil else selected[v] = true end
            else
                selected = v
                Library._configFlags[id] = v
                listHolder.Visible = false
                tween(ddStroke, 0.15, { Color = Library.Scheme.AccentColor })
            end
            updateText()
            if cb then task.spawn(cb, selected) end
        end)
    end

    -- 🎯 Toggle open/close dengan efek
    local isOpen = false
    ddBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listHolder.Visible = isOpen
        tween(ddStroke, 0.15, { Color = isOpen and Color3.fromRGB(46, 204, 113) or Library.Scheme.AccentColor })
    end)

    updateText()
    return { Set = function(v) selected = v; updateText() end, Get = function() return selected end }
end

--========================================================--
-- BUTTON
--========================================================--
function Groupbox:AddButton(text, cb)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Library.Scheme.BackgroundColor,
        BackgroundTransparency = 0.1,
        Text = text,
        TextColor3 = Library.Scheme.AccentColor,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
        ClipsDescendants = true,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })
    corner(btn, 6)
    stroke(btn, Library.Scheme.AccentColor, 1.2)

    btn.MouseEnter:Connect(function() tween(btn, 0.15, { BackgroundTransparency = 0 }) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.15, { BackgroundTransparency = 0.1 }) end)
    btn.MouseButton1Click:Connect(function()
        if Library.ToggleEffects.Ripple then
            createRipple(btn, btn.AbsoluteSize.X / 2, btn.AbsoluteSize.Y / 2, Library.Scheme.AccentColor)
        end
        if cb then task.spawn(cb) end
    end)

    return btn
end

--========================================================--
-- LABEL
--========================================================--
function Groupbox:AddLabel(text)
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self:_nextOrder(),
        Text = text,
        Parent = self.Inner,
    })
    local wrapper = { Label = lbl }
    function wrapper:AddColor(color)
        lbl.TextColor3 = color
        return self
    end
    function wrapper:SetText(t)
        lbl.Text = t
        return self
    end
    return wrapper
end

--========================================================--
-- DIVIDER
--========================================================--
function Groupbox:AddDivider()
    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, 5),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, -0.5),
        BackgroundColor3 = Library.Scheme.AccentColor,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = holder,
    })
    return holder
end

--========================================================--
-- INPUT
--========================================================--
function Groupbox:AddInput(id, opt)
    opt = opt or {}
    local text        = opt.Text or id
    local default     = opt.Default or ""
    local placeholder = opt.Placeholder or "Input..."
    local cb          = opt.Callback

    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = frame,
    })

    local box = new("TextBox", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 17),
        BackgroundColor3 = Library.Scheme.BackgroundColor,
        Text = default,
        PlaceholderText = placeholder,
        TextColor3 = Library.Scheme.AccentColor,
        PlaceholderColor3 = Color3.fromRGB(120, 120, 130),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ClearTextOnFocus = false,
        Parent = frame,
    })
    corner(box, 6)
    stroke(box, Library.Scheme.AccentColor, 1)

    local value = default
    Library._configFlags[id] = default

    box.FocusLost:Connect(function()
        value = box.Text
        Library._configFlags[id] = value
        if cb then task.spawn(cb, value) end
    end)

    return { Set = function(v) value = v; box.Text = v; Library._configFlags[id] = v end, Get = function() return value end }
end

--========================================================--
-- COLORPICKER
--========================================================--
function Groupbox:AddColorpicker(id, opt)
    opt = opt or {}
    local text    = opt.Text or id
    local default = opt.Default or Color3.fromRGB(255, 255, 255)
    local cb      = opt.Callback

    local frame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })

    new("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Library.Scheme.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = frame,
    })

    local swatch = new("TextButton", {
        Size = UDim2.fromOffset(36, 18),
        Position = UDim2.new(1, -36, 0.5, -9),
        BackgroundColor3 = default,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    corner(swatch, 5)
    stroke(swatch, Color3.new(1, 1, 1), 1)

    Library._configFlags[id] = default

    local palette = {
        Color3.fromRGB(180, 110, 255), Color3.fromRGB(255, 105, 180),
        Color3.fromRGB(80, 210, 255),  Color3.fromRGB(90, 230, 150),
        Color3.fromRGB(255, 215, 90),  Color3.fromRGB(255, 150, 80),
        Color3.fromRGB(255, 95, 95),   Color3.fromRGB(110, 150, 255),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(30, 30, 40),
    }
    local idx = 1
    for i, c in ipairs(palette) do if c == default then idx = i break end end

    local value = default
    swatch.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #palette then idx = 1 end
        value = palette[idx]
        swatch.BackgroundColor3 = value
        Library._configFlags[id] = value
        if cb then task.spawn(cb, value) end
    end)

    return { Set = function(v) value = v; swatch.BackgroundColor3 = v; Library._configFlags[id] = v end, Get = function() return value end }
end

--========================================================--
-- IMAGE
--========================================================--
function Groupbox:AddImage(assetId, opt)
    opt = opt or {}
    local height = opt.Height or 120

    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, height + 18),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.Inner,
    })

    local img = new("ImageLabel", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Library.Scheme.BackgroundColor,
        BackgroundTransparency = 0.1,
        Image = "rbxassetid://" .. tostring(assetId),
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    corner(img, 8)
    stroke(img, Library.Scheme.AccentColor, 1.5)

    if opt.Text and opt.Text ~= "" then
        new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, height + 2),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = Library.Scheme.AccentColor,
            Text = opt.Text,
            Parent = holder,
        })
    end

    return img
end

return Library