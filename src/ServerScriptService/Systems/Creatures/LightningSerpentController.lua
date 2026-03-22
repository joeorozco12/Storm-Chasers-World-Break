--!strict
-- ServerScriptService/Systems/Creatures/LightningSerpentController.lua
-- Spawns the Lightning Serpent during legendary lightning events and starts a lightweight encounter loop.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local CreatureConfig = require(ReplicatedStorage.Shared.Config.CreatureConfig)
local NetworkTypes = require(ReplicatedStorage.Shared.Types.NetworkTypes)
local LightningSerpentAI = require(ServerScriptService.AI.LightningSerpentAI)

local LightningSerpentController = {}
LightningSerpentController.__index = LightningSerpentController

function LightningSerpentController.new(weatherManager, remotesFolder: Folder)
	local self = setmetatable({}, LightningSerpentController)
	self._weatherManager = weatherManager
	self._encounterStartedRemote =
		remotesFolder:WaitForChild("CreatureEncounterStarted") :: RemoteEvent
	self._encounterEndedRemote = remotesFolder:WaitForChild("CreatureEncounterEnded") :: RemoteEvent
	self._activeModel = nil :: Model?
	self._activeAI = nil
	self._encounterToken = 0
	return self
end

function LightningSerpentController:_resolveEncounterCenter(): Vector3
	local encounterMarkers = Workspace:FindFirstChild("EncounterMarkers")
	if encounterMarkers then
		local marker = encounterMarkers:FindFirstChild("LightningSerpentCenter")
		if marker and marker:IsA("BasePart") then
			return marker.Position + Vector3.new(0, 120, 0)
		end
	end

	return Vector3.new(0, 120, 0)
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

	self._encounterToken += 1
	local encounterToken = self._encounterToken
	local encounterCenter = self:_resolveEncounterCenter()
	local model = self:_buildSerpentModel()
	model:PivotTo(CFrame.new(encounterCenter))
	self._activeModel = model
	self._activeAI = LightningSerpentAI.new(model, encounterCenter)
	self._activeAI:start()

	local descriptor = CreatureConfig.LightningSerpent
	self._encounterStartedRemote:FireAllClients(
		NetworkTypes.createEncounterStartedPayload(
			descriptor.id,
			descriptor.displayName,
			descriptor.encounterDuration
		)
	)

	task.delay(descriptor.encounterDuration, function()
		if self._encounterToken == encounterToken then
			self:endEncounter("Storm window collapsed")
		end
	end)

	return true
end

function LightningSerpentController:endEncounter(reason: string)
	local wasActive = self._activeModel ~= nil or self._activeAI ~= nil
	self._encounterToken += 1

	if self._activeAI then
		self._activeAI:stop()
		self._activeAI = nil
	end

	if self._activeModel then
		self._activeModel:Destroy()
		self._activeModel = nil
	end

	if wasActive then
		self._encounterEndedRemote:FireAllClients(
			NetworkTypes.createEncounterEndedPayload("LightningSerpent", reason)
		)
	end
end

return LightningSerpentController
