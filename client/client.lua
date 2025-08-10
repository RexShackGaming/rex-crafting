local RSGCore = exports['rsg-core']:GetCoreObject()
local CategoryMenus = {}
lib.locale()

--------------------------------------
-- prompts and blips
--------------------------------------
Citizen.CreateThread(function()
    for _,v in pairs(Config.CraftingLocations) do
        if not Config.EnableTarget then
            exports['rsg-core']:createPrompt(v.prompt, v.coords, RSGCore.Shared.Keybinds[Config.Keybind], locale('cl_lang_1'), {
                type = 'client',
                event = 'rex-crafting:client:craftingmenu'
            })
        end
        if v.showblip == true then    
            local CraftingBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(CraftingBlip, joaat('blip_shop_blacksmith'), true)
            SetBlipScale(CraftingBlip, 0.2)
            SetBlipName(CraftingBlip, locale('cl_lang_2'))
        end
    end
end)

---------------------------------------------
-- crafting menu
---------------------------------------------
CreateThread(function()
    for _, v in ipairs(Config.Crafting) do
        local IngredientsMetadata = {}
        local setheader = RSGCore.Shared.Items[tostring(v.receive)].label
        local itemimg = "nui://"..Config.Image..RSGCore.Shared.Items[tostring(v.receive)].image

        for i, ingredient in ipairs(v.ingredients) do
            table.insert(IngredientsMetadata, { label = RSGCore.Shared.Items[ingredient.item].label, value = ingredient.amount })
        end

        local option = {
            title = setheader,
            icon = itemimg,
            event = 'rex-crafting:client:craftitem',
            metadata = IngredientsMetadata,
            args = {
                title = setheader,
                category = v.category,
                ingredients = v.ingredients,
                crafttime = v.crafttime,
                craftingxp = v.craftingxp,
                bpc = v.bpc,
                receive = v.receive,
                giveamount = v.giveamount
            }
        }

        if not CategoryMenus[v.category] then
            CategoryMenus[v.category] = {
                id = 'crafting_menu_' .. v.category,
                title = v.category,
                menu = 'crafting_menu',
                onBack = function() end,
                options = { option }
            }
        else
            table.insert(CategoryMenus[v.category].options, option)
        end
    end
end)

CreateThread(function()
    for category, MenuData in pairs(CategoryMenus) do
        RegisterNetEvent('rex-crafting:client:' .. category)
        AddEventHandler('rex-crafting:client:' .. category, function()
            lib.registerContext(MenuData)
            lib.showContext(MenuData.id)
        end)
    end
end)

RegisterNetEvent('rex-crafting:client:craftingmenu', function()
    local Menu = {
        id = 'crafting_menu',
        title = locale('cl_lang_3'),
        options = {}
    }

    for category, MenuData in pairs(CategoryMenus) do
        table.insert(Menu.options, {
            title = category,
            event = 'rex-crafting:client:' .. category,
            arrow = true
        })
    end

    lib.registerContext(Menu)
    lib.showContext(Menu.id)
end)

---------------------------------------------
-- craft item
---------------------------------------------
RegisterNetEvent('rex-crafting:client:craftitem', function(data)
    local hasItem = RSGCore.Functions.HasItem(data.bpc, 1)
    if hasItem then
        -- check crafting rep
        RSGCore.Functions.TriggerCallback('rex-crafting:server:checkxp', function(currentXP)
            if currentXP >= data.craftingxp then
                -- check crafting items
                RSGCore.Functions.TriggerCallback('rex-crafting:server:checkingredients', function(hasRequired)
                    if hasRequired == true then
                        LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
                        lib.progressBar({
                            duration = tonumber(data.crafttime),
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = false,
                            disableControl = true,
                            disable = {
                                move = true,
                                mouse = true,
                            },
                            label = locale('cl_lang_4').. RSGCore.Shared.Items[data.receive].label,
                        })
                        TriggerServerEvent('rex-crafting:server:finishcrafting', data)
                        LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
                    else
                        lib.notify({ title = locale('cl_lang_5'), type = 'inform', duration = 7000 })
                    end
                end, data.ingredients)
            else
                lib.notify({ title = locale('cl_lang_6'), type = 'error', duration = 7000 })
            end
        end, 'crafting')
    else
        lib.notify({ title = RSGCore.Shared.Items[data.bpc].label..locale('cl_lang_7'), type = 'error', duration = 7000 })
    end
end)
