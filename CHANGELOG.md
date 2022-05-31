# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [3.0.0]

- This is first version using Bitmovin Player iOS V4 SDK. This is not backward compatible with previous versions of the player SDK.
- Utilises Conviva's Simple SDK instead of the old interface
- Added `release()` method for use at end of app lifecycle
- Internal changes to ConvivaAnalytics and related classes 

### Fixed

- Content length not set correctly (when using `initializeSession()`)

## [2.0.1]

### Fixed

- Stall events being over reported

## [2.0.0]

### Added

- This is first version using Bitmovin Player iOS V3 SDK. This is not backward compatible with V2 player SDK.

### Known Issues
- Playlist API available in V3 player SDK is not supported.

## [1.4.0]

### Fixed

- Re-Buffering events before initial playing state

### Added

- Tracking the current framerate

## [1.3.1] (2021-04-13) : First changelog entry. Consider this as baseline.

### Fixed

- Detach / attach player for AdBreaks
