local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Config = require(ReplicatedStorage.Core.Config)

local FacilityUI = {}

-- Initialize the Facility UI
function FacilityUI:Init(businessService)
	self.upgradePanel = nil
	self.resourceIndicators = {}
	self.statusDisplays = {}
	self.businessService = businessService
	self.businessId = nil

	-- Create sound effects
	self.sounds = {
		upgrade = Instance.new("Sound"),
		error = Instance.new("Sound"),
		hover = Instance.new("Sound"),
		click = Instance.new("Sound"),
	}

	-- Configure sounds
	self.sounds.upgrade.SoundId = "rbxassetid://1234567896" -- Replace with your upgrade sound
	self.sounds.error.SoundId = "rbxassetid://1234567897" -- Replace with your error sound
	self.sounds.hover.SoundId = "rbxassetid://1234567898" -- Replace with your hover sound
	self.sounds.click.SoundId = "rbxassetid://1234567899" -- Replace with your click sound

	-- Set volume and parent
	for _, sound in pairs(self.sounds) do
		sound.Volume = 0.5
		sound.Parent = SoundService
	end
end

-- Create animation for UI elements
local function createAnimation(instance: Instance, properties: { [string]: any }, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	return TweenService:Create(instance, tweenInfo, properties)
end

-- Create the upgrade panel
function FacilityUI:CreateUpgradePanel()
	-- Create a larger, more visible frame for the upgrade panel, positioned on the left
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 400)
	frame.Position = UDim2.new(0, 20, 0.5, -200) -- Left side, vertically centered
	frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.1
	frame.Visible = false

	-- Add a subtle gradient background
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35)),
	})
	gradient.Rotation = 45
	gradient.Parent = frame

	-- Add corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	-- Title with icon
	local titleContainer = Instance.new("Frame")
	titleContainer.Name = "TitleContainer"
	titleContainer.Size = UDim2.new(1, -40, 0, 40)
	titleContainer.Position = UDim2.new(0, 20, 0, 10)
	titleContainer.BackgroundTransparency = 1
	titleContainer.Parent = frame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.Text = "Facility Upgrades"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleContainer

	-- Close button with hover effect and animation
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

	-- Add corner radius to close button
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	-- Add hover effect with animation
	local function onHover(button)
		self.sounds.hover:Play()
		createAnimation(button, {
			BackgroundColor3 = Color3.fromRGB(220, 70, 70),
			Size = UDim2.new(0, 34, 0, 34),
		}, 0.2):Play()
	end

	local function onUnhover(button)
		createAnimation(button, {
			BackgroundColor3 = Color3.fromRGB(200, 60, 60),
			Size = UDim2.new(0, 32, 0, 32),
		}, 0.2):Play()
	end

	closeButton.MouseEnter:Connect(function()
		onHover(closeButton)
	end)
	closeButton.MouseLeave:Connect(function()
		onUnhover(closeButton)
	end)
	closeButton.MouseButton1Click:Connect(function()
		self.sounds.click:Play()
		createAnimation(frame, {
			Position = UDim2.new(-1, 20, 0.5, -200),
			BackgroundTransparency = 1,
		}, 0.3).Completed:Connect(function()
			frame.Visible = false
			frame.Position = UDim2.new(0, 20, 0.5, -200)
			frame.BackgroundTransparency = 0.1
		end)
	end)

	-- Create upgrade sections with progress bars and animations
	local upgrades = {
		{ name = "Capacity", icon = "rbxassetid://1234567890", description = "Increases storage capacity" },
		{ name = "Speed", icon = "rbxassetid://1234567891", description = "Improves processing speed" },
		{ name = "Efficiency", icon = "rbxassetid://1234567892", description = "Reduces resource consumption" },
	}

	local yOffset = 60
	for _, upgrade in ipairs(upgrades) do
		local section = Instance.new("Frame")
		section.Size = UDim2.new(1, -40, 0, 80)
		section.Position = UDim2.new(0, 20, 0, yOffset)
		section.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		section.BorderSizePixel = 0
		section.Parent = frame

		-- Add corner radius to section
		local sectionCorner = Instance.new("UICorner")
		sectionCorner.CornerRadius = UDim.new(0, 6)
		sectionCorner.Parent = section

		-- Add hover effect with animation
		section.MouseEnter:Connect(function()
			self.sounds.hover:Play()
			createAnimation(section, {
				BackgroundColor3 = Color3.fromRGB(70, 70, 70),
			}, 0.2):Play()
		end)

		section.MouseLeave:Connect(function()
			createAnimation(section, {
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			}, 0.2):Play()
		end)

		-- Upgrade name and icon
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -20, 0, 24)
		nameLabel.Position = UDim2.new(0, 10, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = upgrade.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 18
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = section

		-- Progress bar with animation
		local progressBar = Instance.new("Frame")
		progressBar.Name = "ProgressBar"
		progressBar.Size = UDim2.new(1, -20, 0, 6)
		progressBar.Position = UDim2.new(0, 10, 0, 34)
		progressBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		progressBar.BorderSizePixel = 0
		progressBar.Parent = section

		local progressCorner = Instance.new("UICorner")
		progressCorner.CornerRadius = UDim.new(0, 3)
		progressCorner.Parent = progressBar

		local progressFill = Instance.new("Frame")
		progressFill.Name = "ProgressFill"
		progressFill.Size = UDim2.new(0, 0, 1, 0)
		progressFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		progressFill.BorderSizePixel = 0
		progressFill.Parent = progressBar

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 3)
		fillCorner.Parent = progressFill

		-- Upgrade button with animation
		local upgradeButton = Instance.new("TextButton")
		upgradeButton.Name = "UpgradeButton"
		upgradeButton.Size = UDim2.new(0, 100, 0, 30)
		upgradeButton.Position = UDim2.new(1, -110, 0, 40)
		upgradeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		upgradeButton.Text = "Upgrade"
		upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		upgradeButton.TextSize = 14
		upgradeButton.Font = Enum.Font.GothamBold
		upgradeButton.Parent = section

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 6)
		buttonCorner.Parent = upgradeButton

		-- Add hover effect with animation
		upgradeButton.MouseEnter:Connect(function()
			self.sounds.hover:Play()
			createAnimation(upgradeButton, {
				BackgroundColor3 = Color3.fromRGB(0, 190, 255),
				Size = UDim2.new(0, 102, 0, 32),
			}, 0.2):Play()
		end)

		upgradeButton.MouseLeave:Connect(function()
			createAnimation(upgradeButton, {
				BackgroundColor3 = Color3.fromRGB(0, 170, 255),
				Size = UDim2.new(0, 100, 0, 30),
			}, 0.2):Play()
		end)

		-- Tooltip with fade animation
		local tooltip = Instance.new("TextLabel")
		tooltip.Size = UDim2.new(0, 200, 0, 40)
		tooltip.Position = UDim2.new(0, 10, 1, 5)
		tooltip.BackgroundTransparency = 1
		tooltip.Text = upgrade.description
		tooltip.TextColor3 = Color3.fromRGB(200, 200, 200)
		tooltip.TextSize = 12
		tooltip.Font = Enum.Font.Gotham
		tooltip.TextXAlignment = Enum.TextXAlignment.Left
		tooltip.TextWrapped = true
		tooltip.Visible = false
		tooltip.Parent = section

		-- Show/hide tooltip with animation
		section.MouseEnter:Connect(function()
			tooltip.Visible = true
			createAnimation(tooltip, {
				TextTransparency = 0,
			}, 0.2):Play()
		end)

		section.MouseLeave:Connect(function()
			createAnimation(tooltip, {
				TextTransparency = 1,
			}, 0.2).Completed:Connect(function()
				tooltip.Visible = false
			end)
		end)

		yOffset += 90
	end

	self.upgradePanel = frame
	return frame
end

-- Create resource indicators
function FacilityUI:CreateResourceIndicators()
	-- Create a container for resource indicators
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 60)
	container.Position = UDim2.new(0, 20, 0, 320)
	container.BackgroundTransparency = 1
	container.Parent = self.upgradePanel

	-- Input resource indicator
	local inputContainer = Instance.new("Frame")
	inputContainer.Size = UDim2.new(0.5, -10, 1, 0)
	inputContainer.Position = UDim2.new(0, 0, 0, 0)
	inputContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	inputContainer.BorderSizePixel = 0
	inputContainer.Parent = container

	local inputIcon = Instance.new("ImageLabel")
	inputIcon.Size = UDim2.new(0, 24, 0, 24)
	inputIcon.Position = UDim2.new(0, 10, 0.5, -12)
	inputIcon.BackgroundTransparency = 1
	inputIcon.Image = "rbxassetid://1234567893" -- Replace with your input icon
	inputIcon.Parent = inputContainer

	local inputLabel = Instance.new("TextLabel")
	inputLabel.Size = UDim2.new(1, -50, 1, 0)
	inputLabel.Position = UDim2.new(0, 40, 0, 0)
	inputLabel.BackgroundTransparency = 1
	inputLabel.Text = "Input: 0"
	inputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputLabel.TextSize = 16
	inputLabel.Font = Enum.Font.GothamMedium
	inputLabel.TextXAlignment = Enum.TextXAlignment.Left
	inputLabel.Parent = inputContainer

	-- Output resource indicator
	local outputContainer = Instance.new("Frame")
	outputContainer.Size = UDim2.new(0.5, -10, 1, 0)
	outputContainer.Position = UDim2.new(0.5, 10, 0, 0)
	outputContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	outputContainer.BorderSizePixel = 0
	outputContainer.Parent = container

	local outputIcon = Instance.new("ImageLabel")
	outputIcon.Size = UDim2.new(0, 24, 0, 24)
	outputIcon.Position = UDim2.new(0, 10, 0.5, -12)
	outputIcon.BackgroundTransparency = 1
	outputIcon.Image = "rbxassetid://1234567894" -- Replace with your output icon
	outputIcon.Parent = outputContainer

	local outputLabel = Instance.new("TextLabel")
	outputLabel.Size = UDim2.new(1, -50, 1, 0)
	outputLabel.Position = UDim2.new(0, 40, 0, 0)
	outputLabel.BackgroundTransparency = 1
	outputLabel.Text = "Output: 0"
	outputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	outputLabel.TextSize = 16
	outputLabel.Font = Enum.Font.GothamMedium
	outputLabel.TextXAlignment = Enum.TextXAlignment.Left
	outputLabel.Parent = outputContainer

	self.resourceIndicators = {
		input = inputLabel,
		output = outputLabel,
	}
end

-- Create status displays
function FacilityUI:CreateStatusDisplays()
	-- Create a container for status displays
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -40, 0, 40)
	container.Position = UDim2.new(0, 20, 0, 390)
	container.BackgroundTransparency = 1
	container.Parent = self.upgradePanel

	-- Status indicator
	local statusContainer = Instance.new("Frame")
	statusContainer.Size = UDim2.new(1, 0, 1, 0)
	statusContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	statusContainer.BorderSizePixel = 0
	statusContainer.Parent = container

	local statusIcon = Instance.new("ImageLabel")
	statusIcon.Size = UDim2.new(0, 24, 0, 24)
	statusIcon.Position = UDim2.new(0, 10, 0.5, -12)
	statusIcon.BackgroundTransparency = 1
	statusIcon.Image = "rbxassetid://1234567895" -- Replace with your status icon
	statusIcon.Parent = statusContainer

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -50, 1, 0)
	statusLabel.Position = UDim2.new(0, 40, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Status: Idle"
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.TextSize = 16
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = statusContainer

	-- Add status color indicators
	local function updateStatusColor(status: string)
		local color = Color3.fromRGB(255, 255, 255) -- Default white
		if status == "idle" then
			color = Color3.fromRGB(200, 200, 200) -- Gray
		elseif status == "active" then
			color = Color3.fromRGB(0, 255, 0) -- Green
		elseif status == "upgrading" then
			color = Color3.fromRGB(255, 165, 0) -- Orange
		elseif status == "error" then
			color = Color3.fromRGB(255, 0, 0) -- Red
		end
		statusLabel.TextColor3 = color
	end

	self.statusDisplays = {
		status = statusLabel,
		updateColor = updateStatusColor,
	}
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
	if not self.upgradePanel then
		return
	end

	self.upgradePanel.Visible = true
	self.businessId = businessId

	-- Animate panel entrance
	createAnimation(self.upgradePanel, {
		Position = UDim2.new(0, 20, 0.5, -200),
		BackgroundTransparency = 0.1,
	}, 0.3):Play()

	-- Update resource indicators with animation
	if self.resourceIndicators.input then
		local inputAmount = businessState.input or 0
		local oldText = self.resourceIndicators.input.Text
		self.resourceIndicators.input.Text = `Input: {inputAmount}`

		-- Animate text change
		if oldText ~= self.resourceIndicators.input.Text then
			createAnimation(self.resourceIndicators.input, {
				TextColor3 = Color3.fromRGB(0, 255, 0),
			}, 0.2).Completed:Connect(function()
				createAnimation(self.resourceIndicators.input, {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}, 0.2):Play()
			end)
		end
	end

	if self.resourceIndicators.output then
		local outputAmount = businessState.output or 0
		local oldText = self.resourceIndicators.output.Text
		self.resourceIndicators.output.Text = `Output: {outputAmount}`

		-- Animate text change
		if oldText ~= self.resourceIndicators.output.Text then
			createAnimation(self.resourceIndicators.output, {
				TextColor3 = Color3.fromRGB(0, 255, 0),
			}, 0.2).Completed:Connect(function()
				createAnimation(self.resourceIndicators.output, {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}, 0.2):Play()
			end)
		end
	end

	-- Update status display with color and animation
	if self.statusDisplays.status then
		local status = businessState.state or "idle"
		local oldStatus = self.statusDisplays.status.Text
		self.statusDisplays.status.Text = `Status: {status:upper()}`

		if oldStatus ~= self.statusDisplays.status.Text then
			createAnimation(self.statusDisplays.status, {
				TextTransparency = 0.5,
			}, 0.1).Completed:Connect(function()
				if self.statusDisplays.updateColor then
					self.statusDisplays.updateColor(status)
				end
				createAnimation(self.statusDisplays.status, {
					TextTransparency = 0,
				}, 0.1):Play()
			end)
		end
	end

	-- Update upgrade progress bars and buttons with animations
	for _, upgrade in ipairs(Config.BUSINESS_UPGRADES) do
		local upgradeName = upgrade.name:lower()
		local currentLevel = businessState.upgrades[upgradeName] or 0
		local maxLevel = upgrade.maxLevel
		local progress = currentLevel / maxLevel

		local section = self.upgradePanel:FindFirstChild(upgrade.name)
		if section then
			-- Update progress bar with animation
			local progressBar = section:FindFirstChild("ProgressBar")
			if progressBar then
				local progressFill = progressBar:FindFirstChild("ProgressFill")
				if progressFill then
					createAnimation(progressFill, {
						Size = UDim2.new(progress, 0, 1, 0),
					}, 0.3):Play()
				end
			end

			-- Update upgrade button state with animation
			local upgradeButton = section:FindFirstChild("UpgradeButton")
			if upgradeButton then
				local canUpgrade = currentLevel < maxLevel
				local newColor = canUpgrade and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)

				createAnimation(upgradeButton, {
					BackgroundColor3 = newColor,
				}, 0.2):Play()

				upgradeButton.Text = canUpgrade and "Upgrade" or "MAX"
				upgradeButton.Active = canUpgrade
			end

			-- Update cost display with animation
			local costLabel = section:FindFirstChild("CostLabel")
			if costLabel then
				local cost = upgrade.cost * (currentLevel + 1)
				local oldCost = costLabel.Text
				costLabel.Text = `Cost: {cost}`

				if oldCost ~= costLabel.Text then
					createAnimation(costLabel, {
						TextColor3 = Color3.fromRGB(255, 165, 0),
					}, 0.2).Completed:Connect(function()
						createAnimation(costLabel, {
							TextColor3 = Color3.fromRGB(255, 255, 255),
						}, 0.2):Play()
					end)
				end
			end
		end
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
