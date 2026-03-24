# Storm Chasers: World Break

This repository contains the Roblox-first bootstrap for **Storm Chasers: World Break**:

- a full game vision and systems design document in `docs/GAME_FOUNDATION.md`
- a Roblox Studio-oriented architecture plan and folder structure
- MVP-ready Luau starter modules for weather, encounters, monetization hooks, and persistence under `src/`
- a concrete MVP map-slice foundation for `StarterBasin -> ThunderstepPlains`, including landmarks, weather zones, route metadata, and encounter anchors
- a publish-ready Roblox store page package in `docs/STORE_PAGE_PACKAGE.md`
- a Rojo-based Luau source tree under `src/`
- a Studio-ready MVP bootstrap for weather, encounters, monetization hooks, player journal data, and a development play space

## Workflow

The repository is set up for a filesystem-first workflow:

1. Install [Rokit](https://github.com/rojo-rbx/rokit).
2. Run `~/.rokit/bin/rokit install` from the repo root.
3. Install the Rojo Studio plugin in Roblox Studio.
4. Start a sync server with `~/.rokit/bin/rojo serve default.project.json`.
5. Connect Studio to Rojo and run the place.

The code in `src/` is the source of truth. Avoid editing gameplay scripts directly inside Studio unless you plan to sync those changes back into the repository immediately.

## Repository Commands

- `~/.rokit/bin/rokit install`: install project tools from `rokit.toml`
- `~/.rokit/bin/stylua --check .`: verify formatting
- `~/.rokit/bin/selene src`: lint Luau sources
- `~/.rokit/bin/rojo build default.project.json -o build/StormChasersWorldBreak.rbxlx`: build a place file from source
- `~/.rokit/bin/rojo serve default.project.json`: sync the project into Studio

## First Playable Slice

Running the project in Studio now bootstraps a small development arena automatically:

- a neutral spawn platform
- weather-reactive terrain pieces that show wetness changes
- lightning strike targets
- an encounter marker used by the Lightning Serpent controller
- a client debug HUD with storm state, journal counters, and a Studio-only force-storm button

Use the debug HUD button in Studio to force a `CataclysmicLightningFront` over `ThunderstepPlains` for repeatable testing.

## Project Structure

- `default.project.json`: canonical Rojo mapping
- `docs/STORE_PAGE_PACKAGE.md`: store title, copy, thumbnail briefs, and icon direction
- `rokit.toml`: pinned Roblox CLI toolchain
- `src/ReplicatedStorage`: shared config, remotes, and network contracts
- `src/ServerScriptService`: authoritative gameplay systems and bootstraps
- `src/StarterPlayer`: client controllers

Track notable repository updates in `CHANGELOG.md`.
