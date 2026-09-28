--========================================================--
-- MAWWWHUB THEME MANAGER
--========================================================--
local ThemeManager = {}
ThemeManager.__index = ThemeManager

local Themes = {
    Default = {
        AccentColor     = Color3.fromRGB(180, 110, 255),
        BackgroundColor = Color3.fromRGB(12, 8, 18),
        MainColor       = Color3.fromRGB(28, 22, 38),
        OutlineColor    = Color3.fromRGB(180, 110, 255),
        FontColor       = Color3.fromRGB(240, 240, 245),
    },
    Pink = {
        AccentColor     = Color3.fromRGB(255, 105, 180),
        BackgroundColor = Color3.fromRGB(20, 8, 15),
        MainColor       = Color3.fromRGB(40, 18, 30),
        OutlineColor    = Color3.fromRGB(255, 105, 180),
        FontColor       = Color3.fromRGB(255, 240, 245),
    },
    Cyan = {
        AccentColor     = Color3.fromRGB(80, 210, 255),
        BackgroundColor = Color3.fromRGB(8, 15, 20),
        MainColor       = Color3.fromRGB(18, 30, 40),
        OutlineColor    = Color3.fromRGB(80, 210, 255),
        FontColor       = Color3.fromRGB(230, 245, 255),
    },
    Dark = {
        AccentColor     = Color3.fromRGB(80, 80, 90),
        BackgroundColor = Color3.fromRGB(10, 10, 12),
        MainColor       = Color3.fromRGB(22, 22, 26),
        OutlineColor    = Color3.fromRGB(80, 80, 90),
        FontColor       = Color3.fromRGB(230, 230, 235),
    },
}

local Library = nil

function ThemeManager:SetLibrary(lib) Library = lib; return self end
function ThemeManager:SetFolder(name) self._folder = name; return self end
function ThemeManager:GetThemes() return Themes end

function ThemeManager:SetTheme(name)
    if Themes[name] and Library then
        for k, v in pairs(Themes[name]) do
            Library.Scheme[k] = v
        end
        if Library.Notify then
            Library:Notify({ Title = "Theme", Content = "Applied: " .. name, Duration = 3 })
        end
    end
    return self
end

return ThemeManager
