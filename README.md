# Conviva Analytics Integration for the Bitmovin Player iOS SDK

## Installation

BitmovinConvivaAnalytics is available through [CocoaPods](https://cocoapods.org). We depend on cocoapods version >= 1.4.

To install it, simply add the following line to your Podfile:

```ruby
pod 'BitmovinConvivaAnalytics', git: 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva.git', tag: '1.3.1'
```

Then, in your command line run:

```
pod install
```

### Compatibility

The most recent version of the Conviva Analytics Integration depends on `BitmovinPlayer` version `>= 2.57.1`.
For `BitmovinPlayer` version `>= 2.57.1` please use [v1.3.0](https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva/tree/1.3.0) or later.

If you need support for prior to `2.57.1` please use [v1.2.0](https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva/tree/1.2.0).

## Usage

### Basic Setup

The following example shows how to setup the BitmovinConvivaAnalytics:

```swift
do {
    convivaAnalytics = try ConvivaAnalytics(player: bitmovinPlayer,
                                            customerKey: "YOUR-CONVIVA-CUSTOMER-KEY")
} catch {
    NSLog("[ Example ] ConvivaAnalytics initialization failed with error: \(error)")
}
```

Details about usage of `BitmovinPlayer` can be found [here](https://github.com/bitmovin/bitmovin-player-ios-sdk-cocoapod).

### Content Metadata handling

If you want to override some content metadata attributes you can do so by adding the following:

```swift
var metadata = BitmovinConvivaAnalytics.Metadata()
metadata.applicationName = "Bitmovin iOS Conviva integration example app"
metadata.viewerId = "awesomeViewerId"
metadata.custom = ["contentType": "Episode"]

// …
// Initialize ConvivaAnalytics
// …

convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
```

Those values will be cleaned up after the session is closed.

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
