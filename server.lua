local QBCore = exports['qb-core']:GetCoreObject()

local carrying = {}
local carried = {}

RegisterServerEvent('ml187-kidnap:server:registerZiptieItem')
AddEventHandler('ml187-kidnap:server:registerZiptieItem', function()
    QBCore.Functions.CreateUseableItem(Config.ZiptieItem, function(source, item)
        local src = source
        TriggerClientEvent("ml187-kidnap:client:useZiptie", src)
    end)
end)

QBCore.Functions.CreateCallback('ml187-kidnap:server:getZiptieItem', function(source, cb)
    local item = QBCore.Shared.Items[Config.ZiptieItem]
    if item then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('ml187-kidnap:server:removeZiptie')
AddEventHandler('ml187-kidnap:server:removeZiptie', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.RemoveItem(Config.ZiptieItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ZiptieItem], "remove")
    end
end)

RegisterServerEvent('ml187-kidnap:server:zipTiePlayer')
AddEventHandler('ml187-kidnap:server:zipTiePlayer', function(targetId)
    local src = source
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if targetPlayer then
        TriggerClientEvent('ml187-kidnap:client:getZiptied', targetId)
    end
end)

RegisterServerEvent("ml187-kidnap:sync")
AddEventHandler("ml187-kidnap:sync", function(targetSrc)
    local source = source
    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    
    if #(sourceCoords - targetCoords) <= 3.0 then 
        TriggerClientEvent("ml187-kidnap:syncTarget", targetSrc, source)
        carrying[source] = targetSrc
        carried[targetSrc] = source
    end
end)

RegisterServerEvent("ml187-kidnap:stop")
AddEventHandler("ml187-kidnap:stop", function(targetSrc)
    local source = source

    if carrying[source] then
        TriggerClientEvent("ml187-kidnap:cl_stop", targetSrc)
        carrying[source] = nil
        carried[targetSrc] = nil
    elseif carried[source] then
        TriggerClientEvent("ml187-kidnap:cl_stop", carried[source])            
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)

RegisterServerEvent('ml187-kidnap:server:putInTrunk')
AddEventHandler('ml187-kidnap:server:putInTrunk', function(targetId, vehNetId)
    local src = source
    
    TriggerClientEvent('ml187-kidnap:client:putInTrunk', targetId, vehNetId)
    if carrying[src] then
        TriggerClientEvent("ml187-kidnap:cl_stop", carrying[src])
        carrying[src] = nil
        carried[targetId] = nil
    end
end)

RegisterServerEvent('ml187-kidnap:server:getOutTrunk')
AddEventHandler('ml187-kidnap:server:getOutTrunk', function(targetId, vehNetId)
    TriggerClientEvent('ml187-kidnap:client:getOutTrunk', targetId, vehNetId)
end)

QBCore.Functions.CreateCallback('ml187-kidnap:server:hasKnife', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player then
        if Player.Functions.GetItemByName(Config.KnifeItem) then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

RegisterServerEvent('ml187-kidnap:server:cutZiptie')
AddEventHandler('ml187-kidnap:server:cutZiptie', function(targetId)
    local src = source
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if targetPlayer then
        TriggerClientEvent('ml187-kidnap:client:cutZiptie', targetId)
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    
    if carrying[source] then
        TriggerClientEvent("ml187-kidnap:cl_stop", carrying[source])
        carried[carrying[source]] = nil
        carrying[source] = nil
    end

    if carried[source] then
        TriggerClientEvent("ml187-kidnap:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)
