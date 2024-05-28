//
//  DefaultPlayerConfig.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 28.05.24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import BitmovinPlayer

func buildDefaultPlayerConfig(enableAds: Bool) -> PlayerConfig {
    let playerConfig = PlayerConfig()

    if enableAds {
        playerConfig.advertisingConfig = defaultAdConfig
    }

    let playbackConfig = PlaybackConfig()
    playbackConfig.isAutoplayEnabled = true
    playbackConfig.isMuted = true
    playerConfig.playbackConfig = playbackConfig
    return playerConfig
}
