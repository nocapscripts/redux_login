local Core = exports[Config.Framework]:GetCoreObject()
local hasDonePreloading = {}


local function GiveStarterItems(source)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    
    
   
    for k, v in pairs(QBShared.StarterItems) do
        exports['idcard']:CreateMetaLicense(src)
        exports.ox_inventory.AddItem(src, v.item, v.count)
    end
end


AddEventHandler(Config.OnPlayerLoaded, function(Player)
    Wait(1000) -- 1 second should be enough to do the preloading in other resources
    hasDonePreloading[Player.PlayerData.source] = true
end)

AddEventHandler(Config.OnPlayerUnload, function(src)
    hasDonePreloading[src] = false
end)

RegisterNetEvent('qb-multicharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "lahkus")
end)

RegisterNetEvent('qb-multicharacter:server:loadUserData', function(cData)
    local src = source
    if Core.Player.Login(src, cData) then
        repeat
            Wait(10)
        until hasDonePreloading[src]
        print('^2[qb-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData..') has succesfully loaded!')
        Core.Commands.Refresh(src)
        --TriggerClientEvent("CloseNui", src)
        TriggerClientEvent('ps-housing:client:setupSpawnUI', src, cData)
    end
end)


RegisterNetEvent('qb-multicharacter:server:createCharacter', function(data)
    local src = source
    local newData = {}
    print(json.encode(data))
    newData.cid = math.random(1, 600)
    newData.charinfo = data
    if Core.Player.Login(src, false, newData) then
        repeat
            Wait(10)
        until hasDonePreloading[src]
        print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
        Core.Commands.Refresh(src)
        GiveStarterItems(src)
        TriggerClientEvent("CloseNui", src)
        newData.citizenid = Core.Functions.GetPlayer(src).PlayerData.citizenid
        TriggerClientEvent('ps-housing:client:setupSpawnUI', src, newData)
        
    end
end)


RegisterNetEvent('qb-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    Core.Player.DeleteCharacter(src, citizenid)
    TriggerClientEvent(Config.Notify, src, Lang:t("notifications.char_deleted") , "success")
end)


lib.callback.register('qb-multicharacter:server:GetUserCharacters', function(data)
    local src = source
    local steam = Core.Functions.GetIdentifier(src, 'steam')
    local data = {}
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ?', {steam})
    
    return result

end)





lib.callback.register('qb-multicharacter:server:setupCharacters', function(source)
    local steam = Core.Functions.GetIdentifier(source, 'steam')
    local plyChars = {}
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ?', {steam})

    for i = 1, #result do
        result[i].charinfo = json.decode(result[i].charinfo)
        result[i].money = json.decode(result[i].money)
        result[i].job = json.decode(result[i].job)
        plyChars[#plyChars+1] = result[i]
    end
    print("Setup Chars: "..json.encode(plyChars))
    return plyChars
end)




lib.callback.register('qb-multicharacter:server:GetNumberOfCharacters', function(data)
    local src = source
    local license = Core.Functions.GetIdentifier(src, 'steam')
    local numOfChars = 0

    if next(Config.PlayersNumberOfCharacters) then
        for _, v in pairs(Config.PlayersNumberOfCharacters) do
            if v.license == license then
                numOfChars = v.numberOfChars
                break
            else
                numOfChars = 4
            end
        end
    else
        numOfChars = Config.DefaultNumberOfCharacters
    end
    return numOfChars
    
end)



lib.callback.register('qb-multicharacter:server:getSkin', function(data)
    local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1})
    if result[1] ~= nil then
        local data = {
            model = result[1].model,
            skin = result[1].skin
        }
        return data
    else
        return nil
    end
    
end)




Core.Commands.Add("logout", "[Charmenu] logs you off", {}, false, function(source)
    local src = source
    Core.Player.Logout(src)
    TriggerClientEvent('np-base:spawnInitialized', src)
end, "admin")


