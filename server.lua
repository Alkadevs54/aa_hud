Citizen.CreateThread(function()
    while true do
        local count = GetNumPlayerIndices()
        
        TriggerClientEvent('hud:updatePlayerCount', -1, count)
        
        Citizen.Wait(10000)
    end
end)
