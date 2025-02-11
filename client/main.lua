local QBCore = exports['qb-core']:GetCoreObject()
local rentalVehicle = nil
local rentalPrice = Config.Rental[1].rentals[1].price
local rentalTime = 0
local rentalTimerActive = false
local currentTotalCost = 0

Citizen.CreateThread(function()
  for a, rental in pairs(Config.Rental) do
    for b, ped in pairs(rental) do
      RequestModel(rental.pedModel)
      while not HasModelLoaded(rental.pedModel) do
        Wait(500)
      end

      local ped = CreatePed(4, rental.pedModel, rental.pedCoords.x, rental.pedCoords.y, rental.pedCoords.z - 1.0,
        rental.pedCoords.w, false, true)
      SetEntityInvincible(ped, true)
      SetBlockingOfNonTemporaryEvents(ped, true)
      FreezeEntityPosition(ped, true)
      break
    end

    for c, target in pairs(rental) do
      exports.ox_target:addBoxZone({
        coords = rental.pedCoords.xyz,
        size = vec3(1, 1, 2),
        rotation = rental.pedCoords.w,
        debug = Config.Debug,
        options = { {
          distance = 2.5,
          name = "_rental_" .. c,
          label = 'Rental',
          icon = rental.icon,
          onSelect = function()
            TriggerEvent('jk_rental:client:rental', a)
          end
        } }
      })
      break
    end

    for d, blip in pairs(rental) do
      local blip = AddBlipForCoord(rental.pedCoords.x, rental.pedCoords.y, rental.pedCoords.z)

      SetBlipSprite(blip, rental.blip)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.9)
      SetBlipColour(blip, rental.blipColor)
      SetBlipAsShortRange(blip, true)

      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Rental")
      EndTextCommandSetBlipName(blip)
      break
    end
  end
end)

RegisterNetEvent('jk_rental:client:rental', function(rentalIndex)
  local rentalData = Config.Rental[rentalIndex]
  local options = {}

  for _, rental in pairs(rentalData.rentals) do
    table.insert(options, {
      title = rental.model,
      description = rental.price .. ' $',
      onSelect = function()
        TriggerEvent('jk_rental:client:startRental', rental.model, rentalData.spawnRental, tonumber(rental.price))
      end,
      image = rental.img,
    })
  end

  lib.registerContext({
    id = 'rental_menu_' .. rentalIndex,
    title = 'Rental Menu',
    options = options
  })

  lib.showContext('rental_menu_' .. rentalIndex)
end)

function StartRentalTimer(rentalPrice)
  CreateThread(function()
    rentalTime = 0
    rentalTimerActive = true
    local pricePerMinute = rentalPrice
    currentTotalCost = rentalPrice

    while rentalTimerActive do
      Wait(1000)

      rentalTime = rentalTime + 1
      currentTotalCost = rentalPrice + math.floor(rentalTime / 60) * pricePerMinute

      lib.showTextUI("Price: " ..
        currentTotalCost .. "$ Time: " .. string.format("%02d:%02d", math.floor(rentalTime / 60), rentalTime % 60))
    end
    lib.hideTextUI()
  end)
end

RegisterNetEvent('jk_rental:client:startRental', function(vehicleModel, spawnCoords, price, plate)
  local playerPed = PlayerPedId()
  local model = GetHashKey(vehicleModel)

  QBCore.Functions.TriggerCallback('jk_rental:server:checkMoney', function(hasMoney)
    if not hasMoney then
      lib.notify({
        title = 'Rental',
        description = 'You do not have enough money to rent this vehicle!',
        duration = 3000,
        type = 'error'
      })
      return 
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(100)
    end

    rentalVehicle = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    TaskWarpPedIntoVehicle(playerPed, rentalVehicle, -1)
    SetVehicleNumberPlateText(rentalVehicle, "RENT" .. math.random(100, 999))
    SetEntityAsMissionEntity(rentalVehicle, true, true)
    SetModelAsNoLongerNeeded(model)
    SetVehicleDoorsLocked(rentalVehicle, 1) 
    SetVehicleEngineOn(rentalVehicle, true, true, false)
    SetEntityAsMissionEntity(rentalVehicle, true, true)
    SetModelAsNoLongerNeeded(model)

    rentalTime = 0
    rentalTimerActive = true

    lib.notify({
      title = 'Rental',
      description = 'You have rented a ' .. vehicleModel,
      duration = 3000,
      showDuration = true,
      type = 'success'
    })

    StartRentalTimer(price)
  end, price) 
end)


RegisterNetEvent('jk_rental:client:stopRental', function()
  if rentalVehicle then
    rentalTimerActive = false
    TriggerServerEvent('jk_rental:server:stopRental', currentTotalCost, VehToNet(rentalVehicle))

    lib.notify({
      title = 'Rental',
      description = 'You have now ended your rental! Total cost: ' .. currentTotalCost .. '$',
      duration = 3000,
      type = 'success'
    })

    lib.hideTextUI()
    DeleteVehicle(rentalVehicle)
    rentalVehicle = nil
    rentalTime = 0
    currentTotalCost = 0
  else
    lib.notify({
      title = 'Rental',
      description = 'You have no rental active.',
      duration = 3000,
      type = 'error'
    })
  end
end)

RegisterCommand('stoprental', function()
  TriggerEvent('jk_rental:client:stopRental')
end)