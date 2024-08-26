//
//  SpyTracker.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

class SpyTracker {
    var spies: [ObjectIdentifier: [String: [[String: String]?]]] = [:]

    func track(aClass: AnyObject, functionName: String, args: [String: String]? = nil) {
        spies[ObjectIdentifier(aClass), default: [:]][functionName, default: []].append(args)
    }

    func hasCalledFunction(
        spy: Spy,
        _ name: String,
        withArgs args: [String: String]? = nil
    ) -> (success: Bool, trackedArgs: [[String: String]?]) {
        let called = spies[ObjectIdentifier(spy.aClass)]?.keys.contains(name) ?? false
        if !called {
            return (false, [])
        }

        if let expectedArgs = args {
            if let spyCalls = spies[ObjectIdentifier(spy.aClass)]?[name] {
                for calledArgs in spyCalls {
                    guard let calledArgs else { continue }

                    var containsExpectedArgs = true
                    for key in expectedArgs.keys {
                        containsExpectedArgs = containsExpectedArgs && (calledArgs[key] == expectedArgs[key])
                    }
                    if containsExpectedArgs {
                        return (containsExpectedArgs, [calledArgs])
                    }
                }

                return (false, spyCalls)
            }

            return (false, [nil])
        }

        return (called, [nil])
    }

    func reset() {
        spies = [:]
    }
}
