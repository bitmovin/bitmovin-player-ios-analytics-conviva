//
//  ExternallyManagedSessionTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 30.01.19.
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
                        let playerConfig = PlayerConfig()
                        _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)
                    }

                    it("with asset name provided") {
                        var metadata: MetadataOverrides = MetadataOverrides()
                        metadata.assetName = "MyAsset"
                        convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
                        try? convivaAnalytics.initializeSession()
                        expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyAsset"]))
                    }

                    #if targetEnvironment(simulator)
                    // This test will only run on a simulator
                    // https://github.com/Quick/Nimble#swift-assertions
                    it("throw error without source and asset name") {
                        expect { try convivaAnalytics.initializeSession() }.to(throwError())
                        expect(spy).toNot(haveBeenCalled())
                    }
                    #endif
                }

                context("with source loaded") {
                    beforeEach {
                        let playerConfig = PlayerConfig()

                        _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)
                    }

                    it("uses item title") {
                        let sourceConfig = SourceConfig(url: URL(string: "http://a.url")!, type: .hls)
                        sourceConfig.title = "MyTitle"
                        let source = SourceFactory.create(from: sourceConfig)
                        playerDouble.load(source: source)
                        try? convivaAnalytics.initializeSession()
                        expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyTitle"]))
                    }

                    it("uses asset name attribute") {
                        var metadata = MetadataOverrides()
                        metadata.assetName = "A Override"
                        convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
                        let sourceConfig = SourceConfig(url: URL(string: "http://a.url")!, type: .hls)
                        let source = SourceFactory.create(from: sourceConfig)
                        playerDouble.load(source: source)

                        try? convivaAnalytics.initializeSession()
                        expect(spy).to(haveBeenCalled(withArgs: ["assetName": "A Override"]))
                    }

                    it("throw error without title in the source and without asset name") {
                        let sourceConfig = SourceConfig(url: URL(string: "http://a.url")!, type: .hls)
                        let source = SourceFactory.create(from: sourceConfig)
                        playerDouble.load(source: source)
                        expect { try convivaAnalytics.initializeSession() }.to(throwError())
                        expect(spy).toNot(haveBeenCalled())
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
                    let playerConfig = PlayerConfig()
                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)

                    var metadata = MetadataOverrides()
                    metadata.assetName = "MyAsset"
                    convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)

                    try? convivaAnalytics.initializeSession()
                    expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyAsset"]))
                    convivaAnalytics.endSession()

                    // With source at second run
                    let sourceConfig = SourceConfig(url: URL(string: "http://a.url")!, type: .hls)
                    sourceConfig.title = "MyTitle"
                    let source = SourceFactory.create(from: sourceConfig)
                    playerDouble.load(source: source)
                    try? convivaAnalytics.initializeSession()
                    expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyTitle"]))
                }
            }

            context("report playback deficiency") {
                var spy: Spy!

                beforeEach {
                    spy = Spy(aClass: CISClientTestDouble.self, functionName: "reportError")
                }

                it("no-opt if no session is running") {
                    convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                    expect(spy).toNot(haveBeenCalled())
                }

                context("reports a deficiency") {
                    beforeEach {
                        playerDouble.fakePlayEvent()
                    }

                    it("reports a warning") {
                        let severity = ErrorSeverity.ERROR_WARNING
                        convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_WARNING)
                        expect(spy).to(haveBeenCalled(withArgs: ["severity": "\(severity.rawValue)"]))
                    }

                    it("reports an error") {
                        let severity = ErrorSeverity.ERROR_FATAL
                        convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                        expect(spy).to(haveBeenCalled(withArgs: ["severity": "\(severity.rawValue)"]))
                    }

                    context("session closing handling") {
                        beforeEach {
                            spy = Spy(aClass: CISClientTestDouble.self, functionName: "cleanupSession")
                        }
                        it("closes session by default") {
                            convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                            expect(spy).to(haveBeenCalled())
                        }

                        it("closes session if set to true") {
                            convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                            expect(spy).to(haveBeenCalled())
                        }

                        it("not closes session if set to false") {
                            convivaAnalytics.reportPlaybackDeficiency(message: "Test",
                                                                      severity: .ERROR_FATAL,
                                                                      endSession: false)
                            expect(spy).toNot(haveBeenCalled())
                        }
                    }
                }
            }
        }
    }
}
