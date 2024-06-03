//
//  ConvivaConfiguration.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 04.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import ConvivaSDK
import Foundation

public final class ConvivaConfiguration {
    /**
     Enables debug logging when set to true
     Default: false
     */
    public var debugLoggingEnabled = false
    /**
     The `TOUCHSTONE_SERVICE_URL` for testing with Touchstone. Only to be used for development, **must not be set in
     production or automated testing**.
     */
    public var gatewayUrl: URL?

    public var convivaLogLevel = LogLevel.LOGLEVEL_WARNING

    public init() {}
}
