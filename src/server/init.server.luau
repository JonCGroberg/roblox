--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

-- Load shared modules
local Types = require(Shared.Types)
local Constants = require(Shared.Constants)
local Config = require(Shared.Config)
local Utils = require(Shared.Utils)

-- Initialize services
local function init()
	-- TODO: Initialize services here
end

-- Start the game
init()
