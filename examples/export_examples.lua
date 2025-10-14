-- Example script demonstrating rex-crafting exports
-- This file shows how other resources can integrate with rex-crafting

print("^2=== REX-CRAFTING EXPORTS EXAMPLES ===^7")

-- CLIENT-SIDE EXAMPLES (use in client scripts)
if IsDuplicityVersion() == false then -- Client-side only
    
    print("^3--- CLIENT EXPORTS EXAMPLES ---^7")
    
    -- Example 1: Check if player is near crafting location
    CreateThread(function()
        while true do
            Wait(5000) -- Check every 5 seconds
            
            local isNear, locationData = exports['rex-crafting']:IsNearCraftingLocation(25.0)
            if isNear then
                print("^2Player is near: " .. locationData.name .. " (Distance: " .. math.floor(locationData.distance) .. "m)^7")
            end
        end
    end)
    
    -- Example 2: Get all crafting categories
    local function ShowCraftingInfo()
        local categories = exports['rex-crafting']:GetCraftingCategories()
        print("^3Available crafting categories:^7")
        for _, category in ipairs(categories) do
            print("  - " .. category)
            
            -- Get recipes in this category
            local recipes = exports['rex-crafting']:GetCraftingRecipes(category)
            for _, recipe in ipairs(recipes) do
                print("    → " .. recipe.receive .. " (requires " .. #recipe.ingredients .. " ingredients)")
            end
        end
    end
    
    -- Example 3: Custom command to show crafting info
    RegisterCommand('craftinginfo', function()
        ShowCraftingInfo()
    end, false)
    
    -- Example 4: Custom command to open crafting menu anywhere
    RegisterCommand('craft', function()
        exports['rex-crafting']:OpenCraftingMenu()
    end, false)
    
    -- Example 5: Get recipe details
    RegisterCommand('recipe', function(source, args)
        if not args[1] then
            print("^1Usage: /recipe <item_name>^7")
            return
        end
        
        local itemName = args[1]
        local recipe = exports['rex-crafting']:GetRecipeByItem(itemName)
        
        if recipe then
            print("^2Recipe found for " .. itemName .. ":^7")
            print("  Category: " .. recipe.category)
            print("  Craft time: " .. recipe.crafttime .. "ms")
            print("  XP reward: " .. recipe.craftingxp)
            
            local ingredients = exports['rex-crafting']:GetRecipeIngredients(itemName)
            print("  Ingredients:")
            for _, ingredient in ipairs(ingredients) do
                print("    - " .. ingredient.amount .. "x " .. ingredient.label)
            end
        else
            print("^1No recipe found for " .. itemName .. "^7")
        end
    end, false)
    
end

-- SERVER-SIDE EXAMPLES (use in server scripts)
if IsDuplicityVersion() then -- Server-side only
    
    print("^3--- SERVER EXPORTS EXAMPLES ---^7")
    
    -- Example 1: Check player ingredients command
    RegisterCommand('checkingredients', function(source, args)
        if source == 0 then return end -- Console only
        
        -- Example ingredients to check
        local testIngredients = {
            { item = 'coal', amount = 5 },
            { item = 'steel_bar', amount = 2 }
        }
        
        local result = exports['rex-crafting']:CheckPlayerIngredients(source, testIngredients)
        
        if result.success then
            print("^2Player " .. source .. " has all required ingredients^7")
        else
            print("^1Player " .. source .. " is missing ingredients:^7")
            for _, missing in ipairs(result.missingItems) do
                print("  - " .. missing.missing .. "x " .. missing.label .. " (has " .. missing.have .. "/" .. missing.need .. ")")
            end
        end
    end, true)
    
    -- Example 2: Give crafting XP command
    RegisterCommand('givecraftxp', function(source, args)
        if source ~= 0 then return end -- Console only
        
        local targetId = tonumber(args[1])
        local xpAmount = tonumber(args[2]) or 10
        
        if not targetId then
            print("Usage: givecraftxp <player_id> [amount]")
            return
        end
        
        local success = exports['rex-crafting']:GivePlayerCraftingXP(targetId, xpAmount)
        if success then
            print("^2Gave " .. xpAmount .. " crafting XP to player " .. targetId .. "^7")
        else
            print("^1Failed to give XP to player " .. targetId .. "^7")
        end
    end, true)
    
    -- Example 3: Add custom recipe at runtime
    local function AddExampleRecipe()
        local customRecipe = {
            category = 'Examples',
            crafttime = 15000,
            craftingxp = 5,
            bpc = 'bpc_example_item',
            ingredients = {
                { item = 'coal', amount = 2 },
                { item = 'wood', amount = 3 }
            },
            receive = 'example_crafted_item',
            giveamount = 1
        }
        
        local success, message = exports['rex-crafting']:AddCustomRecipe(customRecipe)
        print("^3Custom recipe result: " .. message .. "^7")
    end
    
    -- Add the custom recipe when resource starts
    CreateThread(function()
        Wait(5000) -- Wait for rex-crafting to fully load
        AddExampleRecipe()
    end)
    
    -- Example 4: External crafting system
    RegisterNetEvent('example:craft-external')
    AddEventHandler('example:craft-external', function(itemName)
        local source = source
        
        -- Check if item can be crafted
        local canCraft, recipe = exports['rex-crafting']:CanCraftItem(itemName)
        
        if not canCraft then
            TriggerClientEvent('chat:addMessage', source, {
                args = { '^1Error', 'No recipe exists for ' .. itemName }
            })
            return
        end
        
        -- Use the ProcessCrafting export to handle everything
        local result = exports['rex-crafting']:ProcessCrafting(source, recipe)
        
        if result.success then
            TriggerClientEvent('chat:addMessage', source, {
                args = { '^2Success', 'Crafted ' .. itemName .. ' successfully!' }
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = { '^1Error', 'Crafting failed: ' .. result.error }
            })
        end
    end)
    
    -- Example 5: Get player's current crafting level
    RegisterCommand('craftlevel', function(source, args)
        if source == 0 then return end
        
        local xp = exports['rex-crafting']:GetPlayerCraftingXP(source)
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^3Crafting', 'Your crafting XP: ' .. xp }
        })
    end, false)
    
end

print("^2=== EXPORT EXAMPLES LOADED ===^7")
