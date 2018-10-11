// https://github.com/Quick/Quick

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

// swiftlint:disable:next type_body_length
class TableOfContentsSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        var playerDouble: BitmovinPlayerDouble!
        beforeSuite {
            self.continueAfterFailure = true
            TestHelper.shared.factory.mockConviva()
        }
        beforeEach {
            playerDouble = BitmovinPlayerDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        describe("Conviva Analytics") {
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
            context("Content meta data") {
                beforeEach {
                    do {
                        let convivaConfig = ConvivaConfiguration()
                        convivaConfig.applicationName = "Unit Tests"
                        convivaConfig.viewerId = "TestViewer"
                        convivaConfig.customTags = ["Custom": "Tags", "TestRun": "Success"]
                        _ = try ConvivaAnalytics(player: playerDouble, customerKey: "", config: convivaConfig)
                    } catch {
                        fail("ConvivaAnalytics failed with error: \(error)")
                    }
                }
                context("when initializins session") {
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

                        _ = Double(aClass: playerDouble, name: "config", return: playerConfiguration)

                        playerDouble.fakePlayEvent() // to initialize session
                        playerDouble.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["assetName": "Art of Unit Test"])
                        )
                    }

                    it("set viwer id") {
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
                        _ = Double(aClass: playerDouble, name: "duration", return: TimeInterval(50))

                        playerDouble.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["duration": "50"])
                        )
                    }

                    it("update stream type (VOD/Live)") {
                        playerDouble.fakePlayEvent() // to initialize session
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                        _ = Double(aClass: playerDouble, name: "isLive", return: true)

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

                        _ = Double(aClass: playerDouble, name: "config", return: playerConfiguration)
                        _ = Double(aClass: playerDouble, name: "streamType", return: BMPMediaSourceType.HLS)

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

                        _ = Double(aClass: playerDouble, name: "videoQuality", return: videoQuality)

                        playerDouble.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["newBitrateKbps": "4000"])
                        )
                    }
                }
            }
            context("custom events") {
                var convivaAnalytics: ConvivaAnalytics!
                beforeEach {
                    do {
                        convivaAnalytics = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                    } catch {
                        fail("ConvivaAnalytics failed with error: \(error)")
                    }
                }

                it("send custom playback event") {
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "sendCustomEvent")
                    convivaAnalytics.sendCustomPlaybackEvent(name: "Playback Event",
                                                             attributes: ["Test Case": "Playback"])
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["eventName": "Playback Event", "Test Case": "Playback"])
                    )
                }

                it("senc dustom application event") {
                    let spy = Spy(aClass: CISClientDouble.self, functionName: "sendCustomEvent")
                    convivaAnalytics.sendCustomApplicationEvent(name: "Application Event",
                                                                attributes: ["Test Case": "Application"])
                    expect(spy).to(
                        haveBeenCalled(withArgs: ["sessionKey": "\(NO_SESSION_KEY)",
                                                  "eventName": "Application Event",
                                                  "Test Case": "Application"])
                    )
                }
            }
            describe("seek / timeshift") {
                var spy: Spy!
                context("seek start") {
                    beforeEach {
                        do {
                            _ = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                        } catch {
                            fail("ConvivaAnalytics failed with error: \(error)")
                        }
                        spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setSeekStart")
                    }

                    xit("tracked on seek") {
                        // will fail until updates in branch conviva-validation-updates
                        playerDouble.fakeSeekEvent(position: 100)
                        expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                    }

                    xit("tracked on timeshift") {
                        // will fail until updates in branch conviva-validation-updates
                        playerDouble.fakeTimeShiftEvent(position: 100)
                        expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                    }
                }
                context("seek finished") {
                    beforeEach {
                        spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setSeekEnd")

                        do {
                            _ = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                        } catch {
                            fail("ConvivaAnalytics failed with error: \(error)")
                        }

                        _ = Double(aClass: playerDouble, name: "currentTime", return: TimeInterval(100))
                    }

                    it("tracked on seeked") {
                        playerDouble.fakeSeekedEvent()
                        expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                    }

                    it("tracked on timeshifted") {
                        playerDouble.fakeTimeShiftedEvent()
                        expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                    }
                }
            }
        }
    }
}
