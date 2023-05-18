//
//  AdMetadataBuilder.swift
//  BitmovinConvivaAnalytics
//
//  Created by Mark Gage on 17.05.23.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

public struct AdMetadataOverrides {
	public var adType: String?
    public var adIdentifier: String?
    public var assetName: String?
    

    public var custom: [String: Any]?
    public var duration: Int?

    public var encodedFramerate: Int?
    public var defaultResource: String?
    
    public var adSystem: String?
    public var adUrl: String?
    public var adPosition: String?

    public init() {}
}

class AdMetadataBuilder : CustomStringConvertible {
    let logger: Logger
    var contentInfo: [String: Any]

    // internal metadata fields to enable merging / overriding
    var metadataOverrides: AdMetadataOverrides = AdMetadataOverrides()
    var metadata: AdMetadataOverrides = AdMetadataOverrides()
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

    public func setOverrides(_ metadataOverrides: AdMetadataOverrides) {
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
        if let adType = self.adType {
        	contentInfo["c3.ad.technology"] = adType
        }
        if let adIdentifier = self.adIdentifier {
        	contentInfo["c3.ad.id"] = adIdentifier
        	contentInfo["c3.ad.firstAdId"] = adIdentifier
        }
        if let assetName = self.assetName {
        	contentInfo[CIS_SSDK_METADATA_ASSET_NAME] = assetName
        }
        if let duration = self.duration {
        	contentInfo[CIS_SSDK_METADATA_DURATION] = duration
        }
        if let encodedFramerate = self.encodedFramerate {
        	contentInfo[CIS_SSDK_METADATA_ENCODED_FRAMERATE] = encodedFramerate
        }
        if let defaultResource = self.defaultResource {
        	contentInfo[CIS_SSDK_METADATA_DEFAULT_RESOURCE] = defaultResource
        }
        if let adSystem = self.adSystem {
        	contentInfo["c3.ad.system"] = adSystem
        	contentInfo["c3.ad.firstAdSystem"] = adSystem
        }
        if let adUrl = self.adUrl {
        	contentInfo[CIS_SSDK_METADATA_STREAM_URL] = adUrl
        }
        if let adPosition = self.adPosition {
        	contentInfo["c3.ad.position"] = assetNaadPositionme
        }
        
        //default set to N/A
        contentInfo["c3.ad.firstCreativeId"] = "N/A"
        contentInfo["c3.ad.creativeId"] = "N/A"
		
        if let custom = self.custom {
			contentInfo.merge(custom, uniquingKeysWith: {(_, new) in new})
		}

        return contentInfo
    }
    
    public var adType: String? {
        get {
            return metadataOverrides.adType ?? metadata.adType
        }
        set {
            metadata.adType = newValue
        }
    }
    public var adIdentifier: String? {
        get {
            return metadataOverrides.adIdentifier ?? metadata.adIdentifier
        }
        set {
            metadata.adIdentifier = newValue
        }
    }

    public var assetName: String? {
        get {
            return metadataOverrides.assetName ?? metadata.assetName
        }
        set {
            metadata.assetName = newValue
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

    public var adSystem: String? {
        get {
            return metadataOverrides.adSystem ?? metadata.adSystem
        }
        set {
            metadata.adSystem = newValue
        }
    }
    
    public var adUrl: String? {
        get {
            return metadataOverrides.adUrl ?? metadata.adUrl
        }
        set {
            metadata.adUrl = newValue
        }
    }
    
    public var adPosition: String? {
        get {
            return metadataOverrides.adPosition ?? metadata.adPosition
        }
        set {
            metadata.adPosition = newValue
        }
    }

    public func reset() {
        metadataOverrides = AdMetadataOverrides()
        metadata = AdMetadataOverrides()
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
