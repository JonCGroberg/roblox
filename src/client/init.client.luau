--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Shared = ReplicatedStorage.Shared
local Client = StarterPlayer.StarterPlayerScripts.Client

-- Load shared modules
local Types = require(Shared.Types)
local Constants = require(Shared.Constants)
local Config = require(Shared.Config)
local Utils = require(Shared.Utils)

-- Initialize client
local function init()
	-- TODO: Initialize client systems here
end

-- Start the client
init()
