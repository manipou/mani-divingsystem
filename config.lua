local Config = {}

Config.OxygenConsumption = 2

Config.Gender = {
    [GetHashKey('mp_m_freemode_01')] = 'Male',
    [GetHashKey('mp_f_freemode_01')] = 'Female',
}

Config.GetSkin = function() -- Skin is the only function using my Bridge - Changing this to your clothing script, and you wouldnt need a whole bridge for this resource
    return exports['mani-bridge']:GetSkin(false)
end

Config.SetSkin = function(ped, skin)
    exports['mani-bridge']:SetSkin(ped, skin)
end

return Config
