//
//  CISClientSEttingsCreatorDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by David Steinacher on 08.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientSettingCreatorDouble: NSObject {
    @objc static func myCreate(withCustomerKey: String) -> CISClientSettingProtocol {
        return CISClientSettingProtocolDouble()
    }
}

// TODO: extract
class CISClientCreatorDouble {
    @objc static func create(withClientSettings: CISClientSettingProtocol, factory: CISSystemSettings) -> CISClientProtocol {
        return CISClientDouble()
    }
}
