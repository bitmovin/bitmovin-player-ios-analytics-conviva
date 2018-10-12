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
        var playerDouble: BitmovinPlayerDouble!

        beforeEach {
            playerDouble = BitmovinPlayerDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("Player event handling") {
            beforeEach {
                do {
                    _ = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
            }
            context("initialize session") {
                it("on Play") {
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "createSession")
                    playerDouble.fakePlayEvent()
                    expect(spy).to(haveBeenCalled())
                }

                xit("on Error") {
                    // will fail until updates in branch conviva-validation-updates
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "createSession")
                    playerDouble.fakeErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }
            }

            context("not initialize session") {
                xit("on Ready") {
                    // will fail until updates in branch conviva-validation-updates
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "createSession")
                    playerDouble.fakePlayEvent()
                    expect(spy).toNot(haveBeenCalled())
                }
            }

            context("update playback state") {
                it("on Play") {
                    let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                    playerDouble.fakePlayEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PLAYING.rawValue)"])
                    )
                }

                it("on Pause") {
                    let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                    playerDouble.fakePauseEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PAUSED.rawValue)"])
                    )
                }

                it("on stall Started") {
                    let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                    playerDouble.fakeStallStartedEvent()
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_BUFFERING.rawValue)"])
                    )
                }

                context("after stalling") {
                    it("in playing state") {
                        let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                        _ = Double(aClass: playerDouble, name: "isPlaying", return: true)
                        playerDouble.fakeStallEndedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PLAYING.rawValue)"])
                        )
                    }

                    it("in paused state") {
                        let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                        _ = Double(aClass: playerDouble, name: "isPlaying", return: false)
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
                    spy = Spy(aClass: CISClientDouble.self, functionName: "cleanupSession")
                }
                it("on source unloaded") {
                    playerDouble.fakeSourceUnloadedEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on error") {
                    playerDouble.fakeErrorEvent()
                    expect(spy).to(haveBeenCalled())
                }

                it("on playback finished") {
                    let playbackStateSpy = Spy(aClass: PlayerStateManagerDouble.self,
                                               functionName: "setPlayerState")
                    playerDouble.fakePlaybackFinishedEvent()
                    expect(spy).to(haveBeenCalled())
                    expect(playbackStateSpy).to(
                        haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_STOPPED.rawValue)"])
                    )
                }
            }

            describe("ads") {
                var spy: Spy!
                beforeEach {
                    spy = Spy(aClass: CISClientDouble.self, functionName: "adStart")
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
                        _ = Double(aClass: playerDouble, name: "duration", return: TimeInterval(120))
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
                        _ = Double(aClass: playerDouble, name: "duration", return: TimeInterval(120))
                        playerDouble.fakeAdStartedEvent(position: "00:02:00.000")
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                        )
                    }
                }

                context("track ad end") {
                    beforeEach {
                        playerDouble.fakePlayEvent()
                        spy = Spy(aClass: CISClientDouble.self, functionName: "adEnd")
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
