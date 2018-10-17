//
//  PlayerEventTests.swift
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

class PlayerEventsSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("player event handling") {
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

                it("on play") {
                    playerDouble.fakePlayEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on error") {
                    playerDouble.fakeErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("not initialize session") {
                it("on ready") {
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")
                    playerDouble.fakeReadyEvent()
                    expect(spy).toNot(haveBeenCalled())
                }
            }

            context("initialize player state manager") {
                it("on play") {
                    let spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "init")
                    playerDouble.fakePlayEvent()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("not initialize player state manager") {
                it("when initializing conviva analytics") {
                    let spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "init")
                    expect(spy).toNot(haveBeenCalled())
                }
            }

            context("deinitialize player state manager") {
                it("on playback finished") {
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "releasePlayerStateManager")
                    playerDouble.fakePlaybackFinishedEvent()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("update playback state") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "setPlayerState")
                }

                it("on play") {
                    playerDouble.fakePlayEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PLAYING.rawValue)"])
                    )
                }

                it("on pause") {
                    playerDouble.fakePauseEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PAUSED.rawValue)"])
                    )
                }

                it("on stall started") {
                    playerDouble.fakeStallStartedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_BUFFERING.rawValue)"])
                    )
                }

                context("after stalling") {
                    beforeEach {
                        playerDouble.fakeStallStartedEvent()
                    }

                    it("in playing state") {
                        _ = TestDouble(aClass: playerDouble, name: "isPlaying", return: true)
                        playerDouble.fakeStallEndedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PLAYING.rawValue)"])
                        )
                    }

                    it("in paused state") {
                        _ = TestDouble(aClass: playerDouble, name: "isPlaying", return: false)
                        playerDouble.fakeStallEndedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PAUSED.rawValue)"])
                        )
                    }
                }
            }

            context("end session") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISClientTestDouble.self, functionName: "cleanupSession")
                }

                it("on source unloaded") {
                    playerDouble.fakeSourceUnloadedEvent()
                    DispatchQueue.main.async {
                        expect(spy).to(haveBeenCalled())
                    }
                }

                it("on error") {
                    playerDouble.fakeErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on playback finished") {
                    let playbackStateSpy = Spy(aClass: PlayerStateManagerTestDouble.self,
                                               functionName: "setPlayerState")
                    playerDouble.fakePlaybackFinishedEvent()
                    expect(spy).to(haveBeenCalled())
                    expect(playbackStateSpy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_STOPPED.rawValue)"])
                    )
                }

                describe("with on source unloaded / on error workaround") {
                    it("when on source unloaded is followed by on error") {
                        // simulating a mid stream error so simulate a session initialization first
                        playerDouble.fakePlayEvent()

                        // reset spies to add ability to test against createSession has not been called
                        TestHelper.shared.spyTracker.reset()
                        let errorSpy = Spy(aClass: CISClientTestDouble.self, functionName: "reportError")
                        let sessionSpy = Spy(aClass: CISClientTestDouble.self, functionName: "createSession")

                        // default sdk error handling is to call unload and this will be triggered first
                        // but we want to track the error event in the same session
                        playerDouble.fakeSourceUnloadedEvent()
                        playerDouble.fakeErrorEvent()

                        expect(errorSpy).to(haveBeenCalled())
                        // should not be called while session is still valid (would be invalidated in end session)
                        expect(sessionSpy).toNot(haveBeenCalled())
                    }
                }
            }

            describe("ads") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISClientTestDouble.self, functionName: "adStart")
                }

                context("track preroll ad") {
                    it("with string") {
                        playerDouble.fakeAdStartedEvent(position: "pre")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }

                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "0%")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }

                    it("with timestamp") {
                        playerDouble.fakeAdStartedEvent(position: "00:00:00.000")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }

                    it("with invalid position") {
                        playerDouble.fakeAdStartedEvent(position: "start")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }

                    it("without position") {
                        playerDouble.fakeAdStartedEvent(position: nil)
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                        )
                    }
                }

                context("track midroll ad") {
                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "10%")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_MIDROLL.rawValue)"])
                        )
                    }

                    it("with timestamp") {
                        _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(120))
                        playerDouble.fakeAdStartedEvent(position: "00:01:00.000")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_MIDROLL.rawValue)"])
                        )
                    }
                }

                context("track postroll ad") {
                    it("with string") {
                        playerDouble.fakeAdStartedEvent(position: "post")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                        )
                    }

                    it("with percentage") {
                        playerDouble.fakeAdStartedEvent(position: "100%")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                        )
                    }

                    it("with timestamp") {
                        _ = TestDouble(aClass: playerDouble, name: "duration", return: TimeInterval(120))
                        playerDouble.fakeAdStartedEvent(position: "00:02:00.000")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                        )
                    }
                }

                context("track ad end") {
                    beforeEach {
                        playerDouble.fakePlayEvent()
                        spy = Spy(aClass: CISClientTestDouble.self, functionName: "adEnd")
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
