--!strict
-- ServerScriptService/Boot/ServerBootstrap.server.lua
-- MVP bootstrap that wires the server-authoritative weather loop, creature encounters, wet-surface updates, and monetization hooks.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local CreatureConfig = require(ReplicatedStorage.Shared.Config.CreatureConfig)
local NetworkTypes = require(ReplicatedStorage.Shared.Types.NetworkTypes)
local WeatherConfig = require(ReplicatedStorage.Shared.Config.WeatherConfig)
local RemoteSetup = require(ReplicatedStorage.Shared.Remotes.RemoteSetup)
local WorldBootstrap = require(ServerScriptService.Boot.WorldBootstrap)
local WeatherManager = require(ServerScriptService.Systems.Weather.WeatherManager)
local StormScheduler = require(ServerScriptService.Systems.Weather.StormScheduler)
local LightningStormSystem = require(ServerScriptService.Systems.Weather.LightningStormSystem)
local WetSurfaceService = require(ServerScriptService.Systems.Weather.WetSurfaceService)
local MapSliceService = require(ServerScriptService.Systems.World.MapSliceService)
local LightningSerpentController = require(ServerScriptService.Systems.Creatures.LightningSerpentController)
local CreatureEncounterService = require(ServerScriptService.Systems.Creatures.CreatureEncounterService)
local LightningSerpentController =
	require(ServerScriptService.Systems.Creatures.LightningSerpentController)
local CreatureEncounterService =
	require(ServerScriptService.Systems.Creatures.CreatureEncounterService)
local PlayerDataService = require(ServerScriptService.Systems.Data.PlayerDataService)
local ReceiptRouter = require(ServerScriptService.Systems.Monetization.ReceiptRouter)
local StormSeedService = require(ServerScriptService.Systems.Monetization.StormSeedService)

WorldBootstrap.build()

local remotesFolder = RemoteSetup.initialize()
local mapSliceService = MapSliceService.new()
local purchaseFeedbackRemote = remotesFolder:WaitForChild("PurchaseFeedback") :: RemoteEvent
local forceStormEventRequested =
	remotesFolder:WaitForChild("ForceStormEventRequested") :: RemoteEvent
local requestForecast = remotesFolder:WaitForChild("RequestForecast") :: RemoteFunction
local weatherManager = WeatherManager.new(remotesFolder)
local stormScheduler = StormScheduler.new(weatherManager, mapSliceService)
local lightningStormSystem = LightningStormSystem.new(weatherManager)
local wetSurfaceService = WetSurfaceService.new(weatherManager)
local lightningSerpentController = LightningSerpentController.new(weatherManager, remotesFolder, mapSliceService)
local creatureEncounterService = CreatureEncounterService.new(weatherManager, lightningSerpentController)
local stormSeedService = StormSeedService.new(weatherManager, remotesFolder)
local lightningSerpentController = LightningSerpentController.new(weatherManager, remotesFolder)
local creatureEncounterService =
	CreatureEncounterService.new(weatherManager, lightningSerpentController)
local playerDataService = PlayerDataService.new(remotesFolder)
local receiptRouter = ReceiptRouter.new()
local stormSeedService = StormSeedService.new(weatherManager, receiptRouter, remotesFolder)

local function rewardWeatherDiscovery(state)
	if not state then
		return
	end

	local shardReward = math.max(1, math.floor(state.intensity * 10))
	for _, player in Players:GetPlayers() do
		playerDataService:recordWeather(player, state.eventId, shardReward)
	end
end

local function rewardCreatureDiscovery(creatureId: string)
	local descriptor = CreatureConfig[creatureId]
	if not descriptor then
		return
	end

	for _, player in Players:GetPlayers() do
		playerDataService:recordCreature(player, creatureId, descriptor.studyReward)
	end
end

local function loadPlayerProfile(player: Player)
	playerDataService:loadProfile(player)
end

requestForecast.OnServerInvoke = function()
	return {
		currentState = weatherManager:getCurrentState(),
		debugForce = {
			eventId = WeatherConfig.DeveloperDefaults.forceEventId,
			biome = WeatherConfig.DeveloperDefaults.forceBiome,
			duration = WeatherConfig.DeveloperDefaults.forceDuration,
		},
		studioEnabled = RunService:IsStudio(),
	}
end

weatherManager.Changed:Connect(function(state)
	wetSurfaceService:applyCurrentStateToTaggedParts()

	local creatureId = creatureEncounterService:handleWeatherChanged()
	if state then
		rewardWeatherDiscovery(state)
	end
	if creatureId then
		rewardCreatureDiscovery(creatureId)
	end
end)

forceStormEventRequested.OnServerEvent:Connect(function(player, request)
	if not RunService:IsStudio() then
		purchaseFeedbackRemote:FireClient(
			player,
			NetworkTypes.createPurchaseFeedback(
				"Rejected",
				"Force-storm tools are only enabled in Studio."
			)
		)
		return
	end

	local requestTable = if typeof(request) == "table" then request else {}
	local eventId = if typeof(requestTable.eventId) == "string"
		then requestTable.eventId
		else WeatherConfig.DeveloperDefaults.forceEventId
	local biome = if typeof(requestTable.biome) == "string"
		then requestTable.biome
		else WeatherConfig.DeveloperDefaults.forceBiome
	local duration = if typeof(requestTable.duration) == "number"
		then requestTable.duration
		else WeatherConfig.DeveloperDefaults.forceDuration

	local ok, forcedStateOrError = pcall(function()
		return stormScheduler:forceEvent(eventId, biome, duration)
	end)

	if not ok then
		purchaseFeedbackRemote:FireClient(
			player,
			NetworkTypes.createPurchaseFeedback(
				"Rejected",
				string.format("Could not force storm: %s", tostring(forcedStateOrError))
			)
		)
		return
	end

	purchaseFeedbackRemote:FireClient(
		player,
		NetworkTypes.createPurchaseFeedback(
			"Activated",
			string.format(
				"Forced %s over %s.",
				forcedStateOrError.displayName,
				forcedStateOrError.biome
			)
		)
	)
end)

receiptRouter:initialize()
stormSeedService:initialize()
wetSurfaceService:applyCurrentStateToTaggedParts()

Players.PlayerAdded:Connect(loadPlayerProfile)
Players.PlayerRemoving:Connect(function(player)
	playerDataService:unloadProfile(player)
end)

for _, player in Players:GetPlayers() do
	loadPlayerProfile(player)
end

lightningStormSystem:start()
stormScheduler:start()
