--!strict
-- StarterPlayer/StarterPlayerScripts/Controllers/WeatherClientController.client.lua
-- Client presentation controller for weather HUD, alerts, and local wet-surface reactions.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local NetworkTypes = require(sharedFolder:WaitForChild("Types"):WaitForChild("NetworkTypes"))
local remotes = sharedFolder:WaitForChild("Remotes")
local weatherStateUpdated = remotes:WaitForChild("WeatherStateUpdated") :: RemoteEvent
local stormEventAnnounce = remotes:WaitForChild("StormEventAnnounce") :: RemoteEvent
local encounterStarted = remotes:WaitForChild("CreatureEncounterStarted") :: RemoteEvent
local encounterEnded = remotes:WaitForChild("CreatureEncounterEnded") :: RemoteEvent
local purchaseFeedback = remotes:WaitForChild("PurchaseFeedback") :: RemoteEvent
local journalUpdated = remotes:WaitForChild("JournalUpdated") :: RemoteEvent
local forceStormEventRequested = remotes:WaitForChild("ForceStormEventRequested") :: RemoteEvent
local requestForecast = remotes:WaitForChild("RequestForecast") :: RemoteFunction

type ActiveWeatherState = NetworkTypes.ActiveWeatherState
type StormAnnouncementPayload = NetworkTypes.StormAnnouncementPayload
type CreatureEncounterStartedPayload = NetworkTypes.CreatureEncounterStartedPayload
type CreatureEncounterEndedPayload = NetworkTypes.CreatureEncounterEndedPayload
type PurchaseFeedbackPayload = NetworkTypes.PurchaseFeedbackPayload
type JournalUpdatedPayload = NetworkTypes.JournalUpdatedPayload
type ForceStormEventRequest = NetworkTypes.ForceStormEventRequest

type ForecastSnapshot = {
	currentState: ActiveWeatherState?,
	debugForce: ForceStormEventRequest,
	studioEnabled: boolean,
}

local currentWeatherState = nil :: ActiveWeatherState?
local currentEncounterState = nil :: CreatureEncounterStartedPayload?
local journalState = nil :: JournalUpdatedPayload?
local studioEnabled = RunService:IsStudio()
local forceButtonLocked = false
local debugForceRequest = {
	eventId = "CataclysmicLightningFront",
	biome = "ThunderstepPlains",
	duration = 90,
} :: ForceStormEventRequest

local function stylePanel(panel: GuiObject)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(73, 133, 163)
	stroke.Transparency = 0.2
	stroke.Parent = panel
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StormDebugHud"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0, 0)
panel.Position = UDim2.fromOffset(16, 18)
panel.Size = UDim2.fromOffset(360, 246)
panel.BackgroundColor3 = Color3.fromRGB(8, 19, 30)
panel.BackgroundTransparency = 0.12
panel.Parent = screenGui
stylePanel(panel)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 12)
title.Size = UDim2.new(1, -32, 0, 24)
title.Font = Enum.Font.GothamBold
title.Text = "Storm Chasers Debug"
title.TextColor3 = Color3.fromRGB(217, 238, 244)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local body = Instance.new("TextLabel")
body.Name = "Body"
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(16, 44)
body.Size = UDim2.new(1, -32, 1, -114)
body.Font = Enum.Font.RobotoMono
body.Text = "Loading weather state..."
body.TextColor3 = Color3.fromRGB(214, 225, 232)
body.TextSize = 16
body.TextWrapped = false
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.Parent = panel

local banner = Instance.new("TextLabel")
banner.Name = "Banner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 18)
banner.Size = UDim2.fromOffset(560, 42)
banner.BackgroundColor3 = Color3.fromRGB(14, 41, 60)
banner.BackgroundTransparency = 0.05
banner.Font = Enum.Font.GothamMedium
banner.Text = "Studio weather tools ready."
banner.TextColor3 = Color3.fromRGB(229, 243, 249)
banner.TextSize = 18
banner.Parent = screenGui
stylePanel(banner)

local forceButton = Instance.new("TextButton")
forceButton.Name = "ForceStormButton"
forceButton.Position = UDim2.fromOffset(16, 204)
forceButton.Size = UDim2.new(1, -32, 0, 28)
forceButton.AutoButtonColor = true
forceButton.BackgroundColor3 = Color3.fromRGB(25, 90, 122)
forceButton.Font = Enum.Font.GothamBold
forceButton.Text = "Force Lightning Front"
forceButton.TextColor3 = Color3.fromRGB(237, 248, 252)
forceButton.TextSize = 15
forceButton.Parent = panel
stylePanel(forceButton)

local function setBanner(message: string)
	banner.Text = message
end

local function applyWetnessVisuals(state: ActiveWeatherState?)
	local wetness = if state then state.wetness else 0
	for _, part in CollectionService:GetTagged("WeatherReactive") do
		if part:IsA("BasePart") then
			part.Reflectance = math.clamp(wetness * 0.25, 0, 0.2)
		end
	end
end

local function buildBodyText(): string
	local weatherName = if currentWeatherState
		then currentWeatherState.displayName
		else "Clear Skies"
	local rarity = if currentWeatherState then currentWeatherState.rarity else "-"
	local biome = if currentWeatherState then currentWeatherState.biome else "StarterBasin"
	local secondsRemaining = if currentWeatherState
		then math.max(0, currentWeatherState.endsAt - os.time())
		else 0
	local wetness = if currentWeatherState then currentWeatherState.wetness else 0
	local encounterText = if currentEncounterState
		then string.format(
			"%s (%ds window)",
			currentEncounterState.displayName,
			currentEncounterState.duration
		)
		else "Idle"
	local journalText = if journalState
		then string.format(
			"%d weather / %d creatures",
			journalState.weatherDiscoveries,
			journalState.creatureDiscoveries
		)
		else "Awaiting profile"
	local currencyText = if journalState
		then string.format(
			"%d shards / %d notes",
			journalState.stormShards,
			journalState.researchNotes
		)
		else "0 shards / 0 notes"

	return table.concat({
		string.format("Weather   : %s", weatherName),
		string.format("Rarity    : %s", rarity),
		string.format("Biome     : %s", biome),
		string.format("Timer     : %ds", secondsRemaining),
		string.format("Wetness   : %.2f", wetness),
		string.format("Encounter : %s", encounterText),
		string.format("Journal   : %s", journalText),
		string.format("Currencies: %s", currencyText),
	}, "\n")
end

local function refreshHud()
	body.Text = buildBodyText()
	forceButton.Visible = studioEnabled
end

weatherStateUpdated.OnClientEvent:Connect(function(state: ActiveWeatherState?)
	currentWeatherState = state
	applyWetnessVisuals(state)
	setBanner(string.format("Weather updated: %s", state and state.displayName or "Clear Skies"))
	refreshHud()
end)

stormEventAnnounce.OnClientEvent:Connect(function(payload: StormAnnouncementPayload)
	setBanner(payload.message)
end)

encounterStarted.OnClientEvent:Connect(function(payload: CreatureEncounterStartedPayload)
	currentEncounterState = payload
	setBanner(string.format("Encounter started: %s", payload.displayName))
	refreshHud()
end)

encounterEnded.OnClientEvent:Connect(function(payload: CreatureEncounterEndedPayload)
	if currentEncounterState and currentEncounterState.creatureId == payload.creatureId then
		currentEncounterState = nil
	end
	setBanner(payload.reason)
	refreshHud()
end)

purchaseFeedback.OnClientEvent:Connect(function(payload: PurchaseFeedbackPayload)
	setBanner(payload.message)
end)

journalUpdated.OnClientEvent:Connect(function(payload: JournalUpdatedPayload)
	journalState = payload
	refreshHud()
end)

forceButton.MouseButton1Click:Connect(function()
	if not studioEnabled or forceButtonLocked then
		return
	end

	forceButtonLocked = true
	forceButton.Text = "Forcing..."
	forceStormEventRequested:FireServer(debugForceRequest)
	task.delay(0.8, function()
		if forceButton.Parent then
			forceButtonLocked = false
			forceButton.Text = "Force Lightning Front"
		end
	end)
end)

task.spawn(function()
	while screenGui.Parent do
		refreshHud()
		task.wait(0.25)
	end
end)

local ok, forecast = pcall(function()
	return requestForecast:InvokeServer()
end)

if ok and typeof(forecast) == "table" then
	local typedForecast = forecast :: ForecastSnapshot
	if typeof(typedForecast.studioEnabled) == "boolean" then
		studioEnabled = typedForecast.studioEnabled
	end
	if typeof(typedForecast.debugForce) == "table" then
		if typeof(typedForecast.debugForce.eventId) == "string" then
			debugForceRequest.eventId = typedForecast.debugForce.eventId
		end
		if typeof(typedForecast.debugForce.biome) == "string" then
			debugForceRequest.biome = typedForecast.debugForce.biome
		end
		if typeof(typedForecast.debugForce.duration) == "number" then
			debugForceRequest.duration = typedForecast.debugForce.duration
		end
	end
	currentWeatherState = typedForecast.currentState
	applyWetnessVisuals(currentWeatherState)
end

refreshHud()
