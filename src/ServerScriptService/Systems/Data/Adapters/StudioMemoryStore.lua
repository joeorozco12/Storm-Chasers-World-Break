--!strict
-- ServerScriptService/Systems/Data/Adapters/StudioMemoryStore.lua
-- In-memory persistence adapter used for Studio-first bootstrap testing.

local ServerScriptService = game:GetService("ServerScriptService")
local DiscoveryData = require(ServerScriptService.Systems.Data.DiscoveryData)

type DiscoveryBlob = DiscoveryData.DiscoveryBlob

local StudioMemoryStore = {}
StudioMemoryStore.__index = StudioMemoryStore

local function cloneValue(value)
	if type(value) ~= "table" then
		return value
	end

	local cloned = {}
	for key, nestedValue in pairs(value) do
		cloned[cloneValue(key)] = cloneValue(nestedValue)
	end

	return cloned
end

function StudioMemoryStore.new()
	local self = setmetatable({}, StudioMemoryStore)
	self._profiles = {} :: { [number]: DiscoveryBlob }
	return self
end

function StudioMemoryStore:load(userId: number): DiscoveryBlob?
	local profile = self._profiles[userId]
	if not profile then
		return nil
	end

	return cloneValue(profile) :: DiscoveryBlob
end

function StudioMemoryStore:save(userId: number, profile: DiscoveryBlob)
	self._profiles[userId] = cloneValue(profile) :: DiscoveryBlob
end

return StudioMemoryStore
