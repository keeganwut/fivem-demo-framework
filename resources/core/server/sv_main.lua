Core = Core or {}

local playerCharacters = {}

Core.GetPlayerCharacters = function(playerId)
    return playerCharacters[playerId]
end

Core.SetPlayerCharacters = function(playerId, data)
    playerCharacters[playerId] = data
end

exports('FetchCore', function()
    return Core
end)
