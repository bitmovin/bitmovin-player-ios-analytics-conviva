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
        return 1
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

    }

    func detachPlayer(_ sessionKey: Int32) {

    }

    func contentPreload(_ sessionKey: Int32) {

    }

    func contentStart(_ sessionKey: Int32) {

    }

    func sendCustomEvent(_ sessionKey: Int32, eventname eventName: String!, withAttributes attributes: [AnyHashable : Any]! = [:]) {

    }

    func cleanupSession(_ sessionKey: Int32) {

    }

    func releasePlayerStateManager(_ playerStateManager: CISPlayerStateManagerProtocol!) {

    }

    func adStart(_ sessionKey: Int32, adStream: AdStream, adPlayer: AdPlayer, adPosition: AdPosition) {

    }

    func adEnd(_ sessionKey: Int32) {

    }

    func getAttachedPlayer(_ sessionKey: Int32) -> CISPlayerStateManagerProtocol! {
        return PlayerStateManagerDouble()
    }

    func isPlayerAttached(_ sessionKey: Int32) -> Bool {
        return true
    }


}
