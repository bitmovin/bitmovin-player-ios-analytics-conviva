//
//  SpecHelper.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 12.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Quick

// This file is used for beforeSuite and afterSuite hooks.
// They should only be executed once so put it into this extra file.
class SpecHelper: QuickSpec {
    override class func spec() {
        beforeSuite {
            TestHelper.shared.factory.mockConviva()
        }

        // Do not add any test case here!

        afterSuite {
            TestHelper.shared.factory.undoConvivaMock()
        }
    }
}
