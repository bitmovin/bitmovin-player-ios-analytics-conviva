//
//  BitmovinPlayerHelper.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 05.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import BitmovinPlayer

final class BitmovinPlayerHelper: NSObject {
    let player: Player

    init(player: Player) {
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
        return Bundle(for: PlayerFactory.self).infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
