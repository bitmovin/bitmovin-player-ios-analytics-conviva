//
//  ViewController.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 10/02/2018.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import UIKit
import BitmovinPlayer
import BitmovinConvivaAnalytics

class ViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var playerUIView: UIView!
    @IBOutlet weak var adsSwitch: UISwitch!
    @IBOutlet weak var streamUrlTextField: UITextField!
    @IBOutlet weak var uiEventLabel: UILabel!

    var player: Player?
    var playerView: PlayerView?
    var fullScreen: Bool = false

    var convivaAnalytics: ConvivaAnalytics?

    let convivaCustomerKey: String = "YOUR-CONVIVA-CUSTOMER-KEY"
    var convivaGatewayString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBitmovinPlayer()

        if let posterUrl = vodSourceConfig.posterSource {
            // Be aware that this will be executed synchronously on the main thread (change to SDWebImage if needed)
            if let data = try? Data(contentsOf: posterUrl) {
                posterImageView.image = UIImage(data: data)
            }
        }
    }

    func setupBitmovinPlayer() {
        // Setup Player
        player = PlayerFactory.create(playerConfig: playerConfiguration)

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
            convivaAnalytics = try ConvivaAnalytics(player: player!,
                                                    customerKey: convivaCustomerKey,
                                                    config: convivaConfig)
            convivaAnalytics?.updateContentMetadata(metadataOverrides: metadata)
        } catch {
            NSLog("[ Example ] ConvivaAnalytics initialization failed with error: \(error)")
        }

        // Setup UI
        playerView = PlayerView(player: player!, frame: playerUIView.bounds)
        playerView?.fullscreenHandler = self

        if let convivaAnalytics = convivaAnalytics {
            convivaAnalytics.playerView = playerView
        }

        playerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerUIView.addSubview(playerView!)

        player?.load(source: SourceFactory.create(from: vodSourceConfig))
    }

    var playerConfiguration: PlayerConfig {
        let playerConfig = PlayerConfig()
        if adsSwitch.isOn {
            playerConfig.advertisingConfig = adConfig
        }

        let playbackConfig = PlaybackConfig()
        playbackConfig.isAutoplayEnabled = true
        playbackConfig.isMuted = true
        playerConfig.playbackConfig = playbackConfig
        return playerConfig
    }

    var vodSourceConfig: SourceConfig {
        var sourceString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        if let streamString = streamUrlTextField.text,
           URL(string: streamString) != nil {
            sourceString = streamString
        }

        let sourceConfig = SourceConfig(url: URL(string: sourceString)!, type: .hls)
        sourceConfig.title = "Art of Motion"
        return sourceConfig
    }

    var adConfig: AdvertisingConfig {
        // swiftlint:disable:next line_length
        let adTagVastSkippable = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=1"
        // swiftlint:disable:next line_length
        let adTagVast1 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=2"
        // swiftlint:disable:next line_length
        let adTagVast2 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/32573358/2nd_test_ad_unit&ciu_szs=300x100&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=3"

        let adSource1 = AdSource(tag: URL(string: adTagVastSkippable)!, ofType: .ima)
        let adSource2 = AdSource(tag: URL(string: adTagVast1)!, ofType: .ima)
        let adSource3 = AdSource(tag: URL(string: adTagVast2)!, ofType: .ima)

        let preRoll = AdItem(adSources: [adSource1], atPosition: "pre")
        let midRoll = AdItem(adSources: [adSource2], atPosition: "20%")
        let postRoll = AdItem(adSources: [adSource3], atPosition: "post")

        let adConfig = AdvertisingConfig(schedule: [preRoll, midRoll, postRoll])

        return adConfig
    }

    // MARK: - actions
    @IBAction func setupPlayer(_ sender: Any) {
        player?.load(source: SourceFactory.create(from: vodSourceConfig))
    }

    @IBAction func destroyPlayer(_ sender: Any) {
        player?.unload()
    }

    @IBAction func sendCustomEvent(_ sender: Any) {
        if let player = player {
            convivaAnalytics?.sendCustomPlaybackEvent(name: "Custom Event",
                                                      attributes: ["at Time": "\(Int(player.currentTime))"])
        }
    }

}

extension ViewController: FullscreenHandler {
    var isFullscreen: Bool {
        return fullScreen
    }

    func onFullscreenRequested() {
        fullScreen = true
        uiEventLabel.text = "enterFullscreen"
    }

    func onFullscreenExitRequested() {
        fullScreen = false
        uiEventLabel.text = "exitFullscreen"
    }
}
