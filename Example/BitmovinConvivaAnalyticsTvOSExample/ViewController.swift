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

    var player: BitmovinPlayer?
    var playerView: BMPBitmovinPlayerView?
    var fullScreen: Bool = false

    var convivaAnalytics: ConvivaAnalytics?

    let convivaCustomerKey: String = "YOUR-CONVIVA-CUSTOMER-KEY"
    var convivaGatewayString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBitmovinPlayer()
    }

    func setupBitmovinPlayer() {
        // Setup Player
        player = BitmovinPlayer()

        let convivaConfig = ConvivaConfiguration()

        // Set gatewayUrl ONLY in debug mode !!!
        if let gatewayString = convivaGatewayString,
            let gatewayUrl = URL(string: gatewayString) {
            convivaConfig.gatewayUrl = gatewayUrl
        }
        convivaConfig.debugLoggingEnabled = true

        convivaConfig.applicationName = "Bitmovin tvOS Conviva integration example app"
        convivaConfig.viewerId = "awesomeViewerId"
        convivaConfig.customTags = ["contentType": "Episode"]

        do {
            convivaAnalytics = try ConvivaAnalytics(player: player!,
                                                    customerKey: convivaCustomerKey,
                                                    config: convivaConfig)
        } catch {
            NSLog("[ Example ] ConvivaAnalytics initialization failed with error: \(error)")
        }

        player?.setup(configuration: playerConfiguration)

        // Setup UI
        playerView = BMPBitmovinPlayerView(player: player!, frame: .zero)
        playerView?.frame = view.bounds

        if let convivaAnalytics = convivaAnalytics {
            convivaAnalytics.playerView = playerView
        }

        playerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(playerView!)
        view.bringSubviewToFront(playerView!)
    }

    var playerConfiguration: PlayerConfiguration {
        let playerConfiguration = PlayerConfiguration()
        playerConfiguration.sourceItem = sourceItem

        return playerConfiguration
    }

    var sourceItem: SourceItem? {
        let sourceString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        guard let url = URL(string: sourceString),
            let sourceItem = SourceItem(url: url) else {
                return nil
        }
        sourceItem.posterSource = URL(string: "https://bitmovin-a.akamaihd.net/content/poster/hd/RedBull.jpg")
        sourceItem.itemTitle = "Art of Motion"
        return sourceItem
    }
}
