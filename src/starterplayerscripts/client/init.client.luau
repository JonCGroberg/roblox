--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Constants = require(ReplicatedStorage.Core.Constants)
local Players = game:GetService("Players")

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
local EconomyService = require(ReplicatedStorage.Services.EconomyService)
local economyService = EconomyService.new() -- create an instance
local BusinessService = require(ReplicatedStorage.Services.BusinessService)
local FacilityUI = require(ReplicatedStorage.UI.FacilityUI)
local DeliveryUI = require(ReplicatedStorage.UI.DeliveryUI)

-- Screens
local MainMenu = require(ReplicatedStorage.UI.Screens.MainMenu)
local GameScreen = require(ReplicatedStorage.UI.Screens.GameScreen)

-- Initialize services
local uiService = UIService.new()
local marketService = MarketService.new()

-- Initialize BusinessService with EconomyService
local businessService = BusinessService.new(economyService)

-- Initialize FacilityUI with BusinessService
local facilityUI = FacilityUI
facilityUI:Init(businessService)

-- Initialize UI
uiService:Init()

-- Create and register screens
local mainMenu = MainMenu.new(uiService)
local gameScreen = GameScreen.new(uiService, economyService)
uiService:RegisterScreen(mainMenu)
uiService:RegisterScreen(gameScreen)

-- Show main menu on game start
uiService:ShowScreen("MainMenu", Constants.UI.TRANSITION_TYPES.FADE)

-- Initialize market
marketService:Init()

-- Connect to market updates
marketService.OnPriceUpdated.Event:Connect(function(resourceId: string, price: number)
	-- TODO: Update market UI when prices change
	print(`Price updated for {resourceId}: {price}`)
end)

-- Create the UI components
local upgradePanel = facilityUI:CreateUpgradePanel()
facilityUI:CreateResourceIndicators()
facilityUI:CreateStatusDisplays()
facilityUI:AddCapacitySliders()
facilityUI:AddUpgradeButtons()
facilityUI:AddResourceDisplays()

-- Add behavior to the UI components
facilityUI:AddSliderBehavior()
facilityUI:AddButtonClickEvent()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a ScreenGui for Facility UI if it doesn't exist
local facilityScreenGui = playerGui:FindFirstChild("FacilityUI") or Instance.new("ScreenGui")
facilityScreenGui.Name = "FacilityUI"
facilityScreenGui.Parent = playerGui

-- Parent the upgrade panel to the ScreenGui and make it visible for testing
upgradePanel.Parent = facilityScreenGui
upgradePanel.Visible = true

-- After initializing businessService and facilityUI, create a test business and set the businessId for the UI
local testBusinessType = "factory" :: any -- Use a valid business type from your config
local testPosition = Vector3.new(0, 0, 0)
local testRotation = Vector3.new(0, 0, 0)
local player = Players.LocalPlayer

-- Create a test business for the player
local success = businessService:PlaceBusiness(player, testBusinessType, testPosition, testRotation)
local testBusinessId = nil
if success then
	local businesses = businessService:GetPlayerBusinesses(player)
	if #businesses > 0 then
		testBusinessId = businesses[#businesses].id
	end
end

facilityUI["businessId"] = testBusinessId

economyService.OnCurrencyUpdated.Event:Connect(function(player)
	if player == Players.LocalPlayer then
		(gameScreen :: any):UpdateCurrencyFromService(economyService, player)
	end
end)

economyService.OnCurrencyUpdated:Fire(player)

-- Initialize DeliveryUI
DeliveryUI:Init()
