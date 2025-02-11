local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('jk_rental:server:checkMoney', function(source, cb, price)
  local Player = QBCore.Functions.GetPlayer(source)
  if Player then
    local cash = Player.Functions.GetMoney('cash')
    if cash >= price then
      cb(true)
    else
      cb(false)
    end
  else
    cb(false)
  end
end)

RegisterNetEvent('jk_rental:server:stopRental', function(totalCost)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)

  if Player then
    if Player.Functions.RemoveMoney('cash', totalCost) then
      TriggerClientEvent('ox_lib:notify', src, "You paid " .. totalCost .. " $ for the rental.", "success")
    end
  end
end)