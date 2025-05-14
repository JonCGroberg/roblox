local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Types = require(ReplicatedStorage.Core.Types)

local BotModels = {}

-- Constants for bot models
local BOT_COLORS = {
	basic = {
		body = Color3.fromRGB(120, 180, 255),
		accent = Color3.fromRGB(200, 220, 255),
		wheel = Color3.fromRGB(100, 160, 220),
	},
	advanced = {
		body = Color3.fromRGB(120, 255, 120),
		accent = Color3.fromRGB(180, 255, 180),
		wheel = Color3.fromRGB(80, 180, 80),
	},
	special = {
		body = Color3.fromRGB(255, 220, 120),
		accent = Color3.fromRGB(255, 255, 180),
		wheel = Color3.fromRGB(220, 200, 100),
	},
}

-- Animation configurations
local ANIMATIONS = {
	idle = {
		bobHeight = 0.2,
		bobSpeed = 2,
	},
	moving = {
		bobHeight = 0.3,
		bobSpeed = 4,
		wheelSpeed = 360,
	},
	charging = {
		pulseSpeed = 2,
		pulseIntensity = 0.3,
	},
	error = {
		flashSpeed = 4,
	},
}

function BotModels.CreateBasicBot(position: Vector3)
	local model = Instance.new("Model")
	model.Name = "BasicBot"

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 1, 2)
	body.Anchored = true
	body.CanCollide = false
	body.Position = position
	body.Color = BOT_COLORS.basic.body
	body.Material = Enum.Material.Plastic
	body.Parent = model

	-- Dome
	local dome = Instance.new("Part")
	dome.Name = "Dome"
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(1.2, 0.6, 1.2)
	dome.Position = position + Vector3.new(0, 0.8, 0)
	dome.Anchored = true
	dome.CanCollide = false
	dome.Color = BOT_COLORS.basic.accent
	dome.Material = Enum.Material.Plastic
	dome.Parent = model

	-- Wheels
	for i = -1, 1, 2 do
		local wheel = Instance.new("Part")
		wheel.Name = "Wheel"
		wheel.Shape = Enum.PartType.Cylinder
		wheel.Size = Vector3.new(0.4, 1.2, 1.2)
		wheel.Position = position + Vector3.new(i * 0.9, -0.3, 0)
		wheel.Anchored = true
		wheel.CanCollide = false
		wheel.Orientation = Vector3.new(0, 0, 90)
		wheel.Color = BOT_COLORS.basic.wheel
		wheel.Material = Enum.Material.Plastic
		wheel.Parent = model
	end

	model.PrimaryPart = body
	return model
end

function BotModels.CreateAdvancedBot(position: Vector3)
	local model = Instance.new("Model")
	model.Name = "AdvancedBot"

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2.2, 1.2, 2.2)
	body.Anchored = true
	body.CanCollide = false
	body.Position = position
	body.Color = BOT_COLORS.advanced.body
	body.Material = Enum.Material.Plastic
	body.Parent = model

	-- Top sensor array
	local sensor = Instance.new("Part")
	sensor.Name = "Sensor"
	sensor.Size = Vector3.new(1.4, 0.4, 1.4)
	sensor.Position = position + Vector3.new(0, 0.9, 0)
	sensor.Anchored = true
	sensor.CanCollide = false
	sensor.Color = BOT_COLORS.advanced.accent
	sensor.Material = Enum.Material.Neon
	sensor.Parent = model

	-- Wheels with suspension
	for i = -1, 1, 2 do
		-- Suspension
		local suspension = Instance.new("Part")
		suspension.Name = "Suspension"
		suspension.Size = Vector3.new(0.3, 0.6, 0.3)
		suspension.Position = position + Vector3.new(i * 1.1, -0.2, 0)
		suspension.Anchored = true
		suspension.CanCollide = false
		suspension.Color = BOT_COLORS.advanced.accent
		suspension.Material = Enum.Material.Metal
		suspension.Parent = model

		-- Wheel
		local wheel = Instance.new("Part")
		wheel.Name = "Wheel"
		wheel.Shape = Enum.PartType.Cylinder
		wheel.Size = Vector3.new(0.5, 1.4, 1.4)
		wheel.Position = position + Vector3.new(i * 1.1, -0.6, 0)
		wheel.Anchored = true
		wheel.CanCollide = false
		wheel.Orientation = Vector3.new(0, 0, 90)
		wheel.Color = BOT_COLORS.advanced.wheel
		wheel.Material = Enum.Material.Plastic
		wheel.Parent = model
	end

	model.PrimaryPart = body
	return model
end

function BotModels.CreateSpecialBot(position: Vector3)
	local model = Instance.new("Model")
	model.Name = "SpecialBot"

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2.4, 1.4, 2.4)
	body.Anchored = true
	body.CanCollide = false
	body.Position = position
	body.Color = BOT_COLORS.special.body
	body.Material = Enum.Material.Plastic
	body.Parent = model

	-- Energy core
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Size = Vector3.new(1.6, 1.6, 1.6)
	core.Position = position + Vector3.new(0, 0.8, 0)
	core.Anchored = true
	core.CanCollide = false
	core.Color = BOT_COLORS.special.accent
	core.Material = Enum.Material.Neon
	core.Parent = model

	-- Hover engines
	for i = -1, 1, 2 do
		for j = -1, 1, 2 do
			local engine = Instance.new("Part")
			engine.Name = "Engine"
			engine.Size = Vector3.new(0.6, 0.2, 0.6)
			engine.Position = position + Vector3.new(i * 0.8, -0.4, j * 0.8)
			engine.Anchored = true
			engine.CanCollide = false
			engine.Color = BOT_COLORS.special.accent
			engine.Material = Enum.Material.Neon
			engine.Parent = model
		end
	end

	model.PrimaryPart = body
	return model
end

function BotModels.CreateBotModel(botType: string, position: Vector3)
	if botType == "basic" then
		return BotModels.CreateBasicBot(position)
	elseif botType == "advanced" then
		return BotModels.CreateAdvancedBot(position)
	elseif botType == "special" then
		return BotModels.CreateSpecialBot(position)
	end
	return BotModels.CreateBasicBot(position) -- Fallback to basic
end

function BotModels.AnimateBot(model: Model, state: string, botType: string)
	local animations = {}

	-- Bob animation for idle and moving
	if state == "idle" or state == "moving" then
		local config = ANIMATIONS[state]
		local body = model.PrimaryPart
		local originalY = body.Position.Y

		-- Create bobbing animation
		local tweenInfo = TweenInfo.new(
			1 / config.bobSpeed,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut,
			-1, -- Repeat infinitely
			true -- Reverses
		)

		local tween = TweenService:Create(body, tweenInfo, {
			Position = Vector3.new(body.Position.X, originalY + config.bobHeight, body.Position.Z),
		})
		table.insert(animations, tween)

		-- Wheel rotation for moving state
		if state == "moving" and botType ~= "special" then
			for _, part in ipairs(model:GetChildren()) do
				if part.Name == "Wheel" then
					local tweenInfo =
						TweenInfo.new(1 / config.wheelSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
					local tween = TweenService:Create(part, tweenInfo, {
						Orientation = Vector3.new(0, 0, 90 + 360),
					})
					table.insert(animations, tween)
				end
			end
		end
	end

	-- Charging animation
	if state == "charging" then
		local config = ANIMATIONS.charging
		for _, part in ipairs(model:GetChildren()) do
			if part.Name == "Core" or part.Name == "Sensor" or part.Name == "Dome" then
				local originalColor = part.Color
				local tweenInfo =
					TweenInfo.new(1 / config.pulseSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
				local tween = TweenService:Create(part, tweenInfo, {
					Color = originalColor:Lerp(Color3.new(1, 1, 1), config.pulseIntensity),
				})
				table.insert(animations, tween)
			end
		end
	end

	-- Error animation
	if state == "error" then
		local config = ANIMATIONS.error
		for _, part in ipairs(model:GetChildren()) do
			if part:IsA("BasePart") then
				local originalColor = part.Color
				local tweenInfo =
					TweenInfo.new(1 / config.flashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
				local tween = TweenService:Create(part, tweenInfo, {
					Color = Color3.fromRGB(255, 80, 80),
				})
				table.insert(animations, tween)
			end
		end
	end

	-- Play all animations
	for _, tween in ipairs(animations) do
		tween:Play()
	end

	return animations
end

return BotModels
