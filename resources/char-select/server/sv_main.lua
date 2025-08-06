local function SetupClient(player)
    TriggerClientEvent('char-select:client:SetupClient', player)
end

AddEventHandler('playerJoining', function()
    local src = source | nil

    SetupClient(src) -- prep client menu
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
