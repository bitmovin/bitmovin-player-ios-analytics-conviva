//
//  MockTracker.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

class MockTracker {
    var mocks: [String: Any] = [:]

    func addMock(_ name: String, returnValue: Any) {
        mocks[name] = returnValue
    }

    func reset() {
        mocks = [:]
    }
}
