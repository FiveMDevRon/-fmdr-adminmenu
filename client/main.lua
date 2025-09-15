ESX = exports["es_extended"]:getSharedObject()

local isMenuOpen = false
local isNoclipEnabled = false
local isInvisible = false
local isFrozen = false
local isSpectating = false
local spectateTarget = nil

-- Open menu key
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 167) then -- F6 key
            if HasAdminPermission() then
                ToggleMenu()
            end
        end
    end
end)

-- Check if player has admin permission
function HasAdminPermission()
    for group, level in pairs(Config.AdminGroups) do
        if IsPlayerAceAllowed(PlayerId(), 'group.' .. group) then
            return true
        end
    end
    return false
end

-- Toggle menu
function ToggleMenu()
    isMenuOpen = not isMenuOpen
    SetNuiFocus(isMenuOpen, isMenuOpen)
    SendNUIMessage({
        type = 'toggleMenu',
        show = isMenuOpen
    })
    
    if isMenuOpen then
        -- Refresh player list when opening
        RefreshPlayerList()
    end
end

-- Refresh player list
function RefreshPlayerList()
    ESX.TriggerServerCallback('fmdr-adminmenu:getPlayers', function(players)
        SendNUIMessage({
            type = 'updatePlayers',
            players = players
        })
    end)
    
    ESX.TriggerServerCallback('fmdr-adminmenu:getAdmins', function(admins)
        SendNUIMessage({
            type = 'updateAdmins',
            admins = admins
        })
    end)
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    ToggleMenu()
    cb('ok')
end)

RegisterNUICallback('toggleNoclip', function(data, cb)
    ToggleNoclip()
    cb('ok')
end)

RegisterNUICallback('toggleInvisible', function(data, cb)
    ToggleInvisible()
    cb('ok')
end)

RegisterNUICallback('healSelf', function(data, cb)
    HealSelf()
    cb('ok')
end)

RegisterNUICallback('reviveSelf', function(data, cb)
    TriggerEvent('esx_ambulancejob:revive')
    cb('ok')
end)

-- Player action callbacks
RegisterNUICallback('kickPlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:kickPlayer', data.playerId, data.reason)
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:banPlayer', data.playerId, data.duration, data.reason)
    cb('ok')
end)

RegisterNUICallback('bringPlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:bringPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('sendBackPlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:sendBackPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('gotoPlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:gotoPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    StartSpectating(data.playerId)
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:giveItem', data.playerId, data.item, data.amount)
    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:setJob', data.playerId, data.job, data.grade)
    cb('ok')
end)

RegisterNUICallback('healPlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:healPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('revivePlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:revivePlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('freezePlayer', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:freezePlayer', data.playerId)
    cb('ok')
end)

-- Server action callbacks
RegisterNUICallback('sendAnnouncement', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:sendAnnouncement', data.message)
    cb('ok')
end)

RegisterNUICallback('bringAllPlayers', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:bringAllPlayers')
    cb('ok')
end)

RegisterNUICallback('freezeAllPlayers', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:freezeAllPlayers')
    cb('ok')
end)

RegisterNUICallback('unfreezeAllPlayers', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:unfreezeAllPlayers')
    cb('ok')
end)

RegisterNUICallback('giveMoneyAll', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:giveMoneyAll', data.amount)
    cb('ok')
end)

RegisterNUICallback('giveItemAll', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:giveItemAll', data.item, data.amount)
    cb('ok')
end)

-- Admin Center callbacks
RegisterNUICallback('teleportToHQ', function(data, cb)
    SetEntityCoords(PlayerPedId(), Config.AdminHQ.x, Config.AdminHQ.y, Config.AdminHQ.z, false, false, false, true)
    cb('ok')
end)

RegisterNUICallback('setAdminHQ', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:setAdminHQ')
    cb('ok')
end)

RegisterNUICallback('startAdminMeeting', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:startAdminMeeting')
    cb('ok')
end)

RegisterNUICallback('endAdminMeeting', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:endAdminMeeting')
    cb('ok')
end)

RegisterNUICallback('summonAdmins', function(data, cb)
    TriggerServerEvent('fmdr-adminmenu:summonAdmins')
    cb('ok')
end)

-- Functions
function ToggleNoclip()
    isNoclipEnabled = not isNoclipEnabled
    local ped = PlayerPedId()
    
    if isNoclipEnabled then
        SetEntityInvincible(ped, true)
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
        FreezeEntityPosition(ped, true)
        SetPlayerInvincible(PlayerId(), true)
    else
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
        SetPlayerInvincible(PlayerId(), false)
    end
    
    SendNUIMessage({
        type = 'updateNoclip',
        enabled = isNoclipEnabled
    })
end

function ToggleInvisible()
    isInvisible = not isInvisible
    local ped = PlayerPedId()
    
    SetEntityVisible(ped, not isInvisible, false)
    
    SendNUIMessage({
        type = 'updateInvisible',
        enabled = isInvisible
    })
end

function HealSelf()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
end

function StartSpectating(playerId)
    if isSpectating then
        StopSpectating()
    end
    
    isSpectating = true
    spectateTarget = playerId
    
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    NetworkSetInSpectatorMode(true, targetPed)
    
    ESX.ShowNotification('Spectating player. Press ~INPUT_CONTEXT~ to stop.')
end

function StopSpectating()
    if not isSpectating then return end
    
    isSpectating = false
    spectateTarget = nil
    NetworkSetInSpectatorMode(false, PlayerPedId())
    
    ESX.ShowNotification('Stopped spectating.')
end

-- Spectate key handler
CreateThread(function()
    while true do
        Wait(0)
        if isSpectating and IsControlJustPressed(0, 38) then -- E key
            StopSpectating()
        end
    end
end)

-- Noclip movement
CreateThread(function()
    while true do
        Wait(0)
        if isNoclipEnabled then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            
            -- Movement controls
            if IsControlPressed(0, 32) then -- W
                coords = coords + GetEntityForwardVector(ped) * 2.0
            end
            if IsControlPressed(0, 33) then -- S
                coords = coords - GetEntityForwardVector(ped) * 2.0
            end
            if IsControlPressed(0, 34) then -- A
                coords = coords - GetEntityRightVector(ped) * 2.0
            end
            if IsControlPressed(0, 35) then -- D
                coords = coords + GetEntityRightVector(ped) * 2.0
            end
            if IsControlPressed(0, 44) then -- Q (down)
                coords = vector3(coords.x, coords.y, coords.z - 2.0)
            end
            if IsControlPressed(0, 38) then -- E (up)
                coords = vector3(coords.x, coords.y, coords.z + 2.0)
            end
            
            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)
        end
    end
end)

-- Client events
RegisterNetEvent('fmdr-adminmenu:teleportToCoords', function(x, y, z)
    SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, true)
end)

RegisterNetEvent('fmdr-adminmenu:heal', function()
    HealSelf()
end)

RegisterNetEvent('fmdr-adminmenu:freezePlayer', function()
    isFrozen = not isFrozen
    FreezeEntityPosition(PlayerPedId(), isFrozen)
end)

RegisterNetEvent('fmdr-adminmenu:unfreezePlayer', function()
    isFrozen = false
    FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNetEvent('fmdr-adminmenu:notify', function(message, type)
    SendNUIMessage({
        type = 'showNotification',
        message = message,
        notificationType = type or 'info'
    })
end)

RegisterNetEvent('fmdr-adminmenu:showNotification', function(message, type)
    SendNUIMessage({
        type = 'showNotification',
        message = message,
        notificationType = type or 'info'
    })
end)