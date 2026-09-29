--========================================================--
-- MAWWWHUB KEY SYSTEM (Railway API) — BUG FIXED
--========================================================--
local KeySystem = {}

--========================================================--
-- URL RAILWAY
--========================================================--
local BASE_URL = "https://mawww-key-server-production.up.railway.app"
KeySystem.BASE_URL = BASE_URL

--========================================================--
-- SAVED KEY HELPERS
--========================================================--
function KeySystem:HasSavedKey()
    local ok, result = pcall(function()
        if isfile and isfile("MawwwHub/key.txt") then
            local k = readfile("MawwwHub/key.txt")
            if k and k ~= "" then return true, k end
        end
        return false, nil
    end)
    if ok then return result end
    return false, nil
end

--========================================================--
-- HWID
--========================================================--
function KeySystem:GetHWID()
    local ok, hwid = pcall(function()
        if gethwid then return gethwid() end
        if syn and syn.get_hwid then return syn.get_hwid() end
        if getgenv and getgenv().get_hwid then return getgenv().get_hwid() end
        return nil
    end)
    if ok and hwid and hwid ~= "" then return hwid end

    local platform = "P"
    pcall(function()
        platform = game:GetService("UserInputService").TouchEnabled and "M" or "P"
    end)
    return tostring(game.Players.LocalPlayer.UserId) .. "-" .. platform
end

--========================================================--
-- VALIDATE KEY
--========================================================--
function KeySystem:ValidateKey(userKey)
    if not userKey or userKey == "" then
        return false, "Key kosong!"
    end

    userKey = tostring(userKey):gsub("%s+", "")

    local hwid = self:GetHWID()
    local httpService = game:GetService("HttpService")

    local url = string.format(
        "%s/api/validate?key=%s&hwid=%s",
        BASE_URL,
        httpService:UrlEncode(userKey),
        httpService:UrlEncode(hwid)
    )

    local ok, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not response then
        return false, "Server offline, coba lagi."
    end

    local decodeOk, data = pcall(function()
        return httpService:JSONDecode(response)
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

function KeySystem:GetKeyInfo(userKey)
    return self:ValidateKey(userKey)
end

function KeySystem:GetBuyLink()
    return BASE_URL
end

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
