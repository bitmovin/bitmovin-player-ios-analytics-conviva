//
//  TestDoubleDataSource.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

protocol TestDoubleDataSource: AnyObject {
    var mocks: [String: Any] { get }
    func spy(functionName: String, args: [String: String]?)
}

extension TestDoubleDataSource {
    var mocks: [String: Any] {
        TestHelper.shared.mockTracker.mocks
    }

    func spy(functionName: String, args: [String: String]? = nil) {
        TestHelper.shared.spy(
            aClass: type(of: self),
            functionName: functionName,
            args: args
        )
    }
}
