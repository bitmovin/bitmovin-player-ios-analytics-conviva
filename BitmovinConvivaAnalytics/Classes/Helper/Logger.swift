//
//  Logger.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 05.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

final class Logger: NSObject {
    var loggingEnabled: Bool = false

    init(loggingEnabled: Bool) {
        self.loggingEnabled = loggingEnabled
    }

    func debugLog(message: String) {
        if loggingEnabled {
            NSLog("[ Conviva Analytics ] %@", message)
        }
    }
}
