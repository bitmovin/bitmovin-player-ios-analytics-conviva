//
//  CISClientDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by David Steinacher on 08.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientDouble: NSObject, CISClientProtocol {
    func createSession(with cisContentMetadata: CISContentMetadata!) -> Int32 {
        TestHelper.shared.tracker.track(functionName: "createSession")
        return Int32(0)
    }

    func createAdSession(_ contentSessionKey: Int32, adMetadata: CISContentMetadata!) -> Int32 {
        return 2
    }

    func cleanUp() {

    }

    func getPlayerStateManager() -> CISPlayerStateManagerProtocol! {
        return PlayerStateManagerDouble()
    }

    func attachPlayer(_ sessionKey: Int32, playerStateManager: CISPlayerStateManagerProtocol!) {

    }

    func reportError(_ sessionKey: Int32, errorMessage: String!, errorSeverity severity: ErrorSeverity) {

    }

    func updateContentMetadata(_ sessionKey: Int32, metadata contentMetadata: CISContentMetadata!) {
        var args: [String: String] = [:]
        // content meta data
        args["applicationName"] = contentMetadata.applicationName
        args["viewerId"] = contentMetadata.viewerId
        for key in contentMetadata.custom.allKeys {
            if let keyString = key as? String {
                if let value = contentMetadata.custom.value(forKey: keyString) as? String {
                    args[keyString] = value
                }
            }
        }
        args["assetName"] = contentMetadata.assetName

        // update session metadata
        args["duration"] = "\(contentMetadata.duration)"
        args["streamType"] = "\(contentMetadata.streamType.rawValue)"
        args["streamUrl"] = contentMetadata.streamUrl

        TestHelper.shared.tracker.track(functionName: "updateContentMetadata", args: args)
    }

    func detachPlayer(_ sessionKey: Int32) {

    }

    func contentPreload(_ sessionKey: Int32) {

    }

    func contentStart(_ sessionKey: Int32) {

    }

    func sendCustomEvent(_ sessionKey: Int32, eventname eventName: String!, withAttributes attributes: [AnyHashable : Any]! = [:]) {
        var args: [String: String] = [:]
        args["sessionKey"] = "\(sessionKey)"
        args["eventName"] = eventName
        // swiftlint:disable:next force_cast
        args.merge(attributes as! [String: String]) { (_, new) in new }
        TestHelper.shared.tracker.track(functionName: "sendCustomEvent", args: args)
    }

    func cleanupSession(_ sessionKey: Int32) {
        TestHelper.shared.tracker.track(functionName: "cleanupSession", args: ["sessionKey": "\(sessionKey)"])
    }

    func releasePlayerStateManager(_ playerStateManager: CISPlayerStateManagerProtocol!) {

    }

    func adStart(_ sessionKey: Int32, adStream: AdStream, adPlayer: AdPlayer, adPosition: AdPosition) {
        TestHelper.shared.tracker.track(functionName: "adStart", args: ["adPosition": "\(adPosition.rawValue)"])
    }

    func adEnd(_ sessionKey: Int32) {
        TestHelper.shared.tracker.track(functionName: "adEnd")
    }

    func getAttachedPlayer(_ sessionKey: Int32) -> CISPlayerStateManagerProtocol! {
        return PlayerStateManagerDouble()
    }

    func isPlayerAttached(_ sessionKey: Int32) -> Bool {
        return true
    }


}
