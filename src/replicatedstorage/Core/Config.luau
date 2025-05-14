--!strict
local Config = {}

-- Game Configuration
Config.GAME = {
	STARTING_CURRENCY = 5000,
	MAX_PLAYERS = 50,
	SAVE_INTERVAL = 300, -- 5 minutes
	DEBUG_MODE = false,
}

-- Economy Configuration
Config.ECONOMY = {
	-- Initial player balances
	INITIAL_BALANCE = {
		coins = 1000,
		gems = 10,
	},

	-- Transaction settings
	MAX_TRANSACTION_HISTORY = 100,
	TRANSACTION_FEE_PERCENTAGE = 0.05, -- 5% fee on transactions

	-- Market settings
	PRICE_UPDATE_INTERVAL = 60, -- seconds
	MAX_PRICE_HISTORY = 100,
	PRICE_VOLATILITY = 0.1, -- 10% max price change per update
	SUPPLY_DEMAND_IMPACT = 0.05, -- 5% price change per unit of supply/demand difference
}

-- Resource Configuration
Config.RESOURCES = {
	-- Resource definitions
	ITEMS = {
		{
			id = "iron_ore",
			name = "Iron Ore",
			type = "raw",
			basePrice = 10,
			description = "Raw iron ore that can be processed into iron ingots",
			icon = "rbxassetid://1234567890",
			stackSize = 100,
			rarity = 1,
		},
		{
			id = "iron_ingot",
			name = "Iron Ingot",
			type = "processed",
			basePrice = 25,
			description = "Processed iron ingot used in crafting",
			icon = "rbxassetid://1234567891",
			stackSize = 50,
			rarity = 2,
		},
		{
			id = "copper_ore",
			name = "Copper Ore",
			type = "raw",
			basePrice = 15,
			description = "Raw copper ore that can be processed into copper ingots",
			icon = "rbxassetid://1234567892",
			stackSize = 100,
			rarity = 1,
		},
		{
			id = "copper_ingot",
			name = "Copper Ingot",
			type = "processed",
			basePrice = 35,
			description = "Processed copper ingot used in crafting",
			icon = "rbxassetid://1234567893",
			stackSize = 50,
			rarity = 2,
		},
		{
			id = "gold_ore",
			name = "Gold Ore",
			type = "raw",
			basePrice = 50,
			description = "Raw gold ore that can be processed into gold ingots",
			icon = "rbxassetid://1234567894",
			stackSize = 50,
			rarity = 3,
		},
		{
			id = "gold_ingot",
			name = "Gold Ingot",
			type = "processed",
			basePrice = 120,
			description = "Processed gold ingot used in crafting",
			icon = "rbxassetid://1234567895",
			stackSize = 25,
			rarity = 4,
		},
	},

	-- Resource categories
	CATEGORIES = {
		RAW = {
			"iron_ore",
			"copper_ore",
			"gold_ore",
			"coal",
		},
		PROCESSED = {
			"iron_ingot",
			"copper_ingot",
			"gold_ingot",
			"steel",
		},
		SPECIAL = {
			"advanced_circuit",
			"processing_unit",
		},
	},
}

-- Facility Configuration
Config.FACILITIES = {
	MINER = {
		input = {},
		output = { "iron_ore", "copper_ore", "coal" },
		processingTime = 5,
		baseCost = 1000,
	},
	FURNACE = {
		input = { "iron_ore", "coal" },
		output = { "iron_ingot" },
		processingTime = 10,
		baseCost = 2000,
	},
	ASSEMBLER = {
		input = { "iron_ingot", "copper_ingot" },
		output = { "steel" },
		processingTime = 15,
		baseCost = 3000,
	},
}

-- Processing Recipes
Config.RECIPES = {
	{
		id = "iron_ingot",
		name = "Iron Ingot",
		input = {
			{ resourceId = "iron_ore", amount = 2 },
		},
		output = {
			{ resourceId = "iron_ingot", amount = 1 },
		},
		processingTime = 5, -- seconds
		facilityType = "smelter",
	},
	{
		id = "copper_ingot",
		name = "Copper Ingot",
		input = {
			{ resourceId = "copper_ore", amount = 2 },
		},
		output = {
			{ resourceId = "copper_ingot", amount = 1 },
		},
		processingTime = 5, -- seconds
		facilityType = "smelter",
	},
	{
		id = "gold_ingot",
		name = "Gold Ingot",
		input = {
			{ resourceId = "gold_ore", amount = 2 },
		},
		output = {
			{ resourceId = "gold_ingot", amount = 1 },
		},
		processingTime = 8, -- seconds
		facilityType = "smelter",
	},
}

-- Delivery Bot Configuration
Config.DELIVERY = {
	BUFFER_THRESHOLD = 0.8, -- Create delivery task when buffer is 80% full
	DELIVERY_RATIO = 0.5, -- Deliver 50% of buffer contents
	BOT_TYPES = {
		basic = {
			speed = 16,
			capacity = 100,
			cost = 1000,
		},
		advanced = {
			speed = 24,
			capacity = 200,
			cost = 2500,
		},
		special = {
			speed = 32,
			capacity = 500,
			cost = 5000,
		},
	},
	QUEUE_PRIORITIES = {
		normal = 1,
		high = 2,
		urgent = 3,
	},
}

-- Business Upgrade Configuration
Config.BUSINESS_UPGRADES = {
	capacity = {
		baseCapacity = 1000,
		capacityMultiplier = 0.5, -- Each level increases capacity by 50%
		cost = 500,
		maxLevel = 5,
	},
	speed = {
		baseSpeed = 1,
		speedMultiplier = 0.25, -- Each level increases speed by 25%
		cost = 750,
		maxLevel = 3,
	},
	efficiency = {
		baseEfficiency = 1,
		efficiencyMultiplier = 0.2, -- Each level increases efficiency by 20%
		cost = 1000,
		maxLevel = 4,
	},
}

return Config
