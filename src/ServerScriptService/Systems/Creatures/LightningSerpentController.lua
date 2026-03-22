--!strict
-- ServerScriptService/Systems/Creatures/LightningSerpentController.lua
-- Spawns the Lightning Serpent during legendary lightning events and starts a lightweight encounter loop.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local CreatureConfig = require(ReplicatedStorage.Shared.Config.CreatureConfig)
local LightningSerpentAI = require(ServerScriptService.AI.LightningSerpentAI)

local LightningSerpentController = {}
LightningSerpentController.__index = LightningSerpentController

function LightningSerpentController.new(weatherManager, remotesFolder: Folder)
	local self = setmetatable({}, LightningSerpentController)
	self._weatherManager = weatherManager
	self._encounterStartedRemote = remotesFolder:WaitForChild("CreatureEncounterStarted") :: RemoteEvent
	self._encounterEndedRemote = remotesFolder:WaitForChild("CreatureEncounterEnded") :: RemoteEvent
	self._activeModel = nil :: Model?
	self._activeAI = nil
	return self
end

function LightningSerpentController:_buildSerpentModel(): Model
	local model = Instance.new("Model")
	model.Name = "LightningSerpent"

	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.Neon
	core.Color = Color3.fromRGB(130, 220, 255)
	core.Size = Vector3.new(8, 8, 8)
	core.Anchored = true
	core.CanCollide = false
	core.Parent = model
	model.PrimaryPart = core

	model.Parent = Workspace
	return model
end

function LightningSerpentController:tryStartEncounter()
	local currentState = self._weatherManager:getCurrentState()
	if not currentState or currentState.eventId ~= "CataclysmicLightningFront" then
		return false
	end
	if self._activeModel then
		return false
	end

	local model = self:_buildSerpentModel()
	model:PivotTo(CFrame.new(0, 120, 0))
	self._activeModel = model
	self._activeAI = LightningSerpentAI.new(model)
	self._activeAI:start()

	local descriptor = CreatureConfig.LightningSerpent
	self._encounterStartedRemote:FireAllClients({
		creatureId = descriptor.id,
		displayName = descriptor.displayName,
		duration = descriptor.encounterDuration,
	})

	task.delay(descriptor.encounterDuration, function()
		self:endEncounter("Storm window collapsed")
	end)

	return true
end

function LightningSerpentController:endEncounter(reason: string)
	if self._activeAI then
		self._activeAI:stop()
		self._activeAI = nil
	end

	if self._activeModel then
		self._activeModel:Destroy()
		self._activeModel = nil
	end

	self._encounterEndedRemote:FireAllClients({
		creatureId = "LightningSerpent",
		reason = reason,
	})
end

return LightningSerpentController
