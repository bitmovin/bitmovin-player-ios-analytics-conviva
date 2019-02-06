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
            if let dur = duration {
                contentMetadata.duration = dur
            }
            if let cus = custom {
                contentMetadata.custom = NSMutableDictionary(dictionary: cus)
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
            return mergeDictionaries(dict1: metadataOverrides.custom, dict2: metadata.custom)
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
