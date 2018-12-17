//
//  CISClientSettingCreatorTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientSettingCreatorTestDouble: NSObject {
    @objc static func myCreate(withCustomerKey: String) -> CISClientSettingProtocol {
        return CISClientSettingProtocolTestDouble()
    }
}
