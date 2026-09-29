--========================================================--
-- MAWWWHUB MAIN SCRIPT • HOME WITH PHOTO
--========================================================--
local BASE = "https://raw.githubusercontent.com/mawww1222/MawwwHub/main/"

local Library      = loadstring(game:HttpGet(BASE .. "Library.lua?t=" .. tick()))()
local ThemeManager = loadstring(game:HttpGet(BASE .. "ThemeManager.lua?t=" .. tick()))()
local SaveManager  = loadstring(game:HttpGet(BASE .. "SaveManager.lua?t=" .. tick()))()

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace        = game:GetService("Workspace")
local CoreGui          = game:GetService("CoreGui")
local TeleportService  = game:GetService("TeleportService")

local Player = Players.LocalPlayer

--========================================================--
-- 🎨 ASSETS
--========================================================--
local ASSETS = {
    ToggleIcon   = 88250532753444,
    HomePhoto    = 88250532753444,
    HomeBanner   = 94736003254558,
}

--========================================================--
-- THEME
--========================================================--
Library.Scheme.AccentColor     = Color3.fromRGB(80, 170, 255)
Library.Scheme.BackgroundColor = Color3.fromRGB(8, 14, 26)
Library.Scheme.MainColor       = Color3.fromRGB(20, 32, 52)
Library.Scheme.OutlineColor    = Color3.fromRGB(80, 170, 255)
Library.Scheme.FontColor       = Color3.fromRGB(235, 242, 255)

local Palette = {
    Purple = Color3.fromRGB(180, 110, 255),
    Pink   = Color3.fromRGB(255, 105, 180),
    Cyan   = Color3.fromRGB(80, 210, 255),
    Green  = Color3.fromRGB(90, 230, 150),
    Yellow = Color3.fromRGB(255, 215, 90),
    Orange = Color3.fromRGB(255, 150, 80),
    Red    = Color3.fromRGB(255, 95, 95),
    Blue   = Color3.fromRGB(110, 150, 255),
}
local ColorKeys = { "Purple", "Pink", "Cyan", "Green", "Yellow", "Orange", "Red", "Blue" }
local ColorIdx = 0
local function NextColor()
    ColorIdx = ColorIdx + 1
    if ColorIdx > #ColorKeys then ColorIdx = 1 end
    return Palette[ColorKeys[ColorIdx]]
end

--========================================================--
-- TOGGLE MENU BUTTON
--========================================================--
local function CreateToggleMenu(IconId)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MawwwHubToggle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = CoreGui end)

    local MainButton = Instance.new("TextButton")
    MainButton.Text = ""
    MainButton.AutoButtonColor = false
    MainButton.Size = UDim2.fromOffset(42, 42)
    MainButton.Position = UDim2.fromOffset(15, 120)
    MainButton.BackgroundColor3 = Color3.fromRGB(20, 32, 52)
    MainButton.BackgroundTransparency = 0.05
    MainButton.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainButton

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Palette.Blue
    Stroke.Thickness = 1.6
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MainButton

    local Grad = Instance.new("UIGradient")
    Grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Palette.Blue),
        ColorSequenceKeypoint.new(0.25, Palette.Cyan),
        ColorSequenceKeypoint.new(0.50, Palette.Purple),
        ColorSequenceKeypoint.new(0.75, Palette.Blue),
        ColorSequenceKeypoint.new(1.00, Palette.Cyan),
    })
    Grad.Rotation = 45
    Grad.Parent = Stroke

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.fromScale(0.7, 0.7)
    Icon.Position = UDim2.fromScale(0.15, 0.15)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://" .. IconId
    Icon.Parent = MainButton

    MainButton.MouseButton1Click:Connect(function() Library:Toggle() end)
    Library:MakeDraggable(MainButton, MainButton)
end

CreateToggleMenu(ASSETS.ToggleIcon)

--========================================================--
-- WINDOW
--========================================================--
local Window = Library:CreateWindow({
    Title = "MawwwHub",
    Footer = "MawwwHub • Blue Edition",
    Icon = ASSETS.ToggleIcon,
    CornerRadius = 8,
    NotifySide = "Right",
    ShowCustomCursor = false,
    ToggleKeybind = Enum.KeyCode.LeftControl,
})

--========================================================--
-- TABS
--========================================================--
local Tabs = {
    Home     = Window:AddTab("Home", "house"),
    Player   = Window:AddTab("Player", "user"),
    Visuals  = Window:AddTab("Visuals", "eye"),
    Combat   = Window:AddTab("Combat", "swords"),
    Movement = Window:AddTab("Movement", "move"),
    Scripts  = Window:AddTab("Scripts", "code"),
    Misc     = Window:AddTab("Misc", "sliders-horizontal"),
}

--========================================================--
-- 🏠 HOME TAB
--========================================================--
local HomeLeft  = Tabs.Home:AddLeftGroupbox("Welcome", "sparkles")
local HomeRight = Tabs.Home:AddRightGroupbox("Info", "info")

HomeLeft:AddImage(ASSETS.HomePhoto, {
    Text = "",
    Height = 150,
})

HomeLeft:AddLabel("✨ Selamat datang di MawwwHub ✨"):AddColor(Color3.fromRGB(180, 220, 255))
HomeLeft:AddLabel("UI Blue Edition"):AddColor(Color3.fromRGB(150, 200, 255))
HomeLeft:AddLabel("Discord: MawwwHub#0001"):AddColor(Color3.fromRGB(120, 180, 255))

HomeRight:AddLabel("UI Settings"):AddColor(Palette.Cyan)
HomeRight:AddDivider()
HomeRight:AddToggle("HomeUICustomCursor", {
    Text = "Custom Cursor (PC only)",
    Default = false,
    Callback = function(v)
        Library.ShowCustomCursor = v
        Library.RefreshCursor()
    end,
})
HomeRight:AddDropdown("HomeNotifySide", {
    Text = "Notification Side",
    Values = { "Left", "Right" }, Default = "Right", Multi = false,
    Callback = function(v) Library:SetNotifySide(v) end,
})
HomeRight:AddDropdown("HomeTheme", {
    Text = "Theme Preset",
    Values = { "Default", "Blue", "Pink", "Cyan", "Dark" }, Default = "Blue", Multi = false,
    Callback = function(v)
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetTheme(v)
    end,
})
HomeRight:AddDivider()
HomeRight:AddButton("📋 Copy Discord Tag", function()
    if setclipboard then setclipboard("MawwwHub#0001") end
    Library:Notify({ Title = "Copied", Content = "Discord tag disalin!", Duration = 3 })
end)
HomeRight:AddButton("🔄 Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId)
end)
HomeRight:AddButton("❌ Unload MawwwHub", function() Library:Unload() end)

--========================================================--
-- PLAYER
--========================================================--
local PlayerMain  = Tabs.Player:AddLeftGroupbox("Character", "user")
local PlayerExtra = Tabs.Player:AddRightGroupbox("Extras", "sparkles")

PlayerMain:AddToggle("WalkSpeedToggle", { Text = "Walk Speed", Default = false, Callback = function(v) _G.Mawww_WalkSpeed = v end })
PlayerMain:AddSlider("WalkSpeedValue", { Text = "Speed Value", Default = 16, Min = 8, Max = 200, Rounding = 0, Callback = function(v) _G.Mawww_WalkSpeedValue = v end })
PlayerMain:AddToggle("JumpPowerToggle", { Text = "Jump Power", Default = false, Callback = function(v) _G.Mawww_JumpPower = v end })
PlayerMain:AddSlider("JumpPowerValue", { Text = "Jump Value", Default = 50, Min = 30, Max = 300, Rounding = 0, Callback = function(v) _G.Mawww_JumpPowerValue = v end })

PlayerExtra:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false, Callback = function(v) _G.Mawww_InfJump = v end })
PlayerExtra:AddToggle("AntiAFK", { Text = "Anti AFK", Default = false, Callback = function(v) _G.Mawww_AntiAFK = v end })
PlayerExtra:AddToggle("GodMode", { Text = "God Mode", Default = false, Callback = function(v) _G.Mawww_GodMode = v end })

--========================================================--
-- VISUALS
--========================================================--
local ESPMain = Tabs.Visuals:AddLeftGroupbox("ESP", "scan-eye")
local ESPOpts = Tabs.Visuals:AddRightGroupbox("Options", "settings")

ESPMain:AddToggle("ESPPlayer",   { Text = "ESP Player",   Default = false, Callback = function(v) _G.Mawww_ESP_Player = v end })
ESPMain:AddToggle("ESPName",     { Text = "ESP Name",     Default = true,  Callback = function(v) _G.Mawww_ESP_Name = v end })
ESPMain:AddToggle("ESPHealth",   { Text = "ESP Health",   Default = false, Callback = function(v) _G.Mawww_ESP_Health = v end })
ESPMain:AddToggle("ESPDistance", { Text = "ESP Distance", Default = true,  Callback = function(v) _G.Mawww_ESP_Distance = v end })
ESPMain:AddToggle("ESPTracer",   { Text = "Tracer Line",  Default = false, Callback = function(v) _G.Mawww_ESP_Tracer = v end })

ESPOpts:AddColorpicker("ESPColor", { Text = "ESP Color", Default = Palette.Blue, Callback = function(v) _G.Mawww_ESP_Color = v end })
ESPOpts:AddSlider("ESPRadius", { Text = "ESP Radius", Default = 500, Min = 50, Max = 5000, Rounding = 0, Callback = function(v) _G.Mawww_ESP_Radius = v end })
ESPOpts:AddSlider("ESPTransparency", { Text = "Transparency", Default = 0.3, Min = 0, Max = 1, Rounding = 2, Callback = function(v) _G.Mawww_ESP_Transparency = v end })

--========================================================--
-- COMBAT
--========================================================--
local CombatMain = Tabs.Combat:AddLeftGroupbox("Combat", "swords")
local CombatAim  = Tabs.Combat:AddRightGroupbox("Aim Assist", "crosshair")

CombatMain:AddToggle("AutoParry",  { Text = "Auto Parry",  Default = false, Callback = function(v) _G.Mawww_AutoParry = v end })
CombatMain:AddSlider("ParryRange", { Text = "Parry Range", Default = 15, Min = 5, Max = 40, Rounding = 0, Callback = function(v) _G.Mawww_ParryRange = v end })
CombatMain:AddToggle("AutoAttack", { Text = "Auto Attack", Default = false, Callback = function(v) _G.Mawww_AutoAttack = v end })
CombatMain:AddSlider("AttackDelay",{ Text = "Attack Delay",Default = 0.45, Min = 0.1, Max = 2, Rounding = 2, Callback = function(v) _G.Mawww_AttackDelay = v end })
CombatMain:AddToggle("KillAura",   { Text = "Kill Aura",   Default = false, Callback = function(v) _G.Mawww_KillAura = v end })

CombatAim:AddToggle("SilentAim",  { Text = "Silent Aim",  Default = false, Callback = function(v) _G.Mawww_SilentAim = v end })
CombatAim:AddToggle("ShowTracer", { Text = "Show Tracer", Default = false, Callback = function(v) _G.Mawww_ShowTracer = v end })
CombatAim:AddSlider("SilentAimFOV", { Text = "FOV", Default = 250, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) _G.Mawww_SilentAim_FOV = v end })
CombatAim:AddDropdown("SilentAimPart", { Text = "Target Part", Values = { "Head", "HumanoidRootPart", "Torso" }, Default = "Head", Multi = false, Callback = function(v) _G.Mawww_SilentAim_Part = v end })

--========================================================--
-- MOVEMENT
--========================================================--
local MoveMain     = Tabs.Movement:AddLeftGroupbox("Movement", "move")
local MoveTeleport = Tabs.Movement:AddRightGroupbox("Teleport", "navigation")

MoveMain:AddToggle("InfiniteJumpMove", { Text = "Infinite Jump", Default = false, Callback = function(v) _G.Mawww_InfJump = v end })
MoveMain:AddToggle("Fly",               { Text = "Fly (Basic)",   Default = false, Callback = function(v) _G.Mawww_Fly = v end })
MoveMain:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 50, Min = 10, Max = 500, Rounding = 0, Callback = function(v) _G.Mawww_FlySpeed = v end })
MoveMain:AddToggle("Noclip",     { Text = "Noclip",      Default = false, Callback = function(v) _G.Mawww_Noclip = v end })
MoveMain:AddToggle("SpeedBoost", { Text = "Speed Boost", Default = false, Callback = function(v) _G.Mawww_SpeedBoost = v end })

MoveTeleport:AddButton("📌 Save Position", function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        _G.Mawww_SavedPos = hrp.CFrame
        Library:Notify({ Title = "Saved", Content = "Posisi disimpan!", Duration = 3 })
    end
end)
MoveTeleport:AddButton("🎯 Teleport to Saved", function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and _G.Mawww_SavedPos then
        hrp.CFrame = _G.Mawww_SavedPos
        Library:Notify({ Title = "Teleported", Content = "Ke posisi tersimpan!", Duration = 3 })
    end
end)
MoveTeleport:AddButton("🚀 Teleport to Mouse", function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local mouse = Player:GetMouse()
    if hrp and mouse.Hit then
        hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end)

--========================================================--
-- SCRIPTS
--========================================================--
local ScriptsBox   = Tabs.Scripts:AddLeftGroupbox("Script Loader", "code")
local ScriptsQuick = Tabs.Scripts:AddRightGroupbox("Quick Load", "zap")

ScriptsBox:AddInput("ScriptURL", {
    Text = "Script URL", Default = "",
    Placeholder = "https://... (raw lua)",
    Callback = function(v) _G.Mawww_ScriptURL = v end,
})
ScriptsBox:AddButton("▶️ Execute Script", function()
    if _G.Mawww_ScriptURL and _G.Mawww_ScriptURL ~= "" then
        local ok, err = pcall(function() loadstring(game:HttpGet(_G.Mawww_ScriptURL))() end)
        if ok then
            Library:Notify({ Title = "Success", Content = "Script dijalankan!", Duration = 3 })
        else
            Library:Notify({ Title = "Error", Content = tostring(err), Duration = 4 })
        end
    else
        Library:Notify({ Title = "Warning", Content = "URL masih kosong!", Duration = 3 })
    end
end)
ScriptsBox:AddDivider()
ScriptsBox:AddButton("🧹 Clear Console", function() if rconsoleclear then rconsoleclear() end end)

ScriptsQuick:AddButton("⚡ Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)
ScriptsQuick:AddButton("🌊 Hydroxide", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Upbolt/Hydroxide/master/init.lua"))()()
end)
ScriptsQuick:AddButton("🔧 IY Admin Commands", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

--========================================================--
-- MISC
--========================================================--
local MiscCamera = Tabs.Misc:AddLeftGroupbox("Camera", "camera")
local MiscFun    = Tabs.Misc:AddRightGroupbox("Fun", "smile")

MiscCamera:AddToggle("UnlimitedZoom", { Text = "Unlimited Zoom", Default = false, Callback = function(v) _G.Mawww_UnlimZoom = v end })
MiscCamera:AddSlider("MaxZoom", { Text = "Max Zoom Distance", Default = 1000, Min = 100, Max = 10000, Rounding = 0, Callback = function(v) _G.Mawww_MaxZoom = v end })
MiscCamera:AddToggle("CustomFOV", { Text = "Custom FOV", Default = false, Callback = function(v) _G.Mawww_CustomFOV = v end })
MiscCamera:AddSlider("FOVValue", { Text = "FOV Value", Default = 70, Min = 40, Max = 120, Rounding = 0, Callback = function(v) _G.Mawww_FOV = v end })

MiscFun:AddButton("🎵 Play Emote (Wave)", function()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if r and r:FindFirstChild("EmoteHandler") then
        pcall(function() r.EmoteHandler:FireServer("Wave") end)
    end
end)
MiscFun:AddButton("💃 Play Emote (Dance)", function()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if r and r:FindFirstChild("EmoteHandler") then
        pcall(function() r.EmoteHandler:FireServer("Mannrobics") end)
    end
end)
MiscFun:AddToggle("JerkTool", { Text = "Jerk Tool", Default = false, Callback = function(v) _G.Mawww_JerkTool = v end })

--========================================================--
-- COLORFUL STROKE
--========================================================--
local function PaintButtons(container)
    if not container then return end
    task.spawn(function()
        for _, d in ipairs(container:GetDescendants()) do
            if d:IsA("GuiButton") and not d:FindFirstChildOfClass("UIStroke") then
                local s = Instance.new("UIStroke")
                s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                s.Thickness = 1.3
                s.Color = NextColor()
                s.Parent = d
                local g = Instance.new("UIGradient")
                g.Color = ColorSequence.new(NextColor(), NextColor())
                g.Rotation = 45
                g.Parent = s
            end
        end
    end)
end

PaintButtons(Window.Gui)

--========================================================--
-- MANAGERS
--========================================================--
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MawwwHub")

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("MawwwHub")
SaveManager:BuildConfigSection(Tabs.Home)

print("====================================")
print(" MAWWWHUB • SIMPLE NOTIFICATION")
print(" Toggle : LeftControl")
print("====================================")
