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
        spy(functionName: "setAdInfo", args: adInfo.mapKeyAndValuesToString())
    }

    func setAdPlayerInfo(_ adPlayerInfo: [AnyHashable: Any]) {
        spy(functionName: "setAdPlayerInfo", args: adPlayerInfo.mapKeyAndValuesToString())
    }

    func reportAdFailed(_ errorMessage: String, adInfo: [AnyHashable: Any]?) {
        var args = adInfo?.mapKeyAndValuesToString() ?? [String: String]()
        args["errorMessage"] = errorMessage
        spy(functionName: "reportAdFailed", args: args)
    }

    func reportAdLoaded(_ adInfo: [AnyHashable: Any]?) {
        spy(functionName: "reportAdLoaded", args: adInfo?.mapKeyAndValuesToString())
    }

    func reportAdStarted(_ adInfo: [AnyHashable: Any]?) {
        spy(functionName: "reportAdStarted", args: adInfo?.mapKeyAndValuesToString())
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
        var args = details?.mapKeyAndValuesToString() ?? [String: String]()
        args["eventType"] = eventType
        spy(functionName: "reportAdPlayerEvent", args: args)
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
        var args = info.mapKeyAndValuesToString()
        args["adProxy"] = "\(adProxy ?? "")"
        spy(functionName: "setAdListener", args: args)
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

private extension Dictionary where Key == AnyHashable, Value == Any {
    func mapKeyAndValuesToString() -> [String: String] {
        var args = [String: String]()
        forEach { key, value in
            args[String(describing: key)] = String(describing: value)
        }
        return args
    }
}
