//
//  Double.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

class Double {
    // can be used for methods and properties
    init(aClass: Any, name: String, return value: Any) {
        TestHelper.shared.mock(name, returnValue: value)
    }
}
