//
//  ViewController.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 10/02/2018.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import BitmovinConvivaAnalytics
import BitmovinPlayer
import UIKit

class ViewController: UIViewController {
    // swiftlint:disable implicitly_unwrapped_optional
    @IBOutlet weak var playerUIView: UIView!
    @IBOutlet weak var adsSwitch: UISwitch!
    @IBOutlet weak var streamUrlTextField: UITextField!

    private var player: Player!
    private var playerView: PlayerView!
    // swiftlint:enable implicitly_unwrapped_optional

    private var convivaAnalytics: ConvivaAnalytics?
    private let convivaCustomerKey: String = "YOUR-CONVIVA-CUSTOMER-KEY"
    private var convivaGatewayString: String?

    var vodSourceConfig: SourceConfig {
        // swiftlint:disable:next force_unwrapping
        var sourceUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8")!
        if let streamString = streamUrlTextField.text, let url = URL(string: streamString) {
            sourceUrl = url
        }

        let sourceConfig = SourceConfig(url: sourceUrl, type: .hls)
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
        let playerConfig = buildDefaultPlayerConfig(enableAds: adsSwitch.isOn)
        player = PlayerFactory.createPlayer(playerConfig: playerConfig)

        let convivaConfig = ConvivaConfiguration()

        // Set gatewayUrl ONLY in debug mode !!!
        if let gatewayString = convivaGatewayString,
            let gatewayUrl = URL(string: gatewayString) {
            convivaConfig.gatewayUrl = gatewayUrl
        }
        convivaConfig.debugLoggingEnabled = true

        var metadata = MetadataOverrides()
        metadata.applicationName = "Bitmovin iOS Conviva integration example app"
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
        playerView = PlayerView(player: player, frame: playerUIView.bounds)

        if let convivaAnalytics = convivaAnalytics {
            convivaAnalytics.playerView = playerView
        }

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerUIView.addSubview(playerView)

        player.load(source: SourceFactory.createSource(from: vodSourceConfig))
    }

    // MARK: - actions
    @IBAction func setupPlayer(_ sender: Any) {
        setupBitmovinPlayer()
    }

    @IBAction func destroyPlayer(_ sender: Any) {
        convivaAnalytics?.release()
        player?.unload()
    }

    @IBAction func pauseTracking(_ sender: Any) {
        NSLog("[ Example ] Will pause tracking")
        convivaAnalytics?.pauseTracking(isBumper: false)
    }

    @IBAction func resumeTracking(_ sender: Any) {
        NSLog("[ Example ] Will resume tracking")
        convivaAnalytics?.resumeTracking()
    }

    @IBAction func sendCustomEvent(_ sender: Any) {
        guard let player else { return }

        convivaAnalytics?.sendCustomPlaybackEvent(
            name: "Custom Event",
            attributes: ["at Time": "\(Int(player.currentTime))"]
        )
    }
}
