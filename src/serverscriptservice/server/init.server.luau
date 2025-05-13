--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameService = require(ReplicatedStorage.Services.GameService)
local Players = game:GetService("Players")
local BusinessService = require(ReplicatedStorage.Services.BusinessService)

-- Initialize GameService
local gameService = GameService.new()
gameService:Init()

print("GameService initialized")

local businessService = BusinessService.new()

Players.PlayerAdded:Connect(function(player)
	businessService:LoadPlayerBusinesses(player)
end)

Players.PlayerRemoving:Connect(function(player)
	businessService:SavePlayerBusinesses(player)
end)
