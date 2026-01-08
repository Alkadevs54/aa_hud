Citizen.CreateThread(function()
    while true do
        -- Compte le nombre de joueurs et l'envoie aux clients
        local count = GetNumPlayerIndices()
        TriggerClientEvent('hud:updatePlayerCount', -1, count)
        Citizen.Wait(10000) -- Mise à jour toutes les 10 secondes
    end
end)
