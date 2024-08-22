//
//  ContentMetadataBuilder.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 05.02.19.
//  Copyright (c) 2019 Bitmovin. All rights reserved.
//

import ConvivaSDK
import Foundation

public struct MetadataOverrides {
    // Can only be set once
    public var assetName: String?
    @available(*, deprecated, message: "Use imaSdkVersion instead", renamed: "imaSdkVersion")
    public var imaSdkVerison: String? {
        get {
            imaSdkVersion
        }
        set {
            imaSdkVersion = newValue
        }
    }
    public var imaSdkVersion: String?

    // Can only be set before playback started
    public var viewerId: String?
    public var streamType: StreamType?
    public var applicationName: String?
    public var custom: [String: Any]?
    public var duration: Int?
    /// Standard Conviva tags that aren't covered by the other fields in this class.
    /// List of tags can be found here:
    /// [Pre-defined Video and Content Metadata](https://pulse.conviva.com/learning-center/content/sensor_developer_center/sensor_integration/ios/ios_stream_sensor.html#Predefined_video_meta)
    public var additionalStandardTags: [String: Any]?

    // Dynamic
    public var encodedFramerate: Int?
    public var defaultResource: String?
    public var streamUrl: String?

    public init() {}
}

class ContentMetadataBuilder: CustomStringConvertible {
    let logger: Logger
    var contentInfo: [String: Any]

    // internal metadata fields to enable merging / overriding
    var metadataOverrides = MetadataOverrides()
    var metadata = MetadataOverrides()
    var playbackStarted = false

    var description: String {
        """
        <\(type(of: self)): \
        metadata = \(metadata) \
        metadataOverrieds = \(metadataOverrides) \
        playbackStarted = \(playbackStarted)>
        """
    }

    init(logger: Logger) {
        self.logger = logger
        contentInfo = [String: Any]()
    }

    func setOverrides(_ metadataOverrides: MetadataOverrides) {
        if playbackStarted {
            logger.debugLog(
                message: "Playback has started. Only some metadata attributes will be updated"
            )
        }

        self.metadataOverrides = metadataOverrides
    }

    func setPlaybackStarted(_ playbackStarted: Bool) {
        self.playbackStarted = playbackStarted

        guard playbackStarted else { return }

        let buildMissingMetadataWarningMessage: (_ metadataName: String) -> String = { name in
            """
            [ Warning ] `\(name)` not set but playback started. \
            Please provide `\(name)` through \
            `ConvivaAnalytics.updateContentMetadata(metadataOverrides:)` before playback starts
            """
        }

        if viewerId == nil {
            logger.debugLog(
                message: buildMissingMetadataWarningMessage("viewerId")
            )
        }

        if applicationName == nil {
            logger.debugLog(
                message: buildMissingMetadataWarningMessage("applicationName")
            )
        }
    }

    func build() -> [String: Any] {
        if !playbackStarted {
            // Asset name is only allowed to be set once
            if contentInfo[CIS_SSDK_METADATA_ASSET_NAME] == nil {
                contentInfo[CIS_SSDK_METADATA_ASSET_NAME] = assetName
            }

            contentInfo[CIS_SSDK_METADATA_VIEWER_ID] = viewerId
            contentInfo[CIS_SSDK_METADATA_PLAYER_NAME] = applicationName

            if let type = streamType {
                contentInfo[CIS_SSDK_METADATA_IS_LIVE] = type
                == StreamType.CONVIVA_STREAM_LIVE ? NSNumber(value: true) : NSNumber(value: false)
            }
            if let duration, duration != 0 {
                contentInfo[CIS_SSDK_METADATA_DURATION] = duration
            }
            if let custom = self.custom {
                contentInfo.merge(custom) { $1 }
            }
            if let additionalStandardTags = self.additionalStandardTags {
                contentInfo.merge(additionalStandardTags) { $1 }
            }
        } else {
            let oldDuration = contentInfo[CIS_SSDK_METADATA_DURATION] as? Int
            if oldDuration == 0,
               let duration,
               duration != 0 {
                contentInfo[CIS_SSDK_METADATA_DURATION] = duration
            }
        }

        if let framerate = encodedFramerate {
            contentInfo[CIS_SSDK_METADATA_ENCODED_FRAMERATE] = framerate
        }

        contentInfo[CIS_SSDK_METADATA_DEFAULT_RESOURCE] = defaultResource

        contentInfo[CIS_SSDK_METADATA_STREAM_URL] = streamUrl

        return contentInfo
    }

    var assetName: String? {
        get {
            metadataOverrides.assetName ?? metadata.assetName
        }
        set {
            metadata.assetName = newValue
        }
    }

    var viewerId: String? {
        get {
            metadataOverrides.viewerId ?? metadata.viewerId
        }
        set {
            metadata.viewerId = newValue
        }
    }

    var streamType: StreamType? {
        get {
            metadataOverrides.streamType ?? metadata.streamType
        }
        set {
            metadata.streamType = newValue
        }
    }

    var applicationName: String? {
        get {
            metadataOverrides.applicationName ?? metadata.applicationName
        }
        set {
            metadata.applicationName = newValue
        }
    }

    var custom: [String: Any]? {
        get {
            mergeDictionaries(dict1: metadata.custom, dict2: metadataOverrides.custom)
        }
        set {
            metadata.custom = newValue
        }
    }

    var duration: Int? {
        get {
            metadataOverrides.duration ?? metadata.duration
        }
        set {
            metadata.duration = newValue
        }
    }

    var additionalStandardTags: [String: Any]? {
        get {
            mergeDictionaries(dict1: metadata.additionalStandardTags, dict2: metadataOverrides.additionalStandardTags)
        }
        set {
            metadata.additionalStandardTags = newValue
        }
    }

    var encodedFramerate: Int? {
        get {
            metadataOverrides.encodedFramerate ?? metadata.encodedFramerate
        }
        set {
            metadata.encodedFramerate = newValue
        }
    }

    var defaultResource: String? {
        get {
            metadataOverrides.defaultResource ?? metadata.defaultResource
        }
        set {
            metadata.defaultResource = newValue
        }
    }

    var streamUrl: String? {
        get {
            metadataOverrides.streamUrl ?? metadata.streamUrl
        }
        set {
            metadata.streamUrl = newValue
        }
    }

    func reset() {
        metadataOverrides = MetadataOverrides()
        metadata = MetadataOverrides()
        playbackStarted = false
        contentInfo = [String: Any]()
    }

    // Values from dict2 will override value from dict1
    private func mergeDictionaries(dict1: [String: Any]?, dict2: [String: Any]?) -> [String: Any]? {
        if dict1 == nil && dict2 == nil {
            return nil
        }

        var finalDictionary: [String: Any] = dict1 ?? [:]
        dict2?.keys.forEach { key in
            finalDictionary[key] = dict2?[key]
        }

        return finalDictionary
    }
}
