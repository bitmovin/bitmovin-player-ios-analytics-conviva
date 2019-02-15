# Conviva Analytics Integration for the Bitmovin Player iOS SDK

## Installation

BitmovinConvivaAnalytics is available through [CocoaPods](https://cocoapods.org). We depend on cocoapods version >= 1.4.

To install it, simply add the following line to your Podfile:

```ruby
pod 'BitmovinConvivaAnalytics', git: 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva.git', tag: '1.1.0'
```

Then, in your command line run:

```
pod install
```

### Compatibility
This version of the Conviva Analytics Integration depends on `BitmovinPlayer` version `>= 2.17.x`. If you need support for prior `2.17.x` please use [v1.0.0](https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva/tree/1.0.0).

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

### Advanced Setup

You can add more information to your conviva integration via the `ConvivaConfig`:

```swift
let convivaConfig = ConvivaConfiguration()

// Set gatewayUrl ONLY in debug mode for testing!!!
convivaConfig.gatewayUrl = "https://youraccount-test.testonly.conviva.com"

convivaConfig.debugLoggingEnabled = true

// Set an application name
convivaConfig.applicationName = "Some App name"

// Set the viewerId
convivaConfig.viewerId = "awesomeViewerId"

// Add custom tags which will be sent to conviva
convivaConfig.customTags = ["key": "value"]

do {
    convivaAnalytics = try ConvivaAnalytics(player: bitmovinPlayer,
                                            customerKey: "YOUR-CONVIVA-CUSTOMER-KEY",
                                            config: convivaConfig)
} catch {
    NSLog("[ Example ] ConvivaAnalytics initialization failed with error: \(error)")
}
```

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

If you want to use the same player instance for multiple playback call `player.unload()` before loading a new source.

```swift
player.unload();
player.load(…);
```
