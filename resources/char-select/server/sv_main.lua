local Core = exports['core']:FetchCore()

local mockdata = {
    [1] = {
        firstName = 'John',
        lastName = 'Doe',
        gender = 'male'
    },
    [2] = {
        firstName = 'Jane',
        lastName = 'Doe',
        gender = 'female'
    },
    [3] = {
        firstName = 'Jane',
        lastName = 'Doe',
        gender = 'female'
    }
}

local function SetupClient(player, characters)
    TriggerClientEvent('char-select:client:SetupClient', player, characters)
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

    SetEntityRoutingBucket(
        playerPed,
        bucket
    )
end)


RegisterNetEvent('char-select:server:MimicJoin', function() -- Debug event
    local src = source

    Core.SetPlayerCharacters(src, mockdata) -- populate the "database" with data to test our API

    Wait(1000)

    SetupClient(src, Core.GetPlayerCharacters(src)) -- prep client menu
end)
