//
//  CISAdAnalyticsTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Eyevinn on 27/05/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import ConvivaSDK
import Foundation

class CISAdAnalyticsTestDouble: NSObject, CISAdAnalyticsProtocol, TestDoubleDataSource {
    func isAirPlaying() -> Bool {
        false
    }

    func setAdInfo(_ adInfo: [AnyHashable: Any]) {
        spy(
            functionName: "setAdInfo",
            args: [
                "adInfo": adInfo.toStringWithStableOrder()
            ]
        )
    }

    func setAdPlayerInfo(_ adPlayerInfo: [AnyHashable: Any]) {
        spy(
            functionName: "setAdPlayerInfo",
            args: [
                "adPlayerInfo": adPlayerInfo.toStringWithStableOrder()
            ]
        )
    }

    func reportAdFailed(_ errorMessage: String, adInfo: [AnyHashable: Any]?) {
        spy(
            functionName: "reportAdFailed",
            args: [
                "errorMessage": errorMessage,
                "adInfo": adInfo?.toStringWithStableOrder() ?? ""
            ]
        )
    }

    func reportAdLoaded(_ adInfo: [AnyHashable: Any]?) {
        spy(functionName: "reportAdLoaded", args: ["adInfo": adInfo?.toStringWithStableOrder() ?? ""])
    }

    func reportAdStarted(_ adInfo: [AnyHashable: Any]?) {
        spy(functionName: "reportAdStarted", args: ["adInfo": adInfo?.toStringWithStableOrder() ?? ""])
    }

    func reportAdEnded() {
        spy(functionName: "reportAdEnded")
    }

    func reportAdError(_ errorMessage: String, severity: ErrorSeverity) {
        spy(functionName: "reportAdError", args: [
            "errorMessage": errorMessage,
            "severity": "\(severity)"
        ])
    }

    func reportAdSkipped() {
        spy(functionName: "reportAdSkipped")
    }

    func reportAdPlayerEvent(_ eventType: String, details: [AnyHashable: Any]?) {
        spy(
            functionName: "reportAdPlayerEvent",
            args: [
                "eventType": eventType,
                "details": details?.toStringWithStableOrder() ?? ""
            ]
        )
    }

    func reportAdMetric(_ key: String, value: Any) {
        spy(functionName: "reportAdMetric", args: [
            "key": key,
            "value": "\(value)"
        ])
    }

    func setContentSessionID(_ sessionID: Int32) {
        spy(functionName: "setContentSessionID", args: [
            "sessionID": "\(sessionID)"
        ])
    }

    func setAdListener(_ adProxy: Any?, andInfo info: [AnyHashable: Any]) {
        spy(
            functionName: "setAdListener",
            args: [
                "adProxy": "\(adProxy ?? "")",
                "info": info.toStringWithStableOrder()
            ]
        )
    }

    func report(_ playerState: PlayerState) {
        spy(functionName: "report", args: [
            "playerState": "\(playerState)"
        ])
    }

    func getSessionId() -> Int32 {
        0
    }

    func getSessionKey() -> Int32 {
        1
    }

    func getMetadataInfo() -> [AnyHashable: Any] {
        [:]
    }

    func reportPlaybackMetric(_ key: String, value: Any?) {
        spy(functionName: "reportPlaybackMetric", args: [
               "key": key,
               "value": "\(value ?? "")"
           ])
    }

    func setUpdateHandler(_ updateHandler: @escaping UpdateHandler) {
    }

    func isAdAnalytics() -> Bool {
        true
    }

    func isVideoAnalytics() -> Bool {
        false
    }

    func cleanup() {
        spy(functionName: "cleanup")
    }
}
