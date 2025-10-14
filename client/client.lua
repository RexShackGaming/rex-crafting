local RSGCore = exports['rsg-core']:GetCoreObject()
local CategoryMenus = {}
local MenusRegistered = false
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
local function BuildCraftingMenus()
    CategoryMenus = {} -- Reset menus
    MenusRegistered = false -- Reset registration flag
    
    for _, v in ipairs(Config.Crafting) do
        local IngredientsMetadata = {}
        
        -- Validate item exists before accessing
        local receivedItem = RSGCore.Shared.Items[tostring(v.receive)]
        if not receivedItem then
            print("^1[ERROR] Item '" .. tostring(v.receive) .. "' not found in RSGCore.Shared.Items^7")
            goto continue
        end
        
        local setheader = receivedItem.label
        local itemimg = "nui://"..Config.Image..receivedItem.image

        for i, ingredient in ipairs(v.ingredients) do
            local ingredientItem = RSGCore.Shared.Items[ingredient.item]
            if ingredientItem then
                table.insert(IngredientsMetadata, { label = ingredientItem.label, value = ingredient.amount })
            else
                print("^1[ERROR] Ingredient '" .. ingredient.item .. "' not found in RSGCore.Shared.Items^7")
            end
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
                requiredxp = v.requiredxp,
                xpreward = v.xpreward,
                receive = v.receive,
                giveamount = v.giveamount,
                requiredjob = v.requiredjob
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
        
        ::continue::
    end
end

-- Build initial menus
CreateThread(function()
    BuildCraftingMenus()
end)

-- Register category events only once
local function RegisterCategoryMenus()
    if MenusRegistered then return end
    
    for category, MenuData in pairs(CategoryMenus) do
        RegisterNetEvent('rex-crafting:client:' .. category)
        AddEventHandler('rex-crafting:client:' .. category, function()
            lib.registerContext(MenuData)
            lib.showContext(MenuData.id)
        end)
    end
    
    MenusRegistered = true
end

-- Register menus after they're built
CreateThread(function()
    Wait(100) -- Small delay to ensure CategoryMenus is populated
    RegisterCategoryMenus()
end)

-- Filter recipes based on player's job
local function GetJobFilteredRecipes()
    RSGCore.Functions.TriggerCallback('rex-crafting:server:getplayerjob', function(playerJob)
        local filteredCategoryMenus = {}
        
        for _, v in ipairs(Config.Crafting) do
            -- Skip if recipe requires a job that player doesn't have
            if v.requiredjob and v.requiredjob ~= playerJob then
                goto continue
            end
            
            local IngredientsMetadata = {}
            
            -- Validate item exists before accessing
            local receivedItem = RSGCore.Shared.Items[tostring(v.receive)]
            if not receivedItem then
                goto continue
            end
            
            local setheader = receivedItem.label
            local itemimg = "nui://"..Config.Image..receivedItem.image

            for i, ingredient in ipairs(v.ingredients) do
                local ingredientItem = RSGCore.Shared.Items[ingredient.item]
                if ingredientItem then
                    table.insert(IngredientsMetadata, { label = ingredientItem.label, value = ingredient.amount })
                end
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
                    requiredxp = v.requiredxp,
                    xpreward = v.xpreward,
                    receive = v.receive,
                    giveamount = v.giveamount,
                    requiredjob = v.requiredjob
                }
            }

            if not filteredCategoryMenus[v.category] then
                filteredCategoryMenus[v.category] = {
                    id = 'crafting_menu_' .. v.category,
                    title = v.category,
                    menu = 'crafting_menu',
                    onBack = function() end,
                    options = { option }
                }
            else
                table.insert(filteredCategoryMenus[v.category].options, option)
            end
            
            ::continue::
        end
        
        -- Register filtered menus
        for category, MenuData in pairs(filteredCategoryMenus) do
            RegisterNetEvent('rex-crafting:client:' .. category)
            AddEventHandler('rex-crafting:client:' .. category, function()
                lib.registerContext(MenuData)
                lib.showContext(MenuData.id)
            end)
        end
        
        -- Show main menu
        local Menu = {
            id = 'crafting_menu',
            title = locale('cl_lang_3'),
            options = {}
        }

        for category, MenuData in pairs(filteredCategoryMenus) do
            table.insert(Menu.options, {
                title = category,
                event = 'rex-crafting:client:' .. category,
                arrow = true
            })
        end

        if #Menu.options == 0 then
            lib.notify({ title = 'No Recipes Available', description = 'You don\'t have access to any crafting recipes.', type = 'inform', duration = 5000 })
            return
        end

        lib.registerContext(Menu)
        lib.showContext(Menu.id)
    end)
end

RegisterNetEvent('rex-crafting:client:craftingmenu', function()
    GetJobFilteredRecipes()
end)

---------------------------------------------
-- craft item
---------------------------------------------
RegisterNetEvent('rex-crafting:client:craftitem', function(data)
    RSGCore.Functions.TriggerCallback('rex-crafting:server:checkxp', function(currentXP)
        if currentXP >= (data.requiredxp or 0) then
            -- check crafting items and job requirements
            RSGCore.Functions.TriggerCallback('rex-crafting:server:checkingredients', function(result)
                if result.jobRestricted then
                    lib.notify({ 
                        title = 'Job Required', 
                        description = 'You need to be a ' .. result.requiredJob .. ' to craft this item.', 
                        type = 'error', 
                        duration = 7000 
                    })
                    return
                elseif result.success == true then
                    LocalPlayer.state:set("inv_busy", true, true) -- lock inventory
                    
                    -- Validate item exists before accessing
                    local itemData = RSGCore.Shared.Items[data.receive]
                    if not itemData then
                        print("^1[ERROR] Crafted item '" .. data.receive .. "' not found in RSGCore.Shared.Items^7")
                        LocalPlayer.state:set("inv_busy", false, true)
                        return
                    end
                    
                    local success = lib.progressBar({
                        duration = tonumber(data.crafttime),
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disableControl = true,
                        disable = {
                            move = true,
                            mouse = true,
                        },
                        label = locale('cl_lang_4').. itemData.label,
                    })
                    
                    if success then
                        TriggerServerEvent('rex-crafting:server:finishcrafting', data)
                    end
                    
                    LocalPlayer.state:set("inv_busy", false, true) -- unlock inventory
                else
                    -- Show detailed missing items notification
                    local function ShowMissingItemsNotification(missingItems)
                        if not missingItems or #missingItems == 0 then
                            lib.notify({ title = locale('cl_lang_5'), type = 'error', duration = 7000 })
                            return
                        end
                        
                        local missingText = locale('cl_lang_8') .. "\n"
                        
                        for i, missing in ipairs(missingItems) do
                            if missing.have > 0 then
                                -- Player has some but not enough
                                missingText = missingText .. string.format(locale('cl_lang_9'), 
                                    missing.missing, missing.label, missing.have, missing.need)
                            else
                                -- Player has none
                                missingText = missingText .. string.format(locale('cl_lang_10'), 
                                    missing.need, missing.label)
                            end
                            
                            if i < #missingItems then
                                missingText = missingText .. "\n"
                            end
                        end
                        
                        lib.notify({ 
                            description = missingText, 
                            type = 'error', 
                            duration = 10000 -- Longer duration for detailed info
                        })
                    end
                    
                    ShowMissingItemsNotification(result.missingItems)
                end
            end, data.ingredients, data.requiredjob)
        else
            local requiredXP = data.requiredxp or 0
            lib.notify({ 
                title = 'Insufficient Experience', 
                description = 'You need ' .. requiredXP .. ' XP to craft this item. Current XP: ' .. currentXP, 
                type = 'error', 
                duration = 7000 
            })
        end
    end, 'crafting')
end)

---------------------------------------------
-- CLIENT EXPORTS
---------------------------------------------

-- Open crafting menu programmatically
exports('OpenCraftingMenu', function()
    TriggerEvent('rex-crafting:client:craftingmenu')
end)

-- Check if player is near a crafting location
exports('IsNearCraftingLocation', function(maxDistance)
    local playerCoords = GetEntityCoords(cache.ped)
    local checkDistance = maxDistance or Config.DistanceSpawn
    
    for k, v in pairs(Config.CraftingLocations) do
        local distance = #(playerCoords - v.coords)
        if distance <= checkDistance then
            return true, {
                id = k,
                name = v.name,
                coords = v.coords,
                distance = distance
            }
        end
    end
    
    return false, nil
end)

-- Get all crafting locations
exports('GetCraftingLocations', function()
    return Config.CraftingLocations
end)

-- Get crafting recipes by category
exports('GetCraftingRecipes', function(category)
    if not category then
        return Config.Crafting
    end
    
    local recipes = {}
    for _, recipe in ipairs(Config.Crafting) do
        if recipe.category == category then
            table.insert(recipes, recipe)
        end
    end
    
    return recipes
end)

-- Get all available categories
exports('GetCraftingCategories', function()
    local categories = {}
    local seen = {}
    
    for _, recipe in ipairs(Config.Crafting) do
        if not seen[recipe.category] then
            table.insert(categories, recipe.category)
            seen[recipe.category] = true
        end
    end
    
    return categories
end)

-- Check if a specific recipe exists
exports('GetRecipeByItem', function(itemName)
    for _, recipe in ipairs(Config.Crafting) do
        if recipe.receive == itemName then
            return recipe
        end
    end
    
    return nil
end)

-- Get recipe ingredients with labels
exports('GetRecipeIngredients', function(itemName)
    local recipe = exports['rex-crafting']:GetRecipeByItem(itemName)
    if not recipe then return nil end
    
    local ingredients = {}
    for _, ingredient in ipairs(recipe.ingredients) do
        local itemData = RSGCore.Shared.Items[ingredient.item]
        table.insert(ingredients, {
            item = ingredient.item,
            amount = ingredient.amount,
            label = itemData and itemData.label or ingredient.item
        })
    end
    
    return ingredients
end)
