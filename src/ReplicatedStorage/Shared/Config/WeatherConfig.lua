--!strict
-- ReplicatedStorage/Shared/Config/WeatherConfig.lua
-- Shared authoritative descriptors for all weather events used by both server logic and client presentation.

local WeatherConfig = {
	DefaultEventId = "PassingRain",
	EventCatalog = {
		PassingRain = {
			id = "PassingRain",
			displayName = "Passing Rain",
			rarity = "Normal",
			duration = NumberRange.new(90, 180),
			intensity = 0.25,
			wetness = 0.4,
			hazards = {},
			biomes = { "StarterBasin", "GlassreefCoast", "SunkenBloomMarsh" },
		},
		HeavyThunderstorm = {
			id = "HeavyThunderstorm",
			displayName = "Heavy Thunderstorm",
			rarity = "Normal",
			duration = NumberRange.new(120, 220),
			intensity = 0.7,
			wetness = 0.85,
			hazards = { "Lightning", "LowVisibility" },
			biomes = { "ThunderstepPlains", "StarterBasin", "GlassreefCoast" },
		},
		DenseFogBank = {
			id = "DenseFogBank",
			displayName = "Dense Fog Bank",
			rarity = "Normal",
			duration = NumberRange.new(120, 200),
			intensity = 0.35,
			wetness = 0.1,
			hazards = { "LowVisibility" },
			biomes = { "MistwoodCanopy", "SunkenBloomMarsh", "StarterBasin" },
		},
		WindSquall = {
			id = "WindSquall",
			displayName = "Wind Squall",
			rarity = "Normal",
			duration = NumberRange.new(60, 140),
			intensity = 0.55,
			wetness = 0.0,
			hazards = { "Knockback" },
			biomes = { "ThunderstepPlains", "GlassreefCoast", "RedstoneBadlands" },
		},
		CataclysmicLightningFront = {
			id = "CataclysmicLightningFront",
			displayName = "Cataclysmic Lightning Front",
			rarity = "Legendary",
			duration = NumberRange.new(180, 300),
			intensity = 1.0,
			wetness = 0.95,
			hazards = { "Lightning", "Surge", "HighWind" },
			biomes = { "ThunderstepPlains", "SkybreakExpanse" },
			creatureSpawns = { "LightningSerpent" },
		},
	},
	RarityWeights = {
		Normal = 75,
		Rare = 20,
		Legendary = 5,
	},
	HybridRules = {
		{ primary = "HeavyThunderstorm", secondary = "WindSquall", result = "Supercell" },
	},
}

return WeatherConfig
