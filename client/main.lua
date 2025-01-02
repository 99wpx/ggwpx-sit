local QBCore = exports['qb-core']:GetCoreObject()

local sitting, currentSitCoords, currentScenario, disableControls = false, nil, nil, false
local currentObj = nil

exports('sitting', function()
    return sitting
end)

Citizen.CreateThread(function()
    local Sitables = {}

    for _, v in pairs(Config.Interactables) do
        local model = GetHashKey(v)
        table.insert(Sitables, model)
    end
    Citizen.Wait(100)

    if Config.UseTarget == "qb-target" then
        exports['qb-target']:AddTargetModel(Sitables, {
            options = {
                {
                    event = "ggwpx-sit-anyware:Sit",
                    icon = "fas fa-chair",
                    label = "Use",
                    canInteract = function()
                        return not sitting
                    end,
                },
            },
            job = {"all"},
            distance = Config.MaxDistance
        })
    elseif Config.UseTarget == "ox_target" then
        exports['ox_target']:AddTargetModel(Sitables, {
            {
                name = "Sit",
                icon = "fas fa-chair",
                label = "Use",
                onSelect = function(data)
                    if not sitting then
                        TriggerEvent("ggwpx-sit-anyware:Sit", { entity = data.entity })
                    end
                end,
                canInteract = function()
                    return not sitting
                end,
            },
        })
    end
end)

function wakeup()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    if currentScenario then
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)
        FreezeEntityPosition(currentObj, false)
        TriggerServerEvent('ggwpx-sit-anyware:leaveSeat', currentSitCoords)
        currentSitCoords, currentScenario = nil, nil
        sitting = false
        disableControls = false
    end
end

function sit(object, modelName, data)
    if not HasEntityClearLosToEntity(PlayerPedId(), object, 17) then
        return
    end
    disableControls = true
    currentObj = object
    FreezeEntityPosition(object, true)

    local pos = GetEntityCoords(object)
    local playerPos = GetEntityCoords(PlayerPedId())
    local objectCoords = pos.x .. pos.y .. pos.z

    QBCore.Functions.TriggerCallback('ggwpx-sit-anyware:getSeat', function(occupied)
        if occupied then
            QBCore.Functions.Notify('Chair is being used.', 'error')
        else
            local playerPed = PlayerPedId()
            currentSitCoords = objectCoords

            TriggerServerEvent('ggwpx-sit-anyware:TakeSeat', objectCoords)

            currentScenario = data.scenario
            TaskStartScenarioAtPosition(playerPed, currentScenario, pos.x, pos.y, pos.z + 0.5, GetEntityHeading(object) + 180.0, 0, true, false)

            Citizen.Wait(2500)
            if GetEntitySpeed(PlayerPedId()) > 0 then
                ClearPedTasks(PlayerPedId())
                TaskStartScenarioAtPosition(playerPed, currentScenario, pos.x, pos.y, pos.z + 0.5, GetEntityHeading(object) + 180.0, 0, true, true)
            end

            sitting = true
        end
    end, objectCoords)
end

RegisterNetEvent("ggwpx-sit-anyware:Sit", function(data)
    local playerPed = PlayerPedId()

    if sitting and not IsPedUsingScenario(playerPed, currentScenario) then
        wakeup()
    end

    if disableControls then
        DisableControlAction(1, 37, true)
    end

    local object, distance = data.entity, #(GetEntityCoords(playerPed) - GetEntityCoords(data.entity))

    if distance and distance < 1.4 then
        local hash = GetEntityModel(object)

        for k, v in pairs(Config.Sitable) do
            if GetHashKey(k) == hash then
                sit(object, k, v)
                break
            end
        end
    end
end)

RegisterNetEvent("ggwpx-sit-anyware:Stand", function()
    if sitting then
        wakeup() 
    end
end)

function helpText(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if sitting then
            helpText("Press ~INPUT_CONTEXT~ to stand up.")
            if IsControlJustPressed(0, 38) then
                TriggerEvent("ggwpx-sit-anyware:Stand")
            end
        end
    end
end)
