--!strict
-- ServerScriptService/Systems/World/MapSliceService.lua
-- Provides validated access to the MVP map-slice metadata used by spawns, weather routing, and encounter staging.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MapSliceConfig = require(ReplicatedStorage.Shared.Config.MapSliceConfig)

local MapSliceService = {}
MapSliceService.__index = MapSliceService

local function indexById<T>(items: { T }): { [string]: T }
	local indexed = {}
	for _, item in ipairs(items) do
		local itemId = (item :: any).id
		assert(type(itemId) == "string" and itemId ~= "", "Map slice entries require a non-empty id")
		indexed[itemId] = item
	end
	return indexed
end

function MapSliceService.new()
	local self = setmetatable({}, MapSliceService)
	self._config = MapSliceConfig
	self._landmarksById = indexById(MapSliceConfig.Landmarks)
	self._spawnPointsById = indexById(MapSliceConfig.SpawnPoints)
	self._weatherZonesById = indexById(MapSliceConfig.WeatherZones)
	self:_validateConfig()
	return self
end

function MapSliceService:_validateConfig()
	assert(#self._config.BiomeOrder >= 2, "Map slice should include at least two biomes")

	for _, biomeId in ipairs(self._config.BiomeOrder) do
		assert(self._config.BiomeCatalog[biomeId] ~= nil, string.format("Missing biome catalog entry for %s", biomeId))
	end

	for _, route in ipairs(self._config.RouteSegments) do
		assert(self._landmarksById[route.fromLandmarkId] ~= nil, string.format("Unknown route origin %s", route.fromLandmarkId))
		assert(self._landmarksById[route.toLandmarkId] ~= nil, string.format("Unknown route destination %s", route.toLandmarkId))
	end

	for creatureId, anchorInfo in self._config.EncounterAnchors do
		assert(self._landmarksById[anchorInfo.primaryLandmarkId] ~= nil, string.format("Unknown primary encounter anchor for %s", creatureId))
		for _, fallbackId in ipairs(anchorInfo.fallbackLandmarkIds or {}) do
			assert(self._landmarksById[fallbackId] ~= nil, string.format("Unknown fallback encounter anchor %s for %s", fallbackId, creatureId))
		end
	end
end

function MapSliceService:getActiveSliceId(): string
	return self._config.ActiveSliceId
end

function MapSliceService:getBiomeIds(): { string }
	return table.clone(self._config.BiomeOrder)
end

function MapSliceService:getSpawnPoint(spawnPointId: string)
	return self._spawnPointsById[spawnPointId]
end

function MapSliceService:getLandmark(landmarkId: string)
	return self._landmarksById[landmarkId]
end

function MapSliceService:getLandmarksForBiome(biomeId: string): { any }
	local matches = {}
	for _, landmark in ipairs(self._config.Landmarks) do
		if landmark.biome == biomeId then
			table.insert(matches, landmark)
		end
	end
	return matches
end

function MapSliceService:getWeatherZonesForBiome(biomeId: string): { any }
	local matches = {}
	for _, zone in ipairs(self._config.WeatherZones) do
		if zone.biome == biomeId then
			table.insert(matches, zone)
		end
	end
	return matches
end

function MapSliceService:getEncounterAnchor(creatureId: string)
	return self._config.EncounterAnchors[creatureId]
end

return MapSliceService
