//
//  ContentMetadataBuilder.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 05.02.19.
//  Copyright (c) 2019 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

public struct MetadataOverrides {
    // Can only be set before playback started
    public var viewerId: String?
    public var streamType: StreamType?
    public var applicationName: String?
    public var custom: [String: Any]?

    // Dynamic
    public var encodedFramerate: Int?
    public var defaultResource: String?
    public var streamUrl: String?
    public var assetName: String?
    public var duration: Int?

    public init() {}
}

class ContentMetadataBuilder : CustomStringConvertible {
    let logger: Logger
    var contentInfo: [String: Any]

    // internal metadata fields to enable merging / overriding
    var metadataOverrides: MetadataOverrides = MetadataOverrides()
    var metadata: MetadataOverrides = MetadataOverrides()
    var playbackStarted: Bool = false

    var description: String {
        return """
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

    public func setOverrides(_ metadataOverrides: MetadataOverrides) {
        if playbackStarted {
            logger.debugLog(
                message: "[ Conviva Analytics ] Playback has started. Only some metadata attributes will be updated"
            )
        }

        self.metadataOverrides = metadataOverrides
    }

    public func setPlaybackStarted(_ playbackStarted: Bool) {
        self.playbackStarted = playbackStarted
    }

    public func build() -> [String: Any] {
//        if !playbackStarted {
            contentInfo[CIS_SSDK_METADATA_VIEWER_ID] = viewerId
            contentInfo[CIS_SSDK_METADATA_PLAYER_NAME] = applicationName

            if let type = streamType {
                contentInfo[CIS_SSDK_METADATA_IS_LIVE] = type
                == StreamType.CONVIVA_STREAM_LIVE ? NSNumber(value: true) : NSNumber(value: false)
            }

            if let custom = self.custom {
                contentInfo.merge(custom, uniquingKeysWith: {(_, new) in new})
            }
//        }

        if let framerate = encodedFramerate {
            contentInfo[CIS_SSDK_METADATA_ENCODED_FRAMERATE] = framerate
        }

        contentInfo[CIS_SSDK_METADATA_ASSET_NAME] = assetName
        if let duration = self.duration, duration > 0 {
            contentInfo[CIS_SSDK_METADATA_DURATION] = duration
        }
        contentInfo[CIS_SSDK_METADATA_DEFAULT_RESOURCE] = defaultResource

        contentInfo[CIS_SSDK_METADATA_STREAM_URL] = streamUrl

        return contentInfo
    }

    public var assetName: String? {
        get {
            return metadataOverrides.assetName ?? metadata.assetName
        }
        set {
            metadata.assetName = newValue
        }
    }

    public var viewerId: String? {
        get {
            return metadataOverrides.viewerId ?? metadata.viewerId
        }
        set {
            metadata.viewerId = newValue
        }
    }

    public var streamType: StreamType? {
        get {
            return metadataOverrides.streamType ?? metadata.streamType
        }
        set {
            metadata.streamType = newValue
        }
    }

    public var applicationName: String? {
        get {
            return metadataOverrides.applicationName ?? metadata.applicationName
        }
        set {
            metadata.applicationName = newValue
        }
    }

    public var custom: [String: Any]? {
        get {
            return mergeDictionaries(dict1: metadata.custom, dict2: metadataOverrides.custom)
        }
        set {
            metadata.custom = newValue
        }
    }

    public var duration: Int? {
        get {
            return metadataOverrides.duration ?? metadata.duration
        }
        set {
            metadata.duration = newValue
        }
    }

    public var encodedFramerate: Int? {
        get {
            return metadataOverrides.encodedFramerate ?? metadata.encodedFramerate
        }
        set {
            metadata.encodedFramerate = newValue
        }
    }

    public var defaultResource: String? {
        get {
            return metadataOverrides.defaultResource ?? metadata.defaultResource
        }
        set {
            metadata.defaultResource = newValue
        }
    }

    public var streamUrl: String? {
        get {
            return metadataOverrides.streamUrl ?? metadata.streamUrl
        }
        set {
            metadata.streamUrl = newValue
        }
    }

    public func reset() {
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
        dict2?.keys.forEach({ (key) in
            finalDictionary[key] = dict2?[key]
        })

        return finalDictionary
    }
}
