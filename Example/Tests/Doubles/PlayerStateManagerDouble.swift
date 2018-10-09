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
    func setPlayerType(_ plType: String!) {

    }

    func setPlayerVersion(_ plVer: String!) {

    }

    func setPlayerState(_ newState: PlayerState) {
        TestHelper.tracker.track(functionName: #function, args: ["newState": "\(newState)"])
    }
}
