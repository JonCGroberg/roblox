--!strict
local Config = {}

-- Game Configuration
Config.GAME = {
	STARTING_CURRENCY = 5000,
	MAX_PLAYERS = 50,
	SAVE_INTERVAL = 300, -- 5 minutes
	DEBUG_MODE = false,
}

-- Resource Configuration
Config.RESOURCES = {
	RAW = {
		"iron_ore",
		"copper_ore",
		"coal",
	},
	PROCESSED = {
		"iron_ingot",
		"copper_ingot",
		"steel",
	},
	SPECIAL = {
		"advanced_circuit",
		"processing_unit",
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

return Config
