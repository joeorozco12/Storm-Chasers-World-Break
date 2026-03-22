# Changelog

All notable changes to this project will be documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]
### Added
- Created a project changelog to document notable updates moving forward.
- Added a Rojo + Rokit repository scaffold with project config, linting, formatting, build automation, and CI checks.
- Added a development world bootstrap, a Studio debug HUD, and a force-storm path for repeatable local testing.
- Added a shared network contract layer, an in-memory player data service, and a centralized receipt router for dev products.
- Added a Roblox store page package with final copy, icon direction, thumbnail briefs, benchmark notes, and review checks in `docs/STORE_PAGE_PACKAGE.md`.

### Changed
- Reworked weather flow integration to use an explicit weather change signal instead of bootstrap-time method monkey-patching.
- Upgraded the starter bootstrap so server systems, player journal data, and the client debug view stay in sync during local playtests.

## [2026-03-22]
### Added
- Established the initial repository structure and project scaffold.
- Added the complete game vision and systems foundation in `docs/GAME_FOUNDATION.md`.
- Added Roblox Studio-oriented starter modules for weather, encounters, monetization hooks, shared config, remotes, and persistence under `src/`.
- Documented the repository entry point and setup guidance in `README.md`.
