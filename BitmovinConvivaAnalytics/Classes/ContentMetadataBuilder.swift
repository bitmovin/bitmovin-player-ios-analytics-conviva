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
    // Can only be set once
    public var assetName: String?

    // Can only be set before playback started
    public var viewerId: String?
    public var streamType: StreamType?
    public var applicationName: String?
    public var custom: [String: Any]?
    public var duration: Int?

    // Dynamic
    public var encodedFramerate: Int?
    public var defaultResource: String?
    public var streamUrl: String?

    public init() {}
}

class ContentMetadataBuilder {
    let logger: Logger
    var contentInfo = [String: Any]()

    // internal metadata fields to enable merging / overriding
    var metadataOverrides: MetadataOverrides = MetadataOverrides()
    var metadata: MetadataOverrides = MetadataOverrides()
    var playbackStarted: Bool = false

    init(logger: Logger) {
        self.logger = logger
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
        if !playbackStarted {
            // NOTE: Asset name is only allowed to be set once
            if contentInfo[CIS_SSDK_METADATA_ASSET_NAME] == nil {
                contentInfo[CIS_SSDK_METADATA_ASSET_NAME] = assetName
            }
            contentInfo[CIS_SSDK_METADATA_VIEWER_ID] = viewerId
            contentInfo[CIS_SSDK_METADATA_PLAYER_NAME] = applicationName

            if let type = streamType {
                contentInfo["c3.cm.contentType"] = type.rawValue
            }
            if let duration = self.duration {
                contentInfo[CIS_SSDK_METADATA_DURATION] = duration
            }

            if let custom = self.custom {
                for (key, value) in custom {
                    contentInfo[key] = value
                }
            }
        }

        if let framerate = encodedFramerate {
            contentInfo[CIS_SSDK_METADATA_ENCODED_FRAMERATE] = framerate
        }

        contentInfo[CIS_SSDK_METADATA_DEFAULT_RESOURCE] = defaultResource
        contentInfo[CIS_SSDK_METADATA_STREAM_URL] = streamUrl

        return contentInfo
    }

    public var assetName: String? {
        set {
            metadata.assetName = newValue
        }
        get {
            return metadataOverrides.assetName ?? metadata.assetName
        }
    }

    public var viewerId: String? {
        set {
            metadata.viewerId = newValue
        }
        get {
            return metadataOverrides.viewerId ?? metadata.viewerId
        }
    }

    public var streamType: StreamType? {
        set {
            metadata.streamType = newValue
        }
        get {
            return metadataOverrides.streamType ?? metadata.streamType
        }
    }

    public var applicationName: String? {
        set {
            metadata.applicationName = newValue
        }
        get {
            return metadataOverrides.applicationName ?? metadata.applicationName
        }
    }

    public var custom: [String: Any]? {
        set {
            metadata.custom = newValue
        }
        get {
            return mergeDictionaries(dict1: metadata.custom, dict2: metadataOverrides.custom)
        }
    }

    public var duration: Int? {
        set {
            metadata.duration = newValue
        }
        get {
            return metadataOverrides.duration ?? metadata.duration
        }
    }

    public var encodedFramerate: Int? {
        set {
            metadata.encodedFramerate = newValue
        }
        get {
            return metadataOverrides.encodedFramerate ?? metadata.encodedFramerate
        }
    }

    public var defaultResource: String? {
        set {
            metadata.defaultResource = newValue
        }
        get {
            return metadataOverrides.defaultResource ?? metadata.defaultResource
        }
    }

    public var streamUrl: String? {
        set {
            metadata.streamUrl = newValue
        }
        get {
            return metadataOverrides.streamUrl ?? metadata.streamUrl
        }
    }

    public func reset() {
        playbackStarted = false
        contentInfo = [:]
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
