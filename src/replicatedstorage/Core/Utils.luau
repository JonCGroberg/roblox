--!strict
local Utils = {}

-- Math Utilities
function Utils.clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

function Utils.lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

-- Table Utilities
function Utils.deepCopy<T>(original: T): T
	if type(original) ~= "table" then
		return original
	end

	local copy:any = {}
	for key, value in pairs(original::{[any]:any}) do
		copy[key] = Utils.deepCopy(value)
	end

	return copy :: T
end

-- Vector Utilities
function Utils.distance(a: Vector3, b: Vector3): number
	return (a - b).Magnitude
end

function Utils.direction(a: Vector3, b: Vector3): Vector3
	return (b - a).Unit
end

-- String Utilities
function Utils.formatNumber(num: number): string
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(num)
	end
end

return Utils
