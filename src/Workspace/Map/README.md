# Workspace Map Starter Notes

This folder mirrors the first playable world slice for Roblox Studio assembly.

## Section 16.A.1 scope
- **Starter Basin** is the onboarding biome with the safe camp, starter build plots, and the first storm-view ridge.
- **Thunderstep Plains** is the first danger biome with exposed traversal lanes and the Lightning Serpent encounter field.
- Shared metadata for spawn points, landmarks, weather zones, route segments, and encounter anchors lives in `ReplicatedStorage/Shared/Config/MapSliceConfig.lua`.

## Expected Studio folders
Create or mirror these folders under `Workspace/Map` in Studio:
- `Biomes`
- `Landmarks`
- `SpawnPoints`
- `WeatherZones`

Keep the placed models/parts named after the IDs in `MapSliceConfig.lua` so later systems can resolve them consistently.
