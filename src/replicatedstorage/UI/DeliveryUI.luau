local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage.Core.Config)
local Types = require(ReplicatedStorage.Core.Types)
local BotModels = require(ReplicatedStorage.UI.BotModels)

local DeliveryUI = {}

function DeliveryUI:Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	self.screenGui = playerGui:FindFirstChild("DeliveryUI") or Instance.new("ScreenGui")
	self.screenGui.Name = "DeliveryUI"
	self.screenGui.Parent = playerGui

	self.bots = {}
	self.queue = {}
	self.pathVisualizations = {}
	self.selectedBotId = nil
	self.selectingDestination = false
	self.botIndicators = {}
	self.botModels = {}

	self:CreateBotStatusPanel()
	self:CreateQueuePanel()
	self:CreateTestButtons()
	self:CreateRouteVisualizer()
	self:SetDestinationButton()
	self:CreatePauseResumeButtons()
	self:CreateReturnToAutoButton()

	-- Listen for server updates
	local botEvent = ReplicatedStorage:WaitForChild("DeliveryBotUpdate")
	local queueEvent = ReplicatedStorage:WaitForChild("DeliveryQueueUpdate")
	botEvent.OnClientEvent:Connect(function(bots)
		self.bots = bots
		self:UpdateBotStatusPanel()
		self:UpdateRouteVisualizations()
		self:UpdateBotIndicators()
		self:UpdateBotModels()
	end)
	queueEvent.OnClientEvent:Connect(function(queue)
		self.queue = queue
		self:UpdateQueuePanel()
	end)

	print("[DeliveryUI] Initialized.")
end

function DeliveryUI:CreateBotStatusPanel()
	local panel = Instance.new("Frame")
	panel.Name = "BotStatusPanel"
	panel.Size = UDim2.new(0, 320, 0, 180)
	panel.Position = UDim2.new(1, -340, 0, 40)
	panel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Parent = self.screenGui

	local title = Instance.new("TextLabel")
	title.Text = "Delivery Bots"
	title.Size = UDim2.new(1, 0, 0, 32)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = panel

	self.botStatusPanel = panel
	self:UpdateBotStatusPanel()
end

function DeliveryUI:UpdateBotStatusPanel()
	if not self.botStatusPanel then
		return
	end
	-- Remove old rows
	for _, child in ipairs(self.botStatusPanel:GetChildren()) do
		if child:IsA("Frame") and child.Name == "BotRow" then
			child:Destroy()
		end
	end
	-- Add new rows
	local selectedBot = nil
	for i, bot in ipairs(self.bots) do
		local row = Instance.new("Frame")
		row.Name = "BotRow"
		row.Size = UDim2.new(1, -20, 0, 60) -- Increased height for battery bar
		row.Position = UDim2.new(0, 10, 0, 32 + (i - 1) * 64) -- Adjusted spacing
		row.BackgroundTransparency = 1
		row.Parent = self.botStatusPanel

		-- Highlight if selected
		if self.selectedBotId == bot.id then
			row.BackgroundTransparency = 0.2
			row.BackgroundColor3 = Color3.fromRGB(255, 255, 120)
			selectedBot = bot
		end

		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.selectedBotId = bot.id
				self:UpdateBotStatusPanel()
				self:UpdateRouteVisualizations()
				if self.setDestBtn then
					self.setDestBtn.Visible = true
				end
			end
		end)

		local name = Instance.new("TextLabel")
		name.Text = bot.id .. " (" .. bot.type .. ")"
		name.Size = UDim2.new(0.35, 0, 0, 20)
		name.Position = UDim2.new(0, 0, 0, 0)
		name.BackgroundTransparency = 1
		name.TextColor3 = Color3.fromRGB(200, 200, 255)
		name.TextSize = 16
		name.Font = Enum.Font.Gotham
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Parent = row

		local state = Instance.new("TextLabel")
		state.Text = bot.state
		state.Size = UDim2.new(0.25, 0, 0, 20)
		state.Position = UDim2.new(0.35, 0, 0, 0)
		state.BackgroundTransparency = 1
		state.TextColor3 = (
			bot.state == "idle" and Color3.fromRGB(120, 255, 120)
			or bot.state == "moving" and Color3.fromRGB(120, 180, 255)
			or bot.state == "charging" and Color3.fromRGB(255, 200, 100)
			or bot.state == "maintenance" and Color3.fromRGB(255, 150, 100)
			or bot.state == "error" and Color3.fromRGB(255, 120, 120)
			or Color3.fromRGB(255, 255, 255)
		)
		state.TextSize = 16
		state.Font = Enum.Font.Gotham
		state.TextXAlignment = Enum.TextXAlignment.Left
		state.Parent = row

		local carrying = Instance.new("TextLabel")
		local carryingAmount = 0
		for _, v in pairs(bot.carrying or {}) do
			carryingAmount = carryingAmount + v
		end
		carrying.Text = "Carrying: " .. carryingAmount
		carrying.Size = UDim2.new(0.4, 0, 0, 20)
		carrying.Position = UDim2.new(0.6, 0, 0, 0)
		carrying.BackgroundTransparency = 1
		carrying.TextColor3 = Color3.fromRGB(180, 255, 180)
		carrying.TextSize = 16
		carrying.Font = Enum.Font.Gotham
		carrying.TextXAlignment = Enum.TextXAlignment.Left
		carrying.Parent = row

		-- Battery bar
		local batteryBar = Instance.new("Frame")
		batteryBar.Name = "BatteryBar"
		batteryBar.Size = UDim2.new(0.95, 0, 0, 8)
		batteryBar.Position = UDim2.new(0.025, 0, 0, 25)
		batteryBar.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
		batteryBar.BorderSizePixel = 0
		batteryBar.Parent = row

		local batteryFill = Instance.new("Frame")
		batteryFill.Name = "BatteryFill"
		batteryFill.Size = UDim2.new(bot.battery or 1, 0, 1, 0)
		batteryFill.BackgroundColor3 = (
			bot.battery > 0.7 and Color3.fromRGB(120, 255, 120)
			or bot.battery > 0.3 and Color3.fromRGB(255, 200, 100)
			or Color3.fromRGB(255, 120, 120)
		)
		batteryFill.BorderSizePixel = 0
		batteryFill.Parent = batteryBar

		-- Maintenance progress bar (if in maintenance)
		if bot.state == "maintenance" then
			local maintenanceBar = Instance.new("Frame")
			maintenanceBar.Name = "MaintenanceBar"
			maintenanceBar.Size = UDim2.new(0.95, 0, 0, 8)
			maintenanceBar.Position = UDim2.new(0.025, 0, 0, 35)
			maintenanceBar.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
			maintenanceBar.BorderSizePixel = 0
			maintenanceBar.Parent = row

			local maintenanceFill = Instance.new("Frame")
			maintenanceFill.Name = "MaintenanceFill"
			maintenanceFill.Size = UDim2.new(bot.maintenanceProgress or 0, 0, 1, 0)
			maintenanceFill.BackgroundColor3 = Color3.fromRGB(255, 150, 100)
			maintenanceFill.BorderSizePixel = 0
			maintenanceFill.Parent = maintenanceBar
		end

		-- Progress bar for moving bots
		if bot.state == "moving" then
			local progressBar = Instance.new("Frame")
			progressBar.Name = "ProgressBar"
			progressBar.Size = UDim2.new(0.95, 0, 0, 8)
			progressBar.Position = UDim2.new(0.025, 0, 0, 35)
			progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
			progressBar.BorderSizePixel = 0
			progressBar.Parent = row

			local progressFill = Instance.new("Frame")
			progressFill.Name = "ProgressFill"
			progressFill.Size = UDim2.new(0.1, 0, 1, 0) -- Start small, animate below
			progressFill.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
			progressFill.BorderSizePixel = 0
			progressFill.Parent = progressBar

			-- Animate progress bar (simulate, since we don't have exact timing info)
			local tweenService = game:GetService("TweenService")
			local tween = tweenService:Create(
				progressFill,
				TweenInfo.new(3, Enum.EasingStyle.Linear),
				{ Size = UDim2.new(1, 0, 1, 0) }
			)
			tween:Play()
		end
	end
	if self.setDestBtn then
		self.setDestBtn.Visible = self.selectedBotId ~= nil
	end

	-- Show/hide pause/resume buttons
	if self.pauseBtn and self.resumeBtn then
		if selectedBot then
			self.pauseBtn.Visible = not selectedBot.paused
			self.resumeBtn.Visible = selectedBot.paused
		else
			self.pauseBtn.Visible = false
			self.resumeBtn.Visible = false
		end
	end

	-- Show/hide Return to Auto button
	if self.returnAutoBtn then
		if selectedBot and not selectedBot.paused and selectedBot.path and selectedBot.target then
			self.returnAutoBtn.Visible = true
		else
			self.returnAutoBtn.Visible = false
		end
	end
end

function DeliveryUI:CreateQueuePanel()
	local panel = Instance.new("Frame")
	panel.Name = "QueuePanel"
	panel.Size = UDim2.new(0, 320, 0, 120)
	panel.Position = UDim2.new(1, -340, 0, 230)
	panel.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Parent = self.screenGui

	local title = Instance.new("TextLabel")
	title.Text = "Delivery Queue"
	title.Size = UDim2.new(1, 0, 0, 32)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = panel

	self.queuePanel = panel
	self:UpdateQueuePanel()
end

function DeliveryUI:UpdateQueuePanel()
	if not self.queuePanel then
		return
	end
	for _, child in ipairs(self.queuePanel:GetChildren()) do
		if child:IsA("Frame") and child.Name == "QueueRow" then
			child:Destroy()
		end
	end
	for i, task in ipairs(self.queue) do
		local row = Instance.new("Frame")
		row.Name = "QueueRow"
		row.Size = UDim2.new(1, -20, 0, 28)
		row.Position = UDim2.new(0, 10, 0, 32 + (i - 1) * 30)
		row.BackgroundTransparency = 1
		row.Parent = self.queuePanel

		local desc = Instance.new("TextLabel")
		desc.Text = task.resourceId .. " x" .. task.amount
		desc.Size = UDim2.new(0.45, 0, 1, 0)
		desc.Position = UDim2.new(0, 0, 0, 0)
		desc.BackgroundTransparency = 1
		desc.TextColor3 = Color3.fromRGB(255, 220, 180)
		desc.TextSize = 15
		desc.Font = Enum.Font.Gotham
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.Parent = row

		local priority = Instance.new("TextLabel")
		priority.Text = "Priority: " .. task.priority
		priority.Size = UDim2.new(0.25, 0, 1, 0)
		priority.Position = UDim2.new(0.45, 0, 0, 0)
		priority.BackgroundTransparency = 1
		priority.TextColor3 = (
			task.priority == 3 and Color3.fromRGB(255, 100, 100)
			or task.priority == 2 and Color3.fromRGB(255, 200, 100)
			or Color3.fromRGB(180, 255, 180)
		)
		priority.TextSize = 15
		priority.Font = Enum.Font.Gotham
		priority.TextXAlignment = Enum.TextXAlignment.Left
		priority.Parent = row

		local status = Instance.new("TextLabel")
		status.Text = task.status
		status.Size = UDim2.new(0.3, 0, 1, 0)
		status.Position = UDim2.new(0.7, 0, 0, 0)
		status.BackgroundTransparency = 1
		status.TextColor3 = (
			task.status == "pending" and Color3.fromRGB(255, 255, 180)
			or task.status == "in_progress" and Color3.fromRGB(120, 180, 255)
			or task.status == "completed" and Color3.fromRGB(180, 255, 180)
			or Color3.fromRGB(255, 180, 180)
		)
		status.TextSize = 15
		status.Font = Enum.Font.Gotham
		status.TextXAlignment = Enum.TextXAlignment.Left
		status.Parent = row
	end
end

function DeliveryUI:CreateRouteVisualizer()
	-- Create a folder for path visualizations
	self.pathFolder = Instance.new("Folder")
	self.pathFolder.Name = "PathVisualizations"
	self.pathFolder.Parent = workspace
end

function DeliveryUI:UpdateRouteVisualizations()
	-- Clear existing path visualizations
	for _, path in pairs(self.pathVisualizations) do
		path:Destroy()
	end
	self.pathVisualizations = {}

	-- Create new path visualizations for each bot
	for _, bot in ipairs(self.bots) do
		if bot.path and bot.path.nodes then
			local colorOverride = nil
			if self.selectedBotId == bot.id then
				colorOverride = Color3.fromRGB(255, 255, 80) -- Highlight color
			end
			local path = self:CreatePathVisualization(bot.path.nodes, bot.state, colorOverride)
			if path then
				self.pathVisualizations[bot.id] = path
			end
		end
	end
end

function DeliveryUI:CreatePathVisualization(nodes: { Types.PathNode }, botState: string, colorOverride: Color3?)
	if #nodes < 2 then
		return nil
	end

	local path = Instance.new("Model")
	path.Name = "Path"

	-- Determine path color based on bot state or override
	local pathColor = colorOverride
		or (
			botState == "moving" and Color3.fromRGB(120, 180, 255)
			or botState == "charging" and Color3.fromRGB(255, 200, 100)
			or botState == "maintenance" and Color3.fromRGB(255, 150, 100)
			or botState == "error" and Color3.fromRGB(255, 120, 120)
			or Color3.fromRGB(100, 255, 100)
		)

	-- Create path segments
	for i = 1, #nodes - 1 do
		local start = nodes[i].position
		local finish = nodes[i + 1].position
		local distance = (finish - start).Magnitude

		local part = Instance.new("Part")
		part.Size = Vector3.new(0.2, 0.2, distance)
		part.CFrame = CFrame.new(start, finish) * CFrame.new(0, 0, -distance / 2)
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Color = pathColor
		part.Transparency = colorOverride and 0.2 or 0.5
		part.Parent = path

		if i < #nodes - 1 then
			local arrow = Instance.new("Part")
			arrow.Size = Vector3.new(0.4, 0.4, 0.4)
			arrow.CFrame = CFrame.new(finish) * CFrame.Angles(0, math.rad(45), 0)
			arrow.Anchored = true
			arrow.CanCollide = false
			arrow.Material = Enum.Material.Neon
			arrow.Color = pathColor
			arrow.Transparency = colorOverride and 0.1 or 0.3
			arrow.Parent = path
		end
	end

	path.Parent = self.pathFolder
	return path
end

function DeliveryUI:CreateTestButtons()
	local spawnBotEvent = ReplicatedStorage:WaitForChild("DeliveryTestSpawnBot")
	local enqueueEvent = ReplicatedStorage:WaitForChild("DeliveryTestEnqueueDelivery")

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "TestButtonFrame"
	buttonFrame.Size = UDim2.new(0, 320, 0, 40)
	buttonFrame.Position = UDim2.new(1, -340, 0, 360)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Parent = self.screenGui

	local spawnBotBtn = Instance.new("TextButton")
	spawnBotBtn.Text = "Spawn Bot"
	spawnBotBtn.Size = UDim2.new(0.48, -5, 1, 0)
	spawnBotBtn.Position = UDim2.new(0, 0, 0, 0)
	spawnBotBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
	spawnBotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	spawnBotBtn.TextSize = 18
	spawnBotBtn.Font = Enum.Font.GothamBold
	spawnBotBtn.Parent = buttonFrame
	spawnBotBtn.MouseButton1Click:Connect(function()
		spawnBotEvent:FireServer()
	end)

	local enqueueBtn = Instance.new("TextButton")
	enqueueBtn.Text = "Add Delivery Task"
	enqueueBtn.Size = UDim2.new(0.48, -5, 1, 0)
	enqueueBtn.Position = UDim2.new(0.52, 5, 0, 0)
	enqueueBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 80)
	enqueueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	enqueueBtn.TextSize = 18
	enqueueBtn.Font = Enum.Font.GothamBold
	enqueueBtn.Parent = buttonFrame
	enqueueBtn.MouseButton1Click:Connect(function()
		enqueueEvent:FireServer()
	end)

	self.testButtonFrame = buttonFrame
end

function DeliveryUI:SetDestinationButton()
	if self.setDestBtn then
		self.setDestBtn:Destroy()
	end
	local btn = Instance.new("TextButton")
	btn.Name = "SetDestinationBtn"
	btn.Text = "Set Destination"
	btn.Size = UDim2.new(0, 160, 0, 36)
	btn.Position = UDim2.new(1, -340, 0, 105)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 120)
	btn.TextColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextSize = 18
	btn.Font = Enum.Font.GothamBold
	btn.Visible = self.selectedBotId ~= nil
	btn.Parent = self.screenGui
	self.setDestBtn = btn

	btn.MouseButton1Click:Connect(function()
		if not self.selectedBotId then
			return
		end
		self.selectingDestination = true
		btn.Text = "Click world..."
		btn.BackgroundColor3 = Color3.fromRGB(255, 220, 80)
	end)

	-- Listen for world click
	if not self.inputConn then
		self.inputConn = game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
			if
				self.selectingDestination
				and input.UserInputType == Enum.UserInputType.MouseButton1
				and not processed
			then
				local mouse = Players.LocalPlayer:GetMouse()
				local hit = mouse.Hit
				if hit then
					local pos = hit.Position
					self:SendManualDestination(self.selectedBotId, pos)
					self.selectingDestination = false
					btn.Text = "Set Destination"
					btn.BackgroundColor3 = Color3.fromRGB(255, 255, 120)
				end
			end
		end)
	end
end

function DeliveryUI:SendManualDestination(botId, position)
	local remote = ReplicatedStorage:FindFirstChild("DeliverySetManualDestination")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "DeliverySetManualDestination"
		remote.Parent = ReplicatedStorage
	end
	remote:FireServer(botId, position)
end

function DeliveryUI:ShowBotStatusPanel()
	-- Placeholder for showing bot status panel
	print("[DeliveryUI] ShowBotStatusPanel")
end

function DeliveryUI:ShowQueuePanel()
	-- Placeholder for showing delivery queue panel
	print("[DeliveryUI] ShowQueuePanel")
end

function DeliveryUI:ShowRouteVisualizer()
	-- Placeholder for showing route visualization
	print("[DeliveryUI] ShowRouteVisualizer")
end

function DeliveryUI:CreatePauseResumeButtons()
	if self.pauseBtn then
		self.pauseBtn:Destroy()
	end
	if self.resumeBtn then
		self.resumeBtn:Destroy()
	end

	local pauseBtn = Instance.new("TextButton")
	pauseBtn.Name = "PauseBotBtn"
	pauseBtn.Text = "Pause"
	pauseBtn.Size = UDim2.new(0, 80, 0, 32)
	pauseBtn.Position = UDim2.new(1, -340, 0, 150)
	pauseBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 120)
	pauseBtn.TextColor3 = Color3.fromRGB(60, 60, 60)
	pauseBtn.TextSize = 16
	pauseBtn.Font = Enum.Font.GothamBold
	pauseBtn.Visible = false
	pauseBtn.Parent = self.screenGui
	self.pauseBtn = pauseBtn

	local resumeBtn = Instance.new("TextButton")
	resumeBtn.Name = "ResumeBotBtn"
	resumeBtn.Text = "Resume"
	resumeBtn.Size = UDim2.new(0, 80, 0, 32)
	resumeBtn.Position = UDim2.new(1, -250, 0, 150)
	resumeBtn.BackgroundColor3 = Color3.fromRGB(120, 255, 180)
	resumeBtn.TextColor3 = Color3.fromRGB(60, 60, 60)
	resumeBtn.TextSize = 16
	resumeBtn.Font = Enum.Font.GothamBold
	resumeBtn.Visible = false
	resumeBtn.Parent = self.screenGui
	self.resumeBtn = resumeBtn

	pauseBtn.MouseButton1Click:Connect(function()
		if self.selectedBotId then
			self:SendPauseResume(self.selectedBotId, true)
		end
	end)
	resumeBtn.MouseButton1Click:Connect(function()
		if self.selectedBotId then
			self:SendPauseResume(self.selectedBotId, false)
		end
	end)
end

function DeliveryUI:SendPauseResume(botId, pause)
	local remote = ReplicatedStorage:FindFirstChild("DeliveryPauseResumeBot")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "DeliveryPauseResumeBot"
		remote.Parent = ReplicatedStorage
	end
	remote:FireServer(botId, pause)
end

function DeliveryUI:CreateReturnToAutoButton()
	if self.returnAutoBtn then
		self.returnAutoBtn:Destroy()
	end
	local btn = Instance.new("TextButton")
	btn.Name = "ReturnToAutoBtn"
	btn.Text = "Return to Auto"
	btn.Size = UDim2.new(0, 160, 0, 32)
	btn.Position = UDim2.new(1, -340, 0, 190)
	btn.BackgroundColor3 = Color3.fromRGB(180, 180, 255)
	btn.TextColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextSize = 16
	btn.Font = Enum.Font.GothamBold
	btn.Visible = false
	btn.Parent = self.screenGui
	self.returnAutoBtn = btn

	btn.MouseButton1Click:Connect(function()
		if self.selectedBotId then
			self:SendReturnToAuto(self.selectedBotId)
		end
	end)
end

function DeliveryUI:SendReturnToAuto(botId)
	local remote = ReplicatedStorage:FindFirstChild("DeliveryReturnToAuto")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "DeliveryReturnToAuto"
		remote.Parent = ReplicatedStorage
	end
	remote:FireServer(botId)
end

function DeliveryUI:UpdateBotIndicators()
	-- Clean up old indicators
	for id, gui in pairs(self.botIndicators) do
		if gui and gui.Parent then
			gui:Destroy()
		end
	end
	self.botIndicators = {}

	for _, bot in ipairs(self.bots) do
		if bot.position then
			local icon, color = nil, nil
			if bot.paused then
				icon = "⏸️"
				color = Color3.fromRGB(255, 180, 120)
			elseif bot.path and bot.target then
				icon = "🖐️"
				color = Color3.fromRGB(255, 255, 120)
			end
			if icon then
				local part = workspace:FindFirstChild("DeliveryBotIndicator_" .. bot.id)
				if not part then
					part = Instance.new("Part")
					part.Name = "DeliveryBotIndicator_" .. bot.id
					part.Size = Vector3.new(1, 1, 1)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.Parent = workspace
				end
				part.Position = bot.position + Vector3.new(0, 4, 0)

				local gui = Instance.new("BillboardGui")
				gui.Name = "BotStateBillboard"
				gui.Size = UDim2.new(0, 48, 0, 48)
				gui.AlwaysOnTop = true
				gui.Adornee = part
				gui.Parent = part

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = icon
				label.TextColor3 = color
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.Parent = gui

				self.botIndicators[bot.id] = part
			else
				-- Clean up indicator part if it exists
				local part = workspace:FindFirstChild("DeliveryBotIndicator_" .. bot.id)
				if part then
					part:Destroy()
				end
			end
		end
	end
end

function DeliveryUI:UpdateBotModels()
	-- Remove models for bots that no longer exist
	for id, model in pairs(self.botModels) do
		local found = false
		for _, bot in ipairs(self.bots) do
			if bot.id == id then
				found = true
				break
			end
		end
		if not found and model and model.Parent then
			model:Destroy()
			self.botModels[id] = nil
		end
	end

	-- Update or create models for current bots
	for _, bot in ipairs(self.bots) do
		local model = self.botModels[bot.id]
		if not model then
			model = BotModels.CreateBotModel(bot.type, bot.position)
			self.botModels[bot.id] = model
			model.Parent = workspace
		end

		if model then
			-- Update position
			model:SetPrimaryPartCFrame(CFrame.new(bot.position))

			-- Animate based on state
			BotModels.AnimateBot(model, bot.state, bot.type)
		end
	end
end

function DeliveryUI:CreateBotModel(bot)
	return BotModels.CreateBotModel(bot.type, bot.position)
end

return DeliveryUI
