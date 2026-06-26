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
        Doors = {locked = false, id = 2440500124 },
        Rivals = {locked = true, id = 6035872082 },
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

local function loadCurrentGame()
    local placeId = game.GameId

    if placeId == notaHub.Supported_Games.Doors.id then
        if notaHub.Supported_Games.Doors.locked then
            game:GetService("Players").LocalPlayer:Kick("Script locked for game. please check the available games list on our discord!")
            return
        end

        loadstring(game:HttpGet("https://raw.githubusercontent.com/00uxnx/550e8400-e29b-41d4-a716-446655440000/refs/heads/main/Doors/main.lua?token=GHSAT0AAAAAAD6LXKI7UAWOJCAG744YPNRO2R6YPHA"))()

    elseif placeId == notaHub.Supported_Games.Rivals.id then
        if notaHub.Supported_Games.Rivals.locked then
            game:GetService("Players").LocalPlayer:Kick("Script locked for game. please check the available games list on our discord!")
            return
        end

        loadstring(game:HttpGet("https://raw.githubusercontent.com/00uxnx/550e8400-e29b-41d4-a716-446655440000/refs/heads/main/Rivals/Main.lua?token=GHSAT0AAAAAAD6LXKI6FFDDC4NCZLHRNYE22R6YPWQ"))()
    else
        game:GetService("Players").LocalPlayer:Kick("Game not supported!, please check the available games list on our discord!")
    end
end

Setup_notaHubsFolders()
loadCurrentGame()
