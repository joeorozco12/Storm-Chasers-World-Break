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
	return self
end

function StormScheduler:_pickEventForRarity(rarity: string): string
	local matching = {}
	for eventId, descriptor in WeatherConfig.EventCatalog do
		if descriptor.rarity == rarity then
			table.insert(matching, eventId)
		end
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

function StormScheduler:start()
	if self._running then
		return
	end
	self._running = true

	task.spawn(function()
		while self._running do
			local rarity = weightedRoll(WeatherConfig.RarityWeights)
			local eventId = self:_pickEventForRarity(rarity)
			local biome = self:_pickBiomeForEvent(eventId)
			local state = self._weatherManager:setWeather(eventId, biome)
			local remaining = math.max(1, state.endsAt - os.time())
			task.wait(remaining)
			self._weatherManager:clearWeather()
			task.wait(math.random(self._defaultDowntime.Min, self._defaultDowntime.Max))
		end
	end)
end

function StormScheduler:stop()
	self._running = false
end

return StormScheduler
