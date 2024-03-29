//
//  CISVideoAnalyticsTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Eyevinn on 27/05/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISVideoAnalyticsTestDouble: NSObject, CISVideoAnalyticsProtocol, TestDoubleDataSource {
    func setContentInfo(_ contentInfo: [AnyHashable: Any]) {
        spy(functionName: "setContentInfo", args: [
            "applicationName": "\(contentInfo[CIS_SSDK_METADATA_PLAYER_NAME] ?? "")",
            "assetName": "\(contentInfo[CIS_SSDK_METADATA_ASSET_NAME] ?? "")",
            "duration": "\(contentInfo[CIS_SSDK_METADATA_DURATION] ?? "")",
            "isLive": "\(contentInfo[CIS_SSDK_METADATA_IS_LIVE] ?? "")",
            "streamUrl": "\(contentInfo[CIS_SSDK_METADATA_STREAM_URL] ?? "")",
            "viewerId": "\(contentInfo[CIS_SSDK_METADATA_VIEWER_ID] ?? "")"
        ])
    }

    func setPlayerInfo(_ playerInfo: [AnyHashable: Any]) {
        spy(functionName: "setPlayerInfo", args: ["playerInfo": "\(String(describing: playerInfo))"])
    }

    func reportPlaybackRequested(_ contentInfo: [AnyHashable: Any]?) {
        spy(functionName: "reportPlaybackRequested", args: [
            "applicationName": "\(contentInfo?[CIS_SSDK_METADATA_PLAYER_NAME] ?? "")",
            "assetName": "\(contentInfo?[CIS_SSDK_METADATA_ASSET_NAME] ?? "")",
            "duration": "\(contentInfo?[CIS_SSDK_METADATA_DURATION] ?? "")",
            "isLive": "\(contentInfo?[CIS_SSDK_METADATA_IS_LIVE] ?? "")",
            "streamUrl": "\(contentInfo?[CIS_SSDK_METADATA_STREAM_URL] ?? "")",
            "viewerId": "\(contentInfo?[CIS_SSDK_METADATA_VIEWER_ID] ?? "")",
            "defaultResource": "\(contentInfo?[CIS_SSDK_METADATA_DEFAULT_RESOURCE] ?? "")",
            "contentType": "\(contentInfo?["contentType"] ?? "")",
            "MyCustom": "\(contentInfo?["MyCustom"] ?? "")",
            "streamType": "\(contentInfo?["streamType"] ?? "")"
        ])
    }

    func reportPlaybackEnded() {
        spy(functionName: "reportPlaybackEnded")
    }

    func reportPlaybackFailed(_ errorMessage: String, contentInfo: [AnyHashable: Any]?) {
    }

    func reportPlaybackError(_ errorMessage: String, errorSeverity severity: ErrorSeverity) {
        spy(functionName: "reportPlaybackError", args: [
            "errorMessage": errorMessage,
            "errorSeverity": "\(severity.rawValue)"
        ])

    }

    func reportPlaybackEvent(_ eventName: String, withAttributes attributes: [AnyHashable: Any]? = nil) {
    }

    func reportAdBreakStarted(_ adPlayer: AdPlayer, adType: AdTechnology, adBreakInfo: [AnyHashable: Any]) {
        spy(functionName: "reportAdBreakStarted", args: [
            "adPlayer": "\(String(describing: adPlayer))",
            "adType": "\(String(describing: adType))",
            "adBreakInfo": "\(adBreakInfo["c3.ad.position"] ?? "")"
        ])
    }

    func reportAdBreakEnded() {
        spy(functionName: "reportAdBreakEnded")
    }

    func setPlayer(_ player: Any?) {
    }

    func reportPlaybackMetric(_ key: String, value: Any?) {
        spy(functionName: "reportPlaybackMetric", args: [
            key: "\(value ?? "")"
        ])
    }

    func setAdAnalytics(_ adAnalytics: CISAdAnalytics) {
    }

    func report(_ playerState: PlayerState) {
    }

    func getSessionId() -> Int32 {
        return 1
    }

    func getSessionKey() -> Int32 {
        return 1
    }

    func getMetadataInfo() -> [AnyHashable: Any] {
        return [AnyHashable: Any]()
    }

    func setUpdateHandler(_ updateHandler: @escaping UpdateHandler) {
    }

    func isAdAnalytics() -> Bool {
        return false
    }

    func isVideoAnalytics() -> Bool {
        return true
    }

    func cleanup() {
    }
}
