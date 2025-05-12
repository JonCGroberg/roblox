--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Constants = require(ReplicatedStorage.Core.Constants)

-- Disable default Roblox UI elements
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.SelfView, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, false)

-- Services
local UIService = require(ReplicatedStorage.Services.UIService)
local MarketService = require(ReplicatedStorage.Services.MarketService)

-- Screens
local MainMenu = require(ReplicatedStorage.UI.Screens.MainMenu)
local GameScreen = require(ReplicatedStorage.UI.Screens.GameScreen)

-- Initialize services
local uiService = UIService.new()
local marketService = MarketService.new()

-- Initialize UI
uiService:Init()

-- Register screens
uiService:RegisterScreen(MainMenu.new(uiService))
uiService:RegisterScreen(GameScreen.new(uiService))

-- Show main menu on game start
uiService:ShowScreen("MainMenu", Constants.UI.TRANSITION_TYPES.FADE)

-- Initialize market
marketService:Init()

-- Connect to market updates
marketService.OnPriceUpdated.Event:Connect(function(resourceId: string, price: number)
	-- TODO: Update market UI when prices change
	print(`Price updated for {resourceId}: {price}`)
end)
