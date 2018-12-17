//
//  ConvivaConfiguration.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 04.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

public final class ConvivaConfiguration {
    /**
     Enables debug logging when set to true
     Default: false
     */
    public var debugLoggingEnabled: Bool = false
    /**
     The `TOUCHSTONE_SERVICE_URL` for testing with Touchstone. Only to be used for development, **must not be set in
     production or automated testing**.
     */
    public var gatewayUrl: URL?
    /**
     A string value used to distinguish individual apps, players, locations, platforms, and/or deployments.
     Default: Unknown (no config.applicationName set)
     */
    public var applicationName: String = "Unknown (no config.applicationName set)"
    /**
     A unique identifier to distinguish individual viewers/subscribers and their watching experience through
     Conviva's Viewers Module in Pulse.
     */
    public var viewerId: String?
    /**
     A `Dictionary<String, String>` to send customer specific custom tags.
     */
    public var customTags: [String: String]?

    public init() {}
}
