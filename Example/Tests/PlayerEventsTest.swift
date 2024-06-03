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

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("player event handling") {
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
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
                    playerDouble.fakePlayEvent()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("not initialize player state manager") {
                it("when initializing conviva analytics") {
                    let spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "setPlayerInfo")
                    expect(spy).toNot(haveBeenCalled())
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
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportAdBreakStarted")
                }

                context("track preroll ad") {
                    it("with string") {
                        playerDouble.fakeAdStartedEvent(position: "pre")
                        expect(spy).to(
                            haveBeenCalled(
                                withArgs: [
                                    "adBreakInfo": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"
                                ]
                            )
                        )
                    }

                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "0%")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }

                    it("with timestamp") {
                        playerDouble.fakeAdStartedEvent(position: "00:00:00.000")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }

                    it("with invalid position") {
                        playerDouble.fakeAdStartedEvent(position: "start")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }

                    it("without position") {
                        playerDouble.fakeAdStartedEvent(position: nil)
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }
                }

                context("track midroll ad") {
                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "10%")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_MIDROLL.rawValue)"])
                        )
                    }

                    it("with timestamp") {
                        _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(120))
                        playerDouble.fakeAdStartedEvent(position: "00:01:00.000")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_MIDROLL.rawValue)"])
                        )
                    }
                }

                context("track postroll ad") {
                    it("with string") {
                        playerDouble.fakeAdStartedEvent(position: "post")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                        )
                    }

                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "100%")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                        )
                    }

                    it("with timestamp") {
                        _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(120))
                        playerDouble.fakeAdStartedEvent(position: "00:02:00.000")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adBreakInfo": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                        )
                    }
                }

                context("track ad end") {
                    beforeEach {
                        playerDouble.fakePlayEvent()
                        spy = Spy(aClass: CISVideoAnalyticsTestDouble.self, functionName: "reportAdBreakEnded")
                    }

                    it("on ad skipped") {
                        playerDouble.fakeAdSkippedEvent()
                        expect(spy).to(haveBeenCalled())
                    }

                    it("on ad finished") {
                        playerDouble.fakeAdFinishedEvent()
                        expect(spy).to(haveBeenCalled())
                    }

                    it("on ad error") {
                        playerDouble.fakeAdErrorEvent()
                        expect(spy).to(haveBeenCalled())
                    }
                }
            }
        }
    }
}
