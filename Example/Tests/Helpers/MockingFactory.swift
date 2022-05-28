//
//  MockingFactory.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

class MockingFactory {
    func mockConviva() {
        // method swizzling
        method_exchangeImplementations(createAnalyticsMethod, mockedCreateAnalyticsMethod)
        method_exchangeImplementations(createAnalyticsMethod2, mockedCreateAnalyticsMethod2)
        
        // method_exchangeImplementations(createSettingMethod, mockedCreateSettingMethod)
        // method_exchangeImplementations(createClientMethod, mockedCreateClientMethod)
    }

    func undoConvivaMock() {
        method_exchangeImplementations(mockedCreateAnalyticsMethod, createAnalyticsMethod)
        method_exchangeImplementations(mockedCreateAnalyticsMethod2, createAnalyticsMethod2)

//        method_exchangeImplementations(mockedCreateSettingMethod, createSettingMethod)
//        method_exchangeImplementations(mockedCreateClientMethod, createClientMethod)
    }

    var createAnalyticsMethod: Method {
        return class_getClassMethod(CISAnalyticsCreator.self,
                                    #selector(CISAnalyticsCreator.create(withCustomerKey:)))!
    }

    var mockedCreateAnalyticsMethod: Method {
        return class_getClassMethod(CISAnalyticsCreatorTestDouble.self,
                                    #selector(CISAnalyticsCreatorTestDouble.create(withCustomerKey:)))!
    }

    var createAnalyticsMethod2: Method {
        return class_getClassMethod(CISAnalyticsCreator.self,
                                    #selector(CISAnalyticsCreator.create(withCustomerKey:settings:)))!
    }

    var mockedCreateAnalyticsMethod2: Method {
        return class_getClassMethod(CISAnalyticsCreatorTestDouble.self,
                                    #selector(CISAnalyticsCreatorTestDouble.create(withCustomerKey:settings:)))!
    }

//    var createSettingMethod: Method {
//        return class_getClassMethod(CISClientSettingCreator.self,
//                                    #selector(CISClientSettingCreator.create(withCustomerKey: )))!
//    }
//
//    var mockedCreateSettingMethod: Method {
//        return class_getClassMethod(CISClientSettingCreatorTestDouble.self,
//                                    #selector(CISClientSettingCreatorTestDouble.myCreate(withCustomerKey:)))!
//    }
//
//    var createClientMethod: Method {
//        return class_getClassMethod(CISClientCreator.self,
//                                    #selector(CISClientCreator.create(withClientSettings:factory:)))!
//    }
//
//    var mockedCreateClientMethod: Method {
//        return class_getClassMethod(CISClientCreatorTestDouble.self,
//                                    #selector(CISClientCreatorTestDouble.create(withClientSettings:factory:)))!
//    }
}
