//
//  MockTracker.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
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
