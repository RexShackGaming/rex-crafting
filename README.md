<img width="2948" height="497" alt="rex_scripts" src="https://github.com/user-attachments/assets/bccc94d2-0702-48aa-9868-08b05cc2a8bd" />

# 🔨 Rex-Crafting

**An advanced job-based crafting system with XP progression for RedM servers using RSG-Core framework.**

---

## 📋 Table of Contents
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Job-Based Crafting](#-job-based-crafting)
- [XP Progression System](#-xp-progression-system)
- [Exports API](#-exports-api)
- [Usage](#-usage)
- [Migration Guide](#-migration-guide)
- [Support](#-support)
- [Changelog](#-changelog)

---

## ✨ Features

### 🎯 Core Functionality
- **Dynamic NPC Spawning**: Proximity-based NPC management with fade animations
- **Category-Based Crafting**: Organized recipes by categories (Tools, Weapons, etc.)
- **Job-Based Restrictions**: Restrict recipes to specific RSG-Core jobs (blacksmith, gunsmith, etc.)
- **XP Progression System**: Separate XP requirements and rewards for advanced crafting
- **Multiple Locations**: 8 pre-configured crafting locations across the map
- **Dual Interaction**: Support for both prompt-based and ox_target interactions

### 🚀 Advanced Features
- **Job Integration**: Only blacksmiths can craft weapons, doctors can craft medicine, etc.
- **Experience Gating**: Advanced items require crafting experience to unlock
- **Dynamic Menu Filtering**: Players only see recipes they can actually craft
- **Detailed Missing Items**: Shows exactly what materials players need with quantities
- **Progress Bar Integration**: Visual crafting progress with ox_lib progress bars
- **Inventory Locking**: Prevents inventory manipulation during crafting
- **Comprehensive Validation**: Server-side ingredient and job verification
- **Automatic Logging**: Built-in crafting event logging with rsg-log
- **Version Checking**: Automatic update notifications

### 🔧 Performance Optimizations
- **Configurable Update Intervals**: Adjustable NPC spawn checking frequency
- **Non-Blocking Animations**: Asynchronous fade animations prevent script blocking
- **Memory Management**: Proper model cleanup and entity existence checks
- **Concurrent Limiting**: Configurable limits for simultaneous operations
- **Smart Caching**: Optimized menu registration and context management

### 🔌 Integration Features
- **20+ Export Functions**: Comprehensive API for external script integration
- **Job-Based APIs**: Check player jobs, get job-specific recipes, validate permissions
- **Runtime Recipe Addition**: Add custom recipes with job restrictions dynamically
- **External Crafting Processing**: Complete crafting operations with job validation
- **Ingredient Validation**: Detailed missing items checking for other systems
- **XP Management**: Award and retrieve crafting experience with progression tracking
- **Backward Compatibility**: Seamless migration from older crafting systems

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
    -- Basic recipe - anyone can craft
    {
        category = 'Tools',       -- Recipe category
        crafttime = 30000,        -- Crafting time in milliseconds
        requiredxp = 0,           -- XP required to craft (0 = no requirement)
        xpreward = 5,             -- XP gained after crafting
        requiredjob = nil,        -- Job required (nil = anyone can craft)
        ingredients = {
            { item = 'coal',      amount = 1 },
            { item = 'steel_bar', amount = 1 },
            { item = 'wood',      amount = 1 },
        },
        receive = 'pickaxe',      -- Item to receive
        giveamount = 1            -- Quantity to give
    },
    
    -- Job-restricted recipe - only blacksmiths
    {
        category = 'Blacksmith',
        crafttime = 45000,
        requiredxp = 25,          -- Need 25 XP to craft
        xpreward = 10,            -- Gain 10 XP after crafting
        requiredjob = 'blacksmith', -- Only blacksmiths can craft
        ingredients = {
            { item = 'coal',      amount = 3 },
            { item = 'steel_bar', amount = 2 },
        },
        receive = 'weapon_melee_knife02',
        giveamount = 1
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

## 👥 Job-Based Crafting

The enhanced system allows you to restrict crafting recipes to specific RSG-Core jobs, creating a more realistic and balanced economy.

### Supported Job Types
- `'blacksmith'` - Metalworking and weapon crafting
- `'gunsmith'` - Advanced weapon and ammunition crafting
- `'doctor'` - Medical supplies and remedies
- `'hunter'` - Hunting and trapping equipment
- `'miner'` - Mining tools and equipment
- `'farmer'` - Agricultural tools and supplies
- **Custom jobs** - Any job defined in your RSG-Core setup
- `nil` - No job restriction (anyone can craft)

### Job Restriction Examples

```lua
-- Only blacksmiths can craft weapons
{
    category = 'Weapons',
    requiredjob = 'blacksmith',
    ingredients = { { item = 'steel_bar', amount = 5 } },
    receive = 'weapon_melee_knife02',
    -- ... other properties
},

-- Only doctors can craft medical supplies
{
    category = 'Medical',
    requiredjob = 'doctor',
    ingredients = { { item = 'herbs', amount = 3 } },
    receive = 'health_tonic',
    -- ... other properties
},

-- Anyone can craft basic items
{
    category = 'Basic Tools',
    requiredjob = nil, -- No restriction
    ingredients = { { item = 'wood', amount = 2 } },
    receive = 'basic_hammer',
    -- ... other properties
}
```

### Dynamic Menu Filtering

Players automatically see only the recipes they can craft based on their current job:
- **Blacksmiths** see weapon and tool categories
- **Doctors** see medical supply categories
- **Unemployed** players see only unrestricted recipes
- **Job switching** immediately updates available recipes

### Security Features

- **Server-side validation**: All job checks happen on the server
- **Exploit prevention**: Impossible to bypass job restrictions client-side
- **Real-time verification**: Job status checked at time of crafting
- **Comprehensive logging**: All crafting attempts logged with job information

---

## 🎆 XP Progression System

The enhanced XP system separates experience requirements from experience rewards, allowing for sophisticated crafting progression.

### XP Fields

- **`requiredxp`**: XP needed to unlock this recipe (0 = no requirement)
- **`xpreward`**: XP gained after successfully crafting this item

### Progression Examples

#### Beginner Level (0 XP required)
```lua
{
    category = 'Novice Blacksmith',
    requiredxp = 0,      -- Anyone can start here
    xpreward = 5,        -- Small reward to build experience
    receive = 'iron_nail',
    -- ... other properties
}
```

#### Intermediate Level (25 XP required)
```lua
{
    category = 'Apprentice Blacksmith',
    requiredxp = 25,     -- Need some experience first
    xpreward = 10,       -- Better reward
    receive = 'weapon_melee_knife02',
    -- ... other properties
}
```

#### Master Level (100 XP required)
```lua
{
    category = 'Master Blacksmith',
    requiredxp = 100,    -- High experience requirement
    xpreward = 25,       -- Excellent reward
    receive = 'legendary_sword',
    -- ... other properties
}
```

### Player Experience

- **Clear Progression**: Players see exactly what XP they need vs. what they'll gain
- **Meaningful Rewards**: Advanced recipes provide better XP rewards
- **Skill Gates**: High-value items require investment in crafting skill
- **Visual Feedback**: Enhanced notifications show XP requirements and current progress

### Backward Compatibility

Existing recipes using `craftingxp` continue to work:
- `craftingxp = 10` automatically becomes both requirement and reward
- Gradual migration supported - update recipes at your own pace
- No breaking changes to existing functionality

---

## 🔌 Exports API

The resource provides 20+ export functions for comprehensive integration with other scripts.

### Client Exports
```lua
-- Open crafting menu (with job filtering)
exports['rex-crafting']:OpenCraftingMenu()

-- Check proximity to crafting locations
local isNear, locationData = exports['rex-crafting']:IsNearCraftingLocation(25.0)

-- Get all recipes or filter by category
local allRecipes = exports['rex-crafting']:GetCraftingRecipes()
local toolRecipes = exports['rex-crafting']:GetCraftingRecipes('Tools')

-- Find recipe for specific item
local recipe = exports['rex-crafting']:GetRecipeByItem('pickaxe')

-- Get recipe ingredients with labels
local ingredients = exports['rex-crafting']:GetRecipeIngredients('weapon_melee_knife02')
```

### Server Exports - Basic Functions
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

### Server Exports - Job-Based Functions
```lua
-- Check if player has required job
local canCraft = exports['rex-crafting']:CheckPlayerJob(source, 'blacksmith')

-- Get player's current job
local playerJob = exports['rex-crafting']:GetPlayerJob(source)

-- Check job requirement for specific item
local requiredJob = exports['rex-crafting']:GetRecipeJobRequirement('weapon_melee_knife02')

-- Get all recipes available to a specific job
local blacksmithRecipes = exports['rex-crafting']:GetRecipesByJob('blacksmith')

-- Enhanced crafting with automatic job validation
local result = exports['rex-crafting']:ProcessCraftingWithJobCheck(source, craftData)
if not result.success then
    if result.error == 'Job requirement not met' then
        print('Player needs job:', result.requiredJob)
        print('Player has job:', result.playerJob)
    end
end
```

### Additional Documentation

**Full API documentation and testing commands available in the examples folder.**

---

## 🎮 Usage

### For Players
1. **Get the right job** - Become a blacksmith, doctor, etc. for specialized recipes
2. **Build experience** - Start with basic recipes to gain crafting XP
3. **Approach any crafting location** (marked with blacksmith blips)
4. **Press J** (default) or **use ox_target** to open crafting menu
5. **Select category** - Only see recipes available to your job and XP level
6. **Choose item to craft** and ensure you have:
   - All necessary ingredients
   - Required job (if any)
   - Sufficient crafting XP
7. **Wait for progress bar** to complete
8. **Receive your crafted item** and XP reward

### Job Progression Examples
- **Unemployed**: Craft basic tools and items to build initial XP
- **Novice Blacksmith**: Start with simple metal items (nails, horseshoes)
- **Experienced Blacksmith**: Unlock weapon crafting and advanced tools
- **Master Craftsman**: Access legendary items and maximum XP rewards

### For Developers
- Use the comprehensive exports API for integration
- Add custom recipes with job restrictions via configuration or runtime
- Leverage job validation and ingredient checking for other systems
- Hook into crafting events for additional functionality
- Create progression systems using the XP requirements/rewards

---

## 🔄 Migration Guide

### From Standard Rex-Crafting

The enhanced system is fully backward compatible. No immediate changes required!

#### Option 1: Keep Current Setup (No Changes)
- Existing recipes continue working exactly as before
- `craftingxp` field still supported (used for both requirement and reward)
- All current functionality preserved

#### Option 2: Gradual Enhancement (Recommended)
1. **Start with XP separation**:
   ```lua
   -- Old format (still works)
   craftingxp = 10
   
   -- New format (enhanced)
   requiredxp = 25,  -- XP needed to craft
   xpreward = 10,    -- XP gained after crafting
   ```

2. **Add job restrictions gradually**:
   ```lua
   -- Add to specific recipes
   requiredjob = 'blacksmith',  -- Restrict to blacksmiths
   -- or
   requiredjob = nil,           -- Keep unrestricted
   ```

3. **Test and adjust** progression balancing

#### Option 3: Full Enhancement
1. Update all recipes with new XP fields
2. Add job restrictions where appropriate
3. Create progression tiers (novice → apprentice → master)
4. Balance XP requirements and rewards

### Migration Checklist

- [ ] **Backup current config** before making changes
- [ ] **Test with one recipe** first to ensure compatibility
- [ ] **Update RSG-Core jobs** if using custom job names
- [ ] **Inform players** about new job-based crafting
- [ ] **Monitor XP progression** and adjust as needed
- [ ] **Check external integrations** that use crafting exports

### Common Issues & Solutions

**Players can't see any recipes:**
- Check job names match RSG-Core exactly (case-sensitive)
- Verify players have assigned jobs
- Check server console for errors

**Job restrictions not working:**
- Ensure RSG-Core is up to date
- Verify job system is functioning
- Check server-side validation logs

**XP progression too slow/fast:**
- Adjust `xpreward` values for better balance
- Consider `requiredxp` thresholds for pacing
- Monitor player feedback and adjust accordingly

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

### Version 2.1.1+ Enhanced (Latest)
#### 🆕 New Features - Job-Based Crafting
- **Job Restrictions**: Restrict recipes to specific RSG-Core jobs (blacksmith, doctor, etc.)
- **Dynamic Menu Filtering**: Players only see recipes available to their job
- **20+ Export Functions**: Comprehensive API including job-based functions
- **Real-time Job Validation**: Server-side job checking prevents exploitation
- **Comprehensive Job APIs**: Check jobs, get job-specific recipes, validate permissions

#### 🎆 New Features - XP Progression System
- **Separated XP Fields**: `requiredxp` (needed to craft) vs `xpreward` (gained after crafting)
- **Skill-Gated Recipes**: Advanced items require crafting experience
- **Progressive Unlocks**: Novice → Apprentice → Master crafting tiers
- **Enhanced Feedback**: Clear XP requirement and reward messaging
- **Flexible Progression**: Different XP requirements and rewards per recipe

#### ⚙️ Enhanced Features
- **Detailed Missing Items Notifications**: Players see exactly what materials they need
- **Runtime Recipe Management**: Add/modify recipes with job restrictions dynamically
- **Backward Compatibility**: Full support for existing `craftingxp` field
- **Performance Optimization**: Configurable intervals and non-blocking operations
- **Enhanced Security**: Server-side job and ingredient validation

#### 🐛 Bug Fixes
- **Syntax Errors**: Fixed Lua array syntax issues (`[]` → `{}`)
- **Progress Bar Race Condition**: Fixed inventory unlock timing
- **Memory Leaks**: Proper NPC cleanup and model management
- **XP Calculation**: Corrected double XP addition bug
- **Item Validation**: Added null checks for missing items
- **Ingredient Logic**: Improved server-side validation

#### ⚡ Performance Improvements
- **Job-Filtered Menus**: Only load recipes player can access
- **NPC Spawning**: Reduced update frequency (500ms → 1000ms configurable)
- **Animation System**: Non-blocking fade in/out animations
- **Menu Registration**: One-time context registration
- **Memory Management**: Automatic model cleanup
- **Concurrent Limiting**: Configurable fade animation limits

#### 🔒 Security Enhancements
- **Job-Based Security**: Server-side job validation prevents bypass
- **Dual Validation**: Both ingredient and job checks before processing
- **Real-time Verification**: Job status checked at crafting time
- **Server-side Validation**: Double-checking ingredients before processing
- **Data Sanitization**: Improved validation of client data
- **Transaction Safety**: Rollback protection for failed operations
- **Error Handling**: Comprehensive validation with detailed logging

#### 📄 Documentation & Examples
- **Comprehensive Documentation**: Job-based crafting guide with examples
- **Migration Guide**: Step-by-step upgrade instructions
- **XP Progression Examples**: Novice to master crafting progression
- **Testing Commands**: Built-in commands for testing job restrictions
- **API Documentation**: Complete export function reference

---

## 📄 License

Custom license - See Discord for terms and conditions.

---

**Made with ❤️ by RexShack Gaming**
