--!strict
-- ServerScriptService/Systems/Monetization/ReceiptRouter.lua
-- Central receipt entrypoint so multiple dev products can coexist without overwriting ProcessReceipt.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local ReceiptRouter = {}
ReceiptRouter.__index = ReceiptRouter

type ReceiptInfoLike = {
	PlayerId: number,
	ProductId: number,
}

export type ReceiptHandler = (
	player: Player,
	receiptInfo: ReceiptInfoLike
) -> Enum.ProductPurchaseDecision

function ReceiptRouter.new()
	local self = setmetatable({}, ReceiptRouter)
	self._handlers = {} :: { [number]: ReceiptHandler }
	self._initialized = false
	return self
end

function ReceiptRouter:initialize()
	if self._initialized then
		return
	end

	self._initialized = true
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local handler = self._handlers[receiptInfo.ProductId]
		if not handler then
			warn(
				string.format("No receipt handler registered for product %d", receiptInfo.ProductId)
			)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		return handler(player, receiptInfo)
	end
end

function ReceiptRouter:registerProductHandler(productId: number, handler: ReceiptHandler)
	self._handlers[productId] = handler
end

return ReceiptRouter
