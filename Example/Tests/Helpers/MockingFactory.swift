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
        let createMethod = class_getClassMethod(CISClientSettingCreator.self,
                                                #selector(CISClientSettingCreator.create(withCustomerKey: )))
        let myCreateMethod = class_getClassMethod(CISClientSettingCreatorDouble.self,
                                                  #selector(CISClientSettingCreatorDouble.myCreate(withCustomerKey:)))
        method_exchangeImplementations(createMethod!, myCreateMethod!)

        let clientCreateMethod = class_getClassMethod(CISClientCreator.self,
                                                      #selector(CISClientCreator.create(withClientSettings:factory:)))
        let myClientCreateMethod = class_getClassMethod(CISClientCreatorDouble.self,
                                                        #selector(
                                                            CISClientCreatorDouble.create(withClientSettings:factory:)
            )
        )
        method_exchangeImplementations(clientCreateMethod!, myClientCreateMethod!)
    }
}
