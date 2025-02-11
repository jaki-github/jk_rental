Config = {}

Config.Debug = false

Config.Rental = {
    { 
        pedModel = "s_m_o_busker_01", 
        pedCoords = vec4(191.11, -861.9, 31.4, 12.51), 
        rentals = {
            { model = 'BMX', price = '10', img = 'https://docs.fivem.net/vehicles/bmx.webp' },
            { model = 'Cruiser', price = '15', img = 'https://docs.fivem.net/vehicles/cruiser.webp' },
            { model = 'inductor2', price = '25', img = 'https://docs.fivem.net/vehicles/inductor2.webp' }
        },
        blip = 348,
        blipColor = 0,
        icon = "fa-solid fa-bicycle",
        spawnRental = vec4(189.97, -858.76, 31.5, 4.84)
    },
    { 
        pedModel = "a_m_y_business_03", 
        pedCoords = vec4(235.27, -754.34, 34.64, 342.38), 
        rentals = {
            { model = 'Blista', price = '100', img = 'https://docs.fivem.net/vehicles/blista.webp' },
            { model = 'Club', price = '80', img = 'https://docs.fivem.net/vehicles/club.webp' },
            { model = 'Asea', price = '70', img = 'https://docs.fivem.net/vehicles/asea.webp' }
        },
        blip = 225,
        blipColor = 0,
        icon = "fa-solid fa-car",
        spawnRental = vec4(224.95, -751.66, 34.64, 343.21)
    },
    --- Add more here:
}

function dbug(...)
    if Config.Debug then print('^3[DEBUG]^7', ...) end
end