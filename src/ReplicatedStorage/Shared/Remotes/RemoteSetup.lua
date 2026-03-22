--!strict
-- ReplicatedStorage/Shared/Remotes/RemoteSetup.lua
-- Creates or retrieves all replicated RemoteEvents/RemoteFunctions required by the MVP.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteSetup = {}

local REMOTE_EVENT_NAMES = {
	"WeatherStateUpdated",
	"StormEventAnnounce",
	"CreatureEncounterStarted",
	"CreatureEncounterEnded",
	"StormSeedRequested",
	"ForceStormEventRequested",
	"PurchaseFeedback",
	"JournalUpdated",
}

local REMOTE_FUNCTION_NAMES = {
	"RequestForecast",
}

local function getOrCreateFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

function RemoteSetup.initialize()
	local sharedFolder = getOrCreateFolder(ReplicatedStorage, "Shared")
	local remotesFolder = getOrCreateFolder(sharedFolder, "Remotes")

	for _, remoteName in REMOTE_EVENT_NAMES do
		if not remotesFolder:FindFirstChild(remoteName) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = remoteName
			remote.Parent = remotesFolder
		end
	end

	for _, remoteName in REMOTE_FUNCTION_NAMES do
		if not remotesFolder:FindFirstChild(remoteName) then
			local remote = Instance.new("RemoteFunction")
			remote.Name = remoteName
			remote.Parent = remotesFolder
		end
	end

	return remotesFolder
end

return RemoteSetup
