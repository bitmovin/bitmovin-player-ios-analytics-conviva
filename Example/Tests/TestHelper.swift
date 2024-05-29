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
