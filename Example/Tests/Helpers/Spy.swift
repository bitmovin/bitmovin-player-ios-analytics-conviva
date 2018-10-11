//
//  Spy.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct Spy {
    let aClass: Any
    let functionName: String

    init(aClass: Any, functionName: String) {
        self.aClass = aClass
        self.functionName = functionName
    }
}
