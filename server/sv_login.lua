local hasDonePreloading = {}


local function GiveStarterItems(source)
    local src = source
    local Player = NPX.Functions.GetPlayer(src)
    
    
   
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
    NPX.Player.Logout(src)
    Wait(0)
    DropPlayer(src, "lahkus")
end)




RegisterNetEvent('rs_login:loadUserData')
AddEventHandler('rs_login:loadUserData', function(cData)
    local src = source
    print("Citizen ID: " .. cData.citizenid) -- No need for json encoding if it's already a string
    if NPX.Player.Login(src, cData.citizenid) then
        repeat
            Wait(20)
        until hasDonePreloading[src]
        
        -- Better to include the player's name for clarity
        local playerName = GetPlayerName(src)
        print('^2[WSRP]^7 '.. playerName ..' (Citizen ID: '.. cData.citizenid .. ') has successfully loaded!')
        
        NPX.Commands.Refresh(src)
        Wait(1000)
        TriggerClientEvent('ps-housing:client:setupSpawnUI', src, cData)
    end
    print("Load user data: " .. json.encode(cData)) -- Confirming data received (optional)
end)



RegisterNetEvent('qb-multicharacter:server:createCharacter')
AddEventHandler('qb-multicharacter:server:createCharacter', function(data)
    local src = source
    local newData = {
        cid = data.cid,
        charinfo = data
    }
    
    print("Character Created")
    print("Character data: " .. json.encode(newData))
    
    if NPX.Player.Login(src, false, newData) then
        repeat
            Wait(10)
        until hasDonePreloading[src]
        
        print('^2[WSRP]^7 '..GetPlayerName(src) ..' has successfully loaded!')
        NPX.Commands.Refresh(src)
        TriggerClientEvent("CloseNui", src)
        
        newData.citizenid = NPX.Functions.GetPlayer(src).PlayerData.citizenid
        print('^2[WSRP]^7 '..json.encode(newData.citizenid)..' has successfully added!')
        
        GiveStarterItems(src)
        Wait(5000)
        TriggerClientEvent('ps-housing:client:setupSpawnUI', src, newData)
    end
end)






RegisterNetEvent('qb-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    NPX.Player.DeleteCharacter(src, citizenid)
    TriggerClientEvent(Config.Notify, src, "Tegelane kustutatud" , "success")
end)


lib.callback.register('qb-multicharacter:server:GetUserCharacters', function(data)
    local src = source
    local steam = NPX.Functions.GetIdentifier(src, 'steam')
    local data = {}
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ?', {steam})
    
    return result

end)





lib.callback.register('qb-multicharacter:server:setupCharacters', function(source)
    local steam = NPX.Functions.GetIdentifier(source, 'steam')
    local plyChars = {}
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ?', {steam})

    for i = 1, #result do
        result[i].charinfo = json.decode(result[i].charinfo)
        result[i].money = json.decode(result[i].money)
        result[i].job = json.decode(result[i].job)
        plyChars[#plyChars+1] = result[i]
    end
    print("Setup Chars: " .. json.encode(plyChars))
    return plyChars
end)




lib.callback.register('qb-multicharacter:server:GetNumberOfCharacters', function(data)
    local src = source
    local license = NPX.Functions.GetIdentifier(src, 'steam')
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
        return
    end
    
end)


RegisterNetEvent('Logout', function()
    local src = source
    NPX.Player.Logout(src)
    TriggerClientEvent('np-base:spawnInitialized', src)


end)


NPX.Commands.Add("logout", "[Charmenu] logs you off", {}, false, function(source)
    local src = source
    NPX.Player.Logout(src)
    TriggerClientEvent('np-base:spawnInitialized', src)
end, "admin")


