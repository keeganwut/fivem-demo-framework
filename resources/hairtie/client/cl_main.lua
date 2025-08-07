local isTyingHair = false

local originalHairData = {
    drawable = nil,
    texture = nil,
}

local tiedHairForBodyType = {
    ['male']   = Config.MaleHairTied,
    ['female'] = Config.FemaleHairTied,
}

local function playAnim(animDict, animName)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end

    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, 2000, 50, 1, false, false, false)
end

function GetPedBodyType()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)

    if model == GetHashKey("mp_m_freemode_01") then
        return "male"
    elseif model == GetHashKey("mp_f_freemode_01") then
        return "female"
    else
        return "error" -- fails with non-mp peds
    end
end

RegisterNetEvent('hairtie:client:UseHairtie', function()
    CreateThread(function() -- thread because of the while loop in playAnim
        if isTyingHair then
            print("[INFO]: You are already doing this.")

            return
        end

        local ped = PlayerPedId()
        local bodyType = GetPedBodyType()

        if bodyType == "error" then
            print("[ERROR]: Ped model not supported.")
            return
        end

        local currentHair = GetPedDrawableVariation(ped, 2)
        local targetTiedHair = tiedHairForBodyType[bodyType]

        local isHairTied = (currentHair == targetTiedHair)

        if not isHairTied and not Config.SupportedHairs[bodyType][currentHair] then
            print("[INFO]: This hairstyle cannot be tied.")
            return
        end

        isTyingHair = true

        playAnim(Config.AnimDict, Config.AnimName)

        SetTimeout(1500, function()
            local playerPed = PlayerPedId()

            if IsEntityPlayingAnim(playerPed, Config.AnimDict, Config.AnimName, 3) then
                if isHairTied then
                    if originalHairData.drawable then
                        SetPedComponentVariation(playerPed, 2, originalHairData.drawable, originalHairData.texture, 2)
                        originalHairData.drawable = nil
                        originalHairData.texture = nil
                    end
                else
                    originalHairData.drawable = GetPedDrawableVariation(playerPed, 2)
                    originalHairData.texture = GetPedTextureVariation(playerPed, 2)
                    SetPedComponentVariation(playerPed, 2, targetTiedHair, originalHairData.texture, 2)
                end
            else
                print("[INFO]: Action canceled.")
            end

            isTyingHair = false
        end)
    end)
end)

RegisterNetEvent('hairtie:client:SetHair', function(args) -- DEBUG
    CreateThread(function()                               -- thread because of the while loop in loading model
        local bodyType = args and args[1]

        if bodyType ~= 'male' and bodyType ~= 'female' then return end

        local modelHash = (bodyType == 'male' and GetHashKey("mp_m_freemode_01") or GetHashKey("mp_f_freemode_01"))

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(0)
        end

        SetPlayerModel(PlayerId(), modelHash)
        SetModelAsNoLongerNeeded(modelHash)

        Wait(100)
        local ped = PlayerPedId()

        local supportedHairsForbodyType = Config.SupportedHairs[bodyType]
        if not supportedHairsForbodyType or not next(supportedHairsForbodyType) then return end

        local hairIdList = {}
        for hairId in pairs(supportedHairsForbodyType) do
            table.insert(hairIdList, hairId)
        end

        local randomHairId = hairIdList[math.random(#hairIdList)]

        SetPedComponentVariation(ped, 2, randomHairId, 0, 2)
    end)
end)
