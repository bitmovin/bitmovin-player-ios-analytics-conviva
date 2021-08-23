//
//  BitmovinPlayerHelper.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 05.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import BitmovinPlayer

public typealias BitmovinPlayer = Player

final class BitmovinPlayerHelper: NSObject {
    let player: BitmovinPlayer

    init(player: BitmovinPlayer) {
        self.player = player
    }

    var streamType: String {
        switch player.source?.sourceConfig.type {
        case .dash:
            return "DASH"
        case .hls:
            return "HLS"
        case .progressive:
            return "progressive"
        default:
            return "none"
        }
    }

    var version: String? {
        let bundle = Bundle(for: BitmovinPlayer.self)
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        //return Bundle(for: Player.self).infoDictionary?["CFBundleShortVersionString"] as? String
        return version
    }
}
