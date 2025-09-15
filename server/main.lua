ESX = exports["es_extended"]:getSharedObject()

-- Store admin meeting status and player last positions
local adminMeetingActive = false
local playerLastPositions = {}
local spectatingPlayers = {}

-- Helper function to check admin permission
function HasPermission(source, minLevel)
    local adminLevel = 0
    
    for group, level in pairs(Config.AdminGroups) do
        if IsPlayerAceAllowed(source, 'group.' .. group) then
            if level > adminLevel then
                adminLevel = level
            end
        end
    end
    
    return adminLevel >= minLevel
end

-- Get all online players
ESX.RegisterServerCallback('fmdr-adminmenu:getPlayers', function(source, cb)
    if not HasPermission(source, 1) then
        cb({})
        return
    end
    
    local players = {}
    local xPlayers = ESX.GetExtendedPlayers()
    
    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        table.insert(players, {
            id = xPlayer.source,
            name = xPlayer.getName(),
            job = xPlayer.job.name,
            grade = xPlayer.job.grade,
            identifier = xPlayer.identifier
        })
    end
    
    cb(players)
end)

-- Get admin list
ESX.RegisterServerCallback('fmdr-adminmenu:getAdmins', function(source, cb)
    if not HasPermission(source, 2) then
        cb({})
        return
    end
    
    local admins = {}
    local allPlayers = GetPlayers()
    
    for i = 1, #allPlayers do
        local playerId = tonumber(allPlayers[i])
        local playerName = GetPlayerName(playerId)
        local adminLevel = 0
        local role = 'none'
        
        for group, level in pairs(Config.AdminGroups) do
            if IsPlayerAceAllowed(playerId, 'group.' .. group) then
                if level > adminLevel then
                    adminLevel = level
                    role = group
                end
            end
        end
        
        if adminLevel > 0 then
            table.insert(admins, {
                id = playerId,
                name = playerName,
                role = role,
                level = adminLevel
            })
        end
    end
    
    cb(admins)
end)

-- Kick player
RegisterNetEvent('fmdr-adminmenu:kickPlayer', function(playerId, reason)
    local source = source
    
    if not HasPermission(source, 2) then
        return
    end
    
    local playerName = GetPlayerName(playerId)
    local adminName = GetPlayerName(source)
    
    DropPlayer(playerId, 'Kicked by ' .. adminName .. ': ' .. reason)
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"[ADMIN]", playerName .. " was kicked by " .. adminName .. ": " .. reason}
    })
end)

-- Ban player
RegisterNetEvent('fmdr-adminmenu:banPlayer', function(playerId, duration, reason)
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    local playerName = GetPlayerName(playerId)
    local adminName = GetPlayerName(source)
    local identifier = xPlayer.identifier
    local banUntil = os.time() + (duration * 3600) -- Convert hours to seconds
    
    -- Insert ban into database
    MySQL.insert('INSERT INTO user_bans (identifier, reason, banned_by, banned_until) VALUES (?, ?, ?, ?)', {
        identifier,
        reason,
        adminName,
        banUntil
    })
    
    DropPlayer(playerId, 'Banned by ' .. adminName .. ' for ' .. duration .. ' hours: ' .. reason)
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"[ADMIN]", playerName .. " was banned by " .. adminName .. " for " .. duration .. " hours: " .. reason}
    })
end)

-- Bring player
RegisterNetEvent('fmdr-adminmenu:bringPlayer', function(playerId)
    local source = source
    
    if not HasPermission(source, 1) then
        return
    end
    
    local adminPed = GetPlayerPed(source)
    local adminCoords = GetEntityCoords(adminPed)
    
    -- Store player's last position
    local targetPed = GetPlayerPed(playerId)
    playerLastPositions[playerId] = GetEntityCoords(targetPed)
    
    TriggerClientEvent('fmdr-adminmenu:teleportToCoords', playerId, adminCoords.x, adminCoords.y, adminCoords.z)
end)

-- Send back player
RegisterNetEvent('fmdr-adminmenu:sendBackPlayer', function(playerId)
    local source = source
    
    if not HasPermission(source, 1) then
        return
    end
    
    if playerLastPositions[playerId] then
        local coords = playerLastPositions[playerId]
        TriggerClientEvent('fmdr-adminmenu:teleportToCoords', playerId, coords.x, coords.y, coords.z)
        playerLastPositions[playerId] = nil
    end
end)

-- Goto player
RegisterNetEvent('fmdr-adminmenu:gotoPlayer', function(playerId)
    local source = source
    
    if not HasPermission(source, 1) then
        return
    end
    
    local targetPed = GetPlayerPed(playerId)
    local targetCoords = GetEntityCoords(targetPed)
    
    TriggerClientEvent('fmdr-adminmenu:teleportToCoords', source, targetCoords.x, targetCoords.y, targetCoords.z)
end)

-- Give item
RegisterNetEvent('fmdr-adminmenu:giveItem', function(playerId, item, amount)
    local source = source
    
    if not HasPermission(source, 1) then
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        xPlayer.addInventoryItem(item, amount)
        TriggerClientEvent('fmdr-adminmenu:notify', source, 'Given ' .. amount .. 'x ' .. item .. ' to ' .. xPlayer.getName(), 'success')
    end
end)

-- Set job
RegisterNetEvent('fmdr-adminmenu:setJob', function(playerId, job, grade)
    local source = source
    
    if not HasPermission(source, 2) then
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        xPlayer.setJob(job, grade)
        TriggerClientEvent('fmdr-adminmenu:notify', source, 'Set ' .. xPlayer.getName() .. ' job to ' .. job .. ' (' .. grade .. ')', 'success')
    end
end)

-- Heal player
RegisterNetEvent('fmdr-adminmenu:healPlayer', function(playerId)
    local source = source
    
    if not HasPermission(source, 1) then
        return
    end
    
    TriggerClientEvent('fmdr-adminmenu:heal', playerId)
end)

-- Revive player
RegisterNetEvent('fmdr-adminmenu:revivePlayer', function(playerId)
    local source = source
    
    if not HasPermission(source, 1) then
        return
    end
    
    TriggerClientEvent('esx_ambulancejob:revive', playerId)
end)

-- Freeze player
RegisterNetEvent('fmdr-adminmenu:freezePlayer', function(playerId)
    local source = source
    
    if not HasPermission(source, 1) then
        return
    end
    
    TriggerClientEvent('fmdr-adminmenu:freezePlayer', playerId)
end)

-- Server actions
RegisterNetEvent('fmdr-adminmenu:sendAnnouncement', function(message)
    local source = source
    
    if not HasPermission(source, 2) then
        return
    end
    
    local adminName = GetPlayerName(source)
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 165, 0},
        multiline = true,
        args = {"[ANNOUNCEMENT]", message}
    })
    
    TriggerClientEvent('fmdr-adminmenu:showNotification', -1, message, 'info')
end)

-- Bring all players
RegisterNetEvent('fmdr-adminmenu:bringAllPlayers', function()
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    local adminPed = GetPlayerPed(source)
    local adminCoords = GetEntityCoords(adminPed)
    local allPlayers = GetPlayers()
    
    for i = 1, #allPlayers do
        local playerId = tonumber(allPlayers[i])
        if playerId ~= source then
            TriggerClientEvent('fmdr-adminmenu:teleportToCoords', playerId, adminCoords.x, adminCoords.y, adminCoords.z)
        end
    end
end)

-- Freeze all players
RegisterNetEvent('fmdr-adminmenu:freezeAllPlayers', function()
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    TriggerClientEvent('fmdr-adminmenu:freezePlayer', -1)
end)

-- Unfreeze all players  
RegisterNetEvent('fmdr-adminmenu:unfreezeAllPlayers', function()
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    TriggerClientEvent('fmdr-adminmenu:unfreezePlayer', -1)
end)

-- Give money to all
RegisterNetEvent('fmdr-adminmenu:giveMoneyAll', function(amount)
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    local xPlayers = ESX.GetExtendedPlayers()
    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        xPlayer.addMoney(amount)
    end
end)

-- Give item to all
RegisterNetEvent('fmdr-adminmenu:giveItemAll', function(item, amount)
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    local xPlayers = ESX.GetExtendedPlayers()
    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        xPlayer.addInventoryItem(item, amount)
    end
end)

-- Admin Center functions
RegisterNetEvent('fmdr-adminmenu:startAdminMeeting', function()
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    adminMeetingActive = true
    TriggerClientEvent('fmdr-adminmenu:showNotification', -1, 'Admin meeting started', 'info')
end)

RegisterNetEvent('fmdr-adminmenu:endAdminMeeting', function()
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    adminMeetingActive = false
    TriggerClientEvent('fmdr-adminmenu:showNotification', -1, 'Admin meeting ended', 'info')
end)

RegisterNetEvent('fmdr-adminmenu:summonAdmins', function()
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    local adminPed = GetPlayerPed(source)
    local adminCoords = GetEntityCoords(adminPed)
    local allPlayers = GetPlayers()
    
    for i = 1, #allPlayers do
        local playerId = tonumber(allPlayers[i])
        if playerId ~= source and HasPermission(playerId, 1) then
            TriggerClientEvent('fmdr-adminmenu:teleportToCoords', playerId, adminCoords.x, adminCoords.y, adminCoords.z)
        end
    end
end)

-- Set Admin HQ
RegisterNetEvent('fmdr-adminmenu:setAdminHQ', function()
    local source = source
    
    if not HasPermission(source, 3) then
        return
    end
    
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    
    Config.AdminHQ.x = coords.x
    Config.AdminHQ.y = coords.y
    Config.AdminHQ.z = coords.z
    
    -- Save to file or database if needed
    TriggerClientEvent('fmdr-adminmenu:notify', source, 'Admin HQ location updated', 'success')
end)

-- Check for bans on player connecting
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local source = source
    local identifier = nil
    
    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            identifier = v
            break
        end
    end
    
    if identifier then
        MySQL.scalar('SELECT banned_until FROM user_bans WHERE identifier = ? AND banned_until > ?', {
            identifier,
            os.time()
        }, function(bannedUntil)
            if bannedUntil then
                local timeLeft = bannedUntil - os.time()
                local hoursLeft = math.ceil(timeLeft / 3600)
                setKickReason('You are banned for ' .. hoursLeft .. ' more hours.')
            end
        end)
    end
end)