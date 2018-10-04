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

    var player: BitmovinPlayer?
    var playerView: BMPBitmovinPlayerView?

    var convivaAnalytics: ConvivaAnalytics?

    let convivaCustomerKey: String = ""
    let convivaGatewayString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBMPlayer()

        if let posterUrl = sourceItem.posterSource {
            // Be aware that this will be executed synchronously on the main thread (change to SDWebImage if needed)
            if let data = try? Data(contentsOf: posterUrl) {
                posterImageView.image = UIImage(data: data)
            }
        }
    }

    func setupBMPlayer() {
        // Setup Player
        player = BitmovinPlayer()


        let convivaConfig = ConvivaConfiguration()
        convivaConfig.gatewayUrl = URL(string: convivaGatewayString)!
        convivaConfig.viewerId = "awesomeViewerId"
        // TODO: handle error here
        // swiftlint:disable all
        convivaAnalytics = try? ConvivaAnalytics(player: player!, customerKey: convivaCustomerKey, config: convivaConfig) as! ConvivaAnalytics
        if convivaAnalytics != nil {
            print("🤷‍♂️ Success")
        } else {
            print("🆘 Error")
        }

        player?.setup(configuration: playerConfiguration)




        // Setup UI
        playerView = BMPBitmovinPlayerView(player: player!, frame: playerUIView.bounds)
        playerView?.fullscreenHandler = self // TODO: do something in the fullscreen Handler
        if let convivaAnalytics = convivaAnalytics {
            convivaAnalytics.registerPlayerView(playerView: playerView!)
        }
        playerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerUIView.addSubview(playerView!)
    }
    @IBAction func setupPlayer(_ sender: Any) {
        player?.setup(configuration: playerConfiguration)
    }
    @IBAction func destroyPlayer(_ sender: Any) {
        player?.unload()
//        player?.destroy()
    }

    var playerConfiguration: PlayerConfiguration {
        let playerConfiguration = PlayerConfiguration()
        playerConfiguration.sourceItem = sourceItem
        if adsSwitch.isOn {
            playerConfiguration.advertisingConfiguration = adConfig
        }
        return playerConfiguration
    }

    var sourceItem: SourceItem {
        var sourceString = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        if let streamString = streamUrlTextField.text,
           URL(string: streamString) != nil {
            sourceString = streamString
        }

        let sourceItem = SourceItem(url: URL(string: sourceString)!)!
        sourceItem.posterSource = URL(string: "https://bitmovin-a.akamaihd.net/content/poster/hd/RedBull.jpg")
        sourceItem.itemTitle = "Art of Motion"
        return sourceItem
    }

    var adConfig: AdvertisingConfiguration {
        let adTagVastSkippable = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=1"
        let adTagVast1 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=2"
        let adTagVast2 = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/32573358/2nd_test_ad_unit&ciu_szs=300x100&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=3"

        let adSource1 = AdSource(tag: URL(string: adTagVastSkippable)!, ofType: .IMA)
        let adSource2 = AdSource(tag: URL(string: adTagVast1)!, ofType: .IMA)
        let adSource3 = AdSource(tag: URL(string: adTagVast2)!, ofType: .IMA)

        let preRoll = AdItem(adSources: [adSource1], atPosition: "blub")
        let midRoll = AdItem(adSources: [adSource2], atPosition: "20%")
        let postRoll = AdItem(adSources: [adSource3], atPosition: "post")

        let adConfig = AdvertisingConfiguration(schedule: [preRoll, midRoll, postRoll])

        return adConfig
    }

}

extension ViewController: FullscreenHandler {
    var isFullscreen: Bool {
        return fullScreen
    }

    func onFullscreenRequested() {
        fullScreen = true
    }

    func onFullscreenExitRequested() {
        fullScreen = false
    }


}
