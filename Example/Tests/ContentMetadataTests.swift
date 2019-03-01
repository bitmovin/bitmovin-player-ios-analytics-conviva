//
//  ContentMetadataTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

// swiftlint:disable:next type_body_length
class ContentMetadataSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("content meta data") {
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
                do {
                    let convivaConfig = ConvivaConfiguration()

                    convivaAnalytics = try ConvivaAnalytics(player: playerDouble,
                                                            customerKey: "",
                                                            config: convivaConfig)

                    var metadata = MetadataOverrides()
                    metadata.applicationName = "Unit Tests"
                    metadata.viewerId = "TestViewer"
                    metadata.custom = ["Custom": "Tags", "TestRun": "Success"]
                    convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
            }
            afterEach {
                if convivaAnalytics != nil {
                    convivaAnalytics = nil
                }
            }
            context("when initializing session") {
                it("set application name") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")

                    expect(spy).to(
                        haveBeenCalled(withArgs: ["applicationName": "Unit Tests"])
                    )
                }

                it("set asset name") {
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")

                    let playerConfiguration = PlayerConfiguration()
                    let sourceItem = SourceItem(url: URL(string: "www.google.com.m3u8")!)!
                    sourceItem.itemTitle = "Art of Unit Test"
                    playerConfiguration.sourceItem = sourceItem

                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfiguration)

                    playerDouble.fakePlayEvent() // to initialize session
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["assetName": "Art of Unit Test"])
                    )
                }

                it("set viewer id") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["viewerId": "TestViewer"])
                    )
                }

                it("set custom tags") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["Custom": "Tags", "TestRun": "Success"])
                    )
                }

                it("set stream url") {
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")

                    let playerConfiguration = PlayerConfiguration()
                    let sourceItem = SourceItem(url: URL(string: "www.google.com.m3u8")!)!
                    sourceItem.itemTitle = "Art of Unit Test"
                    playerConfiguration.sourceItem = sourceItem

                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfiguration)
                    _ = TestDouble(aClass: playerDouble, name: "streamType", return: BMPMediaSourceType.HLS)

                    playerDouble.fakePlayEvent() // to initialize session

                    expect(spy).to(
                        haveBeenCalled(withArgs: ["streamUrl": "www.google.com.m3u8"])
                    )
                }
            }

            context("when updating session") {
                it("update video duration") {
                    _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(50))
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "updateContentMetadata")

                    expect(spy).to(
                        haveBeenCalled(withArgs: ["duration": "50"])
                    )
                }

                it("update stream type (VOD/Live)") {
                    _ = TestDouble(aClass: playerDouble, name: "isLive", return: true)
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "updateContentMetadata")

                    expect(spy).to(
                        haveBeenCalled(withArgs: ["streamType": "\(StreamType.CONVIVA_STREAM_LIVE.rawValue)"])
                    )
                }

                it("update stream url") {
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "updateContentMetadata")

                    let playerConfiguration = PlayerConfiguration()
                    let sourceItem = SourceItem(url: URL(string: "www.google.com.m3u8")!)!
                    sourceItem.itemTitle = "Art of Unit Test"
                    playerConfiguration.sourceItem = sourceItem

                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfiguration)
                    _ = TestDouble(aClass: playerDouble, name: "streamType", return: BMPMediaSourceType.HLS)

                    playerDouble.fakePlayEvent() // to initialize session

                    expect(spy).to(
                        haveBeenCalled(withArgs: ["streamUrl": "www.google.com.m3u8"])
                    )
                }

                it("update bitrate") {
                    let videoQuality = VideoQuality(identifier: "Test",
                                                    label: "test",
                                                    bitrate: 4_000_000,
                                                    width: 1900,
                                                    height: 800)

                    _ = TestDouble(aClass: playerDouble, name: "videoQuality", return: videoQuality)

                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "setBitrateKbps")

                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newBitrateKbps": "4000"])
                    )
                }
            }

            describe("overriding") {
                var metadata: MetadataOverrides!
                beforeEach {
                    metadata = MetadataOverrides()
                }

                context("setting overrides before playback report them at session creation") {
                    var spy: Spy!
                    beforeEach {
                        spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")
                        metadata.assetName = "MyAsset"

                    }

                    func updateMetadataAndInitialize() {
                        convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
                        // swiftlint:disable:next force_try
                        try! convivaAnalytics.initializeSession()
                    }

                    it("set assetName") {
                        // Asset name is set in beforeEach block
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["assetName": "MyAsset"]))
                    }

                    it("set viewerId") {
                        metadata.viewerId = "MyViewerId"
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["viewerId": "MyViewerId"]))
                    }

                    it("set application name") {
                        metadata.applicationName = "My Application Name"
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["applicationName": "My Application Name"]))
                    }

                    it("set stream type") {
                        let streamType = StreamType.CONVIVA_STREAM_LIVE
                        metadata.streamType = streamType
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["streamType": "\(streamType.rawValue)"]))
                    }

                    it("set duration") {
                        metadata.duration = 659
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["duration": "659"]))
                    }

                    it("set custom") {
                        metadata.custom = [
                            "MyCustom": "Test Value"
                        ]
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["MyCustom": "Test Value"]))
                    }

                    it("set encoded frame rate") {
                        metadata.encodedFramerate = 55
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["encodedFramerate": "55"]))
                    }

                    it("set default resrouce") {
                        metadata.defaultResource = "MyResource"
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["defaultResource": "MyResource"]))
                    }

                    it("set stream Url") {
                        metadata.streamUrl = "MyUrl"
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["streamUrl": "MyUrl"]))
                    }

                    it("dont override intern custom tags") {
                        metadata.custom = [
                            "integrationVersion": "xyz"
                        ]
                        updateMetadataAndInitialize()
                        expect(spy).toNot(haveBeenCalled(withArgs: ["integrationVersion": "xyz"]))
                    }
                }

                context("setting overrides during playback reports just permitted immediately") {
                    var spy: Spy!
                    beforeEach {
                        spy = Spy(aClass: CISClientTestDouble.self, functionName: "updateContentMetadata")
                        let playerConfig = PlayerConfiguration()

                        let hlsSource = HLSSource(url: URL(string: "http://a.url")!)
                        playerConfig.sourceItem = SourceItem(hlsSource: hlsSource)
                        playerConfig.sourceItem?.itemTitle = "MyTitle"

                        _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfig)

                        playerDouble.fakePlayEvent()
                        playerDouble.fakePlayingEvent()
                    }

                    func updateMetadataAndInitialize() {
                        convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
                    }

                    it("set assetName") {
                        metadata.assetName = "MyAsset"
                        updateMetadataAndInitialize()
                        expect(spy).toNot(haveBeenCalled(withArgs: ["assetName": "MyAsset"]))
                    }

                    it("set viewerId") {
                        metadata.viewerId = "MyViewerId"
                        updateMetadataAndInitialize()
                        expect(spy).toNot(haveBeenCalled(withArgs: ["viewerId": "MyViewerId"]))
                    }

                    it("set application name") {
                        metadata.applicationName = "My Application Name"
                        updateMetadataAndInitialize()
                        expect(spy).toNot(haveBeenCalled(withArgs: ["applicationName": "My Application Name"]))
                    }

                    it("set stream type") {
                        let streamType = StreamType.CONVIVA_STREAM_LIVE
                        metadata.streamType = streamType
                        updateMetadataAndInitialize()
                        expect(spy).toNot(haveBeenCalled(withArgs: ["streamType": "\(streamType.rawValue)"]))
                    }

                    it("set duration") {
                        metadata.duration = 659
                        updateMetadataAndInitialize()
                        expect(spy).toNot(haveBeenCalled(withArgs: ["duration": "659"]))
                    }

                    it("set custom") {
                        metadata.custom = [
                            "MyCustom": "Test Value"
                        ]
                        updateMetadataAndInitialize()
                        expect(spy).toNot(haveBeenCalled(withArgs: ["MyCustom": "Test Value"]))
                    }

                    it("set encoded frame rate") {
                        metadata.encodedFramerate = 55
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["encodedFramerate": "55"]))
                    }

                    it("set default resrouce") {
                        metadata.defaultResource = "MyResource"
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["defaultResource": "MyResource"]))
                    }

                    it("set stream Url") {
                        metadata.streamUrl = "MyUrl"
                        updateMetadataAndInitialize()
                        expect(spy).to(haveBeenCalled(withArgs: ["streamUrl": "MyUrl"]))
                    }
                }
            }
        }
    }
}
