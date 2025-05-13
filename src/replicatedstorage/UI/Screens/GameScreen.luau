--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local BaseComponent = require(ReplicatedStorage.UI.Components.BaseComponent)

local GameScreen = {}
GameScreen.__index = GameScreen
setmetatable(GameScreen, BaseComponent)

function GameScreen.new(uiService: Types.UIService?, economyService: any): Types.Screen
	print("Creating new GameScreen...")
	-- Create the screen instance first
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameScreen"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = false -- Hide by default

	-- Create the component with the instance
	local base = BaseComponent.new("GameScreen", screenGui)
	local self = {
		Name = base.Name,
		Instance = base.Instance,
		IsVisible = base.IsVisible,
		_events = base._events,
		_uiService = uiService,
		_economyService = economyService,
	}
	setmetatable(self, GameScreen)

	-- Create main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Parent = screenGui
	mainFrame.BackgroundTransparency = 1
	print("MainFrame created and parented")

	-- Create top bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BorderSizePixel = 0
	topBar.BackgroundTransparency = 1
	topBar.Parent = mainFrame
	print("TopBar created and parented")

	-- Create currency display
	local currencyDisplay = Instance.new("Frame")
	currencyDisplay.Name = "CurrencyDisplay"
	currencyDisplay.Size = UDim2.new(0, 200, 0, 40)
	currencyDisplay.Position = UDim2.new(0, 10, 0, 5)
	currencyDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	currencyDisplay.BorderSizePixel = 0
	currencyDisplay.Parent = topBar
	print("CurrencyDisplay created and parented")

	-- Create coins label
	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(0.5, 0, 1, 0)
	coinsLabel.Position = UDim2.new(0, 0, 0, 0)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.Text = "Coins: 0"
	coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinsLabel.TextSize = 18
	coinsLabel.Font = Enum.Font.GothamMedium
	coinsLabel.Parent = currencyDisplay
	print("CoinsLabel created and parented")

	-- Create gems label
	local gemsLabel = Instance.new("TextLabel")
	gemsLabel.Name = "GemsLabel"
	gemsLabel.Size = UDim2.new(0.5, 0, 1, 0)
	gemsLabel.Position = UDim2.new(0.5, 0, 0, 0)
	gemsLabel.BackgroundTransparency = 1
	gemsLabel.Text = "Gems: 0"
	gemsLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
	gemsLabel.TextSize = 18
	gemsLabel.Font = Enum.Font.GothamMedium
	gemsLabel.Parent = currencyDisplay
	print("GemsLabel created and parented")

	-- Create menu button
	local menuButton = Instance.new("TextButton")
	menuButton.Name = "MenuButton"
	menuButton.Size = UDim2.new(0, 100, 0, 40)
	menuButton.Position = UDim2.new(1, -110, 0, 5)
	menuButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	menuButton.Text = "Menu"
	menuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	menuButton.TextSize = 18
	menuButton.Font = Enum.Font.GothamMedium
	menuButton.Parent = topBar

	-- Add button hover effect
	menuButton.MouseEnter:Connect(function()
		menuButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end)
	menuButton.MouseLeave:Connect(function()
		menuButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)

	-- Connect menu button event
	menuButton.MouseButton1Click:Connect(function()
		if self._uiService then
			self._uiService:HideScreen("GameScreen")
			self._uiService:ShowScreen("MainMenu")
		end
	end)

	return (self :: any) :: Types.Screen
end

function GameScreen:Show()
	BaseComponent.Show(self)
end

function GameScreen:Hide()
	BaseComponent.Hide(self)
end

function GameScreen:Destroy()
	BaseComponent.Destroy(self)
end

-- Update currency display
function GameScreen:UpdateCurrency(coins: number, gems: number)
	print("Updating currency display...")
	print("self.Instance path:", self.Instance:GetFullName())
	local mainFrame = self.Instance:FindFirstChild("MainFrame")
	if not mainFrame then
		warn("MainFrame missing! Children:", self.Instance:GetChildren())
		return
	end
	print("MainFrame children:", mainFrame:GetChildren())
	local topBar = mainFrame:FindFirstChild("TopBar")
	if not topBar then
		warn("TopBar missing! Children:", mainFrame:GetChildren())
		return
	end
	local currencyDisplay = topBar:FindFirstChild("CurrencyDisplay")
	if not currencyDisplay then
		warn("CurrencyDisplay missing! Children:", topBar:GetChildren())
		return
	end
	local coinsLabel = currencyDisplay:FindFirstChild("CoinsLabel")
	local gemsLabel = currencyDisplay:FindFirstChild("GemsLabel")
	if not coinsLabel or not gemsLabel then
		warn("CoinsLabel or GemsLabel missing! Children:", currencyDisplay:GetChildren())
		return
	end

	coinsLabel.Text = `Coins: {coins}`
	gemsLabel.Text = `Gems: {gems}`
	print("Currency display updated successfully")
end

-- Show facility UI
function GameScreen:ShowFacilityUI(facilityData: { [string]: any })
	local container = self.Instance.MainFrame.FacilityUIContainer
	container.Visible = true

	-- TODO: Populate facility UI with data
end

-- Hide facility UI
function GameScreen:HideFacilityUI()
	local container = self.Instance.MainFrame.FacilityUIContainer
	container.Visible = false
end

function GameScreen:UpdateCurrencyFromService(economyService, player)
	economyService = economyService or self._economyService
	local coins = economyService:GetBalance(player, "coins")
	local gems = economyService:GetBalance(player, "gems")
	self:UpdateCurrency(coins, gems)
end

return GameScreen
