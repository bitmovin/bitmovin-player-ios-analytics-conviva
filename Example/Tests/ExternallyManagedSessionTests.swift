//
//  ExternallyManagedSessionTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class ExternallyManagedSessionSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("Externally Managed Session") {
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
                do {
                    convivaAnalytics = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
            }

            afterEach {
                if convivaAnalytics != nil {
                    convivaAnalytics = nil
                }
            }

            context("initialize session") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")
                }
                context("without source loaded") {
                    beforeEach {
                        let playerConfig = PlayerConfiguration()
                        _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)
                    }

                    it("with asset name provided") {
                        try? convivaAnalytics.initializeSession(assetName: "MyAsset")
                        expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyAsset"]))
                    }

                    it("throw error without source and asset name") {
                        expect { try convivaAnalytics.initializeSession() }.to(throwError())
                        expect(spy).toNot(haveBeenCalled())
                    }
                }

                context("with source config") {
                    beforeEach {
                        let playerConfig = PlayerConfiguration()
                        let hlsSource = HLSSource(url: URL(string: "http://a.url")!)
                        playerConfig.sourceItem = SourceItem(hlsSource: hlsSource)
                        playerConfig.sourceItem?.itemTitle = "MyTitle"
                        _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)
                    }

                    it("uses item title") {
                        try? convivaAnalytics.initializeSession()
                        expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyTitle"]))
                    }

                    it("uses asset anem attribute") {
                        try? convivaAnalytics.initializeSession(assetName: "A Override")
                        expect(spy).to(haveBeenCalled(withArgs: ["assetName": "A Override"]))
                    }
                }

                it("no-opt if session is running") {
                    playerDouble.fakePlayEvent()
                    TestHelper.shared.spyTracker.reset()
                    try? convivaAnalytics.initializeSession()
                    expect(spy).toNot(haveBeenCalled())
                }
            }

            context("end session") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISClientTestDouble.self, functionName: "cleanupSession")
                }

                it("no-opt if no session running") {
                    convivaAnalytics.endSession()
                    expect(spy).toNot(haveBeenCalled())
                }

                it("cleanup running session") {
                    playerDouble.fakePlayEvent()
                    convivaAnalytics.endSession()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("multiple sessions") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")
                }

                it("take the asset name from the source in a consecutive session") {
                    // No source at first run
                    let playerConfig = PlayerConfiguration()
                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)

                    try? convivaAnalytics.initializeSession(assetName: "MyAsset")
                    expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyAsset"]))
                    convivaAnalytics.endSession()

                    // With source at second run
                    let hlsSource = HLSSource(url: URL(string: "http://a.url")!)
                    playerConfig.sourceItem = SourceItem(hlsSource: hlsSource)
                    playerConfig.sourceItem?.itemTitle = "MyTitle"
                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)

                    try? convivaAnalytics.initializeSession()
                    expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyTitle"]))
                }
            }
        }
    }
}
