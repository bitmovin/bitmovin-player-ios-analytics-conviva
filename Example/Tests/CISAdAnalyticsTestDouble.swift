//
//  CISAdAnalyticsTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Eyevinn on 27/05/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISAdAnalyticsTestDouble: NSObject, CISAdAnalyticsProtocol {
    func isAirPlaying() -> Bool {
        false
    }

    func setAdInfo(_ adInfo: [AnyHashable: Any]) {
    }

    func setAdPlayerInfo(_ adPlayerInfo: [AnyHashable: Any]) {
    }

    func reportAdFailed(_ errorMessage: String, adInfo: [AnyHashable: Any]?) {
    }

    func reportAdLoaded(_ adInfo: [AnyHashable: Any]?) {
    }

    func reportAdStarted(_ adInfo: [AnyHashable: Any]?) {
    }

    func reportAdEnded() {
    }

    func reportAdError(_ errorMessage: String, severity: ErrorSeverity) {
    }

    func reportAdSkipped() {
    }

    func reportAdPlayerEvent(_ eventType: String, details: [AnyHashable: Any]?) {
    }

    func reportAdMetric(_ key: String, value: Any) {
    }

    func setContentSessionID(_ sessionID: Int32) {
    }

    func setAdListener(_ adProxy: Any?, andInfo info: [AnyHashable: Any]) {
    }

    func report(_ playerState: PlayerState) {
    }

    func getSessionId() -> Int32 {
        return 0
    }

    func getSessionKey() -> Int32 {
        return 1
    }

    func getMetadataInfo() -> [AnyHashable: Any] {
        return [AnyHashable: Any]()
    }

    func reportPlaybackMetric(_ key: String, value: Any?) {
    }

    func setUpdateHandler(_ updateHandler: @escaping UpdateHandler) {
    }

    func isAdAnalytics() -> Bool {
        return true
    }

    func isVideoAnalytics() -> Bool {
        return false
    }

    func cleanup() {
    }
}
