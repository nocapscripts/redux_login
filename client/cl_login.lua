local menuOpen = false
local setDate = 0
local spawnAlreadyInit = false
local cam = nil
local chardata

local function skyCam(bool)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        --vector4(151.67008, -768.8977, 279.66925, 96.837013)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 151.67008, -768.8977, 279.66925, 96.837013, 60.00, false, 0)
        SetEntityCoords(PlayerPedId(), 149.03585, -769.2849, 279.16873)
        
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end



local function sendMessage(data)
    SendNUIMessage(data)
end


CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
            TriggerEvent('qb-multicharacter:client:chooseChar')
            Wait(10)
			return
        
        end
	end
end)

local function openMenu(bool)

    if spawnAlreadyInit then
        return
    end
    menuOpen = bool
    sendMessage({open = bool})
    SetNuiFocus(bool, bool)
    skyCam(bool)
    Citizen.CreateThread(function()
        while menuOpen do
            Citizen.Wait(0)
            HideHudAndRadarThisFrame()
        
            
        end
    end)
    

end

RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    SetNuiFocus(true, true)
    DoScreenFadeOut(10)
    Wait(1000)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    openMenu(true)
end)





local function closeMenu(bool)
    menuOpen = bool
    spawnAlreadyInit = bool
    EnableAllControlActions(0)
    sendMessage({close = bool})
    TaskSetBlockingOfNonTemporaryEvents(PlayerPedId(), bool)
    SetNuiFocus(bool, bool)
    skyCam(bool)
end

RegisterNetEvent('CloseNui', function()
    closeMenu() -- default no bool

end)

local function disconnect()
    TriggerServerEvent("qb-multicharacter:server:disconnect")
end

local function datacallback(data)
    Citizen.Wait(1000)
    local src = source
    
    print(json.encode(data))

    if data.close then openMenu(false) end
    if data.disconnect then disconnect() end
    
    --if data.setcursorloc then SetCursorLocation(data.setcursorloc.x, data.setcursorloc.y) end
    
    if data.fetchdata then
        userchars = {}
        userchars = lib.callback.await('qb-multicharacter:server:GetUserCharacters', false)
        
        sendMessage({playerdata = userchars})
        
        
        --if data.showcursor or data.showcursor == false then SetNuiFocus(true, data.showcursor) end
    end

    if data.newchar then
        print(json.encode(data))
       

        chardata = { 
            firstname = data.firstname,
            lastname = data.lastname,
            birthdate = data.birthdate,
            gender = data.gender,
            background = data.background,
            story = data.story,
            cid = math.random(9999),
        }
       
        if data.gender == "Male" then
            data.gender = 0
        elseif data.gender == "Female" then
            data.gender = 1
        end
        TriggerServerEvent('qb-multicharacter:server:createCharacter', chardata)
        Wait(50)
       
        sendMessage({createCharacter = data})
        closeMenu(false)

       
    end

    if data.fetchcharacters then
        fetch = {}
        fetch = lib.callback.await('qb-multicharacter:server:setupCharacters', false)
        sendMessage({playercharacters = fetch})
        
        
        
        
    end

    if data.deletecharacter then
        if not data.deletecharacter then return end
        TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data)

        TriggerEvent('qb-multicharacter:client:chooseChar')
        openMenu(true)
        sendMessage({reload = true})
       
      
    end

    if data.selectcharacter then
        Wait(1000)
        closeMenu(false)
        print(json.encode("MEGA LAHE ON IKKA: " .. data.charId))
        TriggerServerEvent('rs_login:loadUserData', data.charId)
        print("Nehhhhhhhhhhhh")
       
        
    end
end

RegisterNUICallback("nuiMessage", datacallback)

RegisterNUICallback('createNewCharacter', function(data, cb)
    local src = source
    local cData = data
    DoScreenFadeOut(150)
    if cData.gender == "Male" then
        cData.gender = 0
    elseif cData.gender == "Female" then
        cData.gender = 1
    end
    cData.isNew = true
    TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
   
    Wait(500)
    cb("ok")
end)

RegisterNUICallback("deletechar", function(data)
    local src = source
    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data)

end)

RegisterNUICallback("selectchar", function(data, cb)
    print("Selected character citizenid: ".. json.encode(data))
    local cData = {
        citizenid = data
    }
    DoScreenFadeOut(10)
    closeMenu(false)
    cb("ok")
    TriggerServerEvent('rs_login:loadUserData', cData)
end)




RegisterNetEvent("updateTimeReturn")
AddEventHandler("updateTimeReturn", function()
    setDate = "" .. 0 .. ""
    sendMessage({date = setDate})
end)

  
if Config.Debug then 
    RegisterCommand("charopen", function()
        --TriggerEvent('qb-multicharacter:client:chooseChar')
        openMenu(true)
    end, false)

    RegisterCommand("charclose", function()
        closeMenu(false)
    end, false)
end



-- It is related to my custom library script unfortunately i cannot share this :(

--if Config.InsertUserData then
    AddEventHandler(Config.OnPlayerLoaded, function()
        local src = source
        local user = NPX.Functions.GetPlayerData()
        local steam = user.license 
        local cid = user.cid

        TriggerServerEvent('InsertUserData', src, cid, steam)

    end)
--end

AddEventHandler('onResourceStart', function()
    TriggerServerEvent('Logout')
    --openMenu(true)

end)


RegisterNUICallback("exit", function(data)
    closeMenu(false)
end)





RegisterNetEvent("np-base:spawnInitialized")
AddEventHandler("np-base:spawnInitialized", function()
    -- Citizen.Wait(3000)
    TriggerEvent('qb-multicharacter:client:chooseChar')
end)