--!strict
-- ServerScriptService/Systems/Weather/WetSurfaceService.lua
-- MVP hook that toggles attributes/tags for world parts so clients or shaders can react with wet-surface visuals.

local CollectionService = game:GetService("CollectionService")

local WetSurfaceService = {}
WetSurfaceService.__index = WetSurfaceService

function WetSurfaceService.new(weatherManager)
	local self = setmetatable({}, WetSurfaceService)
	self._weatherManager = weatherManager
	return self
end

function WetSurfaceService:applyCurrentStateToTaggedParts()
	local state = self._weatherManager:getCurrentState()
	local wetness = if state then state.wetness else 0

	for _, part in CollectionService:GetTagged("WeatherReactive") do
		if part:IsA("BasePart") then
			part:SetAttribute("Wetness", wetness)
			part:SetAttribute("StormEventId", if state then state.eventId else "")
		end
	end
end

return WetSurfaceService
