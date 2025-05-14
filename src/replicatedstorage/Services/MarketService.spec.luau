local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketService = require(ReplicatedStorage.Services.MarketService)
local Config = require(ReplicatedStorage.Core.Config)

local function test(desc, fn)
	print("[MarketService Test]", desc)
	fn()
end

local function assertEqual(a, b, msg)
	if a ~= b then
		error(msg or ("Expected " .. tostring(a) .. " == " .. tostring(b)))
	end
end

local function assertTrue(val, msg)
	if not val then
		error(msg or "Expected true but got false")
	end
end

local function assertFalse(val, msg)
	if val then
		error(msg or "Expected false but got true")
	end
end

local function runTests()
	local service = MarketService.new()
	service:Init()
	local resourceId = Config.RESOURCES.ITEMS[1].id

	test("Initial price is base price", function()
		local price = service:GetPrice(resourceId)
		assertEqual(price.currentPrice, price.basePrice, "Initial price should be base price")
	end)

	test("Buy reduces supply and increases demand", function()
		local userId = 123
		local priceBefore = service:GetPrice(resourceId).currentPrice
		local supplyBefore = service:GetPrice(resourceId).supply
		local demandBefore = service:GetPrice(resourceId).demand
		local ok, msg = service:Buy(userId, resourceId, 10)
		assertTrue(ok, "Buy should succeed")
		local priceAfter = service:GetPrice(resourceId).currentPrice
		local supplyAfter = service:GetPrice(resourceId).supply
		local demandAfter = service:GetPrice(resourceId).demand
		assertEqual(supplyAfter, supplyBefore - 10, "Supply should decrease by 10")
		assertEqual(demandAfter, demandBefore + 10, "Demand should increase by 10")
	end)

	test("Sell increases supply and reduces demand", function()
		local userId = 123
		local supplyBefore = service:GetPrice(resourceId).supply
		local demandBefore = service:GetPrice(resourceId).demand
		local ok, msg = service:Sell(userId, resourceId, 5)
		assertTrue(ok, "Sell should succeed")
		local supplyAfter = service:GetPrice(resourceId).supply
		local demandAfter = service:GetPrice(resourceId).demand
		assertEqual(supplyAfter, supplyBefore + 5, "Supply should increase by 5")
		assertEqual(demandAfter, math.max(0, demandBefore - 5), "Demand should decrease by 5 or be 0")
	end)

	test("Buy fails if not enough supply", function()
		local userId = 123
		local price = service:GetPrice(resourceId)
		price.supply = 2
		local ok, msg = service:Buy(userId, resourceId, 10)
		assertFalse(ok, "Buy should fail if not enough supply")
	end)

	test("Transaction history is recorded", function()
		local userId = 123
		service:Buy(userId, resourceId, 1)
		service:Sell(userId, resourceId, 2)
		local history = service:GetPlayerHistory(userId)
		assertTrue(#history >= 2, "History should have at least 2 entries")
		assertEqual(history[#history].type, "sell", "Last transaction should be sell")
	end)

	print("All MarketService tests passed!")
end

runTests()
