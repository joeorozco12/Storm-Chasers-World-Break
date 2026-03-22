--!strict
-- ServerScriptService/Boot/ServerBootstrap.server.lua
-- MVP bootstrap that wires the server-authoritative weather loop, creature encounters, wet-surface updates, and monetization hooks.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RemoteSetup = require(ReplicatedStorage.Shared.Remotes.RemoteSetup)
local WeatherManager = require(ServerScriptService.Systems.Weather.WeatherManager)
local StormScheduler = require(ServerScriptService.Systems.Weather.StormScheduler)
local LightningStormSystem = require(ServerScriptService.Systems.Weather.LightningStormSystem)
local WetSurfaceService = require(ServerScriptService.Systems.Weather.WetSurfaceService)
local MapSliceService = require(ServerScriptService.Systems.World.MapSliceService)
local LightningSerpentController = require(ServerScriptService.Systems.Creatures.LightningSerpentController)
local CreatureEncounterService = require(ServerScriptService.Systems.Creatures.CreatureEncounterService)
local StormSeedService = require(ServerScriptService.Systems.Monetization.StormSeedService)

local remotesFolder = RemoteSetup.initialize()
local mapSliceService = MapSliceService.new()
local weatherManager = WeatherManager.new(remotesFolder)
local stormScheduler = StormScheduler.new(weatherManager, mapSliceService)
local lightningStormSystem = LightningStormSystem.new(weatherManager)
local wetSurfaceService = WetSurfaceService.new(weatherManager)
local lightningSerpentController = LightningSerpentController.new(weatherManager, remotesFolder, mapSliceService)
local creatureEncounterService = CreatureEncounterService.new(weatherManager, lightningSerpentController)
local stormSeedService = StormSeedService.new(weatherManager, remotesFolder)

local function onWeatherChanged()
	wetSurfaceService:applyCurrentStateToTaggedParts()
	creatureEncounterService:handleWeatherChanged()
end

local originalSetWeather = weatherManager.setWeather
function weatherManager:setWeather(eventId: string, biome: string, durationOverride: number?)
	local state = originalSetWeather(self, eventId, biome, durationOverride)
	onWeatherChanged()
	return state
end

local originalClearWeather = weatherManager.clearWeather
function weatherManager:clearWeather()
	originalClearWeather(self)
	onWeatherChanged()
end

stormSeedService:initialize()
lightningStormSystem:start()
stormScheduler:start()
