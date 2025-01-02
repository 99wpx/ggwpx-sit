local QBCore = exports['qb-core']:GetCoreObject()

local seatsTaken = {}

RegisterNetEvent('ggwpx-sit-anyware:TakeSeat', function(objectCoords)
    local src = source
    if not seatsTaken[objectCoords] then
        seatsTaken[objectCoords] = true
        TriggerClientEvent('QBCore:Notify', src, 'You are now seat.', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'This seat is already taken.', 'error')
    end
end)

RegisterNetEvent('ggwpx-sit-anyware:leaveSeat', function(objectCoords)
    local src = source
    if seatsTaken[objectCoords] then
        seatsTaken[objectCoords] = nil
        TriggerClientEvent('QBCore:Notify', src, 'You have left the seat.', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'You are not seat here.', 'error')
    end
end)

QBCore.Functions.CreateCallback('ggwpx-sit-anyware:getSeat', function(source, cb, objectCoords)
    cb(seatsTaken[objectCoords] or false)
end)
