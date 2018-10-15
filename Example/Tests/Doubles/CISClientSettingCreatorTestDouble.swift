//
//  CISClientSettingCreatorTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by David Steinacher on 08.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientSettingCreatorTestDouble: NSObject {
    @objc static func myCreate(withCustomerKey: String) -> CISClientSettingProtocol {
        return CISClientSettingProtocolTestDouble()
    }
}
