//
//  CISClientCreatorTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 15.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientCreatorTestDouble {
    @objc static func create(withClientSettings: CISClientSettingProtocol,
                             factory: CISSystemSettings) -> CISClientProtocol {
        return CISClientTestDouble()
    }
}
