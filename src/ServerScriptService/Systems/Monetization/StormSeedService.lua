--!strict
-- ServerScriptService/Systems/Monetization/StormSeedService.lua
-- Handles the purchasable Storm Seed flow without granting exclusive rewards beyond normal event participation.

local MarketplaceService = game:GetService("MarketplaceService")

local StormSeedService = {}
StormSeedService.__index = StormSeedService

local STORM_SEED_PRODUCT_ID = 1001001

function StormSeedService.new(weatherManager, remotesFolder: Folder)
	local self = setmetatable({}, StormSeedService)
	self._weatherManager = weatherManager
	self._stormSeedRequestedRemote = remotesFolder:WaitForChild("StormSeedRequested") :: RemoteEvent
	self._purchaseFeedbackRemote = remotesFolder:WaitForChild("PurchaseFeedback") :: RemoteEvent
	return self
end

function StormSeedService:initialize()
	self._stormSeedRequestedRemote.OnServerEvent:Connect(function(player, requestedEventId: string, biome: string)
		MarketplaceService:PromptProductPurchase(player, STORM_SEED_PRODUCT_ID)
		self._purchaseFeedbackRemote:FireClient(player, {
			status = "Prompted",
			message = string.format("Storm Seed purchase opened for %s in %s", requestedEventId, biome),
		})
		player:SetAttribute("PendingStormSeedEventId", requestedEventId)
		player:SetAttribute("PendingStormSeedBiome", biome)
	end)

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		if receiptInfo.ProductId == STORM_SEED_PRODUCT_ID then
			local requestedEventId = player:GetAttribute("PendingStormSeedEventId")
			local biome = player:GetAttribute("PendingStormSeedBiome")
			if typeof(requestedEventId) == "string" and typeof(biome) == "string" then
				self._weatherManager:setWeather(requestedEventId, biome)
			end
			self._purchaseFeedbackRemote:FireAllClients({
				status = "Activated",
				message = string.format("%s triggered a Storm Seed over %s!", player.Name, biome or "the region"),
			})
		end

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

return StormSeedService
