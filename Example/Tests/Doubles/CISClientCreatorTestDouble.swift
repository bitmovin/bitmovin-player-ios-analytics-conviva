//
//  CISClientCreatorTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 15.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientCreatorTestDouble {
    @objc static func create(withClientSettings: CISClientSettingProtocol,
                             factory: CISSystemSettings) -> CISClientProtocol {
        return CISClientTestDouble()
    }
}
