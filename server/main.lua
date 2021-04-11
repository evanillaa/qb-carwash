QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local ItemList = {
    ["cash"] = "cash"
}

-- Code

RegisterServerEvent('qb-carwash:server:washCar')
AddEventHandler('qb-carwash:server:washCar', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cash = Player.Functions.GetItemByName('cash')

    if Player.PlayerData.items ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if cash ~= nil then
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    if Player.PlayerData.items[k].name == "cash" and Player.PlayerData.items[k].amount >= Config.DefaultPrice then 
                        Player.Functions.RemoveItem("cash", Config.DefaultPrice, k)
                        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cash'], "remove")
                        TriggerClientEvent('qb-carwash:client:washCar', src)
                    else
                        TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                        break
                    end
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "You do not have cash", 'error')   
                break
            end
        end
    end
end) 