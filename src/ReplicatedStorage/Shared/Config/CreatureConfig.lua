--!strict
-- ReplicatedStorage/Shared/Config/CreatureConfig.lua
-- Shared creature definitions used for server spawn checks and client journal presentation.

local CreatureConfig = {
	LightningSerpent = {
		id = "LightningSerpent",
		displayName = "Lightning Serpent",
		rarity = "Legendary",
		spawnWeather = { "CataclysmicLightningFront" },
		preferredBiomes = { "ThunderstepPlains", "SkybreakExpanse" },
		encounterDuration = 150,
		studyReward = 120,
	},
	StaticHare = {
		id = "StaticHare",
		displayName = "Static Hare",
		rarity = "Uncommon",
		spawnWeather = { "HeavyThunderstorm" },
		preferredBiomes = { "ThunderstepPlains" },
		encounterDuration = 60,
		studyReward = 25,
	},
	RainbackTortoise = {
		id = "RainbackTortoise",
		displayName = "Rainback Tortoise",
		rarity = "Common",
		spawnWeather = { "PassingRain" },
		preferredBiomes = { "StarterBasin", "SunkenBloomMarsh" },
		encounterDuration = 90,
		studyReward = 10,
	},
}

return CreatureConfig
