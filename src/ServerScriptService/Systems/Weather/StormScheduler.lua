--!strict
-- ServerScriptService/Systems/Weather/StormScheduler.lua
-- Selects weather events on an interval and feeds the WeatherManager with server-authored choices.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeatherConfig = require(ReplicatedStorage.Shared.Config.WeatherConfig)

local StormScheduler = {}
StormScheduler.__index = StormScheduler

local function weightedRoll(weights: { [string]: number }): string
	local total = 0
	for _, weight in weights do
		total += weight
	end

	local roll = math.random() * total
	local cursor = 0
	for key, weight in weights do
		cursor += weight
		if roll <= cursor then
			return key
		end
	end

	return "Normal"
end

function StormScheduler.new(weatherManager, biomeProvider)
	local self = setmetatable({}, StormScheduler)
	self._weatherManager = weatherManager
	self._biomeProvider = biomeProvider
	self._running = false
	self._defaultDowntime = NumberRange.new(25, 45)
	self._phase = "Idle"
	self._nextTransitionAt = 0
	return self
end

function StormScheduler:_pickEventForRarity(rarity: string): string
	local matching = {}
	for eventId, descriptor in WeatherConfig.EventCatalog do
		if descriptor.rarity == rarity then
			table.insert(matching, eventId)
		end
	end

	if #matching == 0 then
		return WeatherConfig.DefaultEventId
	end

	return matching[math.random(1, #matching)]
end

function StormScheduler:_pickBiomeForEvent(eventId: string): string
	local descriptor = WeatherConfig.EventCatalog[eventId]
	local activeBiomes = if self._biomeProvider and self._biomeProvider.getBiomeIds then self._biomeProvider:getBiomeIds() else nil
	local supportedBiomes = descriptor.biomes or activeBiomes

	if activeBiomes and descriptor.biomes then
		local activeLookup = {}
		for _, biomeId in ipairs(activeBiomes) do
			activeLookup[biomeId] = true
		end

		local filtered = {}
		for _, biomeId in ipairs(descriptor.biomes) do
			if activeLookup[biomeId] then
				table.insert(filtered, biomeId)
			end
		end

		if #filtered > 0 then
			supportedBiomes = filtered
		end
	end

	assert(supportedBiomes and #supportedBiomes > 0, string.format("No active biomes support weather event '%s'", eventId))
	return supportedBiomes[math.random(1, #supportedBiomes)]
end

function StormScheduler:_scheduleDowntime(now: number?)
	local currentTime = now or os.time()
	self._phase = "Downtime"
	self._nextTransitionAt = currentTime
		+ math.random(self._defaultDowntime.Min, self._defaultDowntime.Max)
end

function StormScheduler:_startScheduledEvent()
	local rarity = weightedRoll(WeatherConfig.RarityWeights)
	local eventId = self:_pickEventForRarity(rarity)
	local biome = self:_pickBiomeForEvent(eventId)
	local state = self._weatherManager:setWeather(eventId, biome)
	self._phase = "Active"
	self._nextTransitionAt = state.endsAt
	return state
end

function StormScheduler:_tick()
	local now = os.time()
	local currentState = self._weatherManager:getCurrentState()

	if currentState then
		self._phase = "Active"
		self._nextTransitionAt = currentState.endsAt

		if now >= currentState.endsAt then
			self._weatherManager:clearWeather()
			self:_scheduleDowntime(now)
		end

		return
	end

	if self._phase == "Idle" then
		self:_scheduleDowntime(now)
		return
	end

	if now >= self._nextTransitionAt then
		self:_startScheduledEvent()
	end
end

function StormScheduler:start()
	if self._running then
		return
	end
	self._running = true
	self._phase = "Idle"
	self._nextTransitionAt = os.time()

	task.spawn(function()
		while self._running do
			self:_tick()
			task.wait(1)
		end
	end)
end

function StormScheduler:forceEvent(eventId: string, biome: string, durationOverride: number?)
	local state = self._weatherManager:setWeather(eventId, biome, durationOverride)
	self._phase = "Active"
	self._nextTransitionAt = state.endsAt
	return state
end

function StormScheduler:stop()
	self._running = false
	self._phase = "Idle"
end

return StormScheduler
