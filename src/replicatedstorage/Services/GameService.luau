--!strict
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Types = require(game:GetService("ReplicatedStorage").Core.Types)
local Constants = require(game:GetService("ReplicatedStorage").Core.Constants)

-- Service
local GameService = {}
GameService.__index = GameService

-- Local data store for development
local LocalDataStore = {
	_data = {},
	GetAsync = function(self, key)
		return self._data[key]
	end,
	SetAsync = function(self, key, value)
		self._data[key] = value
	end,
}

function GameService.new(): Types.GameService
	local self = setmetatable({}, GameService)

	self._state = {
		players = {},
		isInitialized = false,
		startTime = os.time(),
	}

	-- Use local data store in development
	if RunService:IsStudio() then
		self._dataStore = LocalDataStore
		print("Using local data store for development")
	else
		self._dataStore = DataStoreService:GetDataStore(Constants.GAME.DATA_STORE_NAME)
	end

	return (self :: any) :: Types.GameService
end

function GameService:Init()
	-- Connect to player events
	Players.PlayerAdded:Connect(function(player)
		self:_handlePlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_handlePlayerRemoving(player)
	end)

	-- Initialize existing players
	for _, player in Players:GetPlayers() do
		self:_handlePlayerAdded(player)
	end

	-- Start auto-save loop
	task.spawn(function()
		while true do
			task.wait(Constants.GAME.SAVE_INTERVAL)
			for userId, _ in self._state.players do
				self:SavePlayerData(userId)
			end
		end
	end)

	self._state.isInitialized = true
end

function GameService:_handlePlayerAdded(player: Player)
	local playerState: Types.PlayerState = {
		userId = player.UserId,
		joinedAt = os.time(),
		isInitialized = false,
		data = {},
	}

	self._state.players[player.UserId] = playerState

	-- Load player data
	local success = self:LoadPlayerData(player.UserId)
	if not success then
		warn(`Failed to load data for player {player.Name}`)
	end

	-- Initialize player after a short delay
	task.delay(Constants.GAME.INITIALIZATION_TIMEOUT, function()
		if not playerState.isInitialized then
			warn(`Player {player.Name} failed to initialize within {Constants.GAME.INITIALIZATION_TIMEOUT} seconds`)
		end
	end)

	playerState.isInitialized = true
end

function GameService:_handlePlayerRemoving(player: Player)
	local playerState = self._state.players[player.UserId]
	if playerState then
		-- Save player data before removing
		self:SavePlayerData(player.UserId)
		self._state.players[player.UserId] = nil
	end
end

function GameService:SavePlayerData(userId: number): boolean
	local playerState = self._state.players[userId]
	if not playerState then
		return false
	end

	local success, err = pcall(function()
		self._dataStore:SetAsync(tostring(userId), playerState.data)
	end)

	if not success then
		warn(`Failed to save data for user {userId}: {err}`)
		return false
	end

	return true
end

function GameService:LoadPlayerData(userId: number): boolean
	local playerState = self._state.players[userId]
	if not playerState then
		return false
	end

	local success, data = pcall(function()
		return self._dataStore:GetAsync(tostring(userId))
	end)

	if not success then
		warn(`Failed to load data for user {userId}`)
		return false
	end

	if data then
		playerState.data = data
	end

	return true
end

function GameService:GetPlayerState(userId: number): Types.PlayerState?
	return self._state.players[userId]
end

function GameService:GetGameState(): Types.GameState
	return self._state
end

return GameService
