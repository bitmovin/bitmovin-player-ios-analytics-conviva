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
        playerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerUIView.addSubview(playerView!)
    }

    var playerConfiguration: PlayerConfiguration {
        let playerConfiguration = PlayerConfiguration()
        playerConfiguration.sourceItem = sourceItem
        return playerConfiguration
    }

    var sourceItem: SourceItem {
        let sourceURL = "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8"
        let sourceItem = SourceItem(url: URL(string: sourceURL)!)!
        sourceItem.posterSource = URL(string: "https://bitmovin-a.akamaihd.net/content/poster/hd/RedBull.jpg")
        sourceItem.itemTitle = "Art of Motion"
        sourceItem.itemDescription = "HLS, AES-128"
        return sourceItem
    }

}
