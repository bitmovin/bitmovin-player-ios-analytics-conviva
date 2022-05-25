//
//  ViewController.swift
//  BitmovinConvivaAnalyticsTvOSExample
//
//  Created by Bitmovin on 10.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import UIKit
import BitmovinPlayer
import BitmovinConvivaAnalytics

class ViewController: UIViewController {

    var player: Player?
    var playerView: PlayerView?
    var fullScreen: Bool = false

    var convivaAnalytics: ConvivaAnalytics?

    let convivaCustomerKey: String = "YOUR-CONVIVA-CUSTOMER-KEY"
    var convivaGatewayString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBitmovinPlayer()
    }
    
    deinit {
        convivaAnalytics?.release()
        NSLog("[ Example ] ConvivaAnalytics released")
    }
    
    func setupBitmovinPlayer() {
        // Setup Player
        player = PlayerFactory.create(playerConfig: playerConfig)

        let convivaConfig = ConvivaConfiguration()

        // Set gatewayUrl ONLY in debug mode !!!
        if let gatewayString = convivaGatewayString,
            let gatewayUrl = URL(string: gatewayString) {
            convivaConfig.gatewayUrl = gatewayUrl
        }
        convivaConfig.debugLoggingEnabled = true

        var metadata = MetadataOverrides()
        metadata.applicationName = "Bitmovin tvOS Conviva integration example app"
        metadata.viewerId = "awesomeViewerId"
        metadata.custom = ["contentType": "Episode"]

        do {
            convivaAnalytics = try ConvivaAnalytics(player: player!,
                                                    customerKey: convivaCustomerKey,
                                                    config: convivaConfig)
            convivaAnalytics?.updateContentMetadata(metadataOverrides: metadata)
        } catch {
            NSLog("[ Example ] ConvivaAnalytics initialization failed with error: \(error)")
        }

        // Setup UI
        playerView = PlayerView(player: player!, frame: .zero)
        playerView?.frame = view.bounds

        if let convivaAnalytics = convivaAnalytics {
            convivaAnalytics.playerView = playerView
        }

        playerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(playerView!)
        view.bringSubviewToFront(playerView!)

        player?.load(source: SourceFactory.create(from: vodSourceConfig))
    }

    var playerConfig: PlayerConfig {
        let playerConfig = PlayerConfig()
        let playbackConfig = PlaybackConfig()
        playbackConfig.isAutoplayEnabled = true
        playbackConfig.isMuted = true
        playerConfig.playbackConfig = playbackConfig
        return playerConfig
    }

    var vodSourceConfig: SourceConfig {
        let sourceString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        let sourceConfig = SourceConfig(url: URL(string: sourceString)!, type: .hls)
        sourceConfig.title = "Art of Motion"
        return sourceConfig
    }
}
