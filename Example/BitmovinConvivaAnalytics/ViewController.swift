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

    var player: BitmovinPlayer?
    var playerView: BMPBitmovinPlayerView?
    var fullScreen: Bool = false

    var convivaAnalytics: ConvivaAnalytics?

    let convivaCustomerKey: String = "YOUR-CONVIVA-CUSTOMER-KEY"
    var convivaGatewayString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBitmovinPlayer()

        /*if let posterUrl = sourceItem.posterSource {
            // Be aware that this will be executed synchronously on the main thread (change to SDWebImage if needed)
            if let data = try? Data(contentsOf: posterUrl) {
                posterImageView.image = UIImage(data: data)
            }
        }*/
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

        player?.setup(configuration: playerConfiguration)

        // Setup UI
        playerView = BMPBitmovinPlayerView(player: player!, frame: playerUIView.bounds)
        playerView?.fullscreenHandler = self

        if let convivaAnalytics = convivaAnalytics {
            convivaAnalytics.playerView = playerView
        }

        playerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerUIView.addSubview(playerView!)
    }

    var playerConfiguration: PlayerConfiguration {
        let playerConfiguration = PlayerConfiguration()
        playerConfiguration.sourceItem = vodSourceItem
//        playerConfiguration.sourceItem = vodSourceItemStartOffset
        if adsSwitch.isOn {
            playerConfiguration.advertisingConfiguration = adConfig
        }

        let playbackConfiguration = PlaybackConfiguration()
        playbackConfiguration.isAutoplayEnabled = true
        playbackConfiguration.isMuted = true
        playerConfiguration.playbackConfiguration = playbackConfiguration
        return playerConfiguration
    }

    var vodSourceItem: SourceItem {
        var sourceString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        if let streamString = streamUrlTextField.text,
           URL(string: streamString) != nil {
            sourceString = streamString
        }

        let sourceItem = SourceItem(url: URL(string: sourceString)!)!
        sourceItem.itemTitle = "Art of Motion"
        return sourceItem
    }

    var vodSourceItemStartOffset: SourceItem {
        var sourceString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        if let streamString = streamUrlTextField.text,
           URL(string: streamString) != nil {
            sourceString = streamString
        }

        let sourceItem = SourceItem(url: URL(string: sourceString)!)!
        sourceItem.itemTitle = "Art of Motion"
        // set start offset
        let  options: SourceOptions = SourceOptions()
        options.startOffset = 30
        options.startOffsetTimelineReference = .start
        sourceItem.options = options
        return sourceItem
    }

    var adConfig: AdvertisingConfiguration {
        // swiftlint:disable:next line_length
        let adTagVastSkippable = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=1"
        // swiftlint:disable:next line_length
        let adTagVast1 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=2"
        // swiftlint:disable:next line_length
        let adTagVast2 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/32573358/2nd_test_ad_unit&ciu_szs=300x100&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=3"

        let adSource1 = AdSource(tag: URL(string: adTagVastSkippable)!, ofType: .IMA)
        let adSource2 = AdSource(tag: URL(string: adTagVast1)!, ofType: .IMA)
        let adSource3 = AdSource(tag: URL(string: adTagVast2)!, ofType: .IMA)

        let preRoll = AdItem(adSources: [adSource1], atPosition: "pre")
        let midRoll = AdItem(adSources: [adSource2], atPosition: "20%")
        let postRoll = AdItem(adSources: [adSource3], atPosition: "post")

        let adConfig = AdvertisingConfiguration(schedule: [preRoll, midRoll, postRoll])

        return adConfig
    }

    // MARK: - actions
    @IBAction func setupPlayer(_ sender: Any) {
        player?.setup(configuration: playerConfiguration)
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
