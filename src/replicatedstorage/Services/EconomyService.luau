--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local Constants = require(ReplicatedStorage.Core.Constants)

local EconomyService = {}
EconomyService.__index = EconomyService

function EconomyService.new(): Types.EconomyService
	local self = setmetatable({}, EconomyService)
	self._playerEconomy = {} -- [userId: string]: { coins: number, gems: number, transactionHistory: { Types.Transaction } }
	return (self :: any) :: Types.EconomyService
end

function EconomyService:GetBalance(player: Player, currency: Types.CurrencyType): number
	local econ = self._playerEconomy[tostring(player.UserId)]
	if not econ then
		return 0
	end
	return econ[currency] or 0
end

function EconomyService:SetBalance(player: Player, currency: Types.CurrencyType, amount: number)
	local userId = tostring(player.UserId)
	self._playerEconomy[userId] = self._playerEconomy[userId] or { coins = 0, gems = 0, transactionHistory = {} }
	self._playerEconomy[userId][currency] = amount
end

function EconomyService:AddTransaction(player: Player, transaction: Types.Transaction)
	local userId = tostring(player.UserId)
	self._playerEconomy[userId] = self._playerEconomy[userId] or { coins = 0, gems = 0, transactionHistory = {} }
	table.insert(self._playerEconomy[userId].transactionHistory, transaction)
end

function EconomyService:GetTransactionHistory(player: Player): { Types.Transaction }
	local econ = self._playerEconomy[tostring(player.UserId)]
	if not econ then
		return {}
	end
	return econ.transactionHistory
end

return EconomyService
