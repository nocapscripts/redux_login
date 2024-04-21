local Core = exports[Config.Framework]:GetCoreObject()
local menuOpen = false
local setDate = 0
local spawnAlreadyInit = false
local cam = nil


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

RegisterNUICallback("exit", function(data)
    openMenu(false)
end)

local function sendMessage(data)
    SendNUIMessage(data)
end
CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
            openMenu(true)
			return
        
        end
	end
end)



function openMenu(bool)

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
    closeMenu(false) -- default no bool

end)

local function disconnect()
    TriggerServerEvent("qb-multicharacter:server:disconnect")
end

local function nuiCallBack(data)
    Citizen.Wait(60)
    

    if data.close then openMenu(false) end
    if data.disconnect then disconnect() end
    
    if data.setcursorloc then SetCursorLocation(data.setcursorloc.x, data.setcursorloc.y) end
    
    if data.fetchdata then
        local userchars = {}
        userchars = lib.callback.await('qb-multicharacter:server:GetUserCharacters', false)
        
        sendMessage({playerdata = userchars})
        
        
        if data.showcursor or data.showcursor == false then SetNuiFocus(true, data.showcursor) end
    end

    if data.newchar then
        print(json.encode(data))
       

        local chardata = { 
            firstname = data.firstname,
            lastname = data.lastname,
            birthdate = data.birthdate ,
            gender = data.gender,
            background = data.background,
            story = data.story,
            cid = 0,

        }
       
        if data.gender == "Male" then
            data.gender = 0
        elseif data.gender == "Female" then
            data.gender = 1
        end
        TriggerServerEvent('qb-multicharacter:server:createCharacter', chardata)
        Wait(500)
       
        sendMessage({createCharacter = data})
        closeMenu()

       
    end

    if data.fetchcharacters then
        local fetch = {}
        fetch = lib.callback.await('qb-multicharacter:server:setupCharacters', false)
        sendMessage({playercharacters = fetch})
        
        
        
        
    end

    if data.deletecharacter then
        if not data.deletecharacter then return end
        TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data)
        TriggerEvent('np-base:spawnInitialized')
        sendMessage({reload = true})
       
      
    end

    if data.selectcharacter then
        Wait(1000)
        closeMenu(false)
        TriggerServerEvent('qb-multicharacter:server:loadUserData', data)
       
       
        
    end
end

RegisterNUICallback("nuiMessage", nuiCallBack)

RegisterNUICallback('createNewCharacter', function(data, cb)
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

    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data)

end)

RegisterNUICallback("selectchar", function(data)
    closeMenu(false)
    SetNuiFocus(false, false)
    print("This is selector")
    TriggerServerEvent('qb-multicharacter:server:loadUserData', data)

end)

RegisterNetEvent("np-base:spawnInitialized")
AddEventHandler("np-base:spawnInitialized", function()
    -- Citizen.Wait(3000)
    openMenu(true)
end)


RegisterNetEvent("updateTimeReturn")
AddEventHandler("updateTimeReturn", function()
    setDate = "" .. 0 .. ""
    sendMessage({date = setDate})
end)

  
if Config.Debug then 
    RegisterCommand("charopen", function()
        openMenu(true)
    end, false)

    RegisterCommand("charclose", function()
        closeMenu(true)
    end, false)
end



-- It is related to my custom library script unfortunately i cannot share this :(

if Config.InsertUserData then
    AddEventHandler(Config.OnPlayerLoaded, function()
        local src = source
        local user = Core.Functions.GetPlayerData()
        local steam = user.license 
        local cid = user.cid

        TriggerServerEvent('InsertUserData', src, cid, steam)

    end)
end


