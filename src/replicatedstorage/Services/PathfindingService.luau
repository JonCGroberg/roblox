local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Core.Types)
local Config = require(ReplicatedStorage.Core.Config)

local PathfindingService = {}
PathfindingService.__index = PathfindingService

-- Constants for pathfinding
local GRID_SIZE = 4 -- Match the grid size from BusinessService
local DIAGONAL_COST = 1.414 -- sqrt(2)

function PathfindingService.new()
	local self = setmetatable({}, PathfindingService)
	self.obstacles = {} -- Store obstacles for pathfinding
	return self
end

-- Initialize the service
function PathfindingService:Init()
	-- Set up any initial state
	self:UpdateObstacles()
end

-- Update the obstacles list based on current business placements
function PathfindingService:UpdateObstacles()
	self.obstacles = {}
	-- This will be populated by the business service
end

-- Add an obstacle to the pathfinding grid
function PathfindingService:AddObstacle(position: Vector3, size: Vector3)
	table.insert(self.obstacles, {
		position = position,
		size = size,
	})
end

-- Remove an obstacle from the pathfinding grid
function PathfindingService:RemoveObstacle(position: Vector3)
	for i, obstacle in ipairs(self.obstacles) do
		if obstacle.position == position then
			table.remove(self.obstacles, i)
			break
		end
	end
end

-- Check if a position is walkable
function PathfindingService:IsWalkable(position: Vector3): boolean
	for _, obstacle in ipairs(self.obstacles) do
		local dx = math.abs(position.X - obstacle.position.X)
		local dz = math.abs(position.Z - obstacle.position.Z)
		if dx < obstacle.size.X / 2 and dz < obstacle.size.Z / 2 then
			return false
		end
	end
	return true
end

-- Get neighboring positions for pathfinding
function PathfindingService:GetNeighbors(position: Vector3): { Vector3 }
	local neighbors = {}
	local directions = {
		Vector3.new(GRID_SIZE, 0, 0),
		Vector3.new(-GRID_SIZE, 0, 0),
		Vector3.new(0, 0, GRID_SIZE),
		Vector3.new(0, 0, -GRID_SIZE),
		Vector3.new(GRID_SIZE, 0, GRID_SIZE),
		Vector3.new(GRID_SIZE, 0, -GRID_SIZE),
		Vector3.new(-GRID_SIZE, 0, GRID_SIZE),
		Vector3.new(-GRID_SIZE, 0, -GRID_SIZE),
	}

	for _, direction in ipairs(directions) do
		local newPos = position + direction
		if self:IsWalkable(newPos) then
			table.insert(neighbors, newPos)
		end
	end

	return neighbors
end

-- Calculate heuristic (estimated distance) between two points
function PathfindingService:CalculateHeuristic(start: Vector3, goal: Vector3): number
	return (start - goal).Magnitude
end

-- Find path using A* algorithm
function PathfindingService:FindPath(start: Vector3, goal: Vector3): { Types.PathNode }?
	local openSet = { start }
	local cameFrom = {}
	local gScore = { [tostring(start)] = 0 }
	local fScore = { [tostring(start)] = self:CalculateHeuristic(start, goal) }

	while #openSet > 0 do
		-- Find node with lowest fScore
		local current = openSet[1]
		local currentIndex = 1
		for i, pos in ipairs(openSet) do
			if fScore[tostring(pos)] < fScore[tostring(current)] then
				current = pos
				currentIndex = i
			end
		end

		-- Remove current from openSet
		table.remove(openSet, currentIndex)

		-- Check if we reached the goal
		if (current - goal).Magnitude < GRID_SIZE then
			return self:ReconstructPath(cameFrom, current)
		end

		-- Check neighbors
		for _, neighbor in ipairs(self:GetNeighbors(current)) do
			local tentativeGScore = gScore[tostring(current)] + (neighbor - current).Magnitude

			if not gScore[tostring(neighbor)] or tentativeGScore < gScore[tostring(neighbor)] then
				cameFrom[tostring(neighbor)] = current
				gScore[tostring(neighbor)] = tentativeGScore
				fScore[tostring(neighbor)] = tentativeGScore + self:CalculateHeuristic(neighbor, goal)

				-- Add neighbor to openSet if not already there
				local found = false
				for _, pos in ipairs(openSet) do
					if pos == neighbor then
						found = true
						break
					end
				end
				if not found then
					table.insert(openSet, neighbor)
				end
			end
		end
	end

	return nil -- No path found
end

-- Reconstruct path from cameFrom map
function PathfindingService:ReconstructPath(cameFrom: { [string]: Vector3 }, current: Vector3): { Types.PathNode }
	local path = { { position = current } }
	while cameFrom[tostring(current)] do
		current = cameFrom[tostring(current)]
		table.insert(path, 1, { position = current })
	end
	return path
end

-- Smooth path to make movement more natural
function PathfindingService:SmoothPath(path: { Types.PathNode }): { Types.PathNode }
	if #path <= 2 then
		return path
	end

	local smoothed = { path[1] }
	local current = 1

	while current < #path do
		local furthest = current + 1
		for i = current + 2, #path do
			if self:HasLineOfSight(path[current].position, path[i].position) then
				furthest = i
			end
		end
		table.insert(smoothed, path[furthest])
		current = furthest
	end

	return smoothed
end

-- Check if there's a clear line of sight between two points
function PathfindingService:HasLineOfSight(start: Vector3, goal: Vector3): boolean
	local direction = (goal - start).Unit
	local distance = (goal - start).Magnitude
	local step = GRID_SIZE / 2

	for i = step, distance, step do
		local checkPoint = start + direction * i
		if not self:IsWalkable(checkPoint) then
			return false
		end
	end

	return true
end

-- Calculate movement points along a path
function PathfindingService:CalculateMovementPoints(
	path: { Types.PathNode },
	speed: number,
	deltaTime: number
): { Vector3 }
	local points = {}
	local totalDistance = 0
	local distances = {}

	-- Calculate total path distance and segment distances
	for i = 1, #path - 1 do
		local segmentDistance = (path[i + 1].position - path[i].position).Magnitude
		distances[i] = segmentDistance
		totalDistance += segmentDistance
	end

	-- Calculate number of points based on speed and deltaTime
	local distancePerStep = speed * deltaTime
	local numPoints = math.ceil(totalDistance / distancePerStep)

	-- Generate points along the path
	local currentDistance = 0
	for i = 1, numPoints do
		local targetDistance = (i / numPoints) * totalDistance
		local currentSegment = 1
		local segmentStartDistance = 0

		-- Find which segment this point belongs to
		while currentSegment < #path and segmentStartDistance + distances[currentSegment] < targetDistance do
			segmentStartDistance += distances[currentSegment]
			currentSegment += 1
		end

		-- Calculate position within the segment
		local segmentProgress = (targetDistance - segmentStartDistance) / distances[currentSegment]
		local point = path[currentSegment].position:Lerp(path[currentSegment + 1].position, segmentProgress)
		table.insert(points, point)
	end

	return points
end

return PathfindingService
