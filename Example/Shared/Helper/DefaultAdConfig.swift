//
//  DefaultAdConfig.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 28.05.24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import BitmovinPlayer

// Represents the AdConfig which is used for the iOS and tvOS sample application
var defaultAdConfig: AdvertisingConfig {
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
