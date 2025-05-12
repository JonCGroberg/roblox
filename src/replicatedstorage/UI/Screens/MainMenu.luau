--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local Constants = require(ReplicatedStorage.Core.Constants)
local BaseComponent = require(ReplicatedStorage.UI.Components.BaseComponent)

local MainMenu = {}
MainMenu.__index = MainMenu
setmetatable(MainMenu, BaseComponent)

function MainMenu.new(uiService: Types.UIService?): Types.Screen
	-- Create the screen instance first
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainMenu"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Create the component with the instance
	local self = setmetatable(BaseComponent.new("MainMenu", screenGui), MainMenu)
	self._uiService = uiService

	-- Create main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1.1, 0)
	mainFrame.Position = UDim2.new(0, 0, -0.1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	mainFrame.BackgroundTransparency = 0
	mainFrame.Parent = screenGui

	-- Create title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0, 400, 0, 100)
	title.Position = UDim2.new(0.5, -200, 0.2, 0)
	title.BackgroundTransparency = 1
	title.Text = "Tycoon Game"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 48
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame

	-- Create play button
	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.new(0, 200, 0, 50)
	playButton.Position = UDim2.new(0.5, -100, 0.5, 0)
	playButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	playButton.Text = "Play"
	playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playButton.TextSize = 24
	playButton.Font = Enum.Font.GothamMedium
	playButton.Parent = mainFrame

	-- Create settings button
	local settingsButton = Instance.new("TextButton")
	settingsButton.Name = "SettingsButton"
	settingsButton.Size = UDim2.new(0, 200, 0, 50)
	settingsButton.Position = UDim2.new(0.5, -100, 0.5, 70)
	settingsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	settingsButton.Text = "Settings"
	settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	settingsButton.TextSize = 24
	settingsButton.Font = Enum.Font.GothamMedium
	settingsButton.Parent = mainFrame

	-- Create quit button
	local quitButton = Instance.new("TextButton")
	quitButton.Name = "QuitButton"
	quitButton.Size = UDim2.new(0, 200, 0, 50)
	quitButton.Position = UDim2.new(0.5, -100, 0.5, 140)
	quitButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	quitButton.Text = "Quit"
	quitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	quitButton.TextSize = 24
	quitButton.Font = Enum.Font.GothamMedium
	quitButton.Parent = mainFrame

	-- Add button hover effects
	local function setupButtonHover(button: TextButton, hoverColor: Color3)
		local originalColor = button.BackgroundColor3
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = hoverColor
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = originalColor
		end)
	end

	setupButtonHover(playButton, Color3.fromRGB(0, 100, 180))
	setupButtonHover(settingsButton, Color3.fromRGB(80, 80, 80))
	setupButtonHover(quitButton, Color3.fromRGB(180, 40, 40))

	-- Connect button events
	playButton.MouseButton1Click:Connect(function()
		print("Play clicked")
		print(self._uiService)
		if self._uiService then
			self._uiService:HideScreen("MainMenu", Constants.UI.TRANSITION_TYPES.FADE)
			self._uiService:ShowScreen("GameScreen", Constants.UI.TRANSITION_TYPES.FADE)
		end
	end)

	settingsButton.MouseButton1Click:Connect(function()
		-- TODO: Implement settings menu
		print("Settings clicked")
	end)

	quitButton.MouseButton1Click:Connect(function()
		-- TODO: Implement quit functionality
		print("Quit clicked")
	end)

	return (self :: any) :: Types.Screen
end

return MainMenu
