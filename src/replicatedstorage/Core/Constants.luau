--!strict
-- Type definitions for module constants
local Constants = {}

-- Game Service Constants
Constants.GAME = {
	INITIALIZATION_TIMEOUT = 10, -- seconds
	DATA_STORE_NAME = "PlayerData_v1",
	SAVE_INTERVAL = 300, -- 5 minutes
}

-- UI Service Constants
Constants.UI = {
	TRANSITION_TYPES = {
		FADE = "Fade",
		SLIDE_LEFT = "SlideLeft",
		SLIDE_RIGHT = "SlideRight",
		SLIDE_UP = "SlideUp",
		SLIDE_DOWN = "SlideDown",
	},
	TRANSITION_DURATION = 0.3,
}

-- Facility Constants
Constants.FACILITY = {
	MAX_INPUT_BUFFER = 1000,
	MAX_OUTPUT_BUFFER = 1000,
	BASE_PROCESSING_RATE = 10,
	BASE_EFFICIENCY = 1.0,
	UPGRADE_COST_MULTIPLIER = 1.5,
}

-- Bot Constants
Constants.BOT = {
	BASE_SPEED = 16,
	BASE_CARRY_CAPACITY = 100,
	HIRE_COST = 1000,
	UPGRADE_COST_MULTIPLIER = 1.5,
}

-- Market Constants
Constants.MARKET = {
	BASE_PRICE_MULTIPLIER = 1.0,
	SUPPLY_DEMAND_IMPACT = 0.1,
	MIN_PRICE_MULTIPLIER = 0.5,
	MAX_PRICE_MULTIPLIER = 2.0,
}

-- Grid Constants
Constants.GRID = {
	CELL_SIZE = 4,
	MAX_FACILITIES_PER_CELL = 10,
}

return Constants
