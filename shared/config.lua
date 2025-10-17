Config = {}

---------------------------------
-- settings
---------------------------------
Config.Image = "rsg-inventory/html/images/"
Config.Keybind = 'J'
Config.EnableTarget = true

---------------------------------
-- npc settings
---------------------------------
Config.DistanceSpawn = 20.0
Config.FadeIn = true

---------------------------------
-- optimization settings
---------------------------------
Config.UpdateInterval = 1000  -- NPC distance check interval (ms)
Config.ModelTimeout = 5000    -- Model loading timeout (ms)
Config.MaxConcurrentFades = 5 -- Maximum simultaneous fade animations

---------------------------------
-- npc locations
---------------------------------
Config.CraftingLocations = {
    {
        name = 'Valentine Crafting',
        prompt = 'valcrafting',
        coords = vector3(-369.83, 798.21, 116.19),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(-369.83, 798.21, 116.19, 225.12),
        showblip = true
    },
    {
        name = 'Blackwater Crafting',
        prompt = 'blkcrafting',
        coords = vector3(-869.38, -1389.79, 43.52),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(-869.38, -1389.79, 43.52, 116.44),
        showblip = true
    },
    {
        name = 'Van-Horn Crafting',
        prompt = 'vancrafting',
        coords = vector3(2930.54, 560.51, 44.95),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(2930.54, 560.51, 44.95, 316.93),
        showblip = true
    },
    {
        name = 'StDenis Crafting',
        prompt = 'stdencrafting',
        coords = vector3(2514.08, -1459.59, 46.31),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(2514.08, -1459.59, 46.31, 35.81),
        showblip = true
    },
    {
        name = 'Strawberry Crafting',
        prompt = 'strcrafting',
        coords = vector3(-1821.03, -569.88, 156.01),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(-1821.03, -569.88, 156.01, 220.72),
        showblip = true
    },
    {
        name = 'Macfarlane Crafting',
        prompt = 'maccrafting',
        coords = vector3(-2401.67, -2382.50, 61.19),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(-2401.67, -2382.50, 61.19, 295.38),
        showblip = true
    },
    {
        name = 'Spider Crafting',
        prompt = 'spicrafting',
        coords = vector3(-1344.05, 2404.69, 307.10),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(-1344.05, 2404.69, 307.10, 115.11),
        showblip = true
    },
    {
        name = 'Tumbleweed Crafting',
        prompt = 'tumcrafting',
        coords = vector3(-5512.38, -3040.98, -2.39),
        npcmodel = `mp_u_M_M_lom_rhd_smithassistant_01`,
        npccoords = vector4(-5512.38, -3040.98, -2.39, 148.73),
        showblip = true
    },
}

---------------------------------
-- crafting items
---------------------------------
Config.Crafting = {
    ----------------------
    -- tools
    ----------------------
    {
        category = 'Tools',
        crafttime = 30000,
        requiredxp = 0,      -- XP required to craft this item
        xpreward = 5,        -- XP gained after successful crafting
        requiredjob = nil,   -- nil means no job restriction (anyone can craft)
        ingredients = {
            { item = 'coal',      amount = 1 },
            { item = 'steel_bar', amount = 1 },
            { item = 'wood',      amount = 1 },
        },
        receive = 'pickaxe',
        giveamount = 1
    },
    ----------------------
    -- blacksmith items
    ----------------------
    {
        category = 'Blacksmith',
        crafttime = 45000,
        requiredxp = 0,     -- Need 0 XP to craft this
        xpreward = 5,       -- Gain 5 XP after crafting
        requiredjob = 'blacksmith', -- Only jobtype blacksmith can craft this
        ingredients = {
            { item = 'coal',      amount = 1 },
            { item = 'steel_bar', amount = 1 },
        },
        receive = 'weapon_melee_knife',
        giveamount = 1
    },
    -- add more as required
}
