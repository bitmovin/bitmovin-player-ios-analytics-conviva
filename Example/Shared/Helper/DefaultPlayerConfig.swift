//
// Bitmovin Player iOS SDK
// Copyright (C) 2023, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
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
