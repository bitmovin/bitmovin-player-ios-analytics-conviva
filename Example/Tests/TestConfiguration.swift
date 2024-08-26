//
//  BitmovinPlayerTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import XCTest

class TestConfiguration: NSObject {
    override init() {
        TestHelper.shared.factory.mockConviva()
    }
}
