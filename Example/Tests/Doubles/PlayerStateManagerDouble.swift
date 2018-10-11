//
//  PlayerStateManagerDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by David Steinacher on 08.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class PlayerStateManagerDouble: NSObject, CISPlayerStateManagerProtocol {
    override func doesNotRecognizeSelector(_ aSelector: Selector!) {
        // be aware that all method calls that are not existing will silently fail
        print("[ PlayerStateManagerDouble ] method_missing: \(NSStringFromSelector(aSelector))")
    }

    func setPlayerState(_ newState: PlayerState) {
        TestHelper.shared.tracker.track(functionName: "setPlayerState", args: ["newState": "\(newState.rawValue)"])
    }

    func setBitrateKbps(_ newBitrateKbps: Int) {
        TestHelper.shared.tracker.track(functionName: "setBitrateKbps",
                                        args: ["newBitrateKbps": "\(newBitrateKbps)"])
    }

    func setSeekStart(_ seekToPosition: Int64) {
        TestHelper.shared.tracker.track(functionName: "setSeekStart",
                                        args: ["seekToPosition": "\(seekToPosition)"])
    }

    func setSeekEnd(_ seekPosition: Int64) {
        TestHelper.shared.tracker.track(functionName: "setSeekEnd",
                                        args: ["seekPosition": "\(seekPosition)"])
    }
}
