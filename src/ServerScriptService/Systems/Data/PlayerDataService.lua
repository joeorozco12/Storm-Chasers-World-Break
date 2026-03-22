--!strict
-- ServerScriptService/Systems/Data/PlayerDataService.lua
-- Loads, updates, and publishes lightweight discovery data snapshots for local iteration.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetworkTypes = require(ReplicatedStorage.Shared.Types.NetworkTypes)
local DiscoveryData = require(ServerScriptService.Systems.Data.DiscoveryData)
local StudioMemoryStore = require(ServerScriptService.Systems.Data.Adapters.StudioMemoryStore)

type DiscoveryBlob = DiscoveryData.DiscoveryBlob

local PlayerDataService = {}
PlayerDataService.__index = PlayerDataService

local function countEntries(dictionary): number
	local total = 0
	for _ in pairs(dictionary) do
		total += 1
	end
	return total
end

function PlayerDataService.new(remotesFolder: Folder)
	local self = setmetatable({}, PlayerDataService)
	self._journalUpdatedRemote = remotesFolder:WaitForChild("JournalUpdated") :: RemoteEvent
	self._store = StudioMemoryStore.new()
	self._profiles = {} :: { [number]: DiscoveryBlob }
	return self
end

function PlayerDataService:_publishProfile(player: Player, profile: DiscoveryBlob)
	self._journalUpdatedRemote:FireClient(
		player,
		NetworkTypes.createJournalUpdatedPayload(
			profile.version,
			profile.currencies.stormShards,
			profile.currencies.researchNotes,
			countEntries(profile.discoveries.creatures),
			countEntries(profile.discoveries.weather)
		)
	)
end

function PlayerDataService:loadProfile(player: Player): DiscoveryBlob
	local profile = self._profiles[player.UserId]
	if profile then
		return profile
	end

	profile = self._store:load(player.UserId) or DiscoveryData.newProfile()
	self._profiles[player.UserId] = profile
	self:_publishProfile(player, profile)
	return profile
end

function PlayerDataService:saveProfile(player: Player)
	local profile = self._profiles[player.UserId]
	if not profile then
		return
	end

	self._store:save(player.UserId, profile)
end

function PlayerDataService:unloadProfile(player: Player)
	self:saveProfile(player)
	self._profiles[player.UserId] = nil
end

function PlayerDataService:recordCreature(
	player: Player,
	creatureId: string,
	researchReward: number
)
	local profile = self:loadProfile(player)
	DiscoveryData.recordCreature(profile, creatureId, researchReward)
	self._store:save(player.UserId, profile)
	self:_publishProfile(player, profile)
end

function PlayerDataService:recordWeather(player: Player, eventId: string, shardReward: number)
	local profile = self:loadProfile(player)
	DiscoveryData.recordWeather(profile, eventId, shardReward)
	self._store:save(player.UserId, profile)
	self:_publishProfile(player, profile)
end

return PlayerDataService
