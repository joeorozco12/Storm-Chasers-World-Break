--!strict
-- ServerScriptService/Systems/Creatures/CreatureEncounterService.lua
-- Example encounter loop that watches weather changes and starts/stops the Lightning Serpent event.

local CreatureEncounterService = {}
CreatureEncounterService.__index = CreatureEncounterService

function CreatureEncounterService.new(weatherManager, lightningSerpentController)
	local self = setmetatable({}, CreatureEncounterService)
	self._weatherManager = weatherManager
	self._lightningSerpentController = lightningSerpentController
	return self
end

function CreatureEncounterService:handleWeatherChanged()
	local state = self._weatherManager:getCurrentState()
	if state and state.eventId == "CataclysmicLightningFront" then
		if self._lightningSerpentController:tryStartEncounter() then
			return "LightningSerpent"
		end
	else
		self._lightningSerpentController:endEncounter("Weather moved on")
	end

	return nil
end

return CreatureEncounterService
