//
//  ConvivaConfiguration.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 04.10.18.
//

import Foundation

public class ConvivaConfiguration {
    public var debugLoggingEnabled: Bool = false
    public var gatewayUrl: URL?
    public var applicationName: String = "Unknown (no config.applicationName set)"
    public var viewerId: String?
    public var customTags: [String: Any]?

    public init() {}
}
