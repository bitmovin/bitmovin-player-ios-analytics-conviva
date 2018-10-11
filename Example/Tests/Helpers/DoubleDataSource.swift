//
//  DoubleDataSource.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

protocol DoubleDataSource {
    var mocks: [String: Any] { get }
    func spy(functionName: String, args: [String: String]?)
}

extension DoubleDataSource {
    var mocks: [String: Any] {
        return TestHelper.shared.mockTracker.mocks
    }

    func spy(functionName: String, args: [String: String]? = nil) {
        TestHelper.shared.spy(functionName: functionName, args: args)
    }
}
