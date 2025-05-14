local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local Config = require(ReplicatedStorage.Core.Config)

local ProductionService = {}
ProductionService.__index = ProductionService

function ProductionService.new(businessService, deliveryService)
	local self = setmetatable({}, ProductionService)
	self.businessService = businessService
	self.deliveryService = deliveryService
	self.buffers = {}
	self.processingQueue = {}
	return self
end

-- Initialize production service
function ProductionService:Init()
	self.buffers = {}
	self.processingQueue = {}
end

-- Process resources for a business
function ProductionService:ProcessResources(
	businessId: string,
	inputResources: { [string]: number },
	outputResources: { [string]: number }
): boolean
	-- Validate input and output resources
	if not self:ValidateResources(inputResources, outputResources) then
		warn("Invalid resources for business:", businessId)
		return false
	end

	-- Check if input resources are available in buffer
	if not self:CheckBufferAvailability(businessId, inputResources) then
		warn("Insufficient resources in buffer for business:", businessId)
		return false
	end

	-- Check if output buffer has space
	if not self:CheckOutputBufferSpace(businessId, outputResources) then
		warn("Output buffer full for business:", businessId)
		return false
	end

	-- Deduct input resources from buffer
	self:DeductFromBuffer(businessId, inputResources)

	-- Add output resources to buffer
	self:AddToBuffer(businessId, outputResources)

	-- Check and create delivery tasks for full output buffers
	self:CheckAndCreateDeliveryTasks(businessId)

	return true
end

-- Validate input and output resources
function ProductionService:ValidateResources(
	inputResources: { [string]: number },
	outputResources: { [string]: number }
): boolean
	-- Check if input and output resources are valid
	for resource, amount in pairs(inputResources) do
		if amount <= 0 or not Config.RESOURCES[resource] then
			return false
		end
	end
	for resource, amount in pairs(outputResources) do
		if amount <= 0 or not Config.RESOURCES[resource] then
			return false
		end
	end
	return true
end

-- Check if input resources are available in buffer
function ProductionService:CheckBufferAvailability(businessId: string, inputResources: { [string]: number }): boolean
	local buffer = self.buffers[businessId] or {}
	for resource, amount in pairs(inputResources) do
		if (buffer[resource] or 0) < amount then
			return false
		end
	end
	return true
end

-- Check if output buffer has space
function ProductionService:CheckOutputBufferSpace(businessId: string, outputResources: { [string]: number }): boolean
	local buffer = self.buffers[businessId] or {}
	local business = self.businessService:GetBusinessState(businessId)
	if not business then
		return false
	end

	local capacityUpgrade = business.upgrades.capacity or 0
	local maxCapacity = Config.BUSINESS_UPGRADES.capacity.baseCapacity
		* (1 + capacityUpgrade * Config.BUSINESS_UPGRADES.capacity.capacityMultiplier)

	for resource, amount in pairs(outputResources) do
		if (buffer[resource] or 0) + amount > maxCapacity then
			return false
		end
	end
	return true
end

-- Deduct input resources from buffer
function ProductionService:DeductFromBuffer(businessId: string, inputResources: { [string]: number })
	local buffer = self.buffers[businessId] or {}
	for resource, amount in pairs(inputResources) do
		buffer[resource] = (buffer[resource] or 0) - amount
	end
	self.buffers[businessId] = buffer
end

-- Add output resources to buffer
function ProductionService:AddToBuffer(businessId: string, outputResources: { [string]: number })
	local buffer = self.buffers[businessId] or {}
	for resource, amount in pairs(outputResources) do
		buffer[resource] = (buffer[resource] or 0) + amount
	end
	self.buffers[businessId] = buffer
end

-- Check and create delivery tasks for full output buffers
function ProductionService:CheckAndCreateDeliveryTasks(businessId: string)
	local business = self.businessService:GetBusinessState(businessId)
	if not business or not business.outputBuffer then
		return
	end

	local buffer = self.buffers[businessId] or {}
	local capacityUpgrade = business.upgrades.capacity or 0
	local maxCapacity = Config.BUSINESS_UPGRADES.capacity.baseCapacity
		* (1 + capacityUpgrade * Config.BUSINESS_UPGRADES.capacity.capacityMultiplier)

	for resourceId, amount in pairs(buffer) do
		if amount >= maxCapacity * Config.DELIVERY.BUFFER_THRESHOLD then
			-- Find facilities that need this resource
			local deliveryAmount = math.floor(amount * Config.DELIVERY.DELIVERY_RATIO)
			local task = {
				id = "task_" .. businessId .. "_" .. resourceId .. "_" .. os.time(),
				resourceId = resourceId,
				amount = deliveryAmount,
				sourceFacilityId = businessId,
				destinationFacilityId = nil, -- Will be set by delivery service
				destinationPosition = business.position,
				priority = 1,
				status = "pending",
			}
			self.deliveryService:EnqueueDelivery(task)
		end
	end
end

-- Validate production chain
function ProductionService:ValidateProductionChain(businessId: string): boolean
	local business = self.businessService:GetBusinessState(businessId)
	if not business then
		return false
	end

	local recipe = Config.RECIPES[business.type]
	if not recipe then
		return false
	end

	-- Check if all required input resources are available
	for _, input in ipairs(recipe.input) do
		local buffer = self.buffers[businessId] or {}
		if (buffer[input.resourceId] or 0) < input.amount then
			return false
		end
	end

	return true
end

-- Get buffer state for a business
function ProductionService:GetBufferState(businessId: string): { [string]: number }?
	return self.buffers[businessId]
end

return ProductionService
