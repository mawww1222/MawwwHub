--========================================================--
-- MAWWWHUB KEY GATE — Cinematic Animation Edition
--========================================================--
local BASE = "https://raw.githubusercontent.com/mawww1222/MawwwHub/main/"

local KeySystem = loadstring(game:HttpGet(BASE .. "KeySystem.lua?t=" .. tick()))()
local Notification = loadstring(game:HttpGet(BASE .. "Notification.lua?t=" .. tick()))()

--========================================================--
-- SERVICES
--========================================================--
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

--========================================================--
-- SAVED KEY
--========================================================--
local function getSavedKey()
    if isfile and isfile("MawwwHub/key.txt") then
        local ok, k = pcall(readfile, "MawwwHub/key.txt")
        if ok then return k end
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
-- ✨ ANIMATED KEY UI (Cinematic Pop-in)
--========================================================--
local function ShowKeyUI()
    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "MawwwKeyUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    pcall(function() gui.Parent = CoreGui end)

    -- Overlay background (blur/gelap)
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 0
    overlay.Parent = gui

    -- Animated gradient background blob 1
    local blob1 = Instance.new("Frame")
    blob1.Size = UDim2.fromOffset(400, 400)
    blob1.Position = UDim2.new(0.2, 0, 0.3, 0)
    blob1.BackgroundColor3 = Color3.fromRGB(180, 110, 255)
    blob1.BackgroundTransparency = 0.85
    blob1.BorderSizePixel = 0
    blob1.ZIndex = 1
    blob1.Parent = gui
    local blob1Corner = Instance.new("UICorner")
    blob1Corner.CornerRadius = UDim.new(1, 0)
    blob1Corner.Parent = blob1

    -- Animated gradient background blob 2
    local blob2 = Instance.new("Frame")
    blob2.Size = UDim2.fromOffset(350, 350)
    blob2.Position = UDim2.new(0.7, 0, 0.6, 0)
    blob2.BackgroundColor3 = Color3.fromRGB(80, 210, 255)
    blob2.BackgroundTransparency = 0.85
    blob2.BorderSizePixel = 0
    blob2.ZIndex = 1
    blob2.Parent = gui
    local blob2Corner = Instance.new("UICorner")
    blob2Corner.CornerRadius = UDim.new(1, 0)
    blob2Corner.Parent = blob2

    -- Blob animation loop (bergerak pelan)
    task.spawn(function()
        while blob1.Parent do
            TweenService:Create(blob1, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.4, 0, 0.5, 0),
            }):Play()
            task.wait(4)
            if not blob1.Parent then break end
            TweenService:Create(blob1, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.2, 0, 0.3, 0),
            }):Play()
            task.wait(4)
        end
    end)

    task.spawn(function()
        while blob2.Parent do
            TweenService:Create(blob2, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.5, 0, 0.3, 0),
            }):Play()
            task.wait(5)
            if not blob2.Parent then break end
            TweenService:Create(blob2, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.7, 0, 0.6, 0),
            }):Play()
            task.wait(5)
        end
    end)

    --======================================================--
    -- MAIN FRAME (pop-in scale)
    --======================================================--
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.fromOffset(440, 360)
    frame.Position = UDim2.new(0.5, -220, 0.5, -180)
    frame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = gui

    -- Scale dari 0 → 1 (pop-in)
    frame.Size = UDim2.fromOffset(0, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    local targetSize = UDim2.fromOffset(440, 360)
    local targetPos = UDim2.new(0.5, -220, 0.5, -180)
    task.delay(0.1, function()
        TweenService:Create(frame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = targetSize,
            Position = targetPos,
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

    -- Gradient animasi pada stroke
    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 110, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(80, 210, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 105, 180)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 110, 255)),
    })
    strokeGrad.Rotation = 0
    strokeGrad.Parent = stroke

    -- Rotasi gradient
    task.spawn(function()
        while strokeGrad.Parent do
            for i = 0, 360, 3 do
                if not strokeGrad.Parent then break end
                strokeGrad.Rotation = i
                task.wait(0.03)
            end
        end
    end)

    --======================================================--
    -- FLOATING LOCK ICON (bounce loop)
    --======================================================--
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.fromOffset(60, 60)
    iconFrame.Position = UDim2.new(0.5, -30, 0, 20)
    iconFrame.BackgroundColor3 = Color3.fromRGB(180, 110, 255)
    iconFrame.BackgroundTransparency = 0.15
    iconFrame.BorderSizePixel = 0
    iconFrame.ZIndex = 11
    iconFrame.Parent = frame

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame

    local iconGrad = Instance.new("UIGradient")
    iconGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 110, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 210, 255)),
    })
    iconGrad.Rotation = 135
    iconGrad.Parent = iconFrame

    -- Icon glow di belakang
    local iconGlow = Instance.new("Frame")
    iconGlow.Size = UDim2.new(1, 12, 1, 12)
    iconGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    iconGlow.BackgroundColor3 = Color3.fromRGB(180, 110, 255)
    iconGlow.BackgroundTransparency = 0.5
    iconGlow.BorderSizePixel = 0
    iconGlow.ZIndex = 10
    iconGlow.Parent = iconFrame

    local iconGlowCorner = Instance.new("UICorner")
    iconGlowCorner.CornerRadius = UDim.new(1, 0)
    iconGlowCorner.Parent = iconGlow

    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.fromScale(1, 1)
    iconText.BackgroundTransparency = 1
    iconText.Font = Enum.Font.GothamBold
    iconText.TextSize = 32
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.Text = "🔐"
    iconText.ZIndex = 12
    iconText.Parent = iconFrame

    -- Bounce animation
    task.spawn(function()
        while iconFrame.Parent do
            TweenService:Create(iconFrame, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.5, -30, 0, 12),
            }):Play()
            TweenService:Create(iconGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.3,
            }):Play()
            task.wait(0.8)
            if not iconFrame.Parent then break end
            TweenService:Create(iconFrame, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.5, -30, 0, 20),
            }):Play()
            TweenService:Create(iconGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.6,
            }):Play()
            task.wait(0.8)
        end
    end)

    -- Sparkle particles di sekitar icon
    task.spawn(function()
        local sparkleIds = {"rbxassetid://5014978988", "rbxassetid://5014979922"}
        while iconFrame.Parent do
            task.wait(0.4)
            if not iconFrame.Parent then break end
            task.spawn(function()
                local angle = math.random() * math.pi * 2
                local radius = 40
                local sparkle = Instance.new("ImageLabel")
                sparkle.Size = UDim2.fromOffset(14, 14)
                sparkle.Position = UDim2.new(0.5, -7, 0.5, -7)
                sparkle.BackgroundTransparency = 1
                sparkle.Image = sparkleIds[math.random(1, #sparkleIds)]
                sparkle.ImageColor3 = math.random() > 0.5 and Color3.fromRGB(180, 110, 255) or Color3.fromRGB(255, 255, 255)
                sparkle.ImageTransparency = 0
                sparkle.ZIndex = 13
                sparkle.Parent = iconFrame

                local endX = 30 + math.cos(angle) * radius
                local endY = 30 + math.sin(angle) * radius

                local tween = TweenService:Create(sparkle, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.fromOffset(endX - 7, endY - 7),
                    ImageTransparency = 1,
                    Size = UDim2.fromOffset(6, 6),
                    Rotation = math.random(180, 720),
                })
                tween:Play()
                tween.Completed:Connect(function() sparkle:Destroy() end)
            end)
        end
    end)

    --======================================================--
    -- TITLE (slide dari atas)
    --======================================================--
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 32)
    title.Position = UDim2.fromOffset(10, 90)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "MAWWWHUB"
    title.TextTransparency = 1
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

    -- Slide + fade in title
    title.Position = UDim2.fromOffset(10, 70)
    task.delay(0.4, function()
        TweenService:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(10, 90),
            TextTransparency = 0,
        }):Play()
    end)

    --======================================================--
    -- SUBTITLE
    --======================================================--
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 18)
    sub.Position = UDim2.fromOffset(10, 124)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextColor3 = Color3.fromRGB(200, 200, 210)
    sub.Text = "Masukkan key untuk mengakses script"
    sub.TextTransparency = 1
    sub.ZIndex = 11
    sub.Parent = frame

    task.delay(0.55, function()
        TweenService:Create(sub, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
    end)

    --======================================================--
    -- INPUT (slide dari bawah)
    --======================================================--
    local inputHolder = Instance.new("Frame")
    inputHolder.Size = UDim2.new(1, -20, 0, 42)
    inputHolder.Position = UDim2.fromOffset(10, 152)
    inputHolder.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
    inputHolder.BorderSizePixel = 0
    inputHolder.ZIndex = 11
    inputHolder.Parent = frame
    inputHolder.BackgroundTransparency = 1

    local inCorner = Instance.new("UICorner")
    inCorner.CornerRadius = UDim.new(0, 8)
    inCorner.Parent = inputHolder

    local inStroke = Instance.new("UIStroke")
    inStroke.Color = Color3.fromRGB(180, 110, 255)
    inStroke.Thickness = 1.5
    inStroke.Transparency = 1
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
    input.TextTransparency = 1
    input.ZIndex = 12
    input.Parent = inputHolder

    -- Fade in input
    task.delay(0.7, function()
        TweenService:Create(inputHolder, TweenInfo.new(0.4), { BackgroundTransparency = 0 }):Play()
        TweenService:Create(inStroke, TweenInfo.new(0.4), { Transparency = 0 }):Play()
        TweenService:Create(input, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
    end)

    -- Focus animation untuk input
    input.Focused:Connect(function()
        TweenService:Create(inStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(80, 210, 255),
            Thickness = 2,
        }):Play()
    end)
    input.FocusLost:Connect(function()
        TweenService:Create(inStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(180, 110, 255),
            Thickness = 1.5,
        }):Play()
    end)

    --======================================================--
    -- STATUS LABEL
    --======================================================--
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.fromOffset(10, 200)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Text = ""
    status.TextTransparency = 1
    status.ZIndex = 11
    status.Parent = frame

    --======================================================--
    -- VERIFY BUTTON (slide + pulsing glow)
    --======================================================--
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(1, -20, 0, 42)
    verifyBtn.Position = UDim2.fromOffset(10, 224)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(180, 110, 255)
    verifyBtn.BorderSizePixel = 0
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 15
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.Text = "🔓 VERIFY KEY"
    verifyBtn.AutoButtonColor = false
    verifyBtn.TextTransparency = 1
    verifyBtn.BackgroundTransparency = 1
    verifyBtn.ZIndex = 11
    verifyBtn.Parent = frame

    local vCorner = Instance.new("UICorner")
    vCorner.CornerRadius = UDim.new(0, 8)
    vCorner.Parent = verifyBtn

    local vGrad = Instance.new("UIGradient")
    vGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 110, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 210, 255)),
    })
    vGrad.Rotation = 45
    vGrad.Parent = verifyBtn

    local vGlow = Instance.new("Frame")
    vGlow.Size = UDim2.new(1, 10, 1, 10)
    vGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    vGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    vGlow.BackgroundColor3 = Color3.fromRGB(180, 110, 255)
    vGlow.BackgroundTransparency = 0.4
    vGlow.BorderSizePixel = 0
    vGlow.ZIndex = 10
    vGlow.Parent = verifyBtn

    local vGlowCorner = Instance.new("UICorner")
    vGlowCorner.CornerRadius = UDim.new(0, 12)
    vGlowCorner.Parent = vGlow

    -- Fade in verify button
    task.delay(0.85, function()
        TweenService:Create(verifyBtn, TweenInfo.new(0.4), {
            BackgroundTransparency = 0,
            TextTransparency = 0,
        }):Play()
    end)

    -- Pulsing glow loop
    task.spawn(function()
        while verifyBtn.Parent do
            TweenService:Create(vGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.7,
                Size = UDim2.new(1, 16, 1, 16),
            }):Play()
            task.wait(1.2)
            if not verifyBtn.Parent then break end
            TweenService:Create(vGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 10, 1, 10),
            }):Play()
            task.wait(1.2)
        end
    end)

    --======================================================--
    -- BELI KEY + CLEAR BUTTON (slide dari bawah)
    --======================================================--
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0.5, -15, 0, 36)
    buyBtn.Position = UDim2.fromOffset(10, 276)
    buyBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    buyBtn.BorderSizePixel = 0
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 11
    buyBtn.TextColor3 = Color3.fromRGB(180, 110, 255)
    buyBtn.Text = "🔗 BELI KEY"
    buyBtn.AutoButtonColor = false
    buyBtn.TextTransparency = 1
    buyBtn.BackgroundTransparency = 1
    buyBtn.ZIndex = 11
    buyBtn.Parent = frame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = buyBtn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(180, 110, 255)
    bStroke.Thickness = 1
    bStroke.Transparency = 1
    bStroke.Parent = buyBtn

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.5, -15, 0, 36)
    clearBtn.Position = UDim2.new(0.5, 5, 0, 276)
    clearBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    clearBtn.BorderSizePixel = 0
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 11
    clearBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    clearBtn.Text = "🗑️ CLEAR SAVED"
    clearBtn.AutoButtonColor = false
    clearBtn.TextTransparency = 1
    clearBtn.BackgroundTransparency = 1
    clearBtn.ZIndex = 11
    clearBtn.Parent = frame

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = clearBtn

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 100, 100)
    cStroke.Thickness = 1
    cStroke.Transparency = 1
    cStroke.Parent = clearBtn

    task.delay(1, function()
        TweenService:Create(buyBtn, TweenInfo.new(0.4), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.4), { Transparency = 0 }):Play()
        TweenService:Create(clearBtn, TweenInfo.new(0.4), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
        TweenService:Create(cStroke, TweenInfo.new(0.4), { Transparency = 0 }):Play()
    end)

    --======================================================--
    -- HWID + FOOTER
    --======================================================--
    local hwidLbl = Instance.new("TextLabel")
    hwidLbl.Size = UDim2.new(1, -20, 0, 14)
    hwidLbl.Position = UDim2.fromOffset(10, 318)
    hwidLbl.BackgroundTransparency = 1
    hwidLbl.Font = Enum.Font.Gotham
    hwidLbl.TextSize = 9
    hwidLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
    hwidLbl.Text = "HWID: " .. KeySystem:GetHWID():sub(1, 30) .. "..."
    hwidLbl.TextTransparency = 1
    hwidLbl.ZIndex = 11
    hwidLbl.Parent = frame

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -20, 0, 14)
    footer.Position = UDim2.fromOffset(10, 332)
    footer.BackgroundTransparency = 1
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 10
    footer.TextColor3 = Color3.fromRGB(150, 150, 160)
    footer.Text = "Dapatkan key dengan klik BELI KEY"
    footer.TextTransparency = 1
    footer.ZIndex = 11
    footer.Parent = frame

    task.delay(1.1, function()
        TweenService:Create(hwidLbl, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
        TweenService:Create(footer, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
    end)

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
        status.TextTransparency = 0
        verifyBtn.Text = "⏳ CHECKING..."

        task.wait(0.2)
        local valid, msg = KeySystem:ValidateKey(key)

        if valid then
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(100, 255, 150)
            verifyBtn.Text = "✅ SUCCESS"

            Notification.Celebrate(
                "KEY VALID!",
                "Selamat " .. (Player.DisplayName or Player.Name) ..
                "!\n\nKey berhasil diverifikasi.\nScript akan dimuat..."
            )

            saveKey(key)
            task.wait(2.5)
            gui:Destroy()
            loadMainScript()
        else
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            verifyBtn.Text = "🔓 VERIFY KEY"

            Notification.Error(
                "Verifikasi Gagal",
                "Key tidak valid.\n\nPesan: " .. (msg or "-"),
                5
            )
            isVerifying = false
        end
    end)

    buyBtn.MouseButton1Click:Connect(function()
        local link = KeySystem:GetBuyLink()
        if setclipboard then
            setclipboard(link)
            status.Text = "🔗 Link beli dicopy!"
            status.TextColor3 = Color3.fromRGB(100, 200, 255)
            status.TextTransparency = 0

            Notification.Info(
                "Link Dicopy!",
                "Link beli sudah dicopy.\nBuka browser untuk beli key.",
                4
            )
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        clearSavedKey()
        status.Text = "🗑️ Saved key dihapus!"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        status.TextTransparency = 0
        Notification.Warning("Key Dihapus", "Saved key sudah dihapus.", 4)
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
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
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
local hasSavedKey = getSavedKey() ~= nil
Notification.WelcomeImage({ HasKey = hasSavedKey })

local loadingCard = nil
if hasSavedKey then
    task.wait(2.5)
    loadingCard = Notification.Loading(
        "Memverifikasi Key",
        "Menghubungi server Railway..."
    )
end

task.wait(1)
local savedKey = getSavedKey()
local autoLoggedIn = false

if savedKey then
    local valid, msg = KeySystem:ValidateKey(savedKey)

    if valid then
        if loadingCard then
            Notification.UpdateLoading(loadingCard, {
                Type = "Success",
                Title = "Auto-Login Berhasil!",
                Message = "Key valid. Memuat script...",
            })

            task.wait(0.3)
            Notification.Celebrate("SELAMAT DATANG!", "Auto-login berhasil!")

            task.delay(3, function()
                if loadingCard and loadingCard.Parent then
                    loadingCard:Destroy()
                end
            end)
        else
            Notification.Celebrate("AUTO-LOGIN BERHASIL!", "Key valid. Memuat script...")
        end

        task.wait(3)
        loadMainScript()
        autoLoggedIn = true
    else
        if loadingCard then
            Notification.UpdateLoading(loadingCard, {
                Type = "Error",
                Title = "Key Tidak Valid",
                Message = "Key expired atau salah.\n" .. (msg or ""),
            })
            task.delay(3, function()
                if loadingCard and loadingCard.Parent then
                    loadingCard:Destroy()
                end
            end)
        else
            Notification.Error("Key Tidak Valid", "Key expired atau salah.\n" .. (msg or ""), 5)
        end
        clearSavedKey()
    end
end

if not autoLoggedIn then
    task.wait(2)
    Notification.Info(
        "Masukkan Key",
        "Silakan masukkan key kamu.\nBelum punya? Klik BELI KEY.",
        6
    )
    ShowKeyUI()
end
