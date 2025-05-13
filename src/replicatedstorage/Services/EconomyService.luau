--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local Constants = require(ReplicatedStorage.Core.Constants)

local EconomyService = {}
EconomyService.__index = EconomyService

function EconomyService.new(): Types.EconomyService
	local self = setmetatable({}, EconomyService)
	self._playerEconomies = {} :: { [string]: Types.PlayerEconomy }
	self.OnCurrencyUpdated = Instance.new("BindableEvent")
	-- For testing: initialize the local player with a default balance
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	if player then
		self._playerEconomies[tostring(player.UserId)] = {
			coins = 1000,
			gems = 100,
			transactionHistory = {},
			lastUpdated = os.time(),
		}
	end
	return (self :: any) :: Types.EconomyService
end

function EconomyService:GetBalance(player: Player, currency: Types.CurrencyType): number
	local userId = tostring(player.UserId)
	print("playerEconomies is", self._playerEconomies)
	if not self._playerEconomies[userId] then
		self._playerEconomies[userId] = { coins = 0, gems = 0, transactionHistory = {}, lastUpdated = os.time() }
	end
	local econ = self._playerEconomies[userId]
	return econ[currency] or 0
end

function EconomyService:SetBalance(player: Player, currency: Types.CurrencyType, amount: number)
	local userId = tostring(player.UserId)
	if not self._playerEconomies[userId] then
		self._playerEconomies[userId] = { coins = 0, gems = 0, transactionHistory = {}, lastUpdated = os.time() }
	end
	local econ = self._playerEconomies[userId]
	econ[currency] = amount
	econ.lastUpdated = os.time()
	self._playerEconomies[userId] = econ
	self.OnCurrencyUpdated:Fire(player)
end

function EconomyService:AddTransaction(player: Player, transaction: Types.Transaction)
	local userId = tostring(player.UserId)
	local econ: Types.PlayerEconomy = self._playerEconomies[userId]
		or { coins = 0, gems = 0, transactionHistory = {}, lastUpdated = os.time() }
	table.insert(econ.transactionHistory, transaction)
	econ.lastUpdated = os.time()
	self._playerEconomies[userId] = econ
end

function EconomyService:GetTransactionHistory(player: Player): { Types.Transaction }
	local econ: Types.PlayerEconomy? = self._playerEconomies[tostring(player.UserId)]
	if not econ then
		return {}
	end
	return econ.transactionHistory
end

function EconomyService:ValidateTransaction(transaction: Types.Transaction): (boolean, string?)
	if transaction.amount <= 0 then
		return false, "Transaction amount must be positive"
	end

	if transaction.type == "purchase" then
		if not transaction.from then
			return false, "Missing purchaser (from)"
		end
		local econ = self._playerEconomies[transaction.from]
		if not econ or econ[transaction.currency] < transaction.amount then
			return false, "Insufficient funds for purchase"
		end
	elseif transaction.type == "sale" then
		if not transaction.to then
			return false, "Missing recipient (to)"
		end
		-- For sales, you may want to check if the system or player can receive the funds
		-- For now, always valid
	elseif transaction.type == "transfer" then
		if not transaction.from or not transaction.to then
			return false, "Missing sender or recipient"
		end
		local econ = self._playerEconomies[transaction.from]
		if not econ or econ[transaction.currency] < transaction.amount then
			return false, "Insufficient funds for transfer"
		end
	else
		return false, "Unknown transaction type"
	end

	return true, nil
end

return EconomyService
