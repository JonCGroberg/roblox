--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local Constants = require(ReplicatedStorage.Core.Constants)
local Config = require(ReplicatedStorage.Core.Config)
local EconomyService = require(ReplicatedStorage.Services.EconomyService)

local BusinessService = {}
BusinessService.__index = BusinessService

local GRID_SIZE = 4

local function snapToGrid(pos: Vector3): Vector3
	return Vector3.new(
		math.floor(pos.X / GRID_SIZE + 0.5) * GRID_SIZE,
		pos.Y,
		math.floor(pos.Z / GRID_SIZE + 0.5) * GRID_SIZE
	)
end

local _mockDataStore = {} :: { [number]: { Types.BusinessState } }

function BusinessService.new(economyService: any): Types.BusinessService
	local self = setmetatable({}, BusinessService)
	self._businesses = {} :: { [string]: Types.BusinessState } -- [businessId] = BusinessState
	self._playerBusinesses = {} :: { [number]: { Types.BusinessState } } -- [player.UserId] = { BusinessState }
	self._economyService = economyService
	return (self :: any) :: Types.BusinessService
end

-- Server-side methods
function BusinessService:CanPlaceBusiness(
	player: Player,
	businessType: Types.BusinessType,
	position: Vector3,
	rotation: Vector3
): boolean
	local snapped = snapToGrid(position)
	for _, business: Types.BusinessState in pairs(self._businesses) do
		if (business.position - snapped).Magnitude < GRID_SIZE then
			return false -- Collision detected
		end
	end
	-- Optionally add bounds checks here
	return true
end

function BusinessService:PlaceBusiness(
	player: Player,
	businessType: Types.BusinessType,
	position: Vector3,
	rotation: Vector3
): boolean
	if not self:CanPlaceBusiness(player, businessType, position, rotation) then
		return false
	end
	local businessId = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
	local snapped = snapToGrid(position)
	local state: Types.BusinessState = {
		id = businessId,
		type = businessType,
		ownerId = player.UserId,
		position = snapped,
		rotation = rotation,
		state = "idle",
		upgrades = {},
		lastUpdated = os.time(),
	}
	self._businesses[businessId] = state
	self._playerBusinesses[player.UserId] = self._playerBusinesses[player.UserId] or {}
	table.insert(self._playerBusinesses[player.UserId], state)
	return true
end

function BusinessService:GetBusinessState(businessId: string): Types.BusinessState?
	return self._businesses[businessId]
end

function BusinessService:GetPlayerBusinesses(player: Player): { Types.BusinessState }
	return self._playerBusinesses[player.UserId] or {}
end

function BusinessService:UpgradeBusiness(businessId: string, upgradeType: string, player: Player): boolean
	local business = self._businesses[businessId]
	if not business then
		return false
	end
	local upgradeConfig = Config.BUSINESS_UPGRADES[upgradeType]
	if not upgradeConfig then
		return false
	end
	local currentLevel = business.upgrades[upgradeType] or 0
	if currentLevel >= upgradeConfig.maxLevel then
		return false
	end
	local coins = self._economyService:GetBalance(player, "coins")
	if coins < upgradeConfig.cost then
		return false
	end
	self._economyService:SetBalance(player, "coins", coins - upgradeConfig.cost)
	business.upgrades[upgradeType] = currentLevel + 1
	business.lastUpdated = os.time()
	return true
end

function BusinessService:SetBusinessState(businessId: string, newState: string): boolean
	local business = self._businesses[businessId]
	if not business then
		return false
	end
	business.state = newState
	business.lastUpdated = os.time()
	return true
end

function BusinessService:SavePlayerBusinesses(player: Player): boolean
	local businesses = self._playerBusinesses[player.UserId]
	if not businesses then
		return false
	end
	_mockDataStore[player.UserId] = businesses
	return true
end

function BusinessService:LoadPlayerBusinesses(player: Player): boolean
	local businesses = _mockDataStore[player.UserId]
	if not businesses then
		return false
	end
	self._playerBusinesses[player.UserId] = businesses
	for _, business in businesses do
		self._businesses[business.id] = business
	end
	return true
end

-- Client-side methods
function BusinessService:UpdateUI(businessId: string)
	-- Example: Update UI based on business state
	local business = self._businesses[businessId]
	if business then
		-- Call the FacilityUI update method
		local facilityUI = require(ReplicatedStorage.UI.FacilityUI)
		facilityUI:UpdateUI(businessId, business)
	end
end

return BusinessService
