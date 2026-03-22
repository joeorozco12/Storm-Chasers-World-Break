--!strict
-- ServerScriptService/Systems/Data/DiscoveryData.lua
-- Compact versioned data model for player discoveries, weather encounters, and journal progress.

export type DiscoveryBlob = {
	version: number,
	currencies: {
		stormShards: number,
		researchNotes: number,
	},
	discoveries: {
		creatures: { [string]: number },
		weather: { [string]: number },
		landmarks: { [string]: boolean },
	},
	unlocks: {
		buildTiers: { [string]: boolean },
		forecastTools: { [string]: boolean },
	},
}

local DiscoveryData = {}

function DiscoveryData.newProfile(): DiscoveryBlob
	return {
		version = 1,
		currencies = {
			stormShards = 0,
			researchNotes = 0,
		},
		discoveries = {
			creatures = {},
			weather = {},
			landmarks = {},
		},
		unlocks = {
			buildTiers = {
				BasicShelter = true,
			},
			forecastTools = {
				WeatherLens = true,
			},
		},
	}
end

function DiscoveryData.recordCreature(
	profile: DiscoveryBlob,
	creatureId: string,
	researchReward: number
)
	profile.discoveries.creatures[creatureId] = (profile.discoveries.creatures[creatureId] or 0) + 1
	profile.currencies.researchNotes += researchReward
end

function DiscoveryData.recordWeather(profile: DiscoveryBlob, eventId: string, shardReward: number)
	profile.discoveries.weather[eventId] = (profile.discoveries.weather[eventId] or 0) + 1
	profile.currencies.stormShards += shardReward
end

return DiscoveryData
