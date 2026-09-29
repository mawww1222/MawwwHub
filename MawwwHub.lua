--========================================================--
-- MAWWWHUB KEY GATE — FIXED (No Pop-in Bug)
-- Key UI muncul duluan, notif simple
--========================================================--
local BASE = "https://raw.githubusercontent.com/mawww1222/MawwwHub/main/"

-- Load dengan pcall
local KeySystem, Notification
pcall(function() KeySystem = loadstring(game:HttpGet(BASE .. "KeySystem.lua?t=" .. tick()))() end)
pcall(function() Notification = loadstring(game:HttpGet(BASE .. "Notification.lua?t=" .. tick()))() end)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local KEY_LOGO_ID = "88250532753444"

--========================================================--
-- SAVED KEY
--========================================================--
local function getSavedKey()
    local ok, k = pcall(function()
        if isfile and isfile("MawwwHub/key.txt") then
            local r = readfile("MawwwHub/key.txt")
            if r and r ~= "" then return r end
        end
        return nil
    end)
    if ok then return k end
    return nil
end

local function saveKey(key)
    pcall(function()
        if writefile then
            if isfolder and not isfolder("MawwwHub") then makefolder("MawwwHub") end
            writefile("MawwwHub/key.txt", key)
        end
    end)
end

local function clearSavedKey()
    pcall(function()
        if delfile and isfile and isfile("MawwwHub/key.txt") then
            delfile("MawwwHub/key.txt")
        end
    end)
end

local function loadMainScript()
    pcall(function()
        loadstring(game:HttpGet(BASE .. "MawwwHub_Main.lua?t=" .. tick()))()
    end)
end

--========================================================--
-- SAFE NOTIF
--========================================================--
local function showNotif(text, color)
    if Notification and Notification.Loading then
        pcall(function()
            if Notification.ClearAll then Notification.ClearAll() end
            Notification.Loading(text, 4)
        end)
    end
end

--========================================================--
-- KEY UI — SIMPLE, LANGSUNG UKURAN PENUH
--========================================================--
local function ShowKeyUI()
    -- Hapus GUI lama kalau ada
    local old = CoreGui:FindFirstChild("MawwwKeyUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MawwwKeyUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    pcall(function() gui.Parent = CoreGui end)

    -- Overlay gelap
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 0
    overlay.Parent = gui

    --======================================================--
    -- FRAME UTAMA — LANGSUNG UKURAN PENUH (NO ANIMATION DELAY)
    --======================================================--
    local FRAME_W = 440
    local FRAME_H = 400

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.fromOffset(FRAME_W, FRAME_H)  -- 🎯 LANGSUNG FULL
    frame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = gui

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
    strokeGrad.Parent = stroke

    -- Rotasi gradient (opsional, bisa dihapus kalau bikin lag)
    task.spawn(function()
        while strokeGrad.Parent do
            for i = 0, 360, 5 do
                if not strokeGrad.Parent then break end
                strokeGrad.Rotation = i
                task.wait(0.05)
            end
        end
    end)

    --======================================================--
    -- LOGO
    --======================================================--
    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.fromOffset(130, 130)
    logoFrame.Position = UDim2.new(0.5, -65, 0, 20)
    logoFrame.BackgroundTransparency = 1
    logoFrame.ZIndex = 11
    logoFrame.Parent = frame

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.fromScale(1, 1)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://" .. KEY_LOGO_ID
    logo.ScaleType = Enum.ScaleType.Fit
    logo.ZIndex = 12
    logo.Parent = logoFrame

    --======================================================--
    -- TITLE
    --======================================================--
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

    --======================================================--
    -- INPUT
    --======================================================--
    local inputHolder = Instance.new("Frame")
    inputHolder.Size = UDim2.new(1, -20, 0, 40)
    inputHolder.Position = UDim2.fromOffset(10, 218)
    inputHolder.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
    inputHolder.BorderSizePixel = 0
    inputHolder.ZIndex = 11
    inputHolder.Parent = frame

    local inCorner = Instance.new("UICorner")
    inCorner.CornerRadius = UDim.new(0, 8)
    inCorner.Parent = inputHolder

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

    --======================================================--
    -- STATUS
    --======================================================--
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

    --======================================================--
    -- VERIFY BUTTON
    --======================================================--
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

    --======================================================--
    -- BELI + CLEAR
    --======================================================--
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

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = buyBtn

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

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = clearBtn

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
        if not KeySystem then
            status.Text = "❌ KeySystem tidak loaded!"
            return
        end
        isVerifying = true

        local key = input.Text
        status.Text = "⏳ Checking..."
        status.TextColor3 = Color3.fromRGB(200, 200, 100)
        verifyBtn.Text = "⏳ CHECKING..."

        task.wait(0.2)

        local valid, msg = false, "Error"
        pcall(function()
            valid, msg = KeySystem:ValidateKey(key)
        end)

        if valid then
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(100, 255, 150)
            verifyBtn.Text = "✅ SUCCESS"

            showNotif("KEY ACTIVATED", Color3.fromRGB(80, 230, 120))
            saveKey(key)

            task.wait(1)
            gui:Destroy()
            task.wait(2)
            loadMainScript()
        else
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            verifyBtn.Text = "🔓 VERIFY KEY"
            isVerifying = false
        end
    end)

    buyBtn.MouseButton1Click:Connect(function()
        if not KeySystem then return end
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

    return gui
end

--========================================================--
-- 🚀 MAIN FLOW — KALAU ADA KEY, AUTO-LOGIN. KALAU TIDAK, KEY UI
--========================================================--
print("[MawwwHub] Starting...")

local savedKey = getSavedKey()

if savedKey and KeySystem then
    print("[MawwwHub] Found saved key, validating...")

    local valid = false
    pcall(function()
        valid = KeySystem:ValidateKey(savedKey)
    end)

    if valid then
        print("[MawwwHub] Auto-login success")
        showNotif("KEY ACTIVATED", Color3.fromRGB(80, 230, 120))
        task.wait(2)
        loadMainScript()
    else
        print("[MawwwHub] Saved key invalid, clearing...")
        clearSavedKey()
        task.wait(0.5)
        ShowKeyUI()
    end
else
    print("[MawwwHub] No saved key, showing Key UI")
    ShowKeyUI()
end
