local ESX = exports["es_extended"]:getSharedObject()

-- Variables
local jobName = "Chômeur"
local jobGrade = ""
local cashAmount = 0
local bankAmount = 0
local onlinePlayers = 0
local postals = {}
local nearestPostal = "0000"

-- 1. Chargement du fichier Postals
Citizen.CreateThread(function()
    local rawFile = LoadResourceFile(GetCurrentResourceName(), "new-postals.json")
    if rawFile then postals = json.decode(rawFile) end
end)

-- 2. Events Serveur & ESX
RegisterNetEvent('hud:updatePlayerCount')
AddEventHandler('hud:updatePlayerCount', function(count) onlinePlayers = count end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer) UpdateHUDData(xPlayer) end)
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job) jobName = job.label; jobGrade = job.grade_label end)
RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    if account.name == 'money' then cashAmount = account.money
    elseif account.name == 'bank' then bankAmount = account.money end
end)

function UpdateHUDData(xPlayer)
    if xPlayer.job then jobName = xPlayer.job.label; jobGrade = xPlayer.job.grade_label end
    if xPlayer.accounts then
        for _, account in pairs(xPlayer.accounts) do
            if account.name == 'money' then cashAmount = account.money
            elseif account.name == 'bank' then bankAmount = account.money end
        end
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    if ESX.IsPlayerLoaded() then UpdateHUDData(ESX.GetPlayerData()) end
end)

-- 3. Cache le HUD de base (Boucle ultra-rapide)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        HideHudComponentThisFrame(2)  -- Weapon Icon
        HideHudComponentThisFrame(20) -- Weapon Stats
        HideHudComponentThisFrame(22) -- Max HUD Weapons
    end
end)

-- 4. Calcul Postal (Boucle moyenne)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local minDistance = -1
        local foundCode = "0000"
        if #postals > 0 then
            for i = 1, #postals do
                local dist = #(coords - vector3(postals[i].x, postals[i].y, 0.0))
                if minDistance == -1 or dist < minDistance then
                    minDistance = dist
                    foundCode = postals[i].code
                end
            end
        end
        nearestPostal = foundCode
    end
end)

-- 5. Boucle Principale d'affichage (200ms)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        local playerPed = PlayerPedId()

        if IsPauseMenuActive() then
            SendNUIMessage({ action = "toggleHud", show = false })
        else
            SendNUIMessage({ action = "toggleHud", show = true })

            -- Données joueur
            local health = GetEntityHealth(playerPed) - 100
            if health < 0 then health = 0 end
            if health > 100 then health = 100 end
            local armor = GetPedArmour(playerPed)
            local stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
            local isTalking = NetworkIsPlayerTalking(PlayerId())

            -- Faim / Soif
            TriggerEvent('esx_status:getStatus', 'hunger', function(status) hunger = status.getPercent() end)
            TriggerEvent('esx_status:getStatus', 'thirst', function(status) thirst = status.getPercent() end)

            -- Heure
            local hour = GetClockHours()
            local minute = GetClockMinutes()
            if hour < 10 then hour = "0" .. hour end
            if minute < 10 then minute = "0" .. minute end

            -- Envoi HUD Principal
            SendNUIMessage({
                action = "updateHud",
                job = jobName, grade = jobGrade,
                cash = cashAmount, bank = bankAmount,
                health = health, armor = armor, stamina = stamina,
                hunger = hunger or 100, thirst = thirst or 100,
                time = hour .. ":" .. minute, postal = nearestPostal,
                id = GetPlayerServerId(PlayerId()), online = onlinePlayers,
                talking = isTalking
            })

            -- Logique Arme
            local weapon = GetSelectedPedWeapon(playerPed)
            local isArmed = IsPedArmed(playerPed, 4)
            if isArmed then
                local _, ammoInClip = GetAmmoInClip(playerPed, weapon)
                SendNUIMessage({ action = "updateAmmo", show = true, ammo = ammoInClip })
            else
                SendNUIMessage({ action = "updateAmmo", show = false })
            end

            -- Logique Voiture
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local speed = math.ceil(GetEntitySpeed(vehicle) * 3.6)
                local fuel = GetVehicleFuelLevel(vehicle)
                SendNUIMessage({ action = "carHud", show = true, speed = speed, fuel = fuel })
            else
                SendNUIMessage({ action = "carHud", show = false })
            end
        end
    end
end)
