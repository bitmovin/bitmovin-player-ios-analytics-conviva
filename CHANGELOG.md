# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [3.5.0] - 2024-12-13

### Fixed
- Build error when using Bitmovin Player version 3.78.0 or newer

### Changed
- Updated the Bitmovin Player version used in the Example application to 3.79.0

## [3.4.1] - 2024-08-26

### Fixed
- Potential crash during ad tracking due to accessing Player APIs on a background thread

## [3.4.0] - 2024-08-26

### Added
- Warning logs in case the `viewerId` or `applicationName` is missing
- Possibility to start session tracking without a `Player` instance
  - `ConvivaAnalytics.init(customerKey:config:)` initializer without a `Player`
  - `ConvivaAnalytics.attach(player:)` to attach the `Player` at a later point in the session life-cycle

### Fixed
- Wrong initial Content Length reported when pre-roll ads are present

## [3.3.2] - 2024-07-26

### Fixed
- Missing viewer ID and Player Name collection for client-side ads
- Invalid session ID errors in Conviva Touchstone when using ads
- Missing metadata Content Length error reported for live streams

## [3.3.1] - 2024-07-14

### Fixed
- Missing content length reporting when autoplay is enabled

## [3.3.0] - 2024-07-04

### Added
- `MetadataOverrides.imaSdkVersion` as a replacement for `MetadataOverrides.imaSdkVerison` to set the IMA SDK version
- Tracking of `c3.ad.firstCreativeId` and `c3.ad.firstAdSystem` tags for VAST client side ads
- `ConvivaAnalytics.ssai` namespace to enable server side ad tracking

### Changed
- Updated minimum Bitmovin Player version to 3.64.0

### Deprecated
- `MetadataOverrides.imaSdkVerison` in favor of `MetadataOverrides.imaSdkVersion`

### Fixed
- Wrong value tracked for `c3.ad.description` for VAST client side ads

### Internal
- `ConvivaAnalytics` internal state is now stored in private properties

## [3.2.0] - 2024-06-07

### Added
- Ad analytics for ad event reporting
- Ad tracking support on tvOS
- The IMA SDK and sample ads to the tvOS sample app
- `MetadataOverrides.additionalStandardTags` that allows to set additional standard tags for the session. The List of tags can be found here: [Pre-defined Video and Content Metadata](https://pulse.conviva.com/learning-center/content/sensor_developer_center/sensor_integration/ios/ios_stream_sensor.html#Predefined_video_meta)

### Changed
- Ad break started and ended is now reported with `AdBreakStartedEvent` and `AdBreakFinishedEvent`

### Internal
- Added a Gemfile to pin the CocoaPods version to 1.15.2
- Added a Github Actions workflow to validate code style using SwiftLint
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
