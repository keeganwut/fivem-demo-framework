RegisterCommand("hairtie", function(source, args, rawCommand)
    local src = source

    if src > 0 then
        TriggerClientEvent('hairtie:client:UseHairtie', src)
    else
        print("This command does not work from the server console.")
    end
end, false)

RegisterCommand("sethair", function(source, args, rawCommand)
    local src = source

    if src > 0 then
        if #args < 1 then
            print("Usage: /sethair <male|female>")
            return
        end

        TriggerClientEvent('hairtie:client:SetHair', src, args)
    else
        print("This command does not work from the server console.")
    end
end)
