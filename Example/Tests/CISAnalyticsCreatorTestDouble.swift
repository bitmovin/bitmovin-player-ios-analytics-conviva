//
//  VideoAnalyticsTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Eyevinn on 27/05/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import ConvivaSDK
import Foundation

class CISAnalyticsCreatorTestDouble: NSObject {
    @objc
    static func create(withCustomerKey: String, settings: [String: Any] ) -> CISAnalyticsProtocol {
        CISAnalyticsTestDouble()
    }

    @objc
    static func create(withCustomerKey: String) -> CISAnalyticsProtocol {
        CISAnalyticsTestDouble()
    }
}
