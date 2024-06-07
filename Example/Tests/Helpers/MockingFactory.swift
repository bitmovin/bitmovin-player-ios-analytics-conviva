//
//  MockingFactory.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import ConvivaSDK
import Foundation

class MockingFactory {
    func mockConviva() {
        // method swizzling
        method_exchangeImplementations(createAnalyticsMethod, mockedCreateAnalyticsMethod)
        method_exchangeImplementations(createAnalyticsMethod2, mockedCreateAnalyticsMethod2)
    }

    func undoConvivaMock() {
        method_exchangeImplementations(mockedCreateAnalyticsMethod, createAnalyticsMethod)
        method_exchangeImplementations(mockedCreateAnalyticsMethod2, createAnalyticsMethod2)
    }

    var createAnalyticsMethod: Method {
        class_getClassMethod(
            CISAnalyticsCreator.self,
            #selector(CISAnalyticsCreator.create(withCustomerKey:))
        )!
    }

    var mockedCreateAnalyticsMethod: Method {
        class_getClassMethod(
            CISAnalyticsCreatorTestDouble.self,
            #selector(CISAnalyticsCreatorTestDouble.create(withCustomerKey:))
        )!
    }

    var createAnalyticsMethod2: Method {
        class_getClassMethod(
            CISAnalyticsCreator.self,
            #selector(CISAnalyticsCreator.create(withCustomerKey:settings:))
        )!
    }

    var mockedCreateAnalyticsMethod2: Method {
        class_getClassMethod(
            CISAnalyticsCreatorTestDouble.self,
            #selector(CISAnalyticsCreatorTestDouble.create(withCustomerKey:settings:))
        )!
    }
}
