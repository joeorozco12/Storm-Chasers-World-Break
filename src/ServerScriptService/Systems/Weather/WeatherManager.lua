--!strict
-- ServerScriptService/Systems/Weather/WeatherManager.lua
-- Server-authoritative weather state manager. Clients only receive replicated summaries.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkTypes = require(ReplicatedStorage.Shared.Types.NetworkTypes)
local WeatherConfig = require(ReplicatedStorage.Shared.Config.WeatherConfig)

type ActiveWeatherState = NetworkTypes.ActiveWeatherState

local WeatherManager = {}
WeatherManager.__index = WeatherManager

function WeatherManager.new(remotesFolder: Folder)
	local self = setmetatable({}, WeatherManager)
	self._remotesFolder = remotesFolder
	self._weatherUpdatedRemote = remotesFolder:WaitForChild("WeatherStateUpdated") :: RemoteEvent
	self._announceRemote = remotesFolder:WaitForChild("StormEventAnnounce") :: RemoteEvent
	self._changedEvent = Instance.new("BindableEvent")
	self._currentState = nil :: ActiveWeatherState?
	self.Changed = self._changedEvent.Event
	return self
end

function WeatherManager:getCurrentState(): ActiveWeatherState?
	return self._currentState
end

function WeatherManager:_publishState(announcementPayload)
	self._weatherUpdatedRemote:FireAllClients(self._currentState)
	self._changedEvent:Fire(self._currentState)

	if announcementPayload then
		self._announceRemote:FireAllClients(announcementPayload)
	end
end

function WeatherManager:setWeather(eventId: string, biome: string, durationOverride: number?)
	local descriptor = WeatherConfig.getEventDescriptor(eventId)
	assert(descriptor, string.format("Unknown weather event '%s'", eventId))
	assert(
		WeatherConfig.isBiomeSupported(eventId, biome),
		string.format("Weather event '%s' does not support biome '%s'", eventId, biome)
	)

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

	self:_publishState(
		NetworkTypes.createStormAnnouncement(
			descriptor.id,
			descriptor.displayName,
			descriptor.rarity,
			biome
		)
	)
	return self._currentState
end

function WeatherManager:clearWeather()
	if self._currentState == nil then
		return
	end

	self._currentState = nil
	self:_publishState(nil)
end

return WeatherManager
