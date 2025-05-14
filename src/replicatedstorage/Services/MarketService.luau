local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Core.Types)
local Config = require(ReplicatedStorage.Core.Config)

-- Service
local MarketService = {}
MarketService.__index = MarketService

function MarketService.new(): Types.MarketService
	local self = setmetatable({}, MarketService)
	self.prices = {} -- [resourceId] = MarketPrice
	self.history = {} -- { MarketHistoryEntry }
	self.playerHistory = {} -- [userId] = { MarketTransaction }
	self.lastUpdate = os.time()
	self.OnPriceUpdated = Instance.new("BindableEvent")
	return self
end

-- Private functions
local function calculatePriceChange(currentPrice: number, supply: number, demand: number): number
	local supplyDemandDiff = demand - supply
	local priceChange = supplyDemandDiff * Config.ECONOMY.SUPPLY_DEMAND_IMPACT * currentPrice
	local randomFactor = (math.random() * 2 - 1) * Config.ECONOMY.PRICE_VOLATILITY * currentPrice
	priceChange += randomFactor
	return priceChange
end

function MarketService:Init()
	for _, resource in ipairs(Config.RESOURCES.ITEMS) do
		self.prices[resource.id] = {
			resourceId = resource.id,
			basePrice = resource.basePrice,
			currentPrice = resource.basePrice,
			lastUpdated = os.time(),
			priceHistory = { resource.basePrice },
			supply = 0,
			demand = 0,
		}
	end

	task.spawn(function()
		while true do
			self:UpdateAllMarketPrices()
			task.wait(Config.ECONOMY.PRICE_UPDATE_INTERVAL)
		end
	end)
end

function MarketService:UpdateAllMarketPrices()
	local currentTime = os.time()
	if currentTime - self.lastUpdate < Config.ECONOMY.PRICE_UPDATE_INTERVAL then
		return
	end
	for resourceId, priceData in pairs(self.prices) do
		local priceChange = calculatePriceChange(priceData.currentPrice, priceData.supply, priceData.demand)
		priceData.currentPrice = math.max(0, priceData.currentPrice + priceChange)
		table.insert(priceData.priceHistory, priceData.currentPrice)
		if #priceData.priceHistory > Config.ECONOMY.MAX_PRICE_HISTORY then
			table.remove(priceData.priceHistory, 1)
		end
		priceData.lastUpdated = currentTime
	end
	self.lastUpdate = currentTime
end

function MarketService:GetPrice(resourceId: string): Types.MarketPrice
	local price = self.prices[resourceId]
	if not price then
		price = {
			resourceId = resourceId,
			basePrice = 10,
			currentPrice = 10,
			supply = 100,
			demand = 100,
			lastUpdated = os.time(),
			priceHistory = { 10 },
		}
		self.prices[resourceId] = price
	end
	return price
end

function MarketService:GetPriceHistory(resourceId: string): { number }?
	local priceData = self.prices[resourceId]
	if not priceData then
		return nil
	end
	return priceData.priceHistory
end

function MarketService:UpdateSupply(resourceId: string, amount: number)
	local priceData = self.prices[resourceId]
	if not priceData then
		return
	end
	priceData.supply += amount
end

function MarketService:UpdateDemand(resourceId: string, amount: number)
	local priceData = self.prices[resourceId]
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

function MarketService:UpdateMarket(resourceId: string)
	local price = self:GetPrice(resourceId)
	local supply, demand = price.supply, price.demand
	local base = price.basePrice
	local ratio = (demand > 0 and supply > 0) and (demand / supply) or 1
	local newPrice = math.max(1, math.floor(base * ratio))
	price.currentPrice = newPrice
	price.lastUpdated = os.time()
	table.insert(self.history, {
		resourceId = resourceId,
		price = newPrice,
		timestamp = os.time(),
	})
end

function MarketService:AddTransaction(
	playerUserId: number,
	resourceId: string,
	amount: number,
	price: number,
	txType: string
)
	self.playerHistory[playerUserId] = self.playerHistory[playerUserId] or {}
	table.insert(self.playerHistory[playerUserId], {
		playerUserId = playerUserId,
		resourceId = resourceId,
		amount = amount,
		price = price,
		type = txType,
		timestamp = os.time(),
	})
	-- Limit history to 50
	if #self.playerHistory[playerUserId] > 50 then
		table.remove(self.playerHistory[playerUserId], 1)
	end
end

function MarketService:GetPlayerHistory(playerUserId: number): { Types.MarketTransaction }
	return self.playerHistory[playerUserId] or {}
end

function MarketService:Buy(playerUserId: number, resourceId: string, amount: number): (boolean, string)
	local price = self:GetPrice(resourceId)
	if price.supply < amount then
		return false, "Not enough supply"
	end
	price.supply -= amount
	price.demand += amount
	self:UpdateMarket(resourceId)
	self:AddTransaction(playerUserId, resourceId, amount, price.currentPrice, "buy")
	return true, "Bought " .. amount .. " " .. resourceId
end

function MarketService:Sell(playerUserId: number, resourceId: string, amount: number): (boolean, string)
	local price = self:GetPrice(resourceId)
	price.supply += amount
	price.demand = math.max(0, price.demand - amount)
	self:UpdateMarket(resourceId)
	self:AddTransaction(playerUserId, resourceId, amount, price.currentPrice, "sell")
	return true, "Sold " .. amount .. " " .. resourceId
end

function MarketService:GetHistory(resourceId: string): { Types.MarketHistoryEntry }
	local out = {}
	for _, entry in ipairs(self.history) do
		if entry.resourceId == resourceId then
			table.insert(out, entry)
		end
	end
	return out
end

return MarketService
