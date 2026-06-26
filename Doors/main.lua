local settingss = _G.notaHubSettings

if settingss.Library == '' then
    return error('nota: need a valid lib')
end

-- Varibles
local WS: Workspace = cloneref(game:GetService('Workspace'))
local TweenService: TweenService = cloneref(game:GetService('TweenService'))
local Players: Players = cloneref(game:GetService('Players'))
local LP: Player = Players.LocalPlayer
local RunService: RunService = cloneref(game:GetService('RunService'))

local function BuildLinoriaVer()
    local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
    local scriptrepo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

    local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

    local Options = Library.Options
    local Toggles = Library.Toggles
    local functions = {}

    local FolderDirectory = 'notaHub'
    local DoorsDirectory = FolderDirectory .. '/Doors'
    local Addons = FolderDirectory .. '/Doors/Addons'
    local Lua = FolderDirectory .. '/Doors/Lua'

    Library.ShowToggleFrameInKeybinds = true
    Library.ShowCustomCursor = true
    Library.NotifySide = settingss.NotificationSide or 'Left'

    local Window = Library:CreateWindow({
        Title = "notaHub v1",
        Center = true,
        AutoShow = true,
        Resizable = true,
        ShowCustomCursor = true,
        UnlockMouseWhileOpen = true,
        NotifySide = settingss.NotificationSide or 'Left',
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    local Tabs = {
        Player = Window:AddTab("Player"),
        Bypass = Window:AddTab("Bypass"),
        Visuals = Window:AddTab("Visuals"),
        Floor = Window:AddTab("Floor"),
        Misc = Window:AddTab("Misc"),
        Addons = Window:AddTab("Addons"),
        ["UI Settings"] = Window:AddTab("UI Settings"),
    }

    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    -- Addons Tab
    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    local currentGame = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:lower()

    local function BuildAddonUI(addonScript, side)
        local addonProxy = {}
        local addonEnv = {
        notaHub = addonProxy,
    }
    addonEnv.__index = addonEnv
    setmetatable(addonEnv, { __index = addonEnv })

    local func, err = loadstring(addonScript)
    if not func then
        warn('[notaHub Addons] Failed to parse addon:', err)
        return
    end

    setfenv(func, addonEnv)

    local ok, result = pcall(func)
    if not ok then
        warn('[notaHub Addons] Failed to run addon:', result)
        return
    end

    local info = addonProxy.Info
    if not info then
        warn('[notaHub Addons] Addon missing Info, skipping.')
        return
    end

    -- check if addon supports current game
    local supported = false
    if info.Game then
        for _, g in ipairs(info.Game) do
            if currentGame:find(g:lower()) then
                supported = true
                break
            end
        end
    else
        supported = true
    end

    if not supported then return end

    -- build the groupbox
    local groupbox
    if side == 'right' then
        groupbox = Tabs.Addons:AddRightGroupbox(info.Title or info.Name or 'Addon')
    else
        groupbox = Tabs.Addons:AddLeftGroupbox(info.Title or info.Name or 'Addon')
    end

    if info.Description then
        groupbox:AddLabel(info.Description)
        groupbox:AddDivider()
    end

    -- give addon only what it needs
    addonProxy.Groupbox = groupbox
    addonProxy.Options = Options
    addonProxy.Toggles = Toggles
    addonProxy.Library = Library

    -- re-run now groupbox is ready
    local func2, err2 = loadstring(addonScript)
    if not func2 then return end
    setfenv(func2, addonEnv)
    pcall(func2)
end

    local function LoadAddons()
        if not isfolder(Addons) then
            warn('[notaHub Addons] Addons folder not found:', Addons)
            return
        end

        local files = listfiles(Addons)
        if #files == 0 then
            Tabs.Addons:AddLeftGroupbox('Addons'):AddLabel('Your addons folder is empty!!! please go to notaHub/Doors/Addons to put addons in! go to our discord for public addons!')
            return
        end

        local side = 'left'
        for i, filePath in ipairs(files) do
            -- only load .lua files
            if filePath:sub(-4) == '.lua' then
                local ok, content = pcall(readfile, filePath)
                if ok and content then
                    BuildAddonUI(content, side)
                    -- alternate left/right so they stack nicely
                    side = side == 'left' and 'right' or 'left'
                else
                    warn('[notaHub Addons] Could not read file:', filePath)
                end
            end
        end
    end

    LoadAddons()

    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    -- Lua Tab (runs .lua files from Lua folder)
    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    local lua_BuildVersion = 'Lua 5.1'

    local function LoadLuaFiles()
        if not isfolder(Lua) then
            warn('[notaHub Lua] Lua folder not found:', Lua)
            return
        end

        local files = listfiles(Lua)
        local LuaGroup = Tabs.Misc:AddLeftGroupbox('Lua')

        if #files == 0 then
            LuaGroup:AddLabel('No Lua scripts found.')
            return
        end

        for _, filePath in ipairs(files) do
            if filePath:sub(-4) == '.lua' then
                local fileName = filePath:match("([^/\\]+)%.lua$") or filePath

                LuaGroup:AddButton(fileName, function()
                    local ok, content = pcall(readfile, filePath)
                    if not ok or not content then
                        Library:Notify('Failed to read: ' .. fileName, 3)
                        return
                    end

                    local func, err = loadstring(content)
                    if not func then
                        Library:Notify('Parse error: ' .. fileName, 3)
                        warn('[notaHub Lua] Parse error in', fileName, err)
                        return
                    end

                    local success, result = pcall(func)
                    if not success then
                        Library:Notify('Error: ' .. fileName, 3)
                        warn('[notaHub Lua] Runtime error in', fileName, result)
                    else
                        Library:Notify('Loaded: ' .. fileName, 3)
                    end
                end)
            end
        end
    end

    LoadLuaFiles()

    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    -- UI Settings Tab
    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
    MenuGroup:AddToggle("KeybindMenuOpen", {
        Default = Library.KeybindFrame.Visible,
        Text = "Open Keybind Menu",
        Callback = function(value) Library.KeybindFrame.Visible = value end
    })
    MenuGroup:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor",
        Default = true,
        Callback = function(Value) Library.ShowCustomCursor = Value end
    })
    MenuGroup:AddDivider()
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind"
    })
    MenuGroup:AddButton("Unload", function() Library:Unload() end)
    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("notaHub")
    SaveManager:SetFolder("notaHub/Doors")
    SaveManager:SetSubFolder("specific-place")
    SaveManager:BuildConfigSection(Tabs["UI Settings"])
    ThemeManager:ApplyToTab(Tabs["UI Settings"])
    SaveManager:LoadAutoloadConfig()
end

local function BuildObsidianVer()
    local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/' -- obsidian lib

    local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
end

if settingss.Library == 'Linoria' then
    BuildLinoriaVer()
elseif settingss.Library == 'Obsidian' then
    BuildObsidianVer()
else 
    return error('couldnt find library in settings set by user! please check ur library settings!')
end
