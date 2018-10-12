//
//  MockingFactory.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class MockingFactory {
    func mockConviva() {
        // method swizzling
        method_exchangeImplementations(createSettingMethod, mockedCreateSettingMethod)
        method_exchangeImplementations(createClientMethod, mockedCreateClientMethod)
    }

    func undoConvivaMock() {
        method_exchangeImplementations(mockedCreateSettingMethod, createSettingMethod)
        method_exchangeImplementations(mockedCreateClientMethod, createClientMethod)
    }

    var createSettingMethod: Method {
        return class_getClassMethod(CISClientSettingCreator.self,
                                    #selector(CISClientSettingCreator.create(withCustomerKey: )))!
    }

    var mockedCreateSettingMethod: Method {
        return class_getClassMethod(CISClientSettingCreatorDouble.self,
                                    #selector(CISClientSettingCreatorDouble.myCreate(withCustomerKey:)))!
    }

    var createClientMethod: Method {
        return class_getClassMethod(CISClientCreator.self,
                                    #selector(CISClientCreator.create(withClientSettings:factory:)))!
    }

    var mockedCreateClientMethod: Method {
        return class_getClassMethod(CISClientCreatorDouble.self,
                                    #selector(CISClientCreatorDouble.create(withClientSettings:factory:)))!
    }
}
