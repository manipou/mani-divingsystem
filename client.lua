local Config = lib.load('config')
local oxygenLevel = 1000
local scubaOn = false
local originalSkin = nil

local function SetOxygenLevel(level)
    oxygenLevel = level
    SendNUIMessage({
        type = "updateOxygen",
        value = oxygenLevel
    })
end

exports('SetOxygenLevel', SetOxygenLevel)
exports('IsScubaActive', function() return scubaOn end)

local function applySkin(playerPed, toggle)
    local pedModel = GetEntityModel(playerPed)
    local gender = Config.Gender[pedModel]
    if not gender then return end
    if toggle then
        if not originalSkin then originalSkin = Config.GetSkin() end

        SetPedComponentVariation(playerPed, 8, gender == 'Male' and 124 or 154)
        SetPedPropIndex(playerPed, 1, gender == 'Male' and 26 or 28)
        SetPedComponentVariation(playerPed, 6, gender == 'Male' and 67 or 70)
    else
        Config.SetSkin(playerPed, originalSkin)
        originalSkin = nil
    end
end

local function startScubaLoop()
    scubaOn = true
    CreateThread(function()
        while scubaOn do
            Wait(Config.OxygenConsumption * 100)
            local ped = cache.ped
            if oxygenLevel <= 0 then
                scubaOn = false
                SetPedConfigFlag(ped, 3, true)
            elseif IsPedSwimmingUnderWater(ped) then
                SetOxygenLevel(oxygenLevel - 1)
                SetPedConfigFlag(ped, 3, false)
            end
        end
    end)
end

local function toggleSettings(toggle)
    local ped = cache.ped
    scubaOn = toggle
    SetEnableScuba(ped, toggle)
    SetPedConfigFlag(ped, 3, toggle)
    applySkin(ped, toggle)
end

RegisterCommand('scubaOff', function()
    if not scubaOn then return lib.notify({ title = 'Du har ikke dykkerudstyr på', type = 'error' }) end

    if not lib.progressActive() and lib.progressBar({
        duration = 4000,
        label = 'Tager dykkerudstyr af',
        useWhileDead = false,
        canCancel = true,
        anim = {
			dict = 'clothingtie',
			clip = 'try_tie_negative_a',    
			flags = 51,
        }
    }) then
        toggleSettings(false)
        SendNUIMessage({
            type = "toggleHud",
            visible = false
        })
        lib.callback.await('mani-divingsystem:server:toggle', false, false, { oxygen = oxygenLevel })
    end
end)

exports('equipScuba', function(data)
    if scubaOn then return lib.notify({ title = 'Du har allerde dykkerudstyr på', type = 'error' }) end

    if not lib.progressActive() and lib.progressBar({
        duration = 4000,
        label = 'Tager dykkerudstyr på',
        useWhileDead = false,
        canCancel = true,
        anim = {
			dict = 'clothingtie',
			clip = 'try_tie_negative_a',
			flags = 51,
        }
    }) then
        local itemData = lib.callback.await('mani-divingsystem:server:toggle', false, true, { slot = data.slot })
        toggleSettings(true)
        SendNUIMessage({
            type = "toggleHud",
            visible = true
        })
        startScubaLoop()
        SetOxygenLevel(itemData.metadata.oxygen or 1000)
    end
end)

exports('refillOxygen', function(data)
    if not scubaOn then return lib.notify({ title = 'Du har ikke dykkerudstyr på', type = 'error' }) end

    if not lib.progressActive() and lib.progressBar({
        duration = 4000,
        label = 'Refiller ilt tank',
        useWhileDead = false,
        canCancel = true,
        anim = {
			dict = 'clothingtie',
			clip = 'try_tie_negative_a',
			flags = 51,
        }
    }) then
        if data.slot then lib.callback.await('mani-divingsystem:server:removeTank', false, data.slot or nil) end
        SetOxygenLevel(1000)
    end
end)