//
//  CISAnalyticsTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Eyevinn on 27/05/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import ConvivaSDK
import Foundation

class CISAnalyticsTestDouble: NSObject, CISAnalyticsProtocol, TestDoubleDataSource {
    func getGlobalSessionId() -> Int32 {
        0
    }

    func getipv4SessionId() -> Int32 {
        0
    }

    func getipv6SessionId() -> Int32 {
        0
    }

    func getClientId() -> String {
        ""
    }

    func createVideoAnalytics() -> CISVideoAnalytics {
        CISVideoAnalyticsTestDouble()
    }

    func createVideoAnalytics(_ options: [AnyHashable: Any]) -> CISVideoAnalytics {
        CISVideoAnalyticsTestDouble()
    }

    func createAdAnalytics() -> CISAdAnalytics {
        CISAdAnalyticsTestDouble()
    }

    func createAdAnalytics(withVideoAnalytics videoAnalytics: CISVideoAnalytics) -> CISAdAnalytics {
        CISAdAnalyticsTestDouble()
    }

    func reportAppEvent(_ event: String, details: [AnyHashable: Any]) {
        var args: [String: String] = [:]
        args["eventName"] = event
        // swiftlint:disable:next force_cast
        args.merge(details as! [String: String]) { _, new in new }

        spy(functionName: "reportAppEvent", args: args)
    }

    func reportAppBackgrounded() {
    }

    func reportAppForegrounded() {
    }

    func setUserPrefsForDataCollection(_ userPrefs: [AnyHashable: Any]) {
    }

    func setUserPrefsForDataDeletion(_ userPrefs: [AnyHashable: Any]) {
    }

    func cleanup() {
        spy(functionName: "cleanup")
    }
}
