//
//  BitmovinPlayerDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by David Steinacher on 08.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import BitmovinPlayer

class BitmovinPlayerDouble: BitmovinPlayer {
    var fakeListener: PlayerListener?

    init() {
        super.init(configuration: PlayerConfiguration())
    }

    func fakeEvent() {
        // TODO: generalise
        guard let onPlay = fakeListener?.onPlay else {
            return
        }
        onPlay(PlayEvent(time: 1))
    }

    override func add(listener: PlayerListener) {
        self.fakeListener = listener
    }
}
