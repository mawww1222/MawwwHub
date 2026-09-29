--========================================================--
-- MAWWWHUB KEY GATE — Fixed Version
--========================================================--
local BASE = "https://raw.githubusercontent.com/mawww1222/MawwwHub/main/"

local KeySystem = loadstring(game:HttpGet(BASE .. "KeySystem.lua?t=" .. tick()))()
local Notification = loadstring(game:HttpGet(BASE .. "Notification.lua?t=" .. tick()))()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

--========================================================--
-- 🎨 ASSET FOTO
--========================================================--
local KEY_LOGO_ID = "88250532753444"

--========================================================--
-- SAVED KEY
--========================================================--
local function getSavedKey()
    if isfile and isfile("MawwwHub/key.txt") then
        local ok, k = pcall(readfile, "MawwwHub/key.txt")
        if ok and k and k ~= "" then return k end
    end
    return nil
end

local function saveKey(key)
    if writefile then
        if isfolder and not isfolder("MawwwHub") then
            makefolder("MawwwHub")
        end
        pcall(writefile, "MawwwHub/key.txt", key)
    end
end

local function clearSavedKey()
    if delfile and isfile and isfile("MawwwHub/key.txt") then
        pcall(delfile, "MawwwHub/key.txt")
    end
end

local function loadMainScript()
    loadstring(game:HttpGet(BASE .. "MawwwHub_Main.lua?t=" .. tick()))()
end

--========================================================--
-- KEY UI — POSISI TENGAH LAYAR
--========================================================--
local function ShowKeyUI()
    -- 🎯 Hapus notif dulu biar gak nutupin key UI
    if Notification.ClearAll then
        pcall(function() Notification.ClearAll() end)
    end
    -- Tambah delay kecil biar notif sempat hilang
    task.wait(0.3)

    local gui = Instance.new("ScreenGui")
    gui.Name = "MawwwKeyUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999  -- 🎯 paling atas biar gak ketutup
    pcall(function() gui.Parent = CoreGui end)

    -- Overlay gelap
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 0
    overlay.Parent = gui

    TweenService:Create(overlay, TweenInfo.new(0.5), { BackgroundTransparency = 0.5 }):Play()

    --======================================================--
    -- FRAME UTAMA (TENGAH LAYAR)
    --======================================================--
    local FRAME_W = 440
    local FRAME_H = 400

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.fromOffset(0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = gui

    task.delay(0.1, function()
        TweenService:Create(frame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(FRAME_W, FRAME_H),
        }):Play()
    end)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 110, 255)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 110, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(80, 210, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 105, 180)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 110, 255)),
    })
    strokeGrad.Rotation = 0
    strokeGrad.Parent = stroke

    task.spawn(function()
        while strokeGrad.Parent do
            for i = 0, 360, 3 do
                if not strokeGrad.Parent then break end
                strokeGrad.Rotation = i
                task.wait(0.03)
            end
        end
    end)

    -- LOGO
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.fromOffset(130, 130)
    logoFrame.Position = UDim2.new(0.5, -65, 0, 20)
    logoFrame.BackgroundTransparency = 1
    logoFrame.ZIndex = 11
    logoFrame.Parent = frame

    local logoGlow = Instance.new("ImageLabel")
    logoGlow.Size = UDim2.new(1, 30, 1, 30)
    logoGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    logoGlow.BackgroundTransparency = 1
    logoGlow.Image = "rbxassetid://5028857084"
    logoGlow.ImageColor3 = Color3.fromRGB(180, 110, 255)
    logoGlow.ImageTransparency = 0.4
    logoGlow.ZIndex = 10
    logoGlow.Parent = logoFrame

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.fromScale(1, 1)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://" .. KEY_LOGO_ID
    logo.ScaleType = Enum.ScaleType.Fit
    logo.ZIndex = 12
    logo.Parent = logoFrame

    task.spawn(function()
        while logoFrame.Parent do
            TweenService:Create(logoFrame, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.5, -65, 0, 12),
            }):Play()
            task.wait(1.2)
            if not logoFrame.Parent then break end
            TweenService:Create(logoFrame, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.5, -65, 0, 20),
            }):Play()
            task.wait(1.2)
        end
    end)

    -- TITLE
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.fromOffset(10, 158)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "MAWWWHUB"
    title.ZIndex = 11
    title.Parent = frame

    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 110, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 210, 255)),
    })
    titleGrad.Rotation = 90
    titleGrad.Parent = title

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 16)
    sub.Position = UDim2.fromOffset(10, 190)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextColor3 = Color3.fromRGB(200, 200, 210)
    sub.Text = "Masukkan key untuk mengakses script"
    sub.ZIndex = 11
    sub.Parent = frame

    -- INPUT
    local inputHolder = Instance.new("Frame")
    inputHolder.Size = UDim2.new(1, -20, 0, 40)
    inputHolder.Position = UDim2.fromOffset(10, 218)
    inputHolder.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
    inputHolder.BorderSizePixel = 0
    inputHolder.ZIndex = 11
    inputHolder.Parent = frame
    Instance.new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = inputHolder })

    local inStroke = Instance.new("UIStroke")
    inStroke.Color = Color3.fromRGB(180, 110, 255)
    inStroke.Thickness = 1.5
    inStroke.Parent = inputHolder

    local input = Instance.new("TextBox")
    input.Size = UDim2.fromScale(1, 1)
    input.BackgroundTransparency = 1
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.TextColor3 = Color3.fromRGB(240, 240, 245)
    input.PlaceholderText = "MAWWW-XXXX-XXXX-XXXX"
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    input.Text = ""
    input.ClearTextOnFocus = false
    input.ZIndex = 12
    input.Parent = inputHolder

    -- STATUS
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 18)
    status.Position = UDim2.fromOffset(10, 262)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Text = ""
    status.ZIndex = 11
    status.Parent = frame

    -- VERIFY BUTTON
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(1, -20, 0, 42)
    verifyBtn.Position = UDim2.fromOffset(10, 285)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(180, 110, 255)
    verifyBtn.BorderSizePixel = 0
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 14
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.Text = "🔓 VERIFY KEY"
    verifyBtn.AutoButtonColor = false
    verifyBtn.ZIndex = 11
    verifyBtn.Parent = frame
    Instance.new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = verifyBtn })

    local vGrad = Instance.new("UIGradient")
    vGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 110, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 210, 255)),
    })
    vGrad.Rotation = 45
    vGrad.Parent = verifyBtn

    -- BELI + CLEAR BUTTON
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0.5, -15, 0, 36)
    buyBtn.Position = UDim2.fromOffset(10, 340)
    buyBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    buyBtn.BorderSizePixel = 0
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 11
    buyBtn.TextColor3 = Color3.fromRGB(180, 110, 255)
    buyBtn.Text = "🔗 BELI KEY"
    buyBtn.AutoButtonColor = false
    buyBtn.ZIndex = 11
    buyBtn.Parent = frame
    Instance.new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = buyBtn })

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(180, 110, 255)
    bStroke.Thickness = 1
    bStroke.Parent = buyBtn

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.5, -15, 0, 36)
    clearBtn.Position = UDim2.new(0.5, 5, 0, 340)
    clearBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    clearBtn.BorderSizePixel = 0
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 11
    clearBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    clearBtn.Text = "🗑️ CLEAR SAVED"
    clearBtn.AutoButtonColor = false
    clearBtn.ZIndex = 11
    clearBtn.Parent = frame
    Instance.new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = clearBtn })

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 100, 100)
    cStroke.Thickness = 1
    cStroke.Parent = clearBtn

    --======================================================--
    -- HANDLERS
    --======================================================--
    local isVerifying = false

    verifyBtn.MouseButton1Click:Connect(function()
        if isVerifying then return end
        isVerifying = true

        local key = input.Text
        status.Text = "⏳ Checking..."
        status.TextColor3 = Color3.fromRGB(200, 200, 100)
        verifyBtn.Text = "⏳ CHECKING..."

        task.wait(0.2)
        local valid, msg = KeySystem:ValidateKey(key)

        if valid then
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(100, 255, 150)
            verifyBtn.Text = "✅ SUCCESS"

            Notification.KeyActivated()

            saveKey(key)

            -- Close key UI dulu
            TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0),
            }):Play()
            TweenService:Create(overlay, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()

            task.wait(1)
            gui:Destroy()
            task.wait(2)
            loadMainScript()
        else
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            verifyBtn.Text = "🔓 VERIFY KEY"

            Notification.KeyNotActive()
            isVerifying = false
        end
    end)

    buyBtn.MouseButton1Click:Connect(function()
        local link = KeySystem:GetBuyLink()
        if setclipboard then
            setclipboard(link)
            status.Text = "🔗 Link beli dicopy!"
            status.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        clearSavedKey()
        status.Text = "🗑️ Saved key dihapus!"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
    end)

    input.FocusLost:Connect(function(enter)
        if enter then verifyBtn.MouseButton1Click:Fire() end
    end)

    -- Draggable
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input2)
        if input2.UserInputType == Enum.UserInputType.MouseButton1
        or input2.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input2.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input2)
        if input2.UserInputType == Enum.UserInputType.MouseMovement
        or input2.UserInputType == Enum.UserInputType.Touch then
            dragInput = input2
        end
    end)
    UserInputService.InputChanged:Connect(function(input2)
        if input2 == dragInput and dragging then
            local d = input2.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input2)
        if input2.UserInputType == Enum.UserInputType.MouseButton1
        or input2.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--========================================================--
-- 🚀 MAIN FLOW
--========================================================--

-- STEP 1: Loading notif
local hasSavedKey = getSavedKey() ~= nil
if hasSavedKey then
    Notification.Loading("VERIFYING KEY...", 4)
else
    Notification.Loading("LOADING...", 3)
end

task.wait(1.5)

-- STEP 2: Auto-login
local savedKey = getSavedKey()
local autoLoggedIn = false

if savedKey then
    local valid, msg = KeySystem:ValidateKey(savedKey)

    if valid then
        Notification.KeyActivated()
        task.wait(1.5)
        loadMainScript()
        autoLoggedIn = true
    else
        Notification.KeyNotActive()
        clearSavedKey()
        task.wait(1.5)
    end
end

-- STEP 3: Kalau bukan auto-login → tampilkan UI input key
if not autoLoggedIn then
    task.wait(0.5)
    ShowKeyUI()
end
