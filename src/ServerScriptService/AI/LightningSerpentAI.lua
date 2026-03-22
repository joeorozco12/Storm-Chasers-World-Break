--!strict
-- ServerScriptService/AI/LightningSerpentAI.lua
-- Simple looping AI that circles, dives, and idles to give the Lightning Serpent a dramatic sky presence.

local LightningSerpentAI = {}
LightningSerpentAI.__index = LightningSerpentAI

function LightningSerpentAI.new(model: Model, center: Vector3?)
	local self = setmetatable({}, LightningSerpentAI)
	self._model = model
	self._running = false
	self._angle = 0
	self._center = center or Vector3.new(0, 120, 0)
	self._radius = 180
	return self
end

function LightningSerpentAI:_stepOrbit()
	self._angle += math.rad(10)
	local offset = Vector3.new(
		math.cos(self._angle) * self._radius,
		math.sin(self._angle * 2) * 18,
		math.sin(self._angle) * self._radius
	)
	local position = self._center + offset
	self._model:PivotTo(CFrame.new(position, self._center))
end

function LightningSerpentAI:_performDive()
	local target = self._center + Vector3.new(math.random(-60, 60), 30, math.random(-60, 60))
	self._model:PivotTo(CFrame.new(target))
	task.wait(0.4)
	self._model:PivotTo(CFrame.new(self._center + Vector3.new(0, 150, 0), self._center))
end

function LightningSerpentAI:start()
	if self._running then
		return
	end
	self._running = true

	task.spawn(function()
		local ticks = 0
		while self._running and self._model.Parent do
			ticks += 1
			self:_stepOrbit()
			if ticks % 12 == 0 then
				self:_performDive()
			end
			task.wait(0.25)
		end
	end)
end

function LightningSerpentAI:stop()
	self._running = false
end

return LightningSerpentAI
