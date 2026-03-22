--!strict
-- ServerScriptService/Systems/Weather/LightningStormSystem.lua
-- Handles server-side lightning strike simulation and hooks for storm-state-driven world reactions.

local Workspace = game:GetService("Workspace")

local LightningStormSystem = {}
LightningStormSystem.__index = LightningStormSystem

function LightningStormSystem.new(weatherManager)
	local self = setmetatable({}, LightningStormSystem)
	self._weatherManager = weatherManager
	self._running = false
	self._lightningFolder = Workspace:FindFirstChild("LightningTargets")
	return self
end

function LightningStormSystem:_getEligibleTargets(): { BasePart }
	local targets = {}
	self._lightningFolder = Workspace:FindFirstChild("LightningTargets")
	if not self._lightningFolder then
		return targets
	end

	for _, descendant in self._lightningFolder:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(targets, descendant)
		end
	end

	return targets
end

function LightningStormSystem:_strikeRandomTarget()
	local state = self._weatherManager:getCurrentState()
	if not state or not table.find(state.hazards, "Lightning") then
		return
	end

	local targets = self:_getEligibleTargets()
	if #targets == 0 then
		return
	end

	local target = targets[math.random(1, #targets)]
	local strikeMarker = Instance.new("Attachment")
	strikeMarker.Name = "LightningStrikeMarker"
	strikeMarker.Parent = target
	task.delay(0.15, function()
		if strikeMarker.Parent then
			strikeMarker:Destroy()
		end
	end)
end

function LightningStormSystem:start()
	if self._running then
		return
	end
	self._running = true

	task.spawn(function()
		while self._running do
			self:_strikeRandomTarget()
			task.wait(math.random(2, 5))
		end
	end)
end

function LightningStormSystem:stop()
	self._running = false
end

return LightningStormSystem
