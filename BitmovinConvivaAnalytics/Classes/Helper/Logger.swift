//
//  Logger.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 05.10.18.
//

import UIKit

class Logger: NSObject {
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
