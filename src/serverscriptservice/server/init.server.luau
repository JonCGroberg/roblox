--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameService = require(ReplicatedStorage.Services.GameService)

-- Initialize GameService
local gameService = GameService.new()
gameService:Init()

print("GameService initialized")
