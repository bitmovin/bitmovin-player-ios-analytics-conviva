# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added
- Ad tracking support on tvOS

### Internal
- Added a Gemfile to pin the CocoaPods version to 1.15.2
- Added a Github Actions workflow to run the unit tests

## [3.1.0] - 2024-05-27

### Added
- Hook into `onTimeChanged` callback for reporting Play head time (PHT) to Conviva playback metric.

### Changed
- Raised minimum deployment targets to iOS/tvOS 14.0
- Updated minimum Bitmovin Player version to 3.63.0

### Removed
- iOS/tvOS 12 and 13 support

## [3.0.1]

### Fixed

- Some errors introduced by recent logging changes

## [3.0.0]

### Added

- Added `release()` method for use at end of app lifecycle

### Changed

- Utilises Conviva's Simple SDK instead of the old interface
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
