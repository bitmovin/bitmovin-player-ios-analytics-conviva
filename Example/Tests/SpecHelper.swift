//
//  SpecHelper.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 12.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick

// This file is used for beforeSuite and afterSuite hooks.
// They should only be executed once so put it into this extra file.
class SpecHelper: QuickSpec {
    override func spec() {
        beforeSuite {
            self.continueAfterFailure = true
            TestHelper.shared.factory.mockConviva()
        }

        // Do not add any test case here!

        afterSuite {
            TestHelper.shared.factory.undoConvivaMock()
        }
    }
}
