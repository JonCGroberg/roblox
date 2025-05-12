--!strict
local Types = require(game:GetService("ReplicatedStorage").Core.Types)

-- Component
local BaseComponent = {}
BaseComponent.__index = BaseComponent

function BaseComponent.new(name: string, instance: Instance): Types.BaseComponent
	local self = setmetatable({}, BaseComponent)

	self.Name = name
	self.Instance = instance
	self.IsVisible = true
	self._events = {}

	return (self :: any) :: Types.BaseComponent
end

function BaseComponent.Show(self)
	if self.Instance:IsA("ScreenGui") then
		self.Instance.Enabled = true
	else
		self.Instance.Visible = true
	end
end

function BaseComponent.Hide(self)
	if self.Instance:IsA("ScreenGui") then
		self.Instance.Enabled = false
	else
		self.Instance.Visible = false
	end
end

function BaseComponent:Destroy()
	self:Emit("Destroy")
	self.Instance:Destroy()
end

function BaseComponent:Update(data: any)
	self:Emit("Update", data)
end

function BaseComponent:On(event: string, handler: Types.EventHandler)
	if not self._events[event] then
		self._events[event] = {}
	end

	table.insert(self._events[event], handler)
end

function BaseComponent:Off(event: string, handler: Types.EventHandler)
	if not self._events[event] then
		return
	end

	for i, h in self._events[event] do
		if h == handler then
			table.remove(self._events[event], i)
			break
		end
	end
end

function BaseComponent:Emit(event: string, ...: any)
	if not self._events[event] then
		return
	end

	for _, handler in self._events[event] do
		handler(self, ...)
	end
end

return BaseComponent
