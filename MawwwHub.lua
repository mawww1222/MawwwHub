--========================================================--
-- MAWWWHUB KEY GATE + WELCOME NOTIFICATION
--========================================================--
local BASE = "https://raw.githubusercontent.com/mawww1222/MawwwHub/main/"

-- Load modules
local KeySystem = loadstring(game:HttpGet(BASE .. "KeySystem.lua?t=" .. tick()))()
local Notification = loadstring(game:HttpGet(BASE .. "Notification.lua?t=" .. tick()))()

--========================================================--
-- SAVED KEY HELPERS
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
-- 🔔 STEP 1: WELCOME NOTIFICATION (Muncul pertama kali)
--========================================================--
local function ShowWelcomeNotification()
    local hasSaved = getSavedKey() ~= nil

    -- Tampilkan notifikasi welcome
    Notification.WelcomePopup({
        HasKey = hasSaved,
    })

    -- Notifikasi tambahan setelah 2 detik
    task.delay(2, function()
        if hasSaved then
            Notification.Info(
                "🔍 Memverifikasi Key",
                "Sistem sedang memeriksa key kamu ke server...\n\n🌐 Server: Railway API",
                4
            )
        else
            Notification.Info(
                "📖 Cara Mendapatkan Key",
                "Belum punya key?\n\n" ..
                "1️⃣ Klik tombol BELI KEY di UI\n" ..
                "2️⃣ Chat owner via WhatsApp\n" ..
                "3️⃣ Masukkan key yang kamu terima\n\n" ..
                "💬 Hubungi owner untuk info harga.",
                8
            )
        end
    end)
end

--========================================================--
-- 🔔 STEP 2: AUTO-LOGIN CHECK (Jika ada key tersimpan)
--========================================================--
local function TryAutoLogin()
    local savedKey = getSavedKey()
    if not savedKey then
        return false
    end

    local valid, msg, data = KeySystem:ValidateKey(savedKey)

    if valid then
        Notification.Success(
            "🎉 Auto-Login Berhasil!",
            "Selamat datang kembali!\n\n" ..
            "📝 Key: " .. savedKey:sub(1, 15) .. "...\n" ..
            "⏱️ Status: Key valid\n" ..
            "🎯 Script akan dimuat dalam 1.5 detik...",
            5
        )

        task.wait(1.5)
        loadMainScript()
        return true
    else
        Notification.Error(
            "❌ Key Tidak Valid",
            "Key kamu sudah expired atau tidak valid.\n\n" ..
            "🔧 Silakan masukkan key baru di UI.\n" ..
            "📝 Pesan server: " .. (msg or "-") .. "\n\n" ..
            "💡 Menghapus key lama...",
            6
        )
        clearSavedKey()
        return false
    end
end

--========================================================--
-- 🔔 STEP 3: KEY UI (Jika belum ada key / invalid)
--========================================================--
local function ShowKeyUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MawwwKeyUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = game:GetService("CoreGui") end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(420, 320)
    frame.Position = UDim2.new(0.5, -210, 0.5, -160)
    frame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 110, 255)
    stroke.Thickness = 2
    stroke.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 110, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(80, 210, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 110, 255)),
    })
    grad.Rotation = 45
    grad.Parent = stroke

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.fromOffset(10, 12)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(180, 110, 255)
    title.Text = "🔐 MAWWWHUB"
    title.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 20)
    sub.Position = UDim2.fromOffset(10, 52)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextColor3 = Color3.fromRGB(200, 200, 210)
    sub.Text = "Masukkan key untuk mengakses script"
    sub.Parent = frame

    -- Input
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 42)
    input.Position = UDim2.fromOffset(10, 84)
    input.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
    input.BorderSizePixel = 0
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.TextColor3 = Color3.fromRGB(240, 240, 245)
    input.PlaceholderText = "MAWWW-XXXX-XXXX-XXXX"
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    input.Text = ""
    input.ClearTextOnFocus = false
    input.Parent = frame

    local inCorner = Instance.new("UICorner")
    inCorner.CornerRadius = UDim.new(0, 6)
    inCorner.Parent = input

    local inStroke = Instance.new("UIStroke")
    inStroke.Color = Color3.fromRGB(180, 110, 255)
    inStroke.Thickness = 1
    inStroke.Parent = input

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.fromOffset(10, 132)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Text = ""
    status.Parent = frame

    -- Verify button
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(1, -20, 0, 40)
    verifyBtn.Position = UDim2.fromOffset(10, 158)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(180, 110, 255)
    verifyBtn.BorderSizePixel = 0
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 14
    verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyBtn.Text = "VERIFY KEY"
    verifyBtn.AutoButtonColor = false
    verifyBtn.Parent = frame

    local vCorner = Instance.new("UICorner")
    vCorner.CornerRadius = UDim.new(0, 6)
    vCorner.Parent = verifyBtn

    -- Buy button
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0.5, -15, 0, 34)
    buyBtn.Position = UDim2.fromOffset(10, 206)
    buyBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    buyBtn.BorderSizePixel = 0
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 11
    buyBtn.TextColor3 = Color3.fromRGB(180, 110, 255)
    buyBtn.Text = "🔗 BELI KEY"
    buyBtn.AutoButtonColor = false
    buyBtn.Parent = frame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = buyBtn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(180, 110, 255)
    bStroke.Thickness = 1
    bStroke.Parent = buyBtn

    -- Clear button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.5, -15, 0, 34)
    clearBtn.Position = UDim2.new(0.5, 5, 0, 206)
    clearBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    clearBtn.BorderSizePixel = 0
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 11
    clearBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    clearBtn.Text = "🗑️ CLEAR SAVED"
    clearBtn.AutoButtonColor = false
    clearBtn.Parent = frame

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = clearBtn

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 100, 100)
    cStroke.Thickness = 1
    cStroke.Parent = clearBtn

    -- HWID info
    local hwidLbl = Instance.new("TextLabel")
    hwidLbl.Size = UDim2.new(1, -20, 0, 18)
    hwidLbl.Position = UDim2.fromOffset(10, 250)
    hwidLbl.BackgroundTransparency = 1
    hwidLbl.Font = Enum.Font.Gotham
    hwidLbl.TextSize = 9
    hwidLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
    hwidLbl.Text = "HWID: " .. KeySystem:GetHWID():sub(1, 30) .. "..."
    hwidLbl.Parent = frame

    -- Footer info
    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -20, 0, 18)
    footer.Position = UDim2.fromOffset(10, 270)
    footer.BackgroundTransparency = 1
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 10
    footer.TextColor3 = Color3.fromRGB(150, 150, 160)
    footer.Text = "Dapatkan key dengan klik BELI KEY"
    footer.Parent = frame

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
        verifyBtn.Text = "CHECKING..."

        task.wait(0.2)
        local valid, msg = KeySystem:ValidateKey(key)

        if valid then
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(100, 255, 150)
            verifyBtn.Text = "✅ SUCCESS"

            Notification.Success(
                "🎉 Key Berhasil Diverifikasi!",
                "Selamat bergabung di MawwwHub!\n\n" ..
                "📝 Key: " .. key:sub(1, 15) .. "...\n" ..
                "⏱️ Status: Aktif\n" ..
                "🎯 Script akan dimuat sekarang...",
                5
            )

            saveKey(key)
            task.wait(1)
            gui:Destroy()
            loadMainScript()
        else
            status.Text = msg
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            verifyBtn.Text = "VERIFY KEY"

            Notification.Error(
                "❌ Verifikasi Gagal",
                "Key yang kamu masukkan tidak valid.\n\n" ..
                "📝 Pesan: " .. (msg or "-") .. "\n\n" ..
                "💡 Pastikan key sudah benar atau beli key baru.",
                6
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

            Notification.Info(
                "🔗 Link Beli Key Dicopy!",
                "Link sudah dicopy ke clipboard.\n\n" ..
                "📱 Buka browser / chat owner untuk beli key.\n" ..
                "💰 Harga terjangkau, bisa permanent atau harian!",
                5
            )
        else
            status.Text = link
            status.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        clearSavedKey()
        status.Text = "🗑️ Saved key dihapus!"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)

        Notification.Warning(
            "🗑️ Key Tersimpan Dihapus",
            "Key yang tersimpan sudah dihapus dari device kamu.\n\n" ..
            "📝 Kamu perlu input key baru lain kali.",
            4
        )
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
    game:GetService("UserInputService").InputChanged:Connect(function(input2)
        if input2 == dragInput and dragging then
            local d = input2.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input2)
        if input2.UserInputType == Enum.UserInputType.MouseButton1
        or input2.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--========================================================--
-- 🚀 MAIN FLOW: Eksekusi saat script di-load
--========================================================--

-- STEP 1: Tampilkan notifikasi welcome pertama
ShowWelcomeNotification()

-- STEP 2: Tunggu 1 detik (biar user baca notif welcome)
task.wait(1)

-- STEP 3: Coba auto-login kalau ada key tersimpan
local autoLoggedIn = TryAutoLogin()

-- STEP 4: Kalau auto-login gagal, tampilkan UI input key
if not autoLoggedIn then
    task.wait(0.5)
    ShowKeyUI()
end
