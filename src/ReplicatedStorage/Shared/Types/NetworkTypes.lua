--!strict
-- ReplicatedStorage/Shared/Types/NetworkTypes.lua
-- Shared payload contracts used by both server systems and client presentation.

export type ActiveWeatherState = {
	eventId: string,
	displayName: string,
	rarity: string,
	intensity: number,
	wetness: number,
	biome: string,
	startedAt: number,
	endsAt: number,
	hazards: { string },
}

export type StormAnnouncementPayload = {
	message: string,
	eventId: string,
	rarity: string,
	biome: string,
}

export type CreatureEncounterStartedPayload = {
	creatureId: string,
	displayName: string,
	duration: number,
}

export type CreatureEncounterEndedPayload = {
	creatureId: string,
	reason: string,
}

export type PurchaseFeedbackPayload = {
	status: "Prompted" | "Activated" | "Rejected",
	message: string,
}

export type JournalUpdatedPayload = {
	version: number,
	stormShards: number,
	researchNotes: number,
	creatureDiscoveries: number,
	weatherDiscoveries: number,
}

export type ForceStormEventRequest = {
	eventId: string,
	biome: string,
	duration: number,
}

local NetworkTypes = {}

function NetworkTypes.createStormAnnouncement(
	eventId: string,
	displayName: string,
	rarity: string,
	biome: string
): StormAnnouncementPayload
	return {
		message = string.format("%s is forming over %s", displayName, biome),
		eventId = eventId,
		rarity = rarity,
		biome = biome,
	}
end

function NetworkTypes.createEncounterStartedPayload(
	creatureId: string,
	displayName: string,
	duration: number
): CreatureEncounterStartedPayload
	return {
		creatureId = creatureId,
		displayName = displayName,
		duration = duration,
	}
end

function NetworkTypes.createEncounterEndedPayload(
	creatureId: string,
	reason: string
): CreatureEncounterEndedPayload
	return {
		creatureId = creatureId,
		reason = reason,
	}
end

function NetworkTypes.createPurchaseFeedback(
	status: "Prompted" | "Activated" | "Rejected",
	message: string
): PurchaseFeedbackPayload
	return {
		status = status,
		message = message,
	}
end

function NetworkTypes.createJournalUpdatedPayload(
	version: number,
	stormShards: number,
	researchNotes: number,
	creatureDiscoveries: number,
	weatherDiscoveries: number
): JournalUpdatedPayload
	return {
		version = version,
		stormShards = stormShards,
		researchNotes = researchNotes,
		creatureDiscoveries = creatureDiscoveries,
		weatherDiscoveries = weatherDiscoveries,
	}
end

return table.freeze(NetworkTypes)
