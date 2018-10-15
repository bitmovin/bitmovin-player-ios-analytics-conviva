// https://github.com/Quick/Quick

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class SeekTimeshiftSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        describe("seek / timeshift") {
            var spy: Spy!
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
                do {
                    convivaAnalytics = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
                spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "setSeekStart")
            }

            afterEach {
                if convivaAnalytics != nil {
                    convivaAnalytics = nil
                }
            }

            describe("after an initial play event") {
                beforeEach {
                    playerDouble.fakePlayEvent() // to initialize the session
                }

                context("track seek start") {
                    it("on seek") {
                        playerDouble.fakeSeekEvent(position: 100)
                        expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                    }

                    it("on timeshift") {
                        playerDouble.fakeTimeShiftEvent(position: 100)
                        expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                    }
                }

                context("track seek finished") {
                    beforeEach {
                        spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "setSeekEnd")
                        _ = TestDouble(aClass: playerDouble, name: "currentTime", return: TimeInterval(100))
                    }

                    it("on seeked") {
                        playerDouble.fakeSeekedEvent()
                        expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                    }

                    it("on timeshifted") {
                        playerDouble.fakeTimeShiftedEvent()
                        expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                    }
                }
            }

            describe("does not track seek") {
                it("when play was never called") {
                    playerDouble.fakeSeekEvent(position: 100)
                    expect(spy).toNot(haveBeenCalled())
                }
            }
        }
    }
}
