--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Types = require(game:GetService("ReplicatedStorage").Core.Types)
local Constants = require(game:GetService("ReplicatedStorage").Core.Constants)

-- Service
local UIService = {}
UIService.__index = UIService

function UIService.new(): Types.UIService
	local self = setmetatable({}, UIService)

	self._screens = {}
	self._components = {}
	self._playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self._activeScreen = nil
	self._transitionTween = nil

	return (self :: any) :: Types.UIService
end

function UIService:Init()
	-- Create base UI folder
	local uiFolder = Instance.new("Folder")
	uiFolder.Name = "GameUI"
	uiFolder.Parent = self._playerGui
end

function UIService:RegisterScreen(screen: Types.Screen)
	if self._screens[screen.Name] then
		warn(`Screen {screen.Name} already registered`)
		return
	end

	screen.Instance.Parent = self._playerGui:WaitForChild("GameUI")
	screen.Instance.Enabled = false -- Ensure screen is hidden when registered
	self._screens[screen.Name] = screen
end

function UIService:RegisterComponent(component: Types.Component)
	if self._components[component.Name] then
		warn(`Component {component.Name} already registered`)
		return
	end

	component.Instance.Parent = self._playerGui:WaitForChild("GameUI")
	self._components[component.Name] = component
end

function UIService:GetScreen(name: string): Types.Screen?
	return self._screens[name]
end

function UIService:GetComponent(name: string): Types.Component?
	return self._components[name]
end

function UIService:_createTransitionTween(instance: GuiObject, transition: string, isShowing: boolean): Tween
	local startProps = {}
	local endProps = {}

	-- Get the main frame of the screen
	local frame = instance:FindFirstChild("MainFrame")
	if not frame then
		warn("No MainFrame found in screen instance")
		return TweenService:Create(instance, TweenInfo.new(0), {}) -- Return empty tween instead of nil
	end

	-- Initialize default position
	local defaultPosition = UDim2.new(0, 0, 0, 0)
	startProps.Position = defaultPosition
	endProps.Position = defaultPosition

	if transition == Constants.UI.TRANSITION_TYPES.FADE then
		startProps.BackgroundTransparency = isShowing and 1 or 0
		endProps.BackgroundTransparency = isShowing and 0 or 1
	elseif transition == Constants.UI.TRANSITION_TYPES.SLIDE_LEFT then
		startProps.Position = isShowing and UDim2.new(1, 0, 0, 0) or defaultPosition
		endProps.Position = isShowing and defaultPosition or UDim2.new(-1, 0, 0, 0)
	elseif transition == Constants.UI.TRANSITION_TYPES.SLIDE_RIGHT then
		startProps.Position = isShowing and UDim2.new(-1, 0, 0, 0) or defaultPosition
		endProps.Position = isShowing and defaultPosition or UDim2.new(1, 0, 0, 0)
	elseif transition == Constants.UI.TRANSITION_TYPES.SLIDE_UP then
		startProps.Position = isShowing and UDim2.new(0, 0, 1, 0) or defaultPosition
		endProps.Position = isShowing and defaultPosition or UDim2.new(0, 0, -1, 0)
	elseif transition == Constants.UI.TRANSITION_TYPES.SLIDE_DOWN then
		startProps.Position = isShowing and UDim2.new(0, 0, -1, 0) or defaultPosition
		endProps.Position = isShowing and defaultPosition or UDim2.new(0, 0, 1, 0)
	end

	if frame:IsA("GuiObject") then
		frame.BackgroundTransparency = startProps.BackgroundTransparency
		frame.Position = startProps.Position
	end

	return TweenService:Create(frame, TweenInfo.new(Constants.UI.TRANSITION_DURATION), endProps)
end

function UIService:ShowScreen(name: string, transition: string?)
	print(`Showing screen: {name}`)
	local screen = self._screens[name]
	if not screen then
		warn(`Screen {name} not found`)
		return
	end

	-- Hide current screen if exists
	if self._activeScreen then
		print(`Hiding current screen: {self._activeScreen.Name}`)
		self:HideScreen(self._activeScreen.Name, transition)
	end

	-- Enable the screen (no background transition)
	screen.Instance.Enabled = true
	self._activeScreen = screen
	print(`Screen {name} is now visible`)
end

function UIService:HideScreen(name: string, transition: string?)
	print(`Hiding screen: {name}`)
	local screen = self._screens[name]
	if not screen then
		warn(`Screen {name} not found`)
		return
	end

	-- Disable the screen (no background transition)
	screen.Instance.Enabled = false

	if self._activeScreen == screen then
		self._activeScreen = nil
	end
	print(`Screen {name} is now hidden`)
end

function UIService:ShowComponent(name: string)
	local component = self._components[name]
	if not component then
		warn(`Component {name} not found`)
		return
	end

	component:Show()
end

function UIService:HideComponent(name: string)
	local component = self._components[name]
	if not component then
		warn(`Component {name} not found`)
		return
	end

	component:Hide()
end

return UIService
