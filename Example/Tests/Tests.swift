// https://github.com/Quick/Quick

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

// swiftlint:disable:next type_body_length
class TableOfContentsSpec: QuickSpec {
    var playerMock: BitmovinPlayerDouble = BitmovinPlayerDouble()
    // swiftlint:disable:next function_body_length
    override func spec() {
        beforeSuite {
            self.continueAfterFailure = true
            TestHelper.shared.double.mockConviva()
        }
        beforeEach {
            self.playerMock = BitmovinPlayerDouble()
            TestHelper.shared.tracker.reset()
        }

        describe("Conviva Analytics") {
            context("Player event handling") {
                beforeEach {
                    do {
                        _ = try ConvivaAnalytics(player: self.playerMock, customerKey: "")
                    } catch {
                        fail("ConvivaAnalytics failed with error: \(error)")
                    }
                }
                context("initialize session") {
                    it("on Play") {
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "createSession")
                        self.playerMock.fakePlayEvent()
                        expect(spy).to(haveBeenCalled())
                    }

                    xit("on Error") {
                        // will fail until updates in branch conviva-validation-updates
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "createSession")
                        self.playerMock.fakeErrorEvent()
                        expect(spy).to(haveBeenCalled())
                    }
                }

                context("not initialize session") {
                    xit("on Ready") {
                        // will fail until updates in branch conviva-validation-updates
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "createSession")
                        self.playerMock.fakePlayEvent()
                        expect(spy).toNot(haveBeenCalled())
                    }
                }

                context("update playback state") {
                    it("on Play") {
                        let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                        self.playerMock.fakePlayEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PLAYING.rawValue)"])
                        )
                    }

                    it("on Pause") {
                        let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                        self.playerMock.fakePauseEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PAUSED.rawValue)"])
                        )
                    }

                    it("on stall Started") {
                        let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                        self.playerMock.fakeStallStartedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_BUFFERING.rawValue)"])
                        )
                    }

                    context("after stalling") {
                        it("in playing state") {
                            let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                            _ = Double(aClass: BitmovinPlayerDouble.self, name: "isPlaying", return: true)
                            self.playerMock.fakeStallEndedEvent()
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["newState": "\(PlayerState.CONVIVA_PLAYING.rawValue)"])
                            )
                        }

                        it("in paused state") {
                            let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                            _ = Double(aClass: BitmovinPlayerDouble.self, name: "isPlaying", return: false)
                            self.playerMock.fakeStallEndedEvent()
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
                        self.playerMock.fakeSourceUnloadedEvent()
                        expect(spy).to(haveBeenCalled())
                    }

                    it("on error") {
                        self.playerMock.fakeErrorEvent()
                        expect(spy).to(haveBeenCalled())
                    }

                    it("on playback finished") {
                        let playbackStateSpy = Spy(aClass: PlayerStateManagerDouble.self,
                                                   functionName: "setPlayerState")
                        self.playerMock.fakePlaybackFinishedEvent()
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
                            self.playerMock.fakeAdStartedEvent(position: "pre")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                            )
                        }

                        it("with percentage") {
                            self.playerMock.fakeAdStartedEvent(position: "0%")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                            )
                        }

                        it("with timestamp") {
                            self.playerMock.fakeAdStartedEvent(position: "00:00:00.000")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                            )
                        }

                        it("with invalid position") {
                            self.playerMock.fakeAdStartedEvent(position: "start")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                            )
                        }

                        it("without position") {
                            self.playerMock.fakeAdStartedEvent(position: nil)
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_PREROLL.rawValue)"])
                            )
                        }
                    }

                    context("track midroll ad") {
                        it("with percentage") {
                            self.playerMock.fakeAdStartedEvent(position: "10%")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_MIDROLL.rawValue)"])
                            )
                        }

                        it("with timestamp") {
                            _ = Double(aClass: BitmovinPlayerDouble.self, name: "duration", return: TimeInterval(120))
                            self.playerMock.fakeAdStartedEvent(position: "00:01:00.000")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_MIDROLL.rawValue)"])
                            )
                        }
                    }

                    context("track postroll ad") {
                        it("with string") {
                            self.playerMock.fakeAdStartedEvent(position: "post")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                            )
                        }

                        it("with percentage") {
                            self.playerMock.fakeAdStartedEvent(position: "100%")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                            )
                        }

                        it("with timestamp") {
                            _ = Double(aClass: BitmovinPlayerDouble.self, name: "duration", return: TimeInterval(120))
                            self.playerMock.fakeAdStartedEvent(position: "00:02:00.000")
                            expect(spy).to(
                                haveBeenCalled(withArgs: ["adPosition": "\(AdPosition.ADPOSITION_POSTROLL.rawValue)"])
                            )
                        }
                    }

                    context("track ad end") {
                        beforeEach {
                            self.playerMock.fakePlayEvent()
                            spy = Spy(aClass: CISClientDouble.self, functionName: "adEnd")
                        }

                        it("on ad skipped") {
                            self.playerMock.fakeAdSkippedEvent()
                            expect(spy).to(haveBeenCalled())
                        }

                        it("on ad finished") {
                            self.playerMock.fakeAdFinishedEvent()
                            expect(spy).to(haveBeenCalled())
                        }

                        it("on ad error") {
                            self.playerMock.fakeAdErrorEvent()
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
                        _ = try ConvivaAnalytics(player: self.playerMock, customerKey: "", config: convivaConfig)
                    } catch {
                        fail("ConvivaAnalytics failed with error: \(error)")
                    }
                }
                context("when initializins session") {
                    it("set application name") {
                        self.playerMock.fakePlayEvent() // to initialize session
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                        self.playerMock.fakeTimeChangedEvent()
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

                        _ = Double(aClass: BitmovinPlayerDouble.self, name: "config", return: playerConfiguration)

                        self.playerMock.fakePlayEvent() // to initialize session
                        self.playerMock.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["assetName": "Art of Unit Test"])
                        )
                    }

                    it("set viwer id") {
                        self.playerMock.fakePlayEvent() // to initialize session
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                        self.playerMock.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["viewerId": "TestViewer"])
                        )
                    }

                    it("set custom tags") {
                        self.playerMock.fakePlayEvent() // to initialize session
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                        self.playerMock.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["Custom": "Tags", "TestRun": "Success"])
                        )
                    }
                }

                context("when updating session") {
                    it("update video duration") {
                        self.playerMock.fakePlayEvent() // to initialize session
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                        _ = Double(aClass: BitmovinPlayerDouble.self, name: "duration", return: TimeInterval(50))

                        self.playerMock.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["duration": "50"])
                        )
                    }

                    it("update stream type (VOD/Live)") {
                        self.playerMock.fakePlayEvent() // to initialize session
                        let spy = Spy(aClass: CISClientDouble.self, functionName: "updateContentMetadata")
                        _ = Double(aClass: BitmovinPlayerDouble.self, name: "isLive", return: true)

                        self.playerMock.fakeTimeChangedEvent()
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

                        _ = Double(aClass: BitmovinPlayerDouble.self, name: "config", return: playerConfiguration)
                        _ = Double(aClass: BitmovinPlayerDouble.self, name: "streamType", return: BMPMediaSourceType.HLS)

                        self.playerMock.fakePlayEvent() // to initialize session

                        self.playerMock.fakeTimeChangedEvent()
                        expect(spy).to(
                            haveBeenCalled(withArgs: ["streamUrl": "www.google.com.m3u8"])
                        )
                    }

                    it("update bitrate") {
                        self.playerMock.fakePlayEvent() // to initialize session
                        let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setBitrateKbps")

                        let videoQuality = VideoQuality(identifier: "Test",
                                                        label: "test",
                                                        bitrate: 4_000_000,
                                                        width: 1900,
                                                        height: 800)

                        _ = Double(aClass: BitmovinPlayerDouble.self, name: "videoQuality", return: videoQuality)

                        self.playerMock.fakeTimeChangedEvent()
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
                        convivaAnalytics = try ConvivaAnalytics(player: self.playerMock, customerKey: "")
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
                            _ = try ConvivaAnalytics(player: self.playerMock, customerKey: "")
                        } catch {
                            fail("ConvivaAnalytics failed with error: \(error)")
                        }
                        spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setSeekStart")
                    }

                    xit("tracked on seek") {
                        // will fail until updates in branch conviva-validation-updates
                        self.playerMock.fakeSeekEvent(position: 100)
                        expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                    }

                    xit("tracked on timeshift") {
                        // will fail until updates in branch conviva-validation-updates
                        self.playerMock.fakeTimeShiftEvent(position: 100)
                        expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                    }
                }
                context("seek finished") {
                    beforeEach {
                        spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setSeekEnd")

                        do {
                            _ = try ConvivaAnalytics(player: self.playerMock, customerKey: "")
                        } catch {
                            fail("ConvivaAnalytics failed with error: \(error)")
                        }

                        _ = Double(aClass: BitmovinPlayerDouble.self, name: "currentTime", return: TimeInterval(100))
                    }

                    it("tracked on seeked") {
                        self.playerMock.fakeSeekedEvent()
                        expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                    }

                    it("tracked on timeshifted") {
                        self.playerMock.fakeTimeShiftedEvent()
                        expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                    }
                }
            }
        }
    }
}
