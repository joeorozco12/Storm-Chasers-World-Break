--!strict
-- ServerScriptService/Systems/Weather/WeatherManager.lua
-- Server-authoritative weather state manager. Clients only receive replicated summaries.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeatherConfig = require(ReplicatedStorage.Shared.Config.WeatherConfig)

export type ActiveWeatherState = {
	eventId: string,
	displayName: string,
	rarity: string,
	intensity: number,
	wetness: number,
	biome: string,
	startedAt: number,
	endsAt: number,
	hazards: { string },
}

local WeatherManager = {}
WeatherManager.__index = WeatherManager

function WeatherManager.new(remotesFolder: Folder)
	local self = setmetatable({}, WeatherManager)
	self._remotesFolder = remotesFolder
	self._weatherUpdatedRemote = remotesFolder:WaitForChild("WeatherStateUpdated") :: RemoteEvent
	self._announceRemote = remotesFolder:WaitForChild("StormEventAnnounce") :: RemoteEvent
	self._currentState = nil :: ActiveWeatherState?
	return self
end

function WeatherManager:getCurrentState(): ActiveWeatherState?
	return self._currentState
end

function WeatherManager:setWeather(eventId: string, biome: string, durationOverride: number?)
	local descriptor = WeatherConfig.EventCatalog[eventId]
	assert(descriptor, string.format("Unknown weather event '%s'", eventId))

	local durationRange = descriptor.duration
	local chosenDuration = durationOverride or math.random(durationRange.Min, durationRange.Max)
	local now = os.time()

	self._currentState = {
		eventId = descriptor.id,
		displayName = descriptor.displayName,
		rarity = descriptor.rarity,
		intensity = descriptor.intensity,
		wetness = descriptor.wetness,
		biome = biome,
		startedAt = now,
		endsAt = now + chosenDuration,
		hazards = descriptor.hazards,
	}

	self._weatherUpdatedRemote:FireAllClients(self._currentState)
	self._announceRemote:FireAllClients({
		message = string.format("%s is forming over %s", descriptor.displayName, biome),
		eventId = descriptor.id,
		rarity = descriptor.rarity,
	})

	return self._currentState
end

function WeatherManager:clearWeather()
	self._currentState = nil
	self._weatherUpdatedRemote:FireAllClients(nil)
end

return WeatherManager
