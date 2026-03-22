--!strict
-- ServerScriptService/Systems/Monetization/StormSeedService.lua
-- Handles the purchasable Storm Seed flow without granting exclusive rewards beyond normal event participation.

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkTypes = require(ReplicatedStorage.Shared.Types.NetworkTypes)
local WeatherConfig = require(ReplicatedStorage.Shared.Config.WeatherConfig)

local StormSeedService = {}
StormSeedService.__index = StormSeedService

local STORM_SEED_PRODUCT_ID = 1001001

function StormSeedService.new(weatherManager, receiptRouter, remotesFolder: Folder)
	local self = setmetatable({}, StormSeedService)
	self._weatherManager = weatherManager
	self._receiptRouter = receiptRouter
	self._stormSeedRequestedRemote = remotesFolder:WaitForChild("StormSeedRequested") :: RemoteEvent
	self._purchaseFeedbackRemote = remotesFolder:WaitForChild("PurchaseFeedback") :: RemoteEvent
	self._pendingRequests = {} :: {
		[number]: {
			eventId: string,
			biome: string,
		},
	}
	self._initialized = false
	return self
end

function StormSeedService:_setPendingRequest(player: Player, eventId: string, biome: string)
	self._pendingRequests[player.UserId] = {
		eventId = eventId,
		biome = biome,
	}
	player:SetAttribute("PendingStormSeedEventId", eventId)
	player:SetAttribute("PendingStormSeedBiome", biome)
end

function StormSeedService:_clearPendingRequest(player: Player)
	self._pendingRequests[player.UserId] = nil
	player:SetAttribute("PendingStormSeedEventId", nil)
	player:SetAttribute("PendingStormSeedBiome", nil)
end

function StormSeedService:_validateRequest(
	requestedEventId: string,
	biome: string
): (boolean, string?)
	local descriptor = WeatherConfig.getEventDescriptor(requestedEventId)
	if not descriptor then
		return false, string.format("Unknown storm event '%s'.", requestedEventId)
	end

	if not WeatherConfig.isBiomeSupported(requestedEventId, biome) then
		return false, string.format("%s cannot be triggered in %s.", descriptor.displayName, biome)
	end

	return true, nil
end

function StormSeedService:initialize()
	if self._initialized then
		return
	end

	self._initialized = true
	self._stormSeedRequestedRemote.OnServerEvent:Connect(
		function(player, requestedEventId: string, biome: string)
			local isValid, errorMessage = self:_validateRequest(requestedEventId, biome)
			if not isValid then
				self._purchaseFeedbackRemote:FireClient(
					player,
					NetworkTypes.createPurchaseFeedback(
						"Rejected",
						errorMessage or "Storm Seed request rejected."
					)
				)
				return
			end

			self:_setPendingRequest(player, requestedEventId, biome)
			MarketplaceService:PromptProductPurchase(player, STORM_SEED_PRODUCT_ID)
			self._purchaseFeedbackRemote:FireClient(
				player,
				NetworkTypes.createPurchaseFeedback(
					"Prompted",
					string.format(
						"Storm Seed purchase opened for %s in %s.",
						requestedEventId,
						biome
					)
				)
			)
		end
	)

	self._receiptRouter:registerProductHandler(STORM_SEED_PRODUCT_ID, function(player)
		local pendingRequest = self._pendingRequests[player.UserId]
		if not pendingRequest then
			self._purchaseFeedbackRemote:FireClient(
				player,
				NetworkTypes.createPurchaseFeedback(
					"Rejected",
					"Storm Seed purchase completed, but no pending storm request was found."
				)
			)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		self._weatherManager:setWeather(pendingRequest.eventId, pendingRequest.biome)
		self:_clearPendingRequest(player)
		self._purchaseFeedbackRemote:FireAllClients(
			NetworkTypes.createPurchaseFeedback(
				"Activated",
				string.format(
					"%s triggered a Storm Seed over %s!",
					player.Name,
					pendingRequest.biome
				)
			)
		)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end)
end

return StormSeedService
