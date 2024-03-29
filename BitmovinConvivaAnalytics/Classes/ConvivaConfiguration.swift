//
//  ConvivaConfiguration.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 04.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

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

    public var convivaLogLevel: LogLevel = LogLevel.LOGLEVEL_WARNING

    public init() {}
}
