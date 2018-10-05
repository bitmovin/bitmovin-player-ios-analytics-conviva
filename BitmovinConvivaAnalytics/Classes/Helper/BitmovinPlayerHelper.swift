//
//  BitmovinPlayerHelper.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 05.10.18.
//

import Foundation
import BitmovinPlayer

final class BitmovinPlayerHelper: NSObject {
    let player: BitmovinPlayer

    init(player: BitmovinPlayer) {
        self.player = player
    }

    var streamType: String {
        switch player.streamType {
        case .DASH:
            return "DASH"
        case .HLS:
            return "HLS"
        case .progressive:
            return "progressive"
        default:
            return "none"
        }
    }

    var version: String? {
        return Bundle(for: BitmovinPlayer.self).infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
