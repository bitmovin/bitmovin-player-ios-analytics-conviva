// swiftlint:disable file_length
//
//  BitmovinPlayerTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import BitmovinPlayer
import Foundation

class SourceTestDouble: Source, TestDoubleDataSource {
    var sourceConfig: BitmovinPlayerCore.SourceConfig {
        if let mockedValue = mocks["sourceConfig"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! SourceConfig
        }

        return SourceConfig(url: URL(string: "http://fake.url")!, type: .hls)
    }

    var isAttachedToPlayer: Bool {
        if let mockedValue = mocks["isAttachedToPlayer"] {
            return mockedValue as! Bool
        }

        return false
    }

    var isActive: Bool {
        if let mockedValue = mocks["isActive"] {
            return mockedValue as! Bool
        }

        return false
    }

    var duration: TimeInterval {
        if let mockedValue = mocks["duration"] {
            return mockedValue as! TimeInterval
        }

        return 0
    }

    var loadingState: LoadingState {
        if let mockedValue = mocks["loadingState"] {
            return mockedValue as! BitmovinPlayerCore.LoadingState
        }

        return .unloaded
    }

    var metadata: [String: AnyObject]? {
        get {
            if let mockedValue = mocks["metadata"] {
                return mockedValue as! [String: AnyObject]?
            }

            return [:]
        }
        // swiftlint:disable:next unused_setter_value
        set { }
    }

    // swiftlint:disable:next identifier_name
    var _modules: _SourceModulesApi {
        if let mockedValue = mocks["_modules"] {
            return mockedValue as! _SourceModulesApi
        }

        fatalError("Missing mock for _modules API")
    }

    var events: BitmovinPlayerCore.SourceEventsApi {
        if let mockedValue = mocks["events"] {
            return mockedValue as! BitmovinPlayerCore.SourceEventsApi
        }

        fatalError("Missing mock for events API")
    }

    var drm: BitmovinPlayerCore.SourceDrmApi {
        if let mockedValue = mocks["drm"] {
            return mockedValue as! BitmovinPlayerCore.SourceDrmApi
        }

        fatalError("Missing mock for drm API")
    }

    var latency: BitmovinPlayerCore.SourceLatencyApi {
        if let mockedValue = mocks["latency"] {
            return mockedValue as! BitmovinPlayerCore.SourceLatencyApi
        }

        fatalError("Missing mock for latency API")
    }

    func thumbnail(forTime time: TimeInterval) -> Thumbnail? {
        nil
    }

    func add(listener: any BitmovinPlayerCore.SourceListener) {
    }

    func remove(listener: any BitmovinPlayerCore.SourceListener) {
    }
}
