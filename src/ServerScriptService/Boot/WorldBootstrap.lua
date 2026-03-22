--!strict
-- ServerScriptService/Boot/WorldBootstrap.lua
-- Creates a compact development play space so the repo is runnable in Studio from a clean checkout.

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local WorldBootstrap = {}

local DEV_WORLD_NAME = "StormChasersDevWorld"

local function getOrCreateChild(parent: Instance, name: string, className: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function tagWeatherReactive(part: BasePart)
	if not CollectionService:HasTag(part, "WeatherReactive") then
		CollectionService:AddTag(part, "WeatherReactive")
	end
end

local function configureWeatherPart(part: BasePart, size: Vector3, position: Vector3, color: Color3)
	part.Anchored = true
	part.CanCollide = true
	part.Size = size
	part.Position = position
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.Slate
	part.Color = color
	tagWeatherReactive(part)
end

function WorldBootstrap.build()
	local devWorld = getOrCreateChild(Workspace, DEV_WORLD_NAME, "Folder") :: Folder
	local lightningTargets = getOrCreateChild(Workspace, "LightningTargets", "Folder") :: Folder
	local encounterMarkers = getOrCreateChild(Workspace, "EncounterMarkers", "Folder") :: Folder

	local spawn = getOrCreateChild(devWorld, "DevSpawn", "SpawnLocation") :: SpawnLocation
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 8, 42)
	spawn.Material = Enum.Material.Metal
	spawn.Color = Color3.fromRGB(87, 127, 151)

	local valleyFloor = getOrCreateChild(devWorld, "ValleyFloor", "Part") :: Part
	configureWeatherPart(
		valleyFloor,
		Vector3.new(128, 6, 128),
		Vector3.new(0, 0, 0),
		Color3.fromRGB(61, 89, 64)
	)

	local approachRidge = getOrCreateChild(devWorld, "ApproachRidge", "Part") :: Part
	configureWeatherPart(
		approachRidge,
		Vector3.new(42, 18, 24),
		Vector3.new(-34, 9, -12),
		Color3.fromRGB(76, 84, 90)
	)

	local stormPad = getOrCreateChild(devWorld, "StormPad", "Part") :: Part
	configureWeatherPart(
		stormPad,
		Vector3.new(30, 2, 30),
		Vector3.new(24, 4, -18),
		Color3.fromRGB(70, 95, 107)
	)
	stormPad.Material = Enum.Material.SmoothPlastic

	local lightningRodNorth = getOrCreateChild(lightningTargets, "RodNorth", "Part") :: Part
	lightningRodNorth.Anchored = true
	lightningRodNorth.CanCollide = true
	lightningRodNorth.Size = Vector3.new(3, 28, 3)
	lightningRodNorth.Position = Vector3.new(-18, 14, -40)
	lightningRodNorth.Material = Enum.Material.Metal
	lightningRodNorth.Color = Color3.fromRGB(149, 164, 170)
	tagWeatherReactive(lightningRodNorth)

	local lightningRodSouth = getOrCreateChild(lightningTargets, "RodSouth", "Part") :: Part
	lightningRodSouth.Anchored = true
	lightningRodSouth.CanCollide = true
	lightningRodSouth.Size = Vector3.new(3, 34, 3)
	lightningRodSouth.Position = Vector3.new(28, 17, -28)
	lightningRodSouth.Material = Enum.Material.Metal
	lightningRodSouth.Color = Color3.fromRGB(149, 164, 170)
	tagWeatherReactive(lightningRodSouth)

	local encounterCenter =
		getOrCreateChild(encounterMarkers, "LightningSerpentCenter", "Part") :: Part
	encounterCenter.Anchored = true
	encounterCenter.CanCollide = false
	encounterCenter.Size = Vector3.new(2, 2, 2)
	encounterCenter.Position = Vector3.new(0, 10, -12)
	encounterCenter.Transparency = 1

	Workspace.Gravity = 196.2
end

return WorldBootstrap
