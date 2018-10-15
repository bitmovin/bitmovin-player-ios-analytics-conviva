//
//  ContentMetaDataTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class ContentMetaDataSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        var playerDouble: BitmovinPlayerDouble!

        beforeEach {
            playerDouble = BitmovinPlayerDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("content meta data") {
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
                do {
                    let convivaConfig = ConvivaConfiguration()
                    convivaConfig.applicationName = "Unit Tests"
                    convivaConfig.viewerId = "TestViewer"
                    convivaConfig.customTags = ["Custom": "Tags", "TestRun": "Success"]
                    convivaAnalytics = try ConvivaAnalytics(player: playerDouble,
                                                            customerKey: "",
                                                            config: convivaConfig)
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
            }
            afterEach {
                // hack to silence xcode warning that variable is unused
                if convivaAnalytics != nil {
                    convivaAnalytics = nil
                }
            }
            context("when initializing session") {
                it("set application name") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["applicationName": "Unit Tests"])
                    )
                }

                it("set asset name") {
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")

                    let playerConfiguration = PlayerConfiguration()
                    let sourceItem = SourceItem(url: URL(string: "www.google.com.m3u8")!)!
                    sourceItem.itemTitle = "Art of Unit Test"
                    playerConfiguration.sourceItem = sourceItem

                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfiguration)

                    playerDouble.fakePlayEvent() // to initialize session
                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["assetName": "Art of Unit Test"])
                    )
                }

                it("set viewer id") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["viewerId": "TestViewer"])
                    )
                }

                it("set custom tags") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["Custom": "Tags", "TestRun": "Success"])
                    )
                }
            }

            context("when updating session") {
                it("update video duration") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                    _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(50))

                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["duration": "50"])
                    )
                }

                it("update stream type (VOD/Live)") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                    _ = TestDouble(aClass: playerDouble, name: "isLive", return: true)

                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["streamType": "\(StreamType.CONVIVA_STREAM_LIVE.rawValue)"])
                    )
                }

                it("update stream url") {
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")

                    let playerConfiguration = PlayerConfiguration()
                    let sourceItem = SourceItem(url: URL(string: "www.google.com.m3u8")!)!
                    sourceItem.itemTitle = "Art of Unit Test"
                    playerConfiguration.sourceItem = sourceItem

                    _ = TestDouble(aClass: playerDouble, name: "config", return: playerConfiguration)
                    _ = TestDouble(aClass: playerDouble, name: "streamType", return: BMPMediaSourceType.HLS)

                    playerDouble.fakePlayEvent() // to initialize session

                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["streamUrl": "www.google.com.m3u8"])
                    )
                }

                it("update bitrate") {
                    playerDouble.fakePlayEvent() // to initialize session
                    let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setBitrateKbps")

                    let videoQuality = VideoQuality(identifier: "Test",
                                                    label: "test",
                                                    bitrate: 4_000_000,
                                                    width: 1900,
                                                    height: 800)

                    _ = TestDouble(aClass: playerDouble, name: "videoQuality", return: videoQuality)

                    playerDouble.fakeTimeChangedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newBitrateKbps": "4000"])
                    )
                }
            }
        }
    }
}
