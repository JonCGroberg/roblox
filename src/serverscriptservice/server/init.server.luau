--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameService = require(ReplicatedStorage.Services.GameService)
local Players = game:GetService("Players")
local BusinessService = require(ReplicatedStorage.Services.BusinessService)
local DeliveryService = require(ReplicatedStorage.Services.DeliveryService)
local ProductionService = require(ReplicatedStorage.Services.ProductionService)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local MarketService = require(ReplicatedStorage.Services.MarketService)

-- Initialize GameService
local gameService = GameService.new()
gameService:Init()

print("GameService initialized")

-- Initialize services with proper dependency injection
local economyService = EconomyService.new()
local businessService = BusinessService.new(economyService)
local deliveryService = DeliveryService.new(businessService)
local productionService = ProductionService.new(businessService, deliveryService)

-- Initialize services
businessService:Init()
deliveryService:Init()
productionService:Init()

print("All services initialized")

Players.PlayerAdded:Connect(function(player)
	businessService:LoadPlayerBusinesses(player)
end)

Players.PlayerRemoving:Connect(function(player)
	businessService:SavePlayerBusinesses(player)
end)

-- Require MarketService
local marketService = MarketService.new()
marketService:Init()

-- RemoteEvents for market
local MarketGetPrices = Instance.new("RemoteEvent")
MarketGetPrices.Name = "MarketGetPrices"
MarketGetPrices.Parent = ReplicatedStorage

local MarketPricesUpdate = Instance.new("RemoteEvent")
MarketPricesUpdate.Name = "MarketPricesUpdate"
MarketPricesUpdate.Parent = ReplicatedStorage

local MarketBuy = Instance.new("RemoteEvent")
MarketBuy.Name = "MarketBuy"
MarketBuy.Parent = ReplicatedStorage

local MarketSell = Instance.new("RemoteEvent")
MarketSell.Name = "MarketSell"
MarketSell.Parent = ReplicatedStorage

local MarketTransactionHistory = Instance.new("RemoteEvent")
MarketTransactionHistory.Name = "MarketTransactionHistory"
MarketTransactionHistory.Parent = ReplicatedStorage

-- Send all prices to client
MarketGetPrices.OnServerEvent:Connect(function(player)
	local prices = {}
	for _, resource in ipairs(require(ReplicatedStorage.Core.Config).RESOURCES.ITEMS) do
		prices[resource.id] = marketService:GetPrice(resource.id)
	end
	MarketPricesUpdate:FireClient(player, prices)
end)

-- Handle buy requests
MarketBuy.OnServerEvent:Connect(function(player, resourceId, amount)
	local userId = player.UserId
	local success, msg = marketService:Buy(userId, resourceId, amount)
	-- After buy, broadcast updated prices to all clients
	local prices = {}
	for _, resource in ipairs(require(ReplicatedStorage.Core.Config).RESOURCES.ITEMS) do
		prices[resource.id] = marketService:GetPrice(resource.id)
	end
	MarketPricesUpdate:FireAllClients(prices)
	-- Optionally: send result to player (could use a BindableEvent or another RemoteEvent)
end)

-- Handle sell requests
MarketSell.OnServerEvent:Connect(function(player, resourceId, amount)
	local userId = player.UserId
	local success, msg = marketService:Sell(userId, resourceId, amount)
	-- After sell, broadcast updated prices to all clients
	local prices = {}
	for _, resource in ipairs(require(ReplicatedStorage.Core.Config).RESOURCES.ITEMS) do
		prices[resource.id] = marketService:GetPrice(resource.id)
	end
	MarketPricesUpdate:FireAllClients(prices)
	-- Optionally: send result to player
end)

MarketTransactionHistory.OnServerEvent:Connect(function(player)
	local userId = player.UserId
	local history = marketService:GetPlayerHistory(userId)
	MarketTransactionHistory:FireClient(player, history)
end)
