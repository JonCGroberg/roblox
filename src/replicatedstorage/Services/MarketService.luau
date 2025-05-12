local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Core.Types)
local Config = require(ReplicatedStorage.Core.Config)

-- Service
local MarketService = {}
MarketService.__index = MarketService

function MarketService.new(): Types.MarketService
	local self = setmetatable({}, MarketService)

	-- Create event for price updates
	self.OnPriceUpdated = Instance.new("BindableEvent")

	return (self :: any) :: Types.MarketService
end

-- Private variables
local marketPrices: { [string]: Types.MarketPrice } = {}
local lastUpdate = os.time()

-- Private functions
local function calculatePriceChange(currentPrice: number, supply: number, demand: number): number
	local supplyDemandDiff = demand - supply
	local priceChange = supplyDemandDiff * Config.ECONOMY.SUPPLY_DEMAND_IMPACT * currentPrice

	-- Add some randomness
	local randomFactor = (math.random() * 2 - 1) * Config.ECONOMY.PRICE_VOLATILITY * currentPrice
	priceChange += randomFactor

	return priceChange
end

local function updateMarketPrices()
	local currentTime = os.time()
	if currentTime - lastUpdate < Config.ECONOMY.PRICE_UPDATE_INTERVAL then
		return
	end

	for resourceId, priceData in marketPrices do
		local priceChange = calculatePriceChange(priceData.currentPrice, priceData.supply, priceData.demand)

		-- Update price
		priceData.currentPrice = math.max(0, priceData.currentPrice + priceChange)

		-- Update history
		table.insert(priceData.priceHistory, priceData.currentPrice)
		if #priceData.priceHistory > Config.ECONOMY.MAX_PRICE_HISTORY then
			table.remove(priceData.priceHistory, 1)
		end

		priceData.lastUpdated = currentTime
	end

	lastUpdate = currentTime
end

-- Public methods
function MarketService:Init()
	-- Initialize market prices for all resources
	for _, resource in ipairs(Config.RESOURCES.ITEMS) do
		marketPrices[resource.id] = {
			basePrice = resource.basePrice,
			currentPrice = resource.basePrice,
			lastUpdated = os.time(),
			priceHistory = { resource.basePrice },
			supply = 0,
			demand = 0,
		}
	end

	-- Start price update loop
	task.spawn(function()
		while true do
			updateMarketPrices()
			task.wait(Config.ECONOMY.PRICE_UPDATE_INTERVAL)
		end
	end)
end

function MarketService:GetPrice(resourceId: string): number?
	local priceData = marketPrices[resourceId]
	if not priceData then
		return nil
	end
	return priceData.currentPrice
end

function MarketService:GetPriceHistory(resourceId: string): { number }?
	local priceData = marketPrices[resourceId]
	if not priceData then
		return nil
	end
	return priceData.priceHistory
end

function MarketService:UpdateSupply(resourceId: string, amount: number)
	local priceData = marketPrices[resourceId]
	if not priceData then
		return
	end

	priceData.supply += amount
end

function MarketService:UpdateDemand(resourceId: string, amount: number)
	local priceData = marketPrices[resourceId]
	if not priceData then
		return
	end

	priceData.demand += amount
end

function MarketService:GetAllResources(): { Types.Resource }
	local resources: { Types.Resource } = {}

	for _, item in ipairs(Config.RESOURCES.ITEMS) do
		table.insert(resources, {
			id = item.id,
			name = item.name,
			type = item.type :: Types.ResourceType,
			basePrice = item.basePrice,
			description = item.description,
			icon = item.icon,
			stackSize = item.stackSize,
			rarity = item.rarity,
		})
	end

	return resources
end

return MarketService
