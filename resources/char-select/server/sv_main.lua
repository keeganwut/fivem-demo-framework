local Core = exports['core']:FetchCore()

local mockdata = {
    [1] = {
        cid = 1,
        firstName = 'John',
        lastName = 'Doe'
    },
    [2] = {
        cid = 2,
        firstName = 'Jane',
        lastName = 'Doe'
    }
}

local function SetupClient(player, characters)
    TriggerClientEvent('char-select:client:SetupClient', player, characters)
end

local function SyncClient(player, characters)
    TriggerClientEvent('char-select:client:SyncClient', player, characters)
end

AddEventHandler('playerJoining', function()
    local src = source
    Core.SetPlayerCharacters(src, mockdata) -- populate the "database" with data to test our API
    Wait(1000)
    SetupClient(src, Core.GetPlayerCharacters(src)) -- prep client menu
end)

RegisterNetEvent('char-select:server:InstancePlayer', function()
    local src = source
    local playerPed = GetPlayerPed(src)
    local bucket = tostring(src)
    SetEntityRoutingBucket(playerPed, bucket)
end)

RegisterNetEvent('char-select:server:SelectCharacter', function(cid)
    local src = source
    -- todo ... refer to plan.txt :)
end)

RegisterNetEvent('char-select:server:DeleteCharacter', function(cid)
    local src = source
    local characters = Core.GetPlayerCharacters(src)
    if characters and characters[cid] then
        characters[cid] = nil
        Core.SetPlayerCharacters(src, characters)
        SyncClient(src, Core.GetPlayerCharacters(src))
    end
end)

RegisterNetEvent('char-select:server:CreateCharacter', function(data)
    local src = source
    local characters = Core.GetPlayerCharacters(src) or {}

    local charCount = 0
    for i = 1, 3 do
        if characters[i] then
            charCount = charCount + 1
        end
    end

    if charCount >= 3 then
        return
    end

    local newCid = nil
    for i = 1, 3 do
        if not characters[i] then
            newCid = i
            break
        end
    end

    if newCid then
        local newCharacter = {
            cid = newCid,
            firstName = data.firstname,
            lastName = data.lastname
        }
        characters[newCid] = newCharacter
        Core.SetPlayerCharacters(src, characters)
        SyncClient(src, Core.GetPlayerCharacters(src))
    end
end)

RegisterNetEvent('char-select:server:MimicJoin', function() -- Debug event
    local src = source
    Core.SetPlayerCharacters(src, mockdata) -- populate the "database" with data to test our API
    Wait(1000)
    SetupClient(src, Core.GetPlayerCharacters(src)) -- prep client menu
end)
