//
//  SsaiTest.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 02.07.24.
//  Copyright © 2024 Bitmovin. All rights reserved.
//

import BitmovinConvivaAnalytics
import BitmovinPlayer
import ConvivaSDK
import Nimble
import Quick

// swiftlint:disable:next type_body_length
class SsaiTest: QuickSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        @TestState var playerDouble: BitmovinPlayerTestDouble!
        @TestState var convivaAnalytics: ConvivaAnalytics!
        @TestState var currentVideoQuality: VideoQuality!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.mockTracker.reset()

            let convivaConfig = ConvivaConfiguration()
            convivaConfig.debugLoggingEnabled = true

            do {
                convivaAnalytics = try ConvivaAnalytics(
                    player: playerDouble,
                    customerKey: "",
                    config: convivaConfig
                )
            } catch {
                fail("ConvivaAnalytics failed with error: \(error)")
            }
            var metadata = MetadataOverrides()
            metadata.assetName = "MyAsset"

            convivaAnalytics.updateContentMetadata(metadataOverrides: metadata)
            try convivaAnalytics.initializeSession()

            currentVideoQuality = VideoQuality(
                identifier: "Test",
                label: "test",
                bitrate: 4_000_000,
                codec: nil,
                width: 1_900,
                height: 800
            )

            _ = TestDouble(aClass: playerDouble!, name: "videoQuality", return: currentVideoQuality!)

            TestHelper.shared.spyTracker.reset()
        }
        describe("Ssai API") {
            describe("isAdBreakActive") {
                context("when no ad break is active") {
                    it("returns false") {
                        expect(convivaAnalytics.ssai.isAdBreakActive).to(beFalse())
                    }
                }
                context("when ad break is active") {
                    it("returns false") {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                        expect(convivaAnalytics.ssai.isAdBreakActive).to(beTrue())
                    }
                }
            }
            describe("reportAdBreakStarted") {
                let spy = Spy(
                    aClass: CISVideoAnalyticsTestDouble.self,
                    functionName: "reportAdBreakStarted"
                )
                context("when no ad break is active") {
                    context("with ad break info") {
                        it("reports ad break started") {
                            convivaAnalytics.ssai.reportAdBreakStarted(adBreakInfo: ["foo": "bar"])
                            expect(spy).to(haveBeenCalled(withArgs: [
                                "adPlayer": "\(AdPlayer.ADPLAYER_CONTENT)",
                                "adType": "\(AdTechnology.SERVER_SIDE)",
                                "adBreakInfo": ["foo": "bar"].toStringWithStableOrder()
                            ]))
                        }
                    }
                    context("without ad break info") {
                        it("reports ad break started") {
                            convivaAnalytics.ssai.reportAdBreakStarted()
                            expect(spy).to(haveBeenCalled(withArgs: [
                                "adPlayer": "\(AdPlayer.ADPLAYER_CONTENT)",
                                "adType": "\(AdTechnology.SERVER_SIDE)",
                                "adBreakInfo": "[]"
                            ]))
                        }
                    }
                }
                context("when ad break is active") {
                    it("does not report ad break started") {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                        TestHelper.shared.spyTracker.reset()
                        convivaAnalytics.ssai.reportAdBreakStarted()
                        expect(spy).toNot(haveBeenCalled())
                    }
                }
            }
            describe("reportAdBreakFinished") {
                let spy = Spy(
                    aClass: CISVideoAnalyticsTestDouble.self,
                    functionName: "reportAdBreakEnded"
                )
                context("when no ad break is active") {
                    it("does not report ad break finished") {
                        convivaAnalytics.ssai.reportAdBreakFinished()
                        expect(spy).toNot(haveBeenCalled())
                    }
                }
                context("when ad break is active") {
                    it("reports ad break finished") {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                        convivaAnalytics.ssai.reportAdBreakFinished()
                        expect(spy).to(haveBeenCalled())
                    }
                }
            }
            describe("reportAdStarted") {
                var adInfo: SsaiAdInfo!
                beforeEach {
                    adInfo = SsaiAdInfo(
                        title: "SSAI ad",
                        duration: 5,
                        id: "ssai ad ID",
                        adSystem: "ad system",
                        position: .midroll,
                        isSlate: false,
                        adStitcher: "bitmovin",
                        additionalMetadata: ["custom": 10]
                    )
                }
                context("when no ad break is active") {
                    it("does not report ad started") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdStarted"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).toNot(haveBeenCalled())
                    }
                    it("does not report ad metrics") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdMetric"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).toNot(haveBeenCalled())
                    }
                    it("does not report playback metrics") {
                        let spy = Spy(
                            aClass: CISVideoAnalyticsTestDouble.self,
                            functionName: "reportPlaybackMetric"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).toNot(haveBeenCalled())
                    }
                    it("does not update content info") {
                        let spy = Spy(
                            aClass: CISVideoAnalyticsTestDouble.self,
                            functionName: "setContentInfo"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).toNot(haveBeenCalled())
                    }
                }
                context("when ad break is active") {
                    beforeEach {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                    }
                    it("reports ad started") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdStarted"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).to(haveBeenCalled(withArgs: [
                            "adInfo": [
                                "c3.ad.id": "ssai ad ID",
                                "c3.ad.system": "ad system",
                                "c3.ad.mediaFileApiFramework": "NA",
                                "c3.ad.firstAdSystem": "NA",
                                "c3.ad.firstAdId": "NA",
                                "c3.ad.firstCreativeId": "NA",
                                "c3.ad.technology": "Server Side",
                                "c3.ad.isSlate": "false",
                                CIS_SSDK_METADATA_ASSET_NAME: "SSAI ad",
                                CIS_SSDK_METADATA_DURATION: 5.0,
                                "c3.ad.position": AdPosition.ADPOSITION_MIDROLL.rawValue,
                                "c3.ad.stitcher": "bitmovin",
                                "custom": 10,
                                CIS_SSDK_METADATA_IS_LIVE: 0,
                                CIS_SSDK_METADATA_STREAM_URL: playerDouble.fakeSource.sourceConfig.url.absoluteString,
                                "streamType": "HLS",
                                "integrationVersion": convivaAnalytics.version,
                            ].toStringWithStableOrder()
                        ]))
                    }
                    it("reports playback state ad metrics") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdMetric"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).to(haveBeenCalled(withArgs: [
                            "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                            "value": "\(PlayerState.CONVIVA_PAUSED.rawValue)",
                        ]))
                    }
                    it("reports bitrate ad metrics") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdMetric"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).to(haveBeenCalled(withArgs: [
                            "key": CIS_SSDK_PLAYBACK_METRIC_BITRATE,
                            "value": "\(Int(currentVideoQuality.bitrate / 1_000))",
                        ]))
                    }
                    it("reports resolution ad metrics") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdMetric"
                        )
                        let expectedSize = CGSize(
                            width: CGFloat(currentVideoQuality.width),
                            height: CGFloat(currentVideoQuality.height)
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).to(haveBeenCalled(withArgs: [
                            "key": CIS_SSDK_PLAYBACK_METRIC_RESOLUTION,
                            "value": "\(expectedSize.width)x\(expectedSize.height)",
                        ]))
                    }
                    it("should rendered frame rate ad metrics") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdMetric"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).to(haveBeenCalled(withArgs: [
                            "key": CIS_SSDK_PLAYBACK_METRIC_RENDERED_FRAMERATE,
                            "value": "\(25)",
                        ]))
                    }
                    it("should update content info") {
                        let spy = Spy(
                            aClass: CISVideoAnalyticsTestDouble.self,
                            functionName: "setContentInfo"
                        )
                        convivaAnalytics.ssai.reportAdStarted(adInfo: adInfo)
                        expect(spy).to(haveBeenCalled())
                    }
                }
            }
            describe("reportAdFinished") {
                context("when no ad break is active") {
                    it("does not report ad ended") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdEnded"
                        )
                        convivaAnalytics.ssai.reportAdFinished()
                        expect(spy).toNot(haveBeenCalled())
                    }
                }
                context("when ad break is active") {
                    beforeEach {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                    }
                    it("reports ad ended") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdEnded"
                        )
                        convivaAnalytics.ssai.reportAdFinished()
                        expect(spy).to(haveBeenCalled())
                    }
                }
            }
            describe("reportAdSkipped") {
                context("when no ad break is active") {
                    it("does not report ad skipped") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdSkipped"
                        )
                        convivaAnalytics.ssai.reportAdSkipped()
                        expect(spy).toNot(haveBeenCalled())
                    }
                }
                context("when ad break is active") {
                    beforeEach {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                    }
                    it("reports ad skipped") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdSkipped"
                        )
                        convivaAnalytics.ssai.reportAdSkipped()
                        expect(spy).to(haveBeenCalled())
                    }
                }
            }
            describe("update ad info") {
                var adInfo: SsaiAdInfo!
                beforeEach {
                    adInfo = SsaiAdInfo(
                        title: "SSAI ad",
                        duration: 5,
                        id: "ssai ad ID",
                        adSystem: "ad system",
                        position: .midroll,
                        isSlate: false,
                        adStitcher: "bitmovin",
                        additionalMetadata: ["custom": 10]
                    )
                }
                context("when no ad break is active") {
                    it("does not update ad info") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "setAdInfo"
                        )
                        convivaAnalytics.ssai.update(adInfo: adInfo)
                        expect(spy).toNot(haveBeenCalled())
                    }
                }
                context("when ad break is active") {
                    beforeEach {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                    }
                    it("should update ad info") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "setAdInfo"
                        )
                        convivaAnalytics.ssai.update(adInfo: adInfo)
                        expect(spy).to(haveBeenCalled(withArgs: [
                            "adInfo": [
                                "c3.ad.id": "ssai ad ID",
                                "c3.ad.system": "ad system",
                                "c3.ad.mediaFileApiFramework": "NA",
                                "c3.ad.firstAdSystem": "NA",
                                "c3.ad.firstAdId": "NA",
                                "c3.ad.firstCreativeId": "NA",
                                "c3.ad.technology": "Server Side",
                                "c3.ad.isSlate": "false",
                                CIS_SSDK_METADATA_ASSET_NAME: "SSAI ad",
                                CIS_SSDK_METADATA_DURATION: 5.0,
                                "c3.ad.position": AdPosition.ADPOSITION_MIDROLL.rawValue,
                                "c3.ad.stitcher": "bitmovin",
                                "custom": 10,
                                CIS_SSDK_METADATA_IS_LIVE: 0,
                                CIS_SSDK_METADATA_STREAM_URL: playerDouble.fakeSource.sourceConfig.url.absoluteString,
                                "streamType": "HLS",
                                "integrationVersion": convivaAnalytics.version,
                            ].toStringWithStableOrder()
                        ]))
                    }
                }
            }
            describe("reportPlaybackDeficiency") {
                context("when no ad break is active") {
                    it("does not report ad error") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdError"
                        )
                        convivaAnalytics.reportPlaybackDeficiency(message: "error", severity: .ERROR_FATAL)
                        expect(spy).toNot(haveBeenCalled())
                    }
                    context("and ending session") {
                        it("does not report ad ended") {
                            let spy = Spy(
                                aClass: CISAdAnalyticsTestDouble.self,
                                functionName: "reportAdEnded"
                            )
                            convivaAnalytics
                                .reportPlaybackDeficiency(
                                    message: "error",
                                    severity: .ERROR_FATAL,
                                    endSession: true
                                )
                            expect(spy).toNot(haveBeenCalled())
                        }
                    }
                }
                context("when ad break is active") {
                    beforeEach {
                        convivaAnalytics.ssai.reportAdBreakStarted()
                    }
                    it("reports ad error") {
                        let spy = Spy(
                            aClass: CISAdAnalyticsTestDouble.self,
                            functionName: "reportAdError"
                        )
                        convivaAnalytics.reportPlaybackDeficiency(message: "error", severity: .ERROR_FATAL)
                        expect(spy).to(haveBeenCalled(withArgs: [
                            "errorMessage": "error",
                            "severity": "\(ErrorSeverity.ERROR_FATAL)"
                        ]))
                    }
                    context("and ending session") {
                        it("reports ad ended") {
                            let spy = Spy(
                                aClass: CISAdAnalyticsTestDouble.self,
                                functionName: "reportAdEnded"
                            )
                            convivaAnalytics
                                .reportPlaybackDeficiency(
                                    message: "error",
                                    severity: .ERROR_FATAL,
                                    endSession: true
                                )
                            expect(spy).to(haveBeenCalled())
                        }
                        it("reports ad break ended") {
                            let spy = Spy(
                                aClass: CISVideoAnalyticsTestDouble.self,
                                functionName: "reportAdBreakEnded"
                            )
                            convivaAnalytics
                                .reportPlaybackDeficiency(
                                    message: "error",
                                    severity: .ERROR_FATAL,
                                    endSession: true
                                )
                            expect(spy).to(haveBeenCalled())
                        }
                        it("resets ad break state") {
                            convivaAnalytics
                                .reportPlaybackDeficiency(
                                    message: "error",
                                    severity: .ERROR_FATAL,
                                    endSession: true
                                )
                            expect(convivaAnalytics.ssai.isAdBreakActive).to(beFalse())
                        }
                    }
                    context("and not ending session") {
                        it("does not report ad ended") {
                            let spy = Spy(
                                aClass: CISAdAnalyticsTestDouble.self,
                                functionName: "reportAdEnded"
                            )
                            convivaAnalytics
                                .reportPlaybackDeficiency(
                                    message: "error",
                                    severity: .ERROR_FATAL,
                                    endSession: false
                                )
                            expect(spy).toNot(haveBeenCalled())
                        }
                        it("does not reset ad break state") {
                            convivaAnalytics
                                .reportPlaybackDeficiency(
                                    message: "error",
                                    severity: .ERROR_FATAL,
                                    endSession: false
                                )
                            expect(convivaAnalytics.ssai.isAdBreakActive).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}
