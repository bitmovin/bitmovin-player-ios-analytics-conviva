//
//  TestHelper.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

class TestHelper: NSObject {
    static var shared = TestHelper()
    let spyTracker: SpyTracker
    let mockTracker: MockTracker
    let factory: MockingFactory

    override private init() {
        self.spyTracker = SpyTracker()
        self.factory = MockingFactory()
        self.mockTracker = MockTracker()
    }

    // Shortcut method for TestHelper.shared.spyTracker.track(..)
    func spy(functionName: String, args: [String: String]? = nil) {
        TestHelper.shared.spyTracker.track(functionName: functionName, args: args)
    }

    // Shortcut method for TestHelper.shared.mockTracker.addMock(..)
    func mock(_ name: String, returnValue: Any) {
        TestHelper.shared.mockTracker.addMock(name, returnValue: returnValue)
    }
}

extension Dictionary where Key: Comparable {
    /// Converts the dictionary to a string with keys in stable order.
    /// - Returns: A string representation of the dictionary with sorted keys.
    func toStringWithStableOrder() -> String {
        let sortedKeyValuePairs = sorted { $0.key < $1.key }
        let keyValuePairsString = sortedKeyValuePairs.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        return "[\(keyValuePairsString)]"
    }
}

extension Dictionary {
    /// Maps the keys and values of the dictionary to their string representations.
    /// - Returns: A new dictionary with string keys and values.
    func mapKeyAndValuesToString() -> [String: String] {
        var args = [String: String]()
        for (key, value) in self {
            args[String(describing: key)] = String(describing: value)
        }
        return args
    }

    /// Converts the dictionary to a string with keys in stable order.
    /// - Returns: A string representation of the dictionary with sorted keys.
    func toStringWithStableOrder() -> String {
        mapKeyAndValuesToString().toStringWithStableOrder()
    }
}
