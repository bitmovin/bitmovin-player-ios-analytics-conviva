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
    var contentMetadata: CISContentMetadata

    // internal metadata fields to enable merging / overriding
    var metadataOverrides: MetadataOverrides = MetadataOverrides()
    var metadata: MetadataOverrides = MetadataOverrides()
    var playbackStarted: Bool = false

    init(logger: Logger) {
        self.logger = logger
        contentMetadata = CISContentMetadata()
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

    public func build() -> CISContentMetadata {
        if !playbackStarted {
            // Asset name is only allowed to be set once
            if contentMetadata.assetName == nil {
                contentMetadata.assetName = assetName
            }

            contentMetadata.viewerId = viewerId
            contentMetadata.applicationName = applicationName

            if let type = streamType {
                contentMetadata.streamType = type
            }
            if let duration = self.duration, self.duration ?? 0 > 0 {
                contentMetadata.duration = duration
            }
            if let custom = self.custom {
                contentMetadata.custom = NSMutableDictionary(dictionary: custom)
            }
        } else {
            if let duration = self.duration, duration > 0, contentMetadata.duration == 0 {
                contentMetadata.duration = duration
            }
        }

        if let framerate = encodedFramerate {
            contentMetadata.encodedFramerate = framerate
        }

        contentMetadata.defaultResource = defaultResource
        contentMetadata.streamUrl = streamUrl

        return contentMetadata
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
        contentMetadata = CISContentMetadata()
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
