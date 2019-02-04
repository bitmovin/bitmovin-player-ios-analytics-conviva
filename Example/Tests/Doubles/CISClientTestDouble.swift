//
//  CISClientTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientTestDouble: NSObject, CISClientProtocol, TestDoubleDataSource {
    func createSession(with cisContentMetadata: CISContentMetadata!) -> Int32 {
        spy(functionName: "createSession", args: metaDataToArgs(contentMetadata: cisContentMetadata))
        return Int32(0)
    }

    func createAdSession(_ contentSessionKey: Int32, adMetadata: CISContentMetadata!) -> Int32 {
        return 2
    }

    func getPlayerStateManager() -> CISPlayerStateManagerProtocol! {
        return PlayerStateManagerTestDouble()
    }

    func updateContentMetadata(_ sessionKey: Int32, metadata contentMetadata: CISContentMetadata!) {
        spy(functionName: "updateContentMetadata", args: metaDataToArgs(contentMetadata: contentMetadata))
    }

    func sendCustomEvent(_ sessionKey: Int32,
                         eventname eventName: String!,
                         withAttributes attributes: [AnyHashable: Any]! = [:]) {
        var args: [String: String] = [:]
        args["sessionKey"] = "\(sessionKey)"
        args["eventName"] = eventName
        // swiftlint:disable:next force_cast
        args.merge(attributes as! [String: String]) { (_, new) in new }

        spy(functionName: "sendCustomEvent", args: args)
    }

    func cleanupSession(_ sessionKey: Int32) {
        spy(functionName: "cleanupSession", args: ["sessionKey": "\(sessionKey)"])
    }

    func adStart(_ sessionKey: Int32, adStream: AdStream, adPlayer: AdPlayer, adPosition: AdPosition) {
        spy(functionName: "adStart", args: ["adPosition": "\(adPosition.rawValue)"])
    }

    func adEnd(_ sessionKey: Int32) {
        spy(functionName: "adEnd")
    }

    func getAttachedPlayer(_ sessionKey: Int32) -> CISPlayerStateManagerProtocol! {
        return PlayerStateManagerTestDouble()
    }

    func isPlayerAttached(_ sessionKey: Int32) -> Bool {
        return true
    }

    func releasePlayerStateManager(_ playerStateManager: CISPlayerStateManagerProtocol!) {
        spy(functionName: "releasePlayerStateManager")
    }

    func reportError(_ sessionKey: Int32, errorMessage: String!, errorSeverity severity: ErrorSeverity) {
        spy(functionName: "reportError", args: ["errorMessage": errorMessage,
                                                "severity": "\(severity.rawValue)"])
    }

    func detachPlayer(_ sessionKey: Int32) {}
    func contentPreload(_ sessionKey: Int32) {}
    func contentStart(_ sessionKey: Int32) {}
    func cleanUp() {}
    func attachPlayer(_ sessionKey: Int32, playerStateManager: CISPlayerStateManagerProtocol!) {}

    // MARK: - private helper
    private func metaDataToArgs(contentMetadata: CISContentMetadata) -> [String: String] {
        var args: [String: String] = [:]
        // content metadata
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

        return args
    }
}
