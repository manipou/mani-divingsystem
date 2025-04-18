lib.callback.register('mani-divingsystem:server:toggle', function(src, toggle, data)
    if toggle then
        local itemData = exports['ox_inventory']:GetSlot(src, data.slot)
        exports['ox_inventory']:RemoveItem(src, 'scuba_set', 1, nil, data.slot)
        return itemData
    else
        exports['ox_inventory']:AddItem(src, 'scuba_set', 1, { ['oxygen'] = data.oxygen, ['description'] = ('Ilt: %s'):format(math.floor(data.oxygen / 10) .. '%') })
    end
end)

lib.callback.register('mani-divingsystem:server:removeTank', function(src, slot)
    exports['ox_inventory']:RemoveItem(src, 'scuba_tank', 1, nil, slot)
end)