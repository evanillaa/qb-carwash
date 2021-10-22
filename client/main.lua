local washingVehicle = false

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        local inRange = false
        local PlayerPed = PlayerPedId()
        local PlayerPos = GetEntityCoords(PlayerPed)
        local PedVehicle = GetVehiclePedIsIn(PlayerPed)
        local Driver = GetPedInVehicleSeat(PedVehicle, -1)


        if IsPedInAnyVehicle(PlayerPed) then
            for k, v in pairs(Config.Locations) do
                local dist = #(PlayerPos - vector3(Config.Locations[k]["coords"]["x"], Config.Locations[k]["coords"]["y"], Config.Locations[k]["coords"]["z"]))

                if dist <= 10 then
                    inRange = true
                    
                    if dist <= 7.5 then
                        if Driver == PlayerPed then
                            if not washingVehicle then
                                DrawText3Ds(Config.Locations[k]["coords"]["x"], Config.Locations[k]["coords"]["y"], Config.Locations[k]["coords"]["z"], '~g~E~w~ - Washing car ($'..Config.DefaultPrice..')')
                                if IsControlJustPressed(0, 38) then
                                    TriggerServerEvent('qb-carwash:server:washCar')
                                end
                            else
                                DrawText3Ds(Config.Locations[k]["coords"]["x"], Config.Locations[k]["coords"]["y"], Config.Locations[k]["coords"]["z"], 'The car wash is not available ..')
                            end
                        end
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(5000)
        end

        Citizen.Wait(3)
    end
end)
RegisterNetEvent('qb-carwash:client:washCar')
AddEventHandler('qb-carwash:client:washCar', function()
    local PlayerPed = PlayerPedId()
    local PedVehicle = GetVehiclePedIsIn(PlayerPed)
    local Driver = GetPedInVehicleSeat(PedVehicle, -1)
    local coords = GetEntityCoords(GetVehiclePedIsIn(PlayerPed))

    washingVehicle = true

    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(1)
        end
    end
    UseParticleFxAssetNextCall("core")
    particles = StartParticleFxLoopedAtCoord("ent_amb_waterfall_splash_p", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    UseParticleFxAssetNextCall("core")
    particles2 = StartParticleFxLoopedAtCoord("ent_amb_waterfall_splash_p", coords.x + 1, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    UseParticleFxAssetNextCall("core")
    particles3 = StartParticleFxLoopedAtCoord("ent_amb_waterfall_splash_p", coords.x - 1, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)

    QBCore.Functions.Progressbar("washed", "Vehicle is being washed ..", math.random(4000, 8000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        SetVehicleDirtLevel(PedVehicle)
        SetVehicleUndriveable(PedVehicle, false)
        WashDecalsFromVehicle(PedVehicle, 1.0)
        washingVehicle = false
        StopParticleFxLooped(particles, 0)
        StopParticleFxLooped(particles2, 0)
        StopParticleFxLooped(particles3, 0)
        QBCore.Functions.Notify("Your vehicle is clean.", "success")
    end, function() -- Cancel
        QBCore.Functions.Notify("Washing cancelled.", "error")
        washingVehicle = false
    end)
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.Locations) do
        carWash = AddBlipForCoord(Config.Locations[k]["coords"]["x"], Config.Locations[k]["coords"]["y"], Config.Locations[k]["coords"]["z"])

        SetBlipSprite (carWash, 100)
        SetBlipDisplay(carWash, 4)
        SetBlipScale  (carWash, 0.75)
        SetBlipAsShortRange(carWash, true)
        SetBlipColour(carWash, 37)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.Locations[k]["label"])
        EndTextCommandSetBlipName(carWash)
    end
end)
