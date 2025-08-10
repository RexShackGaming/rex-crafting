local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

---------------------------------------------
-- increase xp fuction
---------------------------------------------
local function IncreasePlayerXP(source, xpGain, xpType)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player then
        local currentXP = Player.Functions.GetRep(xpType)
        local newXP = currentXP + xpGain
        Player.Functions.AddRep(xpType, newXP)
        TriggerClientEvent('ox_lib:notify', source, { title = string.format(locale('sv_lang_3'), xpGain, xpType), type = 'inform', duration = 7000 })
    end
end

---------------------------------------------
-- check player xp
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-crafting:server:checkxp', function(source, cb, xptype)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player then
        local currentXP = Player.Functions.GetRep(xptype)
        cb(currentXP)
    end
end)

---------------------------------------------
-- check player has the ingredients
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-crafting:server:checkingredients', function(source, cb, ingredients)
    local src = source
    local hasItems = false
    local icheck = 0
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    for k, v in pairs(ingredients) do
        if exports['rsg-inventory']:GetItemCount(src, v.item) >= v.amount then
            icheck = icheck + 1
            if icheck == #ingredients then
                cb(true)
            end
        else
            cb(false)
        end
    end
end)

---------------------------------------------
-- finish crafting / give item
---------------------------------------------
RegisterNetEvent('rex-crafting:server:finishcrafting', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
    local receive = data.receive
    local giveamount = data.giveamount
    for k, v in pairs(data.ingredients) do
        Player.Functions.RemoveItem(v.item, v.amount)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[v.item], 'remove', v.amount)
    end
    Player.Functions.AddItem(receive, giveamount)
    Player.Functions.RemoveItem(data.bpc, 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[data.bpc], 'remove', 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[receive], 'add', giveamount)
    IncreasePlayerXP(src, 1, 'crafting')
    TriggerEvent('rsg-log:server:CreateLog', 'crafting', locale('sv_lang_1'), 'green', firstname..' '..lastname..' ('..citizenid..locale('sv_lang_2')..RSGCore.Shared.Items[receive].label)
end)
