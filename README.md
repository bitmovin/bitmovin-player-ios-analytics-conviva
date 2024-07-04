# Bitmovin Player Conviva Analytics Integration
This is an open-source project to enable the use of a third-party component (Conviva) with the Bitmovin Player iOS SDK.

## Maintenance and Update
This project is not part of a regular maintenance or update schedule and is updated once yearly to conform with the latest product versions. For additional update requests, please take a look at the guidance further below.

## Contributions to this project
As an open-source project, we are pleased to accept any and all changes, updates and fixes from the community wishing to use this project. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more details on how to contribute.

## Reporting player bugs
If you come across a bug related to the player, please raise this through your support ticketing system.

## Need more help?
Should you want some help updating this project (update, modify, fix or otherwise) and cant contribute for any reason, please raise your request to your bitmovin account team, who can discuss your request.

## Support and SLA Disclaimer
As an open-source project and not a core product offering, any request, issue or query related to this project is excluded from any SLA and Support terms that a customer might have with either Bitmovin or another third-party service provider or Company contributing to this project. Any and all updates are purely at the contributor's discretion.

Thank you for your contributions!

## Installation

BitmovinConvivaAnalytics is available through [CocoaPods](https://cocoapods.org). We depend on cocoapods version >= 1.9.0

To install it, simply add the following line to your Podfile:

```ruby
pod 'BitmovinConvivaAnalytics', git: 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva.git', tag: '3.2.0'
```

Then, in your command line run:

```
pod repo update
pod install
```

### Compatibility

The 2.x and higher versions of the Conviva Analytics Integration depends on `BitmovinPlayer` version `>= 3.0.0`.

Note: `BitmovinPlayer` version `2.x.x` is not supported anymore. Please upgrade to `BitmovinPlayer` version `3.x.x`.

## Usage

### Basic Setup

The following example shows how to setup the `BitmovinConvivaAnalytics`:

```swift
do {
    convivaAnalytics = try ConvivaAnalytics(player: bitmovinPlayer,
                                            customerKey: "YOUR-CONVIVA-CUSTOMER-KEY")
} catch {
    NSLog("[ Example ] ConvivaAnalytics initialization failed with error: \(error)")
}
```

### Cleanup

At the end of the application's lifecycle, release the integration with:

```swift
    convivaAnalytics.release()
```

Details about usage of `BitmovinPlayer` can be found [here](https://github.com/bitmovin/bitmovin-player-ios-sdk-cocoapod).

### Content Metadata handling

If you want to override some content metadata attributes or track additional custom or standard tags you can do so by adding the following:

```swift
var metadata = BitmovinConvivaAnalytics.Metadata()
metadata.applicationName = "Bitmovin iOS Conviva integration example app"
metadata.viewerId = "awesomeViewerId"
metadata.additionalStandardTags = ["c3.cm.contentType": "VOD"]
metadata.custom = ["custom_tag": "value"]
metadata.additionalStandardTags = ["c3.cm.contentType": "VOD"]

metadata.imaSdkVerison = IMAAdsLoader.sdkVersion()

// …
// Initialize ConvivaAnalytics
// …

convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
```

Those values will be cleaned up after the session is closed.

### Server Side Ad Tracking

In order to track server side ads you can use the methods provided in `SsaiApi` which can be accessed via `ConvivaAnalytics.ssai`.
The following example shows basic server side ad tracking:
```swift
convivaAnalytics.ssai.reportAdBreakStarted()

SsaiAdInfo adInfo = SsaiAdInfo(
    title: "My ad title",
    position: .preroll,
    duration: 30
)
convivaAnalytics.ssai.reportAdStarted(adInfo)

...

convivaAnalytics.ssai.reportAdFinished()
convivaAnalytics.ssai.reportAdBreakFinished()
```

In addition to the metadata provided in the `SsaiAdInfo` object at ad start, the following metadata will be auto collected from the main content metadata:
- CIS_SSDK_METADATA_STREAM_URL
- CIS_SSDK_METADATA_ASSET_NAME
- CIS_SSDK_METADATA_IS_LIVE
- CIS_SSDK_METADATA_DEFAULT_RESOURCE
- CIS_SSDK_METADATA_ENCODED_FRAMERATE
- streamType
- integrationVersion
- CIS_SSDK_METADATA_VIEWER_ID
- CIS_SSDK_METADATA_PLAYER_NAME

Metadata in the `SsaiAdInfo` overwrites all auto collected metadata.

### Background handling

If your app stops playback when entering background conviva suggests to end the active session.
Since the integration can't know if you app supports playback in background this can't be done automatically.

To end a session use:

```swift
convivaAnalytics.endSession()
```

Since the `BitmovinPlayer` automatically pauses the video if no background playback is supported the session creation after
the app is in foreground again is handled automatically.

### UI events

If you want to track UI related events such as full-screen state changes add the following after initializing the `BMPBitmovinPlayerView`:

```swift
convivaAnalytics.playerView = bitmovinPlayerView
```

### Consecutive playback

If you want to use the same player instance for multiple playback, just load a new source with `player.load(…)`. The integration will close the active session.

```swift
player.load(…);
```

## Limitations

- Tracking multiple sources within a Playlist, and related use cases, introduced in Player iOS SDK version `v3` are not supported.
