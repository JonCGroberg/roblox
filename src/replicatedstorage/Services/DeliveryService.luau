local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local Config = require(ReplicatedStorage.Core.Config)
local PathfindingService = require(ReplicatedStorage.Services.PathfindingService)

local DeliveryService = {}
DeliveryService.__index = DeliveryService

-- Constants for bot management
local BATTERY_DRAIN_RATE = 0.1 -- Battery drain per second while moving
local BATTERY_CHARGE_RATE = 0.2 -- Battery charge per second
local MAINTENANCE_THRESHOLD = 0.3 -- Battery level that triggers maintenance
local MAINTENANCE_DURATION = 5 -- Seconds to complete maintenance

function DeliveryService.new(businessService)
	local self = setmetatable({}, DeliveryService)
	self.businessService = businessService
	self.pathfindingService = PathfindingService.new()
	self.bots = {}
	self.deliveryQueue = {}
	self.activeDeliveries = {}
	self.chargingStations = {}
	self.maintenanceStations = {}

	-- RemoteEvents for client updates
	self.BotUpdateEvent = ReplicatedStorage:FindFirstChild("DeliveryBotUpdate") or Instance.new("RemoteEvent")
	self.BotUpdateEvent.Name = "DeliveryBotUpdate"
	self.BotUpdateEvent.Parent = ReplicatedStorage

	self.QueueUpdateEvent = ReplicatedStorage:FindFirstChild("DeliveryQueueUpdate") or Instance.new("RemoteEvent")
	self.QueueUpdateEvent.Name = "DeliveryQueueUpdate"
	self.QueueUpdateEvent.Parent = ReplicatedStorage

	-- RemoteEvents for test actions
	self.TestSpawnBotEvent = ReplicatedStorage:FindFirstChild("DeliveryTestSpawnBot") or Instance.new("RemoteEvent")
	self.TestSpawnBotEvent.Name = "DeliveryTestSpawnBot"
	self.TestSpawnBotEvent.Parent = ReplicatedStorage

	self.TestEnqueueDeliveryEvent = ReplicatedStorage:FindFirstChild("DeliveryTestEnqueueDelivery")
		or Instance.new("RemoteEvent")
	self.TestEnqueueDeliveryEvent.Name = "DeliveryTestEnqueueDelivery"
	self.TestEnqueueDeliveryEvent.Parent = ReplicatedStorage

	-- RemoteEvent for manual destination
	self.SetManualDestEvent = ReplicatedStorage:FindFirstChild("DeliverySetManualDestination")
		or Instance.new("RemoteEvent")
	self.SetManualDestEvent.Name = "DeliverySetManualDestination"
	self.SetManualDestEvent.Parent = ReplicatedStorage
	self.SetManualDestEvent.OnServerEvent:Connect(function(player, botId, position)
		self:HandleManualDestination(botId, position)
	end)

	-- RemoteEvent for pause/resume
	self.PauseResumeEvent = ReplicatedStorage:FindFirstChild("DeliveryPauseResumeBot") or Instance.new("RemoteEvent")
	self.PauseResumeEvent.Name = "DeliveryPauseResumeBot"
	self.PauseResumeEvent.Parent = ReplicatedStorage
	self.PauseResumeEvent.OnServerEvent:Connect(function(player, botId, pause)
		self:HandlePauseResume(botId, pause)
	end)

	-- RemoteEvent for return to auto
	self.ReturnToAutoEvent = ReplicatedStorage:FindFirstChild("DeliveryReturnToAuto") or Instance.new("RemoteEvent")
	self.ReturnToAutoEvent.Name = "DeliveryReturnToAuto"
	self.ReturnToAutoEvent.Parent = ReplicatedStorage
	self.ReturnToAutoEvent.OnServerEvent:Connect(function(player, botId)
		self:HandleReturnToAuto(botId)
	end)

	self.TestSpawnBotEvent.OnServerEvent:Connect(function(player)
		self:TestSpawnBot()
	end)
	self.TestEnqueueDeliveryEvent.OnServerEvent:Connect(function(player)
		self:TestEnqueueDelivery()
	end)

	print("[DeliveryService] Initialized.")
	return self
end

function DeliveryService:Init()
	self.pathfindingService:Init()
	-- Update obstacles based on business placements
	for _, business in pairs(self.businessService._businesses) do
		self.pathfindingService:AddObstacle(business.position, Vector3.new(4, 4, 4))
	end

	-- Start bot management loop
	task.spawn(function()
		while true do
			self:UpdateBots()
			task.wait(0.1)
		end
	end)
end

function DeliveryService:UpdateBots()
	for _, bot in ipairs(self.bots) do
		-- Update battery level
		if bot.state == "moving" then
			bot.battery = math.max(0, bot.battery - BATTERY_DRAIN_RATE * 0.1)
		elseif bot.state == "charging" then
			bot.battery = math.min(1, bot.battery + BATTERY_CHARGE_RATE * 0.1)
			if bot.battery >= 1 then
				bot.state = "idle"
			end
		end

		-- Check for maintenance needs
		if bot.battery <= MAINTENANCE_THRESHOLD and bot.state ~= "maintenance" then
			self:SendBotToMaintenance(bot)
		end

		-- Update maintenance progress
		if bot.state == "maintenance" then
			bot.maintenanceProgress = (bot.maintenanceProgress or 0) + 0.1 / MAINTENANCE_DURATION
			if bot.maintenanceProgress >= 1 then
				bot.state = "idle"
				bot.maintenanceProgress = 0
				bot.battery = 1
			end
		end
	end
	self:SendBotUpdate()
end

function DeliveryService:SendBotToMaintenance(bot)
	if bot.state == "maintenance" then
		return
	end

	-- Find nearest maintenance station
	local nearestStation = nil
	local minDistance = math.huge
	for _, station in ipairs(self.maintenanceStations) do
		local distance = (bot.position - station.position).Magnitude
		if distance < minDistance then
			minDistance = distance
			nearestStation = station
		end
	end

	if nearestStation then
		bot.state = "maintenance"
		bot.maintenanceProgress = 0
		bot.target = nearestStation.position
		-- Calculate path to maintenance station
		local path = self:CalculatePath(bot.position, nearestStation.position)
		if path then
			bot.path = { nodes = path }
		end
	end
end

function DeliveryService:SendBotToCharging(bot)
	if bot.state == "charging" then
		return
	end

	-- Find nearest charging station
	local nearestStation = nil
	local minDistance = math.huge
	for _, station in ipairs(self.chargingStations) do
		local distance = (bot.position - station.position).Magnitude
		if distance < minDistance then
			minDistance = distance
			nearestStation = station
		end
	end

	if nearestStation then
		bot.state = "charging"
		bot.target = nearestStation.position
		-- Calculate path to charging station
		local path = self:CalculatePath(bot.position, nearestStation.position)
		if path then
			bot.path = { nodes = path }
		end
	end
end

function DeliveryService:AddChargingStation(position: Vector3)
	table.insert(self.chargingStations, { position = position })
end

function DeliveryService:AddMaintenanceStation(position: Vector3)
	table.insert(self.maintenanceStations, { position = position })
end

function DeliveryService:SendBotUpdate()
	self.BotUpdateEvent:FireAllClients(self.bots)
end

function DeliveryService:SendQueueUpdate()
	self.QueueUpdateEvent:FireAllClients(self.deliveryQueue)
end

function DeliveryService:SpawnBot(botType, startPosition)
	local botConfig = Config.DELIVERY.BOT_TYPES[botType]
	if not botConfig then
		warn("Invalid bot type:", botType)
		return
	end

	local bot = {
		id = "bot" .. tostring(#self.bots + 1),
		type = botType,
		facilityId = "facility1",
		position = startPosition,
		target = nil,
		carrying = {},
		speed = botConfig.speed,
		capacity = botConfig.capacity,
		state = "idle",
		path = nil,
		battery = 1,
		maintenanceProgress = 0,
		paused = false,
	}
	table.insert(self.bots, bot)
	self:SendBotUpdate()
	print("[DeliveryService] Spawning bot:", botType, startPosition)
end

function DeliveryService:AssignIdleBotsToTasks()
	for _, bot in ipairs(self.bots) do
		if bot.state == "idle" and not bot.paused then
			for _, task in ipairs(self.deliveryQueue) do
				if task.status == "pending" then
					self:AssignBotToDelivery(bot, task)
					break
				end
			end
		end
	end
end

function DeliveryService:CalculatePath(startPos, endPos)
	local path = self.pathfindingService:FindPath(startPos, endPos)
	if not path then
		warn("No path found from", startPos, "to", endPos)
		return nil
	end
	return self.pathfindingService:SmoothPath(path)
end

function DeliveryService:AssignBotToDelivery(bot, deliveryTask)
	if bot.state ~= "idle" or bot.battery <= MAINTENANCE_THRESHOLD or bot.paused then
		return false
	end

	deliveryTask.status = "in_progress"
	bot.state = "moving"
	bot.target = deliveryTask.destinationPosition

	-- Calculate path
	local sourceFacility = self.businessService:GetBusinessState(deliveryTask.sourceFacilityId)
	local startPos = sourceFacility and sourceFacility.position or Vector3.new(0, 0, 0)
	local endPos = deliveryTask.destinationPosition
	local path = self:CalculatePath(startPos, endPos)

	if not path then
		deliveryTask.status = "failed"
		bot.state = "error"
		self:SendBotUpdate()
		self:SendQueueUpdate()
		return false
	end

	bot.path = { nodes = path }
	self:SendBotUpdate()
	self:SendQueueUpdate()

	task.spawn(function()
		-- Calculate movement points
		local movementPoints = self.pathfindingService:CalculateMovementPoints(path, bot.speed, 0.1)

		-- Move along path
		for _, point in ipairs(movementPoints) do
			bot.position = point
			self:SendBotUpdate()
			task.wait(0.1)
		end

		-- Simulate delivery completion
		local sourceFacility = self.businessService:GetBusinessState(deliveryTask.sourceFacilityId)
		if sourceFacility and sourceFacility.outputBuffer then
			sourceFacility.outputBuffer[deliveryTask.resourceId] =
				math.max(0, (sourceFacility.outputBuffer[deliveryTask.resourceId] or 0) - deliveryTask.amount)
		end
		local destFacility = self.businessService:GetBusinessState(deliveryTask.destinationFacilityId)
		if destFacility and destFacility.inputBuffer then
			destFacility.inputBuffer[deliveryTask.resourceId] = (destFacility.inputBuffer[deliveryTask.resourceId] or 0)
				+ deliveryTask.amount
		end

		deliveryTask.status = "completed"
		bot.state = "idle"
		bot.target = nil
		bot.path = nil
		self:SendBotUpdate()
		self:SendQueueUpdate()

		-- Remove completed task from queue
		for i, t in ipairs(self.deliveryQueue) do
			if t.id == deliveryTask.id then
				table.remove(self.deliveryQueue, i)
				break
			end
		end
		self:SendQueueUpdate()
		self:AssignIdleBotsToTasks()
	end)

	return true
end

function DeliveryService:CleanupBot(bot)
	for i, b in ipairs(self.bots) do
		if b.id == bot.id then
			table.remove(self.bots, i)
			break
		end
	end
	self:SendBotUpdate()
	print("[DeliveryService] Cleaning up bot:", bot)
end

function DeliveryService:EnqueueDelivery(deliveryTask)
	table.insert(self.deliveryQueue, deliveryTask)
	self:SendQueueUpdate()
	self:AssignIdleBotsToTasks()
	print("[DeliveryService] Enqueued delivery:", deliveryTask)
end

function DeliveryService:ProcessQueue()
	print("[DeliveryService] Processing queue...")
end

function DeliveryService:FindPath(start, destination)
	print("[DeliveryService] Finding path from", start, "to", destination)
end

function DeliveryService:GetBots()
	return self.bots
end

function DeliveryService:GetQueue()
	return self.deliveryQueue
end

function DeliveryService:TestSpawnBot()
	self:SpawnBot("basic", Vector3.new(math.random(-50, 50), 0, math.random(-50, 50)))
	self:AssignIdleBotsToTasks()
end

function DeliveryService:TestEnqueueDelivery()
	local task = {
		id = "task" .. tostring(#self.deliveryQueue + 1),
		resourceId = "iron_ingot",
		amount = math.random(1, 20),
		sourceFacilityId = "facility1",
		destinationFacilityId = nil,
		destinationPosition = Vector3.new(math.random(-50, 50), 0, math.random(-50, 50)),
		priority = math.random(1, 3),
		status = "pending",
	}
	self:EnqueueDelivery(task)
end

function DeliveryService:HandleManualDestination(botId, position)
	for _, bot in ipairs(self.bots) do
		if bot.id == botId then
			-- Interrupt current task
			bot.state = "moving"
			bot.target = position
			bot.path = nil
			-- Calculate new path
			local path = self:CalculatePath(bot.position, position)
			if not path then
				bot.state = "error"
				self:SendBotUpdate()
				return
			end
			bot.path = { nodes = path }
			self:SendBotUpdate()
			-- Move bot along path
			task.spawn(function()
				local movementPoints = self.pathfindingService:CalculateMovementPoints(path, bot.speed, 0.1)
				for _, point in ipairs(movementPoints) do
					bot.position = point
					self:SendBotUpdate()
					task.wait(0.1)
				end
				bot.state = "idle"
				bot.target = nil
				bot.path = nil
				self:SendBotUpdate()
			end)
			return
		end
	end
end

function DeliveryService:HandlePauseResume(botId, pause)
	for _, bot in ipairs(self.bots) do
		if bot.id == botId then
			bot.paused = pause
			if pause then
				bot.state = "paused"
			else
				if bot.path and bot.target then
					bot.state = "moving"
					self:ResumeBotMovement(bot)
				else
					bot.state = "idle"
				end
			end
			self:SendBotUpdate()
			break
		end
	end
end

function DeliveryService:ResumeBotMovement(bot)
	if not bot.path or not bot.path.nodes then
		return
	end
	task.spawn(function()
		for i, node in ipairs(bot.path.nodes) do
			if bot.paused then
				return
			end
			bot.position = node.position
			self:SendBotUpdate()
			task.wait(0.1)
		end
		bot.state = "idle"
		bot.target = nil
		bot.path = nil
		self:SendBotUpdate()
	end)
end

function DeliveryService:HandleReturnToAuto(botId)
	for _, bot in ipairs(self.bots) do
		if bot.id == botId then
			bot.state = "idle"
			bot.target = nil
			bot.path = nil
			self:SendBotUpdate()
			self:AssignIdleBotsToTasks()
			break
		end
	end
end

return DeliveryService
