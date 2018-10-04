//
//  ConvivaAnalytics.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 02.10.18.
//

import Foundation
import BitmovinPlayer
import ConvivaSDK

class ConvivaAnalytics {
    let player: BitmovinPlayer
    let customerKey: String
    let config: ConvivaConfiguration

    init(player: BitmovinPlayer, customerKey: String, config: ConvivaConfiguration) {
        self.player = player
        self.customerKey = customerKey
        self.config = config

    }
}

class ConvivaConfiguration {
    // TODO
}
