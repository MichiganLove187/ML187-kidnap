local QBCore = exports['qb-core']:GetCoreObject()
local isCarrying = false
local isBeingCarried = false
local isZiptied = false
local targetPlayer = nil

local carryData = {
    InProgress = false,
    targetSrc = -1,
    type = "",
    personCarrying = {
        animDict = "missfinale_c2mcs_1",
        anim = "fin_c2_mcs_1_camman",
        flag = 49,
    },
    personCarried = {
        animDict = "nm",
        anim = "firemans_carry",
        attachX = 0.27,
        attachY = 0.15,
        attachZ = 0.63,
        flag = 33,
    }
}


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('ml187-kidnap:server:getZiptieItem', function(hasItem)
        if not hasItem then
            TriggerServerEvent('ml187-kidnap:server:registerZiptieItem')
        end
    end)
end)


local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end


RegisterNetEvent('ml187-kidnap:client:useZiptie')
AddEventHandler('ml187-kidnap:client:useZiptie', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.0 then
        local playerId = GetPlayerServerId(player)
        QBCore.Functions.Progressbar("using_ziptie", "Zip-tying hands...", Config.ZiptieTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mp_arresting",
            anim = "a_uncuff",
            flags = 49,
        }, {}, {}, function() 
            TriggerServerEvent("ml187-kidnap:server:zipTiePlayer", playerId)
            TriggerServerEvent('ml187-kidnap:server:removeZiptie')
        end, function() 
            QBCore.Functions.Notify(Config.Notifications.cancelled, "error")
        end)
    else
        QBCore.Functions.Notify(Config.Notifications.noPlayerNearby, "error")
    end
end)


RegisterNetEvent('ml187-kidnap:client:getZiptied')
AddEventHandler('ml187-kidnap:client:getZiptied', function()
    isZiptied = true
    local ped = PlayerPedId()
    
    RequestAnimDict("mp_arresting")
    while not HasAnimDictLoaded("mp_arresting") do
        Wait(100)
    end
    
    TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
    SetEnableHandcuffs(ped, true)
    DisablePlayerFiring(ped, true)
    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
    

    CreateThread(function()
        while isZiptied do
            Wait(1000)
            if not IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3) and not isBeingCarried then
                TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
            end
        end
    end)
    
    QBCore.Functions.Notify(Config.Notifications.ziptied, "error")
end)


RegisterCommand(Config.Commands.carry, function()
    if not isZiptied and not carryData.InProgress then
        
        local player, distance = QBCore.Functions.GetClosestPlayer()
        if player ~= -1 and distance < 2.0 then
            local targetSrc = GetPlayerServerId(player)
            if targetSrc ~= -1 then
                carryData.InProgress = true
                carryData.targetSrc = targetSrc
                TriggerServerEvent("ml187-kidnap:sync", targetSrc)
                ensureAnimDict(carryData.personCarrying.animDict)
                carryData.type = "carrying"
            else
                QBCore.Functions.Notify(Config.Notifications.noPlayerNearby, "error")
            end
        else
            QBCore.Functions.Notify(Config.Notifications.noPlayerNearby, "error")
        end
    else
        carryData.InProgress = false
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("ml187-kidnap:stop", carryData.targetSrc)
        carryData.targetSrc = 0
    end
end, false)

RegisterNetEvent("ml187-kidnap:syncTarget")
AddEventHandler("ml187-kidnap:syncTarget", function(targetSrc)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
    carryData.InProgress = true
    isBeingCarried = true
    ensureAnimDict(carryData.personCarried.animDict)
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, carryData.personCarried.attachX, carryData.personCarried.attachY, carryData.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
    carryData.type = "beingcarried"
end)

RegisterNetEvent("ml187-kidnap:cl_stop")
AddEventHandler("ml187-kidnap:cl_stop", function()
    carryData.InProgress = false
    isBeingCarried = false
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
    
    if isZiptied then
        RequestAnimDict("mp_arresting")
        while not HasAnimDictLoaded("mp_arresting") do
            Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if carryData.InProgress then
            if carryData.type == "beingcarried" then
                if not IsEntityPlayingAnim(PlayerPedId(), carryData.personCarried.animDict, carryData.personCarried.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carryData.personCarried.animDict, carryData.personCarried.anim, 8.0, -8.0, 100000, carryData.personCarried.flag, 0, false, false, false)
                end
            elseif carryData.type == "carrying" then
                if not IsEntityPlayingAnim(PlayerPedId(), carryData.personCarrying.animDict, carryData.personCarrying.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carryData.personCarrying.animDict, carryData.personCarrying.anim, 8.0, -8.0, 100000, carryData.personCarrying.flag, 0, false, false, false)
                end
            end
        end
        Wait(0)
    end
end)

function PutPlayerInTrunk()
    if carryData.InProgress and carryData.type == "carrying" then
        local vehicle = QBCore.Functions.GetClosestVehicle()
        if vehicle ~= 0 and vehicle ~= nil then
            local trunkCoords = GetEntityCoords(vehicle)
            local distanceToTrunk = #(GetEntityCoords(PlayerPedId()) - trunkCoords) 
            
            if distanceToTrunk < 5.0 then
                if GetVehicleDoorLockStatus(vehicle) ~= 2 then
                    TriggerServerEvent("ml187-kidnap:server:putInTrunk", carryData.targetSrc, NetworkGetNetworkIdFromEntity(vehicle))
                    carryData.InProgress = false
                    ClearPedSecondaryTask(PlayerPedId())
                    TriggerServerEvent("ml187-kidnap:stop", carryData.targetSrc)
                    carryData.targetSrc = 0
                else
                    QBCore.Functions.Notify(Config.Notifications.vehicleLocked, "error")
                end
            else
                QBCore.Functions.Notify(Config.Notifications.notCloseToVehicle, "error")
            end
        else
            QBCore.Functions.Notify(Config.Notifications.noVehicleNearby, "error")
        end
    else
        QBCore.Functions.Notify(Config.Notifications.notCarryingAnyone, "error")
    end
end

RegisterCommand(Config.Commands.putInTrunk, function()
    PutPlayerInTrunk()
end, false)

RegisterNetEvent('ml187-kidnap:client:putInTrunk')
AddEventHandler('ml187-kidnap:client:putInTrunk', function(vehNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
    
    if DoesEntityExist(vehicle) then
        carryData.InProgress = false
        isBeingCarried = false
        DetachEntity(PlayerPedId(), true, false)
        ClearPedTasks(PlayerPedId())
        
        SetEntityVisible(PlayerPedId(), false, false)
        SetEntityCollision(PlayerPedId(), false, false)
        
        SetVehicleDoorOpen(vehicle, 5, false, false)
        Wait(750)
        SetVehicleDoorShut(vehicle, 5, false)
        
        AttachEntityToEntity(PlayerPedId(), vehicle, 0, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
        
        CreateThread(function()
            while isZiptied do
                Wait(1000)
                local veh = GetEntityAttachedTo(PlayerPedId())
                if not DoesEntityExist(veh) or IsEntityDead(PlayerPedId()) then
                    DetachEntity(PlayerPedId(), true, true)
                    SetEntityVisible(PlayerPedId(), true, false)
                    SetEntityCollision(PlayerPedId(), true, true)
                    ClearPedTasks(PlayerPedId())
                    break
                end
            end
        end)
    end
end)

function GetPlayerOutOfTrunk()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if vehicle ~= 0 and vehicle ~= nil then
        local distanceToTrunk = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle))
        
        if distanceToTrunk < 5.0 then
            if GetVehicleDoorLockStatus(vehicle) ~= 2 then
                local players = QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(vehicle), 10.0)
                local playerFound = false
                
                for _, playerId in ipairs(players) do
                    local targetPed = GetPlayerPed(playerId)
                    if IsEntityAttachedToEntity(targetPed, vehicle) then
                        playerFound = true
                        local targetServerId = GetPlayerServerId(playerId)
                        TriggerServerEvent("ml187-kidnap:server:getOutTrunk", targetServerId, NetworkGetNetworkIdFromEntity(vehicle))
                        break
                    end
                end
                
                if not playerFound then
                    QBCore.Functions.Notify("No one in the trunk", "error")
                end
            else
                QBCore.Functions.Notify(Config.Notifications.vehicleLocked, "error")
            end
        else
            QBCore.Functions.Notify(Config.Notifications.notCloseToVehicle, "error")
        end
    else
        QBCore.Functions.Notify(Config.Notifications.noVehicleNearby, "error")
    end
end

RegisterCommand(Config.Commands.getOutTrunk, function()
    if IsEntityAttachedToEntity(PlayerPedId(), GetEntityAttachedTo(PlayerPedId())) then
        if isZiptied then
            QBCore.Functions.Notify(Config.Notifications.cantGetOut, "error")
            return
        end
        
        local ped = PlayerPedId()
        local vehicle = GetEntityAttachedTo(ped)
        if DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
            DetachEntity(ped, true, true)
            SetEntityVisible(ped, true, false)
            SetEntityCollision(ped, true, true)
            ClearPedTasks(ped)
            
            SetVehicleDoorOpen(vehicle, 5, false, false)
            
            local vehCoords = GetEntityCoords(vehicle)
            local forwardVector = GetEntityForwardVector(vehicle)
            SetEntityCoords(ped, vehCoords.x - forwardVector.x * 2.0, vehCoords.y - forwardVector.y * 2.0, vehCoords.z)
            
            Wait(750)
            SetVehicleDoorShut(vehicle, 5, false)
        end
    else
        GetPlayerOutOfTrunk()
    end
end, false)

RegisterNetEvent('ml187-kidnap:client:getOutTrunk')
AddEventHandler('ml187-kidnap:client:getOutTrunk', function(vehNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
    
    if DoesEntityExist(vehicle) then
        local ped = PlayerPedId()
        
        DetachEntity(ped, true, true)
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
        ClearPedTasks(ped)
        
        SetVehicleDoorOpen(vehicle, 5, false, false)
        
        local vehCoords = GetEntityCoords(vehicle)
        local forwardVector = GetEntityForwardVector(vehicle)
        SetEntityCoords(ped, vehCoords.x - forwardVector.x * 2.0, vehCoords.y - forwardVector.y * 2.0, vehCoords.z)
        
        Wait(750)
        SetVehicleDoorShut(vehicle, 5, false)
        
        if isZiptied then
            RequestAnimDict("mp_arresting")
            while not HasAnimDictLoaded("mp_arresting") do
                Wait(100)
            end
            TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
        end
    end
end)

function CutZiptie()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.0 then
        local targetId = GetPlayerServerId(player)
        QBCore.Functions.TriggerCallback('ml187-kidnap:server:hasKnife', function(hasKnife)
            if hasKnife then
                QBCore.Functions.Progressbar("cutting_ziptie", "Cutting zip-tie...", Config.CutZiptieTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                    anim = "machinic_loop_mechandplayer",
                    flags = 49,
                }, {}, {}, function() 
                    TriggerServerEvent("ml187-kidnap:server:cutZiptie", targetId)
                end, function() 
                    QBCore.Functions.Notify(Config.Notifications.cancelled, "error")
                end)
            else
                QBCore.Functions.Notify(Config.Notifications.needKnife, "error")
            end
        end)
    else
        QBCore.Functions.Notify(Config.Notifications.noPlayerNearby, "error")
    end
end

RegisterCommand(Config.Commands.cutZiptie, function()
    CutZiptie()
end, false)

RegisterNetEvent('ml187-kidnap:client:cutZiptie')
AddEventHandler('ml187-kidnap:client:cutZiptie', function()
    isZiptied = false
    local ped = PlayerPedId()
    
    ClearPedTasks(ped)
    SetEnableHandcuffs(ped, false)
    DisablePlayerFiring(ped, false)
    
    if IsEntityAttached(ped) then
        local vehicle = GetEntityAttachedTo(ped)
        if DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
            DetachEntity(ped, true, true)
            SetEntityVisible(ped, true, false)
            SetEntityCollision(ped, true, true)
            
            SetVehicleDoorOpen(vehicle, 5, false, false)
            
            local vehCoords = GetEntityCoords(vehicle)
            local forwardVector = GetEntityForwardVector(vehicle)
            SetEntityCoords(ped, vehCoords.x - forwardVector.x * 2.0, vehCoords.y - forwardVector.y * 2.0, vehCoords.z)
            
            Wait(750)
            SetVehicleDoorShut(vehicle, 5, false)
        end
    end
    
    QBCore.Functions.Notify(Config.Notifications.ziptiesCut, "success")
end)