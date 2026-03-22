--!strict
-- StarterPlayer/StarterPlayerScripts/Controllers/WeatherClientController.client.lua
-- Client presentation controller for weather HUD, alerts, and local wet-surface reactions.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local weatherStateUpdated = remotes:WaitForChild("WeatherStateUpdated") :: RemoteEvent
local stormEventAnnounce = remotes:WaitForChild("StormEventAnnounce") :: RemoteEvent
local encounterStarted = remotes:WaitForChild("CreatureEncounterStarted") :: RemoteEvent

local function applyWetnessVisuals(state)
	local wetness = if state then state.wetness else 0
	for _, part in CollectionService:GetTagged("WeatherReactive") do
		if part:IsA("BasePart") then
			part.Reflectance = math.clamp(wetness * 0.25, 0, 0.2)
		end
	end
end

weatherStateUpdated.OnClientEvent:Connect(function(state)
	applyWetnessVisuals(state)
	print("Weather updated", state and state.displayName or "Clear Skies")
end)

stormEventAnnounce.OnClientEvent:Connect(function(payload)
	print("Storm incoming:", payload.message)
end)

encounterStarted.OnClientEvent:Connect(function(payload)
	print("Creature encounter started:", payload.displayName, payload.duration)
end)
