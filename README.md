# Conviva Analytics Integration for the Bitmovin Player iOS SDK

## Installation

BitmovinConvivaAnalytics is available through [CocoaPods](https://cocoapods.org). We depend on cocoapods version >= 1.4.

To install it, simply add the following line to your Podfile:

```ruby
pod 'BitmovinConvivaAnalytics', git: 'https://github.com/bitmovin/bitmovin-player-ios-analytics-conviva.git', tag: '1.0.0-b.1'
```

Then, in your command line run:

```
pod install
```

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


If you want to track UI related events such as full-screen state changes add the following after initializing the `BMPBitmovinPlayerView`:

```swift
convivaAnalytics.playerView = bitmovinPlayerView
```
