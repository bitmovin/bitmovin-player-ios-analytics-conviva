//
//  Spy.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
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
