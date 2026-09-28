--========================================================--
-- MAWWWHUB KEY SYSTEM (Railway API)
--========================================================--
local KeySystem = {}

--========================================================--
-- URL RAILWAY KAMU
--========================================================--
local BASE_URL = "https://mawww-key-server-production.up.railway.app"

--========================================================--
-- GENERATE HWID
--========================================================--
function KeySystem:GetHWID()
    local ok, hwid = pcall(function()
        if gethwid then return gethwid() end
        if syn and syn.get_hwid then return syn.get_hwid() end
        if getgenv and getgenv().get_hwid then return getgenv().get_hwid() end
        return nil
    end)
    if ok and hwid and hwid ~= "" then return hwid end

    local Platform = game:GetService("UserInputService").TouchEnabled and "M" or "P"
    return tostring(game.Players.LocalPlayer.UserId) .. "-" .. Platform
end

--========================================================--
-- VALIDATE KEY
--========================================================--
function KeySystem:ValidateKey(userKey)
    if not userKey or userKey == "" then
        return false, "Key kosong!"
    end
    userKey = tostring(userKey):gsub("%s+", "")

    local hwid = KeySystem:GetHWID()
    local HttpService = game:GetService("HttpService")

    local url = string.format(
        "%s/api/validate?key=%s&hwid=%s",
        BASE_URL,
        HttpService:UrlEncode(userKey),
        HttpService:UrlEncode(hwid)
    )

    local ok, response = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not response then
        return false, "Server offline, coba lagi."
    end

    local decodeOk, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if not decodeOk or type(data) ~= "table" then
        return false, "Response tidak valid."
    end

    if data.ok then
        return true, "✅ " .. (data.msg or "Authenticated!"), data
    else
        return false, "❌ " .. (data.msg or "Key tidak valid.")
    end
end

--========================================================--
-- GET BUY LINK
--========================================================--
function KeySystem:GetBuyLink()
    return BASE_URL
end

--========================================================--
-- GET INFO (untuk debug)
--========================================================--
function KeySystem:GetInfo()
    local ok, response = pcall(function()
        return game:HttpGet(BASE_URL .. "/api/info")
    end)
    if not ok then return nil end
    local decodeOk, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response)
    end)
    if not decodeOk then return nil end
    return data
end

return KeySystem
