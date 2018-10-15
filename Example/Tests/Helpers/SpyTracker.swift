//
//  SpyTracker.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

class SpyTracker {
    var spies: [String: [String: String]?] = [:]

    func track(functionName: String, args: [String: String]? = nil) {
        spies[functionName] = args
    }

    func hasCalledFunction(_ name: String,
                           withArgs: [String: String]? = nil) -> (success: Bool, trackedArgs: [String: String]?) {
        let called = spies.keys.contains(name)
        if !called {
            return (false, nil)
        }

        if let expectedArgs = withArgs {
            if let calledArgs = spies[name] {
                var containsExpectedArgs = true
                for key in expectedArgs.keys {
                    containsExpectedArgs = containsExpectedArgs && (calledArgs?[key] == expectedArgs[key])
                }
                return (containsExpectedArgs, spies[name] ?? nil)
            }

            return (false, nil)
        }

        return (called, nil)
    }

    func reset() {
        spies = [:]
    }
}
