//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

public struct SsaiAdInfo {
    /// The title of the ad.
    public var title: String?

    /// Duration of the ad, in seconds.
    public var duration: Double?

    /// The ad ID extracted from the ad server that contains the ad creative.
    public var id: String?

    /// The name of the ad system (i.e., the ad server).
    public var adSystem: String?

    /// The position of the ad.
    public var position: SsaiAdPosition?

    /// Indicates whether this ad is a slate or not. Set to `true` for slate and `false` for a regular ad.
    public var isSlate: Bool

    /// The name of the ad stitcher.
    public var adStitcher: String?

    /// Additional ad metadata.
    /// This is a map of key-value pairs that can be used to pass additional metadata about the ad.
    /// A list of ad metadata can be found here: [Conviva documentation](https://pulse.conviva.com/learning-center/content/sensor_developer_center/sensor_integration/ios/ios_stream_sensor.html#IntegrateAdManagers)
    ///
    /// Metadata provided here will supersede any data provided in the ad break info.
    public var additionalMetadata: [String: Any]?

    public init(
        title: String? = nil,
        duration: Double? = nil,
        id: String? = nil,
        adSystem: String? = nil,
        position: SsaiAdPosition? = nil,
        isSlate: Bool = false,
        adStitcher: String? = nil,
        additionalMetadata: [String: Any]? = nil
    ) {
        self.title = title
        self.duration = duration
        self.id = id
        self.adSystem = adSystem
        self.position = position
        self.isSlate = isSlate
        self.adStitcher = adStitcher
        self.additionalMetadata = additionalMetadata
    }
}
