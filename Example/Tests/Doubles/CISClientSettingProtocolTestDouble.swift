//
//  CISClientSettingProtocolTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import ConvivaSDK

class CISClientSettingProtocolTestDouble: NSObject, CISClientSettingProtocol {
    func setUserPreferenceForDataCollection(_ userPrefs: [AnyHashable: Any]!) {}

    func setUserPreferenceForDataDeletion(_ userPrefs: [AnyHashable: Any]!) {}

    func getCustomerKey() -> String! {
        return "StubKey"
    }

    func getHeartbeatInterval() -> TimeInterval {
        return 1000
    }

    func getGatewayUrl() -> String! {
        return "Stub Url"
    }

    func setGatewayUrl(_ gatewayUrl: String!) {}
    func setCustomerKey(_ customerKey: String!) {}
    func setHeartbeatInterval(_ heartbeatInterval: TimeInterval) {}
}
