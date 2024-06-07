// swiftlint:disable file_length
//
//  PlayerEventTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import BitmovinConvivaAnalytics
import BitmovinPlayer
import ConvivaSDK
import Nimble
import Quick

// swiftlint:disable:next type_body_length
class PlayerEventsTest: QuickSpec {
    // swiftlint:disable:next function_body_length
    override class func spec() {
        var playerDouble: BitmovinPlayerTestDouble!
        var convivaAnalytics: ConvivaAnalytics!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
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
        }

        afterEach {
            if convivaAnalytics != nil {
                convivaAnalytics = nil
            }
        }

        context("player event handling") {
            context("initialize session") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportPlaybackRequested")
                }

                it("on play") {
                    playerDouble.fakePlayEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on player error") {
                    playerDouble.fakePlayerErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on source error") {
                    playerDouble.fakeSourceErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("not initialize session") {
                it("on ready") {
                    let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportPlaybackRequested")
                    playerDouble.fakeReadyEvent()
                    expect(spy).toNot(haveBeenCalled())
                }
            }

            context("initialize player state manager") {
                it("on play") {
                    let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "setPlayerInfo")
                    let adAnalyticsSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "setPlayerInfo")
                    playerDouble.fakePlayEvent()
                    expect(spy).to(haveBeenCalled())
                    expect(adAnalyticsSpy).to(haveBeenCalled())
                }
            }

            context("not initialize player state manager") {
                it("when initializing conviva analytics") {
                    let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "setPlayerInfo")
                    let adAnalyticsSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "setPlayerInfo")
                    expect(spy).toNot(haveBeenCalled())
                    expect(adAnalyticsSpy).toNot(haveBeenCalled())
                }
            }

            context("deinitialize player state manager") {
                it("on playback finished") {
                    let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportPlaybackEnded")
                    playerDouble.fakePlayEvent()
                    playerDouble.fakePlaybackFinishedEvent()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("update playback state") {
                 var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportPlaybackMetric")
                    playerDouble.fakePlayEvent()
                }

                context("not") {
                    it("on play") {
                        playerDouble.fakePlayEvent()
                        expect(spy).notTo(
                            haveBeenCalled(withArgs: [
                                CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                            ])
                        )
                    }
                }

                it("on playing") {
                    playerDouble.fakePlayingEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: [
                            CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                        ])
                    )
                }

                it("on pause") {
                    playerDouble.fakePauseEvent()
                    expect(spy).to(
                        haveBeenCalled(
                            withArgs: [
                                CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_PAUSED.rawValue)"
                            ]
                        )
                    )
                }
                it("on stall started/ Stall Ended wait 0.10 seconds") {
                    playerDouble.fakePlayingEvent()
                    playerDouble.fakeStallStartedEvent()
                    playerDouble.fakeStallEndedEvent()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                        expect(spy).notTo(
                            haveBeenCalled(
                                withArgs: [
                                    CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_BUFFERING.rawValue)"
                                ]
                            )
                        )
                    }
                }
                it("on stall started/Stall Ended no wait") {
                    playerDouble.fakePlayingEvent()
                    playerDouble.fakeStallStartedEvent()
                    playerDouble.fakeStallEndedEvent()
                    expect(spy).toEventuallyNot(
                            haveBeenCalled(
                                withArgs: [
                                    CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_BUFFERING.rawValue)"
                                ]
                            )
                        )
                }
                it("on stall started / Stall Ended after 0.10 seconds") {
                    playerDouble.fakePlayingEvent()
                    playerDouble.fakeStallStartedEvent()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                        playerDouble.fakeStallEndedEvent()
                        expect(spy).to(
                            haveBeenCalled(
                                withArgs: [
                                    CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_BUFFERING.rawValue)"
                                ]
                            )
                        )
                    }
                }
                it("on stall started") {
                    playerDouble.fakeStallStartedEvent()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                        expect(spy).to(
                            haveBeenCalled(
                                withArgs: [
                                    CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_BUFFERING.rawValue)"
                                ]
                            )
                        )
                    }
                }

                context("after stalling") {
                    beforeEach {
                        playerDouble.fakePlayingEvent()
                        playerDouble.fakeStallStartedEvent()
                    }

                    it("in playing state") {
                        _ = TestDouble(aClass: playerDouble, name: "isPlaying", return: true)
                        playerDouble.fakeStallEndedEvent()
                        expect(spy).to(
                            haveBeenCalled(
                                withArgs: [
                                    CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("in paused state") {
                        _ = TestDouble(aClass: playerDouble, name: "isPlaying", return: false)
                        playerDouble.fakeStallEndedEvent()
                        expect(spy).to(
                            haveBeenCalled(
                                withArgs: [
                                    CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_PAUSED.rawValue)"
                                ]
                            )
                        )
                    }
                }
            }

            context("end session") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportPlaybackEnded")
                    playerDouble.fakePlayEvent()
                }

                it("on source unloaded") {
                    playerDouble.fakeSourceUnloadedEvent()
                    expect(spy).toEventually(haveBeenCalled())
                }

                it("on player error") {
                    playerDouble.fakePlayerErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on source error") {
                    playerDouble.fakeSourceErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on playback finished") {
                    let playbackStateSpy = Spy(
                        aClass: CISVideoAnalyticsTestDouble.self,
                        functionName: "reportPlaybackMetric"
                    )

                    playerDouble.fakePlayEvent()
                    playerDouble.fakePlaybackFinishedEvent()
                    expect(spy).to(haveBeenCalled())
                    expect(playbackStateSpy).to(
                        haveBeenCalled(withArgs: [
                            CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_STOPPED.rawValue)"
                        ])
                    )
                }

                it("on playlist transition") {
                    let playbackStateSpy = Spy(
                        aClass: CISVideoAnalyticsTestDouble.self,
                        functionName: "reportPlaybackMetric"
                    )

                    playerDouble.fakePlayEvent()
                    playerDouble.fakePlaylistTransitionEvent()
                    expect(spy).to(haveBeenCalled())
                    expect(playbackStateSpy).to(
                        haveBeenCalled(withArgs: [
                            CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE: "\(PlayerState.CONVIVA_STOPPED.rawValue)"
                        ])
                    )
                }

                it("on destroy") {
                    playerDouble.fakeDestroyEvent()
                    expect(spy).to(haveBeenCalled())
                }

                describe("with on source unloaded / on error workaround") {
                    it("when on source unloaded is followed by on player error") {
                        // simulating a mid stream error so simulate a session initialization first
                        playerDouble.fakePlayEvent()

                        // reset spies to add ability to test against createSession has not been called
                        TestHelper.shared.spyTracker.reset()
                        let errorSpy = Spy(
                            aClass: CISVideoAnalyticsTestDouble.self,
                            functionName: "reportPlaybackError"
                        )
                        let sessionSpy = Spy(
                            aClass: CISVideoAnalyticsTestDouble.self,
                            functionName: "reportPlaybackRequested"
                        )

                        // default sdk error handling is to call unload and this will be triggered first
                        // but we want to track the error event in the same session
                        playerDouble.fakeSourceUnloadedEvent()
                        playerDouble.fakePlayerErrorEvent()

                        expect(errorSpy).to(haveBeenCalled())
                        // should not be called while session is still valid (would be invalidated in end session)
                        expect(sessionSpy).toNot(haveBeenCalled())
                    }

                    it("when on source unloaded is followed by on source error") {
                        // simulating a mid stream error so simulate a session initialization first
                        playerDouble.fakePlayEvent()

                        // reset spies to add ability to test against createSession has not been called
                        TestHelper.shared.spyTracker.reset()
                        let errorSpy = Spy(
                            aClass: CISVideoAnalyticsTestDouble.self,
                            functionName: "reportPlaybackError"
                        )
                        let sessionSpy = Spy(
                            aClass: CISVideoAnalyticsTestDouble.self,
                            functionName: "reportPlaybackRequested"
                        )

                        // default sdk error handling is to call unload and this will be triggered first
                        // but we want to track the error event in the same session
                        playerDouble.fakeSourceUnloadedEvent()
                        playerDouble.fakeSourceErrorEvent()

                        expect(errorSpy).to(haveBeenCalled())
                        // should not be called while session is still valid (would be invalidated in end session)
                        expect(sessionSpy).toNot(haveBeenCalled())
                    }
                }
            }

            describe("ads") {
                let adStartedSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "reportAdStarted")
                let adLoadedSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "reportAdLoaded")
                let adMetricSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "reportAdMetric")

                let baseAdInfo = [
                    "c3.ad.technology": "Client Side",
                    "Conviva.duration": 2.0,
                    "Conviva.frameworkName": "Google IMA SDK",
                    "Conviva.frameworkVersion": "NA",
                    "c3.ad.firstAdId": "NA",
                    "c3.ad.firstAdSystem": "NA",
                    "c3.ad.firstCreativeId": "NA",
                    "c3.ad.id": "NA",
                    "c3.ad.mediaFileApiFramework": "NA",
                    "c3.ad.system": "NA"
                ]

                context("report ad break start") {
                    it("on ad break started event") {
                        let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportAdBreakStarted")

                        playerDouble.fakeAdBreakStartedEvent(position: 0.0)

                        expect(spy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "adPlayer": "\(AdPlayer.ADPLAYER_CONTENT)",
                                    "adType": "\(AdTechnology.CLIENT_SIDE)"
                                ]
                            )
                        )
                    }
                }

                context("report ad break ended") {
                    it("on ad break finished event") {
                        let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportAdBreakEnded")

                        playerDouble.fakeAdBreakFinishedEvent()

                        expect(spy).to(haveBeenCalled())
                    }
                }

                context("track preroll ad") {
                    var expectedAdInfo = baseAdInfo
                    expectedAdInfo["c3.ad.position"] = "\(AdPosition.ADPOSITION_PREROLL.rawValue)"

                    let expectedAdInfoArgs = ["adInfo": expectedAdInfo.toStringWithStableOrder()]

                    it("with string") {
                        playerDouble.fakeAdStartedEvent(position: "pre")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "0%")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("with timestamp") {
                        playerDouble.fakeAdStartedEvent(position: "00:00:00.000")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("with invalid position") {
                        playerDouble.fakeAdStartedEvent(position: "start")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("without position") {
                        playerDouble.fakeAdStartedEvent(position: nil)

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }
                }

                context("track midroll ad") {
                    var expectedAdInfo = baseAdInfo
                    expectedAdInfo["c3.ad.position"] = "\(AdPosition.ADPOSITION_MIDROLL.rawValue)"

                    let expectedAdInfoArgs = ["adInfo": expectedAdInfo.toStringWithStableOrder()]

                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "10%")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("with timestamp") {
                        _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(120))
                        playerDouble.fakeAdStartedEvent(position: "00:01:00.000")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }
                }

                context("track postroll ad") {
                    var expectedAdInfo = baseAdInfo
                    expectedAdInfo["c3.ad.position"] = "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"

                    let expectedAdInfoArgs = ["adInfo": expectedAdInfo.toStringWithStableOrder()]

                    it("with string") {
                        playerDouble.fakeAdStartedEvent(position: "post")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "100%")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }

                    it("with timestamp") {
                        _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(120))
                        playerDouble.fakeAdStartedEvent(position: "00:02:00.000")

                        expect(adStartedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adLoadedSpy).to(haveBeenCalled(withArgs: expectedAdInfoArgs))
                        expect(adMetricSpy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "key": CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                    "value": "\(PlayerState.CONVIVA_PLAYING.rawValue)"
                                ]
                            )
                        )
                    }
                }

                context("track ad end") {
                    let adEndedSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "reportAdEnded")

                    beforeEach {
                        playerDouble.fakePlayEvent()
                    }

                    it("on ad finished") {
                        playerDouble.fakeAdFinishedEvent()
                        expect(adEndedSpy).to(haveBeenCalled())
                    }
                }

                context("track ad skipped") {
                    let adSkippedSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "reportAdSkipped")

                    beforeEach {
                        playerDouble.fakePlayEvent()
                    }

                    it("on ad skipped") {
                        playerDouble.fakeAdSkippedEvent()
                        expect(adSkippedSpy).to(haveBeenCalled())
                    }
                }

                context("track ad failed") {
                    let adFailedSpy = Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "reportAdFailed")

                    beforeEach {
                        playerDouble.fakePlayEvent()
                    }

                    it("on ad error") {
                        playerDouble.fakeAdErrorEvent()
                        expect(adFailedSpy).to(haveBeenCalled(withArgs: ["errorMessage": "Error Message"]))
                    }
                }
            }
        }

        describe("releasing") {
            describe("does a cleanup") {
                beforeEach {
                    convivaAnalytics.release()
                }

                it("on the video analytics") {
                    expect(Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "cleanup")).to(haveBeenCalled())
                }

                it("on the ad analytics") {
                    expect(Spy(aClass: CISAdAnalyticsTestDouble.self, functionName: "cleanup")).to(haveBeenCalled())
                }

                it("on the analytics") {
                    expect(Spy(aClass: CISAnalyticsTestDouble.self, functionName: "cleanup")).to(haveBeenCalled())
                }
            }
        }
    }
}
