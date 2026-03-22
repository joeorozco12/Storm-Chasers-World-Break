--!strict
-- ReplicatedStorage/Shared/Config/MapSliceConfig.lua
-- Shared configuration for the MVP world slice that links Starter Basin into Thunderstep Plains.

export type Vector3Like = {
	x: number,
	y: number,
	z: number,
}

export type SpawnPoint = {
	id: string,
	displayName: string,
	position: Vector3Like,
	yawDegrees: number,
	tags: { string },
}

export type Landmark = {
	id: string,
	displayName: string,
	biome: string,
	position: Vector3Like,
	description: string,
	gameplayPurpose: string,
}

export type WeatherZone = {
	id: string,
	biome: string,
	center: Vector3Like,
	size: Vector3Like,
	allowedEvents: { string },
	intensityBias: number,
}

export type RouteSegment = {
	id: string,
	fromLandmarkId: string,
	toLandmarkId: string,
	riskLevel: string,
	description: string,
}

local MapSliceConfig = {
	ActiveSliceId = "StarterBasinToThunderstepPlains",
	SliceDisplayName = "Starter Basin to Thunderstep Plains",
	BiomeOrder = { "StarterBasin", "ThunderstepPlains" },
	BiomeCatalog = {
		StarterBasin = {
			id = "StarterBasin",
			displayName = "Starter Basin",
			description = "Calm valley tutorial biome with forgiving weather, visible shelter plots, and the first forecast vantage point.",
			recommendedWeather = { "PassingRain", "DenseFogBank", "HeavyThunderstorm" },
			buildMaterials = { "Wood", "Sealstone", "Resin" },
			creatures = { "RainbackTortoise" },
		},
		ThunderstepPlains = {
			id = "ThunderstepPlains",
			displayName = "Thunderstep Plains",
			description = "Open grasslands with exposed ridges, lightning hazard teaching moments, and the first legendary encounter runway.",
			recommendedWeather = { "HeavyThunderstorm", "WindSquall", "CataclysmicLightningFront" },
			buildMaterials = { "Wood", "ConductiveCopper", "Stormglass" },
			creatures = { "StaticHare", "LightningSerpent" },
		},
	},
	SpawnPoints = {
		{
			id = "BasinArrival",
			displayName = "Basin Arrival",
			position = { x = 0, y = 12, z = 0 },
			yawDegrees = 0,
			tags = { "Default", "Tutorial", "Safe" },
		},
		{
			id = "RidgeRelay",
			displayName = "Ridge Relay",
			position = { x = 215, y = 20, z = -160 },
			yawDegrees = 45,
			tags = { "Unlockable", "ForecastView" },
		},
		{
			id = "PlainsForwardCamp",
			displayName = "Plains Forward Camp",
			position = { x = 520, y = 14, z = -80 },
			yawDegrees = 90,
			tags = { "Checkpoint", "StormChase" },
		},
	},
	Landmarks = {
		{
			id = "CalmwaterCamp",
			displayName = "Calmwater Camp",
			biome = "StarterBasin",
			position = { x = 40, y = 10, z = 20 },
			description = "Safe onboarding camp with journal station, shelter plot tutorial, and sightline to the plains horizon.",
			gameplayPurpose = "Onboarding",
		},
		{
			id = "ForecastRidge",
			displayName = "Forecast Ridge",
			biome = "StarterBasin",
			position = { x = 220, y = 42, z = -110 },
			description = "First major vista that frames the storm wall rolling into Thunderstep Plains.",
			gameplayPurpose = "Vista",
		},
		{
			id = "GroundingYard",
			displayName = "Grounding Yard",
			biome = "StarterBasin",
			position = { x = 145, y = 11, z = 110 },
			description = "Starter building plot cluster where players learn grounding rod placement before harsher storms.",
			gameplayPurpose = "Building",
		},
		{
			id = "StaticRun",
			displayName = "Static Run",
			biome = "ThunderstepPlains",
			position = { x = 470, y = 13, z = -40 },
			description = "Wind-swept chase lane that introduces knockback gusts and herd movement under thunderclouds.",
			gameplayPurpose = "Traversal",
		},
		{
			id = "RodspireField",
			displayName = "Rodspire Field",
			biome = "ThunderstepPlains",
			position = { x = 690, y = 18, z = 70 },
			description = "Tall conductive rock field designed for the first Lightning Serpent approach and server-wide visibility.",
			gameplayPurpose = "LegendaryEncounter",
		},
		{
			id = "StormwatchTower",
			displayName = "Stormwatch Tower",
			biome = "ThunderstepPlains",
			position = { x = 610, y = 34, z = -210 },
			description = "Group lookout that supports cooperative storm calls, screenshots, and beacon placement.",
			gameplayPurpose = "Social",
		},
	},
	WeatherZones = {
		{
			id = "StarterBasinCore",
			biome = "StarterBasin",
			center = { x = 80, y = 0, z = 30 },
			size = { x = 420, y = 220, z = 360 },
			allowedEvents = { "PassingRain", "DenseFogBank", "HeavyThunderstorm" },
			intensityBias = 0.9,
		},
		{
			id = "RidgeTransition",
			biome = "StarterBasin",
			center = { x = 280, y = 10, z = -70 },
			size = { x = 180, y = 240, z = 180 },
			allowedEvents = { "HeavyThunderstorm", "WindSquall" },
			intensityBias = 1.0,
		},
		{
			id = "ThunderstepWest",
			biome = "ThunderstepPlains",
			center = { x = 500, y = 0, z = -60 },
			size = { x = 320, y = 260, z = 280 },
			allowedEvents = { "HeavyThunderstorm", "WindSquall" },
			intensityBias = 1.1,
		},
		{
			id = "ThunderstepHeartland",
			biome = "ThunderstepPlains",
			center = { x = 720, y = 0, z = 80 },
			size = { x = 340, y = 300, z = 320 },
			allowedEvents = { "HeavyThunderstorm", "WindSquall", "CataclysmicLightningFront" },
			intensityBias = 1.3,
		},
	},
	RouteSegments = {
		{
			id = "CampToYard",
			fromLandmarkId = "CalmwaterCamp",
			toLandmarkId = "GroundingYard",
			riskLevel = "Low",
			description = "Short safe path that teaches resource pickups and shelter setup before weather pressure begins.",
		},
		{
			id = "YardToRidge",
			fromLandmarkId = "GroundingYard",
			toLandmarkId = "ForecastRidge",
			riskLevel = "Moderate",
			description = "Climb route with the first clear storm-wall read and enough elevation for tutorial camera moments.",
		},
		{
			id = "RidgeToStaticRun",
			fromLandmarkId = "ForecastRidge",
			toLandmarkId = "StaticRun",
			riskLevel = "Moderate",
			description = "Transition descent where wind and thunder telegraph that the player is leaving safety.",
		},
		{
			id = "StaticRunToRodspire",
			fromLandmarkId = "StaticRun",
			toLandmarkId = "RodspireField",
			riskLevel = "High",
			description = "Legendary chase runway with high visibility, surge hazards, and enough open ground for cooperative dodging.",
		},
		{
			id = "StaticRunToTower",
			fromLandmarkId = "StaticRun",
			toLandmarkId = "StormwatchTower",
			riskLevel = "Moderate",
			description = "Alternate group loop that supports social regrouping and storm scouting.",
		},
	},
	BuildPlotAnchors = {
		{ id = "StarterPlotA", biome = "StarterBasin", position = { x = 120, y = 10, z = 96 } },
		{ id = "StarterPlotB", biome = "StarterBasin", position = { x = 170, y = 10, z = 120 } },
		{ id = "PlainsPlotA", biome = "ThunderstepPlains", position = { x = 560, y = 12, z = 110 } },
	},
	EncounterAnchors = {
		LightningSerpent = {
			primaryLandmarkId = "RodspireField",
			fallbackLandmarkIds = { "StormwatchTower", "StaticRun" },
		},
	},
}

return MapSliceConfig
