//
//  ConvivaAnalyticsError.swift
//  BitmovinConvivaAnalytics-iOS
//
//  Created by Bitmovin on 31.01.19.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

public struct ConvivaAnalyticsError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
