local inMenu = false
local spawnedPeds = {}

local peds = {
    [1] = {
        model = 'mp_m_boatstaff_01',
        animDict = 'timetable@reunited@ig_10',
        animName = 'isthisthebest_amanda',
        coords = vec4(-113.2123, -9.9648, 69.4195, 159.5774)
    },
    [2] = {
        model = 'a_m_m_skater_01',
        animDict = 'timetable@maid@couch@',
        animName = 'base',
        coords = vec4(-112.3501, -10.3675, 69.6196, 160.8868)
    },
    [3] = {
        model = 'g_f_y_vagos_01',
        animDict = 'missheist_agency3aleadinout_mcs_1',
        animName = 'sit',
        coords = vec4(-111.3365, -9.9284, 69.0195, 149.6640)
    }
}

local function CloseMenu()
    inMenu = false
    SetNuiFocus(false, false)
    RenderScriptCams(false, false, 0, true, false)
    DestroyAllCams(true)
    ClearFocus()

    for _, ped in pairs(spawnedPeds) do
        DeleteEntity(ped)
    end
    spawnedPeds = {}

    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, true)
    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)

    DisplayRadar(true)
    -- todo ... reroute player back to main bucket
end

local function DisableControls()
    CreateThread(function()
        while inMenu do
            DisableAllControlActions(0)
            Wait(1)
        end
    end)
end

local function SetupCamera()
    local camCoords = vec3(-113.7932, -12.1997, 70.5197)
    ClearFocus()
    local selectCam = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        camCoords,
        0.0,
        0.0,
        -50.0,
        GetGameplayCamFov() * 1.25
    )
    SetCamActive(selectCam, true)
    RenderScriptCams(true, false, 0, true, false)
    SetCamAffectsAiming(selectCam, false)
    DoScreenFadeIn(500)
end

local function PlacePed(index)
    CreateThread(function()
        local pedInfo = peds[index]
        if not pedInfo then return end

        local pedModel = pedInfo.model
        local pedCoords = pedInfo.coords
        local pedAnimDict = pedInfo.animDict
        local pedAnimName = pedInfo.animName

        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(0)
        end

        local createdPed = CreatePed(
            0,
            GetHashKey(pedModel),
            pedCoords.x,
            pedCoords.y,
            pedCoords.z,
            pedCoords.w,
            false,
            false
        )
        table.insert(spawnedPeds, createdPed)

        SetEntityVisible(createdPed, false)
        FreezeEntityPosition(createdPed, true)
        SetEntityInvincible(createdPed, true)
        SetPedConfigFlag(createdPed, 294, true)

        RequestAnimDict(pedAnimDict)
        while not HasAnimDictLoaded(pedAnimDict) do
            Wait(0)
        end

        TaskPlayAnim(
            createdPed,
            pedAnimDict,
            pedAnimName,
            8.0,
            8.0,
            -1,
            1
        )
        Wait(500)
        SetEntityVisible(createdPed, true)
        SetModelAsNoLongerNeeded(pedModel)
    end)
end

local function SetupPeds(characters)
    if spawnedPeds then
        for _, ped in pairs(spawnedPeds) do
            DeleteEntity(ped)
        end
        spawnedPeds = {}
    end

    for k, _ in pairs(characters) do
        PlacePed(k)
    end
end

local function SetupPlayer(characters)
    local playerPed = PlayerPedId()
    local menuCoords = vec3(-110.0162, -11.7297, 70.5197)

    DisableControls()
    DisplayRadar(false)

    SetEntityCoords(playerPed, menuCoords)
    SetEntityInvincible(playerPed, true)
    SetEntityVisible(playerPed, false)
    FreezeEntityPosition(playerPed, true)

    SetupPeds(characters)

    Wait(1000)

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'setupCharacters', data = characters })

    SetupCamera()
end

RegisterNetEvent('char-select:client:SetupClient', function(characters)
    local playerPed = PlayerPedId()
    inMenu = true
    TriggerServerEvent('char-select:server:InstancePlayer', playerPed)

    DoScreenFadeOut(0) -- Gets overwritten by cfx's spawn manager which is out of scope of this repository

    Wait(5000)

    DoScreenFadeOut(0) -- CFX spawn manager now fucks off and allows for a fade out

    SetupPlayer(characters)
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    TriggerServerEvent('char-select:server:SelectCharacter', data.cid)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    TriggerServerEvent('char-select:server:DeleteCharacter', data.cid)
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    TriggerServerEvent('char-select:server:CreateCharacter', data)
    cb('ok')
end)

exports.spawnmanager.setAutoSpawn(false) -- important fixes a bunch of issues
-- TriggerServerEvent('char-select:server:MimicJoin') -- debug
