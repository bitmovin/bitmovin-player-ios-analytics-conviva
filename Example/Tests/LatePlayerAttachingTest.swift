//
//  ExternallyManagedSessionTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 30.01.19.
//  Copyright © 2019 Bitmovin. All rights reserved.
//

import BitmovinConvivaAnalytics
import BitmovinPlayer
import ConvivaSDK
import Nimble
import Quick

class LatePlayerAttachingTest: QuickSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        var convivaAnalytics: ConvivaAnalytics!
        beforeEach {
            convivaAnalytics = try ConvivaAnalytics(customerKey: "")
        }

        afterEach {
            if convivaAnalytics != nil {
                convivaAnalytics = nil
            }
        }

        context("initialize session") {
            var spy: Spy!
            beforeEach {
                spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportPlaybackRequested")
            }
            context("without player") {
                beforeEach {
                    let playerConfig = PlayerConfig()
                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)
                }

                it("initializes the session with the externally provided asset name") {
                    var metadata = MetadataOverrides()
                    metadata.assetName = "MyAsset"
                    convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
                    try? convivaAnalytics.initializeSession()
                    expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyAsset"]))
                }
            }

            context("attaching the player while the session is already active") {
                beforeEach {
                    var metadata = MetadataOverrides()
                    metadata.assetName = "MyAsset"
                    convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
                    try convivaAnalytics.initializeSession()

                    convivaAnalytics.attach(player: playerDouble)
                }

                it("updates the session with available information") {
                    let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "setContentInfo")

                    expect(spy).to(haveBeenCalled())
                }
            }
        }
    }
}
