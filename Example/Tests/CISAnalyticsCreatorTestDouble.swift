//
//  VideoAnalyticsTestDouble.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Eyevinn on 27/05/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISAnalyticsCreatorTestDouble: NSObject {
    @objc static func create(withCustomerKey: String, settings: [String: Any] ) -> CISAnalyticsProtocol {
        return CISAnalyticsTestDouble()
    }

    @objc static func create(withCustomerKey: String) -> CISAnalyticsProtocol {
        return CISAnalyticsTestDouble()
    }

}
