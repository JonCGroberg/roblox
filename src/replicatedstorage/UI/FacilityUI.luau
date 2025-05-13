local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FacilityUI = {}

-- Initialize the Facility UI
function FacilityUI:Init(businessService)
	self.upgradePanel = nil
	self.resourceIndicators = {}
	self.statusDisplays = {}
	self.businessService = businessService
	self.businessId = nil
end

-- Create the upgrade panel
function FacilityUI:CreateUpgradePanel()
	-- Create a larger, more visible frame for the upgrade panel, positioned on the left
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 400)
	frame.Position = UDim2.new(0, 20, 0.5, -200) -- Left side, vertically centered
	frame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	frame.BackgroundTransparency = 0
	frame.Visible = false

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 40)
	title.Position = UDim2.new(0, 20, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "Facility Upgrades"
	title.TextColor3 = Color3.fromRGB(40, 40, 40)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 32, 0, 32)
	closeButton.Position = UDim2.new(1, -42, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = frame
	closeButton.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	-- Upgrade sections (vertical)
	local upgrades = {
		{ name = "Capacity", icon = "rbxassetid://1234567890" },
		{ name = "Speed", icon = "rbxassetid://1234567891" },
		{ name = "Efficiency", icon = "rbxassetid://1234567892" },
	}
	for i, upgrade in ipairs(upgrades) do
		local sectionY = 60 + (i - 1) * 90

		-- Icon
		local icon = Instance.new("ImageLabel")
		icon.Name = upgrade.name .. "Icon"
		icon.Size = UDim2.new(0, 40, 0, 40)
		icon.Position = UDim2.new(0, 20, 0, sectionY)
		icon.BackgroundTransparency = 1
		icon.Image = upgrade.icon
		icon.Parent = frame

		-- Label
		local label = Instance.new("TextLabel")
		label.Name = upgrade.name .. "Label"
		label.Size = UDim2.new(0, 80, 0, 40)
		label.Position = UDim2.new(0, 70, 0, sectionY)
		label.BackgroundTransparency = 1
		label.Text = upgrade.name
		label.TextColor3 = Color3.fromRGB(40, 40, 40)
		label.TextSize = 20
		label.Font = Enum.Font.GothamMedium
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = frame

		-- Current value
		local currentValue = Instance.new("TextLabel")
		currentValue.Name = upgrade.name .. "CurrentValue"
		currentValue.Size = UDim2.new(0, 60, 0, 20)
		currentValue.Position = UDim2.new(0, 70, 0, sectionY + 24)
		currentValue.BackgroundTransparency = 1
		currentValue.Text = "Current: 0"
		currentValue.TextColor3 = Color3.fromRGB(80, 80, 80)
		currentValue.TextSize = 14
		currentValue.Font = Enum.Font.Gotham
		currentValue.TextXAlignment = Enum.TextXAlignment.Left
		currentValue.Parent = frame

		-- Next value
		local nextValue = Instance.new("TextLabel")
		nextValue.Name = upgrade.name .. "NextValue"
		nextValue.Size = UDim2.new(0, 60, 0, 20)
		nextValue.Position = UDim2.new(0, 140, 0, sectionY + 24)
		nextValue.BackgroundTransparency = 1
		nextValue.Text = "Next: 0"
		nextValue.TextColor3 = Color3.fromRGB(80, 80, 80)
		nextValue.TextSize = 14
		nextValue.Font = Enum.Font.Gotham
		nextValue.TextXAlignment = Enum.TextXAlignment.Left
		nextValue.Parent = frame

		-- Cost display
		local cost = Instance.new("TextLabel")
		cost.Name = upgrade.name .. "Cost"
		cost.Size = UDim2.new(0, 60, 0, 20)
		cost.Position = UDim2.new(0, 210, 0, sectionY + 10)
		cost.BackgroundTransparency = 1
		cost.Text = "Cost: 0"
		cost.TextColor3 = Color3.fromRGB(0, 191, 255)
		cost.TextSize = 14
		cost.Font = Enum.Font.Gotham
		cost.TextXAlignment = Enum.TextXAlignment.Left
		cost.Parent = frame

		-- Upgrade button
		local upgradeButton = Instance.new("TextButton")
		upgradeButton.Name = upgrade.name .. "UpgradeButton"
		upgradeButton.Size = UDim2.new(0, 60, 0, 28)
		upgradeButton.Position = UDim2.new(0, 210, 0, sectionY + 34)
		upgradeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		upgradeButton.Text = "Upgrade"
		upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		upgradeButton.TextSize = 14
		upgradeButton.Font = Enum.Font.GothamBold
		upgradeButton.Parent = frame
	end

	self.upgradePanel = frame
	return frame
end

-- Create resource indicators
function FacilityUI:CreateResourceIndicators()
	local inputIndicator = Instance.new("TextLabel")
	inputIndicator.Size = UDim2.new(0, 180, 0, 28)
	inputIndicator.Position = UDim2.new(0.5, -90, 0, 12)
	inputIndicator.Text = "Input: 0"
	inputIndicator.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	inputIndicator.TextColor3 = Color3.fromRGB(40, 40, 40)
	inputIndicator.TextSize = 18
	inputIndicator.Font = Enum.Font.Gotham
	inputIndicator.Parent = self.upgradePanel
	self.resourceIndicators.input = inputIndicator

	local outputIndicator = Instance.new("TextLabel")
	outputIndicator.Size = UDim2.new(0, 180, 0, 28)
	outputIndicator.Position = UDim2.new(0.5, -90, 0, 44)
	outputIndicator.Text = "Output: 0"
	outputIndicator.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	outputIndicator.TextColor3 = Color3.fromRGB(40, 40, 40)
	outputIndicator.TextSize = 18
	outputIndicator.Font = Enum.Font.Gotham
	outputIndicator.Parent = self.upgradePanel
	self.resourceIndicators.output = outputIndicator
end

-- Create status displays
function FacilityUI:CreateStatusDisplays()
	local statusDisplay = Instance.new("TextLabel")
	statusDisplay.Size = UDim2.new(0, 180, 0, 28)
	statusDisplay.Position = UDim2.new(0.5, -90, 0, 92)
	statusDisplay.Text = "Status: Idle"
	statusDisplay.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	statusDisplay.TextColor3 = Color3.fromRGB(40, 40, 40)
	statusDisplay.TextSize = 18
	statusDisplay.Font = Enum.Font.Gotham
	statusDisplay.Parent = self.upgradePanel
	self.statusDisplays.status = statusDisplay
end

-- Add capacity sliders
function FacilityUI:AddCapacitySliders()
	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(0, 180, 0, 28)
	slider.Position = UDim2.new(0.5, -90, 0, 132)
	slider.Text = "Capacity: 50"
	slider.BackgroundColor3 = Color3.fromRGB(180, 220, 255)
	slider.TextColor3 = Color3.fromRGB(40, 40, 40)
	slider.TextSize = 18
	slider.Font = Enum.Font.Gotham
	slider.Parent = self.upgradePanel
	self.capacitySlider = slider
end

-- Add upgrade buttons
function FacilityUI:AddUpgradeButtons()
	local upgradeButton = Instance.new("TextButton")
	upgradeButton.Size = UDim2.new(0, 180, 0, 36)
	upgradeButton.Position = UDim2.new(0.5, -90, 0, 172)
	upgradeButton.Text = "Upgrade"
	upgradeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	upgradeButton.TextSize = 20
	upgradeButton.Font = Enum.Font.GothamBold
	upgradeButton.Parent = self.upgradePanel
	self.upgradeButton = upgradeButton -- Assign to self for later use
end

-- Add resource displays
function FacilityUI:AddResourceDisplays()
	local resourceDisplay = Instance.new("TextLabel")
	resourceDisplay.Size = UDim2.new(0, 180, 0, 28)
	resourceDisplay.Position = UDim2.new(0.5, -90, 0, 220)
	resourceDisplay.Text = "Resources: 0"
	resourceDisplay.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	resourceDisplay.TextColor3 = Color3.fromRGB(40, 40, 40)
	resourceDisplay.TextSize = 18
	resourceDisplay.Font = Enum.Font.Gotham
	resourceDisplay.Parent = self.upgradePanel
	self.resourceDisplay = resourceDisplay
end

-- Update the UI based on business state
function FacilityUI:UpdateUI(businessId: string, businessState: any)
	if self.upgradePanel then
		self.upgradePanel.Visible = true
		-- Update resource indicators
		self.resourceIndicators.input.Text = "Input: " .. tostring(businessState.input or 0)
		self.resourceIndicators.output.Text = "Output: " .. tostring(businessState.output or 0)
		-- Update status display
		self.statusDisplays.status.Text = "Status: " .. businessState.state
	end
end

-- Add slider behavior
function FacilityUI:AddSliderBehavior()
	self.capacitySlider.MouseButton1Click:Connect(function()
		-- Example: Increase capacity by 10
		local currentCapacity = tonumber(self.capacitySlider.Text:match("%d+")) or 0
		self.capacitySlider.Text = "Capacity: " .. tostring(currentCapacity + 10)
		-- Update business state or trigger other actions here
	end)
end

-- Add button click event
function FacilityUI:AddButtonClickEvent()
	self.upgradeButton.MouseButton1Click:Connect(function()
		-- Call upgrade method from BusinessService
		local success = self.businessService:UpgradeBusiness(self.businessId, "capacity", game.Players.LocalPlayer)
		if success then
			print("Upgrade successful!")
		else
			print("Upgrade failed!")
		end
	end)
end

return FacilityUI
