local editablestuff = {
    Notification_Style = 'Linoria',
    AddonsEnable = true,
    Library = 'Linoria',
    NotificationSide = 'Left'
}

_G.notaHubSettings = editablestuff

local repo = ''

local notaHub = {
    Directory = 'notaHub',
    stuff = {
        'notaHub/Doors',
        'notaHub/Rivals',
        'notaHub/Settings'
    },

    Supported_Games = {
        Doors = {locked = false, ids = {6516141723, 6516141723} },
        Rivals = {locked = true, ids = {00, 00} },
    },

    Folders = {
        -- notaHub root
        ['notaHub/Doors'] = {
            'notaHub/Doors/CommunityConf',
            'notaHub/Doors/Addons',
            'notaHub/Doors/Lua',
        },
        ['notaHub/Rivals'] = {
            'notaHub/Rivals/Settings',
            'notaHub/Rivals/Configs',
            'notaHub/Rivals/Lua',
        },
        ['notaHub/Settings'] = {},
    }
}

local function Setup_notaHubsFolders()
    -- create root folder
    if not isfolder(notaHub.Directory) then
        makefolder(notaHub.Directory)
    end

    -- create game folders + subfolders
    for parent, subfolders in pairs(notaHub.Folders) do
        if not isfolder(parent) then
            makefolder(parent)
        end

        for _, subfolder in ipairs(subfolders) do
            if not isfolder(subfolder) then
                makefolder(subfolder)
            end
        end
    end
end

local function hasId(list, id)
    return table.find(list, id) ~= nil
end

local function loadCurrentGame()
    local placeId = game.PlaceId

    if hasId(notaHub.Supported_Games.Doors.ids, placeId) then
        if notaHub.Supported_Games.Doors.locked then
            game:GetService("Players").LocalPlayer:Kick("Script locked for game. please check the available games list on our discord!")
            return
        end

        loadstring(game:HttpGet("https://raw.githubusercontent.com/00uxnx/550e8400-e29b-41d4-a716-446655440000/refs/heads/main/Doors/main.lua"))()

    elseif hasId(notaHub.Supported_Games.Rivals.ids, placeId) then
        if notaHub.Supported_Games.Rivals.locked then
            game:GetService("Players").LocalPlayer:Kick("Script locked for game. please check the available games list on our discord!")
            return
        end

        loadstring(game:HttpGet("https://raw.githubusercontent.com/00uxnx/550e8400-e29b-41d4-a716-446655440000/refs/heads/main/Rivals/Main.lua"))()
    else
        game:GetService("Players").LocalPlayer:Kick("Game not supported!, please check the available games list on our discord!")
    end
end

Setup_notaHubsFolders()
loadCurrentGame()
