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
		self._lightningSerpentController:tryStartEncounter()
	else
		self._lightningSerpentController:endEncounter("Weather moved on")
	end
end

return CreatureEncounterService
