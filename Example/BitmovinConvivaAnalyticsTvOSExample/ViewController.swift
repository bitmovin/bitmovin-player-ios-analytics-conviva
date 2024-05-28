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

// Set this flag to false if you want to test without Ads
private let enableAds = true

class ViewController: UIViewController {

    private var player: Player!
    private var playerView: PlayerView!

    private var convivaAnalytics: ConvivaAnalytics?
    private let convivaCustomerKey: String = "YOUR-CONVIVA-CUSTOMER-KEY"
    private var convivaGatewayString: String?

    var vodSourceConfig: SourceConfig {
        let sourceString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        let sourceConfig = SourceConfig(url: URL(string: sourceString)!, type: .hls)
        sourceConfig.title = "Art of Motion"
        return sourceConfig
    }

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
        let playerConfig = buildDefaultPlayerConfig(enableAds: enableAds)
        player = PlayerFactory.createPlayer(playerConfig: playerConfig)

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
            convivaAnalytics = try ConvivaAnalytics(
                player: player,
                customerKey: convivaCustomerKey,
                config: convivaConfig
            )
            convivaAnalytics?.updateContentMetadata(metadataOverrides: metadata)
        } catch {
            NSLog("[ Example ] ConvivaAnalytics initialization failed with error: \(error)")
        }

        // Setup UI
        playerView = PlayerView(player: player!, frame: .zero)
        playerView.frame = view.bounds

        if let convivaAnalytics = convivaAnalytics {
            convivaAnalytics.playerView = playerView
        }

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(playerView!)
        view.bringSubviewToFront(playerView!)

        player?.load(source: SourceFactory.createSource(from: vodSourceConfig))
    }
}
