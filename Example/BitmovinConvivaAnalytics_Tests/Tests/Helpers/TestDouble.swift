//
//  TestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

class TestDouble {
    // can be used for methods and properties
    init(aClass: Any, name: String, return value: Any) {
        TestHelper.shared.mock(name, returnValue: value)
    }
}
