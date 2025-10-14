<img width="2948" height="497" alt="rex_scripts" src="https://github.com/user-attachments/assets/bccc94d2-0702-48aa-9868-08b05cc2a8bd" />

# 🔨 Rex-Crafting

**A comprehensive and optimized crafting system for RedM servers using RSG-Core framework.**

---

## 📋 Table of Contents
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Exports API](#-exports-api)
- [Support](#-support)
- [Changelog](#-changelog)

---

## ✨ Features

### 🎯 Core Functionality
- **Dynamic NPC Spawning**: Proximity-based NPC management with fade animations
- **Category-Based Crafting**: Organized recipes by categories (Tools, Weapons, etc.)
- **XP Integration**: Crafting experience system with RSG-Core reputation
- **Multiple Locations**: 8 pre-configured crafting locations across the map
- **Dual Interaction**: Support for both prompt-based and ox_target interactions

### 🚀 Advanced Features
- **Detailed Missing Items**: Shows exactly what materials players need with quantities
- **Progress Bar Integration**: Visual crafting progress with ox_lib progress bars
- **Inventory Locking**: Prevents inventory manipulation during crafting
- **Comprehensive Validation**: Server-side ingredient verification
- **Automatic Logging**: Built-in crafting event logging with rsg-log
- **Version Checking**: Automatic update notifications

### 🔧 Performance Optimizations
- **Configurable Update Intervals**: Adjustable NPC spawn checking frequency
- **Non-Blocking Animations**: Asynchronous fade animations prevent script blocking
- **Memory Management**: Proper model cleanup and entity existence checks
- **Concurrent Limiting**: Configurable limits for simultaneous operations
- **Smart Caching**: Optimized menu registration and context management

### 🔌 Integration Features
- **15 Export Functions**: Comprehensive API for external script integration
- **Runtime Recipe Addition**: Add custom recipes dynamically
- **External Crafting Processing**: Complete crafting operations from other resources
- **Ingredient Validation**: Detailed missing items checking for other systems
- **XP Management**: Award and retrieve crafting experience externally

---

## 📋 Requirements

### Framework Dependencies
- **[RSG-Core](https://github.com/Rexshack-RedM/rsg-core)** - Core framework for RedM
- **[ox_lib](https://github.com/overextended/ox_lib)** - UI library for menus and notifications
- **[rsg-inventory](https://github.com/Rexshack-RedM/rsg-inventory)** - Inventory system

### Optional Dependencies
- **ox_target** - For targeted NPC interactions (if `Config.EnableTarget = true`)
- **rsg-log** - For crafting event logging

---

## 🚀 Installation

### Step 1: Download and Extract
1. Download the latest release
2. Extract `rex-crafting` to your server's `resources` folder

### Step 2: Install Dependencies
Ensure all required dependencies are installed and started before rex-crafting:
```cfg
# In your server.cfg
ensure rsg-core
ensure ox_lib
ensure rsg-inventory
# ... other dependencies
ensure rex-crafting
```

### Step 3: Add Items to RSG-Core
Add the items from `installation/shared_items.lua` to your `rsg-core/shared/items.lua`:

```lua
-- Example items to add
coal        = { name = 'coal',        label = 'Coal',        weight = 100,  type = 'item', image = 'coal.png',        unique = false, useable = false, shouldClose = true, description = 'Raw coal for crafting' },
steel_bar   = { name = 'steel_bar',   label = 'Steel Bar',   weight = 1000, type = 'item', image = 'steel_bar.png',   unique = false, useable = false, shouldClose = true, description = 'Refined steel ingot' },
wood        = { name = 'wood',        label = 'Wood',        weight = 100,  type = 'item', image = 'wood.png',        unique = false, useable = false, shouldClose = true, description = 'Basic crafting material' },
pickaxe     = { name = 'pickaxe',     label = 'Pickaxe',     weight = 100,  type = 'item', image = 'pickaxe.png',     unique = false, useable = false, shouldClose = true, description = 'Tool for mining' },
```

### Step 4: Add Item Images
Copy corresponding item images to your `rsg-inventory/html/images/` folder:
- `coal.png`
- `steel_bar.png`
- `wood.png`
- `bpc_pickaxe.png`
- `pickaxe.png`

### Step 5: Start the Resource
Add to your `server.cfg`:
```cfg
ensure rex-crafting
```

---

## ⚙️ Configuration

### Basic Settings (`config.lua`)
```lua
Config.Image = "rsg-inventory/html/images/"  -- Item image path
Config.Keybind = 'J'                        -- Prompt keybind
Config.EnableTarget = true                   -- Use ox_target instead of prompts
```

### NPC Settings
```lua
Config.DistanceSpawn = 20.0     -- NPC spawn distance
Config.FadeIn = true            -- Enable fade animations
```

### Performance Settings
```lua
Config.UpdateInterval = 1000        -- NPC distance check interval (ms)
Config.ModelTimeout = 5000          -- Model loading timeout (ms)
Config.MaxConcurrentFades = 5       -- Maximum simultaneous fade animations
```

### Adding Custom Recipes
```lua
Config.Crafting = {
    {
        category = 'Tools', -- Recipe category
        crafttime = 30000,  -- Crafting time in milliseconds
        craftingxp = 1,     -- XP reward
        ingredients = {
            { item = 'coal',      amount = 1 },
            { item = 'steel_bar', amount = 1 },
            { item = 'wood',      amount = 1 },
        },
        receive = 'pickaxe', -- Item to receive
        giveamount = 1       -- Quantity to give
    },
    -- Add more recipes here
}
```

### Adding Custom Locations
```lua
Config.CraftingLocations = {
    {
        name = 'My Custom Location',
        prompt = 'mycrafting',
        coords = vector3(x, y, z),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(x, y, z, heading),
        showblip = true
    },
}
```

---

## 🔌 Exports API

The resource provides 15 export functions for integration with other scripts.

### Client Exports
```lua
-- Open crafting menu
exports['rex-crafting']:OpenCraftingMenu()

-- Check proximity to crafting locations
local isNear, locationData = exports['rex-crafting']:IsNearCraftingLocation(25.0)

-- Get all recipes or filter by category
local allRecipes = exports['rex-crafting']:GetCraftingRecipes()
local toolRecipes = exports['rex-crafting']:GetCraftingRecipes('Tools')

-- Find recipe for specific item
local recipe = exports['rex-crafting']:GetRecipeByItem('pickaxe')
```

### Server Exports
```lua
-- Validate player ingredients
local result = exports['rex-crafting']:CheckPlayerIngredients(source, ingredients)
if not result.success then
    -- Handle missing items: result.missingItems
end

-- Process complete crafting operation
local craftResult = exports['rex-crafting']:ProcessCrafting(source, craftData)

-- Manage player XP
local xp = exports['rex-crafting']:GetPlayerCraftingXP(source)
exports['rex-crafting']:GivePlayerCraftingXP(source, 5)

-- Add custom recipes at runtime
exports['rex-crafting']:AddCustomRecipe(customRecipe)
```

---

## 🎮 Usage

### For Players
1. **Approach any crafting location** (marked with blacksmith blips)
2. **Press J** (default) or **use ox_target** to open crafting menu
3. **Select category** and choose item to craft
4. **Ensure you have**:
   - All necessary ingredients
   - Sufficient crafting XP
5. **Wait for progress bar** to complete
6. **Receive your crafted item** and XP reward

### For Developers
- Use the comprehensive exports API for integration
- Add custom recipes via configuration or runtime
- Leverage ingredient validation for other systems
- Hook into crafting events for additional functionality

---

## 🛠️ Support

### Community
- **Discord**: [https://discord.gg/YUV7ebzkqs](https://discord.gg/YUV7ebzkqs)
- **YouTube**: [https://www.youtube.com/@rexshack/videos](https://www.youtube.com/@rexshack/videos)

### Commercial
- **Tebex Store**: [https://rexshackgaming.tebex.io/](https://rexshackgaming.tebex.io/)

### Issues and Feature Requests
For bug reports and feature requests, please join our Discord community.

---

## 📝 Changelog

### Version 2.1.0+ (Enhanced)
#### 🆕 New Features
- **Detailed Missing Items Notifications**: Players see exactly what materials they need
- **Comprehensive Exports API**: 15 functions for external script integration
- **Runtime Recipe Management**: Add/modify recipes dynamically
- **Performance Optimization**: Configurable intervals and non-blocking operations

#### 🐛 Bug Fixes
- **Progress Bar Race Condition**: Fixed inventory unlock timing
- **Memory Leaks**: Proper NPC cleanup and model management
- **XP Calculation**: Corrected double XP addition bug
- **Item Validation**: Added null checks for missing items
- **Ingredient Logic**: Improved server-side validation

#### ⚡ Performance Improvements
- **NPC Spawning**: Reduced update frequency (500ms → 1000ms configurable)
- **Animation System**: Non-blocking fade in/out animations
- **Menu Registration**: One-time context registration
- **Memory Management**: Automatic model cleanup
- **Concurrent Limiting**: Configurable fade animation limits

#### 🔒 Security Enhancements
- **Server-side Validation**: Double-checking ingredients before processing
- **Data Sanitization**: Improved validation of client data
- **Transaction Safety**: Rollback protection for failed operations
- **Error Handling**: Comprehensive validation with detailed logging

---

## 📄 License

Custom license - See Discord for terms and conditions.

---

**Made with ❤️ by RexShack Gaming**
