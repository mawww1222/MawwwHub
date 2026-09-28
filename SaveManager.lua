--========================================================--
-- MAWWWHUB SAVE MANAGER
--========================================================--
local SaveManager = {}
SaveManager.__index = SaveManager

local HttpService = game:GetService("HttpService")

local Library = nil
local Config = {}

function SaveManager:SetLibrary(lib)
    Library = lib
    return self
end

function SaveManager:SetFolder(name)
    self._folder = name
    if not isfolder then return self end
    if not isfolder(name) then makefolder(name) end
    if not isfolder(name .. "/configs") then makefolder(name .. "/configs") end
    return self
end

function SaveManager:IgnoreThemeSettings() return self end
function SaveManager:SetIgnoreIndexes() return self end

function SaveManager:Save(name)
    name = name or "default"
    if not Library then return end
    local data = {}
    for k, v in pairs(Library._configFlags or {}) do
        if typeof(v) == "Color3" then
            data[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
        elseif typeof(v) == "table" then
            data[k] = { __type = "table", value = v }
        else
            data[k] = v
        end
    end
    local path = (self._folder or "MawwwHub/configs") .. "/" .. name .. ".json"
    if writefile then
        writefile(path, HttpService:JSONEncode(data))
        if Library.Notify then
            Library:Notify({ Title = "Saved", Content = "Config: " .. name, Duration = 3 })
        end
    end
    return data
end

function SaveManager:Load(name)
    name = name or "default"
    local path = (self._folder or "MawwwHub/configs") .. "/" .. name .. ".json"
    if not isfile or not isfile(path) then
        if Library and Library.Notify then
            Library:Notify({ Title = "Error", Content = "Config tidak ditemukan!", Duration = 3 })
        end
        return
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok then return end
    for k, v in pairs(decoded) do
        if type(v) == "table" and v.__type == "Color3" then
            Library._configFlags[k] = Color3.new(v.r, v.g, v.b)
        elseif type(v) == "table" and v.__type == "table" then
            Library._configFlags[k] = v.value
        else
            Library._configFlags[k] = v
        end
    end
    if Library and Library.Notify then
        Library:Notify({ Title = "Loaded", Content = "Config: " .. name, Duration = 3 })
    end
end

function SaveManager:BuildConfigSection(tab)
    if not tab or not tab.AddLeftGroupbox then return end
    local box = tab:AddLeftGroupbox("Config Manager", "save")
    box:AddInput("SaveConfigName", {
        Text = "Config Name",
        Default = "default",
        Placeholder = "default",
    })
    box:AddButton("💾 Save Config", function()
        local name = (Library._configFlags.SaveConfigName or "default")
        SaveManager:Save(name)
    end)
    box:AddButton("📂 Load Config", function()
        local name = (Library._configFlags.SaveConfigName or "default")
        SaveManager:Load(name)
    end)
    box:AddButton("🗑️ Delete Config", function()
        local name = (Library._configFlags.SaveConfigName or "default")
        local path = (SaveManager._folder or "MawwwHub/configs") .. "/" .. name .. ".json"
        if delfile and isfile(path) then
            delfile(path)
            if Library.Notify then
                Library:Notify({ Title = "Deleted", Content = "Config: " .. name, Duration = 3 })
            end
        end
    end)
end

return SaveManager
